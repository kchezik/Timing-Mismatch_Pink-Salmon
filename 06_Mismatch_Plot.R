library(tidyverse); library(lubridate); library(attenPlot); library(sp); library(rgdal); library(ggridges); library(viridis); library(ggthemes)
#Get Emergence Probability data.
emerg = read_rds("Data_04_EmergProbs.rds") %>% ungroup() %>% select(-1)

#Break data up by geolocid so only 16 are plotted at a time.
geolocid = unique(emerg$geolocid)
id1 = geolocid[c(1:16)]
id2 = geolocid[c(17:32)]
id3 = geolocid[c(33:48)]
id4 = geolocid[c(49:61)]

#Look at a plot of spawning and emergence distributions.
emerg %>% filter(geolocid %in% id1, !is.na(emergDate)) %>% 
	ggplot(.) +
	stat_density(aes(spawnDate, group = year), color = "#9ECE9A", fill = "#9ECE9A", alpha = 0.5) + 
	stat_density(aes(emergDate, group = year), color = "#077187", fill = "#077187", alpha = 0.5)+
	facet_wrap(~geolocid, scales = "free") + 
	theme_light()

#Read in distance and travel timing estimate data.
dist = read_rds("Data_06_DistanceTravelRef.rds")
#Add distance and timing columns to emergence data.
estuary = emerg %>% left_join(., dist, by = c("geolocid","year")) %>%
	mutate(arriveDate = emergDate + travelDays_vel)

#Phytoplankton Data from Dr. Allen.
phyto = read_delim(file = "Data_05_bloomdate_31mar2016.dat", skip = 3, delim = " ")
#Observed In-Situ phytoplankton data from Allen et al. (2013)
phyObs = read_csv(file = "Data_05_PhytoDigi.csv", col_names = c("Year","bloom"))
#Join and incorporate observed data with modelled.
phyto = left_join(phyto, phyObs, by = "Year"); rm(phyObs)
phyto$bloom = if_else(is.na(phyto$bloom),phyto$YearDay,phyto$bloom)
#Add a date of bloom.
phyto$date = ymd(strptime(paste(as.character(phyto$Year), as.character(phyto$bloom)), format="%Y %j"))+14
#Add a residual value to estimate extremes in bloom date.
phyto = phyto %>% mutate(resid = bloom-mean(bloom))

#Recreate Allen et al. paper plot.
ggplot(phyto, aes(Year, bloom)) + geom_point() + 
	geom_errorbar(aes(ymin = bloom-4, ymax = bloom+4)) + 
	geom_line(lty = 2) + 
	geom_abline(aes(intercept = mean(bloom), slope = 0)) + 
	xlab("Year") + ylab("Yearday of Bloom")

#Prediction Sites Near Observed Spawning
PredObs = read_csv("PredObsOverlapRef.csv")

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
	select(id1, year, clim_var, resid)
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
climate = climate %>% group_by(yearAdj, clim_var) %>% mutate(residSTD = zero_one(abs(resid)))
#Accumulate standardized deviations from Estuary climate metrics.
climate = climate %>% group_by(id1, yearAdj) %>% summarise(climDiverg = sum(residSTD))

#Output climate divergence to a shapefile.
sp = preds %>% select(id1, latitude, longitude) %>% distinct() %>% left_join(climate, ., by = "id1")
sp = data.frame(sp)
sp = SpatialPointsDataFrame(coords = sp[,c("longitude","latitude")], data = sp[,c("id1","yearAdj","climDiverg")], proj4string = CRS("+init=epsg:4326"))
sp = spTransform(sp, CRS("+init=epsg:3005"))
writeOGR(obj = sp, dsn = "./maps/", layer = "ClimDiverg", driver = "ESRI Shapefile", overwrite_layer = T)

#Remove No Longer Used Objects
rm(estClim, preds, sp)
############################


#Most common date (i.e., Mode function)
getmode <- function(v) {
	uniqv <- unique(na.exclude(v))
	uniqv[which.max(tabulate(match(v, uniqv)))]
}

