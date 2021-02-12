data("dar.adj.matrix",  package = "BSBT")


test_that("constrained adjacent covariance works", {
  expect_error(constrained_adjacency_covariance_function(dar.adj.matrix, type = "se", hyperparameters = c(1, 0.5),
                                                                   linear.combination = rep(1, 452),
                                                                   linear.constraint = 0), "Could not construct covariance matrix. Unrecognised covariance type")
  expect_error(constrained_adjacency_covariance_function(dar.adj.matrix, type = "sqexp", hyperparameters = c(1, 0.5, 1.5),
                                                        linear.combination = rep(1, 452),
                                                        linear.constraint = 0), "Insufficient hyperparameters. Squared Exponential requires 2 values.")
  expect_error(constrained_adjacency_covariance_function(dar.adj.matrix, type = "sqexp", hyperparameters = c(1, 0.5),
                                                        linear.combination = rep(1, 41),
                                                        linear.constraint = 0), "Could not constrain distirbution. Linear constraint dimensions does not match number of objects.")
  expect_error(constrained_adjacency_covariance_function(dar.adj.matrix, type = "matrix", hyperparameters = c(1, 0.5),
                                                         linear.combination = rep(1, 41),
                                                         linear.constraint = 0), "Insufficient hyperparameters. Matrix exponential requires 1 value.")
})

coords <- data.frame("x" = runif(10), "y" = runif(10))

test_that("constrained covariance works", {
  expect_error(constrained_covariance_function(coords, type = "se", hyperparameters = c(1, 0.5),
                                                        linear.combination = rep(1, 10),
                                                        linear.constraint = 0), "Could not construct covariance matrix. Unrecognised covariance type")
  expect_error(constrained_covariance_function(coords, type = "sqexp", hyperparameters = c(1, 0.5, 1.5),
                                                        linear.combination = rep(1, 10),
                                                        linear.constraint = 0), "Insufficient hyperparameters. Squared Exponential requires 2 values.")
  expect_error(constrained_covariance_function(coords, type = "sqexp", hyperparameters = c(1, 0.5),
                                                        linear.combination = rep(1, 41),
                                                        linear.constraint = 0), "Could not constrain distirbution. Linear constraint dimensions does not match number of objects.")
})

