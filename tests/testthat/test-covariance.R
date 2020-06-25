data("dar.shapefiles",  package = "BTUN")
adj.matrix <- surveillance::poly2adjmat(dar.shapefiles$geometry)

test_that("registered adjacent covariance works", {
  expect_error(registered_adjacency_covariance_function(adj.matrix, type = "se", hyperparameters = c(1, 0.5),
                                                                   linear.combination = rep(1, 452),
                                                                   linear.constraint = 0, tol = 1e-5), "Could not construct covariance matrix. Unrecognised covariance type")
  expect_error(registered_adjacency_covariance_function(adj.matrix, type = "sqexp", hyperparameters = c(1, 0.5, 1.5),
                                                        linear.combination = rep(1, 452),
                                                        linear.constraint = 0, tol = 1e-5), "Insufficient hyperparameters. Squared Exponential requires 2 values.")
  expect_error(registered_adjacency_covariance_function(adj.matrix, type = "sqexp", hyperparameters = c(1, 0.5),
                                                        linear.combination = rep(1, 41),
                                                        linear.constraint = 0, tol = 1e-5), "Could not register distirbution. Linear constraint dimensions does not match number of objects.")
  expect_error(registered_adjacency_covariance_function(adj.matrix, type = "sqexp", hyperparameters = c(1, 0.5),
                                                        linear.combination = rep(1, 452),
                                                        linear.constraint = 0, tol = NA), "the leading minor of order 1 is not positive definite")
})

coords <- data.frame("x" = runif(10), "y" = runif(10))
vertices <- data.frame("x" = c(0, 0, 1, 1), "y" = c(0, 1, 1, 0))

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


test_that("registered network covariance works", {

  expect_error(registered_network_covariance_function(coords, vertices, type = "se", hyperparameters = c(1, 0.5),
                                                        linear.combination = rep(1, 10),
                                                        linear.constraint = 0, tol = 1e-5), "Could not construct covariance matrix. Unrecognised covariance type")
  expect_error(registered_network_covariance_function(coords, vertices,type = "sqexp", hyperparameters = c(1, 0.5, 1.5),
                                                        linear.combination = rep(1, 10),
                                                        linear.constraint = 0, tol = 1e-5), "Insufficient hyperparameters. Squared Exponential requires 2 values.")
  expect_error(registered_network_covariance_function(coords, vertices, type = "sqexp", hyperparameters = c(1, 0.5),
                                                        linear.combination = rep(1, 41),
                                                        linear.constraint = 0, tol = 1e-5), "Could not register distirbution. Linear constraint dimensions does not match number of objects.")
  expect_error(registered_network_covariance_function(coords, vertices, type = "sqexp", hyperparameters = c(1, 0.5),
                                                        linear.combination = rep(1, 10),
                                                        linear.constraint = 0, tol = NA), "the leading minor of order 1 is not positive definite")
})
