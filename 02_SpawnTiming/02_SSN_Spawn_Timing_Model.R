library(tidyverse); library(SSN); library(MuMIn) #Activate Libraries
#Read in the .ssn network data.
network = importSSN("./02_SpawnTiming/lsn/sites_obs.ssn", predpts = "preds", o.write = F) 
#Change to factorized variables and log transform precipitation in the observed dataset.
net <- getSSNdata.frame(network)
names(net)[c(6,7)] = c("end","year")
net[,"year"] <- as.factor(net[,"year"])
net[,"geolocid"] <- as.factor(net[,"geolocid"])
net$logF_ppt = log(net$F_ppt); net$logW_ppt = log(net$W_ppt)

#Place corrected dataset back into the network.
network <- putSSNdata.frame(net, network, Name = "Obs")
#Change to factorized variables and log transform precipitation in the prediction dataset.
pred_net <- getSSNdata.frame(network, Name = "preds")
names(pred_net)[c(1,5)] <- c("id","year")
pred_net[,"year"] <- as.factor(pred_net[,"year"])
pred_net[,"geolocid"] <- factor(pred_net[,"geolocid"])
pred_net$logF_ppt = log(pred_net$F_ppt); pred_net$logW_ppt = log(pred_net$W_ppt)
network <- putSSNdata.frame(pred_net, network, Name = "preds")

#Plot the known pink salmon spawning locations.
plot(network, "peak", lwdLineCol = "afvArea", lwdLineEx = 10, lineCol = "black", pch = 19, xlab = "x-coordinate (m)", ylab = "y-coordinate (m)", asp   =   1)

net = getSSNdata.frame(network)

#Visualize the impact of temperature on peak spawn timing.
temp = net %>% gather(key = "TempMeasure", value = "temperature", starts_with("tm"), starts_with("ta"), starts_with("F_t"), starts_with("W_t")) %>% as.tbl()
ggplot(temp, aes(temperature, peak, color = logW_ppt)) +
	geom_point() + 
	geom_smooth(method = "lm", se = F) +
	facet_wrap(~TempMeasure, scales = "free_x")
#Good evidence for a winter minimum (best) or average temperature representing the longterm incubation regime at a site. Also, fall minimum temperatures look to be the best predictor of annual affects on spawn timing.
temp %>% filter(TempMeasure %in% c("F_tmax","F_tave","F_tmin","W_tmax","W_tave","W_tmin")) %>% 
	ggplot(., aes(temperature, peak, group = TempMeasure)) +
	geom_point() + 
	geom_smooth(aes(color = TempMeasure), method = "lm", se = F)

#Visualize the impact of precipitation on peak spawn timing.
precip = net %>% gather(key = "PrecipMeasure", value = "precipitation", starts_with("ppt"), logW_ppt, W_ppt, logF_ppt, F_ppt) %>% gather(key = "TempMeasure", value = "temperature", starts_with("tm"), starts_with("ta"), starts_with("F_t"), starts_with("W_t")) %>% as.tbl()
#Good evidence that logF and logW precipitation contibutes to understand spawn timing.	
ggplot(precip, aes(precipitation, peak, color = elevation)) +
	geom_point() + 
	geom_smooth(method = "lm", se = F) +
	facet_wrap(~PrecipMeasure, scales = "free_x")
#Compare log precip. models.
precip %>% filter(PrecipMeasure %in% c("logW_ppt","logF_ppt")) %>% 
	ggplot(., aes(precipitation, peak)) +
	geom_point() + 
	geom_smooth(aes(color = PrecipMeasure), method = "lm", se = F)
#No imediately apparent relationship between fall or winter temperature with fall or winter precipiation in predicting peak spawn timing.
precip %>% filter(PrecipMeasure %in% c("logW_ppt","logF_ppt"), TempMeasure %in% c("W_tmin","F_tmin")) %>% 
	ggplot(., aes(precipitation, temperature, group = PrecipMeasure)) +
		geom_point(aes(color = peak)) + 
		geom_smooth(method = "lm", se = F) +
		facet_wrap(~TempMeasure)

