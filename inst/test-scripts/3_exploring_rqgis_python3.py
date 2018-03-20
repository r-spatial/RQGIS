# see qgis-dev/python/plugins/processing/tools/general.py
# QgsApplication.processingRegistry().createAlgorithmById(algOrName)

# find algorithms
QgsApplication.processingRegistry().algorithms()[1].id()
algs = []
for i in QgsApplication.processingRegistry().algorithms():
	algs.append(i.id())

len(algs)  # 873
alg = "grass7:r.slope.aspect"
# alg = algs[136]
alg = QgsApplication.processingRegistry().createAlgorithmById(alg)	
print('{} ({})\n'.format(alg.displayName(), alg.id()))
print(alg.shortHelpString())

# call the installed help URL
alg.helpUrl()
# unfortunately, it's the help of GRASS 7.4
# file:///C:/OSGeo4W64/apps/grass/grass-7.4.0/docs/html/r.slope.aspect.html

alg.params[0].description()
alg.params[0].asScriptCode()
alg.params[0].defaultValue()
alg.params[0].name()
alg.params[0].dependsOnOtherParameters()
alg.params[0].dynamicPropertyDefinition().dataType()
alg.params[0].type()
alg.params[0].typeName()
alg.params[0].toolTip()
# retrieve options for a specific parameter
alg.params[1].toVariantMap()
# name of the parameter
alg.params[1].toVariantMap()["name"]
# options for a specific parameter
alg.params[1].toVariantMap()["options"]
# parameter default value
alg.params[1].toVariantMap()["default"]

# all parameter names
for i in alg.params:
  print(i.name())

# all default values
for i in alg.params:
  print(i.defaultValue())

# all types
for i in alg.params:
  print(i.type())

# some information
for i in alg.params:
  i.toolTip()

# output information
outs = dict()
for i in alg.outputDefinitions():
  outs[i.name()] = i.type()

  
# find QGIS version number
# https://gis.stackexchange.com/questions/268443/getting-users-qgis-version-using-pyqgis
from qgis.core import *
qgis.core.Qgis  # instead of qgis.core.QGis

# From: https://qgis.org/api/api_break.html
# Processing
#
#    Algorithm providers now subclass the c++ QgsProcessingProvider class, and must be adapted to the API for QgsProcessingProvider. Specifically, getName() should be replaced with id(), getDescription() with name(), and getIcon with icon(). AlgorithmProvider was removed.
#    Algorithm's processAlgorithm method now passes a QgsProcessingFeedback object instead of the loosely defined progress parameter. Algorithms will need to update their use of the progress argument to utilize the QgsProcessingFeedback API.
#    Similarly, Python processing scripts no longer have access to a progress variable for reporting their progress. Instead they have a feedback object of type QgsProcessingFeedback, and will need to adapt their use of progress reporting to the QgsProcessingFeedback API.
#    SilentProgress was removed. Use the base QgsProcessingFeedback class instead.
#    algList was removed. Use QgsApplication.processingRegistry() instead.
#    Processing.algs was removed. QgsApplication.processingRegistry().algorithms() instead.
#    ProcessingLog should not be used when reporting log messages from algorithms. Use QgsMessageLog.logMessage() instead.
#    dataobjects.getLayerFromString() was removed. Use QgsProcessingUtils.mapLayerFromString() instead.
#    vector.bufferedBoundingBox() was removed. Use QgsRectangle.grow() instead.
#    vector.duplicateInMemory() was removed.
#    vector.spatialindex() was removed. Use QgsProcessingUtils.createSpatialIndex() instead.
