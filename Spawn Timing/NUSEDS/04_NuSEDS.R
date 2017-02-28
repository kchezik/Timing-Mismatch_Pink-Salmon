library(sp); library(rgdal) ;library(raster); library(tidyverse); library(lubridate)
setwd("~/sfuvault/Simon_Fraser_University/PhD_Research/Projects/Timing-Mismatch_Pink-Salmon/Spawn Timing/NUSEDS")
dat = read.csv("NUSEDS_20160428.csv", as.is = T)
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
sites = read.csv("../FraserSites.csv", header = T)

#Select columns of interest and remove sites with insufficient spawn timing information. I selected only the "from" columns.
dat[dat==""] = NA #replace blanks with NA.
dat =dat %>% filter(gfe_id %in% sites$gfe_id)
dat = dat %>% filter(species == "Pink") %>%
	select(gfe_id, pop_id, estimate_classification, start_spawn_dt_from, 
				 peak_spawn_dt_from, end_spawn_dt_from) %>% 
	filter(!is.na(start_spawn_dt_from),!is.na(peak_spawn_dt_from),!is.na(end_spawn_dt_from))

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
saveRDS(dat, "../FraserSpawnRaw.rds")


#Create data distributions.
dat = readRDS("../FraserSpawnRaw.rds")
names(dat) = c("id","pop","start","peak","end","peak_year","lat","long")
date = strptime(x = paste(as.character(dat$peak), as.character(dat$peak_year)), format = c("%j %Y")) %>% as.Date()
dat = dat %>% mutate(peak_month = month(date + 100)); rm(date)
#Read in the reference site location database which has been verified for locality relative to the stream network.
ref = read.csv(file = "../FraserSpawnSitesClean.csv", header = T)
#Update the raw NUSEDS data with the clean locality data.
dat = ref %>% select(X,Y,pop) %>% full_join(dat,.,by="pop") %>% select(-lat,-long); rm(ref)
names(dat)[c(8,9)] = c("long","lat"); dat = dat %>% select(id,pop,start,peak,end,peak_year, peak_month,lat,long)
#Add column of standard deviation estimates given the range of spawn timing and peak spawn.
dat = dat %>% mutate(sd = sqrt((((log(start) - log(peak))^2) + ((log(end) - log(peak))^2))/2))

set.seed(100)
#Expand the dataset to include range of possible spawn dates. Used 20 samples to keep the number of rows below 10,000 as the SSN model is not yet capable of carrying more. Waiting for big data capabilities.
newdat = dat %>% group_by(id, peak_year) %>% do({
	data_frame(
		sim = rlnorm(20, meanlog = log(.$peak), sdlog = .$sd)
	)
}) %>% right_join(., dat, by = c("id", "peak_year"))

#Determine the month in which simulated spawning occured and update any years where the simulated data ticked over into the next year from observed spawning.
sim_doy = round(newdat$sim) #Get whole number DOYs.
next_year = which(sim_doy>365) #Determine which simulated spawn days happened in the next year.
sim_doy[next_year] = sim_doy[next_year] - 365 #Change doy to ensure days occur between 0-365.
newdat$sim_month = as.numeric(format(c(as.Date(strptime(x = sim_doy, format = "%j"))+100),"%m")) #Determine the month of simulated spawning.
newdat$sim_year = newdat$peak_year #Create new year column.
newdat[next_year,"sim_year"] = newdat[next_year,"sim_year"] + 1 #Update simulation year column to reflect those instances where the date goes into the next year.
rm(next_year, sim_doy)

#Clean up climate data.
climdat = read.csv("../Spawn Site-Climate Data/sites_1957-1998AMT.csv")
names(climdat) = tolower(names(climdat))
climdat = climdat %>% select(year,id1,elevation,starts_with("tmax"),starts_with("tmin"),starts_with("tave"),starts_with("ppt"))