#Visualize the impact of elevation on peak spawn timing.
#Minimal evidence that increasing elevation results in earlier peak spawn.
ggplot(temp, aes(elevation, peak)) +
	geom_point() + 
	geom_smooth(method = "lm", se = F)

#Visualize the impact of distance to the outlet on peak spawn timing.
ggplot(temp, aes(upDist, peak)) +
	geom_point() + 
	geom_smooth(method = "lm", se = F)

#Visualize the impact of latitude and longitude to the outlet on peak spawn timing.
space = net %>% gather(key = "Measure", value = "LatLong", latitude, longitude) %>% as.tbl()
ggplot(space, aes(LatLong, peak)) +
	geom_point() + 
	geom_smooth(method = "lm", se = F) +
facet_wrap(~Measure, scales = "free_x")

#Visualize the impact of watershed area on peak spawn timing.
ggplot(net, aes(log(h2oAreaKm2), peak)) +
	geom_point() + 
	geom_smooth(method = "lm", se = F)

#Create the distance matrices for the model. Only needs to be done once. Look for the 'distance' folder in the lsn.ssn folder.
createDistMat(network, predpts = "preds", o.write = F, amongpreds = F)

#Mixed evidence that flow connected sites are more related out to 300 km away.
Torg = Torgegram(object = network, ResponseName = "peak", maxlag = 650000, nlag = 10)
plot(Torg)

#Temperature mods.
t.model.set = list(
	mod_all <- glmssn(peak ~ F_tmin + F_tave + W_tmin + W_tave, ssn.object = network, EstMeth = "ML", family = "Gaussian", CorModels = c("geolocid","year","Exponential.taildown"), addfunccol = "afvArea"),
	mod_FminWall <- glmssn(peak ~ F_tmin + W_tmin + W_tave, ssn.object = network, EstMeth = "ML", family = "Gaussian", CorModels = c("geolocid","year","Exponential.taildown"), addfunccol = "afvArea"),
	mod_FaveWall <- glmssn(peak ~ F_tave + W_tmin + W_tave, ssn.object = network, EstMeth = "ML", family = "Gaussian", CorModels = c("geolocid","year","Exponential.taildown"), addfunccol = "afvArea"),
	mod_FallWave <- glmssn(peak ~ F_tmin + F_tave + W_tave, ssn.object = network, EstMeth = "ML", family = "Gaussian", CorModels = c("geolocid","year","Exponential.taildown"), addfunccol = "afvArea"),
	mod_FallWmin <- glmssn(peak ~ F_tmin + F_tave + W_tmin, ssn.object = network, EstMeth = "ML", family = "Gaussian", CorModels = c("geolocid","year","Exponential.taildown"), addfunccol = "afvArea"),
	mod_Fall <- glmssn(peak ~ F_tmin + F_tave, ssn.object = network, EstMeth = "ML", family = "Gaussian", CorModels = c("geolocid","year","Exponential.taildown"), addfunccol = "afvArea"),
	mod_Winter <- glmssn(peak ~ W_tmin + W_tave, ssn.object = network, EstMeth = "ML", family = "Gaussian", CorModels = c("geolocid","year","Exponential.taildown"), addfunccol = "afvArea"),
	mod_Min <- glmssn(peak ~ F_tmin + W_tmin, ssn.object = network, EstMeth = "ML", family = "Gaussian", CorModels = c("geolocid","year","Exponential.taildown"), addfunccol = "afvArea"),
	mod_Ave <- glmssn(peak ~ F_tave + W_tave, ssn.object = network, EstMeth = "ML", family = "Gaussian", CorModels = c("geolocid","year","Exponential.taildown"), addfunccol = "afvArea"),
	mod_FminWave <- glmssn(peak ~ F_tmin + W_tave, ssn.object = network, EstMeth = "ML", family = "Gaussian", CorModels = c("geolocid","year","Exponential.taildown"), addfunccol = "afvArea"),
	mod_FaveWmin <- glmssn(peak ~ F_tave + W_tmin, ssn.object = network, EstMeth = "ML", family = "Gaussian", CorModels = c("geolocid","year","Exponential.taildown"), addfunccol = "afvArea"),
	mod_intFminWmin <- glmssn(peak ~ F_tmin * W_tmin, ssn.object = network, EstMeth = "ML", family = "Gaussian", CorModels = c("geolocid","year","Exponential.taildown"), addfunccol = "afvArea"),
	mod_Fmin <- glmssn(peak ~ F_tmin, ssn.object = network, EstMeth = "ML", family = "Gaussian", CorModels = c("geolocid","year","Exponential.taildown"), addfunccol = "afvArea"),
	mod_Wmin <- glmssn(peak ~ W_tmin, ssn.object = network, EstMeth = "ML", family = "Gaussian", CorModels = c("geolocid","year","Exponential.taildown"), addfunccol = "afvArea"),
	mod_Wave <- glmssn(peak ~ W_tave, ssn.object = network, EstMeth = "ML", family = "Gaussian", CorModels = c("geolocid","year","Exponential.taildown"), addfunccol = "afvArea"),
	mod_Fave <- glmssn(peak ~ W_tave, ssn.object = network, EstMeth = "ML", family = "Gaussian", CorModels = c("geolocid","year","Exponential.taildown"), addfunccol = "afvArea")
)

