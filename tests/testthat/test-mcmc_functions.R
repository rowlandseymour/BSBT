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
  expect_equal(as.numeric(mvnorm_chol(c(NA, NA), matrix(c(1, 2, 3, 4), 2, 2))), c(NA_integer_, NA_integer_))
  expect_error(mvnorm_chol(c(1, 2, 3), matrix(c(1, 2, 3, 4), 2, 2)), "non-conformable arguments")
})

