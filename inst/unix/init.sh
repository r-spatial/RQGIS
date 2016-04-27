@echo off
export OSGEO4W_ROOT=/applications/QGIS.app/Contents
@echo off
export DYLD_LIBRARY_PATH=%OSGEO4W_ROOT%/MacOS/lib/:/Applications/QGIS.app/Contents/Frameworks/
export PYTHONPATH=%OSGEO4W_ROOT%/Resources/python/
export QGIS_PREFIX_PATH=%OSGEO4W_ROOT%/MacOS/lib/qgis
