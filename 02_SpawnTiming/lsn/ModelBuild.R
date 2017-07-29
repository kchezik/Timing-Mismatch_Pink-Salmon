library(SSN)
setwd("C:/Users/Chezik/Documents/Fraser/PMM/lsn")
network = importSSN("sites_sims.ssn", predpts ="preds")
network = importPredpts(network, "BK_1960", "ssn")
network = importPredpts(network, "BK_1970", "ssn")
network = importPredpts(network, "BK_1980", "ssn")
network = importPredpts(network, "BK_1990", "ssn")
network = importPredpts(network, "BK_2000", "ssn")
network = importPredpts(network, "BK_2010", "ssn")
plot(network, "peak", pch = 19)

#Change to factorized variables ...
#...and log transform precipitation in teh observed dataset.
net = getSSNdata.frame(network)
names(net)[c(3,8)] = c("year","end")
net[,"year"] = as.factor(net[,"year"])
net[,"geolocid"] = as.factor(net[,"geolocid"])
net$logF_ppt = log(net$F_ppt); net$logW_ppt = log(net$W_ppt)
#Place corrected dataset back into the network.
network = putSSNdata.frame(net, network, Name = "Obs")

#Change to factorized variables ...
#...and log transform precipitation in teh observed dataset.
pred_net = getSSNdata.frame(network, Name = "preds")
names(pred_net)[c(1,5)] = c("id","year")
pred_net[,"year"] = as.factor(pred_net[,"year"])
pred_net[,"geolocid"] = as.factor(pred_net[,"geolocid"])
pred_net$logF_ppt = log(pred_net$F_ppt); pred_net$logW_ppt = log(pred_net$W_ppt)
#Place corrected dataset back into the network.
network = putSSNdata.frame(pred_net, network, Name = "preds")

#Create the distance matrices for the model.
createDistMat(network, predpts = "preds", o.write = F, amongpreds = F)

#Fit the spawn timing stream network model and save the results.
mod = glmssn(peak ~ F_tave + W_tmin + logF_ppt*elevation, 
             ssn.object = network, family = "Gaussian", 
             CorModels = c("geolocid","year", "Exponential.taildown"),
             addfunccol = "afvArea")
saveRDS(object = mod, file = "sim_mod.rds")

#Return the models residuals and save.
mod.resid = residuals(mod)
saveRDS(object = mod.resid, file = "mod_resids.rds")

#Leave one out cross validation (save).
cv.out = CrossValidationSSN(mod)
saveRDS(object = cv.out, file = "mod_CVal.rds")

#Prediction results (save).
mod_pred = predict.glmssn(object = mod, predpointsID = "preds")
saveRDS(object = mod_pred, file = "mod_pred.rds")