#' Construct a registered covariance matrix from the coordiantes of the nodes
#'
#' This function constructs a covariance function from the Euclidean coordinates of the nodes. It constructs a voronoi grpah to partition the space and places edges betweeen areas which are adjacent. The covairance function may be suqred exponential, rational quadratic or Matern
#'
#'
#' @param coordiantes An Nx2 matrix containing the Euclidean coordinates of the nodes.
#' @plane.boundary A matrix containing the cooridnates of the vertices of the boundard of the space. See ggvoronoi.
#' @param type The type of covariance function used. One of "sqexp", "ratquad" or "matern". Note: only matern with nu = 5/2 is supported.
#' @param hyperaparameters A vector containing the covariance function hyperparameters. For the squared exponential and matern, the vector should contain the variance and length scale, for the rational quadratic, the vector should contain the variance, lenght scale and scaling parameters
#' @param linear.combination A matrix which defines the linear combination of (lambda_1, ..., lambda_N)^T.
#' @param linear.constraint The value the linear constraint takes. Defaults to 0.
#' @return The mean vector and covariance matrix
#' @export
#' @export
registered.network.covariance.function <- function(coordinates, plane.boundary, type, hyperparameters,
                                           linear.combination, linear.constraint = 0){


  #Partion Plane using Voronoi diagram and create network from this. Use dijkstra's algorithm to
  # compute shortest path between each node
  plane.partition         <- ggvoronoi::voronoi_polygon(data=coordinates,x="x",y="y",outline=plane.boundary)
  adj.matrix              <- surveillance::poly2adjmat(plane.partition)
  object.network          <- igraph::graph.adjacency(adj.matrix, weighted=TRUE)
  shortest.path.matrix    <- igraph::shortest.paths(object.network, algorithm = "dijkstra")



  if(type == "sqexp" & length(hyperparameters) != 2)
    stop("Insufficient hyperparameters. Squared Exponential requires 2 values.")
  if(type == "ratquad" & length(hyperparameters) != 3)
    stop("Insufficient hyperparameters. Rational Quadratic requires 3 values.")
  if(type == "matern" & length(hyperparameters) != 2)
    stop("Insufficient hyperparameters. Matern requires 2 values.")

  if(dim(shortest.path.matrix)[1] != length(linear.combination))
    stop("Could not register distirbution. Linear constraint dimensions does not match number of objects.")



  #Constructe Covariance Matrix
  if(type == "sqexp"){
    k <- hyperparameters[1]^2*exp(-shortest.path.matrix^2/hyperparameters[2]^2)
  } else if(type == "ratquad"){
    k <- hyperparameters[1]^2*(1 + shortest.path.matrix^2/(2*(hyperparameters[2]^2)*hyperparameters[3]))^(-hyperparameters[3])
  } else if(type == "matern"){
    k <- (1 + sqrt(5)/hyperparameters[2]*shortest.path.matrix + 5/(3*hyperparameters[2]^2)*shortest.path.matrix^2)*exp(-sqrt(5)/hyperparameters[2]*shortest.path.matrix)
  } else {
    stop("Could not construct covariance matrix. Unrecognised covariance type.")
  }


  #Register Prior Distribution
  if(length(linear.constraint) > 1)
    stop("Currently only scalar constraints are supported")

  prior.mean               <- rep(0, dim(shortest.path.matrix)[1])
  registered.k             <- k - k%*%linear.combination%*%t(k%*%linear.combination)*as.numeric((1/(linear.combination%*%k%*%linear.combination)))
  registered.mean          <- prior.mean + as.numeric((0-t(prior.mean)%*%linear.combination)/(t(linear.combination)%*%k%*%linear.combination))*k%*%linear.combination


  return(list("mean" = registered.mean, "covariance" = registered.k))
}
