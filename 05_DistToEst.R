library(tidyverse); library(lubridate); library(spatial); library(sp); library(rgdal); library(attenPlot); library(SSN)

#Read in temperature locality data that has been visually inspected and corrected for errors.
sites = readOGR(dsn = "./02_SpawnTiming/lsn/sites", "preds")
df = sites@data %>% select(geolocid, latitude, longitude) %>% distinct()
WGS84 = CRS("+init=epsg:4326"); BCAlbers = CRS("+init=epsg:3005")
sites = SpatialPointsDataFrame(coords = df[,c("longitude","latitude")], data = df, proj4string = WGS84)
sites = spTransform(sites, BCAlbers)

#Read in temperature locality data that has been visually inspected and corrected for errors.
estuary = readOGR(dsn = "./03_Emergence_Model/estuary_location/", layer = "estuary")

#Determine the distance between the estuary and the points of emergence. Returns distance in kilometeres.
distance = spDistsN1(pts = sites, pt = estuary, longlat = F)

#Combine into dataframe and determine travel time.
df = df %>% mutate(Ldist = distance)

#Read in the .ssn network data.
network = importSSN("./02_SpawnTiming/lsn/sites_sims.ssn", predpts = "preds", o.write = F)
net <- getSSNdata.frame(network, Name = "preds")
net = net %>% select(geolocid, upDist) %>% distinct() %>% 
	left_join(df, ., by = "geolocid") %>% rename(Rdist = upDist) %>% 
	filter(!is.na(Rdist)) %>% 
	mutate(travelDays = (Rdist/max(Rdist))*2)

#Save estimated linear and river distance and travel time estimate reference to a dataframe.
as.tbl(net) %>% saveRDS(., file = "Data_06_DistanceTravelRef.rds")




#Hope Flow Station
#Peak Discharge in 2017 was 14,800 m^3/s
#River Width at peak is approximately 612m
#River Depth at peak was 10.863

#Therefore the max velocity of the stream is appoximately .... velocity = discharge/(depth*width)

14800/(10.863*665) #2.048756 m/s

# If we multiply by the seconds in a day and divide by 1000 meters we get meters per day.
(2.048756*43200)/1000 # 88.50626

# Because pink salmon have been shown to swim a bit thereby increasing speed we can probably safely round to 90km a day. This value assumes day and night travel and max stream velocity. A more reasonable number may be 45km per day because pink salmon travel by night predominately.

#Ultimately our range of travel times under these assumptions would be 0.5 to 26.5 days compared with our assumed 2 days.