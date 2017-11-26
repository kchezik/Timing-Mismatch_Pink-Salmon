data {
	int<lower=0> N; // Number of observations.
	vector[N] x; // Predictor: Degree-days centered by the mean.
	vector[N] y; // Response: Days bound between 0 and 365.
}
parameters {
	real b0; // Intercept: Bound between 0 and 365.
	real b1; // Slope.
	real<lower=0> sigma; // Standard deviation: Not less than zero.
	real tau; // Exponential parameter.
}
model {
	//Priors
	b0 ~ normal(0,1); // Normal around spring time but unlikely to approach 0 or 365.
	b1 ~ normal(0,0.5); // Degree days per day is always a ratio less than 1.
	tau ~ normal(0,1); // Exponential decline or increase bound by 1 and -1.
	
	// Linear model with exponential variance function modeling the errors.
	y ~ normal(b0 + b1 * x, sigma * exp(tau * x));
}
