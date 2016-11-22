context("build_cmds")

test_that("correct output of build_cmds", {
  skip_on_cran()
  skip_on_travis()
  out <- build_cmds()
  
  # check that 'cmd' and 'py_cmd' are build
  expect_equal(length(out), 2)
  # check that all lines of 'cmd' are build
  expect_equal(length(out$cmd), 4)
  # check that all lines of 'py_cmd' are build
  expect_equal(length(out$py_cmd), 14)
})
