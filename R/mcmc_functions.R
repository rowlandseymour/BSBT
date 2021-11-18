#' Compute the logit of the ratio of qualities
#'
#' This function computes the probability i beats j on the logit scale. It is given by logit(pi_ij) = lambda_i - log(exp(lambda_i) + exp(lambda_j))
#'
#'
#' @param x The level of deprivation of the winning object on the exponential scale
#' @param y The level of deprivation of the losing object on the exponential scale
#' @return logit(pi_ij)
#'
#' @keywords internal
#'
#' @examples
#'
#' #compare areas with levels -2 and 2
#'
#' qr <- quality_ratio(exp(-2), exp(2))
#'
#' @export
quality_ratio <- function(x, y) log(x)- log(x+y)


#' Compute the loglikelihood function
#'
#' This function computes the BSBT model loglikelihood function. It requires the deprivation levels and the win matrix.
#'
#'
#' @param x The level of deprivation of the areas on an exponential scale
#' @param win.matrix A matrix, where w_ij give the number of times object i beat j
#' @return The value of of the loglikelihood function
#'
#' @keywords internal
#'
#' @examples
#'
#' win.matrix <- matrix(c(0, 3, 2, 1, 0, 1, 1, 3, 0), 3, 3) #construct win matrix
#' lambda     <- c(3, 1, 2)
#'
#' l <- loglike_function(lambda, win.matrix)
#'
#' @export
loglike_function <- function(x, win.matrix){

  result <- outer(x, x, quality_ratio)*win.matrix

  return(sum(result))

}

#' Draw a sample from a multivariate normal distribution
#'
#' This draws a sample from a multivariate normal distribution with mean vector mu and covariance matrix Sigma. It requires the covariance matrix to be decomposed using the Cholesky method (chol).
#'
#'
#' @param mu The mean vector
#' @param chol The cholesky decomposition of the covariance matrix Sigma
#' @return a vector containing a sample from the distribution
#'
#' @keywords  internal distribution
#'
#'
#' @examples
#'
#' mu <- c(2, 1) #mean vector
#' sigma <- matrix(c(2^2, 0.5*2*1, 0.5*2*1, 1^2), 2, 2) #covariacne matrix
#' sigma.chol <- chol(sigma) #decompose covariance matrix
#' #f <- mvnorm_chol(mu, sigma.chol) #draw sample
#'
#' @export
mvnorm_chol <- function(mu, chol){
  .Deprecated("mvnorm_sd")
  #x <- mu + t(L)u, where u ~ N(0, I)
  return(mu + t(chol)%*%stats::rnorm(length(mu)))
}



#' Draw a sample from a multivariate normal distribution
#'
#' This draws a sample from a multivariate normal distribution with mean vector mu and covariance matrix Sigma. It requires the covariance matrix to be decomposed using spectral decomposition (eigen).
#'
#'
#' @param mu The mean vector
#' @param decomp.covariance This spectral decomposition part of the sampler. It is V*U^0.5, where Sigma = V*U*t(V). The required component is returned by the construct_constrained_covariance_matrix function.
#' @return a vector containing a sample from the distribution
#'
#' @keywords  internal distribution
#'
#'
#' @examples
#'
#' mu <- c(2, 1) #mean vector
#' sigma <- matrix(c(2^2, 0.5*2*1, 0.5*2*1, 1^2), 2, 2) #covariacne matrix
#' sigma.eigen <- eigen(sigma)
#' decomp.covariance <- sigma.eigen$vectors%*%diag(sqrt(sigma.eigen$values))
#' f <- mvnorm_sd(mu, decomp.covariance) #draw sample
#'
#' @export
mvnorm_sd <- function(mu, decomp.covariance){

  #x <- mu + U*V^0.5*u, where u ~ N(0, I)
  return(mu + decomp.covariance%*%stats::rnorm(length(mu)))
}

