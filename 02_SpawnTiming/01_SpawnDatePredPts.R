library(rgdal); library(sp); library(raster) #Read in spatial libraries.
library(tidyverse); library(lubridate) #Read in tidyverse libraries.


################################################################################################
#This bit of code was to bring in the temperature locality data. These data are full of errors.#
#Use the cleaned .csv file to avoid having to individually check the locality information.     #
################################################################################################

#Stream Temperature Data
temp = readRDS("Data_01_Temperature.rds") #Read in stream temprature data.
#Stream Temperature Locality Data. Visually inspect for correctness.
preds = read_rds("../Data/Subset\ Data/01_Site_Locality_Data.rds") %>% 
	select(GeoLocID, Latitude, Longitude) %>% filter(GeoLocID %in% temp$geolocid)
#Create reference table in order to isolate years at each site for which we have temperature data for spawn timing prediction.
temp %>% mutate(year = year(ymd(date))) %>% select(geolocid,year) %>% distinct() %>%
	saveRDS(., file = "./02_SpawnTiming/Spawn\ Site-Climate\ Data/predsYears.rds")
#Write csv of locality data for inspection.
write.csv(x = preds, file = "./02_SpawnTiming/Spawn\ Site-Climate\ Data/preds.csv", row.names = F)
#Insepcet 'preds.csv' in QGIS to make sure data points on the stream network and not out of place ...
# given the desicriptions in the store.mdb file.


#################################################################################################
# Start from below here only if you are adding new sites that require climate data calculations.#
#################################################################################################

#Read in temperature locality data that has been visually inspected and corrected for errors.
preds = read.csv("./02_SpawnTiming/Spawn\ Site-Climate\ Data/TempSitesClean.csv", header = T)
#Reshape the data to be used in the ClimateBC tool.
preds = preds %>% 
	mutate(ID1 = GeoLocID, ID2 = GeoLocID, 
				 lat = Y, long= X) %>% 
	select(ID1,ID2,lat,long,-GeoLocID,-Latitude,-Longitude)

#Make GeoL a spatial object.
WGS84 = crs("+init=epsg:4326")
coords = preds[,c("long","lat")]
sp = SpatialPoints(coords = coords, proj4string = WGS84)
#Extract elevation data from DEM.
dem = raster::raster(x = "~/sfuvault/Simon_Fraser_University/PhD_Research/Projects/Data/Original_Data/GIS_Data/DEMs/BC_DEM/dem_merge/mergeDEM.tif", band = 1)
sp$el = raster::extract(x = dem, y = sp, method = 'simple')
sp = data.frame(sp) %>% select(-optional)
#Add elevation to the temperature dataframe.
preds = preds %>% left_join(., sp, by = c("lat","long"))
preds %>% write.csv(x = ., file = "./02_SpawnTiming/Spawn\ Site-Climate\ Data/preds.csv", row.names = F)
#The output must be opened and saved as a .csv file in Excel. Unsure why I can't seem to save it properly but without this step ClimateBC will not read the datafile correctly.


################################################################################################
# Start from below here unless starting from scratch or adding/removeing sites.                #
################################################################################################

#Prediction Values Must Include: Year,Latitude,Longitude,Elevation,tmax,tmin,tave,ppt,tmax_d,tmin_d,tave_d,ppt_d
#Read in data.
preds = read.csv("./02_SpawnTiming/Spawn Site-Climate Data/preds_1957-2010AMT.csv",header = T)
names(preds) = tolower(names(preds))
#Select columns of interest.
preds = preds %>% select(id1,latitude,longitude,year,elevation,starts_with("tmax"),starts_with("tmin"),starts_with("tave"),starts_with("ppt"))
#Create a long format dataset.
preds = preds %>% gather(key = "clim_var", value = "clim_val", 6:53)
#Add a month variable to the long dataset.
preds = preds %>% do({
	end = nchar(.[,6])
	data.frame(month = as.numeric(substr(.[,6], end-1, end)),
						 var = substr(.[,6], 1, end-2))
}) %>% bind_cols(preds,.)

#For each site and year create a mean fall (ave, max, min, ppt) temperature/precipitation (Sept. - Nov.). This will capture weather in a given year that influences spawn timing.
fall = preds %>% group_by(id1, year, var) %>% 
	filter(month>8,month<11) %>% 
	mutate(fall = mean(clim_val)) %>% 
	select(id1, fall) %>% ungroup() %>%  
	distinct() %>% spread(key = var, value = fall)
names(fall)[3:6] = c("F_ppt", "F_tave", "F_tmax", "F_tmin")
#For each site create a mean winter incubation climate variable for the 44 years in this dataset (Oct. - Feb.). This will  create a site level temperature/precipitation value that is genetically programed.
winter = preds %>% group_by(id1, var) %>% 
	filter(month>10|month<2, year>1957, year<1998) %>% 
	mutate(winter = round(mean(clim_val),2)) %>% 
	select(id1, winter) %>% ungroup() %>% 
	distinct() %>% spread(key = var, value = winter)
names(winter)[2:5] = c("W_ppt", "W_tave", "W_tmax", "W_tmin")
#Spread out climate variables.
preds = preds %>% ungroup() %>% select(-month, -var) %>% spread(key = clim_var, value = clim_val)
#Join winter, fall and other climate data.
preds = preds %>% left_join(., fall)
preds = preds %>% left_join(., winter)
#Add a geolocid that's the same as 'id'.
preds = preds %>% mutate(geolocid = id1)
preds = preds %>% select(1,62,2:61)

