import re
from processing.algs.saga.SagaAlgorithmProvider import SagaAlgorithmProvider
from processing.algs.saga import SagaUtils
from processing.algs.grass.GrassUtils import GrassUtils
from processing.algs.grass7.Grass7Utils import Grass7Utils
from processing.algs.otb.OTBAlgorithmProvider import OTBAlgorithmProvider
from processing.algs.otb.OTBUtils import getInstalledVersion
from processing.algs.taudem.TauDEMUtils import TauDEMUtils
from osgeo import gdal
from processing.tools.system import isWindows, isMac
# QGIS version
qgis = QGis.QGIS_VERSION
# GRASS versions
# grassPath returns "" if called under Linux and if there is no GRASS 
# installation
GrassUtils.checkGrassIsInstalled()
g6 = GrassUtils.isGrassInstalled
if g6 is True and isWindows():
  g6 = GrassUtils.grassPath()
  g6 = re.findall('grass-.*', g6)
if g6 is True and isMac:
  g6 = GrassUtils.grassPath()
  g6 = os.listdir(g6)
  delim = ';'
  g6 = delim.join(g6)
  g6 = re.findall(';(grass[0-9].);', g6)
Grass7Utils.checkGrass7IsInstalled()
g7 = Grass7Utils.isGrass7Installed
if g7 is True and isWindows():
  g7 = Grass7Utils.grassPath()
  g7 = re.findall('grass-.*', g7)
if g7 is True and isMac:
  g7 = Grass7Utils.grassPath()
  g7 = os.listdir(g7)
  delim = ';'
  g7 = delim.join(g7)
  g7 = re.findall(';(grass[0-9].);', g7)
# installed SAGA version usable with QGIS
saga = SagaUtils.getSagaInstalledVersion()
# supported SAGA versions
my_dict = SagaAlgorithmProvider.supportedVersions
saga_versions = my_dict.keys()
saga_versions.sort()
 
# this is good to have for the future, but so far, I would not report 
# these software versions since we don't know if they actually work
# with QGIS (without additional functions such as run_taudem...)
# OTB versions
# "otb = getInstalledVersion()",
# "otb = OTBUtils.getInstalledVersion()",

# GDAL
# "gdal = gdal.VersionInfo('VERSION_NUM')",
# "gdal = '.'.join([gdal[0], gdal[2], gdal[4]])",

# write list for 'out.csv'
ls = [qgis, g6, g7, saga, saga_versions]

# ls = [qgis, g6, g7, saga, saga_versions, otb, gdal]
### TauDEM versions (currently not in use because no function to extract
### Taudem version in 'TauDEMUtils')
# "TauDEMUtils.taudemMultifilePath()",
      