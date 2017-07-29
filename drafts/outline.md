% Pink Salmon: Match-Mismatch Outline
% K. A. Chezik; S. M. Wilson; J. W. Moore
% July 12, 2017

\linenumbers

Abstract
========

Introduction
============
- Climate change is increasingly disturbing the cyclical seasonal patterns that organize and drive the phenology of living systems. Rippling through ecological food webs, changes in climate and increased climatic variability are changing the game for many species. Some individuals, populations and indeed entire species are benefiting under a changing climate but many are struggling to adjust and adapt.
	- For instance ... (benefit)
	- Alternatively ... (struggle)
	- Predominately, climate change is (expected to) negatively affect(ing) most ecological systems.? 
		- (How bad it could be...)
	- Understanding the impact of a rapidly changing climate on species and their sub-populations will help maximize the returns of conservation and reduce the ecological fallout of the anthropocene on future generations.

- As climate change progresses species and populations (hereafter simply populations) that are positioned to adapt dynamically are likely to do better than those that are not.
	- Populations rely on thousands of years of evolution to hone the timing of life events in order to maximize the likelihood of survival and reproduction.
	- Populations that exhibit a wide variety of responses within life history traits may be better suited to inter-annual variation, ensuring the success of some individuals during unfavorable years.
		- For instance ... 
	- Populations who's life history stages strongly share climatic information over space may be able to reduce response diversity and maximize survival to reproduction for a greater proportion of individuals.
		- For instance ...
	- Under climate change, growing inter-annual variability will likely increase the chance of timing mismatch between populations and their food sources.
		- For instance, juvenile salmon outmigrating to the ocean, reside periodically in the estuary eating zooplankton before transitioning to piscivory. Optimally, these juveniles will arrive at the estuary at the same time zooplankton populations are in full bloom. Indeed, salmon do exhibit this evolved synchrony with estuarine zooplankton, thereby increasing the liklihood of survival to adulthood (citation).
- We hypothesize that salmon populations who's climate is more closely linked to that of the estuary are less likely to miss the period of peak zooplankton bloom when emigrating from their natal streams to the ocean.

- Here we use pink salmon spawn and emergence data in British Columbia Canada (Figure \ref{fig:map}) to test whether populations that share similar and correlated climate with the estuary are less likely to miss the peak zooplankton bloom than populations that are more climatically dissimilar.
- The Fraser River basin is a large, topographically complex and climatically diverse watershed (Figure\ref{fig:map}).
	- Pink salmon in the Fraser River basin travel upwards of three hundred miles to and from their natal streams but predominately most populations reside in the lower Fraser River. The predominance of populations living in the lower Fraser is in part the result of the 1913 rock slide at Hells Gate. This blockage prevented millions of pink salmon from reaching their spawning grounds, essentially extirpating populations above Hells Gate until a fish ladder was installed in 1945. Since passage was renewed pink salmon have steadily reinhabited the upper Fraser River, though returns above Hells Gate have remained extremely low relative to pre-rock slide estimates.  
	- Unlike other Pacific salmon, pink salmon exhibit a strict 2 year life span. Spawning in the fall, pink fry emerge and emigrate to the estuary in the spring. Juveniles live and grow in the ocean for two years before returning to their natal stream to parent the next generation.
	- Pink salmon exhibit such strong two year life history cycles that even and odd year populations are largely distinct.
	- Importantly to this study, pinks have the strong proclivity to move swiftly to the estuary upon emergence in the spring, making prediction of estuary arrival time possible unlike other Pacific salmon who may rear in their natal streams or lakes for variables periods of time before leaving for the ocean.
- Leveraging historic spawn timing and emergence data to inform a spawn timing stream network model and a bayesian degree-day emergence model, we estimate estuary arrival timing between 1970 and 2010 determine the degree of match-mismatch with the timing of zooplankton bloom in the Fraser River estuary estimated by Allen and Wolfe (2013).

\begin{figure}[H]
\centering
\includegraphics[width=6.5in]{BK2010.png}
\caption{Mean annual temperature in 1970 (left) and 2010 (center) contrasted with spawn timing (right) in the Fraser River basin. Points indicate observed spawning locations and their color indicates the observed median spawn date. Streams are colored by the estimated change in spawn date given the difference between 1970 and 2010 model estimates. Over this 30 year period spawn timing of adult pink salmon has shifted later as the climate has warmed in the Fraser River basin.}
\label{fig:map}
\end{figure}

