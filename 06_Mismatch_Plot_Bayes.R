library(tidyverse); library(lubridate); library(attenPlot); library(sp); library(rgdal); library(ggridges); library(viridis); library(ggthemes); library(SSN); library(maptools);library(rstan)
#Get Emergence Probability data.
emerg = read_rds("Data_04_EmergProbs_Bayes.rds") 
#Eliminate sites/years with no probability density
emerg = emerg %>% group_by(geolocid, spawn_year) %>% summarise(dens_tot = sum(density)) %>% 
	filter(dens_tot == 0) %>% mutate(elim = "yes") %>% left_join(emerg,.) %>% filter(is.na(elim)) %>% 
	select(1:4)

#Read in distance and travel timing estimate data.
dist = read_rds("Data_06_DistanceTravelRef.rds")
#Add distance and timing columns to emergence data.
estuary = emerg %>% left_join(., dist, by = c("geolocid","spawn_year"="year")) %>%
	mutate(arriveDate = date + travelDays_vel) %>% 
	select(geolocid,spawn_year,arriveDate,density,Rdist,latitude,longitude)

#Phytoplankton Data from Dr. Allen.
phyto = read_delim(file = "Data_05_bloomdate_31mar2016.dat", skip = 3, delim = " ")
#Observed In-Situ phytoplankton data from Allen et al. (2013)
phyObs = read_csv(file = "Data_05_PhytoDigi.csv", col_names = c("Year","bloom"))
#Join and incorporate observed data with modelled.
phyto = left_join(phyto, phyObs, by = "Year"); rm(phyObs)
phyto$bloom = if_else(is.na(phyto$bloom),phyto$YearDay,phyto$bloom)
#Add a date of bloom.
phyto$bloom_date = ymd(strptime(paste(as.character(phyto$Year),
																			as.character(phyto$bloom)),
																format="%Y %j"))+14
#Simplify
phyto  = phyto %>% select(Year,bloom_date) %>% rename("year" = "Year")

#Create cross-year distibution of estuary arrival dates.
set.seed(123)
subPhyto = phyto %>% group_by(year) %>% do({
	data.frame(EDOY =ymd("2000-01-01") + round(rnorm(1000, mean = yday(.$bloom_date), sd = 5),0))
}) %>% ungroup() %>% sample_n(size = 100)

#Determine the difference between the peak arrival date and peak zooplankton bloom
estuary = estuary %>% group_by(geolocid, spawn_year) %>% mutate(year = spawn_year+1) %>% 
	left_join(.,phyto) %>% 
	mutate(date_std = ymd(arriveDate) + years(1999-min(year(arriveDate))),
				 groups = paste(as.character(geolocid),as.character(spawn_year),sep="_"),
				 miss_days = as.numeric(bloom_date - arriveDate[which.max(density)]),
				 prob_dens = density/sum(density,na.rm = T),
				 prob_match = round((sum(density[which(arriveDate<(bloom_date+15) & arriveDate>(bloom_date-15))],
				 												na.rm = T)/sum(density, na.rm = T))*100,1))

#Eliminate sites/years with incomplete probability distributions.
estuary = estuary %>% group_by(geolocid, spawn_year) %>% 
	filter(arriveDate==max(arriveDate), prob_dens > 0.01) %>% 
	select(geolocid, spawn_year) %>% mutate(elim = "yes") %>% left_join(estuary,.) %>% 
	filter(is.na(elim)) %>% select(-elim)

############################
#Climate Correlation Values#
############################

#Prediction Site Climate
preds = read.csv("./02_SpawnTiming/Spawn Site-Climate Data/preds_1957-2011AMT.csv",header = T)
names(preds) = tolower(names(preds))
#Select columns of interest.
preds = preds %>% select(id1,latitude,longitude,year,elevation,
												 starts_with("tmax"),starts_with("tmin"),
												 starts_with("tave"),starts_with("ppt"))
#Create a long format dataset.
preds = preds %>% gather(key = "clim_var", value = "clim_val", 6:53)

