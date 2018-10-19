open_app3 <- function(qgis_env = set_env()) {
  
  # check for server infrastructure
  check_for_server()
  
  # be a good citizen and restore the PATH
  settings <- as.list(Sys.getenv())
  # since we are adding quite a few new environment variables these will remain
  # (PYTHONPATH, QT_PLUGIN_PATH, etc.). We could unset these before exiting the
  # function but I am not sure if this is necessary
  
  # Well, well, not sure if we should change it back or if we at least have to
  # get rid off Anaconda Python or other Python binaries - yes, we do, otherwise
  # reticulate might run into problems when loading modules because it might try
  # to load them first from the other binaries indicated in PATH
  
  # on.exit(do.call(Sys.setenv, settings))
  
  # resetting system settings on exit causes that SAGA algorithms cannot be
  # processed anymore, find out why this is!!!
  
  if (Sys.info()["sysname"] == "Windows") {
    # run Windows setup
    setup_win3(qgis_env = qgis_env)
    
    # Ok, basically, we added a few new paths (especially under Windows) but
    # that's about it, we don't have to change that back. Only under Windows we
    # start with a clean, i.e. empty PATH, and delete everything what was in
    # there before, so we should at least add the old PATH to our newly created
    # one
    reset_path(settings)
  } else if (Sys.info()["sysname"] == "Linux" | Sys.info()["sysname"] == "FreeBSD") {
    setup_linux(qgis_env = qgis_env)
  } else if (Sys.info()["sysname"] == "Darwin") {
    setup_mac(qgis_env = qgis_env)
  }
  
  
  # make sure that QGIS is not already running (this would crash R) app =
  # QgsApplication([], True)  # see below
  # We can only run the test after we have set all the paths. Otherwise
  # reticulate would use another Python interpreter (e.g, Anaconda Python
  # instead of the Python interpreter delivered with QGIS) when running open_app
  # for the first time
  tmp <- try(
    expr = py_run_string("app")$app,
    silent = TRUE
  )
  if (!inherits(tmp, "try-error")) {
    stop("Python QGIS application is already running.")
  }
  
  py_run_string("import os, sys")
  py_run_string("from qgis.core import *")
  py_run_string("from osgeo import ogr")
  py_run_string("from PyQt5.QtCore import *")
  py_run_string("from PyQt5.QtGui import *")
  py_run_string("from qgis.gui import *")
  # native geoalgorithms
  py_run_string("from qgis.analysis import (QgsNativeAlgorithms)")
  # interestingly, under Linux the app would start also without running the next
  # two lines
  set_prefix <- paste0(
    "QgsApplication.setPrefixPath(r'",
    qgis_env$qgis_prefix_path, "', True)"
  )
  py_run_string(set_prefix)
  # not running the next line will produce following error message under Linux
  # QSqlDatabase: QSQLITE driver not loaded
  # QSqlDatabase: available drivers:
  # ERROR: Opening of authentication db FAILED
  # QSqlQuery::prepare: database not open
  # WARNING: Auth db query exec() FAILED
  py_run_string("QgsApplication.showSettings()")
  
  # not running the next two lines leads to a Qt problem when running 
  # QgsApplication([], True)
  # browseURL("http://wiki.qt.io/Deploy_an_Application_on_Windows")
  py_run_string("from qgis.PyQt.QtCore import QCoreApplication")
  # the strange thing is shell.exec(python3) works without it because here 
  # all Qt paths are available as needed as set in SET QT_PLUGIN_PATH
  # but these are not available when running Python3 via reticulate
  # py_run_string("a = QCoreApplication.libraryPaths()")$a  # empty list
  # so, we need to set them again 
  # I have looked them up in the QGIS 3 GUI using QCoreApplication.libraryPaths()
  # py_run_string("QCoreApplication.setLibraryPaths(['C:/OSGEO4~1/apps/qgis/plugins', 'C:/OSGEO4~1/apps/qgis/qtplugins', 'C:/OSGEO4~1/apps/qt5/plugins', 'C:/OSGeo4W64/apps/qt4/plugins', 'C:/OSGeo4W64/bin'])")
  py_run_string(
    sprintf("QCoreApplication.setLibraryPaths(['%s', '%s', '%s', '%s', '%s'])",
            file.path(qgis_env$root, "apps/qgis/plugins"),
            file.path(qgis_env$root, "apps/qgis/qtplugins"),
            file.path(qgis_env$root, "apps/qt5/plugins"),
            file.path(qgis_env$root, "apps/qt4/plugins"),
            file.path(qgis_env$root, "bin"))
  )
  # py_run_string("a = QCoreApplication.libraryPaths()")$a
  py_run_string("app = QgsApplication([], True)")
  py_run_string("QgsApplication.initQgis()")
  py_run_string(paste0("sys.path.append(r'", qgis_env$python_plugins, "')"))
  # add native geoalgorithms
  py_run_string("QgsApplication.processingRegistry().addProvider(QgsNativeAlgorithms())")
  py_run_string("from processing.core.Processing import Processing")
  # try:
  #py_run_string("from processing.core.Processing import *")
  py_run_string("Processing.initialize()")
  py_run_string("import processing")
  
  # starting from 2.14.17 and 2.18.11, QgsApplication.setPrefixPath changes the
  # decimal separator, I don't know why...
  # the next line should turn off locale-specific separators
  Sys.setlocale("LC_NUMERIC", "C")
  
  # attach further modules, our RQGIS class (needed for alglist, algoptions,
  # alghelp)
  py_file <- system.file("python", "python3_funs.py", package = "RQGIS")
  py_run_file(py_file)
  # instantiate/initialize RQGIS class
  py_run_string("RQGIS = RQGIS()")
}


