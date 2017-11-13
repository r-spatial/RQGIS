context("get_options")

test_that("get_options() yields correct output", {
  
  testthat::skip_on_appveyor()
  testthat::skip_on_cran()
  testthat::skip_on_travis()
  
  # testthat::skip("needs inspection locally")
  
  expect_output(get_options(alg = "saga:slopeaspectcurvature", intern = FALSE))
  
  expect_is(get_options(alg = "saga:slopeaspectcurvature", intern = TRUE), 
            "character")
  
})