overlap = estuary %>% group_by(geolocid, year) %>% 
	do({
		df = .
		if(all(is.na(df$arriveDate)) | nrow(df) == 0 | length(unique(df$arriveDate))==1){
			perc = NA; diff = NA; dateA = NA; dateZ = NA
		} 
		else{
			df = df %>% filter(!is.na(arriveDate))
			modeDate =  getmode(df$arriveDate)
			if(sum(df$arriveDate>modeDate)==0 | sum(df$arriveDate<modeDate)==0){
				perc = NA; diff = NA; dateA = NA; dateZ = NA
			}
			else if(any(df[df$arriveDate<modeDate,"ProbEmerg"]<=0.025) & any(df[df$arriveDate>modeDate,"ProbEmerg"]<=0.025)){
				ref.y = unique(.$year)
				TD = phyto %>% filter(Year == ref.y+1)
				perc = round(sum(df$arriveDate>(TD$date - 15) & df$arriveDate<(TD$date + 15))/nrow(df)*100,0)
				diff = round((TD$date - modeDate)[[1]],0)
				dateA = modeDate; dateZ = TD$date
			}
			else {
				ref.y = unique(.$year)
				TD = phyto %>% filter(Year == ref.y+1)
				diff = round((TD$date - modeDate)[[1]],0)
				perc = NA; diff = diff; dateA = modeDate; dateZ = TD$date
			}
		}
		data.frame(dateA, dateZ, diff, perc)
	})

#Look at NA values sites/years. All appear to lack the data necessary to measure a distribution.
error = overlap %>% filter(is.na(perc))
estuary %>% filter(geolocid == error$geolocid, year == error$year) %>%
	ggplot(., aes(arriveDate, fill = as.factor(year))) + geom_histogram(bins = 365) + 
	facet_wrap(~geolocid, scales = "free") + labs(fill='year', x = "Estuary Arrival") 

#Create mismatch dataframe.
mismatch = left_join(overlap, dist)
mismatch = phyto %>% mutate(year = Year - 1) %>% select(year, resid) %>% left_join(mismatch, ., by = "year")
mismatch = mismatch %>% mutate(SpawnObs = if_else(geolocid %in% PredObs$id1, "Inside", "Outside"))
mismatch = mismatch %>% left_join(., climate, by = c("year"="yearAdj", "geolocid"="id1"))
rm(dist, PredObs)

pdo = read.table("http://research.jisao.washington.edu/pdo/PDO.latest.txt", skip = 34, nrows = 111, header = F, 
								 col.names = c("year","jan","feb","mar","apr","may","jun","jul","aug","sep","oct","nov","dec"))
pdo$year = c(1900:2010)
pdo = pdo %>% gather(., key = "month", value = "pdo", 2:13) %>% group_by(year) %>% summarise(pdo = mean(pdo))

nino = read_tsv("https://www.esrl.noaa.gov/psd/enso/mei/table.html", skip = 14, n_max = 67, col_names = c("year","jan","feb","mar","apr","may","jun","jul","aug","sep","oct","nov","dec"))
nino = nino %>% gather(., key = "month", value = "enso", 2:13) %>% group_by(year) %>% summarise(enso = mean(enso))
mismatch = mismatch %>% left_join(., nino, by = "year") %>% left_join(., pdo, by = "year") 

#Add a 'region' variable, describing how the data break out by climatic area.
mismatch = mismatch %>% mutate(region = if_else(climDiverg<15, 1, 
																								if_else(climDiverg<24.5 & climDiverg>15, 2,
																												if_else(climDiverg<28.9 & climDiverg> 24.5, 2.5,3))))

#Output overlap/climate divergence data to a shapefile.
sp = mismatch %>% filter(!is.na(diff)) %>% select(geolocid, year, diff, perc, perc_median, climDiverg, enso, pdo, latitude, longitude) %>% data.frame(.)
sp = SpatialPointsDataFrame(coords = sp[,c("longitude","latitude")], data = sp[,c(1:7)], proj4string = CRS("+init=epsg:4326"))
sp = spTransform(sp, CRS("+init=epsg:3005"))
writeOGR(obj = sp, dsn = "./02_SpawnTiming/lsn/sites/", layer = "sites_overlap", driver = "ESRI Shapefile", overwrite_layer = T)