plyr::ldply(.data = t.model.set, .fun = function(x){
	data.frame(AIC = AIC(x))
}) %>% bind_cols(data.frame(Mods = c("all","FminWall","FaveWall","FallWave",
																		 "FallWmin","Fall","Winter","Min","Ave",
																		 "FminWave","FaveWmin","intFminWmin",
																		 "Fmin","Wmin","Fave","Wave")),.) %>% 
	arrange(AIC) %>% mutate(diff = AIC-.$AIC[1])
#Most combinations are equivalent and while winter minimum temperatures is 'winning', a model with fall average and winter minimum temperatures is equivalent and meets our a priori model structure.

#Test the importance of precipitation in the model.
p.model.set = list(
	mod_T <- glmssn(peak ~ F_tave + W_tmin, ssn.object = network, EstMeth = "ML", family = "Gaussian", CorModels = c("geolocid","year","Exponential.taildown"), addfunccol = "afvArea"),
	mod_FW <- glmssn(peak ~ F_tave + W_tmin + logW_ppt + logF_ppt, ssn.object = network, EstMeth = "ML", family = "Gaussian", CorModels = c("geolocid","year","Exponential.taildown"), addfunccol = "afvArea"),
	mod_W <- glmssn(peak ~ F_tave + W_tmin + logW_ppt, ssn.object = network, EstMeth = "ML", family = "Gaussian", CorModels = c("geolocid","year","Exponential.taildown"), addfunccol = "afvArea"),
	mod_F <- glmssn(peak ~ F_tave + W_tmin + logF_ppt, ssn.object = network, EstMeth = "ML", family = "Gaussian", CorModels = c("geolocid","year","Exponential.taildown"), addfunccol = "afvArea"),
	mod_IntFW <- glmssn(peak ~ F_tave*logF_ppt + W_tmin*logW_ppt , ssn.object = network, EstMeth = "ML", family = "Gaussian", CorModels = c("geolocid","year","Exponential.taildown"), addfunccol = "afvArea"),
	mod_FtIntW <- glmssn(peak ~ F_tave + W_tmin*logW_ppt, ssn.object = network, EstMeth = "ML", family = "Gaussian", CorModels = c("geolocid","year","Exponential.taildown"), addfunccol = "afvArea"),
	mod_WtIntF <- glmssn(peak ~ F_tave*logF_ppt + W_tmin, ssn.object = network, EstMeth = "ML", family = "Gaussian", CorModels = c("geolocid","year","Exponential.taildown"), addfunccol = "afvArea")
)

