library(tidyverse)
test = data.frame(day = c(1:300), five = cumsum(rep(5, 300)), ten = cumsum(rep(10, 300)))

#Calculate mean temperature of 7C.
mn = apply(test, 1, FUN = function(x){
	mean(pstr$b0+pstr$b1*(x[2]-917.4991))
})

perc = lapply(pstr$sigma, function(x){
	pnorm(q = boot::logit(test$day/365), mean = mn, sd = x)
})

test = test %>% mutate(fiveP = round(Reduce("+", perc)/length(perc)*100,0))

#Calculate mean temperature of 10C.
mn = apply(test, 1, FUN = function(x){
	mean(pstr$b0+pstr$b1*(x[3]-917.4991))
})

perc = lapply(pstr$sigma, function(x){
	pnorm(q = boot::logit(test$day/365), mean = mn, sd = x)
})

test = test %>% mutate(tenP = round(Reduce("+", perc)/length(perc)*100,0))