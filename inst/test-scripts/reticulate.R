if (FALSE){
library("reticulate")
library("dplyr")

# initialising twice crashes Python/R
# if not locals().has_key("app"):  # you have to implement that (Barry)

#**********************************************************
# Linux----------------------------------------------------
#**********************************************************

# in the cmd there was something else you should add this just in case (using
# Sys.getenv)!!! before running all the subsequent stuff

py_run_string("import os, sys")
py_run_string("from qgis.core import *")
py_run_string("from osgeo import ogr")
py_run_string("from PyQt4.QtCore import *")
py_run_string("from PyQt4.QtGui import *")
py_run_string("from qgis.gui import *")
py_run_string("QgsApplication.setPrefixPath('/usr/bin/qgis', True)")
py_run_string("app = QgsApplication([], True)")
py_run_string("QgsApplication.initQgis()")
py_run_string("sys.path.append(r'/usr/share/qgis/python/plugins')")
py_run_string("from processing.core.Processing import Processing")
py_run_string("Processing.initialize()")
py_run_string("import processing")
py_run_string("processing.alglist()")

py_run_string("app.setPrefixPath('/usr', True)")
py_run_string("app.initQgis()")
py_run_string("print app.showSettings()")

#**********************************************************
# WINDOWS--------------------------------------------------
#**********************************************************

py_run_string("os.system('SET OSGEO4W_ROOT=C:\\OSGeo4W64')")
py_run_string("os.system('call '%OSGEO4W_ROOT%'\\bin\\o4w_env.bat')")
# ok, command line is not kept open...

library("RQGIS")
env <- set_env("C:/OSGeo4W64/", ltr = FALSE)

# find out running the batch script and opening python and then executing 
# following lines lets you access which Python executable we are actually using 
# import sys print(sys.executable) for QGIS 2.18.4 it was: 
# C:\\OSGEO4~1\\bin\\python.exe' what is really interesting running the same 
# from the Python console in QGIS 2.18.4, it tells us 
# "C:\OSGEO4~1\bin\qgis-bin.exe; so maybe this is also why sometimes the outputs
# differ
library("reticulate")
use_python("C:/OSGeo4W64/apps/qgis-ltr/python/", required = TRUE)
use_python(python = "C:/OSGeo4W64/bin/python-ltr.exe", required = TRUE)
use_python(python = "C:/Python27/ArcGIS10.2/python.exe", required = TRUE)
py_config()

reticulate:::py_discover_config("C:/OSGeo4W64/bin/python.exe")
reticulate:::py_discover_config("C:/Python27/ArcGIS10.2/python")


# Sys.setenv(OSGEO4W_ROOT = "C:\\OSGeo4W64")
# adding things to path
# Sys.setenv(PATH = paste(Sys.getenv("PATH"), 
#                         "C:\\OSGeo4W64\\apps\\qgis-ltr\\bin", sep = ";"))
# confirms that we are actually modifying the PATH
# shell("PATH")
# Sys.setenv(PYTHONPATH = paste("C:\\OSGeo4W64\\apps\\qgis-ltr\\python",
#                                Sys.getenv("PYTHONPATH"), sep = ";"))
# Sys.getenv("PYTHONPATH")         
# ok, this doesn't change anything...
# shell("PYTHONPATH")
# ah, something is there, I just don't have a clue about cmd-stuff...
# shell("%PYTHONPATH%")
# right I remember you got to use ECHO
# shell("ECHO %PYTHONPATH%")  # ok, there we go...

# reticulate:::use_python

# not really sure, if we need the next line (just in case)
Sys.setenv(OSGEO4W_ROOT = "C:\\OSGeo4W64")
shell("ECHO %OSGEO4W_ROOT%")
# REM start with clean path
shell("ECHO %WINDIR%", intern = TRUE)
Sys.setenv(PATH = "C:\\OSGeo4W64\\bin;C:\\WINDOWS\\system32;C:\\WINDOWS;C:\\WINDOWS\\WBem")
Sys.setenv(PYTHONHOME = "C:\\OSGeo4W64\\apps\\Python27")
Sys.setenv(PATH = paste("C:\\OSGeo4W64\\apps\\Python27\\Scripts",
                        Sys.getenv("PATH"), sep = ";"))
Sys.setenv(QT_PLUGIN_PATH = "C:\\OSGeo4W64\\apps\\Qt4\\plugins")
Sys.setenv(QT_RASTER_CLIP_LIMIT = 4096)
Sys.setenv(PATH = paste(Sys.getenv("PATH"),
                        "C:\\OSGeo4W64\\apps\\qgis-ltr\\bin", sep = ";"))
Sys.setenv(PYTHONPATH = paste("C:\\OSGeo4W64\\apps\\qgis-ltr\\python",
                              Sys.getenv("PYTHONPATH"), sep = ";"))
Sys.setenv(QGIS_PREFIX_PATH = "C:\\OSGeo4W64\\apps\\qgis-ltr")
shell.exec("python")  # yeah, it works!!!
library("reticulate")
py_config()  # perfect, that's what we want to see!!!
# but what if you have installed an Anaconda Python, does it still work???
# maybe because we cleaned the path, but I am not sure...
py_run_string("import os, sys")
py_run_string("from qgis.core import *")
py_run_string("from osgeo import ogr")
py_run_string("from PyQt4.QtCore import *")
py_run_string("from PyQt4.QtGui import *")
py_run_string("from qgis.gui import *")
py_run_string("QgsApplication.setPrefixPath('C:/OSGeo4W64/apps/qgis-ltr', True)")
py_run_string("app = QgsApplication([], True)")
py_run_string("QgsApplication.initQgis()")
py_run_string("sys.path.append(r'C:/OSGeo4W64/apps/qgis-ltr/python/plugins')")
py_run_string("from processing.core.Processing import Processing")
py_run_string("Processing.initialize()")
py_run_string("import processing")
# tmp = py_run_string("algs = processing.alglist()")
# py_capture_output("processing.alglist()")
# py_get_attr(tmp, "algs")
# tmp = py_run_string("grass_slope = processing.algoptions('grass7:r.slope.aspect')")
# tmp$grass_slope
# py_get_attr(tmp, "grass_slope")

py_file <- system.file("python", "alglist.py", package = "RQGIS")
py_file <- "D:/programming/R/RQGIS/RQGIS/inst/python/alglist.py"
tmp <- reticulate::py_run_file(py_file)
algs <- strsplit(tmp$s, split = "\n")[[1]]
# algs <- py_to_r(py_get_attr(tmp, "s"))
algs

py_run_string("from processing.core.Processing import Processing")
py_run_string("from processing.core.parameters import ParameterSelection")
tmp = py_run_string("alg = Processing.getAlgorithm('saga:slopeaspectcurvature')")
tmp$alg
py_get_attr(x = tmp, name = "alg")

#**********************************************************
# Mac--------------------------------------------------
#**********************************************************

py_run_string("import os, sys")
py_run_string("from qgis.core import *")
py_run_string("from osgeo import ogr")
py_run_string("from PyQt4.QtCore import *")
py_run_string("from PyQt4.QtGui import *")
py_run_string("from qgis.gui import *")

py_run_string("sys.path.append(r'/usr/local/Cellar/qgis2-ltr/2.14.13/QGIS.app/Contents/Resources/python/plugins')")  
py_run_string("QgsApplication.setPrefixPath(r'/usr/local/Cellar/qgis2-ltr/2.14.13/QGIS.app/Contents', True)")

py_run_string("print QgsApplication.showSettings()")
py_run_string("app = QgsApplication([], True)")
py_run_string("print app.showSettings()")
py_run_string("QgsApplication.initQgis()")

py_run_string("from processing.core.Processing import Processing")   
py_run_string("Processing.initialize()")
py_run_string("import processing")

#**********************************************************
# run_qgis-------------------------------------------------
#**********************************************************

# let's try to run a geoalgorithm
py_run_string("import processing")
py_run_string('processing.runalg("saga:slopeaspectcurvature", "C:/Users/pi37pat/AppData/Local/Temp/Rtmp2HtHJy/ELEVATION.asc", "0", "0", "0", "C:/Users/pi37pat/AppData/Local/Temp/Rtmp2HtHJy/slope.asc", None, None, None, None, None, None, None, None, None, None, None)')
# perfect, that works
# this is interesting because I didn't even run all the etc/ini batch files...


# testing get_args_man (and True, False, None)-------------
devtools::load_all()
library("reticulate")
qgis_env <- set_env("C:/OSGeo4W64/", ltr = TRUE)
qgis_app <- open_app(qgis_env = qgis_env)
qgis_session_info(qgis_app = qgis_app)

algs <- find_algorithms(name_only = TRUE, qgis_env = qgis_env)
tmp <- sample(algs, 100)
ls_1 <- lapply(algs, function(x) {
  print(x)
  x = "grass:v.distance.toattr\""
  x = gsub('\\\\|"', "", shQuote(x))
  get_args_man(x, qgis_env = qgis_env, options = TRUE)
})

# ok, there is not a single function with a function argument set to True
# interesting...
# However, None and False exist and where not converted from reticulate into
# R equivalents NULL and FALSE...
tmp <- lapply(seq_along(ls_1), function(i) {
  lapply(ls_1[[i]], function(j) {
    if (grepl(pattern = "True", j)) {
      print(algs[i])
    }
  })
})

#**********************************************************
# rewriting load_output argument---------------------------
#**********************************************************

# implement when rewriting run_qgis for reticulate usage
# 1. run_qgis via reticulate
# 2. `...`-arguments for specifying arguments within run_qgis (see doGRASS)
# 3. when input is SpatialObject, convert to sf and use write_sf instead of 
#    writeOGR (write a helper_function, say save_spat_object)
# 4. load_output should use read_sf and be only set to TRUE/FALSE, i.e. it
#    should automatically detect which objects should be loaded into R 
#    (write a helper_function, say load_output)

# Example 1: one output file load_output = FALSE but can also take as argument 
# TRUE and a vector of filenames this would make sure that the user can specify 
# to load only one raster or two instead of all (as would be the case for 
# r.slope.aspect or saga:slopeaspectcurvature) however, I am not sure if I might
# mix TRUE, FALSE and other values... but why not?
params <- get_args_man(alg = "qgis:polygoncentroids", options = TRUE,
                       qgis_env = qgis_env)
params$INPUT_LAYER  <- polys  # please note that the input is an R object!!!
# path to the output shapefile
params$OUTPUT_LAYER <- file.path(tempdir(), "coords.shp")
cmd <- paste("'qgis:polygoncentroids'", 
             "'C:/Users/pi37pat/AppData/Local/Temp/Rtmp2NUnNd/INPUT_LAYER.shp'", 
             "'C:/Users/pi37pat/AppData/Local/Temp/Rtmp2NUnNd/coords.shp'",
             sep = ", ")
out <- py_run_string(sprintf("a = processing.runalg(%s)", cmd))$a
# py_run_string("[a.name for a in alg.outputs]")

# Example 2: several output files
data("dem")
params <- get_args_man(alg = "saga:slopeaspectcurvature", options = TRUE)
params$ELEVATION <- dem
# ok, if the user does not specify tempdir() what happens then??? In load_output
# we automatically save the file to tempdir(), so we have to account for that
params$SLOPE <- file.path(tempdir(), "slope.asc")
params$ASPECT <- file.path(tempdir(), "aspect.asc")
library("raster")
writeRaster(dem, file.path(tempdir(), "dem.asc"), format = "ascii", 
            prj = TRUE, overwrite = TRUE)
cmd <- 'a = processing.runalg("saga:slopeaspectcurvature", "C:\\Users\\pi37pat\\AppData\\Local\\Temp\\RtmpI5FuD8/dem.asc", "0", "0", "0", "C:/Users/pi37pat/AppData/Local/Temp/Rtmp2NUnNd/slope.asc", "C:/Users/pi37pat/AppData/Local/Temp/Rtmp2NUnNd/aspect.asc", None, None, None, None, None, None, None, None, None, None)'
out <- py_run_string(cmd)$a
# here, you can also check if QGIS has produced an output!
# compare with input
int <- intersect(names(params), names(out))
params_inp <- normalizePath(unlist(params[int]), mustWork = FALSE)
params_out <- normalizePath(unlist(out[int]), mustWork = FALSE)
out_files <- params_out[params_out == params_inp]
# and now get the files that were actually specified


# also possible using the algorithm name to find out the output names:
# maybe the saver way, because we don't know what happens if QGIS does not write
# any output
py_run_string("alg = Processing.getAlgorithm('saga:slopeaspectcurvature')")
params_out <- py_run_string("out = [a.name for a in alg.outputs]")$out
params_inp <- names(params[params != "None"])
int <- intersect(params_inp, params_out)
out_files <- params[int]

#**********************************************************
# link2GI--------------------------------------------------
#**********************************************************
# get meuse data as sp object
# devtools::install_github("gisma/link2GI")
library(link2GI)
library("sp")
data(meuse) 
coordinates(meuse) <- ~x+y 
proj4string(meuse) <-CRS("+init=epsg:28992") 

# get meuse data as sf object
# require(sf)
# meuse_sf = st_as_sf(meuse, 
#                     coords = 
#                       c("x", "y"), 
#                     crs = 28992, 
#                     agr = "constant")
linkGRASS7(meuse, c("C:/OSGeo4W64","grass-7.2.1","osgeo4W"))
library("rgrass7")
rgrass7::parseGRASS("r.slope.aspect")

data("meuse", package = "sp")

data("meuse", package = "sp")
linkGRASS7(meuse, c("C:/OSGeo4W64", "grass-7.2.1", "osgeo4w"))

#**********************************************************
# Tests----------------------------------------------------
#**********************************************************

devtools::load_all()
library("sp")
library("rgdal")
qgis_env <- set_env("C:/OSGeo4W64/")
open_app(qgis_env = qgis_env)
# write a test for qgis_session_info
qgis_session_info(qgis_env = qgis_env)
# write a test for find algorithms!!!
find_algorithms(qgis_env = qgis_env)  # ok, under Linux, you have to take of '
# write a test for get_usage
get_usage("grass7:v.voronoi", qgis_env = qgis_env)
# write a test for get_options
get_options("grass7:r.slope.aspect", qgis_env = qgis_env)
# write a test for open_help
open_help("grass7:r.slope.aspect", qgis_env = qgis_env)
open_help(alg = "qgis:addfieldtoattributestable", qgis_env = qgis_env)
# write a test for get_args_man
get_args_man("grass7:r.slope.aspect", qgis_env = qgis_env)
get_args_man("saga:slopeaspectcurvature", qgis_env = qgis_env)
# check run_qgis
coords_1 <- 
  matrix(data = c(0, 0, 1, 0, 1, 1, 0, 1, 0, 0),
         ncol = 2, byrow = TRUE)
coords_2 <- coords_1 + 2
polys <- 
  # convert the coordinates into polygons
  polys <- list(Polygons(list(Polygon(coords_1)), 1), 
                Polygons(list(Polygon(coords_2)), 2)) 
polys <- as(SpatialPolygons(polys), "SpatialPolygonsDataFrame")
writeOGR(polys, dsn = tempdir(), layer = "polys", driver = "ESRI Shapefile")

params <- get_args_man("qgis:polygoncentroids", options = TRUE, 
                       qgis_env = qgis_env)
params$INPUT_LAYER <- file.path(tempdir(), "polys.shp")
params$OUTPUT_LAYER <- file.path(tempdir(), "out.shp")
out <- run_qgis(alg = "qgis:polygoncentroids", params = params,
                load_output = params$OUTPUT_LAYER, qgis_env = qgis_env)
# check
plot(polys)
points(out)

}

