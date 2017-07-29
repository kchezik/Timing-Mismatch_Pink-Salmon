library(tidyverse); library(attenPlot)
dat = readRDS("Data_03_Emergence.rds")
dat = dat %>% mutate(ConstVar = if_else(nchar(as.character(Treatment))>2,"var","const"))

load("stanMod.RData")

simple = dat %>% group_by(Treatment,Location,Source) %>% 
	summarize(Degree.Days = mean(Degree.Days), Days.to.Emergence = mean(Days.to.Emergence)) %>% 
	ungroup()
simple = simple %>% mutate(DD_center = Degree.Days-mean(Degree.Days))

simple = dat %>% select(Location, Treatment, Source, Northing, Easting, ConstVar) %>% distinct() %>% left_join(simple, ., by = c("Location","Treatment","Source"))

param = rstan::extract(fit) %>% do.call("cbind",.) %>% tbl_df(.)

lim = apply(param, 1, function(x){
	#Upper Bound
	est = x[[1]] + x[[2]]*simple$DD_center + 1.96*sqrt(x[[3]]^2*exp(2*simple$DD_center*x[[4]]))
	up = max(est); meanUp = mean(est)
	#Lower Bound
	est = x[[1]] + x[[2]]*simple$DD_center - 1.96*sqrt(x[[3]]^2*exp(2*simple$DD_center*x[[4]]))
	low = min(est); meanLow = mean(est)
	data.frame(up, low, meanUp, meanLow)
}) %>% do.call("rbind",.)

param = param %>% mutate(col.up = color.gradient(vec = lim$meanUp*-1, pal = "Greys", shade = 10, monthly = F),
												 col.low = color.gradient(vec = lim$meanLow, pal = "Greys", shade = 10, monthly = F))

wdth = 8.7/2.54; hght = wdth
pdf("./drafts/Fig2_EmergMod.pdf", width = 4.875, height = 5)

LW = 1; ALS = 0.9; LL = 2.5; line.w = 0.5
par(oma = c(3.2,0,0,0), mar = c(0.1,2.5,0.2,0), family = "serif", mgp = c(2,0.2,0))
plot(Days.to.Emergence~Degree.Days, data = simple, type = "n", axes = F, ann = F,
		 xlim = c(min(simple$Degree.Days), max(simple$Degree.Days)), ylim = c(min(lim[,"low"]), max(lim[,"up"])))
axis(1, lwd = LW, cex.axis = ALS-0.2, outer = T)
mtext(expression("Cumulative Degree-Days"~sum("("*bar(degree*C)*" > 0)",i="S","Day"[n])), side = 1, line = LL, cex = ALS)
par(mgp = c(2,0.6,0))
axis(2, lwd = LW, cex.axis = ALS-0.2, las = 1)
mtext("Days to Emergence", side = 2, line = LL-0.8, cex = ALS, las = 0)
#Plot Variance
for(i in 1:nrow(param)){
	x = param[i,]
	#Upper Bound
	est = x[[1]] + x[[2]]*simple$DD_center + 1.96*sqrt(x[[3]]^2*exp(2*simple$DD_center*x[[4]]))
	lines(x = sort(simple$Degree.Days), y = sort(est, decreasing = T), col = x[[6]], lwd = line.w)
	#Lower Bound
	est = x[[1]] + x[[2]]*simple$DD_center - 1.96*sqrt(x[[3]]^2*exp(2*simple$DD_center*x[[4]]))
	lines(x = sort(simple$Degree.Days), y = sort(est, decreasing = T), col = x[[7]], lwd = line.w)
}
#Mean Trend
lines(x = sort(simple$Degree.Days), y = sort(mean(param$b0) + mean(param$b1)*simple$DD_center, decreasing = T),
			col = "black", lty = "dashed")
#Add points
points(x = simple$Degree.Days, y = simple$Days.to.Emergence, pch = 16, cex = 0.9, col = "#25252599")
points(x = simple$Degree.Days, y = simple$Days.to.Emergence, pch = 16, cex = 0.9, col = "#25252599")
dev.off()