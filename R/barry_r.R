init_processing <- function(){
  code = '
  
  import sys
  
  # initialising twice crashes Python/R
  if not locals().has_key("app"):
  
  from qgis.core import *
  from qgis.gui import *
  
  sys.path.append("/usr/share/qgis/python/plugins")
  from PyQt4.QtCore import *
  from PyQt4.QtGui import *
  app = QgsApplication([], True)
  app.setPrefixPath("/usr", True)
  app.initQgis()
  from processing.core.Processing import Processing
  Processing.initialize()
  
  import processing
  
  # handy output catcher because capture.output in R
  # wont catch Python output
  
  from cStringIO import StringIO
  
  class Capturing(list):
  def __enter__(self):
  self._stdout = sys.stdout
  sys.stdout = self._stringio = StringIO()
  return self
  def __exit__(self, *args):
  self.extend(self._stringio.getvalue().splitlines())
  sys.stdout = self._stdout
  
  '
  rPython::python.exec(code)
  
}


algs <- function(q=""){
  # can't see how to easily do this with python.call so make a string and exec:
  code = sprintf("
                 with Capturing() as output:
                 processing.alglist('%s')
                 ", q)
  
  rPython::python.exec(code)
  rPython::python.get("output")
}

format_algs <- function(algstrings){
  parts = do.call(rbind.data.frame,strsplit(algstrings, ">"))
  names(parts)=c("desc","name")
  parts$name = as.character(parts$name)
  parts$desc = gsub("(-)*$","", parts$desc)
  parts[,c("name","desc")]
  
}


centroids <- function(inputshape, outputshape){
  rPython::python.call("processing.runalg",
                       "qgis:polygoncentroids",
                       inputshape,
                       outputshape
  )
}