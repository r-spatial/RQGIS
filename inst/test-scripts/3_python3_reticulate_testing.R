library("reticulate")

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

use_python(
  file.path("C:\\OSGeo4W64", "bin/python3.exe"),
  required = TRUE
)
# also possible
# use_python(file.path(Sys.getenv("PYTHONHOME"), "python.exe"), required = TRUE)
# py_config()
py_run_string("import os, sys, re, webbrowser")
py_run_string("from qgis.core import *")
py_run_string("import qgis.utils")
py_run_string("from osgeo import ogr")
py_run_string("from PyQt5.QtCore import *")
py_run_string("from PyQt5.QtGui import *")
py_run_string("from qgis.gui import *")
py_run_string("QgsApplication.setPrefixPath('C:/OSGeo4W64/apps/qgis', True)")
py_run_string("QgsApplication.setPrefixPath(r'C:/OSGEO4W64/apps/qgis', True)")
py_run_string("QgsApplication.showSettings()")
# not running the next two lines leads to a Qt problem when running 
# QgsApplication([], True)
# browseURL("http://wiki.qt.io/Deploy_an_Application_on_Windows")
py_run_string("from qgis.PyQt.QtCore import QCoreApplication")
# the strange thing is shell.exec(python3) works without it because here 
# all Qt paths are available as needed as set in SET QT_PLUGIN_PATH
# but these are not available when running Python3 via reticulate
py_run_string("a = QCoreApplication.libraryPaths()")$a  # empty list
# so, we need to set them again 
# I have looked them up in the QGIS 3 GUI using QCoreApplication.libraryPaths()
# py_run_string("QCoreApplication.setLibraryPaths(['C:/OSGEO4~1/apps/qgis/plugins', 'C:/OSGEO4~1/apps/qgis/qtplugins', 'C:/OSGEO4~1/apps/qt5/plugins', 'C:/OSGeo4W64/apps/qt4/plugins', 'C:/OSGeo4W64/bin'])")
qgis_env = list(root = "C:/OSGeo4W64")
py_run_string(
  sprintf("QCoreApplication.setLibraryPaths(['%s', '%s', '%s', '%s', '%s'])",
          file.path(qgis_env$root, "apps/qgis/plugins"),
          file.path(qgis_env$root, "apps/qgis/qtplugins"),
          file.path(qgis_env$root, "apps/qt5/plugins"),
          file.path(qgis_env$root, "apps/qt4/plugins"),
          file.path(qgis_env$root, "bin"))
  )
              
py_run_string("a = QCoreApplication.libraryPaths()")$a
py_run_string("app = QgsApplication([], True)")
py_run_string("QgsApplication.initQgis()")
py_run_string("sys.path.append(r'C:/OSGeo4W64/apps/qgis/python/plugins')")
py_run_string("from processing.core.Processing import Processing")
py_run_string("Processing.initialize()")
py_run_string("import processing")

# attaching RQGIS class
py_run_string("sys.path.append(r'D:/programming/R/RQGIS/RQGIS/inst/python')")
py_run_string("from python3_funs import RQGIS")
py_run_string("RQGIS = RQGIS()")
py_capture_output(py_run_string("RQGIS.alglist()"))
py_run_string("a = RQGIS.qgis_session_info()")$a
py_run_string("b = RQGIS.get_args_man('qgis:distancematrix')")$b
cat(py_capture_output(py_run_string("RQGIS.alghelp('qgis:distancematrix')")))
cat(py_capture_output(py_run_string("RQGIS.get_options('qgis:distancematrix')")))

# trying to run processing geoalgorithms
py_run_string('args = "C:/Users/pi37pat/Desktop/dem.tif", "1", "C:/Users/pi37pat/Desktop/aspect14.tif"')
py_run_string('params = "INPUT", "Z_FACTOR", "OUTPUT"')
py_run_string("params = dict((x, y) for x, y in zip(params, args))")
py_run_string("feedback = QgsProcessingFeedback()")
py_run_string('alg = QgsApplication.processingRegistry().createAlgorithmById("qgis:aspect")')
# py_run_string("alg = alg.create()")
py_run_string("Processing.runAlgorithm(algOrName = alg, parameters = params, 
              feedback = feedback)")
# trying to run native geoalgorithm
py_run_string('args = "C:/Users/pi37pat/Desktop/polys.gml", "C:/Users/pi37pat/Desktop/points.shp"')
py_run_string('params = "INPUT", "OUTPUT"')
py_run_string('params = dict((x, y) for x, y in zip(params, args))')
py_run_string('feedback = QgsProcessingFeedback()')
py_run_string("Processing.runAlgorithm(algOrName = 'native:centroids', parameters = params, feedback = feedback)")

#**********************************************************
# COMPARISON WITH CONSOLE----------------------------------
#**********************************************************

# checking environment variables (seem all ok)
py_run_string("a = os.getenv('OSGeo4W_ROOT')")$a
py_run_string("a = os.getenv('PYTHONPATH')")$a
py_run_string("a = os.getenv('QT_PLUGIN_PATH')")$a
py_run_string("a = os.getenv('PYTHONHOME')")
py_run_string("a = os.getenv('QGIS_PREFIX_PATH')")$a
py_run_string("a = os.getenv('PATH')")$a
# more or less the same as os.getenv("PATH") in Python 3
# py_run_string("a = os.get_exec_path()")$a

