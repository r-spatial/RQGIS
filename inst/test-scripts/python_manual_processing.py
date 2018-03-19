# open python-qgis-ltr.bat
import os, sys, re, webbrowser
from qgis.core import *
from osgeo import ogr
from PyQt4.QtCore import *
from PyQt4.QtGui import *
from qgis.gui import *
# QgsApplication.setPrefixPath(r'C:\\OSGeo4W64\\apps\\qgis-ltr', True)
QgsApplication.setPrefixPath('C:/OSGeo4W64/apps/qgis-ltr', True)
app = QgsApplication([], True)
QgsApplication.initQgis()
sys.path.append(r'C:/OSGeo4W64/apps/qgis-ltr/python/plugins')
from processing.core.Processing import Processing
Processing.initialize()
import processing

# processing.runalg("saga:sagawetnessindex", "C:\\Users\\pi37pat\\AppData\\Local\\Temp\\RtmpKukVyJ/DEM.asc", "10.0", None, None, "0.0", "0.1", "1.0", None, None, None, "C:\\Users\\pi37pat\\AppData\\Local\\Temp\\RtmpKukVyJ/wet.tif")
