#Necessary Libraries
library(rstan);library(tidyverse); library(SSN); library(RColorBrewer); library(rgdal) #Activate Libraries

# This table is to standardize by the same values when fitting the model.
#								 mean           sd
# F_tave     10.992839 2.490917e+00
# W_tmin     -4.264661 4.586792e+00
# F_ppt       4.062347   0.7667861
# el        302.938802 2.893437e+02
# upDist     12.583450   0.8860176

# This limit value is to be used to rescale the range estimates.
# limit = 1408253

# Load the fit model and extract the necessary parameters
mod = read_rds("~/sfuvault/Timing-Mismatch_Pink-Salmon/02_SpawnTiming/Model_Results/bayes_spawn_post.rds")
par = rstan::extract(mod,c("beta","sigma","range"))

# PDO Information: Clean up columns and tidy.
pdo = read_table("http://research.jisao.washington.edu/pdo/PDO.latest", skip = 27, n_max = 119)
names(pdo) = tolower(names(pdo))
pdo$year = as.numeric(str_extract(pdo$year, '\\d+'))
pdo = pdo %>% gather(key = "month", value = "index", -year)

# Read in network.
network = importSSN("~/sfuvault/Timing-Mismatch_Pink-Salmon/02_SpawnTiming/lsn/sites_obs.ssn") 
# Choose year
p_year = "BK_2010"
# Load the block krigin prediction data and create the distance matrix
network = importPredpts(target = network, predpts = p_year, obj.type = "ssn")
createDistMat(ssn = network, predpts = p_year, o.write = F, amongpreds = T)

# Extract the prediction data and isolate variables of interest
preds = getSSNdata.frame(network, Name = p_year) %>% 
	rename("year" = "year_") %>% 
  select(pid, rid, F_tave, W_tmin, F_ppt, elevation,
         year, geolocid, locID, upDist, afvArea, h2oAreaKm2)

#Add pdo index to observations
df = pdo %>% group_by(year) %>% summarise(pdo = mean(index)) %>% 
  left_join(preds,.,'year')

#Scale and center predictor and logit transform the reponse.
df = mutate(df, F_tave_cs = (F_tave-10.992839)/2.490917e+00,
            W_tmin_cs = (W_tmin--4.264661)/4.586792e+00,
            F_ppt_cs = (log(F_ppt)-4.062347)/0.7667861,
            el_cs = (elevation-302.938802)/2.893437e+02,
            upDist_lg = (log(upDist)-12.583450)/0.8860176)

#Prediction model matrix
x = model.matrix(~ upDist_lg + pdo + F_ppt_cs*el_cs, data = df) # Make Matrix
#Get stream distance matrix and calculate the full stream distance 
distPreds = getStreamDistMat(network, p_year)$dist.net1
dist.H.p = distPreds + t(distPreds) # Total Distance between points.

# Set up multiple cores.
options(mc.cores = parallel::detectCores(), auto_write = TRUE)
# Compile Model.
compile = stan_model("~/sfuvault/Timing-Mismatch_Pink-Salmon/02_SpawnTiming/spawn_ssn_predict.stan")
#Run model.
est = sampling(compile, data = list(N = nrow(x),
                                    K = ncol(x),
                                    X = x,
                                    dist = dist.H.p,
                                    N_smpl = nrow(par$beta),
																		beta = par$beta,
																		range = par$range*1408253,
																		sigma = par$sigma),
               iter = 1, chains = 1, include = T,
							 pars = c("mu_doy"), algorithm = "Fixed_param")

hist(rstan::extract(est,"mu_doy")$mu_doy)

# Save 
pred_1970 = rstan::extract(est, "mu_doy")$mu_doy+100
write_rds(pred_1970, path = "./02_SpawnTiming/krigin_preds_1970.rds")
#pred_2010 = rstan::extract(est, "mu_doy")$mu_doy+100
pred_2010 = read_rds("./02_SpawnTiming/krigin_preds_2010.rds")

#Write a shapefile of prediction points.

#Find prediction data.
pt_df = getSSNdata.frame(x = network, Name = "BK_2010")
pt_df$preds = pred_2010[1,]
#Isolate stream network polyline data.
net = network@data
net = pt_df %>% select(rid, preds) %>% group_by(rid) %>% 
	summarise(peak = mean(preds)) %>% left_join(net, ., by = "rid")


#Reference for rid and binaryID.
ref = read.delim("./02_SpawnTiming/lsn/sites_obs.ssn/netID1.dat",
					 header = T, sep = ",", col.names = c("rid","binaryID"),
					 numerals = "no.loss", as.is = T)
ref = ref %>% mutate(n = nchar(binaryID))
#Fill in unknown data.
fill = apply(net, 1, function(x){
	if(is.na(x[["peak"]])) {
		xrid = as.numeric(x[["rid"]]) #rid with missing value.
		xBI = ref %>% filter(rid == xrid) %>% .$binaryID #binary of missing value.
		
		xBI_a = xBI; xBI_hold = xBI; above = NULL
		while(is.null(above)){
			#Look for peak spawn dates above the stream segment with missing data.
			xBI_left = paste(xBI_a,"1",sep = "")
			xBI_right = paste(xBI_a,"0",sep = "")
			left = ref %>% filter(binaryID == xBI_left)
			right = ref %>% filter(binaryID == xBI_right)
			#If there is a stream branching to the left, check for peak spawn values...
			#... and return either a new binary or the current binary with peak spawn esimate data.
			if(nrow(left) > 0) {
				leftPeak = net %>% filter(rid == left$rid) %>% select(peak)
				if(is.na(leftPeak$peak)){
					xBI_a = xBI_left
				} else above = c(above, left$rid)
			}
			#If there is a stream branching to the right, check for peak spawn values...
			#... and return either a new binary or the current binary with peak spawn esimate data.
			if(nrow(right) > 0) {
				rightPeak = net %>% filter(rid == right$rid) %>% select(peak)
				if(is.na(rightPeak$peak)){
					xBI_a = xBI_right
				} else above = c(above, right$rid)
			}
			#If both branches are empty then look for a new branch near the begining...
			#... or return an empty dataframe if new branches from the origin don't exist.
			if(nrow(left)==0 & nrow(right)==0){
				xBI_hold = paste(xBI_hold,"1",sep = "")
				if(any(xBI_hold==ref$binaryID))	xBI_a = xBI_hold
				else above = c(above, left$rid)
			}
		}
		#Look for peak spawn dates below the stream segment with missing data.
		below = NULL
		while(is.null(below)){
			xBI_down = substr(xBI, 1, (nchar(xBI)-1))
			down = ref %>% filter(binaryID == xBI_down)
			downPeak = net %>% filter(rid == down$rid) %>% select(peak)
			if(is.na(downPeak$peak)) xBI = xBI_down
			else below = down$rid
		}
		#Average predicted peak spawn values above and below unknown junction.
		peak_se = net %>% filter(rid %in% c(above, below))
		data.frame(peak = mean(peak_se$peak))
	}
	else data.frame(peak = as.numeric(x[["peak"]]))
}) %>% do.call('rbind',.)
#Add filled data to the dataframe
net = net %>% select(-peak) %>% bind_cols(., fill)
row.names(net) = as.character(c(0:(nrow(net)-1)))
#Create spatial lines object and save as shapefile
sp = SpatialLines(LinesList = network@lines, CRS("+init=epsg:3005"))
sp = SpatialLinesDataFrame(sl = sp, data = net)
writeOGR(obj = sp, dsn = "./maps/", layer = "BK_2010_bayes", driver = "ESRI Shapefile", overwrite_layer = T)
