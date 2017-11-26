library(tidyverse); library(lubridate); library(SSN)

#Hope Flow Station (08MF005)
#Peak Discharge in 2017 was 14,800 m^3/s
#River Width at peak is approximately 612m
#River Depth at peak was 10.863m

#Therefore the max velocity of the stream is appoximately .... velocity = discharge/(depth*width)

14800/(10.863*665) #2.048756 m/s

# If we multiply by the seconds in a day and divide by 1000 meters we get meters per day.
(2.048756*43200)/1000 # 88.50626

# ~90km a day assumes day and night travel and max stream velocity. Ultimately our range of travel times under these assumptions would be 0.5 to 18 days compared with our assumed 2 days.

#Read in the .ssn network data.
network = importSSN("./02_SpawnTiming/lsn/sites_sims.ssn", predpts = "preds", o.write = F)
net <- getSSNdata.frame(network, Name = "preds")
net = net %>% select(geolocid, upDist, latitude, longitude) %>% 
	distinct() %>% rename(Rdist = upDist)
rm(network)

#Load flow data.
load("../River-Network-Flow-Trends/01_Data-Flow-Orig.RData")
flow = Flow.2 %>% filter(Station.ID == "08MF005") %>%
	mutate(year = year(ymd(Date))) %>% 
	group_by(year) %>% filter(Flow.Data == max(Flow.Data), year > 1966, year < 2011) %>% 
	summarise(flow = mean(Flow.Data, na.rm = T))
rm(Flow.2)

#Gather and organize depth data.
depth = Hmisc::mdb.get("../Data/Original_Data/HYDAT/Hydat.mdb", tables = "DLY_LEVELS")
names(depth) = tolower(names(depth))
depth = filter(depth, station.number == "08MF005")
#Change df from wide to long format.
depth = depth %>% select(1,2,3,matches("level\\d+")) %>% 
	gather(key = "day", value = "depth", 4:34)
#Standardize column types.
depth$day = as.numeric(stringr::str_extract(depth$day,"\\d+"))
depth$year = as.numeric(depth$year)
depth$month = as.numeric(depth$month)
depth$station.number = as.character(depth$station.number)
#Add date column.
depth = depth %>% do({
	year  = as.character(.$year)
	month = if_else(as.numeric(grep("\\d+",.$month, value = T))<10, 
					paste("0",as.character(.$month),sep=""),
					as.character(.$month))
	day = if_else(as.numeric(grep("\\d+",.$day, value = T))<10, 
								paste("0",as.character(.$day),sep=""),
								as.character(.$day))
	
	data.frame(station.number = .$station.number, 
						 date = lubridate::ymd(paste(year,month,day,sep="")),
						 depth = .$depth)
})

#How do the paramters in the power law affect the intercept and slope.
test = expand.grid(flow = seq(6000, 12000, by = 1000), alpha = seq(0.12, 0.63, by = 0.1), beta = seq(0.28, 0.32, by = 0.01))
test = test %>% mutate(depth = alpha*flow^beta, group = paste(as.character(alpha), as.character(beta),sep = ""))
ggplot(test, aes(flow, depth, color=alpha, group = group)) + geom_line() + facet_wrap(~beta)

#Add depth to the flow data.
flow = depth %>% mutate(Year = year(date)) %>% group_by(Year) %>% 
	summarise(depth = max(depth, na.rm = T)) %>% left_join(flow,.,by=c("year" = "Year"))

#Fill in unknown depth.
# I adjusted the intercept (c) parameter (from 0.27 to 0.52) to increase the depth estimate and bring it in line with our observed depth to discharge relationship. This adjustement is well within the 95% CI of the model.
flow[is.na(flow$depth),"depth"] = 0.52*flow[is.na(flow$depth),"flow"]^0.3
ggplot(flow, (aes(flow, depth))) + geom_point()

#Estimate width from known discharge power relationships (Moody & Troutman (2002)). 
flow = flow %>% mutate(width = 7.2*flow^0.50)
ggplot(flow, (aes(depth, width))) + geom_point()


#Add velocity in meters per day.
flow = flow %>% mutate(vel = ((flow/(width*depth))*43200)/1000)

#Add travel days given the river velocity.
travel = expand.grid(geolocid = net$geolocid, year = unique(flow$year))
travel = net %>% left_join(travel,.,by = "geolocid")
travel = flow %>% select(year,vel) %>% left_join(travel,., by = "year")
travel = travel %>% mutate(travelDays_vel = (Rdist/1000)/vel) %>% arrange(geolocid, year)

ggplot(travel, aes(Rdist, travelDays_vel)) + geom_point()

#Save estimated linear and river distance and travel time estimate reference to a dataframe.
saveRDS(travel, file = "Data_06_DistanceTravelRef.rds")
