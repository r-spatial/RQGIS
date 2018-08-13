library("sp")
library("sf")
library("raster")

context("run_qgis")

# Check QGIS-----------------------------------------------

test_that("Test, if QGIS-algorithms are working?", {
  testthat::skip_on_cran()
  
  coords_1 <- matrix(
    data = c(0, 0, 1, 0, 1, 1, 0, 1, 0, 0),
    ncol = 2, byrow = TRUE
  )
  coords_2 <- coords_1 + 2
  # convert the coordinates into polygons
  polys <- list(
    Polygons(list(Polygon(coords_1)), 1),
    Polygons(list(Polygon(coords_2)), 2)
  )
  polys <- as(SpatialPolygons(polys), "SpatialPolygonsDataFrame")
  
  # Retrieve the function arguments in such a way that they can be easily
  # specified and serve as input for run_qgis
  alg <- "qgis:polygoncentroids"
  # finally, let QGIS do the work!!
  vec_1 <- run_qgis(
    alg, INPUT_LAYER = polys,
    OUTPUT_LAYER = file.path(tempdir(), "coords.shp"),
    show_output_paths = FALSE,
    # let's load the QGIS output directly into R!
    load_output = TRUE
  )
  
  # check if the output is an spatial object
  expect_is(vec_1, "sf")
  # now use ...-notation and sf as input
  vec_2 <- run_qgis(
    alg = "qgis:polygoncentroids",
    INPUT_LAYER = st_as_sf(polys),
    OUTPUT_LAYER = file.path(tempdir(), "coords.shp"),
    show_output_paths = FALSE, load_output = TRUE
  )
  # check if the output is spatial object
  expect_is(vec_2, "sf")
  
  # check geojson and gpkg
  vec_3 <- run_qgis(
    alg, INPUT_LAYER = polys,
    OUTPUT_LAYER = file.path(tempdir(), "coords.geojson"),
    show_output_paths = FALSE,
    # let's load the QGIS output directly into R!
    load_output = TRUE
  )
  expect_is(vec_3, "sf")
  vec_4 <- run_qgis(
    alg, INPUT_LAYER = polys,
    OUTPUT_LAYER = file.path(tempdir(), "coords.gpkg"),
    show_output_paths = FALSE,
    # let's load the QGIS output directly into R!
    load_output = TRUE
  )
  expect_is(vec_4, "sf")
})

# Check SAGA ----------------------------------------------

test_that("Test, if SAGA-algorithms are working?", {
  testthat::skip_on_appveyor()
  testthat::skip_on_cran()
  
  # attach data
  data("dem")
  params <- get_args_man(alg = "saga:sagawetnessindex", options = TRUE)
  params$DEM <- dem
  params$TWI <- file.path(tempdir(), "twi.sdat")
  saga_out_1 <- run_qgis(
    "saga:sagawetnessindex", params = params,
    show_output_paths = FALSE, load_output = TRUE
  )
  # check if the output is a raster
  expect_is(saga_out_1, "RasterLayer")
  # now use ...-notation
  saga_out_2 <- run_qgis(
    "saga:sagawetnessindex",
    DEM = dem,
    TWI = file.path(tempdir(), "twi.sdat"),
    show_output_paths = FALSE, load_output = TRUE
  )
  # check if the output is a raster
  expect_is(saga_out_2, "RasterLayer")
})


# Check GRASS 7------------------------------------------------------

test_that("Test, if GRASS7-algorithms are working?", {
  testthat::skip_on_cran()
  
  # attach data
  data("dem")
  params <- get_args_man(alg = "grass7:r.slope.aspect", options = TRUE)
  params$elevation <- dem
  params$slope <- file.path(tempdir(), "slope.tif")
  params$aspect <- file.path(tempdir(), "aspect.tif")
  grass_out_1 <- run_qgis(
    "grass7:r.slope.aspect", params = params,
    show_output_paths = FALSE, load_output = TRUE
  )
  # check if the output is a raster
  expect_is(grass_out_1[[1]], "RasterLayer")
  expect_is(grass_out_1[[2]], "RasterLayer")
  
  # now use ...-notation
  grass_out_2 <- run_qgis(
    "grass7:r.slope.aspect",
    elevation = dem,
    slope = file.path(tempdir(), "slope.tif"),
    show_output_paths = FALSE, load_output = TRUE
  )
  # check if the output is a raster
  expect_is(grass_out_2, "RasterLayer")
})
