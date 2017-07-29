#Data Cleaning and Organization
library(tidyverse); library(lubridate); library(purrr)
temp.loc = read_rds("../Data/Subset Data/06 Temp_CleanOrg.rds") %>% ungroup()
names(temp.loc)[2] = "geolocid"


#Reduce dates to those falling within years of phytoplankton data.
temp.loc = temp.loc %>% filter(date>=ymd("1967-01-01") & date<=ymd("2010-12-31"))
#Filter for only mean water temperature data. 
temp.loc = temp.loc %>% filter(measurement == "MeanWaterT")
#Add a 'week number', 'cum sum week number' and a 'number of days in each week' column.
temp.loc = temp.loc %>% 
	mutate(month = month(date), 
				 year = year(date), 
				 week_No = week(ymd(date)),
				 siteWeek = ((year-1967)*53) + week_No)
#Correct any week 53's that have only 1 or 2 days in them. Change nDaysWeek from 1 or 2 to 7.
temp.loc = temp.loc %>% group_by(geolocid, year, week_No) %>% 
	mutate(nDaysWeek = if_else(week_No == 53, as.integer(7), n())) #Days in each week.

#For each week in each year, if the number of days in the current week is less than 3, look to the following and preceeding 2 weeks and if they also have less than 3 days data, mark the current week.
temp.loc = temp.loc %>% ungroup() %>%
	select(geolocid, siteWeek, nDaysWeek) %>% 
	distinct() %>% group_by(geolocid) %>% 
	do({
		df = .
		out  = vector(mode = "character", length = nrow(df))
		for(i in seq_along(out)){
			week = df[i,"siteWeek"][[1]]
			daysM = df[i,"nDaysWeek"][[1]]
			if(daysM < 3){
				before = df[which(df$siteWeek==week-2),"nDaysWeek"][[1]]
				after = df[which(df$siteWeek==week+2),"nDaysWeek"][[1]]
				if(length(before)==0) before = 0; if(length(after)==0) after = 0
				if(before >= 1 | after >= 1)
				{
					out[i] = "yes"
				}
				else out[i] = "no"
			}
			else out[i] = "yes"
		}
		data.frame(siteWeek = .$siteWeek, retain = out)
	}) %>% left_join(temp.loc,.)
#Check what data are to be eliminated and if that makes sense. 
ggplot(temp.loc,aes(date, temperature, color = retain)) + geom_point() + facet_wrap(~geolocid, scales = "free")
temp.loc %>% filter(geolocid == 51) %>% 
	ggplot(.,aes(date, temperature, color = retain)) + geom_point()

#Interpolate missing temperature data in weeks with fewer than 7 days.
interp = temp.loc %>% filter(nDaysWeek < 7, retain == "yes") %>% 
	group_by(geolocid, siteWeek) %>% do({
		#Determine the current week and the previous and subsequent week.
		wkObs = unique(.$week_No); geolocID = unique(.$geolocid)
		wkAhead = ifelse(wkObs == 53, 1, wkObs+2)
		wkBehind = ifelse(wkObs == 1, 53, wkObs-2)
		#Make reference data frame to interpolate and gap fill from.
		if(wkObs == 53) {
			ref = data_frame(date = seq(min(.$date)-21, max(.$date)+21, by = "day")) %>% 
				mutate(week_No = week(date)) %>% filter(week_No >= 51 | week_No <= 2)
		}
		else if(wkObs == 1) {
			ref = data_frame(date = seq(min(.$date)-21, max(.$date)+21, by = "day")) %>% 
				mutate(week_No = week(date)) %>% filter(week_No >= 52 | week_No <= 3)
		}
		else {
			ref = data_frame(date = seq(min(.$date)-21, max(.$date)+21, by = "day")) %>% 
				mutate(week_No = week(date)) %>% filter(week_No >= wkBehind, week_No <= wkAhead)
		}
		df = temp.loc %>% filter(geolocid == geolocID) %>% 
			left_join(ref, .) %>% filter(is.na(temperature)==F | week_No==wkObs)
		#Interpolate.
		x = df$date[!is.na(df$temperature)]
		y = if_else(df$temperature[!is.na(df$temperature)]<=0, 0, log(df$temperature[!is.na(df$temperature)]))
		result = approx(x, y, xout = df$date)
		df$approx = if_else(result$y>0,exp(result$y),0)
		#Clean up dataframe.
		df$measurement = unique(.$measurement); df$geolocid = geolocID; df$month = month(df$date); df$year = year(df$date)
		df
})
#Add the interpolated data to the uninterpolated dataset.
temp.loc = interp %>% filter(is.na(temperature), is.na(approx)==F) %>% bind_rows(temp.loc, .)
#Update the interpolation column with the orginal temperature data when original data is available.
temp.loc[is.na(temp.loc$approx),"approx"] = temp.loc[is.na(temp.loc$approx),"temperature"]
#Add a column to make clear which data have been interpolated and which have not.
temp.loc = temp.loc %>% mutate(orig = if_else(is.na(temperature),"no","yes"))

