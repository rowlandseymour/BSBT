#' Compute the qaulity ratio on a logit scale
#'
#' This function compute the logit(pi_ij) = lambda_i - log(exp(lambda_i) + exp(lambda_j))
#'
#'
#' @param x The level of deprivation of the winning area on the exponential scale
#' @param y The level of deprivation of the losing area on the exponential scale
#' @return logit(pi_ij)
#' @export
quality.ratio <- function(x, y) log(x)- log(x+y)


#' Compute the value of the loglikelihood function
#'
#' This function computes the value of the binomial loglikelihood function
#'
#'
#' @param x The level of deprivation of the areas on an exponential scale
#' @param win.matrix A matrix, where w_ij give the number of times area i beat j
#' @return The value of of the loglikelihood function
#' @export
loglike.function <- function(x, win.matrix){

  result <- outer(x, x, quality.ratio)*win.matrix

  return(sum(result))

}

#' Draw a sample from a multivariate normal diastirbution
#'
#' This draws a sample from a multivariate normal distribution with mean vector mu and covariance matirx Sigma, using the Cholesky decomposition method.
#'
#'
#' @param mu The mean vector
#' @param chol The cholesky decomposition of the covariance matrix Sigma
#' @return a vector containing a sample from the distribution
#' @export
mvnorm.chol <- function(mu, chol){

  return(mu + t(chol)%*%rnorm(length(mu)))
}


#' Run the BTUN MCMC algorithm
#'
#' This function runs the BTUN mcmc algorithm
#'
#'
#' @param n.iter The number of iterations to be run
#' @param delta The underrlaxed tuning parameter must be in (0, 1)
#' @param k.mean The GP prior mean vector
#' @param k.chol The cholesky decomposition of the GP prior covariance matrix
#' @param win.matrix A matrix, where w_ij give the number of times area i beat j
#' @param f.initial A vector of the intial esitmate for f
#' @param alpha A boolean if inference for alpha should be carried out
#' @return A list of MCMC output
#' \itemize{
#'   \item f.matrix - A matrix containing the each iteration of f
#'   \item alpha.sq - A vector containing the iterations of alpha^2
#'   \item accpetance.rate - The acceptance rate for f
#'   \item time.taken - Time tkane to run the MCMC algorithm in seconds
#' }
#' @export
run.mcmc <- function(n.iter, delta, k.mean, k.chol, win.matrix, f.intial, alpha = FALSE){

  f <- f.intial
  n.objects <- length(f)
  loglike <- loglike.function(as.numeric(exp(f)), win.matrix)

  counter <- 0
  f.matrix <- matrix(NA, n.iter, n.objects)
  alpha.vector <- numeric(n.iter)

  if(alpha == TRUE)
    k.chol.plain <- k.chol

  # MCMC Loop ---------------------------------------------------------------

  tic <- Sys.time()
  for(i in 1:n.iter){

    #Update alpha

    if(alpha == TRUE){
      alpha.sq.current   <- 1/rgamma(1, 0.1 + n.objects/2, 0.5*t(f)%*%k.chol.plain%*%f + 0.1)
      k.chol     <- sqrt(alpha.sq.current)*k.chol.plain
      alpha.vector[i]  <- alpha.sq.current
    }





    #Update f0
    f.prop <- sqrt(1 - delta^2)*f + delta*mvnorm.chol(k.mean, k.chol)
    loglike.prop <- loglike.function(as.numeric(exp(f.prop)), win.matrix)

    log.p.acc <- loglike.prop - loglike
    if(log(runif(1)) < log.p.acc){
      f                     <- f.prop
      loglike               <- loglike.prop
      counter[1]            <- counter[1] + 1
    }

    f.matrix[i, ]   <- f

  }

  toc <- Sys.time()

  if(alpha == TRUE)
    return(list("f" = f.matrix, "alpha.sq" =alpha.vector, "acceptance.rate" = counter/n.iter, "time.taken" = toc - tic))
  else
    return(list("f" = f.matrix, "acceptance.rate" = counter/n.iter, "time.taken" = toc - tic))

}


#' Run the BTUN with Gender Effect MCMC algorithm
#'
#' This function runs the BTUN with Gender Effect MCMC algorithm
#'
#'
#' @param n.iter The number of iterations to be run
#' @param delta The underrlaxed tuning parameter must be in (0, 1)
#' @param k.mean The GP prior mean vector
#' @param k.chol The cholesky decomposition of the GP prior covariance matrix, alpha must be set to 1 when constructing ths
#' @param male.win.matrix A matrix, where w_ij give the number of times area i beat j when judged by men
#' @param female.win.matrix A matrix, where w_ij give the number of times area i beat j when judged by women
#' @param f.initial A vector of the intial esitmate for f, the male function
#' @param g.initial A vector of the intial esitmate for g, the discrepancy functon
#' @return A list of MCMC output
#' \itemize{
#'   \item f.matrix - A matrix containing the each iteration of f
#'   \item g.matrix - A matrix containing the each iteration of g
#'   \item alpha.sq - A matrix containing the iterations of alpha^2
#'   \item accpetance.rate - The acceptance rate for f and g
#'   \item time.taken - Time tkane to run the MCMC algorithm in seconds
#' }
#' @export

run.gender.mcmc <- function(n.iter, delta, k.mean, k.chol, male.win.matrix, female.win.matrix, f.intial, g.initial){

  f <- f.intial
  g <- g.initial
  n.objects <- length(f)
  loglike <- loglike.function(as.numeric(exp(f)), male.win.matrix) + loglike.function(as.numeric(exp(g + f)), female.win.matrix)

  counter <- 0
  f.matrix <- matrix(NA, n.iter, n.objects)
  g.matrix <- matrix(NA, n.iter, n.objects)
  alpha.matrix <- matrix(NA, n.iter, 2)

  k.plain.chol <- k.chol

  # MCMC Loop ---------------------------------------------------------------

  tic <- Sys.time()
  for(i in 1:n.iter){

  #Gibbs Step for alpha
  male.alpha.sq.current     <- 1/rgamma(1, 0.1 + n.objects/2, 0.5*t(f)%*%k.chol.plain%*%f + 0.1)
  female.alpha.sq.current   <- 1/rgamma(1, 0.1 + n.objects/2, 0.5*t(g)%*%k.chol.plain%*%g + 0.1)
  male.k.chol               <- sqrt(male.alpha.sq.current)*k.chol.plain
  female.k.chol             <- sqrt(female.alpha.sq.current)*k.chol.plain
  alpha.matrix[i, ]         <- c(male.alpha.sq.current, female.alpha.sq.current)

  #MH step for f and g
  f.prop <- sqrt(1 - delta^2)*f + delta*mvnorm.chol(k.mean, male.k.chol)
  g.prop <- sqrt(1 - delta^2)*g + delta*mvnorm.chol(k.mean, female.k.chol)

  loglike.prop <- loglike.function(as.numeric(exp(f.prop)), male.win.matrix) +
    loglike.function(as.numeric(exp(g.prop + f.prop)), female.win.matrix)

  log.p.acc <- loglike.prop - loglike

  if(log(runif(1)) < log.p.acc){

    f <- f.prop
    g <- g.prop
    loglike <- loglike.prop
    counter <- counter + 1

  }

  f.matrix[i, ]   <- f
  g.matrix[i, ]   <- g

  }

  toc <- Sys.time()

  if(alpha == TRUE)
    return(list("f" = f.matrix, "g" = g.matrix, "alpha.sq" =alpha.vector, "acceptance.rate" = counter/n.iter, "time.taken" = toc - tic))



}






