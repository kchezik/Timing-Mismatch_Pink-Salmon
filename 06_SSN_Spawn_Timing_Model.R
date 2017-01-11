library(tidyverse); library(SSN) #Activate Libraries
Path = "~/sfuvault/Simon_Fraser_University/PhD_Research/Projects/Timing-Mismatch_Pink-Salmon/GIS/lsn/lsn.ssn" #Path to .ssn file.
network = importSSN(Path, predpts = "preds", o.write = F) #Read in the .ssn network data.

#Plot the known pink salmon spawning locations.
plot(network, "sim", lwdLineCol = "afvArea", lwdLineEx = 10, lineCol = "black", pch = 19, xlab = "x-coordinate (m)", ylab = "y-coordinate (m)", asp   =   1)

#Create the distance matrices for the model. Only needs to be done once. Look for the 'distance' folder in the lsn.ssn folder.
createDistMat(network, predpts = "preds", o.write = T, amongpreds = T)

Torg = Torgegram(object = network, ResponseName = "sim", maxlag = 650000, nlag = 10)
plot(Torg)

#Convert the population column from numeric to factor.
network@obspoints@SSNPoints[[1]]@point.data$pop = as.factor(network@obspoints@SSNPoints[[1]]@point.data$pop)

mod1 <- glmssn(sim ~ elevation + tave_d + ppt_d, ssn.object = network, EstMeth = "REML", family = "Gaussian", CorModels = "id_rand", addfunccol = "afvArea")
