context("get_usage")

test_that("get_usage() yields correct output", {
  
  expect_output(get_usage(alg = "qgis:polygoncentroids", intern = FALSE))
  
  expect_is(get_usage(alg = "qgis:polygoncentroids", intern = TRUE), 
            "character")
  
})