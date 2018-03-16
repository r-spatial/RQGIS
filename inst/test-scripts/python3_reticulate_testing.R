Sys.setenv(OSGEO4W_ROOT = "C:\\OSGeo4W64")
shell("ECHO %OSGEO4W_ROOT%")
# REM start with clean path
shell("ECHO %WINDIR%", intern = TRUE)
Sys.setenv(PATH = "C:\\OSGeo4W64\\bin;C:\\WINDOWS\\system32;C:\\WINDOWS;C:\\WINDOWS\\WBem")
Sys.setenv(PYTHONHOME = "C:\\OSGeo4W64\\apps\\Python36")
Sys.setenv(PATH = paste("C:\\OSGeo4W64\\apps\\Python36",
                        "C:\\OSGeo4W64\\apps\\Python36\\Scripts",
                        Sys.getenv("PATH"), sep = ";"))
Sys.setenv(PATH = paste("C:\\OSGeo4W64\\apps\\qt5\\bin",
                        Sys.getenv("PATH"), sep = ";"))

# Sys.setenv(QT_PLUGIN_PATH = "C:\\OSGeo4W64\\apps\\qgis\\qtplugins;C:\\OSGeo4W64\\apps\\qt5\\plugins")
Sys.setenv(QT_PLUGIN_PATH = "C:/OSGEO4~1/apps/qgis/plugins;C:/OSGEO4~1/apps/qgis/qtplugins;C:/OSGEO4~1/apps/qt5/plugins;C:/OSGeo4W64/apps/qt4/plugins;C:/OSGeo4W64/bin")

#Sys.setenv(QT_RASTER_CLIP_LIMIT = 4096)
Sys.setenv(PATH = paste(Sys.getenv("PATH"),
                        "C:\\OSGeo4W64\\apps\\qgis\\bin", sep = ";"))
Sys.setenv(PYTHONPATH = paste("C:\\OSGeo4W64\\apps\\qgis\\python",
                              Sys.getenv("PYTHONPATH"), sep = ";"))
Sys.setenv(QGIS_PREFIX_PATH = "C:\\OSGeo4W64\\apps\\qgis")
# set QT_PLUGIN_PATH=%OSGEO4W_ROOT%\apps\qgis\qtplugins;%OSGEO4W_ROOT%\apps\qt5\plugins
# shell.exec("python3")  # yeah, it works!!!

library("reticulate")
use_python(
  file.path("C:\\OSGeo4W64", "bin/python3.exe"),
  required = TRUE
)
# py_config()
py_run_string("import os, sys")
py_run_string("from qgis.core import *")
py_run_string("from osgeo import ogr")
py_run_string("from PyQt5.QtCore import *")
py_run_string("from PyQt5.QtGui import *")
py_run_string("from qgis.gui import *")
py_run_string("QgsApplication.setPrefixPath('C:/OSGeo4W64/apps/qgis', True)")
py_run_string("QgsApplication.showSettings()")
py_run_string("app = QgsApplication([], True)")
py_run_string("QgsApplication.initQgis()")
py_run_string("sys.path.append(r'C:/OSGeo4W64/apps/qgis/python/plugins')")
py_run_string("from processing.core.Processing import Processing")
py_run_string("Processing.initialize()")
py_run_string("import processing")
