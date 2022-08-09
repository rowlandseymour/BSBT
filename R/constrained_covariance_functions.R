#' Construct a constrained covariance matrix from the Euclidean coordinates of the objects
#'
#' This function constructs a covariance function from the Euclidean
#' coordinates of the objects. The covariance function may be
#' squared exponential, rational quadratic or Matern. It includes a constraint,
#' where a linear combination of the parameters can be fixed.
#'
#'
#' @param coordinates An Nx2 matrix containing the Euclidean coordinates of the nodes.
#' @param type The type of covariance function used. One of "sqexp", "ratquad" or "matern". Note: only matern with nu = 5/2 is supported.
#' @param hyperparameters A vector containing the covariance function hyperparameters. For the squared exponential and matern, the vector should contain the variance and length scale, for the rational quadratic, the vector should contain the variance, length scale and scaling parameters
#' @param linear.combination A matrix which defines the linear combination of the parameter vector lambda = (lambda_1, ..., lambda_N)^T. The linear combination is a vector of coefficients such that linear.combination %*% lambda = linear.constraint.
#' @param linear.constraint The value the linear constraint takes. Defaults to 0.
#' @return The mean vector and covariance matrix
#'
#' @seealso For more information about covariance functions see \url{https://www.cs.toronto.edu/~duvenaud/cookbook/} or \url{http://gaussianprocess.org/gpml/chapters/RW4.pdf}
#'
#' @examples
#' #Generate 10 points and create covariance matrix using Euclidean distance metric
#' coords <- data.frame("x" = c(0, 1, 2), "y" = c(0, 1, 2)) #generate coordinates
#' #create covariance matrix using Squared Exponential function and subject to the constraint
#' #the sum of the deprivation levels is 0.
#' k <- constrained_covariance_function(coords, "sqexp",
#' c(1, 5), rep(1, 3), linear.constraint = 0)
#' @export
constrained_covariance_function <- function(coordinates, type, hyperparameters,
                                           linear.combination, linear.constraint = 0){


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
    stop("Could not constrain distirbution. Linear constraint dimensions does not match number of objects.")



  #Constrain Prior Distribution
  if(length(linear.constraint) > 1)
    stop("Currently only scalar constraints are supported")

  prior.mean                <- rep(0, dim(coordinates)[1])
  constrained.k             <- k - k%*%linear.combination%*%t(k%*%linear.combination)*as.numeric((1/(linear.combination%*%k%*%linear.combination)))
  constrained.mean          <- prior.mean + as.numeric((linear.constraint-t(prior.mean)%*%linear.combination)/
                                                         (t(linear.combination)%*%k%*%linear.combination))*k%*%linear.combination
  spectral.decomp           <- eigen(constrained.k)
  spectral.decomp$values[spectral.decomp$values < 0] <- 0 #Deal with precision errors in covariance matrix
  constrained.decomp        <- spectral.decomp$vectors%*%diag(sqrt(spectral.decomp$values))
  constrained.inv           <- MASS::ginv(constrained.k)

 return(list("mean" = constrained.mean, "covariance" = constrained.k, "decomp" = constrained.decomp, "inv" = constrained.inv))
}