#' Run the BSBT MCMC algorithm
#'
#' This function runs the BSBT MCMC algorithm to estimate the deprivation parameters. In this version, the judges are assumed to act homogeneously. This algorithm estimates the deprivation in each object and the prior distribution variance parameter. For data with two types of judges, see \code{\link{run_symmetric_mcmc}}.
#'
#'
#' @param n.iter The number of iterations to be run
#' @param delta The underrlaxed tuning parameter must be in (0, 1)
#' @param covariance.matrix The output from the covariance matrix function, which contains the decomposed and inverted covariance matrix.
#' @param win.matrix A matrix, where w_ij give the number of times object i beat j
#' @param f.initial A vector of the initial estimate for f
#' @param alpha A boolean if inference for alpha should be carried out. If this is TRUE, the covariance matrix
#' @param omega The value of the inverse gamma shape parameter
#' @param chi The value of the inverse gamma scale parameter
#' @return A list of MCMC output
#' \itemize{
#'   \item f.matrix - A matrix containing the each iteration of f
#'   \item alpha.sq - A vector containing the iterations of alpha^2
#'   \item acceptance.rate - The acceptance rate for f
#'   \item time.taken - Time taken to run the MCMC algorithm in seconds
#' }
#'
#' @examples
#'
#' n.iter <- 10
#' delta <- 0.1
#' covariance.matrix <- list()
#' covariance.matrix$mean <- c(0, 0, 0)
#' covariance.matrix$decomp <- diag(3)
#' covariance.matrix$inv    <- diag(3)
#' comparisons <- data.frame("winner" = c(1, 3, 2, 2), "loser" = c(3, 1, 1, 3))
#' win.matrix <- comparisons_to_matrix(3, comparisons) #construct covariance matrix
#' f.initial <- c(0, 0, 0) #initial estimates for lamabda_1, lambda_2, lambda_3
#'
#' mcmc.output <- run_mcmc(n.iter, delta, covariance.matrix, win.matrix, f.initial)
#'
#'
#' @export
run_mcmc <- function(n.iter, delta, covariance.matrix, win.matrix, f.initial, alpha = FALSE, omega = 0.1, chi = 0.1){

  f <- f.initial
  n.objects <- length(f)
  loglike <- loglike_function(as.numeric(exp(f)), win.matrix)

  counter <- 0
  f.matrix <- matrix(NA, n.iter, n.objects)
  alpha.vector <- numeric(n.iter)

  if(alpha == TRUE)
    k.decomp.plain <- covariance.matrix$decomp

  # MCMC Loop ---------------------------------------------------------------
  pb <- utils::txtProgressBar(min = 1, max = n.iter, style = 3)
  tic <- Sys.time()
  for(i in 1:n.iter){

    #Update alpha

    if(alpha == TRUE){
      alpha.sq.current   <- 1/stats::rgamma(1, omega + n.objects/2, 0.5*t(f)%*%covariance.matrix$inv%*%f + chi)
      covariance.matrix$decomp          <- sqrt(alpha.sq.current)*k.decomp.plain
      alpha.vector[i]    <- alpha.sq.current
    }





    #Update f0
    f.prop <- sqrt(1 - delta^2)*f + delta*mvnorm_sd(covariance.matrix$mean, covariance.matrix$decomp)
    loglike.prop <- loglike_function(as.numeric(exp(f.prop)), win.matrix)

    log.p.acc <- loglike.prop - loglike
    if(log(stats::runif(1)) < log.p.acc){
      f                     <- f.prop
      loglike               <- loglike.prop
      counter[1]            <- counter[1] + 1
    }

    f.matrix[i, ]   <- f
    utils::setTxtProgressBar(pb, i) # update text progress bar after each iter

  }

  toc <- Sys.time()

  if(alpha == TRUE)
    return(list("f" = f.matrix, "alpha.sq" = alpha.vector, "acceptance.rate" = counter/n.iter, "time.taken" = toc - tic))
  else
    return(list("f" = f.matrix, "acceptance.rate" = counter/n.iter, "time.taken" = toc - tic))

}


