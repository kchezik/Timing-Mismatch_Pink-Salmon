#Data Cleaning
library(tidyverse); library(lubridate)
setwd("~/sfuvault/Simon_Fraser_University/PhD_Research/Projects/Data/Subset Data")
load("05-2 Locality Limited Temperature Data.RData")

#Reduce dates to those falling within years of phytoplankton data.
Temp.Loc = Temp.Loc %>% filter(Date>=as.Date("1967-01-01") & Date<=as.Date("2010-12-31"))
#Remove rows with no mean water temperature data and filter out unused columns. 
Temp.Loc = Temp.Loc %>% filter(is.na(MeanWaterT)==F) %>% select(GeoLocID, Date, contains("Water"))
#Add a 'week number' column and a 'number of days in each week column'. Remove any rows with fewer than 5 days in the week.
Temp.Loc = Temp.Loc %>% mutate(week_No = week(ymd(Date)), month = month(Date), year = year(Date)) #Week numbers.
Temp.Loc = Temp.Loc %>% group_by(GeoLocID, year, week_No) %>% mutate(nDaysWeek = length(unique(Date))) #Days in each week.
Temp.Loc = Temp.Loc %>% filter(nDaysWeek>=5) %>% ungroup() %>% select(-week_No, -nDaysWeek) #Remove weeks with fewer than 5 days.
#Determine the number of days in each month and remove months with fewer than 25 days. Missing days will be interpolated later.
Temp.Loc = Temp.Loc %>%	group_by(GeoLocID, year, month) %>% mutate(n = length(unique(Date))) %>% filter(n >= 23) %>% ungroup() %>% 
	select(-n)
#Determine which years contain at least 5 fall months or 4 spring months.
Temp.Loc = Temp.Loc %>% group_by(GeoLocID, year) %>% mutate(n.fall = sum(unique(month)>=8), n.spring = sum(unique(month)<=4)) %>%
	filter(n.fall == 5 | n.spring == 4) %>% ungroup() %>% select(-n.fall, -n.spring)
#Isolate years and months.
MYears = Temp.Loc %>% select(GeoLocID, year, month) %>% distinct() %>% 
	group_by(GeoLocID, year) %>% summarize(fall = any(month>7), spring = any(month<7)) %>% 
	#Determine which seasons within years are useful to the spawn timing analysis.
	group_by(GeoLocID) %>% do({
		#Create objects to fill and a counter to keep track location.
		spring.retain = NULL;	fall.retain = NULL;	count = 1
		for(i in .$year){
			#Determine if there is a year behind and/or ahead of the current year. 
			behind = which(.$year == i - 1)
			ahead = which(.$year == i + 1)
			current = which (.$year == i)
			#Assign a 1 or 0 if the spring data is necessary/unnecessary given the presence/absence of the previous year.
			if(length(behind)==1){
				spring.retain[count] = if_else(.[behind,"fall"]==T, true = 1, false = 0)
			}
			else spring.retain[count] = 0
			#If the spring data is necessary, check if the fall data in the current year exists.
			if(spring.retain[count]==1){
				spring.retain[count] = if_else(.[current,"spring"]==T, true = 1, false = 0)
			}
			#Assign a 1 or 0 if the fall data is necessary/unnecessary given the presence/absence of a following year.
			if(length(ahead)==1){
				fall.retain[count] = if_else(.[ahead,"spring"]==T, true = 1, false = 0)
			}
			else fall.retain[count] = 0
			#If the fall data is necessary, check if the spring data in the current year exists.
			if(fall.retain[count] == 1){
				fall.retain[count] = if_else(.[current,"fall"]==T, true = 1, false = 0)
			}
			#Increase the counter.
			count = count + 1
		}
		#Collate into a dataframe.
		data.frame(year = .$year, spring.retain, fall.retain)
	})
#Join the month & years reference object to the temperature dataframe and filter out any rows with 0 in both the spring.retain and fall.retain columns.
Temp.Loc = Temp.Loc %>% left_join(., MYears, by = c("GeoLocID","year")) %>%
	filter(spring.retain != 0 | fall.retain != 0) %>% ungroup() %>%
	select(GeoLocID, Date, year, month, contains("Water"), -spring.retain, -fall.retain)
rm(MYears)

Temp.Loc %>% filter(GeoLocID > 1586) %>% 
	ggplot(aes(Date, MeanWaterT), color = "black") +
	geom_point() +
	geom_point(aes(Date, MaxWaterT), color = "red") +
	geom_point(aes(Date, MinWaterT), color = "blue") +
	geom_point(aes(Date, SptWaterT), color = "green") +
	facet_wrap(~GeoLocID, scales = "free")

setwd("~/sfuvault/Simon_Fraser_University/PhD_Research/Projects/Timing-Mismatch_Pink-Salmon")
saveRDS(Temp.Loc, file = "Data_01_Temperature.rds")




#Identify Remove and Interpolate Erroneous Data.

library(randomForest); library(caret); library(tidyverse); library(lubridate)

setwd("~/sfuvault/Simon_Fraser_University/PhD_Research/Projects/Timing-Mismatch_Pink-Salmon")
dat = readRDS("Data_01_Temperature.rds")

#Add the day of year to the data frame.
dat = dat %>% mutate(doy = yday(ymd(Date)))
#Make month numeric rather than character.
dat$Month = as.numeric(dat$Month)
#Look at predictor correlation matrix
dat %>% select(GeoLocID, MeanWaterT, Month, Year, doy) %>% cor(x = ., use = "na.or.complete")

predictors = dat %>% select(GeoLocID, MeanWaterT, Month, Year, doy) %>% na.omit()
out = randomForest(formula = MeanWaterT ~ GeoLocID + Year + doy, data = predictors)

plot(out)
outlier(out)
varImpPlot(out)
getTree(rfobj = out, k = 1, labelVar = T) %>% head()




#######################################
# Clean and Label the Temperature Data#
#######################################


######		######		Site #63		 ######		######

#Add columns for erroneous data and for air/water assignment. Error/Air = 1 where as 0 = correct.
dat = dat %>% mutate(error = rep(0,nrow(dat)), AirWater = rep(0, nrow(dat)))

#Isolate Individual Site
sites = dat %>% select(GeoLocID) %>% distinct()
siteDat = filter(dat, GeoLocID==sites[[1]][1])
#Isolate and View Periods of Interest.
years = 365 * 5
DateInitial = min(siteDat$Date) + years
DateFinal = DateInitial + 365
siteDat %>% filter(Date>=DateInitial, Date<=DateFinal) %>%
	ggplot(aes(Date, MeanWaterT)) +
	geom_point() #+
	#geom_point(aes(Date, MaxWaterT), color = "red") +
	#geom_point(aes(Date, MinWaterT), color = "blue")

#Deal with Duplicates, Zeros and Obvious Air Temperature or Other Erroneous Recordings.
siteDat %>% filter(Date>DateInitial, Date<DateFinal) %>% arrange(Date) %>% print.data.frame()
#id zeros
dat[which(dat$GeoLocID==sites[[1]][1] & dat$MeanWaterT == 0),"error"] = 1
#data appears to be overlaid from either a different time period or site but does not appear to be 