setup_win3 <- function(qgis_env = set_env()) {
  # call o4w_env.bat from within R
  # not really sure, if we need the next line (just in case)
  Sys.setenv(OSGEO4W_ROOT = qgis_env$root)
  # shell("ECHO %OSGEO4W_ROOT%")
  # REM start with clean path
  # windir <- shell("ECHO %WINDIR%", intern = TRUE)
  # such error messages occurred:
  # [1]"'\\\\helix.klient.uib.no\\BioHome\\nboga'"
  # Jannes: this was the working directory apparently a server
  # [2] "CMD.EXE was started with the above path as the current directory."
  # [3] "UNC paths are not supported. Defaulting to Windows directory."
  # [4] "C:\\Windows"
  # Therefore, pick the last element (not sure if this will always work, well,
  # we will find out). Another solution would be to hard-code "C:/Windows" but
  # I don't know if system32 can always be found there...
  # windir <- windir[length(windir)]
  
  # maybe this is a more generic approach
  cwd <- getwd()
  on.exit(setwd(cwd))
  setwd("C:/")
  windir <- shell("ECHO %WINDIR%", intern = TRUE)
  windir <- normalizePath(windir, "/")
  
  # start with a fresh PATH
  Sys.setenv(PATH = paste(
    file.path(qgis_env$root, "bin"),
    file.path(windir, "system32"),
    windir,
    file.path(windir, "WBem"),
    sep = ";"
  ))
  # call all bat-files
  run_ini(qgis_env = qgis_env)
  # qt5_env.bat
  Sys.setenv(PATH = paste(file.path(qgis_env$root, "apps/qt5/bin"),
                          Sys.getenv("PATH"), sep = ";"))
  Sys.setenv(
    QT_PLUGIN_PATH = paste(file.path(qgis_env$root, "apps/qt5/plugins"),
                           Sys.getenv("QT_PLUGIN_PATH"), sep = ";"))
  # py3_env.bat
  Sys.setenv(PYTHONHOME = file.path(qgis_env$root,"apps/Python36"))
  Sys.setenv(PATH = paste(file.path(qgis_env$root, "apps/Python36"),
                          file.path(qgis_env$root, "apps/Python36/Scripts"),
                          Sys.getenv("PATH"), sep = ";"))
  
  # we need to make sure that qgis-ltr can also be used...
  my_qgis <- gsub(".*/", "", qgis_env$qgis_prefix_path)
  # add the directories where the QGIS libraries reside to search path
  # of the dynamic linker
  Sys.setenv(PATH = paste(
    Sys.getenv("PATH"),
    # this fails:
    # file.path(qgis_env$root, "apps", my_qgis), 
    # so you need to use /bin
    file.path(qgis_env$root, "apps", my_qgis, "bin"),
    sep = ";"
  ))
  # Sys.setenv(GDAL_FILENAME_IS_UTF8 = "YES")
  # set the PYTHONPATH variable, so that QGIS knows where to search for
  # QGIS libraries and appropriate Python modules
  python_path <- Sys.getenv("PYTHONPATH")
  python_add <- file.path(qgis_env$root, "apps", my_qgis, "python")
  if (!grepl(python_add, python_path)) {
    python_path <- paste(python_path, python_add, sep = ";")
    # if PYTHONPATH = "", this results in ';C:/OSGeo4W64/apps/qgis/python'
    python_path <- gsub("^;", "", python_path)
    Sys.setenv(PYTHONPATH = python_path)
  }
  
  # defining QGIS prefix path (i.e. without bin)
  Sys.setenv(QGIS_PREFIX_PATH = file.path(qgis_env$root, "apps", my_qgis))
  Sys.setenv(
    QT_PLUGIN_PATH = paste(file.path(qgis_env$root, "apps/qgis/qtplugins"),
                           file.path(qgis_env$root, "apps/qt5/plugins"), 
                           sep = ";"))
  # shell.exec("python")  # yeah, it works!!!
  # !!!Try to make sure that the right Python version is used!!!
  use_python(
    file.path(qgis_env$root, "bin/python3.exe"),
    required = TRUE
  )
  # We do not need the subsequent test for Linux & Mac since the Python
  # binary should be always found under  /usr/bin
  
  # compare py_config path with set_env path!!
  a <- py_config()
  # py_config() adds following paths to PATH:
  # "C:\\OSGeo4W64\\bin;C:\\OSGeo4W64\\bin\\Scripts;
  py_path <- gsub("/bin.*", "", normalizePath(a$python, "/"))
  if (!identical(py_path, qgis_env$root)) {
    stop("Wrong Python binary. Restart R and check again!")
  }
}

convert_to_tuple <- function(x) {
  vals <- vapply(x, function(i) {
    # get rid off 'strange' or incomplete shellQuotes
    tmp <- unlist(strsplit(as.character(i), ""))
    tmp <- tmp[tmp != "\""]
    # paste the argument together again
    tmp <- paste(tmp, collapse = "")
    # shellQuote argument if is not True, False or None
    ifelse(grepl("True|False|None", tmp), tmp, shQuote(tmp))
  }, character(1))
  # paste the function arguments together
  paste(vals, collapse = ", ")
}




