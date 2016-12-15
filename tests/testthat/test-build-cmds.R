context("build_cmds")

test_that("correct output of build_cmds", {
  
  testthat::skip_on_appveyor()
  testthat::skip_on_travis()
  testthat::skip_on_cran()
  
  library("RQGIS")
  
  out <- build_cmds()
  
  # check that 'cmd' and 'py_cmd' are build
  expect_equal(length(out), 2)
  # check that all lines of 'cmd' are build
  expect_equal(length(out$cmd), 4)
  # check that all lines of 'py_cmd' are build
  expect_equal(length(out$py_cmd), 14)
})