#Estuary Climate Variables
estClim = read.csv(file = "./02_SpawnTiming/Spawn Site-Climate Data/EstuaryClimate/site_1967-2011AMT.csv", header = T)
names(estClim) = tolower(names(estClim))
#Select columns of interest.
estClim = estClim %>% select(id1,latitude,longitude,year,elevation,starts_with("tmax"),starts_with("tmin"),starts_with("tave"),starts_with("ppt"))
#Create a long format dataset.
estClim = estClim %>% gather(key = "clim_var", value = "EstClimVal", 6:53)

#Combine
climate = estClim %>% select(year, clim_var, EstClimVal) %>% left_join(preds, ., by = c("year","clim_var"))
climate = climate %>% filter(year >= 1967, year <= 2011) %>%
	mutate(resid = clim_val - EstClimVal) %>%
	select(id1, year, clim_var, resid, clim_val, EstClimVal)
#Add a month variable to the long dataset.
climate = climate %>% do({
	end = nchar(.[,3])
	data.frame(month = as.numeric(substr(.[,3], end-1, end)),
						 var = substr(.[,3], 1, end-2))
}) %>% bind_cols(climate,.)

#Add a column generalizing time to seasons.
climate = climate %>% mutate(season = if_else(month >= 7, "fall", "spring"))
#Adjust the year column so they span fall to spring rather than spring to fall.
climate = climate %>% mutate(yearAdj = if_else(season == "fall", as.numeric(year), as.numeric(year)-1)) %>% arrange(id1, var, year, month) %>% filter(yearAdj > 1966, yearAdj < 2011)
#Standardize the climate variables between 0-1.
climate = climate %>% group_by(yearAdj, clim_var) %>%
	mutate(residSTD = zero_one(abs(resid)))
#Accumulate standardized deviations from Estuary climate metrics. Determine correlation for each year between the estuary and the temperature monitoring locations.
climate = climate %>% group_by(id1, yearAdj) %>%
	summarise(climDiverg = sum(residSTD),
						cor = cor(clim_val, EstClimVal))
#Output climate divergence to a shapefile.
sp = preds %>% select(id1, latitude, longitude) %>% distinct() %>% left_join(climate, ., by = "id1")
sp = data.frame(sp)
sp = SpatialPointsDataFrame(coords = sp[,c("longitude","latitude")], data = sp[,c("id1","yearAdj","climDiverg","cor")], proj4string = CRS("+init=epsg:4326"))
sp = spTransform(sp, CRS("+init=epsg:3005"))
writeOGR(obj = sp, dsn = "./maps/", layer = "ClimDiverg", driver = "ESRI Shapefile", overwrite_layer = T)

#Remove No Longer Used Objects
rm(estClim, preds, sp)
############################

#Add the climate/region data.
estuary = left_join(estuary, climate, by=c("spawn_year"="yearAdj", "geolocid"="id1")) %>%
	mutate(region = if_else(climDiverg<15, 1,
													if_else(climDiverg<24.5 & climDiverg>15, 2,
																	if_else(climDiverg<28.9 & climDiverg> 24.5, 2.5,3))))

#Distributions plot
ggplot(NULL) + 
	geom_vline(data = subPhyto, aes(xintercept = EDOY), color = "#BDBDBD", alpha = 0.2, size = 1) + 
	geom_ridgeline(data = estuary,
								 aes(x = date_std, y = climDiverg, height = prob_dens, 
								 		group = groups, fill = miss_days),
								 color = "white", alpha = 0.7,
								 lwd = 0.5,
								 scale = 7, show.legend = T) +
	theme_tufte() +
	scale_x_date(date_labels = "%b", date_breaks = "3 month",
							 limits = c(ymd("1999-10-01"), ymd("2000-09-01"))) +
	labs(x = "Arrival Date", y = "Climate Dissimilarity", fill = "Phenological-\nMismatch\n(days)") + 
	facet_wrap(~region, scales = "free_y", nrow = 1, ncol = 4) +
	scale_fill_viridis() +
	theme(strip.background = element_blank(),	strip.text.x = element_blank(),
				plot.background = element_rect(fill = "transparent",colour = NA),
				panel.background = element_rect(fill = "transparent", colour = NA),
				legend.title.align = .5)

