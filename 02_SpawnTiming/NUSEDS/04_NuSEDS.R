library(sp); library(rgdal) ;library(raster); library(tidyverse); library(lubridate)
dat = read.csv("./02_SpawnTiming/NUSEDS/NUSEDS_20160428.csv", as.is = T)
# ref = read.csv("NuSEDS_Report_Definitions.csv")
# sites = read.csv("../Population_Reports/Conservation_Unit_System_Sites.csv", header = T)

#Change header names to lower case.
names(dat) = tolower(names(dat))
# names(ref) =  tolower(names(ref))
# names(sites) = tolower(names(sites))
# ref$field.name = tolower(ref$field.name)

#Read about each field in the database.
# ref$field.name
# ref %>% filter(field.name == "estimate_classification")

#Site Locations
# loc = sites %>% filter(gfe_id %in% dat$gfe_id) %>% select(gfe_id, system_site, ylat, xlong) %>% distinct() %>% write.csv(., "~/Desktop/sites.csv")

#Sites clipped by the Fraser Basin
sites = read.csv("./02_SpawnTiming/FraserSites.csv", header = T)

#Select columns of interest and remove sites with insufficient spawn timing information. I selected only the "from" columns.
dat[dat==""] = NA #replace blanks with NA.
dat =dat %>% filter(gfe_id %in% sites$gfe_id)
dat = dat %>% filter(species == "Pink") %>%
	select(gfe_id, pop_id, estimate_classification, start_spawn_dt_from, 
				 peak_spawn_dt_from, end_spawn_dt_from) %>% 
	filter(!is.na(start_spawn_dt_from),!is.na(peak_spawn_dt_from),!is.na(end_spawn_dt_from))

# Six locations have start dates that are after ther peak spawn dates. Looking at the raw data it is persuasive that these instances occur because the month of the start spawn date was record as the same as the peak spawn date but should be the prior month. I'm going to minus a month and include the data.
dat$start_spawn_dt_from = if_else(condition = ymd(dat$peak_spawn_dt_from) < ymd(dat$start_spawn_dt_from), ymd(dat$start_spawn_dt_from) - months(1), ymd(dat$start_spawn_dt_from))

#Add a year column and convert the dates to the day of year between 1-365(6).
dat = as.Date(dat$start_spawn_dt_from, format = "%Y-%m-%d") %>% format(., "%Y") %>% as.numeric(.) %>% mutate(dat, year = .)
dat$start_spawn_dt_from = c(as.Date(dat$start_spawn_dt_from, format = "%Y-%m-%d")-100) %>% format(.,"%j") %>% as.numeric(.)
dat$peak_spawn_dt_from = c(as.Date(dat$peak_spawn_dt_from, format = "%Y-%m-%d")-100) %>% format(.,"%j") %>% as.numeric(.)
dat$end_spawn_dt_from = c(as.Date(dat$end_spawn_dt_from, format = "%Y-%m-%d")-100) %>% format(.,"%j") %>% as.numeric(.)

#Add location data.
dat = sites %>% select(gfe_id, ylat, xlong) %>% left_join(dat,.,"gfe_id") %>% select(-estimate_classification)
names(dat)[c(7,8)] = c("latitude","longitude")

#Remove a couple duplicates in the data and make the pop_id and gfe_id consistent for a site.
dat = dat[-which(dat$gfe_id==131 & dat$year %in% c(1987,1985)),] #Remove duplicate.
row = which(dat$gfe_id==131 & dat$year==1998)
dat[row,"gfe_id"]=7990579; dat[row,"pop_id"]=47195

#Look at the data. This prompted me to minus 100 days from the dates to keep everything within a year. I will need to add 100 days when I get the data back out of the model to estimate the correct spawn times.
# ggplot(dat, aes()) + 
# 	geom_histogram(aes(start_spawn_dt_from), fill = "red", alpha = 0.5) +
# 	geom_histogram(aes(peak_spawn_dt_from), fill = "green", alpha = 0.5) +
# 	geom_histogram(aes(end_spawn_dt_from), fill = "blue", alpha = 0.5)
# 
# dat %>% gather(., spawn_timing, day, start_spawn_dt_from, peak_spawn_dt_from, end_spawn_dt_from) %>% 
# 	ggplot(., aes(year, day, color = spawn_timing)) +
# 		geom_smooth()

#Save raw Fraser spawning data.
saveRDS(dat, "./02_SpawnTiming/FraserSpawnRaw.rds")


#Create data distributions.
dat = read_rds("./02_SpawnTiming/FraserSpawnRaw.rds")
names(dat)[1:5] = c("id","pop","start","peak","end")
#Read in the reference site location database which has been verified for locality relative to the stream network.
ref = read.csv(file = "./02_SpawnTiming/FraserSpawnSitesClean.csv", header = T)
#Update the raw NUSEDS data with the clean locality data.
dat = ref %>% select(X,Y,pop) %>% full_join(dat,.,by="pop") %>% select(-latitude,-longitude); rm(ref)
names(dat)[c(7,8)] = c("longitude","latitude"); dat = dat %>% select(id,pop,start,peak,end,year,latitude,longitude)

