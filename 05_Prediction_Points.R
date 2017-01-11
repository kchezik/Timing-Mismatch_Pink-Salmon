library(rgdal); library(sp); library(raster) #Read in spatial libraries.
library(tidyverse) #Read in tidyverse libraries.


################################################################################################
#This bit of code was to bring in the temperature locality data. These data are full of errors.#
#Use the cleaned .csv file to avoid having to individually check the locality information. #####
################################################################################################

#Stream Temperature Data
temp = readRDS("Data_01_Temperature.rds") #Read in stream temprature data.
#Stream Temperature Locality Data
setwd("~/sfuvault/Simon_Fraser_University/PhD_Research/Projects/Data/Subset Data")
load("01-2 Corresponding Temperature Locality Data.RData")
#Sites to be visually inspected for locality correctness.
preds = Loc %>% select(GeoLocID, Latitude, Longitude) %>% filter(GeoLocID %in% temp$GeoLocID)
rm(Loc)
#Remove sites that do not fall within the Fraser basin. These were removed after a general visual inspection of the data.
outside = c(1612,1623,1624,1626,1627,1657,1659)
preds = preds %>% filter(!(GeoLocID%in%outside))
#Create reference table in order to isolate years at each site for which we have temperature data for spawn timing prediction.
setwd("~/sfuvault/Simon_Fraser_University/PhD_Research/Projects/Timing-Mismatch_Pink-Salmon/Spawn Timing/Spawn Site-Climate Data")
temp %>% select(GeoLocID,year) %>% distinct() %>% filter(!(GeoLocID%in%outside)) %>% saveRDS(., file = "predsYears.rds")
#Write csv of locality data for inspection.
write.csv(x = preds, file = "preds.csv", row.names = F)




################################################################################################
# Start from below here only if you are adding new sites that require climte data calculations.#
################################################################################################

#Read in temperature locality data that has been visually inspected and corrected for errors.
setwd("~/sfuvault/Simon_Fraser_University/PhD_Research/Projects/Timing-Mismatch_Pink-Salmon/Spawn Timing/Spawn Site-Climate Data")
preds = read.csv("TempSitesClean.csv", header = T)
#Reshape the data to be used in the ClimateBC tool.
preds %>% mutate(ID1 = GeoLocID, ID2 = GeoLocID, lat = Y, long= X, el = rep(NA,nrow(preds))) %>% select(ID1,ID2,lat,long,el,-GeoLocID,-Latitude,-Longitude) %>% write.csv(., file = "preds.csv", row.names = F)
#Now pass to the 'point sampling tool' and the 'join attributes by location' tool in QGIS to add elevation data.
#Finish Cleaning Up Data Prior to ClimateBC Analysis
preds = read.csv(file = "preds.csv", header = T)
preds$el = preds$bcdem
preds %>% select(ID1,ID2,lat,long,el) %>% write.csv(x = ., file = "preds.csv", row.names = F)
#The output must be opened and saved as a .csv file in Excel. Unsure why I can't seem to save it properly but without this step ClimateBC will not read the datafile correctly.



################################################################################################
# Start from below here unless starting from scratch or adding/removeing sites.#################
################################################################################################

#Prediction Values Must Include: Year,Latitude,Longitude,Elevation,tmax,tmin,tave,ppt,tmax_d,tmin_d,tave_d,ppt_d
#Read in data.
setwd("~/sfuvault/Simon_Fraser_University/PhD_Research/Projects/Timing-Mismatch_Pink-Salmon/Spawn Timing/Spawn Site-Climate Data")
preds = read.csv("preds_1967-2010AMT.csv",header = T)
names(preds) = tolower(names(preds))
#Select columns of interest.
preds = preds %>% select(id1,latitude,longitude,year,elevation,starts_with("tmax"),starts_with("tmin"),starts_with("tave"),starts_with("ppt"))
#Create a long format dataset.
preds = preds %>% gather(key = "clim_var", value = "clim_val", 6:53)
#Add a month variable to the long dataset.
sim_month = apply(preds,1,function(x){
	end = nchar(x[6])
	as.numeric(substr(x[6],end-1,end))
	})
var = apply(preds,1,function(x){
	end = nchar(x[6])
	substr(x[6],1,end-2)
})
preds = preds %>% mutate(sim_month = sim_month, var = var) %>% select(1:3,elevation,year,sim_month,var,clim_val)
preds$var = paste(preds$var,"_d",sep="")
names(preds)[5] = "sim_year"
#Spread out climate variables.
preds = preds %>% spread(key = var, value = clim_val)
#Add factor columns for random effects in the SSN model in order to group by population and/or population and year. Also, organize the columns to be more in line with those of the 'sites' dataset.
idR = paste(as.character(preds$id1),"fraser",sep = "_")
idY = paste(as.character(preds$id1),as.character(preds$sim_year),sep = "_")
preds = mutate(preds, idNo = id1, id_rand = as.factor(idR), idY_rand = as.factor(idY))
preds = preds %>% select(id=id1, idNo = idNo, id_rand, idY_rand, lat=latitude, long=longitude, sim_month, sim_year, elevation, tmax_d, tmin_d, tave_d, ppt_d)

#Read in the table with years and sites that have temperature data for emergence prediction.
yearRef = readRDS(file = "predsYears.rds")
preds = preds %>% inner_join(., yearRef, by = c("id"="GeoLocID","sim_year"="year"))
#There are four site/year combinations in the reference dataset that are not in the prediction dataset because they were manually removed during visual inspection of prediction site locations. These sites were noted to be in locations were a stream was not evident by gazeteer records and did not include much temperature data so they were deamed unworthy of follow-up and removed for simplicity. 

#Write to .csv and shapefile.
WGS84 = crs("+init=epsg:4326"); BCAlbers = crs("+init=epsg:3005") 
preds.sp = SpatialPointsDataFrame(coords = preds[,c("long","lat")], data = preds, proj4string = WGS84)
preds.sp = spTransform(x = preds.sp, CRSobj = BCAlbers)
writeOGR(preds.sp, "../../GIS/lsn/sites/", "preds", driver="ESRI Shapefile", overwrite_layer = T)
write.csv(x = preds, file = "../../GIS/lsn/sites/preds.csv", row.names = F)
