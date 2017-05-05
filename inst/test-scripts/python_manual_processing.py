import os, sys, re, webbrowser
from qgis.core import *
from osgeo import ogr
from PyQt4.QtCore import *
from PyQt4.QtGui import *
from qgis.gui import *
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
