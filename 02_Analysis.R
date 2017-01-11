library(tidyverse)
setwd("~/sfuvault/Simon_Fraser_University/PhD_Research/Projects/Timing-Mismatch_Pink-Salmon")
M.Temp = readRDS("Data_01_Temperature.rds")

ggplot(M.Temp, aes(Date, as.factor(GeoLocID))) +
	geom_point()

M.Temp %>% dplyr::filter(Year < 1984) %>%
	ggplot(., aes(Date, MeanWaterT, color = GeoLocID)) +
	geom_point() +
	facet_wrap(~Year, scales = "free_x") +
	theme_bw() +
	theme(legend.position="none") +
	scale_x_date(date_breaks = "months", date_labels = "%b") +
	xlab("Month")

M.Temp %>% dplyr::filter(Year > 1983 & Year < 2000) %>%
	ggplot(., aes(Date, MeanWaterT, color = GeoLocID)) +
	geom_point() +
	facet_wrap(~Year, scales = "free_x") +
	theme_bw() +
	theme(legend.position="none") +
	scale_x_date(date_breaks = "months", date_labels = "%b") +
	xlab("Month")

M.Temp %>% dplyr::filter(Year > 1999) %>%
	ggplot(., aes(Date, MeanWaterT, color = GeoLocID)) +
	geom_point() +
	facet_wrap(~Year, scales = "free_x") +
	theme_bw() +
	theme(legend.position="none") +
	scale_x_date(date_breaks = "months", date_labels = "%b") +
	xlab("Month")

M.Temp %>% group_by(GeoLocID) %>%
	ggplot(aes(Date,MeanWaterT)) +
	geom_point()

##########################################
#Emergence Day Calculations for All Sites#
##########################################

results = M.Temp %>% group_by(GeoLocID,period) %>% dplyr::filter(is.na(MeanWaterT)!=T) %>% summarize(
	year = unique(Year)[1],
	odd.date = 
		max(seq(as.Date(paste(year,"-10-01", sep = "")), length.out = round(exp(7.190 - log(mean(MeanWaterT + 2.663)))), by = "day")), #odd year [sd-a: 0.02 | sd-b: 0.13]
	even.date = 
		max(seq(as.Date(paste(year,"-10-01", sep = "")),length.out = round(exp(7.339 - log(mean(MeanWaterT + 3.755)))), by = "day")),
	mean.T = mean(MeanWaterT)) %>% #even year [sd-a: 0.01 | sd-b: 0.09] 
	data.frame()

results = results %>% mutate(odd.month_day = as.Date(format(.$odd.date, "2000-%m-%d")), even.month_day = as.Date(format(.$even.date, "2000-%m-%d")))

ggplot(results, aes(NULL)) +
	geom_density(aes(odd.month_day), color = "green", fill = "green", alpha = 0.1) +
	geom_density(aes(even.month_day), color = "blue", fill = "blue", alpha = 0.1) +
	theme_bw() +
	scale_x_date(date_breaks = "months", date_labels = "%b") +
	xlab("Month")


###########################
#Single Period Analysis####
###########################
one.year = M.Temp %>% dplyr::filter(Date > as.Date("2009-07-01"))
#Eliminate sites with completly missing data either in the fall or spring period.
cull.partial = one.year %>% group_by(GeoLocID) %>% 
	summarize(before.jan = length(which(as.numeric(Month) > 7)), after.jan = length(which(as.numeric(Month)<7)))%>%
	as.data.frame() %>% dplyr::filter(before.jan != 0 & after.jan != 0)
partial.year = one.year %>% dplyr::filter(GeoLocID%in%cull.partial$GeoLocID)
cull.full = cull.partial %>% dplyr::filter(before.jan == 92 & after.jan == 120)

ggplot(partial.year, aes(Date, MeanWaterT)) +
	geom_point() +
	facet_wrap(~GeoLocID, scales = "free_y")



