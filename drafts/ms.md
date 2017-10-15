% Spatial Structuring of Climate Match-Mismatch in a Migratory Fish
% K. A. Chezik; S. M. Wilson; J. W. Moore
% October 2, 2017

\linenumbers

#Abstract

*Message Box*

There is growing evidence that climate change is driving phenological shifts and disrupting species interactions. However, climate is changing unevenly across space and many animals migrate across great distances and environments. Spatial structuring of populations may influence their vulnerability to phenological mismatch. Here we demonstrate spatial structuring of phenological asynchrony in a migratory fish.

#Introduction

Climate change is disrupting the phenological synchrony of ecological interactions. As global temperatures rise many species are moving towards the poles and shifting the timing of life history events towards cooler seasonal temperatures [@Parmesan:2003; @Root:2003]. For instance, of the 677 species assessed by @Parmesan:2003, 71\% demonstrated shifting phenologies with 87\% of those exhibiting advanced spring life history events. Despite generally coherent directional shifts in phenology among species the magnitude of change has been variable [@Thackeray:2010; @Thackeray:2016]. Incoherent magnitude shifts in phenology increases the opportunity for mismatch between inter-dependent species [@Cushing:1990; @Durant:2005].

Climate change is occurring unevenly over space [@Bindoff:2013], leaving migratory species particularly vulnerable to mismatch [@Visser:2005]. Environments that closely track each-other provide the opportunity for biota to synchronize, allowing species to take advantage of resources over a greater spatio-temporal range [@Moran:1953; @Royama:2012]. As distance increases so does the likelihood of dissimilar climate shifts, possibly disrupting synchrony with important habitat and resources along migratory routes [@Durant:2007]. Migration timing plays a key role in facilitating synchrony with migratory resources and is largely controled by environmental conditions [@Crozier:2011]. Under climate change, plastic responses to local shifts in the environment can lead to maladjusted arrival timing along the migratory route [e.g., Visser:1998]. Similarly, depending predominately on evolutionary adaptation may make keeping pace with climate change a challenge [@Crozier:2008]. Migration timing is only one component of phenology. All recurring life cycle events (e.g., growth, maturation, reproduction) respond and adapt to the environment. The tension between different life stages, their relationship with the environment and the mechanisms that govern them must be considered together if we are to understand the impacts of climate change on species [@Mangel:2008;@Crozier:2008].

Mismatch has been observed in salmon population dynamics throughout the northern hemisphere. For instance, @Otero:2014 found Atlantic salmon are outmigrating on average 2.5 days earlier per-decade since 1960 in the North Atlantic Ocean, similar to findings in the North Pacific where @Taylor:2008 observed Alaskan pink salmon outmigrating 5 days earlier per-decade since 1970. These shifts in smolt outmigration appear to be widespread among salmon species and suggest rapid microevolution [@Kovach:2012;@Kovach:2013], driven primarily by increasing air, river and ocean temperatures [@Taylor:2008]. Shifts in migration timing impact whether populations arrive in the estuary when zooplankton abundances are high, the foundational food resource for outmigrating juvenile salmon.

Increasing sea surface temperatures are shifting the timing [@Richardson:2008] and abundance [@Boyce:2010] of plankton blooms worldwide. Although zooplankton are reaching peak bloom earlier, bloom date has become more erratic and the rate of advance may not be keeping pace with shifting salmon outmigration [@Edwards:2004]. Arriving when food is plentiful encourages faster growth which improves survival [@Mortensen:2000; @Scheuerell:2009; @Satterthwaite:2014]. Tracking the inter-annual variation in plankton bloom in spite of divergent shifts in climate between local environments and the estuary will contribute to the future success and persistence of some populations over others [e.g., @Chittenden:2010, @Malick:2015]. Thus the climate driven phenological shifts of some salmon populations may be differently able to match climate driven phenological change in the ocean.

Here we examine whether there is spatial structuring of phenological asynchrony in a migratory fish of economic, ecological and cultural importance. Locally adapted salmon populations spawn throughout vast river networks that integrate diverse climate variability [@Chezik:2017], however each aims to synchronize with the plankton bloom of a common estuary. By leveraging shared information across a river network and propogating cumulative impacts and uncertainty from the date of spawn through to estuary arrival, we estimate match-mismatch potential for 64 sites within the largest salmon watershed in Canada. Here we test whether populations whose climates are well correlated with the estuary demonstrate increased synchrony with zooplankton bloom. We also examine whether there are changing patterns of synchrony over time as climate change impacts are realized differently over space.

