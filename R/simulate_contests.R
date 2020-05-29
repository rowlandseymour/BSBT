#' Simulate contests from the Bradley--Terry Model
#'
#' This function simulates pair-wise contests according to the Bradley--Terry model
#'
#'
#' @param n.contests The number of contests to be carried out
#' @param true.quality A vector with the level of deprivation in each area on the log scale.
#' @param sigma.obs Standard deviation for the noise to be added to the level of deprivation in each subward. If 0, no noise is used.
#' @return A list containing a data.frame with each par-wise contest and the outcome, and a win matrix where the i,j^th element is the number of times i beat j
#' @export
simulate.contests <- function(n.contests, true.quality, sigma.obs){


  if(n.contests%%1 != 0)
    stop('The argument "n.contests" must be a positive integer.')
  if(n.contests < 1)
    stop('The argument "n.contests" must be a positive integer.')

  contest.results <- data.frame(matrix(NA, nrow = n.contests, ncol = 3))
  names(contest.results) <- c("subward1", "subward2", "result")
  number.of.wins <- matrix(0, length(true.quality), length(true.quality))

  if(sigma.obs > 0){
    for(j in 1:n.contests){

      #Generate IDs of subwards
      subwards <- sample(1:length(true.quality), 2, FALSE)  #choose two subwards to compare
      log.lambda.1 <- true.quality[subwards[1]] + rnorm(1, 0, sigma.obs)  #lambda_i* = lambda_i + N(0, sigma.obs^2)
      log.lambda.2 <- true.quality[subwards[2]] + rnorm(1, 0, sigma.obs)  #lambda_i* = lambda_i + N(0, sigma.obs^2)


      #Simulate Contest
      win.prob <- exp(log.lambda.1)/(exp(log.lambda.1) + exp(log.lambda.2)) #compute probability i > j
      result <- rbinom(1, 1, win.prob)                                      #simulate from bernoulli dist

      #Record Results
      contest.results[j, ] <- c(subwards, result)                           #record result
      if(result == 1)
        number.of.wins[subwards[1], subwards[2]] <- number.of.wins[subwards[1], subwards[2]] + 1
      else
        number.of.wins[subwards[2], subwards[1]] <- number.of.wins[subwards[2], subwards[1]] + 1

    }
  } else if (sigma.obs == 0){
    #If no noise, simulate from true quality
    for(j in 1:n.contests){

      #Generate IDs of subwards
      subwards <- sample(1:length(true.quality), 2, FALSE)
      log.lambda.1 <- true.quality[subwards[1]]
      log.lambda.2 <- true.quality[subwards[2]]
      #Simulate Contest
      win.prob <- exp(log.lambda.1)/(exp(log.lambda.1) + exp(log.lambda.2))
      result <- rbinom(1, 1, win.prob)

      #Record Results
      contest.results[j, ] <- c(subwards, result)
      if(result == 1)
        number.of.wins[subwards[1], subwards[2]] <- number.of.wins[subwards[1], subwards[2]] + 1
      else
        number.of.wins[subwards[2], subwards[1]] <- number.of.wins[subwards[2], subwards[1]] + 1

    }
  } else {
    stop('The argument "sigma.obs" must be a positive real.')
  }



  results <- data.frame("subward1" = as.factor(contest.results$subward1), "subward2" = as.factor(contest.results$subward2),
                        result = contest.results$result)

  return(list("results" = results, "win.matrix" = number.of.wins))
}
