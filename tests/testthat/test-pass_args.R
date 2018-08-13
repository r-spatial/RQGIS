library("raster")
library("sf")

context("pass_args")

test_that("Test, if pass_args works correctly?", {
  testthat::skip_on_cran()
  
  alg <- "grass7:r.slope.aspect"
  params <- pass_args(alg, elevation = dem, format = "degrees")
  # overall checks
  expect_type(params, "list")
  expect_length(params, 17)
  # check if input raster was saved to a elevation
  expect_true(file.exists(params$elevation))
  # check if GRASS_REGION_PARAMETER was constructed from input dem
  expect_identical(
    params$GRASS_REGION_PARAMETER,
    paste0(
      "794599.107614635,798208.557614635,8931774.87460253,",
      "8935384.32460253"
    )
  )
  # check verbal input conversion
  expect_identical(as.character(params$format), "0")
  
  # check if a parameter was wrongly specified
  params <- try(pass_args(alg, elev = dem), silent = TRUE)
  expect_s3_class(params, "try-error")
  # check what happens if an argument was wrongly specified
  params <- try(pass_args(alg, elevation = dem, format = 122), silent = TRUE)
  expect_s3_class(params, "try-error")
})

test_that("Test, if multiple input works with pass_args?", {
  testthat::skip_on_cran()
  
  r <- raster(ncol = 100, nrow = 100)
  r1 <- crop(r, extent(-10, 11, -10, 11))
  r2 <- crop(r, extent(0, 20, 0, 20))
  r3 <- crop(r, extent(9, 30, 9, 30))
  r1[] <- 1:ncell(r1)
  r2[] <- 1:ncell(r2)
  r3[] <- 1:ncell(r3)
  
  alg <- "grass7:r.patch"
  # params <- pass_args(alg, input = list(r1, r2, r3))  # must also work...
  # perfect, it does
  params <- pass_args(alg, input = list(r1, r2, r3), output = "name.tif")
  # now check if multiple raster input was converted to a string containing the
  # paths to the rasters
  expect_type(params$input, "character")
  # check if the correct GRP was extracted
  expect_identical(params$GRASS_REGION_PARAMETER, "-10.8,28.8,-10.8,30.6")
  
  # check if extent is also working for extent objects other than GRP
  # only works for >= SAGA 2.3, hence skip as long we are using QGIS 2.14
  # alg <- "saga:resampling"
  # params <- pass_args(alg, INPUT = dem)
  # expect_identical(
  #   params$OUTPUT_EXTENT, 
  #   "794599.107614635,798208.557614635,8931774.87460253,8935384.32460253")
  
  # also write a test for shapefiles -> find a function that takes multiple
  # shapefiles as input (ParameterMultipleInput), e.g., grass7:v.patch
  
  coords_1 <- matrix(
    data = c(0, 0, 1, 0, 1, 1, 0, 1, 0, 0),
    ncol = 2, byrow = TRUE
  )
  coords_2 <- coords_1 + 2
  # convert coordinates into sf-objects
  poly_1 <- st_sfc(st_polygon(list(coords_1)))
  # st_as_sf(poly_1)  # will not work, we need at least one column
  poly_1 <- st_sf(r = 5, poly_1)
  poly_2 <- st_sfc(st_polygon(list(coords_2)))
  poly_2 <- st_sf(r = 5, poly_2)
  # check if multiple sf-object input was converted into a string containing the
  # paths to the shapefiles
  params <- pass_args("grass7:v.patch", input = list(poly_1, poly_2))
  expect_type(params$input, "character")
  # check if the correct GRP was extracted
  expect_identical(params$GRASS_REGION_PARAMETER, "0,3,0,3")
})
