data("dar.adj.matrix",  package = "BTUN")


test_that("registered adjacent covariance works", {
  expect_error(registered_adjacency_covariance_function(dar.adj.matrix, type = "se", hyperparameters = c(1, 0.5),
                                                                   linear.combination = rep(1, 452),
                                                                   linear.constraint = 0, tol = 1e-5), "Could not construct covariance matrix. Unrecognised covariance type")
  expect_error(registered_adjacency_covariance_function(dar.adj.matrix, type = "sqexp", hyperparameters = c(1, 0.5, 1.5),
                                                        linear.combination = rep(1, 452),
                                                        linear.constraint = 0, tol = 1e-5), "Insufficient hyperparameters. Squared Exponential requires 2 values.")
  expect_error(registered_adjacency_covariance_function(dar.adj.matrix, type = "sqexp", hyperparameters = c(1, 0.5),
                                                        linear.combination = rep(1, 41),
                                                        linear.constraint = 0, tol = 1e-5), "Could not register distirbution. Linear constraint dimensions does not match number of objects.")
  expect_error(registered_adjacency_covariance_function(dar.adj.matrix, type = "sqexp", hyperparameters = c(1, 0.5),
                                                        linear.combination = rep(1, 452),
                                                        linear.constraint = 0, tol = NA), "the leading minor of order 1 is not positive definite")
})

coords <- data.frame("x" = runif(10), "y" = runif(10))

test_that("registered covariance works", {
  expect_error(registered_covariance_function(coords, type = "se", hyperparameters = c(1, 0.5),
                                                        linear.combination = rep(1, 10),
                                                        linear.constraint = 0, tol = 1e-5), "Could not construct covariance matrix. Unrecognised covariance type")
  expect_error(registered_covariance_function(coords, type = "sqexp", hyperparameters = c(1, 0.5, 1.5),
                                                        linear.combination = rep(1, 10),
                                                        linear.constraint = 0, tol = 1e-5), "Insufficient hyperparameters. Squared Exponential requires 2 values.")
  expect_error(registered_covariance_function(coords, type = "sqexp", hyperparameters = c(1, 0.5),
                                                        linear.combination = rep(1, 41),
                                                        linear.constraint = 0, tol = 1e-5), "Could not register distirbution. Linear constraint dimensions does not match number of objects.")
  expect_error(registered_covariance_function(coords, type = "sqexp", hyperparameters = c(1, 0.5),
                                                        linear.combination = rep(1, 10),
                                                        linear.constraint = 0, tol = NA), "the leading minor of order 1 is not positive definite")
})

