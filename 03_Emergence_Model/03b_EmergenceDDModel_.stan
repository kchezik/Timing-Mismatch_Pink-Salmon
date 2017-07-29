data {
	int<lower=0> N; // Number of observations.
	vector<lower=-312, upper=384>[N] x; // Predictor
	vector<lower=0, upper=365>[N] y; // Response
}
parameters {
	real b0; // Intercept
	real b1; // Slope
	real sigma; // Standard deviation.
	real tau; // Exponential parameter.
}
model {
	// Linear model with exponential variance function modeling the errors.
	y ~ normal(b0 + b1 * x, sigma * exp(tau * x));
}