#Materials and methods
*Study site*

The Fraser River watershed drains approximately 217,000 km^2^ of diverse terrain and climate (Fig.$~\ref{fig:map}$). Originating in the western Cordillera of North America, the basin drains snow laiden Canadian Rockies and Coastal Mountains. Converging and running down the dry central plateau of British Columbia, the river eventually crashes through the coastal mountains by way of Hells Gate canyon and spills into the Georgia Straight of the Pacific Ocean. We focus on the Fraser River watershed because the basin is large, topologically diverse, impacted by climate change [e.g., @Kang:2014; @Kang:2016; @Dery:2012; Schnorbus:2010; Shrestha:2012; Healey:2011] and home to five species of salmon. Funneling such a wide diversity of climate and divergent climate shifts to the same ocean outlet, the Fraser basin provides the necessary context for testing spatial match-mismatch patterns in salmon. 

\begin{figure}[H]
\centering
\includegraphics[width=6.5in]{./99_figures/ClimateMap.png}
\caption{Fraser River watershed in British Columbia Canada, colored by the mean annual temperature in 1970 (left) and 2010 (right).}
\label{fig:map}
\end{figure}

*Pink salmon*

Although most widely known for sockeye [@Eliason:2011], the Fraser River basin once also sustained large abundances of pink salmon (*Oncorhynchus gorbuscha*) [@Ricker:1989]. Extirpated from much of their original range due to a rockslide in 1913, pink salmon did not begin to recolonize above Hells Gate canyon until fish passage was reinstated in 1947 [@Roos:1991]. Despite extreme mortality in the early 19th century and incomplete recovery to date [@Pess:2012], we chose to focus our study on pink salmon because their life history patterns are relatively invariant [@Neave:1966]. Unlike most pacific salmon species, pink salmon outmigrate almost immediately upon emerging from the gravel. This relatively deterministic life history pattern eliminates significant behavioral uncertainty. Ultimately, by estimating emergence timing and accounting for the river distance to the estuary, variation in pink salmon arrival is largely driven by abiotic factors which have been relatively well monitored in the Fraser River watershed.

*Emergence timing estimation*

Incubation temperatures dominate the rate of egg growth and development [@Murray:1986], such that if we understand the thermal environment we can predict emergence. In order to account for temperature fluctuations in the natural environment we took a degree-day approach where the accumulation of thermal time since fertilization predicts the timing of emergence. This model is appealing because stream temperature data is widely available throughout the Fraser River basin. To described the relationship between thermal accumulation and days to emergence we used a linear regression model:

\begin{linenomath*}
\begin{equation}
	\hat{E}_{s} = b + m\mathrm{CDD}_{T_{0},s} + \eta_{s}, \quad
  \eta_{s} \sim \mathcal{N}(0, f(\mathrm{CDD}_{T_{0},s})) \label{eq1},
\end{equation}
\end{linenomath*}

where $\hat{E}_{s}$ represents the days to emergence at each observation ($s$) and $\mathrm{CDD}_{T_{0},s}$ represents cumulative degree days per observation ($s$) given a threshold temperature ($T$) of 0$\text{\textdegree}$C. We adjusted $\mathrm{CDD}_{T_{0},s}$ by subtracting the mean $\mathrm{CDD}_{T_{0}}$, thereby centering our predictor. Fitted $m$ and $b$ parameters represent the mean effect of $\mathrm{CDD}_{T_{0}}$ on days to emergence and the mean number of days to emergence for the average number of $\mathrm{CDD}_{T_{0}}$, respectively. In order to allow for heteroskedasticity in the data we modified our error structure using an exponential variance function:

\begin{linenomath*}
\begin{equation}
	f(\mathrm{CDD}_{T_{0},s}) = \sigma_E^2 \exp(2\updelta\mathrm{CDD}_{T_{0},s}) \label{eq2},
\end{equation}
\end{linenomath*}

where we allowed for the variance in our error ($\eta_{s}$) to decline with increasing $\mathrm{CDD}_{T_{0}}$ as defined by the estimated $\updelta$ parameter. This model was fit using RStan 2.16.2 [@Stan:2017] in a bayesian framework using Hamiltonian Monte Carlo (HMC) sampling. We allowed four chains to burn in 8,000 iterations before sampling every third iteration 20,000 times, ensuring convergence among chains and independence between samples.