#' Run the BSBT with symmetric effect MCMC algorithm
#'
#' This function runs the BSBT MCMC algorithm where two types are judges can be separated. It generates samples for the grand mean of the types  perceptions for the derivation in each object and the difference between them. It is similar to \code{\link{run_mcmc}}.
#' This function requires the data to be separate into two parts, one for each type. There should be a win matrix for each type. Similarly, initial estimates for the grand mean and difference parameters need to be included separately.
#'
#' @param n.iter The number of iterations to be run
#' @param delta The underrlaxed tuning parameter. Must be in (0, 1)
#' @param covariance.matrix The output from the covariance matrix function, which contains the decomposed and inverted covariance matrix. The variance hyperparameter must be set to 1.
#' @param type1.win.matrix A matrix, where w_ij give the number of times object i beat j when judged by men
#' @param type2.win.matrix A matrix, where w_ij give the number of times object i beat j when judged by women
#' @param f.initial A vector of the initial estimate for f, the grand mean of the perceptions
#' @param g.initial A vector of the initial estimate for g, the difference between the perceptions
#' @param omega The value of the inverse gamma shape parameter
#' @param chi The value of the inverse gamma scale parameter
#' @param thinning Setting thinning to i will store every i^th iteration. This may be required for very long runs.
#' @return A list of MCMC output
#' \itemize{
#'   \item f.matrix - A matrix containing the each iteration of f
#'   \item g.matrix - A matrix containing the each iteration of g
#'   \item alpha.sq - A matrix containing the iterations of alpha^2
#'   \item acceptance.rate - The acceptance rate for f and g
#'   \item time.taken - Time taken to run the MCMC algorithm in seconds
#' }
#'
#' @examples
#'
#' n.iter <- 10
#' delta <- 0.1
#' covariance.matrix <- list()
#' covariance.matrix$mean <- c(0, 0, 0)
#' covariance.matrix$decomp <- diag(3)
#' covariance.matrix$inv    <- diag(3)
#' men.comparisons <- data.frame("winner" = c(1, 3, 2, 2), "loser" = c(3, 1, 1, 3))
#' women.comparisons <- data.frame("winner" = c(1, 2, 1, 2), "loser" = c(3, 1, 3, 3))
#' men.win.matrix <- comparisons_to_matrix(3, men.comparisons) #win matrix for the male judges
#' women.win.matrix <- comparisons_to_matrix(3, women.comparisons) #win matrix for the female judges
#' f.initial <- c(0, 0, 0) #initial estimate for grand mean
#' g.initial <- c(0, 0, 0) #initial estimate for differences
#'
#' mcmc.output <- run_symmetric_mcmc(n.iter, delta, covariance.matrix, men.win.matrix,
#'     women.win.matrix, f.initial, g.initial)
#'
#' @export

