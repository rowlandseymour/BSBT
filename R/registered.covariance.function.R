#' Construct a registered covariance matrix from the Euclidean coordinates of the objects
#'
#' This function constructs a covariance function from the Euclidean coordinates of the objects. The covairance function may be squared exponential, rational quadratic or Matern.
#'
#'
#' @param coordinates An Nx2 matrix containing the Euclidean coordinates of the nodes.
#' @param type The type of covariance function used. One of "sqexp", "ratquad" or "matern". Note: only matern with nu = 5/2 is supported.
#' @param hyperparameters A vector containing the covariance function hyperparameters. For the squared exponential and matern, the vector should contain the variance and length scale, for the rational quadratic, the vector should contain the variance, lenght scale and scaling parameters
#' @param linear.combination A matrix which defines the linear combination of (lambda_1, ..., lambda_N)^T.
#' @param linear.constraint The value the linear constraint takes. Defaults to 0.
#' @param tol The tolerance for the Cholesky decomposition
#' @return The mean vector and covariance matrix
#' @export
registered_covariance_function <- function(coordinates, type, hyperparameters,
                                           linear.combination, linear.constraint = 0, tol = 1e-5){


  if(type == "sqexp" & length(hyperparameters) != 2)
    stop("Insufficient hyperparameters. Squared Exponential requires 2 values.")
  if(type == "ratquad" & length(hyperparameters) != 3)
    stop("Insufficient hyperparameters. Rational Quadratic requires 3 values.")
  if(type == "matern" & length(hyperparameters) != 2)
    stop("Insufficient hyperparameters. Matern requires 2 values.")



  #Compute Euclidean distance between each pair of objects
  dist.mat <- as.matrix(stats::dist(coordinates))

  #Constructe Covariance Matrix
  if(type == "sqexp"){
    k <- hyperparameters[1]^2*exp(-dist.mat^2/hyperparameters[2]^2)
  } else if(type == "ratquad"){
    k <- hyperparameters[1]^2*(1 + dist.mat^2/(2*(hyperparameters[2]^2)*hyperparameters[3]))^(-hyperparameters[3])
  } else if(type == "matern"){
    k <- (1 + sqrt(5)/hyperparameters[2]*dist.mat + 5/(3*hyperparameters[2]^2)*dist.mat^2)*exp(-sqrt(5)/hyperparameters[2]*dist.mat)
  } else {
    stop("Could not construct covariance matrix. Unrecognised covariance type.")
  }

  if(dim(coordinates)[1] != length(linear.combination))
    stop("Could not register distirbution. Linear constraint dimensions does not match number of objects.")



  #Register Prior Distribution
  if(length(linear.constraint) > 1)
    stop("Currently only scalar constraints are supported")

  prior.mean               <- rep(0, dim(coordinates)[1])
  registered.k             <- k - k%*%linear.combination%*%t(k%*%linear.combination)*as.numeric((1/(linear.combination%*%k%*%linear.combination)))
  registered.mean          <- prior.mean + as.numeric((0-t(prior.mean)%*%linear.combination)/(t(linear.combination)%*%k%*%linear.combination))*k%*%linear.combination
  registered.chol          <- chol(registered.k + tol*diag(dim(k)[1]))

 return(list("mean" = registered.mean, "covariance" = registered.k, "decomp.covariance" = registered.chol))
}
