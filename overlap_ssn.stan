data{
   // Data for fixed effects
   int<lower=1> N;      // Number of observations
   int<lower=1> K;      // Number of predictors
   matrix[N,K] X;       // Predictors matrix
   vector[N] y;         // Response vector
   
   // Data for group-level effects of ID 1
   int<lower=1> n_r1;    // Number of group levels
   int<lower=1> x_r1[N]; // An array of group level effect values
   
   // Data for group-level effects of ID 2
   int<lower=1> n_r2;    // Number of group levels
   int<lower=1> x_r2[N]; // An array of group level effect values
   
   // Data for river network effects
   matrix<lower=0,upper=1>[N,N] dist;    // River network distance matrix between observations
   matrix<lower=0,upper=1>[N,N] flow;    // River network flow connections (0=no, 1=yes)
   vector<lower=0,upper=1>[N] weight;    // Relative influence based on downstream contributions
}
parameters{
   vector[K] beta;               // Coefficients approximating predictor mean effects
   real<lower=0, upper=1> range; // Range parameter
   vector<lower=0>[4] sigma;     // I.I.D. (nugget), partial-sill and random effect variance
   vector[n_r1] w_r1[1];         // Group level effect 1
   vector[n_r2] w_r2[1];         // Group level effect 2
}
transformed parameters{
   // Group-level effects
   vector[n_r1] r1 = (sigma[3]*(w_r1[1]));
   vector[n_r2] r2 = (sigma[4]*(w_r2[1]));
}
model{
   matrix[N,N] Z;  // Covariance matrix
   //matrix[N,N] L;  // Lower diagnal of Z
   
   // Estimate the mean given fixed effects and random effects
   vector[N] mu = X*beta;
   
   // Fit the covariance matrix by row and colum using the river distance matrix
   for(i in 1:N){
      // Calculate the group effects on the mean.
      mu[i] += r1[x_r1[i]] + r2[x_r2[i]];
      for(j in i:N){
         // Exponential tail-down model + group effect variance
         Z[i,j] = flow[i,j]*weight[i]*sigma[2]*exp(-3*dist[i,j]/range);
         // Make symetrical
         Z[j,i] = Z[i,j];
      }
      // Add the nugget effect (i.i.d remainder) and random effect variance to the diagonal
      Z[i,i] += sigma[1];
   }
   
   // Decompose for speed boost
   
   // priors including all constants
   target += student_t_lpdf(beta| 3, 0, 10);
   target += student_t_lpdf(sigma | 3, 0, 10);
   target += normal_lpdf(w_r1[1] | 0, 1);
   target += normal_lpdf(w_r2[1] | 0, 1);
   target += beta_lpdf(range | 5, 3);
   
   // Fit observations to the mean with covariance matrix L.
   target += multi_normal_lpdf(y | mu, Z);
}
generated quantities {
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
