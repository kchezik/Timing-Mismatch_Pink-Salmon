library(tidyverse); library(SSN) #Activate Libraries
#Read in the .ssn network data.
network = importSSN("./02_SpawnTiming/lsn/sites_sims.ssn", predpts = "preds", o.write = F) 
#Change to factorized variables and log transform precipitation in the observed dataset.
net <- getSSNdata.frame(network)
names(net)[c(3,8)] = c("year","end")
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
#Place the corrected prediction dataset back into the network.
network <- putSSNdata.frame(pred_net, network, Name = "preds")

#Create the distance matrices for the model. Only needs to be done once. Look for the 'distance' folder in the lsn.ssn folder.
createDistMat(network, predpts = "preds", o.write = F, amongpreds = F)

#Fit the spawn timing stream network model and save the results.
mod <- glmssn(peak ~ F_tave + W_tmin + logF_ppt*elevation, ssn.object = network, family = "Gaussian", CorModels = c("geolocid", "year","Exponential.taildown"), addfunccol = "afvArea")
saveRDS(object = mod, file = "./02_SpawnTiming/Model_Results/sim_mod.rds")
#Return the models residuals and save.
mod.resid = residuals(mod)
saveRDS(object = mod.resid, file = "./02_SpawnTiming/Model_Results/mod_resids.rds")
#Leave one out cross validation. Save results after running.
cv.out = CrossValidationSSN(mod)
saveRDS(object = cv.out, file = "./02_SpawnTiming/Model_Results/mod_CVal.rds")
#Prediction results (save).
mod_pred <- predict.glmssn(object = mod, predpointsID = "preds")
saveRDS(object = mod_pred, file = "./02_SpawnTiming/Model_Results/mod_pred.rds")