#Look for climatic clumping. Three distinct climatic regions with a transition zone.
ggplot(mismatch, aes(climDiverg, group = region, color = as.factor(region), fill = as.factor(region))) + geom_density(adjust = 2,alpha = 0.5)

#Plot the response variables against eachother. This gives strong evidence that our predictors are measuring match/mismatch...
# ... because as the predicted arrival time diverges from the observed phytoplankton bloom, ...
# ... the percent of Pink arrivals declines. 
ggplot(mismatch, aes(diff, perc, color = as.factor(region))) + geom_point() + 
	labs(x = "Zooplankton Bloom Residual", y = "Percent Overlap", color = "Climatic Region")

#Make mismatch plot.
ggplot(mismatch, aes(climDiverg, perc, color = as.factor(region))) + geom_point() + 
		labs(x = "Climate Divergence", y = "Percent Overlap", color = "Climatic Region") + theme_light()

ggplot(mismatch, aes(climDiverg, perc, color = Rdist/1000)) + geom_jitter(height = 0.3, size = 2.25, alpha = 0.7) +
	scale_color_viridis(option = "plasma") + 
	labs(x = "Climate Divergence", y = "Percent Overlap", color = "River\nDistance\n(km)") +
	theme_tufte(ticks = T) + 
	theme(legend.title.align = 0.5, legend.position = c(0.97,0.80), 
			plot.background = element_rect(fill = "transparent", colour = NA),
			panel.background = element_rect(fill = "transparent", colour = NA),
			axis.line = element_line(color="black"))
ggsave(path = "./drafts/", filename = "mismatch.pdf", device = "pdf", width = 7.5, height = 5, units = "in")

#Y-axis: values are positive when the Pinks enter the estuary after peak bloom.
#X-axis: values describe increasingly disimilar climates from the estuary.
#Color: Percent arrival timing overlap with zooplankton bloom.
ggplot(mismatch, aes(climDiverg, diff, color = perc, shape = as.factor(region))) + geom_point() + 
	labs(x = "Climate Divergence", y = "Estuary Arrival Timing", color = "PhytoResid", shape = "Climatic Region") +
	geom_abline(intercept = 0, slope = 0) +
	scale_color_gradient(name = "%Overlap", low="#67A9CF", high="#FF0000") +
	theme_light()

#Y-axis: values are positive when the Pinks enter the estuary after peak bloom.
#X-axis: values describe increasingly disimilar climates from the estuary.
#Color: values are red if the zooplankton bloom was later than average.
ggplot(mismatch, aes(climDiverg, diff, color = resid, shape = as.factor(region))) + geom_point() + 
	labs(x = "Climate Divergence", y = "Estuary Arrival Timing", color = "PhytoResid", shape = "Climatic Region") +
	geom_abline(intercept = 0, slope = 0) +
	scale_color_gradient2(name = expression(frac("PhytoDate","Residual")),
												midpoint=0, low="#67A9CF", mid="#F2F2F2", high="#FF0000") +
	theme_light()


#Keeper
#Read in emergence data.
df = read_rds("Data_04_EmergProbs.rds") %>% ungroup()
#Combine with mismatch data.
df = mismatch %>% select(geolocid, year, dateZ, diff, perc, resid, climDiverg, region, travelDays_vel) %>% left_join(df, ., by = c("geolocid","year"))
#Add column with estuary arrival day of year.
df.test = df %>% filter(!is.na(perc)) %>% 
	mutate(EDOY = yday(emergDate+100)-86 + travelDays_vel,
				 groups = paste(as.character(geolocid),as.character(year),sep="_"))
#
set.seed(123)
subPhyto = phyto %>% group_by(Year) %>% do({
	data.frame(EDOY = round(rnorm(1000, mean = (unique(.$YearDay+14)), sd = 5),0))
}) %>% ungroup() %>% sample_n(size = 100)

