library(tidyverse); library(SSN); library(MuMIn); library(attenPlot) #Activate Libraries
#Read in the .ssn network data.
network = importSSN("./02_SpawnTiming/lsn/sites_overlap.ssn", predpts = "BK_2010", o.write = F)

#Plot the known pink salmon spawning locations and color by percent overlap.
plot(network, "perc", lwdLineCol = "afvArea", lwdLineEx = 10, lineCol = "black", pch = 19, xlab = "x-coordinate (m)", ylab = "y-coordinate (m)", asp   =   1)

#Read in other prediction points.
network = importPredpts(network, "BK_1970", obj.type = "ssn")
#Change to factorized variables and log transform precipitation in the observed dataset.
net <- getSSNdata.frame(network)
names(net)[2] = "year"; net =net[-13]
net[,"year"] <- as.factor(net[,"year"])
net[,"geolocid"] <- as.factor(net[,"geolocid"])
#Place corrected dataset back into the network.
network <- putSSNdata.frame(net, network, Name = "Obs")

#Extract prediction site dataset.
pred_1970 = getSSNdata.frame(network, Name = "BK_1970")
pred_2010 <- getSSNdata.frame(network, Name = "BK_2010")
pred_2010$netID = as.numeric(as.character(pred_2010$netID))
pred_net = bind_rows(pred_1970, pred_2010)
names(pred_net)[5] <- "year"; pred_net = pred_net[-1]

#The prior years climate data at the prediction sites.
step_back = read_rds("./02_SpawnTiming/Spawn Site-Climate Data/BK_1969_2009.rds"); step_back = step_back[-1]
#Combine prediction climate data and observed climate data from the prior year.
pred_net = pred_net %>% select(1:61) %>% bind_rows(., step_back)

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
climate = estClim %>% select(year, clim_var, EstClimVal) %>% left_join(pred_net, ., by = c("year","clim_var"))
climate = climate %>% mutate(resid = clim_val - EstClimVal)
#Add a month variable to the long dataset.
climate = climate %>% do({
	end = nchar(.[,14])
	data.frame(month = as.numeric(substr(.[,14], end-1, end)),
						 var = substr(.[,14], 1, end-2))
}) %>% bind_cols(climate,.)
#Add a column generalizing time to seasons.
climate = climate %>% mutate(season = if_else(month >= 7, "fall", "spring"))
#Adjust the year column so they span fall to spring rather than spring to fall.
climate = climate %>% mutate(yearAdj = if_else(season == "fall", as.numeric(year), as.numeric(year)-1)) %>% arrange(geolocid, var, year, month) %>% filter(yearAdj > 1966, yearAdj < 2011)
#Standardize the climate variables between 0-1.
climate = climate %>% group_by(yearAdj, clim_var) %>% mutate(residSTD = zero_one(abs(resid)))
#Accumulate standardized deviations from Estuary climate metrics.
climate = climate %>% group_by(geolocid, yearAdj) %>% summarise(climDiverg = sum(residSTD)) %>% filter(yearAdj == 2009 | yearAdj == 1969)


#Add column to the prediction dataset describing the climate divergence from the estuary at each site.
pred_net <- getSSNdata.frame(network, Name = "BK_2010")
names(pred_net)[5] <- "year"; pred_net = pred_net[-1]
pred_net = climate %>% filter(yearAdj == 2009) %>% select(-yearAdj) %>% left_join(pred_net,.,by="geolocid")
#Change geolocid to a factorized variable and log transform precipitation in the prediction dataset.
pred_net[,"geolocid"] <- factor(pred_net[,"geolocid"])
pred_net[,"year"] <- factor(pred_net[,"year"])
pred_net$logF_ppt = log(pred_net$F_ppt); pred_net$logW_ppt = log(pred_net$W_ppt)
row.names(pred_net) = as.character(pred_net$pid)
#Place corrected dataset back into the network.
network <- putSSNdata.frame(pred_net, network, Name = "BK_2010")

#Create distance matrix.
createDistMat(network, predpts = "BK_2010", o.write = F, amongpreds = F)
createDistMat(network, predpts = "BK_1970", o.write = F, amongpreds = F)

#Model the percent overlap.
mod <- glmssn(perc ~ climDiverg, ssn.object = network, family = "Gaussian", CorModels = c("year","Exponential.tailup"), addfunccol = "afvArea")

#Predict the percent overlap.
mod_pred_2010 <- predict.glmssn(object = mod, predpointsID = "BK_2010")

#Add column to the prediction dataset describing the climate divergence from the estuary at each site.
pred_net = getSSNdata.frame(network, Name = "BK_1970")
names(pred_net)[5] <- "year"; pred_net = pred_net[-1]
pred_net = climate %>% filter(yearAdj == 1969) %>% select(-yearAdj) %>% left_join(pred_net,.,by="geolocid")
#Change geolocid to a factorized variable and log transform precipitation in the prediction dataset.
pred_net[,"geolocid"] <- factor(pred_net[,"geolocid"])
pred_net[,"year"] <- factor(pred_net[,"year"])
pred_net$logF_ppt = log(pred_net$F_ppt); pred_net$logW_ppt = log(pred_net$W_ppt)
row.names(pred_net) = as.character(pred_net$pid)
#Place corrected dataset back into the network.
mod <- putSSNdata.frame(pred_net, mod, Name = "BK_1970")
mod_pred_1970 <- predict.glmssn(object = mod, predpointsID = "BK_1970")

#Plot Predictions.
plot(mod_pred_1970)
plot(mod_pred_2010)