plyr::ldply(.data = p.model.set, .fun = function(x){
	data.frame(AIC = AIC(x))
}) %>% bind_cols(data.frame(Mods = c("T","FW","W","F","IntFW","FtIntW","WtIntF")),.) %>%
	arrange(AIC) %>% mutate(diff = AIC-.$AIC[1])
#AIC suggests an interaction is not at play but adding variables beyond temperature is not contributing to the model either. A priori, we would have expected fall precipitation to play a role as it would interact with temperature, but that does not appear be supported in these models. There doesn't appear to be a difference between temperature only models and a model with temperature and fall precipitation. Biological arguments prompt me to keep fall precipitation.

#Test the importance of elevation in the model.
el.model.set = list(
	mod_TP <- glmssn(peak ~ F_tave + W_tmin + logF_ppt, ssn.object = network, EstMeth = "ML", family = "Gaussian", CorModels = c("geolocid","year","Exponential.taildown"), addfunccol = "afvArea"),
	mod_E <- glmssn(peak ~ F_tave + W_tmin + logF_ppt + elevation, ssn.object = network, EstMeth = "ML", family = "Gaussian", CorModels = c("geolocid","year","Exponential.taildown"), addfunccol = "afvArea"),
	mod_FtE <- glmssn(peak ~ F_tave*elevation + W_tmin + logF_ppt, ssn.object = network, EstMeth = "ML", family = "Gaussian", CorModels = c("geolocid","year","Exponential.taildown"), addfunccol = "afvArea"),
	mod_WtE <- glmssn(peak ~ F_tave + W_tmin*elevation + logF_ppt, ssn.object = network, EstMeth = "ML", family = "Gaussian", CorModels = c("geolocid","year","Exponential.taildown"), addfunccol = "afvArea"),
	mod_PE <- glmssn(peak ~ F_tave + W_tmin + logF_ppt*elevation, ssn.object = network, EstMeth = "ML", family = "Gaussian", CorModels = c("geolocid","year","Exponential.taildown"), addfunccol = "afvArea")
)
plyr::ldply(.data = el.model.set, .fun = function(x){
	data.frame(AIC = AIC(x))
}) %>% bind_cols(data.frame(Mods = c("TP","E","FtE","WtE","PE")),.) %>%
	arrange(AIC) %>% mutate(diff = AIC-.$AIC[1])
#Adding elevation to the model does not appear to add anything beyond what precipitation and temperature contribute. That said, adding the interaction between precipiation and elevation does 'win' but not by delta 2.

#Test the importance of latitude/longitude in the model.
ll.model.set = list(
	mod_PE <- glmssn(peak ~ F_tave + W_tmin + logF_ppt*elevation, ssn.object = network, EstMeth = "ML", family = "Gaussian", CorModels = c("geolocid","year","Exponential.taildown"), addfunccol = "afvArea"),
	mod_LL <- glmssn(peak ~ F_tave + W_tmin + logF_ppt*elevation + latitude + longitude, ssn.object = network, EstMeth = "ML", family = "Gaussian", CorModels = c("geolocid","year","Exponential.taildown"), addfunccol = "afvArea"),
	mod_Lat <- glmssn(peak ~ F_tave + W_tmin + logF_ppt*elevation + latitude, ssn.object = network, EstMeth = "ML", family = "Gaussian", CorModels = c("geolocid","year","Exponential.taildown"), addfunccol = "afvArea"),
	mod_Long <- glmssn(peak ~ F_tave + W_tmin + logF_ppt*elevation + longitude, ssn.object = network, EstMeth = "ML", family = "Gaussian", CorModels = c("geolocid","year","Exponential.taildown"), addfunccol = "afvArea")
)
plyr::ldply(.data = ll.model.set, .fun = function(x){
	data.frame(AIC = AIC(x))
}) %>% bind_cols(data.frame(Mods = c("PE","LL","Lat","Long")),.) %>%
	arrange(AIC) %>% mutate(diff = AIC-.$AIC[1])
