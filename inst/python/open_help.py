# copied from baseHelpForAlgorithm in processing\tools\help.py
# Author: Victor Olaya
# modified by: Jannes Muenchow

# from processing.tools.help import *
# find the provider (qgis, saga, grass, etc.)
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
