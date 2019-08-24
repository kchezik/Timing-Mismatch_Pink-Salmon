library(tidyverse); library(SSN); library(RColorBrewer); library(rgdal) #Activate Libraries
#Read in network and prediction points.
network = importSSN(filepath = "./02_SpawnTiming/lsn/sites_sims.ssn", predpts = "preds")
#networkObs = importSSN(filepath = "./02_SpawnTiming/lsn/sites_obs.ssn")
network = importPredpts(target = network, predpts = "BK_2010", obj.type = "ssn")
network = importPredpts(target = network, predpts = "BK_1970", obj.type = "ssn")
#Create distance matrix for observed and prediction points.
#createDistMat(ssn = network, predpts = "preds", o.write = T, amongpreds = T)
#createDistMat(ssn = network, predpts = "BK_2010", o.write = T, amongpreds = T)
createDistMat(ssn = network, predpts = "BK_1970", o.write = T, amongpreds = T)

#Read in model fit.
mod = read_rds(path = "./02_SpawnTiming/Model_Results/sim_mod.rds")
mod$ssn.object@path = "/Users/kylechezik/sfuvault/Simon_Fraser_University/PhD_Research/Projects/Timing-Mismatch_Pink-Salmon/02_SpawnTiming/lsn/sites_sims.ssn" # Change the path of the model from LabPC to local.

#Change to factorized variables and log transform precipitation in the prediction dataset.
pred_net = getSSNdata.frame(mod, Name = "BK_1970")
names(pred_net)[c(1,5)] <- c("id","year")
pred_net[,"year"] <- as.factor(pred_net[,"year"])
pred_net[,"geolocid"] <- factor(pred_net[,"geolocid"])
pred_net$logF_ppt = log(pred_net$F_ppt); pred_net$logW_ppt = log(pred_net$W_ppt)
#Place the corrected prediction dataset back into the network.
mod <- putSSNdata.frame(pred_net, mod, Name = "BK_1970")

#Retrieve predictions at evenly spaced intervals.
modP = predict(mod, "preds")

#Plot observed and predicted data on the network.
par(family = "serif")
plot(networkObs, "peak", pch = 1, cex = 3,
		 xlab = "Easting (m)", ylab = "Northing (m)",
		 color.palette = rev(paste(brewer.pal(8, "Spectral"), "99", sep = "")),
		 breaktype = "user", brks = c(120,150,170,180,190,200,220,240), lineCol = "#677077", lwdLineEx = 0.75)
plot(modP, "peak", cex = 0.5,
		 color.palette = rev(paste(brewer.pal(8, "Spectral"), "99", sep = "")),
		 breaktype = "user", brks = c(120,150,170,180,190,200,220,240), add = TRUE)



#Write a shapefile of prediction points.
#Find prediction data frame slot location.
#pl = which(modP$ssn.object@predpoints@ID=="BK_1970")
pl = which(mod_pred_1970$ssn.object@predpoints@ID=="BK_1970")
#Isolate prediction data.
#df = modP$ssn.object@predpoints@SSNPoints[[pl]]@point.data
df = mod_pred_1970$ssn.object@predpoints@SSNPoints[[pl]]@point.data
#Isolate stream network polyline data.
#net = modP$ssn.object@data
net = mod_pred_1970$ssn.object@data
net = df %>% select(rid, perc, climDiverg) %>% 
	group_by(rid) %>% summarise(peak = mean(perc), peakSE = mean(climDiverg)) %>%
	left_join(net, ., by = "rid")
#Reference for rid and binaryID.
#ref = read.delim(file = "./02_SpawnTiming/lsn/sites_sims.ssn/netID1.dat", header = T, sep = ",", col.names = c("rid", "binaryID"), numerals = "no.loss", as.is = T)
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
#sp = SpatialLines(LinesList = modP$ssn.object@lines, CRS("+init=epsg:3005"))
sp = SpatialLines(LinesList = mod_pred_1970$ssn.object@lines, CRS("+init=epsg:3005"))
sp = SpatialLinesDataFrame(sl = sp, data = net)
#writeOGR(obj = sp, dsn = "./maps/", layer = "BK_1970", driver = "ESRI Shapefile", overwrite_layer = T)
writeOGR(obj = sp, dsn = "./maps/", layer = "BK_1970_overlap", driver = "ESRI Shapefile", overwrite_layer = T)


#Read in sites shapefile and summarize by median value(ish).
sites = readOGR(dsn = "./02_SpawnTiming/lsn/sites_obs.ssn/", layer = "sites")
df = sites@data
df = bind_cols(df, data.frame(sites@coords))
lim = df %>% group_by(geolocid) %>% 
	summarise(medianP = median(peak+100))
lim = df %>% select(geolocid, rid, ratio, h2oAreaKm2, upDist, afvArea, coords.x1, coords.x2) %>% 
	distinct() %>% 
	left_join(lim, ., by = "geolocid")

sp = SpatialPointsDataFrame(coords = lim[, c("coords.x1","coords.x2")], data = data.frame(lim), proj4string = sites@proj4string)
writeOGR(obj = sp, dsn = "./maps/", layer = "sites", driver = "ESRI Shapefile", overwrite_layer = T)
