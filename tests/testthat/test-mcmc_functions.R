test_that("Quality Ratio works", {
  expect_equal(quality_ratio(exp(0), exp(1)), -log(1+exp(1)))
  expect_equal(quality_ratio(exp(0), NA), NA_integer_)
})

test_that("Loglikelihood works", {
  expect_equal(loglike_function(c(exp(0), exp(0)), matrix(c(0, 2, 1, 0), 2, 2)), -3*log(2))
  expect_equal(loglike_function(c(exp(0), NA), matrix(c(0, 2, 1, 0), 2, 2)), NA_integer_)
  expect_error(loglike_function(c(exp(0)), matrix(c(0, 2, 1, 0), 2, 2)), "non-conformable arrays")
  expect_error(loglike_function(c(exp(0), exp(0)), matrix(c(0, 2, 1, 1, 0, 0), 2, 3)), "non-conformable arrays")
})

test_that("Multivariate Normal Sampler works", {
  expect_equal(as.numeric(mvnorm_sd(c(NA, NA), matrix(c(1, 2, 3, 4), 2, 2))), c(NA_integer_, NA_integer_))
  expect_error(mvnorm_sd(c(1, 2, 3), matrix(c(1, 2, 3, 4), 2, 2)), "non-conformable arguments")
})


test_that("standard MCMC function works", {
  data("dar.adj.matrix")
  k <- constrained_adjacency_covariance_function(dar.adj.matrix, type = "sqexp", hyperparameters = c(1, 0.5), linear.combination = rep(1, 452), linear.constraint = 0)
  win.matrix <- matrix(rbinom(452*452, 10, 0.5), 452, 452)
  expect_error(run_mcmc(10, 0.1, k, win.matrix, rep(1, 451), alpha = FALSE), "non-conformable arrays")
  expect_error(run_mcmc(-1, 0.1, k, win.matrix, rep(1, 452), alpha = FALSE), "invalid")
}
)



test_that("gender MCMC function works", {
  data("dar.adj.matrix")
  k <- constrained_adjacency_covariance_function(dar.adj.matrix, type = "sqexp", hyperparameters = c(1, 0.5), linear.combination = rep(1, 452), linear.constraint = 0)
  male.win.matrix <- matrix(rbinom(452*452, 10, 0.5), 452, 452)
  female.win.matrix <- matrix(rbinom(452*452, 10, 0.5), 452, 452)
  expect_error(run_gender_mcmc(10, 0.1, k, male.win.matrix[1:451, ], female.win.matrix, rep(1, 452), rep(1, 452)), "non-conformable arrays")
  expect_error(run_gender_mcmc(-1, 0.1, k, male.win.matrix, female.win.matrix, rep(1, 452), rep(1, 452)), "invalid")
}
)

test_that("ordered MCMC function works", {
  data("dar.adj.matrix")
  S <- list()
  S[[1]] <- rep(1, 2, 1, 10)
  S[[2]] <- rep(3, 4, 4, 10)
  k <- constrained_adjacency_covariance_function(dar.adj.matrix, type = "sqexp", hyperparameters = c(1, 0.5), linear.combination = rep(1, 452), linear.constraint = 0)
  win.matrix <- matrix(rbinom(452*452, 10, 0.5), 452, 452)
  expect_error(run_mcmc_with_ordering(10, 0.1, k, win.matrix, rep(1, 451), S, alpha = FALSE), "non-conformable arrays")
  expect_error(run_mcmc_with_ordering(-1, 0.1, k, win.matrix, rep(1, 452), S, alpha = FALSE), "invalid")
  S <- c(0, 1)
  expect_error(run_mcmc_with_ordering(10, 0.1, k, win.matrix, rep(1, 452), S, alpha = FALSE), "S must be a list")
}
)


test_that("asymmetric MCMC function works", {
  data("dar.adj.matrix")
  k <- constrained_adjacency_covariance_function(dar.adj.matrix, type = "sqexp", hyperparameters = c(1, 0.5), linear.combination = rep(1, 452), linear.constraint = 0)
  male.win.matrix <- matrix(rbinom(452*452, 10, 0.5), 452, 452)
  female.win.matrix <- matrix(rbinom(452*452, 10, 0.5), 452, 452)
  win.matrices <- list(male.win.matrix, female.win.matrix)
  initial.estimates <- list(rep(0, 451), rep(0, 452))
  expect_error(run_asymmetric_mcmc(10, 0.1, k, win.matrices, initial.estimates), "initial estimates have different lengths")
  initial.estimates <- list(rep(0, 452), rep(0, 452))
  expect_error(run_asymmetric_mcmc(-1, 0.1, k, win.matrices, initial.estimates), "invalid")
}
)