ggplot(NULL) + 
	geom_vline(data = subPhyto, aes(xintercept = EDOY), color = "#BDBDBD", alpha = 0.2, size = 1) + 
	geom_density_ridges(data = df.test,
										aes(x = EDOY, y = climDiverg, fill = diff, group = groups), 
					 color = "white", alpha = 0.7,
					 lwd = 0.5,
					 scale = 2, show.legend = T, bandwidth = 10,
					 panel_scaling = F) + 
	theme_tufte() +
	xlim(-80, 300) +
	labs(x = "Day of Year", y = "Climate Divergence", fill = "Mismatch \n (days)") + 
	facet_wrap(~region, scales = "free_y", nrow = 1, ncol = 4) + 
	scale_fill_viridis() +
	theme(strip.background = element_blank(),	strip.text.x = element_blank(),
				legend.title.align = 0.5, 
				plot.background = element_rect(fill = "transparent",colour = NA),
				panel.background = element_rect(fill = "transparent", colour = NA))
	
ggsave(filename = "./drafts/distributions.pdf", device = "pdf", width = 7.5, height = 6.5, units = "in")


#Estuary Arrivals/Blooms Over Time.
estuary = estuary %>% left_join(., climate, by = c("geolocid"="id1", "year"="yearAdj")) %>% 
	mutate(region = if_else(climDiverg<15, "lower",
													if_else(climDiverg<24.5 & climDiverg>15, "interior",
																	if_else(climDiverg<28.9 & climDiverg> 24.5, "transition","cold"))),
				 yearAdj = if_else(region == "lower", year + 1.1,
				 									if_else(region == "interior", year + 1.2,
				 													if_else(region == "transition", year + 1.3, year+1.4))),
				 doy = yday(arriveDate)) 

time = estuary %>% group_by(region, year) %>% 
	summarise(yearAdj = unique(yearAdj),
						ModeA = getmode(yday(arriveDate)), 
						upperQ = quantile(yday(arriveDate), 0.75, na.rm = T),
						lowerQ = quantile(yday(arriveDate), 0.25, na.rm = T),
						ClimateD = mean(climDiverg))
temp = phyto %>% select(1,3) %>% rename(yearAdj = Year, ModeA = bloom) %>% mutate(ModeA = ModeA + 14, region = "estuary", upperQ = ModeA+15, lowerQ = ModeA-15, ClimateD = 0) %>% bind_rows(time, .)



estuaryP = temp %>% filter(region == "estuary")
lower = estuary %>% filter(region == "lower")
interior = estuary %>% filter(region == "interior")

p = ggplot() +
	stat_smooth(data = estuaryP, aes(yearAdj, lowerQ), method = "loess", se = F, span = 0.1, col = "white") +
	stat_smooth(data = estuaryP, aes(yearAdj, upperQ), method = "loess", se = F, span = 0.1, col = "white")

pp = ggplot_build(p)
estuaryP2 = data.frame(yearAdj = pp$data[[1]]$x,
					 lowerQ = pp$data[[1]]$y,
					 upperQ = pp$data[[2]]$y)
p + geom_ribbon(data = estuaryP2, aes(x = yearAdj, ymin = lowerQ, ymax = upperQ),
								fill = "grey", alpha = 0.5) +
	geom_violin(data = lower, aes(x = year+1, y = doy, group = year), 
							colour = "#ffffff99", fill = "#f9e161", alpha = 0.7, size = 0.2, width = 0.5) + 
	geom_violin(data = interior, aes(x = year+1.3, y = doy, group = year), 
							colour = "#ffffff99", fill = "#391d50", alpha = 0.7, size = 0.2, width = 0.5) + 
	ylim(40, 190) + xlim(1967.5,2010.6) +
	theme_tufte(tick = T) +
	theme(legend.title.align = 0.5,
			plot.background = element_rect(fill = "transparent", colour = NA),
			panel.background = element_rect(fill = "transparent", colour = NA),
			axis.line = element_line(color="black"),
			legend.box = "vertical") + 
	labs(x = "Year", y = "Day of Year")

ggsave(filename = "./drafts/sequence.pdf", device = "pdf", width = 8, height = 2, units = "in")
