library(tidyverse); library(SSN) #Activate Libraries
#Get model predictions and select columns of interest.
mod.preds = readRDS(file = "./02_SpawnTiming/Model_Results/mod_pred.rds")
preds = getSSNdata.frame(mod.preds$ssn.object, Name = "preds")
preds = preds %>% select(geolocid, year, peak, peak.predSE)

#Using a t-distribution, draw 1000 estimates given the estimated peak spawn date and SE for each site and year.
set.seed(532)
estSpawn = apply(preds,1,function(x){
	spawn = round(rt(1000, 16)*as.numeric(x["peak.predSE"][[1]]) + as.numeric(x["peak"][[1]]),0)
	data.frame(geolocid = as.numeric(x["geolocid"][[1]]), year = as.numeric(x["year"][[1]]), spawn)
}) %>% do.call("rbind",.)
row.names(estSpawn) = c(1:nrow(estSpawn))

#View Distributions.
ggplot(estSpawn, aes((spawn+100)/30.5, color = as.factor(year), fill = as.factor(year))) + 
	geom_density(alpha = 0.1) +
	theme(legend.position = 'none') +
	facet_wrap(~geolocid, scales = "free")

#Save prediction distributions.
saveRDS(estSpawn, file = "Data_02_EstSpawnDate.rds")
