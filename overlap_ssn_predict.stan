data {
   // Data for fixed effects
   int<lower=1> N;      // Number of observations
   int<lower=1> K;      // Number of predictors
   matrix[N,K] X;       // Predictors matrix
   
   // Data for group-level effects of ID 1
   int<lower=1> n_r1;    // Number of group levels
   int<lower=1> x_r1[N]; // An array of group level effect values
   
   // Data for river network effects
   matrix<lower=0,upper=1>[N,N] dist;    // River network distance matrix between observations
   matrix<lower=0,upper=1>[N,N] flow;    // River network flow connections (0=no, 1=yes)
   vector<lower=0,upper=1>[N] weight;    // Relative influence based on downstream contributions
   
   // Fit Parameters
   int<lower=1> N_smpl;              // Number of samples from fit
   matrix[N_smpl,K] beta;            // Coefficients approximating predictor mean effects
   vector<lower=0>[N_smpl] range;    // Range parameter
   matrix<lower=0>[N_smpl,4] sigma;  // I.I.D. (nugget), partial-sill and random effect variance
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
   
   // Mean effect
   mu = X*beta;
  
  // Add random effect and calculate covariance structure
   for(i in 1:N){
      // Random effect
      mu[i] += r1[x_r1[i]] + r2[x_r2[i]];
      for(j in i:N){
         Z[i,j] = flow[i,j]*weight[i]*sigma[2]*exp(-3*dist[i,j]/range);
         Z[j,i] = Z[i,j];
      }
      Z[i,i] += sigma[1];
   }
  
  // Decompose, estimate and transform
  mu_hat = multi_normal_rng(mu,Z);
  mu_doy = inv_logit(mu_hat);
}