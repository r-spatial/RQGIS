context("run_qgis")


test_that("Test, if QGIS-algorithms are working?", {
  
  testthat::skip_on_appveyor()
  testthat::skip_on_travis()
  testthat::skip_on_cran()
  
  library("testthat")
  library("RQGIS")
  library("sp")
  library("dplyr")
  coords_1 <- 
    matrix(data = c(0, 0, 1, 0, 1, 1, 0, 1, 0, 0),
           ncol = 2, byrow = TRUE)
  coords_2 <-
    matrix(data = c(-0.5, -0.5, 0.5, -0.5, 0.5, 0.5, 
                    -0.5, 0.5, -0.5, -0.5),
           ncol = 2, byrow = TRUE)
  # convert the coordinates into polygons
  poly_1 <- SpatialPolygons(list(
    Polygons(list(Polygon(coords_1)), 1))) %>%
    as(., "SpatialPolygonsDataFrame")
  poly_2 <- SpatialPolygons(list(Polygons(
    list(Polygon(coords_2)), 2))) %>%
    as(., "SpatialPolygonsDataFrame")
  # plot(poly_1, xlim = c(-2, 2), ylim = c(-2, 2))
  # plot(poly_2, add = TRUE)
  # bind the polygons together
  polys <- maptools::spRbind(poly_1, poly_2)
  
  # let's set the environment 
  if (Sys.info()["sysname"] == "Windows") {
  qgis_env <- set_env("C:/OSGeo4W64/")
  } else {
  qgis_env <- set_env()  
  }
  
  # Retrieve the function arguments in such a way that they can be easily
  # specified and serve as input for run_qgis
  params <- get_args_man(alg = "qgis:polygoncentroids", 
                         qgis_env = qgis_env)
  # Define function arguments
  # specify input layer
  params$INPUT_LAYER  <- polys  # please note that the input is an R object!!!
  # path to the output shapefile
  params$OUTPUT_LAYER <- file.path(tempdir(), "coords.shp")
  # not indicating any folder, will write the QGIS output to tempdir() in most
  # cases... though it is much safer to indicate a full output path!!)
  
  # finally, let QGIS do the work!!
  out <- run_qgis(alg = "qgis:polygoncentroids",
                  params = params,
                  # let's load the QGIS output directly into R!
                  load_output = params$OUTPUT_LAYER,
                  qgis_env = qgis_env)
  
  # check if the output is spatial object
  expect_is(out, "SpatialPointsDataFrame")
})


test_that("Test, if SAGA-algorithms are working?", {
  
  testthat::skip_on_appveyor()
  testthat::skip_on_travis()
  testthat::skip_on_cran()
  
  library("testthat")
  library("RQGIS")
  library("raster")
  
  # let's set the environment 
  if (Sys.info()["sysname"] == "Windows") {
    qgis_env <- set_env("C:/OSGeo4W64/")
  } else {
    qgis_env <- set_env()  
  }
  
  data("dem")
  params <- get_args_man(alg = "saga:slopeaspectcurvature", options = TRUE,
                         qgis_env = qgis_env)
  params$ELEVATION <- dem
  params$SLOPE <- file.path(tempdir(), "slope.asc")
  out <- run_qgis("saga:slopeaspectcurvature", params = params, 
                  load_output = params$SLOPE, qgis_env = qgis_env)
  # check if the output is a raster
  expect_is(out, "RasterLayer")
})



test_that("Test, if GRASS7-algorithms are working?", {
  
  testthat::skip_on_appveyor()
  testthat::skip_on_travis()
  testthat::skip_on_cran()
  
  library("testthat")
  library("RQGIS")
  library("raster")
  
  # let's set the environment 
  if (Sys.info()["sysname"] == "Windows") {
    qgis_env <- set_env("C:/OSGeo4W64/")
  } else {
    qgis_env <- set_env()  
  }
  # attach data
  data("dem")
  params <- get_args_man(alg = "grass7:r.slope.aspect", options = TRUE,
                         qgis_env = qgis_env)
  params$elevation <- dem
  params$slope <- file.path(tempdir(), "slope.asc")
  out <- run_qgis("grass7:r.slope.aspect", params = params, 
                  load_output = params$slope, qgis_env = qgis_env)
  # check if the output is a raster
  expect_is(out, "RasterLayer")
  })