#Combine climate data with spawn simulation/raw data.
newdat = left_join(newdat, climdat, by = c("id"="id1","peak_year"="year"))
dat = left_join(dat, climdat, by = c("id"="id1","peak_year"="year"))

#Add temperature and precipitation columns for data in the month of the simulated spawn date.
d_FUN = function(x, var, months){
	#browser()
	n = nchar(var)
	cdat= x[,substr(names(x),1,n)==var] #identify climate data columns of interest.
	cols = x[,names(x)==months][[1]] #identify months of interest.
	rows = as.numeric(row.names(x))
	unlist(lapply(rows,function(y){
		#browser()
		cdat[y,cols[y]][[1]]
	}))
}
newdat = newdat %>% ungroup(.) %>% mutate(tmax_d = d_FUN(.,"tmax", "sim_month"), tmin_d = d_FUN(.,"tmin", "sim_month"), tave_d = d_FUN(.,"tave", "sim_month"), ppt_d = d_FUN(.,"ppt", "sim_month"))
dat = dat %>% tbl_df() %>% mutate(tmax_d = d_FUN(.,"tmax", "peak_month"), tmin_d = d_FUN(.,"tmin", "peak_month"), tave_d = d_FUN(.,"tave", "peak_month"), ppt_d = d_FUN(.,"ppt", "peak_month"))

#Ensure the ID's for individual populations and years are factors instead of numeric AND create a column that combines the year and ID so we can simply use both as a random effect rather than carrying Year as a fixed effect in the model.
#Simulated Data.
idR = paste(as.character(newdat$id),as.character("fraser"),sep = "_")
idY = paste(as.character(newdat$id),as.character(newdat$peak_year),sep = "_")
newdat = mutate(newdat, id_rand = as.factor(idR), idY_rand = as.factor(idY))
newdat = newdat %>% select(id, id_rand, idY_rand, pop, start, peak, end, peak_month, peak_year, lat, long, sd, sim, sim_month, sim_year, elevation, starts_with("tmax"), starts_with("tmin"), starts_with("tave"),starts_with("ppt"))
#Site Data.
idR = paste(as.character(dat$id),as.character("fraser"),sep = "_")
idY = paste(as.character(dat$id),as.character(dat$peak_year),sep = "_")
dat = mutate(dat, id_rand = as.factor(idR), idY_rand = as.factor(idY))
dat = dat %>% select(id, id_rand, idY_rand, pop, start, peak, end, peak_month, peak_year, lat, long, elevation, starts_with("tmax"), starts_with("tmin"), starts_with("tave"),starts_with("ppt"))

#Save the original and new simulated datasets to .csv and shapefiles.
write.csv(x = newdat, file = "../../GIS/lsn/sites/sim_sites.csv", row.names = F)
newdat = read.csv(file = "../../GIS/lsn/sites/sim_sites.csv", header = T)
write.csv(x = dat, file = "../../GIS/lsn/sites/sites.csv", row.names = F)
dat = read.csv(file = "../../GIS/lsn/sites/sites.csv", header = T)
#Save spatial files.
WGS84 = crs("+init=epsg:4326"); BCAlbers = crs("+init=epsg:3005")
#Simulation Data
newdat.sp = SpatialPointsDataFrame(coords = newdat[,c("long","lat")], data = newdat, proj4string = WGS84)
newdat.sp = spTransform(x = newdat.sp, CRSobj = BCAlbers)
writeOGR(newdat.sp, "../../GIS/lsn/sites/", "sim_sites", driver="ESRI Shapefile", overwrite_layer = T)
#Site Data
dat.sp = SpatialPointsDataFrame(coords = dat[,c("long","lat")], data = dat, proj4string = WGS84)
dat.sp = spTransform(x = dat.sp, CRSobj = BCAlbers)
writeOGR(dat.sp, "../../GIS/lsn/sites/", "sites", driver="ESRI Shapefile", overwrite_layer = T)

