# run in terminal
export PYTHONPATH=/usr/share/qgis/python
export LD_LIBRARY_PATH=/usr/lib
# set PYTHONPATH=/usr/share/qgis/python 
python

# trying to create the map canvas just using Python
import os, sys, re, webbrowser
from qgis.core import *
from osgeo import ogr
from PyQt4.QtCore import *
from PyQt4.QtGui import *
from qgis.gui import *
QgsApplication.setPrefixPath(r'/usr/bin/qgis', True)
# it works if we call setPrefixPath two times, once before starting the
# application and once after having started it... (using /usr instead of
# /usr/bin/qgis)
# before running the app both usr/bin/qgis and /usr work
QgsApplication.setPrefixPath(r'/usr/bin/qgis', True)
  # py_run_string("QgsApplication.setPrefixPath(r'/usr', True)")
print QgsApplication.showSettings()
app = QgsApplication([], True)
# uncomment this line if there is trouble with processing.runalg
# under Linux this worked
# py_run_string("app.setPrefixPath('/usr', True)")  # change path for MAC
print app.showSettings()
QgsApplication.initQgis()
sys.path.append(r'/usr/share/qgis/python/plugins')
from processing.core.Processing import Processing
Processing.initialize()
import processing
from processing.core.Processing import Processing
Processing.initialize()
import processing

# # ParameterSelection required by get_args_man.py, algoptions, alghelp
# from processing.core.parameters import (
#   ParameterSelection,
#   ParameterRaster,
#   ParameterVector,
#   ParameterMultipleInput
# )
# from processing.gui.Postprocessing import handleAlgorithmResults
# # needed for open_help
# from processing.tools.help import createAlgorithmHelp
# # needed for qgis_session_info
# from processing.algs.saga.SagaAlgorithmProvider import SagaAlgorithmProvider
# from processing.algs.saga import SagaUtils
# from processing.algs.grass.GrassUtils import GrassUtils
# from processing.algs.grass7.Grass7Utils import Grass7Utils
# from processing.algs.otb.OTBAlgorithmProvider import OTBAlgorithmProvider
# from processing.algs.otb.OTBUtils import getInstalledVersion
# from processing.algs.taudem.TauDEMUtils import TauDEMUtils
# from osgeo import gdal
# from processing.tools.system import isWindows, isMac
# check if it works
processing.alglist()
canvas = QgsMapCanvas()
layer = QgsVectorLayer("/tmp/RtmpPWMR66/points.shp", 'points', 'ogr')
QgsMapLayerRegistry.instance().addMapLayer(layer)
# set extent to the extent of our layer
canvas.setExtent(layer.extent())
# set the map canvas layer set
canvas.setLayerSet([QgsMapCanvasLayer(layer)])  
canvas.resize(QSize(400, 400))
canvas.show()  # well, this works


# and exactly the same in R
Sys.setenv(PYTHONPATH="/usr/share/qgis/python")
Sys.setenv(LD_LIBRARY_PATH="/usr/lib")
# setting here the QGIS_PREFIX_PATH also works instead of running it twice
# later on
# Sys.setenv(QGIS_PREFIX_PATH = qgis_env$root)

library("reticulate")
# reproducing our py_cmd.py
py_run_string("import os, sys, re, webbrowser")
py_run_string("from qgis.core import *")
py_run_string("from osgeo import ogr")
py_run_string("from PyQt4.QtCore import *")
py_run_string("from PyQt4.QtGui import *")
py_run_string("from qgis.gui import *")
py_run_string("QgsApplication.setPrefixPath(r'/usr/bin/qgis', True)")
# it works if we call setPrefixPath two times, once before starting the
# application and once after having started it... (using /usr instead of
# /usr/bin/qgis)
# before running the app both usr/bin/qgis and /usr work
py_run_string("QgsApplication.setPrefixPath(r'/usr/bin/qgis', True)")
# py_run_string("QgsApplication.setPrefixPath(r'/usr', True)")
py_run_string("print QgsApplication.showSettings()")
py_run_string("app = QgsApplication([], True)")
# uncomment this line if there is trouble with processing.runalg
# under Linux this worked
py_run_string("app.setPrefixPath('/usr', True)")  # change path for MAC
py_capture_output(py_run_string("print app.showSettings()"))
py_run_string("QgsApplication.initQgis()")
py_run_string("sys.path.append(r'/usr/share/qgis/python/plugins')")
py_run_string("from processing.core.Processing import Processing")
py_run_string("Processing.initialize()")
py_run_string("import processing")
py_run_string("from processing.core.Processing import Processing")
py_run_string("Processing.initialize()")

py_run_string("canvas = QgsMapCanvas()")
py_run_string("canvas.show()") 
py_run_string("canvas = QgsMapCanvas()")
py_run_string("canvas.resize(QSize(400, 400))")
py_run_string("canvas.show()") 
# and this does not work, I don't know why, it's exactly the same code...