run_symmetric_mcmc <- function(n.iter, delta, covariance.matrix, type1.win.matrix, type2.win.matrix, f.initial, g.initial, omega = 0.1, chi = 0.1, thinning = 1){

  if(n.iter > 1000000 & thinning == 1)
    warning("Large number of iterations and no thinning. Memory problems may occur.")

  f <- f.initial
  g <- g.initial
  n.objects <- length(f) #compute number of objects/areas from f
  loglike <- loglike_function(as.numeric(exp(f - g)), type1.win.matrix) + loglike_function(as.numeric(exp(g + f)), type2.win.matrix) #loglike value based on initial values

  #Initialise storage matrices
  counter <- 0
  f.matrix <- matrix(NA, n.iter/thinning, n.objects)
  g.matrix <- matrix(NA, n.iter/thinning, n.objects)
  alpha.matrix <- matrix(NA, n.iter/thinning, 2)

  #k.decomp.plain stores the decomposed covariance matrix with alpha = 1, k.decomp is for alpha varying
  k.decomp.plain <- covariance.matrix$decomp
  type1.k.decomp <- covariance.matrix$decomp
  type2.k.decomp <- covariance.matrix$decomp

  # MCMC Loop ---------------------------------------------------------------

  tic <- Sys.time()
  pb <- utils::txtProgressBar(min = 1, max = n.iter, style = 3)
  for(i in 1:n.iter){

  #Gibbs Step for alpha
  #Sample alpha values
  type1.alpha.sq.current     <- 1/stats::rgamma(1, omega + n.objects/2, 0.5*t(f)%*%covariance.matrix$inv%*%f + chi)
  type2.alpha.sq.current   <- 1/stats::rgamma(1, omega + n.objects/2, 0.5*t(g)%*%covariance.matrix$inv%*%g + chi)

  #recompute covariance matrices
  type1.k.decomp               <- sqrt(type1.alpha.sq.current)*covariance.matrix$decomp
  type2.k.decomp             <- sqrt(type2.alpha.sq.current)*covariance.matrix$decomp
  if(i %% thinning == 0)
    alpha.matrix[i/thinning, ]           <- c(type1.alpha.sq.current, type2.alpha.sq.current)

  #MH step for f and g
  f.prop <- sqrt(1 - delta^2)*f + delta*mvnorm_sd(covariance.matrix$mean, type1.k.decomp)
  g.prop <- sqrt(1 - delta^2)*g + delta*mvnorm_sd(covariance.matrix$mean, type2.k.decomp)

  loglike.prop <- loglike_function(as.numeric(exp(f.prop - g.prop)), type1.win.matrix) +
    loglike_function(as.numeric(exp(g.prop + f.prop)), type2.win.matrix)

  log.p.acc <- loglike.prop - loglike #underrelaxed means acceptance probability is likelihood ratio

  if(log(stats::runif(1)) < log.p.acc){
    #if accepted, update variables
    f <- f.prop
    g <- g.prop
    loglike <- loglike.prop
    counter <- counter + 1

  }

  #store variables
  if(i %% thinning == 0){
    f.matrix[i/thinning, ]   <- f
    g.matrix[i/thinning, ]   <- g
  }

  utils::setTxtProgressBar(pb, i) # update text progress bar after each iter
  }

  toc <- Sys.time()

  return(list("f" = f.matrix, "g" = g.matrix, "alpha.sq" = alpha.matrix, "acceptance.rate" = counter/n.iter, "time.taken" = toc - tic))



}




