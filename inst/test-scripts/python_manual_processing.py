# Python 3
# in R open Python3 shell
shell.exec("C:/OSGeo4W64/bin/python-qgis.bat")
# or run:
# Sys.setenv(OSGEO4W_ROOT = "C:\\OSGeo4W64")
# shell("ECHO %OSGEO4W_ROOT%")
# # REM start with clean path
# shell("ECHO %WINDIR%", intern = TRUE)
# Sys.setenv(PATH = "C:\\OSGeo4W64\\bin;C:\\WINDOWS\\system32;C:\\WINDOWS;C:\\WINDOWS\\WBem")
# Sys.setenv(PYTHONHOME = "C:\\OSGeo4W64\\apps\\Python36")
# Sys.setenv(PATH = paste("C:\\OSGeo4W64\\apps\\Python36",
#                         "C:\\OSGeo4W64\\apps\\Python36\\Scripts",
#                         Sys.getenv("PATH"), sep = ";"))
# Sys.setenv(PATH = paste("C:\\OSGeo4W64\\apps\\qt5\\bin",
#                         Sys.getenv("PATH"), sep = ";"))
# 
# # Sys.setenv(QT_PLUGIN_PATH = "C:\\OSGeo4W64\\apps\\qgis\\qtplugins;C:\\OSGeo4W64\\apps\\qt5\\plugins")
# Sys.setenv(QT_PLUGIN_PATH = "C:/OSGEO4~1/apps/qgis/plugins;C:/OSGEO4~1/apps/qgis/qtplugins;C:/OSGEO4~1/apps/qt5/plugins;C:/OSGeo4W64/apps/qt4/plugins;C:/OSGeo4W64/bin")
# 
# #Sys.setenv(QT_RASTER_CLIP_LIMIT = 4096)
# Sys.setenv(PATH = paste(Sys.getenv("PATH"),
#                         "C:\\OSGeo4W64\\apps\\qgis\\bin", sep = ";"))
# Sys.setenv(PYTHONPATH = paste("C:\\OSGeo4W64\\apps\\qgis\\python",
#                               Sys.getenv("PYTHONPATH"), sep = ";"))
# Sys.setenv(QGIS_PREFIX_PATH = "C:\\OSGeo4W64\\apps\\qgis")
# # set QT_PLUGIN_PATH=%OSGEO4W_ROOT%\apps\qgis\qtplugins;%OSGEO4W_ROOT%\apps\qt5\plugins
# # shell.exec("python3")  # yeah, it works!!!
# 

# then run in Python3
import os, sys, re, webbrowser
from qgis.core import *
from osgeo import ogr
from PyQt5.QtCore import *
from PyQt5.QtGui import *
from qgis.gui import *
QgsApplication.setPrefixPath(r'C:\\OSGeo4W64\\apps\\qgis', True)
# QgsApplication.setPrefixPath(r'C:\\OSGeo4W64\\apps\\qgis', True)
app = QgsApplication([], True)
QgsApplication.initQgis()
sys.path.append(r'C:/OSGeo4W64/apps/qgis/python/plugins')
from processing.core.Processing import Processing
Processing.initialize()
import processing
sys.path.append(r'D:/programming/R/RQGIS/RQGIS/inst/python')
from python3_funs import RQGIS
RQGIS = RQGIS()
RQGIS.alglist()
RQGIS.qgis_session_info()
RQGIS.get_args_man('qgis:distancematrix')

# Python 2
import os, sys, re, webbrowser
from qgis.core import *
from osgeo import ogr
from PyQt4.QtCore import *
from PyQt4.QtGui import *
from qgis.gui import *
QgsApplication.setPrefixPath(r'C:\\OSGeo4W64\\apps\\qgis', True)
QgsApplication.setPrefixPath(r'C:\\OSGeo4W64\\apps\\qgis', True)

sys.path.append(r'C:\\OSGeo4W64\\apps\\qgis\\python\\plugins')
from processing.core.Processing import Processing
# Processing.initialize()
import processing
# ParameterSelection required by get_args_man.py, algoptions, alghelp
from processing.core.parameters import ParameterSelection
from processing.gui.Postprocessing import handleAlgorithmResults
# needed for open_help
from processing.tools.help import createAlgorithmHelp
# needed for qgis_session_info
from processing.algs.saga.SagaAlgorithmProvider import SagaAlgorithmProvider
from processing.algs.saga import SagaUtils
from processing.algs.grass.GrassUtils import GrassUtils
from processing.algs.grass7.Grass7Utils import Grass7Utils
from processing.algs.otb.OTBAlgorithmProvider import OTBAlgorithmProvider
from processing.algs.otb.OTBUtils import getInstalledVersion
from processing.algs.taudem.TauDEMUtils import TauDEMUtils
from osgeo import gdal
from processing.tools.system import isWindows, isMac

processing.runalg("saga:sagawetnessindex", "C:\\Users\\pi37pat\\AppData\\Local\\Temp\\RtmpKukVyJ/DEM.asc", "10.0", None, None, "0.0", "0.1", "1.0", None, None, None, "C:\\Users\\pi37pat\\AppData\\Local\\Temp\\RtmpKukVyJ/wet.tif")
