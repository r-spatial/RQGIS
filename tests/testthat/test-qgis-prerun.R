context("prerun")

test_that("qgis_session_info yields a list as output", {
  
  testthat::skip_on_appveyor()
  testthat::skip_on_travis()
  testthat::skip_on_cran()
  # skip_if_no_python()
  # skip_if_no_python can be found under: 
  # rstudio/reticulate/blob/master/tests/testthat/utils.R
  
  info <- qgis_session_info()
  # check if the output is a list of length 5
  expect_that(str(info), prints_text("List of 5"))
  })

test_that("find_algorithms finds QGIS geoalgorithms", {
  
  testthat::skip_on_appveyor()
  testthat::skip_on_travis()
  testthat::skip_on_cran()
  # skip_if_no_python() 

  algs <- find_algorithms()
  # just retrieve QGIS geoalgorithms
  test <- grep("qgis:", algs, value = TRUE)
  # normally there are 101 QGIS geoalgorithms, so check if there are more than 
  # 50
  expect_that(length(test), is_more_than(50))
  })


