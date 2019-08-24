library(tidyverse); library(lubridate)

#### Data ####

#Temperature Data
therm_dat = read_rds("~/sfuvault/Timing-Mismatch_Pink-Salmon/Data_01_Temperature.rds")
#Spawn Data
spawn_dat = read_rds("~/sfuvault/Timing-Mismatch_Pink-Salmon/Data_02_EstSpawnDate_Bayes.rds")
# Add the probability of spawn on each date then only retain unique geolocid's and years
spawn_dat = spawn_dat %>% group_by(geolocid, year) %>% mutate(n = n()) %>% 
	group_by(geolocid, year, doy) %>% mutate(prob = n()/n) %>% ungroup() %>% 
	select(-sample) %>% distinct()
#Read in emergence model and extract parameters
emerg_mod = read_rds("~/sfuvault/Timing-Mismatch_Pink-Salmon/Data_03_Emergence_Mod_Bayes.rds")
emerg_mod = data.frame(rstan::extract(emerg_mod))

# Function to calculate the probability density of each CDD and day number.
emerg_pdf = function(mod,CDD,C_Days){
	CDD_std = (CDD-917)/184
	mn = mod$b0 + mod$b1*CDD_std
	sd = mod$sigma*exp(mod$tau*CDD_std)
	lgt_days = boot::logit(C_Days/366)
	return(round(dnorm(lgt_days, mn, sd),2))
}

# Iterate over geolocid and spawn date returning the weighted emergence day pdf
full = list() # List to hold sites and emergence density by day

pb = txtProgressBar(min = 0, max = nrow(spawn_dat), style = 3)
counter = 0
for(i in unique(spawn_dat$geolocid)){
	spawn_geo = spawn_dat %>% filter(geolocid==i) # Subset by site
	hold = list() # List of emergence day density by spawn day
	ctr = 1 # Spawn date counter
	# Calculate the emergence probability density for each day after spawn
	for(j in spawn_geo$date){
		# Calculate the CDD and cummulative days after spawn
		therm_tmp = therm_dat %>% filter(geolocid==i, date>=j) %>%
			arrange(date) %>% mutate(CDD = cumsum(approx),
															 C_Days = as.numeric(date-j),
															 consec = c(NA,diff(C_Days))) %>% 
			filter(C_Days<366) %>%  #Only consider days within the coming year.
			mutate(spawn_year = lubridate::year(.$date[1]))

		if(nrow(therm_tmp)==0) next 				# Skip if no temperature data available
		if(sum(therm_tmp$date==j)==0) next  # Skip if the spawn date is not found in the temperature data
		#if(any(therm_tmp$consec>1, na.rm = T)) browser() #Break if the temperature data are non-consecutive
		if(any(therm_tmp$consec>1,na.rm = T)) therm_tmp = therm_tmp[1:(which(therm_tmp$consec>1)[1]-1),]
		if(nrow(therm_tmp)==0) next 				# Skip if no temperature data available
		
		# Weight the emergence probabilities by the spawn date probabilties
		prob = spawn_geo[spawn_geo$date==j,"prob"][[1]]
		#yr = spawn_geo[spawn_geo$date==j,"year"][[1]]
		# Save the summed densities by day.
		hold[[as.character(i)]][[ctr]] = therm_tmp %>% group_by(date) %>%
			summarise(density = sum(prob*emerg_pdf(emerg_mod,CDD,C_Days)),
								spawn_year = lubridate::year(.$date[1]))
		ctr=ctr+1 # Increase spawn date counter
		
		# Progress bar counter update
		counter = counter + 1
		setTxtProgressBar(pb, counter)
	}
	# Collapse the list into a single dataframe for the site and save.
	full[[as.character(i)]] = hold[[as.character(i)]] %>% 
		reduce(bind_rows) %>% 
		group_by(spawn_year, date) %>% 
		summarise(density = sum(density,na.rm = T)) %>% 
		mutate(geolocid = i)
}
close(pb)

#Save
fin = full %>% reduce(bind_rows) 
write_rds(fin, path = "~/sfuvault/Timing-Mismatch_Pink-Salmon/Data_04_EmergProbs_Bayes.rds")