#############################################
#Temperature Site Location Distance to Ocean#
#############################################
setwd("~/sfuvault/Simon_Fraser_University/PhD_Research/Projects/Data/Subset Data")
load("01-1 Site Locality Data WGS84.RData")
temp.sites = unique(results$GeoLocID)
site.loc = do.call("rbind", lapply(temp.sites, function(x){
	GeoLocID = x
	UTME = GeoL[which(GeoL[,"GeoLocID"] == x),"BC.Alb..E"]
	UTMN = GeoL[which(GeoL[,"GeoLocID"] == x),"BC.Alb..N"]
	data.frame(GeoLocID,UTMN, UTME)
}))
setwd("~/Documents/Simon_Fraser_University/PhD_Research/Projects/Data/Original Data/GIS Data/Fraser WS & River shp file")
library(rgdal)
BC.lim <- readOGR(dsn="Albers", layer="BC_Limit_Albers") #Call the BC boundary polygon.
#points = SpatialPoints(cbind(X=site.loc$UTME, Y=site.loc$UTMN), proj4string = CRS("+proj=aea +lat_1=50 +lat_2=58.5 +lat_0=45 +lon_0=-126 +x_0=1000000 +y_0=0 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0"))
#points = SpatialPointsDataFrame(coords = cbind(site.loc$UTME,site.loc$UTMN), data.frame(GeoLocID=site.loc$GeoLocID))
#writeOGR(points, dsn="/Users/kylechezik/Desktop", layer="Fraser_Temp_Sites", driver = "ESRI Shapefile")

setwd("~/Documents/Simon_Fraser_University/PhD_Research/Projects/Timing-Mismatch_Pink-Salmon")
Distance = readOGR(dsn="GIS", layer="Temp_Site_Dist_to_Coast")
points = readOGR(dsn="GIS", layer="Fraser_Temp_Sites")

par(family = 'serif', fg = NA, las = 1, mar = c(0.25,0.2,0,0), mex = 1, mfrow = c(1,1))
plot(BC.lim, ylim = c(480000, 1225000),xlim=c(850000, 1595000), las=1, lwd=0.25, col = "gray")
plot(Distance, axes=TRUE, add=TRUE)
plot(points, axes=TRUE, add=TRUE)

#To determine the distance between the temperature sites and the ocean I open the BC Limit layer in QGIS. I then added the Fraser Temperature Sites shapefile. I then created teh BC Coast shapefile and drew a line describing the BC west coast. I then turned this coastal line into points seperated by 1km. I then ran the Distance to Nearest Hub algorithm which determines which coastal point each Temperature gauge site is closest to in meters. I output the distance lines as a shapefile and csv file.

###########################################################################
#Temperature Site Location Distance to Ocean with Emergence Timing Results#
###########################################################################

dist = read.csv("~/Documents/Simon_Fraser_University/PhD_Research/Projects/Timing-Mismatch_Pink-Salmon/GIS/Temp_Site_to_Coast_Distance.csv", header = T)[,c(1,3)]
dist$GeoLocID = as.factor(dist$GeoLocID)
results = results %>% left_join(.,dist,by = "GeoLocID")

ggplot(results, aes(NULL,NULL)) +
	geom_point(aes(odd.month_day, HubDist/1000), color="green") +
	geom_point(aes(even.month_day, HubDist/1000), color = "blue") +
	geom_smooth(aes(even.month_day, (HubDist/1000)), color = "blue", method = "lm") +
	geom_smooth(aes(odd.month_day, (HubDist/1000)), color = "green", method = "lm") +
	scale_x_date(date_breaks = "months", date_labels = "%b") +
	theme_bw() +
	xlab("Month") + ylab("Distance (km)") +
	facet_wrap(~period, scales = "free")

ggplot(results, aes(NULL,NULL)) +
	geom_point(aes(odd.month_day, (HubDist/1000)), color="green") +
	geom_point(aes(even.month_day, (HubDist/1000)), color = "blue") +
	geom_smooth(aes(even.month_day, (HubDist/1000)), color = "blue", method = "lm") +
	geom_smooth(aes(odd.month_day, (HubDist/1000)), color = "green", method = "lm") +
	scale_x_date(date_breaks = "months", date_labels = "%b") +
	theme_bw() +
	xlab("Month") + ylab("Distance (km)")






######################################
#Pink Salmon Site Locality Estimation#
######################################
library(rgdal)
Tribs = readOGR(dsn="Albers", layer="Fraser_Tribs_Albers")
Tribs[which(Tribs$GZTTDNM=="ADAMS RIVER"),]