ggsave(filename = "./drafts/99_figures/04_distributions_bayes.pdf",
			 device = "pdf", width = 7.5, height = 6.5, units = "in")


#################
## Subset Only ##
#################

#Read in the .ssn network data and subset by above.
network = importSSN("/Users/kylechezik/sfuvault/Timing-Mismatch_Pink-Salmon/02_SpawnTiming/lsn/sites_overlap.ssn")
#Add combined column of site and year
df = getSSNdata.frame(network); df$groups = paste(df$geolocid,df$year_,sep="_")
network = putSSNdata.frame(df,network); rm(df)
#Subset to those sites and years in the above analysis
network = subsetSSN(ssn = network, filename = "/Users/kylechezik/sfuvault/Timing-Mismatch_Pink-Salmon/02_SpawnTiming/lsn/sites_overlap_bayes.ssn", subset = groups %in% unique(estuary$groups))

#################
### Continue ####
#################

network = importSSN("/Users/kylechezik/sfuvault/Timing-Mismatch_Pink-Salmon/02_SpawnTiming/lsn/sites_overlap_bayes.ssn")

#Read in other prediction points.
network = importPredpts(network, "BK_2010", obj.type = "ssn")
network = importPredpts(network, "BK_1970", obj.type = "ssn")

#Create distance matrix.
createDistMat(network, predpts = "BK_2010", o.write = F, amongpreds = F)
createDistMat(network, predpts = "BK_1970", o.write = F, amongpreds = F)

#Update 
df_obs = getSSNdata.frame(network) %>% rename("year" = "year_") %>% 
	select(pid, rid, geolocid, year, upDist, afvArea, groups)
df_obs = estuary %>% ungroup() %>% select(climDiverg, prob_match, groups) %>% distinct() %>% 
	left_join(df_obs,.,by="groups")
df_obs = df_obs %>% mutate(lgt_prob = if_else(prob_match==0,boot::logit((prob_match/100)+0.001),boot::logit(prob_match/100)))

#Function to center and scale data.
sc_func = function(x){
	(x-mean(x))/sd(x)
}
#Scale and center predictor and logit transform the reponse.
df_obs = arrange(df_obs, year, geolocid) %>% 
	mutate(climDiverg_sc = sc_func(climDiverg),
				 upDist_lg = sc_func(log(upDist)),
				 year_no = as.numeric(factor(year)),
				 geolocid_no = as.numeric(factor(geolocid))) %>% 
	arrange(pid)

#Observed and random effects design matrices.
x = model.matrix(lgt_prob ~ climDiverg_sc, data = df_obs) # Make Matrix
#Get stream distance matrix and calculate the full stream distance 
distObs = getStreamDistMat(network)$dist.net1
dist.H.o = distObs + t(distObs)
b.mat = (pmin(distObs,t(distObs))==0)*1

# Set up multiple cores.
options(mc.cores = parallel::detectCores(), auto_write = TRUE)
# Compile Model.
compile = stan_model("~/sfuvault/Timing-Mismatch_Pink-Salmon/overlap_ssn.stan")
#Run model.
mod = sampling(compile, data = list(N = nrow(x),
																		K = ncol(x),
																		X = x,
																		y = df_obs$lgt_prob,
																		n_r1 = max(df_obs$year_no),
																		x_r1 = df_obs$year_no,
																		n_r2 = max(df_obs$geolocid_no),
																		x_r2 = df_obs$geolocid_no,
																		dist = round(dist.H.o/1408253,6),
																		flow = b.mat,
																		weight = df_obs$afvArea),
							 iter = 2000, chains = 4, thin = 1, include = T,
							 pars = c("mu_doy","beta","range","sigma","w_r1","w_r2"), init = inits,
							 control = list(adapt_delta = .95, max_treedepth = 15), save_warmup = T)

mod = read_rds("./02_SpawnTiming/Model_Results/ssn_tailup_overlap_bayes.rds")
#write_rds(mod, "./02_SpawnTiming/Model_Results/ssn_tailup_overlap_bayes.rds")
#inits = mod@inits
shinystan::launch_shinystan(mod)

