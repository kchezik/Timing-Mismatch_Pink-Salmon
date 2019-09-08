library(tidyverse); library(lubridate); library(attenPlot); library(sp); library(rgdal); library(ggridges); library(viridis); library(ggthemes); library(SSN); library(maptools);library(rstan)

#Read in the .ssn network data.
network = importSSN("/Users/kylechezik/sfuvault/Timing-Mismatch_Pink-Salmon/02_SpawnTiming/lsn/sites_overlap_bayes.ssn")

#Read in other prediction points.
network = importPredpts(network, "BK_2010", obj.type = "ssn")
network = importPredpts(network, "BK_1970", obj.type = "ssn")

#Extract prediction site dataset.
pred_1970 = getSSNdata.frame(network, Name = "BK_1970")
pred_2010 = getSSNdata.frame(network, Name = "BK_2010")

#
pred_net = bind_rows(pred_1970,pred_2010) %>% rename("year" = "year_") %>% select(-id1)

#The prior years climate data at the prediction sites.
step_back = read_rds("./02_SpawnTiming/Spawn Site-Climate Data/BK_1969_2009.rds");step_back = step_back[-1]
#Combine prediction climate data and observed climate data from the prior year.
pred_net = pred_net[,names(pred_net)==names(step_back)] %>% bind_rows(., step_back)

#Create a long format dataset.
pred_net = pred_net %>% gather(key = "clim_var", value = "clim_val", 6:53)

#Estuary Climate Variables
estClim = read.csv(file = "./02_SpawnTiming/Spawn Site-Climate Data/EstuaryClimate/site_1967-2011AMT.csv", header = T)
names(estClim) = tolower(names(estClim))
#Select columns of interest.
estClim = estClim %>% select(id1,latitude,longitude,year,elevation,starts_with("tmax"),starts_with("tmin"),starts_with("tave"),starts_with("ppt"))
#Create a long format dataset.
estClim = estClim %>% gather(key = "clim_var", value = "EstClimVal", 6:53)

#Combine
climate = estClim %>% select(year, clim_var, EstClimVal) %>% 
	left_join(pred_net, ., by = c("year","clim_var"))
climate = climate %>%
	mutate(resid = clim_val - EstClimVal) %>%
	select(geolocid, year, clim_var, resid, clim_val, EstClimVal)
#Add a month variable to the long dataset.
climate = climate %>% do({
	end = nchar(.[,3])
	data.frame(month = as.numeric(substr(.[,3], end-1, end)),
						 var = substr(.[,3], 1, end-2))
}) %>% bind_cols(climate,.)

#Add a column generalizing time to seasons.
climate = climate %>% mutate(season = if_else(month >= 7, "fall", "spring"))
#Adjust the year column so they span fall to spring rather than spring to fall.
climate = climate %>% mutate(yearAdj = if_else(season == "fall", as.numeric(year), as.numeric(year)-1)) %>% arrange(geolocid, var, year, month)
#Standardize the climate variables between 0-1.
climate = climate %>% group_by(yearAdj, clim_var) %>%
	mutate(residSTD = zero_one(abs(resid)))
#Accumulate standardized deviations from Estuary climate metrics. Determine correlation for each year between the estuary and the temperature monitoring locations.
climate = climate %>% group_by(geolocid, yearAdj) %>%
	summarise(climDiverg = sum(residSTD),
						cor = cor(clim_val, EstClimVal)) %>% 
	filter(yearAdj == 2009 | yearAdj == 1969)

#Function to center and scale data.
sc_func = function(x){
	(x-mean(x))/sd(x)
}

#
pred_net = climate %>% group_by(yearAdj) %>%
	mutate(year = yearAdj+1, climDiverg_sc = sc_func(climDiverg)) %>%
	ungroup() %>% select(geolocid, year, climDiverg, climDiverg_sc, -yearAdj)

