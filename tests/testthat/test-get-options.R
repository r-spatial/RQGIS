library("RQGIS")
library("testthat")

context("get_options")

test_that("get_options() yields correct output", {
  
  testthat::skip_on_appveyor()
  testthat::skip("needs inspection locally")
  
  expect_output(get_options(alg = "qgis:polygoncentroids", intern = FALSE))
  
  expect_is(get_options(alg = "qgis:polygoncentroids", intern = TRUE), "character")
  
})