#' BSBT: Bayesian Spatial Bradley--Terry
#'
#'An implementation of the Bayesian Spatial Bradley--Terry (BSBT) model.
#'It can be used to investigate data sets where judges compared different
#'objects. It constructs a network to describe how the objects are connected,
#'and then places a correlated prior distribution on the quality parameter for
#' each object, based on the network. The package includes MCMC algorithms to
#' estimate the quality parameters.
#'
#' @section Covariance Functions:
#' The covariance functions can be used to construct the Multivariate Normal
#' prior distribution. The prior distribution includes a constraint,
#' where a linear combination of the parameters can be specified.
#'
#' There are two functions:
#' \enumerate{
#'     \item \code{\link{constrained_adjacency_covariance_function}} creates a
#'     covariance matrix using a network based metric, and
#'     \item \code{\link{constrained_covariance_function}} creates a matrix
#'
#'     using the Euclidean distance metric.
#' }
#'
#' @section MCMC functions:
#' The main MCMC function is \code{\link{run_mcmc}}, but in cases where there
#'  are different types of judges the function \code{\link{run_symmetric_mcmc}}
#'  can be used to analyse how the different types behave.
#'
#' @docType package
#' @name BSBT
NULL
