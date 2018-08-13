context("prerun")

library("raster")
library("sf")

test_that("qgis_session_info yields a list as output", {
  skip_on_cran()
  
  info <- qgis_session_info()
  # check if the output is a list of length 5 or 6
  expect_gt(length(info), 4)
})

test_that("find_algorithms finds QGIS geoalgorithms", {
  skip_on_cran()
  
  algs <- find_algorithms()
  # just retrieve QGIS geoalgorithms
  test <- grep("qgis:", algs, value = TRUE)
  # normally there are 101 QGIS geoalgorithms, so check if there are more than
  # 50
  expect_gt(length(test), 50)
})

test_that("get_extent is working correctly", {
  testthat::skip_on_cran()
  
  # test multiple rasters
  r1 = raster(extent(0, 1, 1, 2), nrows = 2, ncols = 2)
  r2 = raster(extent(-2, 2, 0, 1), nrow = 2, ncols = 3)
  ex = get_extent(params = list(list(r1, r2)), "multipleinput")
  expect_identical(ex, c("-2", "2", "0", "2"))
  
  # test sf objects
  # shift random points by 1000 m to the east and north
  ps = random_points
  st_geometry(random_points) = st_geometry(random_points) + c(1000, 1000)
  ex = get_extent(params = list(list(ps, random_points)), 
                  type_name = "multipleinput")
  expect_identical(ex, c("795551.3547", "798242.2819", "8932370.0031",
                         "8935800.4185"))
  # test SpatialObjects
  ps = as(ps, "Spatial")
  random_points =  as(random_points, "Spatial")
  ex = get_extent(params = list(list(ps, random_points)), 
                  type_name = "multipleinput")
  expect_identical(ex, c("795551.3547", "798242.2819", "8932370.0031",
                         "8935800.4185"))
})