Methods
=======
##### Spawn Timing Estimation
- To estimate emergence timing using a degree-day model, it is important to know when spawning occurred in order to define when thermal time should begin accumulating. Furthermore, because historical stream temperature data was collected at sites where spawning is not known to occur, we needed to be able to predict when spawning were to happen if a population were to spawn in those locations. Using known spawn timing data, we developed a stream network model (Peterson et al. 2013) that predicted spawn timing throughout the Fraser River basin.

##### Spawn Timing Data
- We extracted spawn timing data within the Fraser River basin from the nuSEDS V2.0 database, owned and maintined by the Department of Fisheries and Oceans Canada. 
- Because spawing occurs over a period of time, we used spawn start, peak and end date estimates to approximate a distibution of spawning dates at each site and year. Sampling within this distribution allowed us to include our uncertainty of spawn date into the stream network model and propogate that uncertainty into the subsequent degree-day emergence model. Due to computational limitations inherent in fitting a large stream network model (Ver Hoef et al. 2014), we limited our distibution sampling to 22 samples for 371 unique site-year combinations resulting in 8,162 spawning dates.

##### Climate and Landscape Data
- The links between the environment and spawn timing for pink salmon is relatively unclear (Hard et al. 1997, Neave 1966). Stream temperature and flow contribute but strong correlations across populations have not been established.
	- To leverage potential climatic drivers of spawn timing we used the British Columbia Climate tool (ClimateBC) (Wang et al. 2016) to extract monthly mean temperature and precipitation data at our observed spawn sites and in locations where we would like to predict spawn timing. To capture any direct impacts of climate we calculated the mean fall (September - October) temperature and precipitation each year, and to capture long-term drivers of climate we calculated the mean winter (November - January) temperature. 
	- Geomorphic features have also been shown to modify spawn timing in some Pacific salmon species such as Sockeye (e.g., Lisi et al. 2013). We included elevation in our models as a proxy for distance upstream, a modifier of precipiation and temperature and a relative measure of stream size and catchment area. 

##### Stream Network Spawn Timing Model
- Salmon returning to their natal spawning grounds are constrained by the river such that stream distance rather than linear distance defines the correlation between populations. For instance, most often individuals arrive in their natal stream but occasionally they stray. When they stray they overwhelmingly end up in a nearby stream. As a result of the networks constraints and salmon behaviour we expect poplations that are closer on the network to act more similarly than those further apart. To capture network constrained inter-population correlation, we used a spatial statistical stream-network model (SSNM) that shares information between populations over the network rather than in linear space.
- This SSNM is an extension of a generlized linear model where the errors are directionally correlated either in a flow-connected path (e.g., downstream) or flow-disconnected path (e.g. upstream). We fit this model by regressing spawn date onto each site's climate and landscape data :
- (model)
- where ... (model specifics)
- Using our stream network model, we predicted spawn dates at sites and in years where water temperature had been collected. Given the standard errors around our mean spawn date estimates, we sampled a t-distribution 1000 times to approximate the range of spawning dates that may occurr. These spawn dates represent when thermal aggregation begins and act as inputs to the forthcoming degree-day emergence model.

##### Degree-Day Emergence Model
- Distributions of spawn timing provide a start date upon which to apply our degree-day emergence model. Our emergence model was built under a bayesian framework, where we estimate the probability of emergence given the accumulation of temperature since fertilization.
	- To fit this model we extracted data from the literature where pink salmon eggs were fertilized and allowed to develop under controlled thermal regimes (Table 1). 
	- For instance, Beacham and Murray (1986) incubated five stocks of fertilized pink salmon eggs at 4, 8 and 12$\text{\textdegree}$C and recorded the number of days to 50% emergence. By simply multiplying the days to emergence by the incubation temperature we get an estimate for the mean number of degree-days to emergence for each population under different thermal regimes.
		- Other studies took different approaches to incubation using varied thermal regimes to mimick natural systems. Temperature accumulation under these variable thermal regimes were accounted for provided the details of each studies methods. 
		- Not all studies provided error estimates in their methodology and results, therefore our model captures only inter-study variation of mean values.
	- Using these study derived data we estimated days to emergence given cumulative degree-days using a linear model.
		- Describe model parameters, etc.
		- Describe variance structure.
	- Leveraging posterior distributions of slope and intercept estimates, we can estimate a distribution of days to emergence given any observed number of degree-days. By simply asking what proportion of predicted days to emergence are less than or equal to the observed number of days in which temperature has been accumulated, we can determine the probability of emergence on any day since fertilization at a given site.

