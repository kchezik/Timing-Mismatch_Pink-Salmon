data {
   // Data for fixed effects
   int<lower=1> N;      // Number of observations
   int<lower=1> K;      // Number of predictors
   matrix[N,K] X;       // Predictors matrix
   
   // Data for group-level effects of ID 1
   //int<lower=1> n_r1;    // Number of group levels
   //int<lower=1> x_r1[N]; // An array of group level effect values
   
   // Data for river network effects
   matrix[N,N] dist;                  // River network distance matrix between observations
   matrix<lower=0,upper=1>[N,N] flow; // River network flow connections (0=no, 1=yes)
   vector<lower=0,upper=1>[N] weight; // Relative influence based on downstream contributions
   
   // Fit Parameters
   int<lower=1> N_smpl;              // Number of samples from fit
   matrix[N_smpl,K] beta;            // Coefficients approximating predictor mean effects
   vector<lower=0>[N_smpl] range;    // Range parameter
   matrix<lower=0>[N_smpl,2] sigma;  // I.I.D. (nugget), partial-sill and random effect variance
}
parameters {
}
model {
}
generated quantities{
  // Observed
  vector[N] mu;     // Mean effect
  vector[N] mu_hat; // Expected mean effect
  vector[N] mu_doy; // DOY transform
  matrix[N,N] Z;    // Covariance matrix
  
  // Set initial values to 0
  for(i in 1:N) mu_doy[i] = 0;
  
  // Calculate the mean DOY across all estimates.
  for(i in 1:N_smpl){
    for(j in 1:N){
      // Mean
      mu[j] = sum(X[j].*beta[i]);
      // Covariance
      for(k in j:N){
        Z[j,k] = flow[j,k]*weight[j]*sigma[i,2]*exp(-3*dist[j,k]/range[i]);
        Z[k,j] = Z[j,k];
      }
      Z[j,j] += sigma[i,1];
    }
    // Decompose and estimate
    mu_hat = multi_normal_rng(mu, Z);
    // Add mean portion to final vector
    for(l in 1:N){
      mu_doy[l] += mu_hat[l]/N_smpl;
    }
  }
}
