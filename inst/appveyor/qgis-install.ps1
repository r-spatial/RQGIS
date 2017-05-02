Function Install-QGIS {
  [CmdletBinding()]
  Param()

  if ( (Test-Path Env:\qgis_dev) ) {
    start "" /wait "http://qgis.org/downloads/QGIS-OSGeo4W-2.18.7-1-Setup-x86_64.exe" /S 
  }
  if ( (Test-Path Env:\qgis_ltr) ) {
    start "" /wait "http://qgis.org/downloads/QGIS-OSGeo4W-2.14.14-1-Setup-x86_64.exe" /S 
  }
}