@echo off
SET OSGEO4W_ROOT=/applications/QGIS.app/Contents
@echo off
path %PATH%;%OSGEO4W_ROOT%/Resources/python/qgis
path %PATH%;%OSGEO4W_ROOT%/MacOS/grass/lib
set PYTHONPATH=%PYTHONPATH%;%OSGEO4W_ROOT%/Resources/python;
set /usr/local/lib/python2.7/site-packages
set QGIS_PREFIX_PATH=%OSGEO4W_ROOT%/MacOS/lib/qgis
