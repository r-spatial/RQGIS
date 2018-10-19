library("RQGIS")
library("RSAGA")
library("raster")
library("sf")

context("paper")


test_that("qgis_session_info yields a list as output", {
  skip_on_cran()
  
  info_r <- version
  info_qgis <- qgis_session_info()
  info <- c(platform = info_r$platform, R = info_r$version.string, info_qgis)
  expect_gt(length(info), 6)
})

test_that("find_algorithms finds curvature algorithms", {
  skip_on_cran()
  
  algs <- find_algorithms(
    search_term = "curvature",
    name_only = TRUE
  )
  expect_gt(length(algs), 1)
})

test_that("get_usage finds grass7:r.slope.aspect", {
  skip_on_cran()
  
  use <- get_usage(alg = "grass7:r.slope.aspect", intern = TRUE)
  expect_match(use, "ALGORITHM: r.slope.aspect")
})

test_that(paste(
  "Test that all terrain attributes can be derived and that",
  "the model can be fitted"
), {
  skip_on_cran()
  
  params <- get_args_man(alg = "grass7:r.slope.aspect")
  expect_length(params, 17)
  # Calculate curvatures
  params$elevation <- dem
  params$pcurvature <- file.path(tempdir(), "pcurv.tif")
  params$tcurvature <- file.path(tempdir(), "tcurv.tif")
  out <- run_qgis(
    alg = "grass7:r.slope.aspect",
    params = params,
    load_output = TRUE,
    show_output_paths = FALSE
  )
  # check if the output is a raster
  expect_is(out[[1]], "RasterLayer")
  expect_is(out[[2]], "RasterLayer")
  
  # Remove possible artifacts
  run_qgis(
    "saga:sinkremoval",
    DEM = dem,
    METHOD = "[1] Fill Sinks",
    DEM_PREPROC = file.path(tempdir(), "sdem.tif"),
    show_output_paths = FALSE
  )
  expect_true(file.exists(file.path(tempdir(), "sdem.tif")))
  
  # Compute wetness index
  run_qgis(
    "saga:sagawetnessindex",
    DEM = file.path(tempdir(), "sdem.tif"),
    AREA = file.path(tempdir(), "carea.tif"),
    SLOPE = file.path(tempdir(), "cslope.tif"),
    SLOPE_TYPE = 1,
    show_output_paths = FALSE
  )
  expect_true(file.exists(file.path(tempdir(), "cslope.tif")))
  expect_true(file.exists(file.path(tempdir(), "carea.tif")))
  
  # transform
  cslope <- raster(file.path(tempdir(), "cslope.tif"))
  cslope <- cslope * 180 / pi
  carea <- raster(file.path(tempdir(), "carea.tif"))
  log_carea <- log(carea / 1e+06)
  data("dem", package = "RQGIS")
  dem <- dem / 1000
  my_poly <- poly(values(dem), degree = 2)
  dem1 <- dem2 <- dem
  values(dem1) <- my_poly[, 1]
  values(dem2) <- my_poly[, 2]
  # load NDVI
  data("ndvi", package = "RQGIS")
  for (i in c("dem1", "dem2", "log_carea", "cslope", "ndvi")) {
    tmp <- crop(get(i), dem)
    writeRaster(
      tmp,
      file.path(tempdir(), paste0(i, ".asc")),
      format = "ascii",
      prj = TRUE,
      overwrite = TRUE
    )
  }
  
  # extract values to points
  data("random_points", package = "RQGIS")
  random_points[, c("x", "y")] <- sf::st_coordinates(random_points)
  raster_names <- c("dem1", "dem2", "log_carea", "cslope", "ndvi")
  vals <- RSAGA::pick.from.ascii.grids(
    data = as.data.frame(random_points),
    X.name = "x",
    Y.name = "y",
    file = file.path(
      tempdir(),
      raster_names
    ),
    varname = raster_names
  )
  expect_false(any(!raster_names %in% names(vals)))
  
  fit <- glm(
    spri ~ dem1 + dem2 + cslope + ndvi + log_carea,
    data = vals,
    family = "poisson"
  )
  
  # make the prediction
  raster_names <- c(
    "dem1.asc", "dem2.asc", "log_carea.asc", "cslope.asc",
    "ndvi.asc"
  )
  s <- stack(x = file.path(tempdir(), raster_names))
  pred <- predict(
    object = s,
    model = fit,
    fun = predict,
    type = "response"
  )
  expect_is(pred, "RasterLayer")
})

test_that("Test that we can call the PYQGIS API directly", {
  skip_on_cran()
  
  met <- py_run_string("methods = dir(RQGIS)")$methods
  expect_gt(length(met), 5)
  
  py_cmd <-
    "opts = RQGIS.get_options('qgis:randompointsinsidepolygonsvariable')"
  opts <- py_run_string(py_cmd)$opts
  expect_is(opts, "list")
  py_cmd <- "processing.alghelp('qgis:randompointsinsidepolygonsvariable')"
  alghelp <- py_capture_output(py_run_string(py_cmd)) %>%
    substring(., 1, 40)
  expect_match(alghelp, "ALGORITHM: Random points inside polygons")
})
