library("reticulate")

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

# Windows
py_run_string("os.system('SET OSGEO4W_ROOT=C:\\OSGeo4W64')")
py_run_string("os.system('call '%OSGEO4W_ROOT%'\\bin\\o4w_env.bat')")
# ok, command line is not kept open...

command = []
command.append("os.system('SET OSGEO4W_ROOT=C:\\OSGeo4W64')")
command.append("os.system('call '%OSGEO4W_ROOT%'\\bin\\o4w_env.bat')")
