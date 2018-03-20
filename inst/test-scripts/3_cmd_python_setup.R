# 2 ways to start a custom application, and both can be executed from within R

#**********************************************************
# 1. Verbose version---------------------------------------
#**********************************************************

# 1.1 Terminal version====================================
#*********************************************************
REM Basically step-by-step version of C:/OSGeo4W64/bin/python-qgis.bat 
REM run in terminal
@echo off
SET OSGEO4W_ROOT=C:\OSGeo4W64
call "%OSGEO4W_ROOT%"\bin\o4w_env.bat
call qt5_env.bat
call py3_env.bat
@echo off
path %OSGEO4W_ROOT%\apps\qgis\bin;%PATH%
  set QGIS_PREFIX_PATH=%OSGEO4W_ROOT:\=/%/apps/qgis
set GDAL_FILENAME_IS_UTF8=YES
REM Set VSI cache to be used as buffer, see #6448
set VSI_CACHE=TRUE
set VSI_CACHE_SIZE=1000000
set QT_PLUGIN_PATH=%OSGEO4W_ROOT%\apps\qgis\qtplugins;%OSGEO4W_ROOT%\apps\qt5\plugins
set PYTHONPATH=%OSGEO4W_ROOT%\apps\qgis\python;%PYTHONPATH%
  set QGIS_PREFIX_PATH=%OSGEO4W_ROOT%\apps\qgis
@echo on
REM open Python3
REM "%PYTHONHOME%\python"
REM this also works
python3

# 1.2 R(QGIS) version=====================================
#*********************************************************
Sys.setenv(OSGEO4W_ROOT = "C:\\OSGeo4W64")
shell("ECHO %OSGEO4W_ROOT%")
# REM start with clean path
shell("ECHO %WINDIR%", intern = TRUE)
Sys.setenv(PATH = "C:\\OSGeo4W64\\bin;C:\\WINDOWS\\system32;C:\\WINDOWS;C:\\WINDOWS\\WBem")
Sys.setenv(PYTHONHOME = "C:\\OSGeo4W64\\apps\\Python36")
Sys.setenv(PATH = paste("C:\\OSGeo4W64\\apps\\Python36",
                        "C:\\OSGeo4W64\\apps\\Python36\\Scripts",
                        Sys.getenv("PATH"), sep = ";"))
Sys.setenv(PATH = paste("C:\\OSGeo4W64\\apps\\qt5\\bin",
                        Sys.getenv("PATH"), sep = ";"))

# Sys.setenv(QT_PLUGIN_PATH = "C:\\OSGeo4W64\\apps\\qgis\\qtplugins;C:\\OSGeo4W64\\apps\\qt5\\plugins")
Sys.setenv(QT_PLUGIN_PATH = "C:/OSGEO4~1/apps/qgis/plugins;C:/OSGEO4~1/apps/qgis/qtplugins;C:/OSGEO4~1/apps/qt5/plugins;C:/OSGeo4W64/apps/qt4/plugins;C:/OSGeo4W64/bin")

#Sys.setenv(QT_RASTER_CLIP_LIMIT = 4096)
Sys.setenv(PATH = paste(Sys.getenv("PATH"),
                        "C:\\OSGeo4W64\\apps\\qgis\\bin", sep = ";"))
Sys.setenv(PYTHONPATH = paste("C:\\OSGeo4W64\\apps\\qgis\\python",
                              Sys.getenv("PYTHONPATH"), sep = ";"))
Sys.setenv(QGIS_PREFIX_PATH = "C:\\OSGeo4W64\\apps\\qgis")
# set QT_PLUGIN_PATH=%OSGEO4W_ROOT%\apps\qgis\qtplugins;%OSGEO4W_ROOT%\apps\qt5\plugins
shell.exec("python3")  # yeah, it works!!!
shell.exec("C:\\OSGeo4W64\\apps\\Python36\\python")


#**********************************************************
# 2. Batchfile version-------------------------------------
#**********************************************************

# 2.1 Terminal version=====================================
#**********************************************************
REM Run in terminal
C:/OSGeo4W64/bin/python-qgis.bat

# 2.2 R version============================================
#**********************************************************
shell.exec("C:/OSGeo4W64/bin/python-qgis.bat")
