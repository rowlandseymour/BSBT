#' BSBT: Bayesian Spatial Bradley--Terry
#'
#' This package implements the Bayesian Spatial Bradley--Terry (BSBT) model. It can be used to investigate data sets where judges compared different spatial areas. It constructs a network to describe how the areas are connected, and then constructs a correlated prior distribution for the quality parameters based on the network. The package includes MCMC algorithms to estimate the quality parameters.
#' @section Covariance Functions:
#' The covariance functions can be used to construct the Gaussian Process prior distribution.
#' There are two functions:
#' \enumerate{
#'     \item \code{\link{registered_adjacency_covariance_function}} creates a covariance matrix
#'     using a network based metric, and
#'     \item \code{\link{registered_covariance_function}} creates a matrix using the Euclidean distance metric.
#' }
#'
#' @section MCMC functions:
#' The main MCMC function is \code{\link{run_mcmc}}, but in cases where the gender of the judges is known
#' the function \code{\link{run_gender_mcmc}} can be used to analyse how the different genders behave.
#'
#' @docType package
#' @name BSBT
NULL