context("pass_args")

test_that("Test, if QGIS-algorithms are working?", {
  
  testthat::skip_on_appveyor()
  # testthat::skip_on_travis()
  testthat::skip_on_cran()
  
  alg <- "grass7:r.slope.aspect"
  params <- pass_args(alg, elevation = dem, format = "degrees")
  # overall checks
  expect_type(params, "list")
  expect_length(params, 17)
  # check if input raster was saved to a elevation
  expect_true(file.exists(params$elevation))
  # check if GRASS_REGION_PARAMETER was constructed from input dem
  expect_identical(params$GRASS_REGION_PARAMETER, 
                   paste0("794599.107614635,798208.557614635,8931774.87460253,", 
                          "8935384.32460253"))
  # check verbal input conversion
  expect_identical(as.character(params$format), "0")
  
  # check if a parameter was wrongly specified
  params <- try(pass_args(alg, elev = dem), silent = TRUE)
  expect_s3_class(params, "try-error")
  # check what happens if an argument was wrongly specified
  params <- try(pass_args(alg, elevation = dem, format = 122), silent = TRUE)
  expect_s3_class(params, "try-error")
  })
