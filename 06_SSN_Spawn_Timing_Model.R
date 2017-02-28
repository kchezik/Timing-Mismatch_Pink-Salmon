library(tidyverse); library(SSN); library(MuMIn) #Activate Libraries
Path = "~/sfuvault/Simon_Fraser_University/PhD_Research/Projects/Timing-Mismatch_Pink-Salmon/GIS/lsn/site_lsn.ssn" #Path to .ssn file.
network = importSSN(Path, predpts = "preds", o.write = F) #Read in the .ssn network data.

#Plot the known pink salmon spawning locations.
plot(network, "peak", lwdLineCol = "afvArea", lwdLineEx = 10, lineCol = "black", pch = 19, xlab = "x-coordinate (m)", ylab = "y-coordinate (m)", asp   =   1)

#Create the distance matrices for the model. Only needs to be done once. Look for the 'distance' folder in the lsn.ssn folder.
createDistMat(network, predpts = "preds", o.write = F, amongpreds = F)

Torg = Torgegram(object = network, ResponseName = "peak", maxlag = 650000, nlag = 10)
plot(Torg)

#Temperature mods.
model.set = list(
	mod <- glmssn(peak ~ elevation + tmin_d + tmax_d + tave_d + ppt_d + peak_year, ssn.object = network, EstMeth = "ML", family = "Gaussian", CorModels = c("Exponential.taildown"), addfunccol = "afvArea"),
	mod_avg <- glmssn(peak ~ elevation + tave_d + ppt_d + peak_year, ssn.object = network, EstMeth = "ML", family = "Gaussian", CorModels = c("Exponential.taildown"), addfunccol = "afvArea"),
	mod_min <- glmssn(peak ~ elevation + tmin_d + ppt_d + peak_year, ssn.object = network, EstMeth = "ML", family = "Gaussian", CorModels = c("Exponential.taildown"), addfunccol = "afvArea"),
	mod_max <- glmssn(peak ~ elevation + tmax_d + ppt_d + peak_year, ssn.object = network, EstMeth = "ML", family = "Gaussian", CorModels = c("Exponential.taildown"), addfunccol = "afvArea")
)

plyr::ldply(.data = model.set, .fun = function(x){
	data.frame(AIC = AIC(x))
}) %>% bind_cols(data.frame(Mods = c("all","Tavg","Tmin","Tmax")),.) %>% arrange(AIC)
#Average Temperature Wins at the Time of Spawn.

#Test the importance of precipitation in the model.
model.set = list(
	mod <- glmssn(peak ~ elevation + tave_d + peak_year, ssn.object = network, EstMeth = "ML", family = "Gaussian", CorModels = c("Exponential.taildown"), addfunccol = "afvArea"),
	mod_ppt <- glmssn(peak ~ elevation + tave_d + ppt_d + peak_year, ssn.object = network, EstMeth = "ML", family = "Gaussian", CorModels = c("Exponential.taildown"), addfunccol = "afvArea")
)

plyr::ldply(.data = model.set, .fun = function(x){
	data.frame(AIC = AIC(x))
}) %>% bind_cols(data.frame(Mods = c("Tave","ppt")),.) %>% arrange(AIC) %>% mutate(diff = diff(AIC))

#AIC suggests keeping ppt_d but just by a hair.


#Add year as a factor to the dataset.
net_yearRand <- getSSNdata.frame(network)
net_yearRand[,"peak_yearR"]<- as.factor(net_yearRand[,"peak_year"])
network <- putSSNdata.frame(net_yearRand, network)
#Test whether site or year should be random effect.
model.set = list(
	mod <- glmssn(peak ~ elevation + tave_d + ppt_d + peak_year, ssn.object = network, EstMeth = "ML", family = "Gaussian", CorModels = c("Exponential.taildown"), addfunccol = "afvArea"),
	mod_yearRand <- glmssn(peak ~ elevation + tave_d + ppt_d, ssn.object = network, EstMeth = "ML", family = "Gaussian", CorModels = c("peak_yearR","Exponential.taildown"), addfunccol = "afvArea"),
	mod_siteR <- glmssn(peak ~ elevation + tave_d + ppt_d + peak_year, ssn.object = network, EstMeth = "ML", family = "Gaussian", CorModels = c("id_rand","Exponential.taildown"), addfunccol = "afvArea"),
	mod_yearSiteR <- glmssn(peak ~ elevation + tave_d + ppt_d + peak_year, ssn.object = network, EstMeth = "ML", family = "Gaussian", CorModels = c("idY_rand","Exponential.taildown"), addfunccol = "afvArea")
)
plyr::ldply(.data = model.set, .fun = function(x){
	data.frame(AIC = AIC(x))
}) %>% bind_cols(data.frame(Mods = c("mod_fixed","mod_yearR","mod_site","mod_yearSiteR")),.) %>% arrange(AIC)
#Good evidence for year as a random effect. Will definitely add a year/site random effect to the replicate model.

#Look at the residuals spatially and as a distribution.
mod = model.set[[2]]
mod.resid = residuals(mod)
plot(mod.resid)
hist(mod.resid)
#Here we seem to have occassionally datapoints drifting 40 days away from the mean but those cases are rare. Residuals look normally distributed.

df = getSSNdata.frame(mod.resid)
ggplot(df, aes(`peak`,`_fit_`, color = tave_d)) +
	geom_point() + 
	geom_smooth(method = "lm")

network = putSSNdata.frame(df, network, Name = "Obs")
plot(network, "peak", lwdLineCol = "afvArea", lwdLineEx = 10, lineCol = "black", pch = 19, xlab = "x-coordinate (m)", ylab = "y-coordinate (m)", asp   =   1)
plot(mod.resid)
