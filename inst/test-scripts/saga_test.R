if (FALSE) {
  devtools::load_all()
  library("reticulate")
  RQGIS:::setup_win(qgis_env = qgis_env)
  py_run_string("import os, sys")
  py_run_string("from qgis.core import *")
  py_run_string("from osgeo import ogr")
  py_run_string("from PyQt4.QtCore import *")
  py_run_string("from PyQt4.QtGui import *")
  py_run_string("from qgis.gui import *")
  py_run_string("QgsApplication.setPrefixPath(r'C:/OSGeo4W64/apps/qgis', True)")
  py_run_string("app = QgsApplication([], True)")
  py_run_string("QgsApplication.initQgis()")
  py_run_string("sys.path.append(r'C:/OSGeo4W64/apps/qgis/python/plugins')")
  py_run_string("from processing.core.Processing import Processing")
  py_run_string("Processing.initialize()")
  py_run_string("import processing")
  
  # ok, still works
  py_run_string("from processing.core.parameters import ParameterSelection")
  py_run_string("from processing.gui.Postprocessing import handleAlgorithmResults")
  # needed for open_help
  py_run_string("from processing.tools.help import createAlgorithmHelp")
  # needed for qgis_session_info
  py_run_string("from processing.algs.saga.SagaAlgorithmProvider import SagaAlgorithmProvider")
  py_run_string("from processing.algs.saga import SagaUtils")
  py_run_string("from processing.algs.grass.GrassUtils import GrassUtils")
  py_run_string("from processing.algs.grass7.Grass7Utils import Grass7Utils")
  py_run_string("from processing.algs.otb.OTBAlgorithmProvider import OTBAlgorithmProvider")
  py_run_string("from processing.algs.otb.OTBUtils import getInstalledVersion")
  py_run_string("from processing.algs.taudem.TauDEMUtils import TauDEMUtils")
  py_run_string("from osgeo import gdal")
  py_run_string("from processing.tools.system import isWindows, isMac")
  py_run_string("my_alg = Processing.getAlgorithm('saga:slopeaspectcurvature')")$my_alg
  
  py_file <- system.file("python", "python_funs.py", package = "RQGIS")
  py_run_file(py_file)
  # initialize our RQGIS class
  py_run_string("RQGIS = RQGIS()")
  
  data("dem")
  raster::writeRaster(dem, filename = "C:/Users/pi37pat/Desktop/dem.asc",
                      format = "ascii", prj = TRUE, overwrite = TRUE)
  # ok, this works, now find out what's wrong with reticulate RQGIS....
  py_run_string('processing.runalg("saga:slopeaspectcurvature", "C:/Users/pi37pat/Desktop/dem.asc", "0", "0", "0", "C:/Users/pi37pat/Desktop/slope.asc", None, None, None, None, None, None, None, None, None, None, None)')
  
  # restarting R and running it like this, doesn't work
  set_env("C:/OSGeo4W64/")
  open_app()
  py_run_string('processing.runalg("saga:slopeaspectcurvature", "C:/Users/pi37pat/Desktop/dem.asc", "0", "0", "0", "C:/Users/pi37pat/Desktop/slope.asc", None, None, None, None, None, None, None, None, None, None, None)')
  
  
}