#Function to estimate SD from the start and peak spawn date.
sdEstimate = function(x, guess.sd = c(1:20)){
	out = abs(qnorm(0.9999, sd = guess.sd)-x)
	rslt = guess.sd[which(out==min(out))]
	rslt
}
#Given the difference between peak spawn and the start of spawn, estimate the SD and add to DF.
dat = dat %>% mutate(sd = map(peak-start, sdEstimate)) %>% unnest()
#Randomly select 22 peak spawn dates from a normal distribution using observed "peak" spawn ...
# ... as the mean and the estimated SD from earlier.
set.seed(123)
newdat = dat %>% group_by(id, year) %>% do({
	data_frame(
		peak = rnorm(22, mean = .$peak, sd = .$sd)
	)
})
newdat = dat %>% rename(peak_obs = peak) %>% 
	right_join(newdat, ., by = c("id", "year"))
#Look at simulated distributions and see if they fall reasonably between the start and end dates.
#ggplot(newdat, aes(peak, color = as.factor(year))) + geom_density() + geom_vline(aes(xintercept = end, color = as.factor(year)), lty = 2) + geom_vline(aes(xintercept = start, color = as.factor(year)), lty = 2) + geom_vline(aes(xintercept = peak_obs, color = as.factor(year))) + facet_wrap(~id, scales = "free") 

#Clean up climate data.
climdat = read.csv("./02_SpawnTiming/Spawn Site-Climate Data/sites_1957-1998AMT.csv")
names(climdat) = tolower(names(climdat))
climdat = climdat %>% select(year,id1,elevation,starts_with("tmax"),starts_with("tmin"),starts_with("tave"),starts_with("ppt"))
#Create a long format dataset.
climdat = climdat %>% gather(key = "clim_var", value = "clim_val", 4:51)
#Add a month variable to the long dataset.
climdat = climdat %>% do({
	end = nchar(.[,4])
	data.frame(month = as.numeric(substr(.[,4], end-1, end)),
						 var = substr(.[,4], 1, end-2))
}) %>% bind_cols(climdat,.)

#For each site and year create a mean fall (ave, max, min, ppt) temperature/precipitation (Sept. - Nov.). This will capture weather in a given year that influences spawn timing.
fall = climdat %>% group_by(id1, year, var) %>% 
	filter(month>8,month<11) %>% 
	mutate(fall = mean(clim_val)) %>% 
	select(id1, fall) %>% ungroup() %>%  
	distinct() %>% spread(key = var, value = fall)
names(fall)[3:6] = c("F_ppt", "F_tave", "F_tmax", "F_tmin")
#For each site create a mean winter incubation climate variable for the 44 years in this dataset (Oct. - Feb.). This will  create a site level temperature/precipitation value that is genetically programed.
winter = climdat %>% group_by(id1, var) %>% 
	filter(month>10|month<2) %>% 
	mutate(winter = round(mean(clim_val),2)) %>% 
	select(id1, winter) %>% ungroup() %>% 
	distinct() %>% spread(key = var, value = winter)
names(winter)[2:5] = c("W_ppt", "W_tave", "W_tmax", "W_tmin")
#Spread out climate variables.
climdat = climdat %>% ungroup() %>% select(-month, -var) %>% spread(key = clim_var, value = clim_val)
#Join winter, fall and other climate data.
climdat = climdat %>% left_join(., fall)
climdat = climdat %>% left_join(., winter)

#Combine climate data with spawn simulation/raw data.
newdat = left_join(newdat, climdat, by = c("id"="id1","year"="year")) %>% 
	mutate(geolocid = id) %>% select(-sd) %>% select(1,67,2:66)
dat = left_join(dat, climdat, by = c("id"="id1","year"="year")) %>%
	mutate(geolocid = id) %>% select(-sd) %>% select(1,66,2:65)

#Save the original and new simulated datasets to .csv and shapefiles.
write.csv(x = newdat, file = "./02_SpawnTiming/lsn/sites/sim_sites.csv", row.names = F)
newdat = read.csv(file = "./02_SpawnTiming/lsn/sites/sim_sites.csv", header = T)
write.csv(x = dat, file = "./02_SpawnTiming/lsn/sites/sites.csv", row.names = F)
dat = read.csv(file = "./02_SpawnTiming/lsn/sites/sites.csv", header = T)
#Save spatial files.
WGS84 = crs("+init=epsg:4326"); BCAlbers = crs("+init=epsg:3005")
#Simulation Data
newdat.sp = SpatialPointsDataFrame(coords = newdat[,c("longitude","latitude")], data = newdat, proj4string = WGS84)
newdat.sp = spTransform(x = newdat.sp, CRSobj = BCAlbers)
writeOGR(newdat.sp, "./02_SpawnTiming/lsn/sites/", "sim_sites", driver="ESRI Shapefile", overwrite_layer = T)
#Site Data
dat.sp = SpatialPointsDataFrame(coords = dat[,c("longitude","latitude")], data = dat, proj4string = WGS84)
dat.sp = spTransform(x = dat.sp, CRSobj = BCAlbers)
writeOGR(dat.sp, "./02_SpawnTiming/lsn/sites/", "sites", driver="ESRI Shapefile", overwrite_layer = T)

