library("testthat")
library("RQGIS")
library("sp")
library("raster")

context("prerun")


  test_that("qgis_session_info yields a list as output", {
    
    skip_on_appveyor()
    skip_on_travis()
    skip_on_cran()
    skip_on_os("linux")
    # skip_if_no_python()
    # skip_if_no_python can be found under: 
    # rstudio/reticulate/blob/master/tests/testthat/utils.R
    
    qgis_env <- set_env(dev = TRUE, new = TRUE)
    info <- qgis_session_info()
    # check if the output is a list of length 5
    expect_that(str(info), prints_text("List of 5"))
  })
  
  test_that("find_algorithms finds QGIS geoalgorithms", {
    
    skip_on_appveyor()
    skip_on_travis()
    skip_on_cran()
    skip_on_os("linux")
    # skip_if_no_python() 
    
    qgis_env <- set_env(dev = TRUE, new = TRUE)
    algs <- find_algorithms()
    # just retrieve QGIS geoalgorithms
    test <- grep("qgis:", algs, value = TRUE)
    # normally there are 101 QGIS geoalgorithms, so check if there are more than 
    # 50
    expect_that(length(test), is_more_than(50))
  })
  
  test_that("get_usage yields an output", {
    
    skip_on_appveyor()
    skip_on_travis()
    skip_on_cran()
    skip_on_os("linux")
    # skip_if_no_python()
    
    qgis_env <- set_env(dev = TRUE, new = TRUE)
    # get the usage of v.voronoi
    usage <- get_usage("grass7:v.voronoi", intern = TRUE)
    expect_match(paste(usage, collapse = "\n"), "ALGORITHM: v.voronoi")
  })
  
  test_that("get_options yields an output", {
    
    skip_on_appveyor()
    skip_on_travis()
    skip_on_cran()
    skip_on_os("linux")
    # skip_if_no_python()
    
    qgis_env <- set_env(dev = TRUE, new = TRUE) 
    # write a test for get_options
    opts <- get_options("grass7:r.slope.aspect", intern = TRUE)
    
    # check if the output is correct
    expect_match(paste(opts, collapse = "\n"), 
                 "format\\(Format for reporting the slope")
  })


# write a test for open_help
# open_help("grass7:r.slope.aspect", qgis_env = qgis_env)
# open_help(alg = "qgis:addfieldtoattributestable", qgis_env = qgis_env)

# get_args_man is already tested in test-run-qgis.R

