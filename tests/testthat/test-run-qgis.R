library("testthat")
library("RQGIS")
library("sp")
library("raster")
library("reticulate")
library("rgdal", quietly = TRUE)

context("run_qgis")

# let's set the environment 
# qgis_env <- set_env()
# Test if all functions are working also with the QGIS developer version
# qgis_env <- set_env("C:/OSGeo4W64/", ltr = FALSE)  


##### 
# manual testing for travis
#####

qgis_env <- set_env()

settings <- as.list(Sys.getenv())
# since we are adding quite a few new environment variables these will remain
# (PYTHONPATH, QT_PLUGIN_PATH, etc.). We could unset these before exiting the
# function but I am not sure if this is necessary

# Well, well, not sure if we should change it back or at least we have to get
# rid off Anaconda Python
# on.exit(do.call(Sys.setenv, settings))

if (Sys.info()["sysname"] == "Windows") {
  # run Windows setup
  setup_win(qgis_env = qgis_env)
} else if (Sys.info()["sysname"] == "Linux") {
  # append pythonpath to import qgis.core etc. packages
  python_path <- Sys.getenv("PYTHONPATH")
  qgis_python_path <- paste0(qgis_env$root, "/share/qgis/python")
  if (python_path != "" & !grepl(qgis_python_path, python_path)) {
    qgis_python_path <- paste(qgis_python_path, Sys.getenv("PYTHONPATH"), 
                              sep=":")
  } 
} else if (Sys.info()["sysname"] == "Darwin") { 
  python_path <- Sys.getenv("PYTHONPATH")
  # PYTHONPATH only applies to homebrew installation - todo: account for Kyngchaos 
  qgis_python_path <- paste0(qgis_env$root, "/Contents/Resources/python/:/usr/local/lib/qt-4/python2.7/site-packages:/usr/local/lib/python2.7/site-packages:$PYTHONPATH")
  if (python_path != "" & !grepl(qgis_python_path, python_path)) {
    qgis_python_path <- paste(qgis_python_path, Sys.getenv("PYTHONPATH"), 
                              sep=":")    
  }
  
  Sys.setenv(QGIS_PREFIX_PATH = paste0(qgis_env$root, "/Contents/MacOS/")) ### is this not needed on Windows/Linux? Without `open_app() does not work on Mac`
} 
Sys.setenv(PYTHONPATH = qgis_python_path)


# define path where QGIS libraries reside to search path of the
# dynamic linker
ld_library <- Sys.getenv("LD_LIBRARY_PATH")

if (!Sys.info()["sysname"] == "Darwin") {
  qgis_ld <- paste(paste0(qgis_env$root, "/lib"))
} else {
  qgis_ld <- paste(paste0(qgis_env$qgis_prefix_path, "/MacOS/lib/:/Applications/QGIS.app/Contents/Frameworks/")) # homebrew
}
if (ld_library != "" & !grepl(paste0(qgis_ld, ":"), ld_library)) {
  qgis_ld <- paste(paste0(qgis_env$root, "/lib"),
                   Sys.getenv("LD_LIBRARY_PATH"), sep=":")
}
Sys.setenv(LD_LIBRARY_PATH = qgis_ld)


py_run_string("import os, sys, re, webbrowser")
py_run_string("from qgis.core import *")
py_run_string("from osgeo import ogr")
py_run_string("from PyQt4.QtCore import *")
py_run_string("from PyQt4.QtGui import *")
py_run_string("from qgis.gui import *")

set_prefix <- paste0("QgsApplication.setPrefixPath(r'",
                     qgis_env$qgis_prefix_path, "', True)")
code <- paste0("sys.path.append(r'", qgis_env$python_plugins, "')")
py_run_string(code)
py_run_string(set_prefix)

py_run_string("app = QgsApplication([], True)")
py_run_string("QgsApplication.initQgis()")

py_run_string("app.setPrefixPath('/usr', True)") # see if that solves QObject::connect: Cannot connect (null)::raiseError( QString ) to QgsVectorLayer::raiseError( QString )


print(qgis_env) # for debugging
py_run_string("print app.showSettings()") # debugging

# works!
py_run_string("from processing.core.Processing import Processing")   
py_run_string("Processing.initialize()")
py_run_string("import processing")

# works!
#py_run_string("processing.alglist()") # works!!! lets see if grass7 algs are also found

print("Searching QGIS algs")
py_run_string("processing.algoptions('qgis:polygoncentroids')")
py_run_string("processing.alghelp('qgis:polygoncentroids')")

print("Searching GRASS algs")
py_run_string("processing.algoptions('grass7:r.slope.aspect')")
py_run_string("processing.alghelp('grass7:r.slope.aspect')")

coords_1 <- 
  matrix(data = c(0, 0, 1, 0, 1, 1, 0, 1, 0, 0),
         ncol = 2, byrow = TRUE)
print("1")
coords_2 <- coords_1 + 2
print("2")
polys <- 
  # convert the coordinates into polygons
  polys <- list(Polygons(list(Polygon(coords_1)), 1), 
                Polygons(list(Polygon(coords_2)), 2)) 
print("3")
polys <- as(SpatialPolygons(polys), "SpatialPolygonsDataFrame")
print("4")
writeOGR(polys, dsn = tempdir(), layer = "polys", driver = "ESRI Shapefile")
print("5")

inp <- file.path(tempdir(), "polys.shp")
print("6")
out <- file.path(tempdir(), "out.shp")
print("7")
cmd <- paste(shQuote("qgis:polygoncentroids"), shQuote(inp), 
             shQuote(out), sep = ",")
print("8")
cmd <- paste0("processing.runalg(", cmd, ")")
print("9")
py_run_string(cmd)
print("10")
# load output
out <- readOGR(dsn = tempdir(), layer = "out")
print("11")


# open_app()

# as.character(py_run_string("with Capturing() as output_alglist:\n  processing.alglist()")$output_alglist)


test_that("Test, if QGIS-algorithms are working?", {
  
  testthat::skip_on_appveyor()
  testthat::skip_on_travis()
  testthat::skip_on_cran()
  
  py_config()
  
  # check if python modules are available
  py_module_available("cStringIO")
  
  as.character(py_run_string("with Capturing() as output_alglist:\n  processing.alglist()")$output_alglist)

  coords_1 <- 
    matrix(data = c(0, 0, 1, 0, 1, 1, 0, 1, 0, 0),
           ncol = 2, byrow = TRUE)
  coords_2 <- coords_1 + 2
  polys <- 
  # convert the coordinates into polygons
  polys <- list(Polygons(list(Polygon(coords_1)), 1), 
                Polygons(list(Polygon(coords_2)), 2)) 
  polys <- as(SpatialPolygons(polys), "SpatialPolygonsDataFrame")

  # let's set the environment 
  qgis_env <- set_env()
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

  # let's set the environment 
  qgis_env <- set_env()  
  
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
  
  # let's set the environment 
  qgis_env <- set_env()  
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