#Read in the table with years and sites that have temperature data for emergence prediction.
yearRef = readRDS(file = "./02_SpawnTiming/Spawn\ Site-Climate\ Data/predsYears.rds")
preds = preds %>% inner_join(., yearRef, by = c("id1"="geolocid","year"))
#There are four site/year combinations in the reference dataset that are not in the prediction dataset because they were manually removed during visual inspection of prediction site locations. These sites were noted to be in locations where a stream was not evident by gazeteer records and did not include much temperature data so they were deamed unworthy of follow-up and removed for simplicity. 

#Write to .csv and shapefile.
WGS84 = crs("+init=epsg:4326"); BCAlbers = crs("+init=epsg:3005") 
preds.sp = SpatialPointsDataFrame(coords = preds[,c("longitude","latitude")], data = preds, proj4string = WGS84)
preds.sp = spTransform(x = preds.sp, CRSobj = BCAlbers)
writeOGR(preds.sp,"./02_SpawnTiming/lsn/sites/", "preds", driver="ESRI Shapefile", overwrite_layer = T)
write.csv(x = preds, file = "./02_SpawnTiming/lsn/sites/preds.csv", row.names = F)




#################################################################################################
# Block Kriging Predictions. Add climate data to all sites.                                     # 
#################################################################################################
WGS84 = crs("+init=epsg:4326"); BCAlbers = crs("+init=epsg:3005") 
BK = readOGR("./02_SpawnTiming/lsn/sites/", "BKpreds")
BK = spTransform(x = BK, CRSobj = BCAlbers)

#Extract elevation data from DEM.
dem = raster::raster(x = "~/sfuvault/Simon_Fraser_University/PhD_Research/Projects/Data/Original_Data/GIS_Data/DEMs/BC_DEM/dem_merge/mergeDEM.tif", band = 1)
BK$el = raster::extract(x = dem, y = BK, method = 'simple')
BK@data[is.na(BK@data$el),"el"]  = 0
BK = spTransform(x = BK, CRSobj = WGS84)
BK = data.frame(BK) %>% mutate(ID1 = 1:nrow(.), ID2 = 1:nrow(.)) %>% select(ID1,ID2,coords.x2,coords.x1,el)
names(BK)[c(3,4)] = c("lat","long")
write.csv(x = BK, file = "./02_SpawnTiming/Spawn\ Site-Climate\ Data/BKpreds.csv", row.names = F)

#Prediction Values Must Include: Year,Latitude,Longitude,Elevation,tmax,tmin,tave,ppt,tmax_d,tmin_d,tave_d,ppt_d
#Read in data.
preds = read.csv("./02_SpawnTiming/Spawn Site-Climate Data/BKpreds_1957-2010AMT.csv",header = T)
names(preds) = tolower(names(preds))
#Select columns of interest.
preds = preds %>% select(id1,latitude,longitude,year,elevation,starts_with("tmax"),starts_with("tmin"),starts_with("tave"),starts_with("ppt"))
#Create a long format dataset.
preds = preds %>% gather(key = "clim_var", value = "clim_val", 6:53)
#Add a month variable to the long dataset.
preds = preds %>% do({
	end = nchar(.[,6])
	data.frame(month = as.numeric(substr(.[,6], end-1, end)),
						 var = substr(.[,6], 1, end-2))
}) %>% bind_cols(preds,.)

#For each site and year create a mean fall (ave, max, min, ppt) temperature/precipitation (Sept. - Nov.). This will capture weather in a given year that influences spawn timing.
fall = preds %>% group_by(id1, year, var) %>% 
	filter(month>8,month<11) %>% 
	mutate(fall = mean(clim_val)) %>% 
	select(id1, fall) %>% ungroup() %>%  
	distinct() %>% spread(key = var, value = fall)
names(fall)[3:6] = c("F_ppt", "F_tave", "F_tmax", "F_tmin")
#For each site create a mean winter incubation climate variable for the 44 years in this dataset (Oct. - Feb.). This will  create a site level temperature/precipitation value that is genetically programed.
winter = preds %>% group_by(id1, var) %>% 
	filter(month>10|month<2, year>1957, year<1998) %>% 
	mutate(winter = round(mean(clim_val),2)) %>% 
	select(id1, winter) %>% ungroup() %>% 
	distinct() %>% spread(key = var, value = winter)
names(winter)[2:5] = c("W_ppt", "W_tave", "W_tmax", "W_tmin")
#Spread out climate variables.
preds = preds %>% ungroup() %>% select(-month, -var) %>% spread(key = clim_var, value = clim_val)
#Join winter, fall and other climate data.
preds = preds %>% left_join(., fall)
preds = preds %>% left_join(., winter)
#Add a geolocid that's the same as 'id'.
preds = preds %>% mutate(geolocid = id1)
preds = preds %>% select(1,62,2:61)

#Write to .csv and shapefile.
WGS84 = crs("+init=epsg:4326"); BCAlbers = crs("+init=epsg:3005") 
for(i in seq(from = 1960,2010,by=10)){
	df = preds %>% filter(year == i)
	preds.sp = SpatialPointsDataFrame(coords = df[,c("longitude","latitude")],
																		data = df, proj4string = WGS84)
	preds.sp = spTransform(x = preds.sp, CRSobj = BCAlbers)
	writeOGR(preds.sp,"./02_SpawnTiming/lsn/sites/", paste("BK_",as.character(i),sep = ""), driver="ESRI Shapefile", overwrite_layer = T)
	write.csv(x = preds,
						file = paste("./02_SpawnTiming/lsn/sites/","BK_",as.character(i),".csv",sep=""),
						row.names = F)
}