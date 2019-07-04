#Activate Libraries
library(tidyverse); library(SSN);library(rstan) 

#Read in the .ssn network data.
network = importSSN("~/sfuvault/Timing-Mismatch_Pink-Salmon/02_SpawnTiming/lsn/sites_obs.ssn",
                    predpts = "preds", o.write = F) 

#Gather observed spawn sites and add identifying column
df_obs = getSSNdata.frame(network) %>% rename("year" = "year_", "end"="end_") %>% 
  select(pid, rid, peak, F_tave, W_tmin, F_ppt, elevation,
         year, geolocid, locID, upDist, afvArea, h2oAreaKm2) %>% 
  mutate(Obs_Preds = "obs")

#Read in the SD estimates around the observed peak value.
df_obs = read_csv("~/sfuvault/Timing-Mismatch_Pink-Salmon/02_SpawnTiming/Obs_SD.csv") %>% 
  select(id,year,sd) %>% 
  left_join(df_obs, ., by=c("geolocid"="id", "year"="year"))

# PDO Information: Clean up columns and tidy.
pdo = read_table("http://research.jisao.washington.edu/pdo/PDO.latest", skip = 27, n_max = 119)
names(pdo) = tolower(names(pdo))
pdo$year = as.numeric(str_extract(pdo$year, '\\d+'))
pdo = pdo %>% gather(key = "month", value = "index", -year)

# ENSO: Not worth including.
enso = read_csv("https://www.ncdc.noaa.gov/teleconnections/enso/indicators/soi/data.csv", skip = 1)
enso$year = as.numeric(substr(as.character(enso$Date),start = 1,stop = 4))
enso = enso %>% group_by(year) %>% summarise(enso = mean(Value))

#Gather prediction spawning locations and add identifying column
df_preds = getSSNdata.frame(network, Name = "preds") %>% rename("year"="year_") %>% 
  select(pid, rid, F_tave, W_tmin, F_ppt, elevation,
         year, geolocid, locID, upDist, afvArea, h2oAreaKm2) %>% 
  mutate(Obs_Preds = "preds")

#Bind observed and predicted together
df = bind_rows(df_obs, df_preds)

#Add pdo index to observations
df = pdo %>% group_by(year) %>% summarise(pdo = mean(index)) %>% 
  left_join(df,.,'year')

#Order group level effects so observed factor levels are first and ...
# ... prediction levels not found in the observed are second.
df = df %>% arrange(Obs_Preds, year) %>% 
  mutate(year = factor(as.character(year), levels = as.character(unique(year))),
         year_no = as.numeric(year)) %>% 
  arrange(Obs_Preds, geolocid) %>% 
  mutate(geolocid = factor(as.character(geolocid), levels = as.character(unique(geolocid))),
         geolocid_no = as.numeric(geolocid))

#Function to center and scale data.
sc_func = function(x){
  (x-mean(x))/sd(x)
}
#Scale and center predictor and logit transform the reponse.
df = mutate(df, peak_lgt = psych::logit(peak/366),
            peak_sd = boot::logit((peak+sd)/366)-boot::logit(peak/366),
            F_tave_cs = sc_func(F_tave),
            W_tmin_cs = sc_func(W_tmin),
            F_ppt_cs = sc_func(log(F_ppt)),
            el_cs = sc_func(elevation),
            upDist_lg = sc_func(log(upDist)))

#Split the observed and prediction datasets
df_obs = filter(df, Obs_Preds == "obs") %>% arrange(pid)
df_preds = filter(df, Obs_Preds == "preds") %>% arrange(pid)
row.names(df_preds) = df_preds$pid

#Observed and random effects design matrices.
x = model.matrix(peak_lgt ~ upDist_lg + pdo + F_ppt_cs*el_cs, data = df_obs) # Make Matrix
#Get stream distance matrix and calculate the full stream distance 
distObs = getStreamDistMat(network)$dist.net1
dist.H.o = distObs + t(distObs)

#Prediction model matrix
xp = model.matrix(~ upDist_lg + pdo + F_ppt_cs*el_cs, data = df_preds) # Make Matrix
#Get stream distance matrix and calculate the full stream distance 
distPreds = getStreamDistMat(network, "preds")$dist.net1
dist.H.p = distPreds + t(distPreds) # Total Distance between points.

# Determine the maximium distance between locations on the network
if(max(dist.H.o) > max(dist.H.p)) limit = max(dist.H.o)
if(max(dist.H.o) < max(dist.H.p)) limit = max(dist.H.p)

