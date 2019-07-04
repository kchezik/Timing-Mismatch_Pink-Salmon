data {
	int<lower=0> N; 								// Number of observations
	vector<lower=0>[N] x; 					// Predictor: Cumulative degree-days (CDD)
	vector<lower=0,upper=366>[N] y; // Response: Days bound between 0 and 365
}
transformed data{
	real mean_x = mean(x);	// Mean CDD
	vector[N] xc;						// Centered CDD
	vector[N] y_lgt;				// Logit transformed response
	// Calculate transformations
	xc = (x - mean_x)/sd(x);
	y_lgt = logit(y/366);
}
parameters {
	real b0; 				      // Intercept
	real<upper=0> b1; 		// Slope
	real<lower=0> sigma;	// Standard deviation
	real tau; 						// Exponential parameter
}
model {
	//Priors
	b0 ~ normal(0,1); 	// After centering and logit transformation should be near 0
	b1 ~ normal(0,1); 	// Degree days per day is always a ratio less than 1.
	tau ~ normal(0,1);	// Exponential decline or increase bound by 1 and -1.
	
	// Linear model with exponential variance function modeling the errors.
	y_lgt ~ normal(b0 + b1*xc, sigma*exp(tau*xc));
}