#Fit mean estimate and uncertainty.
beta = rstan::extract(mod, pars = "beta")$beta %>% data.frame() %>% 
	rename(intercept=X1, climDiverg=X2)

rg = range(df_obs$climDiverg_sc)
global = seq(rg[1],rg[2],length.out = 1000)

fit = matrix(nrow=1000, ncol=4, dimnames = list(c(),c("climDiver_sc","lower","median","upper")))
ct = 1
for(i in global){
	#browser()
	est = boot::inv.logit(beta$intercept + beta$climDiverg_2 * i)*100
	fit[ct,1] = i
	fit[ct,2:4] = t(quantile(est, probs = c(0.05,0.5,0.95)))[1,]
	ct=ct+1
}
fit = data.frame(fit)
#Back transform scaled estimates
mean = mean(df_obs$climDiverg)
sd = sd(df_obs$climDiverg)
fit$climDiverg = fit$climDiver_sc*sd+mean

#Fit by point.
mu_doy = rstan::extract(mod, pars="mu_doy")$mu_doy
mu_doy_fit = vector(mod="numeric",length=ncol(mu_doy))
for(i in 1:ncol(mu_doy)){
	mu_doy_fit[i] = median(mu_doy[,i])*100
}
#add median estimate of each observation 
df_obs$fit = mu_doy_fit

#Add climate region to df.
df_obs = df_obs %>% mutate(region = if_else(climDiverg<15, 1,
															 if_else(climDiverg<24.5 & climDiverg>15, 2,
															 				if_else(climDiverg<28.9 & climDiverg> 24.5, 2.5,3))))

#Create density plot to gather density data.
p = ggplot(df_obs, aes(climDiverg, group = as.factor(region))) +
	geom_density(adjust = 2)
#Gather density data.
pp = ggplot_build(p)
#Create density df.
dens = data.frame(climDiverg = pp$data[[1]]$x,
					 density = pp$data[[1]]$y*200,
					 region = pp$data[[1]]$group)
#Scale the density data by region.
dens = dens %>% group_by(region) %>% mutate(dens_sc = scales::rescale(density, c(0,10)))

# Mismatch plot
ggplot() +
	geom_ridgeline(data = dens, aes(x = climDiverg, y = rep(0, nrow(dens)),
																	height = dens_sc, 
																	fill = as.factor(region)), color = "white",
								 alpha = 0.2, lwd = 0.5, show.legend = T) + 
	geom_jitter(data=df_obs,
							aes(climDiverg, fit), 
							height=1, width=1, size = 1, alpha = 0.5) +
	geom_jitter(data=df_obs,
							aes(climDiverg, prob_match, color = upDist/1000), 
							height=3, width=3, size = 2.25, alpha = 0.7) +
	geom_line(data = fit, aes(climDiverg, median)) +
	geom_line(data = fit, aes(climDiverg, upper), linetype=2) +
	geom_line(data = fit, aes(climDiverg, lower), linetype=2) +
	scale_color_viridis(option = "plasma") + 
	labs(x = "Climate Dissimilarity", y = "Phenological Match (%)",
			 color = "River Distance (km)", fill = "Climate Region") +
	scale_fill_manual(values = c("#51bbfe","#8ff7a7","#85143e","#e4ea69"),
										breaks = as.factor(c(1,2,3,4)),
										labels = as.factor(c("Lower Fraser","Nicola &\nThompson",
											 										 "Transition","Upper Fraser"))) + 
	theme_tufte(ticks = T) + 
	theme(legend.title.align = 0.5, legend.position = c(0.81,0.80),
				legend.box = "horizontal", legend.spacing.x = unit(0.03,'in'),
				legend.key.height = unit(0.2,'in'), legend.text = element_text(size=8),
			plot.background = element_rect(fill = "transparent", colour = NA),
			panel.background = element_rect(fill = "transparent", colour = NA),
			axis.line = element_line(color="black"),
			axis.title = element_text(size = 14))

ggsave(path = "./drafts/99_figures/", filename = "05_mismatch_bayes.pdf",
			 device = "pdf", width = 7.5, height = 5, units = "in")