#' Construct a constrained covariance matrix from the adjacency matrix
#'
#' This function constructs a covariance function from the graph's adjacency
#' matrix. The covariance function may be squared exponential,
#' rational quadratic, Matern or the matrix exponential.
#' It includes a constraint, where a linear combination of the parameters
#' can be fixed.
#'
#'
#' @param adj.matrix The graph adjacency matrix
#' @param type The type of covariance function used. One of "sqexp", "ratquad", "matern" or "matrix". Note: only matern with nu = 5/2 is supported.
#' @param hyperparameters A vector containing the covariance function hyperparameters. For the squared exponential and matern, the vector should contain the variance and length scale, for the rational quadratic, the vector should contain the variance, length scale and scaling parameters
#' @param linear.combination A matrix which defines the linear combination of the parameter vector lambda = (lambda_1, ..., lambda_N)^T. The linear combination is a vector of coefficients such that linear.combination %*% lambda = linear.constraint.
#' @param linear.constraint The value the linear constraint takes. Defaults to 0.
#' @return The mean vector and covariance matrix
#'
#' @seealso For more information about covariance functions see \url{https://www.cs.toronto.edu/~duvenaud/cookbook/} or \url{http://gaussianprocess.org/gpml/chapters/RW4.pdf}
#'
#' @examples
#' #Construct covariance matrix of Dar es Salaam, Tanzania, using network metric
#' data(dar.adj.matrix, package = "BSBT") #load dar es salaam adjacency matrix
#' k <- constrained_adjacency_covariance_function(dar.adj.matrix, type = "sqexp",
#'        hyperparameters = c(1, 1), rep(1, dim(dar.adj.matrix)[1]), 0)
#'        #Covariance registered by sum of objects is 0 using rational quadratic function
#' @export
constrained_adjacency_covariance_function <- function(adj.matrix, type, hyperparameters,
                                                     linear.combination, linear.constraint = 0){


  #Use dijkstra's algorithm to
  # compute shortest path between each node
  if(type != "matrix"){
  object.network          <- igraph::graph.adjacency(adj.matrix, weighted=TRUE)
  shortest.path.matrix    <- igraph::shortest.paths(object.network, algorithm = "dijkstra")
  }



  if(type == "sqexp" & length(hyperparameters) != 2)
    stop("Insufficient hyperparameters. Squared Exponential requires 2 values.")
  if(type == "ratquad" & length(hyperparameters) != 3)
    stop("Insufficient hyperparameters. Rational Quadratic requires 3 values.")
  if(type == "matern" & length(hyperparameters) != 2)
    stop("Insufficient hyperparameters. Matern requires 2 values.")
  if(type == "matrix" & length(hyperparameters) != 2)
    stop("Insufficient hyperparameters. Matrix exponential requires 2 values.")

  if(dim(adj.matrix)[1] != length(linear.combination))
    stop("Could not constrain distirbution. Linear constraint dimensions does not match number of objects.")



  #Construct Covariance Matrix
  if(type == "sqexp"){
    k <- hyperparameters[1]^2*exp(-shortest.path.matrix^2/hyperparameters[2]^2)
  } else if(type == "ratquad"){
    k <- hyperparameters[1]^2*(1 + shortest.path.matrix^2/(2*(hyperparameters[2]^2)*hyperparameters[3]))^(-hyperparameters[3])
  } else if(type == "matern"){
    k <- (1 + sqrt(5)/hyperparameters[2]*shortest.path.matrix + 5/(3*hyperparameters[2]^2)*shortest.path.matrix^2)*exp(-sqrt(5)/hyperparameters[2]*shortest.path.matrix)
  } else if(type == "matrix"){
    k <- expm::expm(hyperparameters[2]*adj.matrix)
    k <- hyperparameters[1]^2*diag(diag(k)^-0.5)%*%k%*%diag(diag(k)^-0.5)
  }else {
    stop("Could not construct covariance matrix. Unrecognised covariance type.")
  }


  #Constrain Prior Distribution
  if(length(linear.constraint) > 1)
    stop("Currently only scalar constraints are supported")

  prior.mean                <- rep(0, dim(k)[1])
  constrained.k             <- k - k%*%linear.combination%*%t(k%*%linear.combination)*as.numeric((1/(linear.combination%*%k%*%linear.combination)))
  constrained.mean          <- prior.mean + as.numeric((linear.constraint-t(prior.mean)%*%linear.combination)/(t(linear.combination)%*%k%*%linear.combination))*k%*%linear.combination
  spectral.decomp           <- eigen(constrained.k)
  spectral.decomp$values[spectral.decomp$values < 0] <- 0 #Deal with precision errors in covariance matrix
  constrained.decomp        <- spectral.decomp$vectors%*%diag(sqrt(spectral.decomp$values))
  constrained.inv           <- MASS::ginv(constrained.k)

  return(list("mean" = constrained.mean, "covariance" = constrained.k, "decomp" = constrained.decomp, "inv" = constrained.inv))
}



