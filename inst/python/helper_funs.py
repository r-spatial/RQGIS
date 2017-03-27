# Author: Barry Rowlingson
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

# RQGIS class should make it unlikely that somebody accidentally overwrites our
# methods defined within this class.
# A basic class consists only of the class keyword, the name of the class, and
# the class from which the new class inherits in parentheses. For now, our 
# classes will inherit from the object class, like so:
# class RQGIS(object):
# Do we need object-power, I guess not:
class RQGIS:
  def __init__(self):
    # well, you need to specify something here, e.g.,
    # self.x = ""
    # could be also something useful. If not needed, use pass
    pass
  
  # Author: Jannes Muenchow, Victor Olaya
  # Method to retrieve geoalgorithm arguments
  def get_args_man(self, alg):
    alg = Processing.getAlgorithm(alg)
    vals = []
    params = []
    opts = list()
    if alg is None:
      sys.exit('Specified algorithm does not exist!')
      # return 'Specified algorithm does not exist!'
    alg = alg.getCopy()
    for param in alg.parameters:
      params.append(param.name)
      vals.append(param.getValueAsCommandLineParameter())
      opts.append(isinstance(param, ParameterSelection))
    for out in alg.outputs:
      params.append(out.name)
      vals.append(out.getValueAsCommandLineParameter())
      opts.append(isinstance(out, ParameterSelection))
    args = [params, vals, opts]
    return args      
    
  # Author: Victor Olaya, Jannes Muenchow
  # copied from baseHelpForAlgorithm in processing\tools\help.py
  # from processing.tools.help import *
  # find the provider (qgis, saga, grass, etc.)
  
  def open_help(self, alg):
    alg = Processing.getAlgorithm(alg)
    provider = alg.provider.getName().lower()
    # to which group does the algorithm belong (e.g., vector_table_tools)
    groupName = alg.group.lower()
    # format the groupName in the QGIS way
    groupName = groupName.replace('[', '').replace(']', '').replace(' - ', '_')
    groupName = groupName.replace(' ', '_')
    if provider == 'saga':
      alg2 = alg.getCopy()
      groupName = alg2.undecoratedGroup
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
    algName = alg.name.lower().replace(' ', '-')
    # just use valid characters
    validChars = ('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRS' +
                  'TUVWXYZ0123456789_')
    safeGroupName = ''.join(c for c in groupName if c in validChars)
    validChars = validChars + '-'
    safeAlgName = ''.join(c for c in algName if c in validChars)
    # which QGIS version are we using
    version = '.'.join(QGis.QGIS_VERSION.split('.')[0:2])
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
  
  # Author: Victor Olaya, Jannes Muenchow
  def qgis_session_info(self):
    # import re
    # from processing.algs.saga.SagaAlgorithmProvider import SagaAlgorithmProvider
    # from processing.algs.saga import SagaUtils
    # from processing.algs.grass.GrassUtils import GrassUtils
    # from processing.algs.grass7.Grass7Utils import Grass7Utils
    # from processing.algs.otb.OTBAlgorithmProvider import OTBAlgorithmProvider
    # from processing.algs.otb.OTBUtils import getInstalledVersion
    # from processing.algs.taudem.TauDEMUtils import TauDEMUtils
    # from osgeo import gdal
    # from processing.tools.system import isWindows, isMac
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
    return [qgis, g6, g7, saga, saga_versions]
    
    # ls = [qgis, g6, g7, saga, saga_versions, otb, gdal]
    ### TauDEM versions (currently not in use because no function to extract
    ### Taudem version in 'TauDEMUtils')
    # "TauDEMUtils.taudemMultifilePath()",
