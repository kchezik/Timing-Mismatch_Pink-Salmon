// The input data is a vector 'y' of length 'N'.
data {
   // Observed Predictor Data
   int<lower=1> N;      // Number of observations
   int<lower=1> K;      // Number of predictors
   matrix[N,K] X;       // Predictors matrix
   
   // Data for river network effects
   matrix[N,N] dist;    // River network distance matrix between observations
   
   // Fit Parameters
   int<lower=1> N_smpl;                    // Number of samples from fit
   matrix[N_smpl,K] beta;                  // Coefficients approximating predictor mean effects
   vector<lower=0>[N_smpl] range; // Range parameter
   matrix<lower=0>[N_smpl,4] sigma;        // I.I.D. (nugget), partial-sill and random effect variance
}
parameters {
}
model {
}
generated quantities {
  // Observed
  vector[N] mu;     // Mean effect
  vector[N] mu_hat; // Expected mean effect
  vector[N] mu_doy; // DOY transform
  matrix[N,N] Z;    // Covariance matrix
  matrix[N,N] L;    // Lower diagnal of Z
  
  // Set initial values to 0
  for(i in 1:N) mu_doy[i] = 0;
  // Calculat the mean DOY across all estimates.
  for(i in 1:N_smpl){
    for(j in 1:N){
      // Mean
      mu[j] = sum(X[j].*beta[i]);
      // Covariance
      for(k in j:N){
        Z[j,k] = sigma[i,2]*exp(-3*dist[j,k]/range[i]);
        Z[k,j] = Z[j,k];
      }
    }
    // Decompose and estimate
    L = cholesky_decompose(Z);
    mu_hat = multi_normal_cholesky_rng(mu,L);
    // Add mean portion to final vector
    for(l in 1:N){
      mu_doy[l] += (inv_logit(mu_hat[l])*366)/N_smpl;
    }
  }
}
