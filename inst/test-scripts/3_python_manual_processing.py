# run python-qgis.bat (see cmd_python_setup for various ways)
# shell.exec("C:/OSGeo4W64/bin/python-qgis.bat")  # Windows R command
# then run in Python3
import os, sys, re, webbrowser
from qgis.core import *
# import qgis.utils
from osgeo import ogr
from PyQt5.QtCore import *
from PyQt5.QtGui import *
from qgis.gui import *
# enable native algorithms
from qgis.analysis import (QgsNativeAlgorithms)
# next line necessary if run via sytem('python3 3_python_manual_processing.py')
# from qgis.PyQt.QtCore import QCoreApplication
QgsApplication.setPrefixPath(r'C:\OSGEO4W64\apps\qgis', True)
QgsApplication.setPrefixPath(r'C:\OSGEO4W64\apps\qgis', True)
# next line necessary if run via sytem('python3 3_python_manual_processing.py')
# QCoreApplication.setLibraryPaths(['C:/OSGEO4~1/apps/qgis/plugins', 'C:/OSGEO4~1/apps/qgis/qtplugins', 'C:/OSGEO4~1/apps/qt5/plugins', 'C:/OSGeo4W64/apps/qt4/plugins', 'C:/OSGeo4W64/bin'])
app = QgsApplication([], True)
QgsApplication.initQgis()
sys.path.append(r'C:/OSGeo4W64/apps/qgis/python/plugins')
# add native algorithms
QgsApplication.processingRegistry().addProvider(QgsNativeAlgorithms())
from processing.core.Processing import Processing
Processing.initialize()
import processing
# somehow warning and error messages disappeared, here I turn them on again
import cgitb
cgitb.enable(format='text')

# test processing toolbox
# first qgis:aspect (works)
args = "C:/Users/pi37pat/Desktop/dem.tif", "1",\
  "C:/Users/pi37pat/Desktop/aspect13.tif"
params = "INPUT", "Z_FACTOR", "OUTPUT"
params = dict((x, y) for x, y in zip(params, args))
feedback = QgsProcessingFeedback()
Processing.runAlgorithm(algOrName = 'qgis:aspect', parameters = params, feedback = feedback)

# # next we try a native algorithm
args = "C:/Users/pi37pat/Desktop/polys.shp", "C:/Users/pi37pat/Desktop/points.shp"
params = "INPUT", "OUTPUT"
params = dict((x, y) for x, y in zip(params, args))
feedback = QgsProcessingFeedback()
Processing.runAlgorithm(algOrName = 'native:centroids', parameters = params,
                        feedback = feedback)

# # let's try grass7:r.slope.aspect, this does not work
# args = "C:/Users/pi37pat/Desktop/dem.tif", "0", "0", True, "1.0", "0.0",\
# "C:/Users/pi37pat/Desktop/slope.tif", None, None, None, None, None, None, None,\
# None, "794599.107614635,798208.557614635,8931774.87460253,8935384.32460253",\
# "0.0", None, None
# params = "elevation", "format", "precision", "-a", "zscale", "min_slope",\
# "slope", "aspect", "pcurvature", "tcurvature", "dx", "dy", "dxx", "dyy",\
# "dxy", "GRASS_REGION_PARAMETER", "GRASS_REGION_CELLSIZE_PARAMETER",\
# "GRASS_RASTER_FORMAT_OPT", "GRASS_RASTER_FORMAT_META"
# params = dict((x, y) for x, y in zip(params, args))
# feedback = QgsProcessingFeedback()
# Processing.runAlgorithm(algOrName = 'grass7:r.slope.aspect', parameters = params, 
#                         feedback = feedback)
# 


# # Python 2=================================================
# # open python-qgis-ltr.bat
# # shell.exec("C:/OSGeo4W64/bin/python-qgis-ltr.bat")  # Windows R command
# import os, sys, re, webbrowser
# from qgis.core import *
# from osgeo import ogr
# from PyQt4.QtCore import *
# from PyQt4.QtGui import *
# from qgis.gui import *
# # QgsApplication.setPrefixPath(r'C:\\OSGeo4W64\\apps\\qgis-ltr', True)
# QgsApplication.setPrefixPath('C:/OSGeo4W64/apps/qgis-ltr', True)
# app = QgsApplication([], True)
# QgsApplication.initQgis()
# sys.path.append(r'C:/OSGeo4W64/apps/qgis-ltr/python/plugins')
# from processing.core.Processing import Processing
# Processing.initialize()
# import processing
# 
# # processing.runalg("saga:sagawetnessindex", "C:\\Users\\pi37pat\\AppData\\Local\\Temp\\RtmpKukVyJ/DEM.asc", "10.0", None, None, "0.0", "0.1", "1.0", None, None, None, "C:\\Users\\pi37pat\\AppData\\Local\\Temp\\RtmpKukVyJ/wet.tif")