# Set up multiple cores.
options(mc.cores = parallel::detectCores(), auto_write = TRUE)
# Compile Model.
compile = stan_model("~/sfuvault/Timing-Mismatch_Pink-Salmon/02_SpawnTiming/spawn_ssn.stan")
#Run model.
mod = sampling(compile, data = list(N = nrow(x),
                                    K = ncol(x),
                                    X = x,
                                    y = df_obs$peak_lgt,
                                    y_sd = df_obs$peak_sd,
                                    n_r1 = max(df_obs$year_no),
                                    x_r1 = df_obs$year_no,
                                    n_r2 = max(df_obs$geolocid_no),
                                    x_r2 = df_obs$geolocid_no,
                                    dist = dist.H.o/limit,
                                    Np = nrow(xp),
                                    X_p = xp,
                                    dist_p = dist.H.p/limit,
                                    x_r1_p = df_preds$year_no,
                                    x_r2_p = df_preds$geolocid_no),
               iter = 200, chains = 4, thin = 1, include = T,
               pars = c("mu_doy","mu_new_doy","beta","range","sigma","w_r1","w_r2"),
               control = list(adapt_delta = .8, max_treedepth = 10), save_warmup = T)


write_rds(mod, "~/sfuvault/Timing-Mismatch_Pink-Salmon/02_SpawnTiming/Model_Results/bayes_spawn_post.rds")

mod = read_rds("~/sfuvault/Timing-Mismatch_Pink-Salmon/02_SpawnTiming/Model_Results/bayes_spawn_post.rds")
shinystan::launch_shinystan(mod)


# When adding the up river distance and PDO index to the model, the minimum winter temperature effect disappears. The only direct weather effect is precipitation while temperature seems subsummed by the regional climate state (PDO) and upstream distance which is colinear with elevation and temperature and probably a better proxy of contibuting temperature from across the watershed rather than sampling only at the site.

# Get posterior estimates of observations
posterior = data.frame(rstan::extract(mod, pars = "mu_doy")$mu_doy)
tdy_post = gather(posterior, "pred","est")
tdy_post$pred = as.numeric(str_extract(tdy_post$pred, '\\d+'))

# Get median estimates by site/year and the standardized residuals from the observations
med = tdy_post %>% group_by(pred) %>% summarise(med = median(est))
med$obs = df_obs$peak
med$resid = sc_func(med$obs-med$med)

# Look at the distributions
library(ggridges)
low = 360; up = 397
tdy_post %>% filter(pred>=low, pred<=up) %>% left_join(.,med) %>% 
ggplot() + 
  stat_density_ridges(aes(x=est, y=as.factor(pred), fill=factor(..quantile..)),
                      geom = "density_ridges_gradient", 
                      calc_ecdf = TRUE, quantiles = c(0.1, 0.9)) + 
  scale_fill_manual(name = "Probability", values = c("#FF0000A0", "#A0A0A0A0", "#0000FFA0"),
                    labels = c("0 - 0.1", "0.1 - 0.9", "0.9 - 1")) +
  geom_segment(aes(x = obs, xend = obs, y = pred-low+1, yend = (pred-low)+2), color = "red") +
  labs(x = "Observed Peak Spawn DOY", y = "Spawn DOY Probability by Site") + 
  ggthemes::theme_tufte()
# Look at the observed vs. predicted: There appears to be a bias indicating some missing variable.
ggplot(med, aes(obs, med)) + geom_point() + 
  geom_abline(intercept = 0, slope = 1)
# Look at the observed vs. residuals: 
ggplot(med, aes(med,resid, ))+geom_point() + geom_abline(slope = 0,intercept = 0)


#### Prepare prediction data for subsequent analysis ####

# Extract predictions, transpose, and add 100 days
posterior_preds = floor(t(data.frame(rstan::extract(mod, pars = "mu_new_doy"))))+100
# Correct row names
rownames(posterior_preds) = as.numeric(str_extract(rownames(posterior_preds),"\\d+"))
# Join with geolocid and year of the predictions dataset for reference
posterior_preds = df_preds %>% select(geolocid,year) %>% bind_cols(.,data.frame(posterior_preds))
# Tidy the dataframe into long format
posterior_preds = posterior_preds %>% gather(key = "sample", value = "doy", contains("X"))
# Add a date
posterior_preds = posterior_preds %>% mutate(date = lubridate::ymd(paste(as.character(year),"01-01"))+doy)
# Make sample number, geolocid and year numeric
posterior_preds$sample = as.numeric(str_extract(posterior_preds$sample, "\\d+"))
posterior_preds$geolocid = as.numeric(as.character(posterior_preds$geolocid))
posterior_preds$year = as.numeric(as.character(posterior_preds$year))

# Plot distributions
ggplot(posterior_preds, aes(doy, color = factor(year))) + 
  geom_density() + 
  facet_wrap(~geolocid) + 
  ggthemes::theme_tufte() +
  theme(legend.position = "none")

# Write out the data
write_rds(posterior_preds, "~/sfuvault/Timing-Mismatch_Pink-Salmon/Data_02_EstSpawnDate_Bayes.rds")
