library(tidyverse); library(lubridate)

# Read in data and standardize to a spawn in fall of 1999 and emergence in 2000.

#Spawn Data
spawn = read_rds("~/sfuvault/Timing-Mismatch_Pink-Salmon/Data_02_EstSpawnDate_Bayes.rds") %>%
	group_by(geolocid, year) %>% 
	mutate(n = n(), date_std = ymd(date)+years(1999-min(year(date))))
#Emergence Data
emerg = read_rds("~/sfuvault/Timing-Mismatch_Pink-Salmon/Data_04_EmergProbs_Bayes.rds") %>%
	group_by(geolocid, spawn_year) %>% 
	mutate(date_std = ymd(date) + years(1999-min(year(date))),
				 prob = density/sum(density,na.rm = T)) %>% 
	filter(prob>0.0001) %>% rename(year = spawn_year) %>% 
	select(geolocid,year,date,date_std,density,prob)

#Eliminate emergence years where not enough temperature data were available to create a full ...
# ... probability distribution and spawn years where there is no subsequent emergence data.
emerg = emerg %>% group_by(geolocid, year) %>% filter(date==max(date), prob > 0.005) %>% select(geolocid, year) %>% mutate(elim = "yes") %>% left_join(emerg,.) %>% filter(is.na(elim))

spawn = emerg %>% select(geolocid, year) %>% distinct() %>%
	mutate(retain = "yes") %>% left_join(spawn,.) %>% filter(retain == "yes")

#Plot
sites = unique(emerg$geolocid)
ggplot() + 
	geom_line(data = spawn %>% filter(geolocid %in% sites[29:56]),
							 aes(date_std, color = year, group = year), stat = "density") +
	geom_line(data = emerg %>% filter(geolocid %in% sites[29:56]), 
						aes(date_std, prob, color = year, group = year)) +
	#geom_hline(yintercept=0, colour="white", size=1) +
  annotate("segment", x=min(spawn$date_std), xend = max(emerg$date_std),
  				 y=-Inf, yend=-Inf, size = .2) +
	viridis::scale_color_viridis() +
	scale_x_date(date_labels = "%b", date_breaks = "2 month", 
							 limits = c(min(spawn$date_std), max(emerg$date_std))) +
	labs(x = "Spawning & Emergence Month", y = "Probability Density") +
	facet_wrap(~geolocid, nrow = 7, ncol = 4) +
	ggthemes::theme_tufte() +
	theme(legend.position = "none",
				axis.ticks.y = element_blank(),
				axis.line.x=element_line(),
				axis.text.y = element_blank())

ggsave("Bayes_Distributions2.png", device = "png", width = 11, height = 8.5, units = "in", dpi = 300)
