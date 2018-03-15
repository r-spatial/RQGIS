import re
import webbrowser

from processing.algs.saga.SagaAlgorithmProvider import SagaAlgorithmProvider
from processing.algs.saga import SagaUtils
from processing.algs.grass7.Grass7Utils import Grass7Utils
from osgeo import gdal
from processing.tools.system import isWindows, isMac


def qgis_session_info():
  # import re
  # from processing.algs.saga.SagaAlgorithmProvider import SagaAlgorithmProvider
  # from processing.algs.saga import SagaUtils
  # from processing.algs.grass7.Grass7Utils import Grass7Utils
  # from osgeo import gdal
  # from processing.tools.system import isWindows, isMac
  
  # QGIS version
  qgis = Qgis.QGIS_VERSION
  # GRASS7 version
  g7 = Grass7Utils.isGrassInstalled
  if g7 is True and isWindows():
    g7 = Grass7Utils.grassPath()
    g7 = re.findall('grass-(.*)',  g7)
  if g7 is True and isMac():
    g7 = Grass7Utils.grassPath()[0:21]
    g7 = os.listdir(g7)
    delim = ';'
    g7 = delim.join(g7)
    #g7 = re.findall(';(grass[0-9].);', g7)
    g7 = re.findall('[0-9].[0-9].[0-9]', g7)
  # installed SAGA version
  saga = SagaUtils.getInstalledVersion()
  # GDAL
  gdal_v = gdal.VersionInfo('VERSION_NUM')
  gdal_v = '.'.join([gdal_v[0], gdal_v[2], gdal_v[4]])
  
  # finally, put it all into a named dictionary
  keys = ["qgis_version", "gdal", "grass7", "saga"]
  values = [qgis, gdal_v, g7, saga]
  info = dict(zip(keys, values))
  return info

def get_options(alg):
  alg = QgsApplication.processingRegistry().createAlgorithmById(alg)	
  opts = dict()
  for i in alg.params:
    tmp = i.toVariantMap()
    if "options" in tmp.keys():
      out = list()
      ls = tmp["options"]
      for j in range(len(ls)):
        out.append(str(j) + " - " + ls[j])
      key = tmp["name"] + "(" + tmp["description"] + ")"
      opts[key] = out  
  return(opts)


def open_help(alg):
  # import re
  # import webbrowser
  alg = QgsApplication.processingRegistry().createAlgorithmById(alg)	
  provider = alg.provider().name().lower()
  # to which group does the algorithm belong (e.g., vector_table_tools)
  groupName = alg.group().lower()
  # format the groupName in the QGIS way
  groupName = groupName.replace('[', '').replace(']', '').replace(' - ', '_')
  groupName = groupName.replace(' ', '')
  if provider == 'saga':
    groupName = alg.undecorated_group
    groupName = groupName.replace('ta_', 'terrain_analysis_')
    groupName = groupName.replace('statistics_kriging', 'kriging')
    groupName = re.sub('^statistics_.*', 'geostatistics', groupName)
    groupName = re.sub('visualisation', 'visualization', groupName)
    groupName = re.sub('_preprocessor', '_hydrology', groupName)
    groupName = groupName.replace('sim_', 'simulation_')
  # retrieve the command line name (worked for 2.8...)
  # "cmdLineName = alg.commandLineName()",
  # "algName = cmdLineName[cmdLineName.find(':') + 1:].lower()",
  # for 2.14 we cannot use the algorithm name 
  # (now you have to test all SAGA and QGIS functions again...)
  algName = alg.displayName().lower().replace(' ', '-')
  # just use valid characters
  validChars = ('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRS' +
                'TUVWXYZ0123456789_')
  safeGroupName = ''.join(c for c in groupName if c in validChars)
  validChars = validChars + '-'
  safeAlgName = ''.join(c for c in algName if c in validChars)
  # which QGIS version are we using
  version = '.'.join(Qgis.QGIS_VERSION.split('.')[0:2])
  # version = "2.18"
  # build the html to the help file
  url = ('https:///docs.qgis.org/%s/en/docs/user_manual/' +
         'processing_algs/%s/%s.html#%s') % (version, provider,
         safeGroupName, safeAlgName)
  # suppress error messages raised by the browser, e.g.,
  # console.error: CustomizableUI: 
  # TypeError: aNode.previousSibling is null -- 
  #  resource://app/modules/CustomizableUI.jsm:4294
  # Solution was found here:
  # paste0("http://stackoverflow.com/questions/2323080/",
  #        "how-can-i-disable-the-webbrowser-message-in-python")
  savout = os.dup(1)
  os.close(1)
  os.open(os.devnull, os.O_RDWR)
  try:
    webbrowser.open(url)
  finally:
    os.dup2(savout, 1)
