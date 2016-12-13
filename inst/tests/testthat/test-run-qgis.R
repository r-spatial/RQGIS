context("run_qgis")

test_that("test GRASS7: is algorithm working?", {
  
  library(testthat)
  library("RQGIS")
  library("raster")
  data("dem")
  params <- get_args_man(alg = "grass7:r.slope.aspect", options = TRUE)
  params$elevation <- dem
  params$slope <- file.path(tempdir(), "slope.asc")
  out <- run_qgis("grass7:r.slope.aspect", params = params, 
                  load_output = params$slope)
  plot(out)
  
  expect_equal(class(out)[1], "RasterLayer")
})
