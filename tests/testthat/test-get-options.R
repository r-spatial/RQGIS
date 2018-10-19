context("get_options")

test_that("get_options() yields correct output", {
  testthat::skip_on_cran()
  
  expect_output(get_options(alg = "saga:slopeaspectcurvature", intern = FALSE))
  
  expect_is(
    get_options(alg = "saga:slopeaspectcurvature", intern = TRUE),
    "character"
  )
})
