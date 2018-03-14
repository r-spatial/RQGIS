def qgis_session_info():
    import re
    from processing.algs.saga.SagaAlgorithmProvider import SagaAlgorithmProvider
    from processing.algs.saga import SagaUtils
    from processing.algs.grass7.Grass7Utils import Grass7Utils
    from osgeo import gdal
    from processing.tools.system import isWindows, isMac
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