##### Emergence and Arrival Timing
- Pink salmon emergence varies greatly within and among populations. To estimate emergence we accumulated temperature for each day after each estimated spawn date and for each day caclulated the probability of emergence, retaining only days that had a probability greater than 0 and less than 1.
	- This process propogates the variance in spawn timing into the emergence model which includes it's own variance estimates. As a result we get distributions of emergence that reflect much of the life history variation and measurement error inherent in the data.
	- Because pink salmon leave for the estuary immediately upon emergence (citation), arrival timing is largely a function of emergence date and river distance. Assuming a maximum travel time of two days, we added time to the emergence date depending on the stream distance to the estuary relative to other sites. In this way we included more swim time to those populations living further from the estuary than those living nearby. 
		- In feeding data from our spawn timing model to our degree-day model, built on observed spawning, emergence, temperature and precipitation data, we result in a distribution of estuary arrival dates, for each year and population.

##### Zooplankton Bloom, Match Mismatch and Climate
- The ultimate food source of juvenile salmon in the estuary are zooplankton thus we need to know when the zooplankton bloom occurs in order to observe match-mismatch dynamics. Allen and Wolfe (2013) developed a model for estimating phytoplankton bloom which are consumed by zooplankton and whose bloom determines that of zooplankton. To estimate the timing of zooplankton bloom from observed phytoplankton bloom estimates we simply applied a constant lag period in which zooplankton was presumed to peak two weeks after phytoplankton bloom.
- To quantify match mismatch, we asked what proportion of estuary arrival date estimates coincided with the eight day window of zooplankton bloom for each population in each year. Those populations and years with greater overlap suggest better opportunites for growth and survival, while those populations with smaller overlap suggest the opposite.
- Ultimately, we wish to test whether correlative climates between the estuary and a populations natal spawn site impacts the liklihood of match mismatch dynamics. To do this we calculated a relative measure of climatic similarity in each year between each site and the estuary.
	- Our index of climate similarity consists of calculating the absolute difference in temperature (mean, min and max) and precipitation (mean) between the estuary and each site, in each month of each year. We then standardize these four climatic measures of similarity between zero and one for each spawn year and sum those standardized differences within each site and year. A spawn year spans between July-01 and June-30 of the subsequent year thereby capturing direct impacts of climate on developing pink salmon embryos. The smaller the index value the greater the similarity between the estuary and the spawn site.
	- Using these index values, we can evaluate the relationship between climate match-mismatch and estuary arrival timing match-mismatch.

Results
=======

##### Spawn Timing

##### Emergence

\begin{figure}[H]
\centering
\includegraphics{Fig2_EmergMod.pdf}
\caption{Days to emergence of pink salmon given the accumulation of degree-days. Cumulative degree-days (CDD) are calculated as the sum of mean daily (Day[n]) temperatures above 0$\text{\textdegree}$C, since spawn (S). Points represent observed values extracted from the literature where each point represents a unique study, population and thermal treatment combination. The dotted line describes the modeled mean relationship between CDD and days to emergence and the solid lines above and below the mean describe the variance around the mean with increasing CDD. The grey color gradient represents the probability tails of the log-normal distribution describing the probability of emergence estimated by the model whereas the white space between represents the 95\% credibility intervals.}
\label{fig:emerg}
\end{figure}

##### Match-Mismatch

Discussion
==========

\begin{figure}[H]
\centering
\includegraphics[width=6.5in]{ChangeOverlap.png}
\caption{Predicted overlap in estuary arrival timing and zooplankton bloom (**left**) and estimated change in overlap between 1970 and 2010 with coincident changes in climate similarity between the Fraser Basin estuary and the network (**right**).}
\label{fig:OverMap}
\end{figure}

References
==========
