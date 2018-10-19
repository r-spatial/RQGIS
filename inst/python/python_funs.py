"""
***************************************************************************
    python_funs.py
    ---------------------
    Date                 : May 2017
    Copyright            : (C) 2017 by Jannes Muenchow, Victor Olaya
    Email                : jannes dot muenchow at uni minus jena dot de
***************************************************************************
*                                                                         *
*   This program is free software; you can redistribute it and/or modify  *
*   it under the terms of the GNU General Public License as published by  *
*   the Free Software Foundation; either version 2 of the License, or     *
*   (at your option) any later version.                                   *
*                                                                         *
***************************************************************************
"""

__author__ = 'Jannes Muenchow, Victor Olaya'
__date__ = 'May 2017'
__copyright__ = '(C) 2017, Jannes Muenchow, Victor Olaya'

from processing.core.Processing import Processing
Processing.initialize()
import processing
# ParameterSelection required by get_args_man.py, algoptions, alghelp
from processing.core.parameters import (
  ParameterSelection,
  ParameterRaster,
  ParameterVector,
  ParameterMultipleInput
)
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
    # make sure you don't overwrite default values!
    alg = alg.getCopy()
    vals = []
    params = []
    output = []
    type_name = []
    opts = list()
    if alg is None:
      sys.exit('Specified algorithm does not exist!')
      # return 'Specified algorithm does not exist!'
    for param in alg.parameters:
      params.append(param.name)
      vals.append(param.getValueAsCommandLineParameter())
      opts.append(isinstance(param, ParameterSelection))
      output.append(False)
      type_name.append(param.typeName())
    for out in alg.outputs:
      params.append(out.name)
      vals.append(out.getValueAsCommandLineParameter())
      opts.append(isinstance(out, ParameterSelection))
      output.append(True)
      type_name.append(param.typeName())
    # args = [params, vals, opts, type_name]
    args = dict(zip(["params", "vals", "opts", "output", "type_name"], \
                    [params, vals, opts, output, type_name]))
    return args      
    
  # Author: Victor Olaya, Jannes Muenchow
  # copied from baseHelpForAlgorithm in processing\tools\help.py
  # from processing.tools.help import *
  # find the provider (qgis, saga, grass, etc.)
  
  def open_help(self, alg):
    alg = Processing.getAlgorithm(alg)
    alg = alg.getCopy()
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
      # extract everything followed by grass-, i.e. extract the version number
      g6 = re.findall("grass-(.*)", g6)
    if g6 is True and isMac():
      g6 = GrassUtils.grassPath()[0:21]
      g6 = os.listdir(g6)
      delim = ';'
      g6 = delim.join(g6)
      g6 = re.findall('[0-9].[0-9].[0-9]', g6)
    Grass7Utils.checkGrass7IsInstalled()
    g7 = Grass7Utils.isGrass7Installed
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
    # installed SAGA version usable with QGIS
    saga = SagaUtils.getSagaInstalledVersion()
    # supported SAGA versions
    try:
      # supportedVersions were deleted from SagaAlgorithmProvider since 
      # QGIS 2.18.10. At least this is the case with custom applications...
      my_dict = SagaAlgorithmProvider.supportedVersions
      saga_versions = my_dict.keys()
      saga_versions.sort()
    except:
      # with QGIS 2.18.10 only SAGA 2.3.0 and 2.3.1 is suppported 
      # well, observe next QGIS releases and try to avoid the hard-coding!
      saga_versions = [""]
    # GDAL
    gdal_v = gdal.VersionInfo('VERSION_NUM')
    gdal_v = '.'.join([gdal_v[0], gdal_v[2], gdal_v[4]])
    
    ## this is good to have for the future, but so far, I would not report 
    ## these software versions since we don't know if they actually work
    ## with QGIS (without additional functions such as run_taudem...)
    ## OTB versions
    # otb = getInstalledVersion()
    # otb = OTBUtils.getInstalledVersion()
    ## TauDEM versions (currently not in use because no function to extract
    ## Taudem version in 'TauDEMUtils')
    # TauDEMUtils.taudemMultifilePath()
    
    # finally, put it all into a named dictionary
    keys = ["qgis_version", "gdal", "grass6", "grass7", "saga",\
            "supported_saga_versions"]
    values = [qgis, gdal_v, g6, g7, saga, saga_versions]
    info = dict(zip(keys, values))
    return info
      
  # function inspired by processing.algoptions  
  def get_options(self, alg):
    alg = Processing.getAlgorithm(alg)
    # just in case, make sure to not overwrite any default values
    alg = alg.getCopy()
    # create a dictionary
    d = dict()
    for param in alg.parameters:
      if isinstance(param, ParameterSelection):
        # keys of the dictionary are the function parameters for which one can
        # specify a selection
        d[param.name] = []
        for option in param.options:
          # the values are the several options for a specific parameter
          d[param.name].append(option)
    return d
  
  # check if all necessary function arguments were provided
  # inspired by runAlgorithm from processing/core/Processing 
  def check_args(self, alg, args):
    alg = Processing.getAlgorithm(alg)
    # make sure to not overwrite any default values
    # using param.setValue would do so
    alg = alg.getCopy()
    i = 0
    d = dict()
    # alg.parameters does not return output values
    # alg.outputs would do so (see get_args_man)
    for param in alg.parameters:
      if not param.hidden:
        if not param.setValue(args[i]):
          d[param.name] = args[i]
        i = i + 1
    return d