#Adding latitude and longitude doesn't add anything according to AIC. Going with simpler model that excludes spatial data because this is baked into the covariance structure.

#I also looked into adding a linear covariance structure but that didn't add anything to the model either.

#Look at the residuals spatially and as a distribution.
mod <- glmssn(peak ~ F_tave + W_tmin + logF_ppt*elevation, ssn.object = network, family = "Gaussian", CorModels = c("geolocid", "year","Exponential.taildown"), addfunccol = "afvArea")
mod.resid = residuals(mod)
plot(mod.resid)
hist(mod.resid)
#Here we seem to have occassionally datapoints drifting 40+ days away from the mean but those cases are rare. Residuals look normally distributed.

net = getSSNdata.frame(mod.resid)
ggplot(net, aes(`_fit_`,`peak`, color = `_CooksD_`)) +
	geom_point() + 
	geom_abline(intercept = 0, slope = 1) +
	scale_color_gradient2(name = expression(frac("CooksD")), midpoint=0.05, low="#67A9CF", mid="#F2F2F2",
												high="#FF0000", space ="Lab") 

ggplot(net, aes(`_fit_`,`peak`, color = `_leverage_`)) +
	geom_point() + 
	geom_abline(intercept = 0, slope = 1) +
	scale_color_gradient2(name = expression(frac("Leverage")), midpoint=2.5, low="#67A9CF", mid="#F2F2F2",
												high="#FF0000", space ="Lab") 

ggplot(net, aes(`_fit_`, `_resid.stand_`, color = `_leverage_`)) +
	geom_point() + 
	geom_smooth(method = "lm", se = F) +
	scale_color_gradient2(name = expression(frac("Leverage")), midpoint=2.5, low="#67A9CF", mid="#F2F2F2",
												high="#FF0000", space ="Lab") 
#outlier = subsetSSN(mod.resid$ssn.object, filename = "~/sfuvault/Simon_Fraser_University/PhD_Research/Projects/Timing-Mismatch_Pink-Salmon/GIS/lsn/subset", `_fit_`>220, clip = FALSE)
#plot(outlier, "peak", lwdLineCol = "afvArea", lwdLineEx = 10, lineCol = "black", pch = 16, xlab = "x-coordinate (m)", ylab = "y-coordinate (m)", asp   =   1)

#Leave one out cross validation.
cv.out = CrossValidationSSN(mod)
par(mfrow = c(1, 2))
plot(mod$sampinfo$z,
		 cv.out[, "cv.pred"], pch = 19,
		 xlab = "Observed Data", ylab = "LOOCV Prediction")
abline(0, 1)
plot( na.omit( getSSNdata.frame(network)[, "peak"]),
			cv.out[, "cv.se"], pch = 19,
			xlab = "Observed Data", ylab = "LOOCV Prediction SE")

#Show how much of the variation in the data is captured by each part of the model. The nugget is contibuting quite a lot.
GR2(mod)
varcomp(mod)

#Prediction
mod_pred <- predict.glmssn(object = mod, predpointsID = "preds")
plot(mod_pred, SEcex.max = .5/3*2, SEcex.min = 2)

net_preds = getSSNdata.frame(mod_pred$ssn.object, Name = "preds")
#Plot predictors against predicted peak spawn timing.
net_preds %>% gather(key = predictor, value = val, F_tave, logF_ppt, W_tmin, elevation) %>% 
	ggplot(., aes(val, peak)) + 
		geom_point() + 
		geom_errorbar(aes(x = val, ymin = peak - peak.predSE, ymax = peak + peak.predSE)) +
		facet_wrap(~predictor, scales = "free")
#Look at the interacting variables.
ggplot(net_preds, aes(elevation, logF_ppt, color = peak)) + 
	geom_point()