library("reticulate")
library("dplyr")

# initialising twice crashes Python/R
# if not locals().has_key("app"):  # you have to implement that (Barry)

# Linux
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

shell("SET OSGEO4W_ROOT=C:\\OSGeo4W64")
shell("call '%OSGEO4W_ROOT%'\\bin\\o4w_env.bat")
shell("path %PATH%;C:\\OSGeo4W64\\apps\\qgis-ltr\\bin")
shell("set PYTHONPATH=%PYTHONPATH%;%OSGEO4W_ROOT%\\apps\\qgis-ltr\\python;", intern = TRUE)
shell("set QGIS_PREFIX_PATH=%OSGEO4W_ROOT%\\apps\\qgis-ltr")
shell("python")
Sys.setenv(OSGEO4W_ROOT = "C:\\OSGeo4W64")
# adding things to path
Sys.setenv(PATH = paste(Sys.getenv("PATH"), 
                        "C:\\OSGeo4W64\\apps\\qgis-ltr\\bin", sep = ";"))
# confirms that we are actually modifying the PATH
shell("PATH")
Sys.setenv(PYTHONPATH = paste("C:\\OSGeo4W64\\apps\\qgis-ltr\\python",
                              Sys.getenv("PYTHONPATH"), sep = ";"))
Sys.getenv("PYTHONPATH")         
# ok, this doesn't change anything...
shell("PYTHONPATH")
# aha, something is there, I just don't have a clue about cmd-stuff...
shell("%PYTHONPATH%")
# right I remember you got to use ECHO
shell("ECHO %PYTHONPATH%")  # ok, there we go...

# reticulate:::use_python

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
py_run_string("sys.path.append(r'C:/OSGeo4W64/apps/qgis-ltr/python/plugins')")  # you've got to change that!!
py_run_string("from processing.core.Processing import Processing")
py_run_string("Processing.initialize()")
py_run_string("import processing")
tmp = py_run_string("algs = processing.alglist()")
py_get_attr(tmp, "algs")
tmp = py_run_string("grass_slope = processing.algoptions('grass7:r.slope.aspect')")
py_get_attr(tmp, "grass_slope")


py_run_string("from processing.core.Processing import Processing")
py_run_string("from processing.core.parameters import ParameterSelection")
tmp = py_run_string("alg = Processing.getAlgorithm('saga:slopeaspectcurvature')")
py_get_attr(x = tmp, name = "alg")

#**********************************************************
# get_args_man---------------------------------------------
#**********************************************************

tmp = py_run_file("C:/Users/pi37pat/Desktop/get_args_man.py", convert = TRUE)
py_get_attr(tmp, "params") %>% 
  py_to_r
py_get_attr(tmp, "vals") %>%
  py_to_r  
# you have to be careful here, if you want to preserve True and False in Python
# script
py_get_attr(tmp, "opts") %>%
  py_to_r
# or return a list
tmp = py_run_string("args = [params, vals, opts]")
py_get_attr(tmp, "args") %>%
  py_to_r

#**********************************************************
# run_qgis-------------------------------------------------
#**********************************************************

# let's try to run a geoalgorithm
py_run_string("import processing")
py_run_string('processing.runalg("saga:slopeaspectcurvature", "C:/Users/pi37pat/AppData/Local/Temp/Rtmp2HtHJy/ELEVATION.asc", "0", "0", "0", "C:/Users/pi37pat/AppData/Local/Temp/Rtmp2HtHJy/slope.asc", None, None, None, None, None, None, None, None, None, None, None)')
# perfect, that works
