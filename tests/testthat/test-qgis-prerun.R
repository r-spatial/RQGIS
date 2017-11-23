context("prerun")

test_that("qgis_session_info yields a list as output", {
  
  skip_on_appveyor()
  skip_on_cran()
  # testthat::skip_on_travis()
  
  info <- qgis_session_info()
  
  # check if the output is a list of length 6
  expect_length(info, 6)
  })

test_that("find_algorithms finds QGIS geoalgorithms", {
  
  skip_on_appveyor()
  skip_on_cran()
  # testthat::skip_on_travis()

  algs <- find_algorithms()
  # just retrieve QGIS geoalgorithms
  test <- grep("qgis:", algs, value = TRUE)
  # normally there are 101 QGIS geoalgorithms, so check if there are more than 
  # 50
  expect_gt(length(test), 50)
  })
