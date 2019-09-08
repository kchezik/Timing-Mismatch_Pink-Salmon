library(tidyverse); library(lubridate); library(attenPlot); library(sp); library(rgdal); library(ggridges); library(viridis); library(ggthemes); library(SSN); library(maptools);library(rstan)

#Read in the .ssn network data.
network = importSSN("/Users/kylechezik/sfuvault/Timing-Mismatch_Pink-Salmon/02_SpawnTiming/lsn/sites_overlap_bayes.ssn")

#Read in other prediction points.
network = importPredpts(network, "BK_2010", obj.type = "ssn")
network = importPredpts(network, "BK_1970", obj.type = "ssn")

#Create Distance Matrices
createDistMat(network, predpts = "BK_1970", o.write = F, amongpreds = TRUE)
createDistMat(network, predpts = "BK_2010", o.write = F, amongpreds = TRUE)

#Extract prediction site dataset.
pred_1970 = getSSNdata.frame(network, Name = "BK_1970")
pred_2010 = getSSNdata.frame(network, Name = "BK_2010")

#Combine prediction network datasets.
pred_net = bind_rows(pred_1970,pred_2010) %>% rename("year" = "year_") %>% select(-id1)

#The prior years climate data at the prediction sites.
step_back = read_rds("./02_SpawnTiming/Spawn Site-Climate Data/BK_1969_2009.rds");step_back = step_back[-1]
#Combine prediction climate data and observed climate data from the prior year.
pred_net = pred_net[,names(pred_net)==names(step_back)] %>%  bind_rows(., step_back)

#Create a long format dataset.
pred_net = pred_net %>% gather(key = "clim_var", value = "clim_val", matches('^tmin|^tmax|^ppt|^tave'))

#Estuary Climate Variables
estClim = read.csv(file = "./02_SpawnTiming/Spawn Site-Climate Data/EstuaryClimate/site_1967-2011AMT.csv", header = T)
names(estClim) = tolower(names(estClim))
#Select columns of interest.
estClim = estClim %>% select(id1,latitude,longitude,year,elevation,matches('^tmin|^tmax|^ppt|^tave'))
#Create a long format dataset.
estClim = estClim %>% gather(key = "clim_var", value = "EstClimVal", matches('^tmin|^tmax|^ppt|^tave'))

#Combine
climate = estClim %>% select(year, clim_var, EstClimVal) %>%
	left_join(pred_net, ., by = c("year","clim_var")) %>%
	mutate(resid = clim_val - EstClimVal)
#Add a month variable to the long dataset.
climate = climate %>% do({
	end = nchar(.[,"clim_var"])
	data.frame(month = as.numeric(substr(.[,"clim_var"], end-1, end)),
						 var = substr(.[,"clim_var"], 1, end-2))
}) %>% bind_cols(climate,.)

#Add a column generalizing time to seasons.
climate = climate %>% mutate(season = if_else(month >= 7, "fall", "spring"))
#Adjust the year column so they span fall to spring rather than spring to fall.
climate = climate %>% 
	mutate(yearAdj = if_else(season == "fall", as.numeric(year), as.numeric(year)-1)) %>%
	arrange(geolocid, var, year, month)
#Standardize the climate variables between 0-1.
climate = climate %>% group_by(yearAdj, clim_var) %>%
	mutate(residSTD = zero_one(abs(resid)))
#Accumulate standardized deviations from Estuary climate metrics.
#Determine correlation for each year between the estuary and the temperature monitoring locations.
climate = climate %>% group_by(geolocid, yearAdj) %>%
	summarise(climDiverg = sum(residSTD),
						cor = cor(clim_val, EstClimVal)) %>% 
	filter(yearAdj == 2009 | yearAdj == 1969) %>% 
	left_join(.,select(pred_1970, geolocid, afvArea))

# Centering values from observational analysis
# Mean: 22.77759
# SD: 8.761527

#Standardize values and re-adjust year value.
pred_net = climate %>% ungroup() %>% 
	mutate(year = yearAdj+1, climDiverg_sc = (climDiverg-22.77759)/8.761527) %>%
	select(-cor, -yearAdj)

#Get stream distance matrix and calculate the full stream distance 
distPreds = getStreamDistMat(network, Name = "BK_2010")$dist.net1
dist.H.p = distPreds + t(distPreds)
b.mat = (pmin(distPreds,t(distPreds))==0)*1

#Prediction model matrix
df = pred_net %>% filter(year == 2010) %>% arrange(geolocid)
x = model.matrix(~ climDiverg_sc, data = df) # Make Matrix

# Load the fit model and extract the necessary parameters
mod = read_rds("./02_SpawnTiming/Model_Results/ssn_tailup_overlap_bayes.rds")
par = rstan::extract(mod,c("beta","sigma","range"))

# Set up multiple cores.
options(mc.cores = parallel::detectCores(), auto_write = TRUE)
# Compile Model.
compile = stan_model("~/sfuvault/Timing-Mismatch_Pink-Salmon/overlap_ssn_predict.stan")
#Run model.
est = sampling(compile, data = list(N = nrow(x),
                                    K = ncol(x),
                                    X = x,
                                    dist = dist.H.p,
                                    N_smpl = nrow(par$beta[c(1:3),]),
																		beta = par$beta[c(1:3),],
																		range = (par$range*1408253)[c(1:3)],
																		sigma = par$sigma[c(1:3),c(1,2)],
																		flow = b.mat,
																		weight = df$afvArea),
               iter = 1, chains = 1, include = T,
							 pars = c("mu_doy"), algorithm = "Fixed_param")

hist(rstan::extract(est,"mu_doy")$mu_doy)
