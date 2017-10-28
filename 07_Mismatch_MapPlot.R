library(tidyverse); library(SSN); library(MuMIn); library(attenPlot); library(rgdal) #Activate Libraries
#Read in the .ssn network data.
network = importSSN("./02_SpawnTiming/lsn/sites_overlap.ssn", predpts = "BK_2010", o.write = F)

#Plot the known pink salmon spawning locations and color by percent overlap.
plot(network, "perc", lwdLineCol = "afvArea", lwdLineEx = 10, lineCol = "black", pch = 19, xlab = "x-coordinate (m)", ylab = "y-coordinate (m)", asp   =   1)

#Read in other prediction points.
network = importPredpts(network, "BK_1970", obj.type = "ssn")

#Read in updated percent overlap data.
perc = readOGR(dsn = "./02_SpawnTiming/lsn/sites/", layer = "sites_overlap")
perc = perc@data %>% select(geolocid, year, perc)
perc[which(perc$perc==0),"perc"] = 0.1
logit = function(p){log(p/(1-p))}
perc = perc %>% mutate(logitPerc = logit(perc*0.01))
#Change to factorized variables and log transform precipitation in the observed dataset.
net <- getSSNdata.frame(network)
names(net)[2] = "year"; net = net[-13];
#Update percent overlap data.
net = net %>% select(-perc) %>% left_join(.,perc, by = c("geolocid","year"))
#Change year and site id to factors.
net[,"year"] <- as.factor(net[,"year"])
net[,"geolocid"] <- as.factor(net[,"geolocid"])
#Place corrected dataset back into the network.
network <- putSSNdata.frame(net, network, Name = "Obs")

#Extract prediction site dataset.
pred_1970 = getSSNdata.frame(network, Name = "BK_1970")
pred_2010 = getSSNdata.frame(network, Name = "BK_2010")
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
mod <- glmssn(logitPerc ~ climDiverg, ssn.object = network, family = "Gaussian", CorModels = c("year","Exponential.tailup"), addfunccol = "afvArea")

#Look at residuals.
mod.resid = residuals(mod)
plot(mod.resid)
hist(mod.resid)

net = getSSNdata.frame(mod.resid)
ggplot(net, aes(`_fit_`,`logitPerc`, color = `_CooksD_`)) +
	geom_point() + 
	geom_abline(intercept = 0, slope = 1) +
	scale_color_gradient2(name = expression(frac("CooksD")), midpoint=0.05, low="#67A9CF", mid="#F2F2F2",
												high="#FF0000", space ="Lab") 

#Cross validation.
cv.out = CrossValidationSSN(mod)
par(mfrow = c(1, 2))
plot(psych::logistic(mod$sampinfo$z),
		 psych::logistic(cv.out[, "cv.pred"]), pch = 19,
		 xlab = "Observed Data", ylab = "LOOCV Prediction")
abline(0, 1)
plot( psych::logistic(na.omit( getSSNdata.frame(network)[, "logitPerc"])),
			psych::logistic(cv.out[, "cv.se"]), pch = 19,
			xlab = "Observed Data", ylab = "LOOCV Prediction SE")

###################
### Predictions ###
###################

#Predict the percent overlap.
mod_pred_2010 <- predict.glmssn(object = mod, predpointsID = "BK_2010")
#Back transform data
pred_net = getSSNdata.frame(mod_pred_2010, Name = "BK_2010")
inv_logit = function(x){exp(x)/(1+exp(x))}
pred_net$perc = inv_logit(pred_net$logitPerc)*100
pred_net$percSE_upper = inv_logit(pred_net$logitPerc + pred_net$logitPerc.predSE)*100
pred_net$precSE_lower = inv_logit(pred_net$logitPerc - pred_net$logitPerc.predSE)*100
mod_pred_2010 = putSSNdata.frame(pred_net, mod_pred_2010, Name = "BK_2010")

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
#Back transform data
pred_net = getSSNdata.frame(mod_pred_1970, Name = "BK_1970")
inv_logit = function(x){exp(x)/(1+exp(x))}
pred_net$perc = inv_logit(pred_net$logitPerc)*100
pred_net$percSE_upper = inv_logit(pred_net$logitPerc + pred_net$logitPerc.predSE)*100
pred_net$precSE_lower = inv_logit(pred_net$logitPerc - pred_net$logitPerc.predSE)*100
mod_pred_1970 = putSSNdata.frame(pred_net, mod_pred_1970, Name = "BK_1970")