#' Run the BSBT MCMC algorithm with n types of individuals and asymmetric variance
#'
#' This function runs the MCMC algorithm with n types of individuals, for example male and female. The types must share the same covariance matrix and the win matrices are entered as a list. The first item in the list acts as the baseline group. This model has an asymmetric variance structure, as the variance of the baseline is always smaller.
#' For a model with thee types, f, g and h, the structure is as follows. The baseline is f, or the second type, g = f + d_1, and the third type, h = f + d_2. Here d_1 and d_2 are the discrepancy between each type and the baseline.
#'
#' @param n.iter The number of iterations to be run
#' @param delta The underrlaxed tuning parameter must be in (0, 1)
#' @param covariance.matrix The output from the covariance matrix function, which contains the decomposed and inverted covariance matrix. The variance hyperparameter must be set to 1.
#' @param win.matrices A list of n matrices where the ith matrix is the win matrix corresponding to only the ith level
#' @param estimates.initial A list of vectors where the ith vector is the initial estimate for the ith level effect
#' @param omega The value of the inverse gamma shape parameter
#' @param chi The value of the inverse gamma scale parameter
#' @return A list of MCMC output
#' \itemize{
#'   \item estimates - A list of matrices. Each matrix containing the iteration of the ith level
#'   \item alpha.sq - A matrix containing the iterations of alpha^2
#'   \item acceptance.rate - The acceptance rate for f and g
#'   \item time.taken - Time taken to run the MCMC algorithm in seconds
#' }
#'
#' @examples
#'
#' n.iter <- 10
#' delta <- 0.1
#' covariance.matrix <- list()
#' covariance.matrix$mean <- c(0, 0, 0)
#' covariance.matrix$decomp <- diag(3)
#' covariance.matrix$inv    <- diag(3)
#' men.comparisons <- data.frame("winner" = c(1, 3, 2, 2), "loser" = c(3, 1, 1, 3))
#' women.comparisons <- data.frame("winner" = c(1, 2, 1, 2), "loser" = c(3, 1, 3, 3))
#' men.win.matrix <- comparisons_to_matrix(3, men.comparisons)
#' women.win.matrix <- comparisons_to_matrix(3, women.comparisons)
#' f.initial <- c(0, 0, 0)
#' g.initial <- c(0, 0, 0)
#'
#' win.matrices <- list(men.win.matrix, women.win.matrix)
#' estimates.initial <- list(f.initial, g.initial)
#'
#' mcmc.output<- run_asymmetric_mcmc(n.iter, delta, covariance.matrix, win.matrices, estimates.initial)
#'
#' @export
run_asymmetric_mcmc <- function(n.iter, delta, covariance.matrix, win.matrices, estimates.initial, omega = 0.1, chi = 0.1){

  inv_gamma <- function(lambdas, k.inv, n.objects) {
    1/stats::rgamma(1, omega + n.objects/2, 0.5*t(lambdas)%*%k.inv%*%lambdas + chi)
  }

  # get model constants
  n.objects <- length(estimates.initial[[1]]) # number of areas
  n.levels <- length(estimates.initial) # 2 for male and female

  for(i in 1:n.levels)
    if(n.objects != length(estimates.initial[[i]]))
      stop("initial estimates have different lengths")

  estimates.current <- matrix(unlist(estimates.initial), ncol=n.objects, byrow=TRUE) # this is a matrix

  loglike <- loglike_function(as.numeric(exp(estimates.initial[[1]])), win.matrices[[1]]) +
    sum(mapply(loglike_function, split(exp(t(estimates.current[1, ] + t(estimates.current[2:n.levels, ]))), 1:(n.levels-1)), win.matrices[2:n.levels]))

  lambda.estimate.matrices <- rep(list(matrix(NA, n.iter, n.objects)), n.levels) # this is a list of matrices
  alpha.matrix <- matrix(NA, n.iter, n.levels) # this is a matrix, tracks the alphas on each iteration

  counter <- 0

  k.decomp.plain <- covariance.matrix$decomp

  # MCMC Loop ---------------------------------------------------------------

  tic <- Sys.time()
  for(i in 1:n.iter){

    # Gibbs Step for alpha
    alpha.sq.current <- apply(estimates.current, 1, inv_gamma, covariance.matrix$inv, n.objects) # this is a vector

    n.levels.k.decomp <- lapply(sqrt(alpha.sq.current), "*", k.decomp.plain) # This is a list
    alpha.matrix[i, ] <- alpha.sq.current

    # MH step for all the n.levels
    estimates.prop <- sqrt(1 - delta^2)*estimates.current +
      delta*t(mapply(mvnorm_sd, rep(list(covariance.matrix$mean), n.levels), n.levels.k.decomp)) # this is a matrix

    # calculate the proposed likelihood
    loglike.prop <- loglike_function(as.numeric(exp(estimates.prop[1, ])), win.matrices[[1]]) +
      sum(mapply(loglike_function, split(exp(t(estimates.prop[1, ] + t(estimates.prop[2:n.levels, ]))), 1:(n.levels-1)), win.matrices[2:n.levels]))

    log.p.acc <- loglike.prop - loglike

    if(log(stats::runif(1)) < log.p.acc){
      estimates.current <- estimates.prop
      loglike <- loglike.prop
      counter <- counter + 1
    }

    #lambda_estimate.matrices <- mapply(function(matrix, vector, row) matrix[row, ] <- vector, lambda_estimate.matrices, estimates.current, i)

    # store each estimate.current value
    for(j in 1:n.levels){
      lambda.estimate.matrices[[j]][i, ] <- estimates.current[j, ]
    }

  }

  toc <- Sys.time()

  return(list("estimates" = lambda.estimate.matrices, "alpha.sq" = alpha.matrix, "acceptance.rate" = counter/n.iter, "time.taken" = toc - tic))

}

