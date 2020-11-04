#' Simulate contests from the Bradley--Terry Model
#'
#' This function simulates pair-wise contests according to the Bradley--Terry model. It require the true quality of the areas and the number of comparisons to be carried out. It can also include some judge noise or error.
#' When including noise, each time a judge carries out a comparisons, we assume they use the true quality with some zero-mean normal noise added. The standard deviation must be specified.
#'
#' @param n.contests The number of contests to be carried out
#' @param true.quality A vector with the level of deprivation in each area on the log scale.
#' @param sigma.obs Standard deviation for the noise to be added to the level of deprivation in each area. If 0, no noise is used.
#' @return A list containing a data.frame with each pair-wise contest, the outcome (a 1 for a win, a 0 for a loss),
#'  and a win matrix where the i,j^th element is the number of times i beat j
#'
#' @examples
#'
#' example.deprivation <- -2:2 #True level of deprivation in each area
#  generate comparisons with no judge noise
#' example.comparisons <- simulate_comparisons(10, example.deprivation, 0)
#' #generate comparisons with judge noise.
#' example.comparisons <- simulate_comparisons(10, example.deprivation, 0.1)
#' @export
simulate_comparisons <- function(n.contests, true.quality, sigma.obs){


  if(n.contests%%1 != 0)
    stop('The argument "n.contests" must be a positive integer.')
  if(n.contests < 1)
    stop('The argument "n.contests" must be a positive integer.')

  contest.results <- data.frame(matrix(NA, nrow = n.contests, ncol = 3))
  names(contest.results) <- c("subward1", "subward2", "result")
  number.of.wins <- matrix(0, length(true.quality), length(true.quality))

  if(sigma.obs > 0){
    for(j in 1:n.contests){

      #Generate IDs of area
      area <- sample(1:length(true.quality), 2, FALSE)  #choose two area to compare
      log.lambda.1 <- true.quality[area[1]] + stats::rnorm(1, 0, sigma.obs)  #lambda_i* = lambda_i + N(0, sigma.obs^2)
      log.lambda.2 <- true.quality[area[2]] + stats::rnorm(1, 0, sigma.obs)  #lambda_i* = lambda_i + N(0, sigma.obs^2)


      #Simulate Contest
      win.prob <- exp(log.lambda.1)/(exp(log.lambda.1) + exp(log.lambda.2)) #compute probability i > j
      result <- stats::rbinom(1, 1, win.prob)                                      #simulate from bernoulli dist

      #Record Results
      contest.results[j, ] <- c(area, result)                           #record result
      if(result == 1)
        number.of.wins[area[1], area[2]] <- number.of.wins[area[1], area[2]] + 1
      else
        number.of.wins[area[2], area[1]] <- number.of.wins[area[2], area[1]] + 1

    }
  } else if (sigma.obs == 0){
    #If no noise, simulate from true quality
    for(j in 1:n.contests){

      #Generate IDs of area
      area <- sample(1:length(true.quality), 2, FALSE)
      log.lambda.1 <- true.quality[area[1]]
      log.lambda.2 <- true.quality[area[2]]
      #Simulate Contest
      win.prob <- exp(log.lambda.1)/(exp(log.lambda.1) + exp(log.lambda.2))
      result <- stats::rbinom(1, 1, win.prob)

      #Record Results
      contest.results[j, ] <- c(area, result)
      if(result == 1)
        number.of.wins[area[1], area[2]] <- number.of.wins[area[1], area[2]] + 1
      else
        number.of.wins[area[2], area[1]] <- number.of.wins[area[2], area[1]] + 1

    }
  } else {
    stop('The argument "sigma.obs" must be a positive real.')
  }



  results <- data.frame("subward1" = as.factor(contest.results$subward1), "subward2" = as.factor(contest.results$subward2),
                        result = contest.results$result)

  return(list("results" = results, "win.matrix" = number.of.wins))
}

#' Construct Win Matrix from Comparisons
#'
#' This function constructs a win matrix from a data frame of comparisons. It is needed for the MCMC functions.
#'
#' @param n.areas The number of areas in the study.
#' @param comparisons An N x 2 data frame, where N is the number of comparisons. Each row should correspond to a judgment. The first column is the winning area, the second column is the more losing area. The areas should be labeled from 1 to n.areas.
#' @return A matrix where the {i, j}^th element is the number of times area i beat area j.
#'
#' @examples
#'
#' #Generate some sample comparisons
#' comparisons <- data.frame("winner" = c(1, 3, 2, 2), "loser" = c(3, 1, 1, 3))
#'
#' #Create matrix from comparisons
#' win.matrix <- comparisons_to_matrix(3, comparisons)
#'
#' @export
comparisons_to_matrix <- function(n.areas, comparisons){

  win.matrix <- matrix(0, n.areas, n.areas) #construct empty matrix

  for(j in 1:dim(comparisons)[1]) #for each comparisons, enter outcome into win matrix
    win.matrix[comparisons[j, 2], comparisons[j, 1]] <- win.matrix[comparisons[j, 2], comparisons[j, 1]] + 1


  return(win.matrix)
}