# checking loaded modules (seem also ok)
py_run_string(
  paste0("def imports():\n\tfor name, val in globals().items():", 
         "\n\t\tif isinstance(val, types.ModuleType):", 
         "\n\t\t\tyield val.__name__"))
py_run_string("a = list(imports())")$a
# def imports():
#   for name, val in globals().items():
#     if isinstance(val, types.ModuleType):
#       yield val.__name__

# Here are differences but not sure if relevant
# I think it's ok since in RQGIS2 also RStudio paths are returned 
py_run_string("a = QCoreApplication.applicationDirPath()")$a
py_run_string("a = QCoreApplication.applicationFilePath()")$a

# Drivers and formats, here are major differences and I guess this is the
# problem...
# in RQGIS2 providers & Co. are returned
py_run_string("tmp =  QgsProviderRegistry.instance().providerList()")$tmp
# only returns [1] "memory"
# Python console returns: 
# ['DB2', 'WFS', 'arcgisfeatureserver', 'arcgismapserver', 'delimitedtext',
#  'gdal', 'geonode', 'gpx', 'memory', 'mssql', 'ogr', 'oracle', 'ows', 'postgres',
#  'spatialite', 'virtual', 'wcs', 'wms']
py_run_string("tmp = QgsProviderRegistry.instance().directoryDrivers()")$tmp
# returns ""
# Python console returns:
# 'ESRI FileGDB,FileGDB;UK. NTF2,UK. NTF;OpenFileGDB,OpenFileGDB;U.S. Census TIGER/Line,TIGER;Arc/Info Binary Coverage,AVCBin;
cat(py_run_string("tmp = QgsProviderRegistry.instance().pluginList()")$tmp)
# only returns Memory provider
py_run_string("vectors = QgsProviderRegistry.instance().fileVectorFilters().split(';;')")$vectors
# returns ""
# Python console returns 53 vector formats
py_run_string("rasters = QgsProviderRegistry.instance().fileRasterFilters().split(';;')")$rasters
# returns ""
# Python console returns 78 raster formats
py_run_string("tmp=QgsProviderRegistry.instance().library('gdal')")$tmp
# returns ""
# Python console: 'C:/OSGEO4~1/apps/qgis/plugins/gdalprovider.dll
py_run_string("tmp=list(QgsProviderRegistry.instance().libraryDirectory())")$tmp
# returns: list()
# Python console: ['arcgisfeatureserverprovider.dll', 'arcgismapserverprovider.dll', 'basicauthmethod.dll', 'coordinatecaptureplugin.dll', 'db2provider.dll', 'delimitedtextprovider.dll', 'evis.dll', 'gdalprovider.dll', 'geometrycheckerplugin.dll', 'geonodeprovider.dll', 'georefplugin.dll', 'gpsimporterplugin.dll', 'gpxprovider.dll', 'grassplugin6.dll', 'grassplugin7.dll', 'grassprovider6.dll', 'grassprovider7.dll', 'grassrasterprovider6.dll', 'grassrasterprovider7.dll', 'identcertauthmethod.dll', 'mssqlprovider.dll', 'offlineeditingplugin.dll', 'ogrprovider.dll', 'oracleprovider.dll', 'owsprovider.dll', 'pkcs12authmethod.dll', 'pkipathsauthmethod.dll', 'postgresprovider.dll', 'spatialiteprovider.dll', 'topolplugin.dll', 'virtuallayerprovider.dll', 'wcsprovider.dll', 'wfsprovider.dll', 'wmsprovider.dll']
py_run_string("QgsProviderRegistry.instance().setLibraryDirectory('C:/OSGEO4~1/apps/qgis/plugins')")

py_run_string("tmp = list()")
py_run_string(paste0("for i in QgsApplication.processingRegistry().providers():\n\t",
                     "tmp.append(i.name())"))$tmp

# showSettings just a shortcut for following commands
cat(py_run_string("a=QgsApplication.showSettings()")$a)
py_run_string("a=QgsApplication.prefixPath()")$a  # good
# QgsApplication.setPrefixPath
py_run_string("a=QgsApplication.pluginPath()")$a  # good
# QgsApplication.setPluginPath
py_run_string("a=QgsApplication.libraryPaths()")$a  # good
# QgsApplication.setLibraryPaths
py_run_string("a=QgsApplication.qgisUserDatabaseFilePath()")$a
# changeable with QgsApplication.setPkgDataPath
py_run_string("a=QgsApplication.qgisAuthDatabaseFilePath()")$a
# QgsApplication.setAuthDatabaseDirPath
py_run_string("QgsApplication.setAuthDatabaseDirPath('C:/Users/pi37pat/AppData/Roaming/QGIS/QGIS3')")
# using regular expressions to find specific methods
# import re
# re.compile("set")
# list(filter(r.match, dir(QgsApplication)))
