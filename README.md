# BTUN: Bradley--Terry for Urban Networks

This package fits the BTUN model to comparative judgement data. It can be used when comparing different urban areas based on the level of deprivation in each area, and it infers the how deprived each area it. It uses a Gaussian Process to model the spatial structure in the variation of deprivation. The package includes an MCMC algorithm to learn the model parameters.


## Functions

### Simulation

* `simulate_contests.R` - This function create simulated data. Given the level of deprivation in each area, it simulates pair-wise contests from the Bradley--Terry Model.

### Covariance Matrices
These functions construct registered covariance matrices. We allow for either Euclidean or Network based distance metrics to be used when constructing the covariance matrix. We allow for squared exponential, rational quadratic, or matern covariance functions to be used. The covariance matrices are registered, meaning a linear combination of the function values are fixed.

* `registered.covariance.function.R` - This function constructs a covariance matrix based on the Euclidean distance between each pair of areas.
* `registered.adjacent.covariance.function.R` - This function constructs a covariance matrix based on the network adjacency matrix.
* `registered.network.covariance.function.R` - This function first partitions the Euclidean plane using a voronoi method, and then creates a network. It constructs a covariance matrix based on the adjacency matrix of the network.

### MCMC

* `mcmc_functions.R` - This contains the functions necessary to run the MCMC algorithm, including computing the likelihood function. 