#Plot the data at one site to check for accuracy.
temp.loc %>% filter(geolocid == 679) %>%
	ggplot(.,aes(date, approx, color = orig)) + geom_point()

#Go through each site and determine if temperature data is consecutive between the first of August and the end of April. Retain data at sites that are continuous during this period.

tempList = plyr::dlply(temp.loc, "geolocid", function(df){
	#Temporary dataframe for each site to be filled with data that meet analysis needs.
	out = data.frame()
	#For each year, determine if there is sufficient data in the fall...
	# and following spring for the analysis. Retain these data.
	for(i in unique(df$year)) {
		#if(any(df$geolocid==32) & i == 2002) browser()
		#Data must fall between 'summer' and 'spring_end'.
		summer = ymd(paste(i,"08-01",sep=""))
		spring_end = ymd(paste(i+1,"04-30",sep=""))
		#The end of fall, (i.e., 'Winter') is either defined by when water temperatures first drop below 2 degrees...
		# or December-15 if water temperatures don't go below 2 in the available data (i.e. No Data in late December).
		winter = df %>% filter(year == i, approx <=  2, month > 8)
		if(nrow(winter)==0) winter = ymd(paste(i,"12-15", sep=""))
		else winter = ymd(max(winter$date))
		#The beginning of 'Spring' is either when temperature data are first collected below or eqaul to 2 degrees C,
		# or February 15th if no data goes above 2 degrees before July 7th (e.g., 0C with no data beyond April 30th).
		# If temperatures after April 30th are below 2 degrees, update 'spring_end' to be the day after 'spring'.
		spring = df %>% filter(year == i+1, approx <=  2, month < 7)
		if(nrow(spring)>0){
			spring = ymd(min(spring$date))
			if(spring > spring_end){
				spring_end = spring + 1
			}	
		} else spring = ymd(paste(i+1,"02-15",sep=""))
		#Create two reference periods (Fall, Spring) that allow for winter preriods to be missing when temperatures...
		# are so low that thermal accumulation is negligable. This will increase the number of sites included in the ...
		# analysis by allowing for the assumption that winter growth is near zero as are temperatures.
		ref = c(seq(summer, winter, by = "day"),
						seq(spring, spring_end, by = "day"))
		if(sum(ref %in% df$date) == length(ref)){
			#If there are missing data over winter but the required fall and spring periods exist...
			# interpolate the missing data.
			#if(any(df$geolocid == 1652)) browser()
			ref = seq(summer,spring_end, by = "day")
			if(sum(ref %in% df$date)!=length(ref)){
				ref = data_frame(geolocid = unique(df$geolocid), date = ymd(ref[ref %in% df$date==F]))
				df.temp = bind_rows(df, ref) %>% filter(date > summer, date < spring_end) %>% tbl_df()
				#Interpolate.
				x = df.temp$date[!is.na(df.temp$approx)]
				y = if_else(df.temp$approx[!is.na(df.temp$approx)]<=0, 0, log(df.temp$approx[!is.na(df.temp$approx)]))
				result = approx(x, y, xout = df.temp$date)
				#Update dataframe.
				df.temp$approx = if_else(result$y>0,exp(result$y),0)
				df.temp$measurement = unique(df$measurement)
				df.temp$month = month(df.temp$date)
				df.temp$year = year(df.temp$date)
				df.temp$orig = if_else(is.na(df.temp$temperature),"no","yes")
				
				#Include dates before and after the core dates that have consecutive temperature data.
				#Arrange dates in order.
				dfCC = df %>% arrange(date)
				#Determine if the dates are consecutive and add a column quantifying the distance in days between observations.
				cc = diff(dfCC$date);	dfCC$cc = c(cc,cc[length(cc)])
				#Determine the start date by assessing days that are consecutive prior to August 1st.
				start = dfCC %>% filter(cc != 1, date<summer) %>%
					mutate(dst = summer-date) %>%
					filter(dst == min(dst)) %>% 
					.$date+1
				#Make sure the reference for the start date does not overlap with the core dates of the previous year.
				if(length(start) == 0) start = summer
				else if(any(i-1 == df$year)) start = summer
				#Determine the end date by assessing days that are consecutive after to April 30th.
				end = dfCC %>% filter(cc != 1, date>spring_end) %>%
					mutate(dst = date - spring_end) %>%
					filter(dst == min(dst)) %>% 
					.$date-1
				#Make sure the reference for the end date does not overlap with the core dates of the subsequent year.
				if(length(end) == 0){
					if(any(i+1 == df$year)){
						end = ymd(paste(year(spring_end),"07-31",sep = "-"))
					}
					else end = max(df$date)
				}
				else if(any(i+1 == df$year)){
					end.ref = ymd(paste(year(spring_end),"07-31",sep = "-"))
					if(end>end.ref) end = end.ref
				}
				
				ref = seq(start, end, by = "day")
				#Save interoplated data.
				test = df %>% filter(!(date %in% df.temp$date), date %in% ref)
				out = df %>% filter(!(date %in% df.temp$date), date %in% ref) %>% 
					bind_rows(., df.temp) %>% arrange(date) %>% bind_rows(., out)
			}
			else {
				#If no data needs interpolation, find the longest consecutive period of data ...
				# ... that includes Aug-01 through Apr-30th and return the data that falls in this time frame.
				#Arrange dates in order.
				dfCC = df %>% arrange(date)
				#Determine if the dates are consecutive and add a column quantifying the distance in days between observations.
				cc = diff(dfCC$date);	dfCC$cc = c(cc,cc[length(cc)])
				#Determine the start date by assessing days that are consecutive prior to August 1st.
				start = dfCC %>% filter(cc != 1, date<summer) %>%
					mutate(dst = summer-date) %>%
					filter(dst == min(dst)) %>% 
					.$date+1
				#Make sure the reference for the start date does not overlap with the core dates of the previous year.
				if(length(start)==0) start = summer
				else if(any(i-1 == df$year))	start = summer
				
				#Determine the end date by assessing days that are consecutive after to April 30th.
				end = dfCC %>% filter(cc != 1, date>spring_end) %>%
					mutate(dst = date - spring_end) %>%
					filter(dst == min(dst)) %>% 
					.$date-1
				#Make sure the reference for the end date does not overlap with the core dates of the subsequent year.
				if(length(end) == 0){
					if(any(i+1 == df$year)){
						end = ymd(paste(year(spring_end),"07-31",sep = "-"))
					}
					else end = max(df$date)
				}
				else if(any(i+1 == df$year)){
					end.ref = ymd(paste(year(spring_end),"07-31",sep = "-"))
					if(end>end.ref) end = end.ref
				}
				
				#Finally select rows to retain.
				out = filter(df, date >= start, date <= end) %>% arrange(date) %>% bind_rows(.,out)
			}
		}
	}
	out
})
#Combine lists into a single dataframe.
temp.loc = do.call("rbind", tempList)
#View final stream temperature dataset.
ggplot(temp.loc, aes(date, approx, color = orig)) + 
	geom_point() + facet_wrap(~geolocid, scales = "free")
#Save final temperature dataset.
temp.loc %>% select(-month, -year, -week_No, -siteWeek, -nDaysWeek) %>% 
	saveRDS(., file = "Data_01_Temperature.rds")
