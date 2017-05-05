library("sp")
library("sf")
library("raster")

context("run_qgis")

# Check QGIS-----------------------------------------------

test_that("Test, if QGIS-algorithms are working?", {
  
  testthat::skip_on_appveyor()
  # testthat::skip_on_travis()
  testthat::skip_on_cran()
  
  coords_1 <- matrix(data = c(0, 0, 1, 0, 1, 1, 0, 1, 0, 0),
                     ncol = 2, byrow = TRUE)
  coords_2 <- coords_1 + 2
  # convert the coordinates into polygons
  polys <- list(Polygons(list(Polygon(coords_1)), 1), 
                  Polygons(list(Polygon(coords_2)), 2)) 
  polys <- as(SpatialPolygons(polys), "SpatialPolygonsDataFrame")
  
  # Retrieve the function arguments in such a way that they can be easily
  # specified and serve as input for run_qgis
  alg <- "qgis:polygoncentroids"
  params <- get_args_man(alg)
  # Define function arguments
  # specify input layer
  params$INPUT_LAYER <- polys  # please note that the input is an R object!!!
  # path to the output shapefile
  params$OUTPUT_LAYER <- file.path(tempdir(), "coords.shp")

  # finally, let QGIS do the work!!
  out <- run_qgis(alg, params = params,
                  # let's load the QGIS output directly into R!
                  load_output = TRUE)
  
  # check if the output is spatial object
  expect_is(out, "sf")
  # now use ...-notation and sf as input
  out <- run_qgis(alg = "qgis:polygoncentroids",
                  INPUT_LAYER = st_as_sf(polys),
                  OUTPUT_LAYER = "coords.shp",
                  load_output = TRUE)
  # check if the output is spatial object
  expect_is(out, "sf")
  })

# Check SAGA ----------------------------------------------

test_that("Test, if SAGA-algorithms are working?", {
  
  testthat::skip_on_appveyor()
  # testthat::skip_on_travis()
  testthat::skip_on_cran()
  
  # attach data
  data("dem")
  params <- get_args_man(alg = "saga:slopeaspectcurvature", options = TRUE)
  params$ELEVATION <- dem
  params$SLOPE <- file.path(tempdir(), "slope.asc")
  out <- run_qgis("saga:slopeaspectcurvature", params = params, 
                  load_output = TRUE)
  # check if the output is a raster
  expect_is(out, "RasterLayer")
  # now use ...-notation
  out <- run_qgis("saga:slopeaspectcurvature", 
                  ELEVATION = dem,
                  SLOPE = "slope.asc",
                  load_output = TRUE)
  # check if the output is a raster
  expect_is(out, "RasterLayer")
  })


# Check GRASS 7------------------------------------------------------

test_that("Test, if GRASS7-algorithms are working?", {
  
  testthat::skip_on_appveyor()
  #testthat::skip_on_travis()
  testthat::skip_on_cran()
  
  # attach data
  data("dem")
  params <- get_args_man(alg = "grass7:r.slope.aspect", options = TRUE)
  params$elevation <- dem
  params$slope <- file.path(tempdir(), "slope.asc")
  params$aspect <- file.path(tempdir(), "aspect.asc")
  out <- run_qgis("grass7:r.slope.aspect", params = params, 
                  load_output = TRUE)
  # check if the output is a raster
  expect_is(out[[1]], "RasterLayer")
  expect_is(out[[2]], "RasterLayer")

  # now use ...-notation
  out <- run_qgis("grass7:r.slope.aspect", 
                  elevation = dem,
                  slope = "slope.asc",
                  load_output = TRUE)
  # check if the output is a raster
  expect_is(out, "RasterLayer")
  })




