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

Our degree-day model allows us to estimate emergence using simply stream water temperature but is limited by the fact that we must also know when spawning occured. Spawning dictates when we begin accumulating thermal time such that adult behavior impacts emergence and subsequently estuary arrival timing. Because we would like to predict emergence over a broad climatic landscape, often in locations where spawn data are not available or spawning has not been observed, we need a model that allows us to predict when spawning might occur were it to happen in a given location. Here we use a spatial linear mixed effects model:

(model)
\begin{linenomath*}
\begin{equation}
\hat{S}_{s,t} = \mathrm{X}_{s,t}\beta + \mathrm{z}_{d} + \mathrm{W}_{s} \label{eq3}
\end{equation}
\end{linenomath*}

where $\hat{S}_{s,t}$ represents a spawn date at site ($\mathrm{s}$) for year ($\mathrm{t}$) and $\mathrm{X}_{s,t}$ represents a matrix of climate and landscape predictor variables. 

We included an autocorrelation stucture that accounts for the spatial relationship between stream connections within the Fraser River network:

(auto-correlation structure)

We chose this model in part because pink salmon have only recently recolonized much of their historic range and in part because pink salmon have a strong straying tendency relative to other salmon species [@Pess:2012]. Therefore we expect populations that are closer together along the river network will share more genetic information and respond more similarly to abiotic drivers than populations further apart. Acounting for network spatial relationship offer a way of accounting for straying among populations thereby reducing uncertainty in our model.


such that spawn timing (i.e., nuSEDS), stream temperature, climate [@Wang:2012], emergence [e.g., Beacham:1988] and plankton bloom [@Allen:2013] data are all available. Using these data we estimate when hypothetical populations throughout the basin would be expected to arrive in the estuary, the probability of overlap with zooplankton blooms and the degree to which overlap is a function of climate synchrony with the estuary.


#References
