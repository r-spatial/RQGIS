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
  py_run_string("my_alg = Processing.getAlgorithm('saga:slopeaspectcurvature')")$my_alg
  
  data("dem")
  raster::writeRaster(dem, filename = "C:/Users/pi37pat/Desktop/dem.asc",
                      format = "ascii", prj = TRUE, overwrite = TRUE)
  # ok, this works, now find out what's wrong with reticulate RQGIS....
  py_run_string('processing.runalg("saga:slopeaspectcurvature", "C:/Users/pi37pat/Desktop/dem.asc", "0", "0", "0", "C:/Users/pi37pat/Desktop/slope.asc", None, None, None, None, None, None, None, None, None, None, None)')
}