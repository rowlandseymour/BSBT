test_that("simulate contests works", {
  expect_error(simulate_comparisons(10.5, c(1, 2), 1), 'The argument "n.contests" must be a positive integer.')
  expect_error(simulate_comparisons(-2, c(1, 2), 1), 'The argument "n.contests" must be a positive integer.')
  expect_error(simulate_comparisons(10, c(1, 2), -2), 'The argument "sigma.obs" must be a positive real.')
  expect_error(simulate_comparisons(NA, c(1, 2), 1), 'missing value where TRUE/FALSE needed')
  expect_error(simulate_comparisons(10, c(1, 2), NA), 'missing value where TRUE/FALSE needed')
})

test.comparisons <- data.frame(c(1, 2, 3), c(2, 1, 1))

test_that("comparisons to matrix works", {
  expect_equal(comparisons_to_matrix(3, test.comparisons), matrix(c(0, 1, 1, 1, 0, 0, 0, 0, 0), 3, 3, TRUE))
  expect_error(comparisons_to_matrix(2, test.comparisons), 'subscript out of bounds')
})
