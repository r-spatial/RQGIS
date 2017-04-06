library("testthat")
library("RQGIS")
library("sp")
library("raster")

context("prerun")

test_that("qgis_session_info yields a list as output", {
  
  testthat::skip_on_appveyor()
  testthat::skip_on_travis()
  testthat::skip_on_cran()
  # skip_if_no_python()
  # skip_if_no_python can be found under: 
  # rstudio/reticulate/blob/master/tests/testthat/utils.R
  
  qgis_env <- set_env()
  info <- qgis_session_info()
  # check if the output is a list of length 5
  expect_that(str(info), prints_text("List of 5"))
  })

test_that("find_algorithms finds QGIS geoalgorithms", {
  
  testthat::skip_on_appveyor()
  testthat::skip_on_travis()
  testthat::skip_on_cran()
  # skip_if_no_python() 
  
  qgis_env <- set_env()
  algs <- find_algorithms()
  # just retrieve QGIS geoalgorithms
  test <- grep("qgis:", algs, value = TRUE)
  # normally there are 101 QGIS geoalgorithms, so check if there are more than 
  # 50
  expect_that(length(test), is_more_than(50))
  })

test_that("get_usage yields an output", {
  
  testthat::skip_on_appveyor()
  testthat::skip_on_travis()
  testthat::skip_on_cran()
  # skip_if_no_python()
  
  qgis_env <- set_env()
  # get the usage of v.voronoi
  usage <- get_usage("grass7:v.voronoi")
  expect_match(paste(usage, collapse = "\n"), "ALGORITHM: v.voronoi")
  })

test_that("get_options yields an output", {
  
  testthat::skip_on_appveyor()
  testthat::skip_on_travis()
  testthat::skip_on_cran()
  # skip_if_no_python()
  
  qgis_env <- set_env() 
  # write a test for get_options
  opts <- get_options("grass7:r.slope.aspect")
  # check if the output is correct
  expect_match(paste(opts, collapse = "\n"), 
              "format\\(Format for reporting the slope")
  })


#********************************************************************
# CHECKING developer QGIS release (Windows)--------------------------
#********************************************************************

# now check the developer QGIS release (at least for Windows)
if (Sys.info()["sysname"] == "Windows") {
  test_that("qgis_session_info yields a list as output", {
    
    testthat::skip_on_appveyor()
    testthat::skip_on_travis()
    testthat::skip_on_cran()
    # skip_if_no_python()
    # skip_if_no_python can be found under: 
    # rstudio/reticulate/blob/master/tests/testthat/utils.R
    
    qgis_env <- set_env(ltr = FALSE)
    info <- qgis_session_info()
    # check if the output is a list of length 5
    expect_that(str(info), prints_text("List of 5"))
    })
  
  test_that("find_algorithms finds QGIS geoalgorithms", {
    
    testthat::skip_on_appveyor()
    testthat::skip_on_travis()
    testthat::skip_on_cran()
    # skip_if_no_python() 
    
    qgis_env <- set_env(ltr = FALSE)
    algs <- find_algorithms()
    # just retrieve QGIS geoalgorithms
    test <- grep("qgis:", algs, value = TRUE)
    # normally there are 101 QGIS geoalgorithms, so check if there are more than 
    # 50
    expect_that(length(test), is_more_than(50))
  })
  
  test_that("get_usage yields an output", {
    
    testthat::skip_on_appveyor()
    testthat::skip_on_travis()
    testthat::skip_on_cran()
    # skip_if_no_python()
    
    qgis_env <- set_env(ltr = FALSE)
    # get the usage of v.voronoi
    usage <- get_usage("grass7:v.voronoi")
    expect_match(paste(usage, collapse = "\n"), "ALGORITHM: v.voronoi")
  })
  
  test_that("get_options yields an output", {
    
    testthat::skip_on_appveyor()
    testthat::skip_on_travis()
    testthat::skip_on_cran()
    # skip_if_no_python()
    
    qgis_env <- set_env(ltr = FALSE) 
    # write a test for get_options
    opts <- get_options("grass7:r.slope.aspect")

    # check if the output is correct
    expect_match(paste(opts, collapse = "\n"), 
                 "format\\(Format for reporting the slope")
  })
}


# write a test for open_help
# open_help("grass7:r.slope.aspect", qgis_env = qgis_env)
# open_help(alg = "qgis:addfieldtoattributestable", qgis_env = qgis_env)

# get_args_man is already tested in test-run-qgis.R

  