Data were gathered from studies that reported days to emergence during a controlled thermal regime. For instance, @Beacham:1986 incubated five stocks of fertillized pink salmon eggs at 4, 8 and 12$\text{\textdegree}$C and recorded the number of days to 50\% emergence. By multiplying the days to emergence by the incubation temperature and summing these values, we get an estimate for the cumulative number of degree-days to emergence for each population under differerent thermal regimes. Many studies incubated eggs at thermal constants [@Brannon:1987; @Beacham:1988a; @Beacham:1988b; @Murray:1988], while others used variable thermal regimes that mimic seasonal shifts [@Murray:1986; @Beacham:1987]. Temperature accumulation under variable thermal regimes were accounted for provided the details of each studies methods. Our literature search resulted in 104 estimates of cumulative degree-days and days to emergence for 20 populations in British Columbia, derived from from seven studies.

*Spawn Timing*

Adult spawning timing dictates when our emergence model begins accumulating thermal time, subsequently affecting emergence and estuary arrival timing. Therefore, we must account for variation among spawning populations as well as in annual fluxuations and long-term trends within populations when predicting emergence. Furthermore, stream temperature data are not always coincident in space and time with spawning data. To account for variation in spawn timing and predict when spawning would occur where pink salmon are not currently known to spawn, we built a stream network linear mixed effects model:  
 
\begin{linenomath*}
\begin{equation}
\hat{S}_{s,t} = \mathrm{X}\beta + \epsilon, \quad
\epsilon \sim \mathrm{z}_{d} + \mathrm{z}_{nug} + \mathrm{z}_{y} + \mathrm{z}_{s} \label{eq3},
\end{equation}
\end{linenomath*}

where spawn date $\hat{S}$ at site ($\mathrm{s}$) in year ($\mathrm{t}$) is predicted by a matrix of climate and landscape variables $\mathrm{X}$, where the relationship between spawn date and these predictors are described by a vector of $\beta$ coefficients. Residual error ($\epsilon$) is decomposed into multiple random effects ($\mathrm{z}$) to capture the spatial autocovariance between populations. A "tail-down" autocovariance model ($\mathrm{z}_{d}$) describes the relationship among flow unconnected locations along the river network [@Ver:2010]. We used year ($\mathrm{z}_{y}$) and a site ($\mathrm{z}_{s}$) identifiers as random effects to account for year specific variation common across sites and repeated measures at individual sites respectively. The remaining independant and random error is captured in $\mathrm{z}_{nug}$.

Spawn timing data were obtained from the nuSEDS database owned and maintained by the Canadian Department of Fisheries and Oceans. We selected pink salmon observations from throughout British Columbia that included an estimate of the begining and peak spawn date. To capture variation in spawn timing we assumed the spawning period to be well approximated by a normal distribution and sampled from distributions for each site and year. Standard deviation ($\sigma$) estimates for each distribution were approximated by searching over a variety of $\sigma$ values and selecting the value whose difference between the mean and 99th percentile best approximated the observed difference between start and peak spawn dates. We sampled distributions 22 times for each of the 379 unique site-year combinations, resulting in 8734 spawn date estimates at 64 locations between 1957 and 1998. We limited our sub-sampling to reduce computational complexity and improve model fit times [@Ver:2014].

Temperature has been loosely connected with spawn timing in pink salmon [@Groot:1991] and may contribute to genetic controls on spawning and egg development [@Hebert:1998; @Smoker:1998]. To account for temperature on spawn timing we used Climate WNA [@Wang:2016] to estimate mean fall (September - October) and winter (November - February) air temperature as well as mean fall precipitation at observation and prediction sites. We also included elevation to act as a relative estimate of migration distance and to account for topographic interactions with precipitation.

We chose a stream network model in part because pink salmon have only recently recolonized much of their historic range and in part because pink salmon have a strong straying tendency relative to other salmon species [@Pess:2012]. Therefore we expect populations that are closer together along the river network will share more genetic information and respond more similarly to abiotic drivers than populations further apart. Acounting for network spatial relationships offers a way of directly addressing straying behaviour thereby reducing uncertainty in our spawn timing predictions.

#References