#Plot Predictions.
plot(mod_pred_1970)
plot(mod_pred_2010)


#Show how much of the variation in the data is captured by each part of the model. The nugget is contibuting quite a lot.
GR2(mod)
varcomp(mod)


#########################################
#Write a shapefile of prediction points.#
#########################################

#Find prediction or observation data frame slot location.
pl = which(mod_pred_1970$ssn.object@predpoints@ID=="BK_1970")
#Isolate data.
df = mod_pred_1970$ssn.object@predpoints@SSNPoints[[pl]]@point.data
#Isolate stream network polyline data.
net = mod_pred_1970$ssn.object@data
net = df %>% select(rid, perc, climDiverg) %>% 
	group_by(rid) %>% summarise(peak = mean(perc), peakSE = mean(climDiverg)) %>%
	left_join(net, ., by = "rid")
#Reference for rid and binaryID.
ref = read.delim(file = "./02_SpawnTiming/lsn/sites_overlap.ssn/netID1.dat", header = T, sep = ",", col.names = c("rid", "binaryID"), numerals = "no.loss", as.is = T)
ref = ref %>% mutate(n = nchar(binaryID))
#Fill in unknown data.
fill = apply(net, 1, function(x){
	if(is.na(x[["peak"]])) {
		xrid = as.numeric(x[["rid"]]) #rid with missing value.
		xBI = ref %>% filter(rid == xrid) %>% .$binaryID #binary of missing value.
		
		xBI_a = xBI; xBI_hold = xBI; above = NULL
		while(is.null(above)){
			#Look for peak spawn dates above the stream segment with missing data.
			xBI_left = paste(xBI_a,"1",sep = "")
			xBI_right = paste(xBI_a,"0",sep = "")
			left = ref %>% filter(binaryID == xBI_left)
			right = ref %>% filter(binaryID == xBI_right)
			#If there is a stream branching to the left, check for peak spawn values...
			#... and return either a new binary or the current binary with peak spawn esimate data.
			if(nrow(left) > 0) {
				leftPeak = net %>% filter(rid == left$rid) %>% select(peak, peakSE)
				if(is.na(leftPeak$peak)){
					xBI_a = xBI_left
				} else above = c(above, left$rid)
			}
			#If there is a stream branching to the right, check for peak spawn values...
			#... and return either a new binary or the current binary with peak spawn esimate data.
			if(nrow(right) > 0) {
				rightPeak = net %>% filter(rid == right$rid) %>% select(peak, peakSE)
				if(is.na(rightPeak$peak)){
					xBI_a = xBI_right
				} else above = c(above, right$rid)
			}
			#If both branches are empty then look for a new branch near the begining...
			#... or return an empty dataframe if new branches from the origin don't exist.
			if(nrow(left)==0 & nrow(right)==0){
				xBI_hold = paste(xBI_hold,"1",sep = "")
				if(any(xBI_hold==ref$binaryID))	xBI_a = xBI_hold
				else above = c(above, left$rid)
			}
		}
		#Look for peak spawn dates below the stream segment with missing data.
		below = NULL
		while(is.null(below)){
			xBI_down = substr(xBI, 1, (nchar(xBI)-1))
			down = ref %>% filter(binaryID == xBI_down)
			downPeak = net %>% filter(rid == down$rid) %>% select(peak, peakSE)
			if(is.na(downPeak$peak)) xBI = xBI_down
			else below = down$rid
		}
		#Average predicted peak spawn and SE values above and below unknown junction.
		peak_se = net %>% filter(rid %in% c(above, below))
		data.frame(peak = mean(peak_se$peak), peakSE = mean(peak_se$peakSE))
	}
	else data.frame(peak = as.numeric(x[["peak"]]), peakSE = as.numeric(x[["peakSE"]]))
}) %>% do.call('rbind',.)
net = net %>% select(-peak, -peakSE) %>% bind_cols(., fill)
row.names(net) = as.character(c(0:(nrow(net)-1)))
names(net)[c(15,16)] = c("perc","climDiverg")
sp = SpatialLines(LinesList = mod_pred_1970$ssn.object@lines, CRS("+init=epsg:3005"))
sp = SpatialLinesDataFrame(sl = sp, data = net)
writeOGR(obj = sp, dsn = "./maps/", layer = "BK_1970_overlap", driver = "ESRI Shapefile", overwrite_layer = T)
