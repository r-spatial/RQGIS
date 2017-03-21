if (FALSE){
library("reticulate")
library("dplyr")

# initialising twice crashes Python/R
# if not locals().has_key("app"):  # you have to implement that (Barry)

#**********************************************************
# Linux----------------------------------------------------
#**********************************************************

# in the cmd there was something else you should add this just in case (using
# Sys.getenv)!!! before running all the subsequent stuff

py_run_string("import os, sys")
py_run_string("from qgis.core import *")
py_run_string("from osgeo import ogr")
py_run_string("from PyQt4.QtCore import *")
py_run_string("from PyQt4.QtGui import *")
py_run_string("from qgis.gui import *")
py_run_string("QgsApplication.setPrefixPath('/usr/bin/qgis', True)")
py_run_string("app = QgsApplication([], True)")
py_run_string("QgsApplication.initQgis()")
py_run_string("sys.path.append(r'/usr/share/qgis/python/plugins')")
py_run_string("from processing.core.Processing import Processing")
py_run_string("Processing.initialize()")
py_run_string("import processing")
py_run_string("processing.alglist()")

#**********************************************************
# WINDOWS--------------------------------------------------
#**********************************************************

py_run_string("os.system('SET OSGEO4W_ROOT=C:\\OSGeo4W64')")
py_run_string("os.system('call '%OSGEO4W_ROOT%'\\bin\\o4w_env.bat')")
# ok, command line is not kept open...

library("RQGIS")
env <- set_env("C:/OSGeo4W64/", ltr = FALSE)

# find out running the batch script and opening python and then executing 
# following lines lets you access which Python executable we are actually using 
# import sys print(sys.executable) for QGIS 2.18.4 it was: 
# C:\\OSGEO4~1\\bin\\python.exe' what is really interesting running the same 
# from the Python console in QGIS 2.18.4, it tells us 
# "C:\OSGEO4~1\bin\qgis-bin.exe; so maybe this is also why sometimes the outputs
# differ
library("reticulate")
use_python("C:/OSGeo4W64/apps/qgis-ltr/python/", required = TRUE)
use_python(python = "C:/OSGeo4W64/bin/python-ltr.exe", required = TRUE)
use_python(python = "C:/Python27/ArcGIS10.2/python.exe", required = TRUE)
py_config()

reticulate:::py_discover_config("C:/OSGeo4W64/bin/python.exe")
reticulate:::py_discover_config("C:/Python27/ArcGIS10.2/python")


# Sys.setenv(OSGEO4W_ROOT = "C:\\OSGeo4W64")
# adding things to path
# Sys.setenv(PATH = paste(Sys.getenv("PATH"), 
#                         "C:\\OSGeo4W64\\apps\\qgis-ltr\\bin", sep = ";"))
# confirms that we are actually modifying the PATH
# shell("PATH")
# Sys.setenv(PYTHONPATH = paste("C:\\OSGeo4W64\\apps\\qgis-ltr\\python",
#                                Sys.getenv("PYTHONPATH"), sep = ";"))
# Sys.getenv("PYTHONPATH")         
# ok, this doesn't change anything...
# shell("PYTHONPATH")
# ah, something is there, I just don't have a clue about cmd-stuff...
# shell("%PYTHONPATH%")
# right I remember you got to use ECHO
# shell("ECHO %PYTHONPATH%")  # ok, there we go...

# reticulate:::use_python

# not really sure, if we need the next line (just in case)
Sys.setenv(OSGEO4W_ROOT = "C:\\OSGeo4W64")
shell("ECHO %OSGEO4W_ROOT%")
# REM start with clean path
shell("ECHO %WINDIR%", intern = TRUE)
Sys.setenv(PATH = "C:\\OSGeo4W64\\bin;C:\\WINDOWS\\system32;C:\\WINDOWS;C:\\WINDOWS\\WBem")
Sys.setenv(PYTHONHOME = "C:\\OSGeo4W64\\apps\\Python27")
Sys.setenv(PATH = paste("C:\\OSGeo4W64\\apps\\Python27\\Scripts",
                        Sys.getenv("PATH"), sep = ";"))
Sys.setenv(QT_PLUGIN_PATH = "C:\\OSGeo4W64\\apps\\Qt4\\plugins")
Sys.setenv(QT_RASTER_CLIP_LIMIT = 4096)
Sys.setenv(PATH = paste(Sys.getenv("PATH"),
                        "C:\\OSGeo4W64\\apps\\qgis-ltr\\bin", sep = ";"))
Sys.setenv(PYTHONPATH = paste("C:\\OSGeo4W64\\apps\\qgis-ltr\\python",
                              Sys.getenv("PYTHONPATH"), sep = ";"))
Sys.setenv(QGIS_PREFIX_PATH = "C:\\OSGeo4W64\\apps\\qgis-ltr")
shell.exec("python")  # yeah, it works!!!
library("reticulate")
py_config()  # perfect, that's what we want to see!!!
# but what if you have installed an Anaconda Python, does it still work???
# maybe because we cleaned the path, but I am not sure...
py_run_string("import os, sys")
py_run_string("from qgis.core import *")
py_run_string("from osgeo import ogr")
py_run_string("from PyQt4.QtCore import *")
py_run_string("from PyQt4.QtGui import *")
py_run_string("from qgis.gui import *")
py_run_string("QgsApplication.setPrefixPath('C:/OSGeo4W64/apps/qgis-ltr', True)")
py_run_string("app = QgsApplication([], True)")
py_run_string("QgsApplication.initQgis()")
py_run_string("sys.path.append(r'C:/OSGeo4W64/apps/qgis-ltr/python/plugins')")
py_run_string("from processing.core.Processing import Processing")
py_run_string("Processing.initialize()")
py_run_string("import processing")
# tmp = py_run_string("algs = processing.alglist()")
# py_capture_output("processing.alglist()")
# py_get_attr(tmp, "algs")
# tmp = py_run_string("grass_slope = processing.algoptions('grass7:r.slope.aspect')")
# tmp$grass_slope
# py_get_attr(tmp, "grass_slope")

py_file <- system.file("python", "alglist.py", package = "RQGIS")
py_file <- "D:/programming/R/RQGIS/RQGIS/inst/python/alglist.py"
tmp <- reticulate::py_run_file(py_file)
algs <- strsplit(tmp$s, split = "\n")[[1]]
# algs <- py_to_r(py_get_attr(tmp, "s"))
algs

py_run_string("from processing.core.Processing import Processing")
py_run_string("from processing.core.parameters import ParameterSelection")
tmp = py_run_string("alg = Processing.getAlgorithm('saga:slopeaspectcurvature')")
tmp$alg
py_get_attr(x = tmp, name = "alg")

#**********************************************************
# get_args_man---------------------------------------------
#**********************************************************

# compare py_config path with set_env path!!
# a <- py_config()
# py_path <- gsub("\\\\bin.*", "", normalizePath(a$python))
# qgis_env <- set_env("C:/OSGeo4W64/")
# identical(py_path, qgis_env$root)

py_file <- system.file("python", "get_args_man.py", package = "RQGIS")
tmp <- py_run_file("D:/programming/R/RQGIS/RQGIS/inst/python/get_args_man.py")
py_get_attr(tmp, "params") %>% 
  py_to_r
py_get_attr(tmp, "vals") %>%
  py_to_r  
# you have to be careful here, if you want to preserve True and False in Python
# script
py_get_attr(tmp, "opts") %>%
  py_to_r
# or return a list
tmp <- py_run_string("args = [params, vals, opts]")
tmp$args
  

#**********************************************************
# run_qgis-------------------------------------------------
#**********************************************************

# let's try to run a geoalgorithm
py_run_string("import processing")
py_run_string('processing.runalg("saga:slopeaspectcurvature", "C:/Users/pi37pat/AppData/Local/Temp/Rtmp2HtHJy/ELEVATION.asc", "0", "0", "0", "C:/Users/pi37pat/AppData/Local/Temp/Rtmp2HtHJy/slope.asc", None, None, None, None, None, None, None, None, None, None, None)')
# perfect, that works
# this is interesting because I didn't even run all the etc/ini batch files...

devtools::load_all()
library("reticulate")
qgis_env <- set_env("C:/OSGeo4W64/", ltr = TRUE)
qgis_app <- open_app(qgis_env = qgis_env)
qgis_session_info(qgis_app = qgis_app)
}
#' @title Open a QGIS application
#' @description `open_app` first sets all the correct paths to the QGIS Python
#'   binary, and secondly opens a QGIS application while importing the most
#'   common Python modules.
#' @param qgis_env Environment settings containing all the paths to run the QGIS
#'   API. For more information, refer to [set_env()].
#' @return The function enables a 'tunnel' to the Python QGIS API.
#' @author Jannes Muenchow
#' @importFrom reticulate py_config py_run_string
#' @examples 
#' \dontrun{
#' open_app()
#' }
#' @export
open_app <- function(qgis_env = set_env()) {
  settings <- as.list(Sys.getenv())
  # since we are adding quite a few new environment variables these will remain
  # (PYTHONPATH, QT_PLUGIN_PATH, etc.). We could unset these before exiting the
  # function but I am not sure if this is necessary
  on.exit(do.call(Sys.setenv, settings))

  # run Windows setup
  setup_win(qgis_env = qgis_env)
  # Mac & Linux are still missing here!!!!!!!!!!!!!!!!!
  
  # compare py_config path with set_env path!!
  a <- py_config()
  py_path <- gsub("\\\\bin.*", "", normalizePath(a$python))
  if (!identical(py_path, qgis_env$root)) {
    stop("Wrong Python binary. Restart R and check!")
  }

  # make sure that QGIS is not already running (this would crash R)
  # app = QgsApplication([], True)  # see below
  tmp <- try(expr =  py_run_string("app")$app,
             silent = TRUE)
  if (!inherits(tmp, "try-error")) {
    stop("Python QGIS application is already running.")
  }
  
  py_run_string("import os, sys")
  py_run_string("from qgis.core import *")
  py_run_string("from osgeo import ogr")
  py_run_string("from PyQt4.QtCore import *")
  py_run_string("from PyQt4.QtGui import *")
  py_run_string("from qgis.gui import *")
  set_prefix <- paste0("QgsApplication.setPrefixPath(r'", 
                       qgis_env$qgis_prefix_path, "', True)")
  py_run_string(set_prefix)
  py_run_string("app = QgsApplication([], True)")
  py_run_string("QgsApplication.initQgis()")
  py_plugins <- paste0("sys.path.append(r'", qgis_env$python_plugins, "')")
  py_run_string(py_plugins)
  py_run_string("from processing.core.Processing import Processing")
  py_run_string("Processing.initialize()")
  py_run_string("import processing")
  # ParameterSelection required by get_args_man.py, algoptions
  py_run_string("from processing.core.parameters import ParameterSelection")
  py_run_string(paste("from processing.gui.Postprocessing",
                      "import handleAlgorithmResults"))
  
  # load Barry's capture class (needed for alglist, algoptions, alghelp)
  py_file <- system.file("python", "capturing_barry.py", package = "RQGIS")
  py_run_file(py_file)
}

#' @title Reproduce o4w_env.bat script in R
#' @description Windows helper function to start QGIS application by setting all
#'   necessary path especially through running [run_ini()].
#' @param qgis_env Environment settings containing all the paths to run the QGIS
#'   API. For more information, refer to [set_env()].
#' @return The function changes the system settings using [base::Sys.setenv()].
#' @keywords internal
#' @author Jannes Muenchow
#' @examples 
#' \dontrun{
#' run_ini()
#' }
#' @export
setup_win <- function(qgis_env = set_env()) {
  # call o4w_env.bat from within R
  # not really sure, if we need the next line (just in case)
  Sys.setenv(OSGEO4W_ROOT = qgis_env$root)
  # shell("ECHO %OSGEO4W_ROOT%")
  # REM start with clean path
  windir <- shell("ECHO %WINDIR%", intern = TRUE)
  Sys.setenv(PATH = paste(file.path(qgis_env$root, "bin", fsep = "\\"), 
                          file.path(windir, "system32", fsep = "\\"),
                          windir,
                          file.path(windir, "WBem", fsep = "\\"),
                          sep = ";"))
  # call all bat-files
  run_ini(qgis_env = qgis_env)
  
  # we need to make sure that qgis-ltr can also be used...
  my_qgis <- gsub(".*\\\\", "", qgis_env$qgis_prefix_path)
  # add the directories where the QGIS libraries reside to search path 
  # of the dynamic linker
  Sys.setenv(PATH = paste(Sys.getenv("PATH"),
                          file.path(qgis_env$root, "apps",
                                    my_qgis, "bin", fsep = "\\"),
                          sep = ";"))
  # set the PYTHONPATH variable, so that QGIS knows where to search for
  # QGIS libraries and appropriate Python modules
  python_path <- Sys.getenv("PYTHONPATH")
  python_path <- paste(python_path,
                       file.path(qgis_env$root, "apps", my_qgis, "python;", 
                                 fsep = "\\"),
                       sep = ";")
  Sys.setenv(PYTHONPATH = python_path)
  # defining QGIS prefix path (i.e. without bin)
  Sys.setenv(QGIS_PREFIX_PATH = file.path(qgis_env$root, "apps", my_qgis,
                                          fsep = "\\"))
  # shell.exec("python")  # yeah, it works!!!
}


#' @title Reproduce o4w_env.bat script in R
#' @description Windows helper function to start QGIS application. Basically, 
#'   the code found in all .bat files found in etc/ini (most likely
#'   "C:/OSGEO4~1/etc/ini") is reproduced within R.
#' @param qgis_env Environment settings containing all the paths to run the QGIS
#'   API. For more information, refer to [set_env()].
#' @return The function changes the system settings using [base::Sys.setenv()].
#' @keywords internal
#' @author Jannes Muenchow
#' @examples 
#' \dontrun{
#' run_ini()
#' }
#' @export

run_ini <- function(qgis_env = set_env()) {
  files <- dir(file.path(qgis_env$root, "etc/ini"), full.names = TRUE)
  files <- files[-grep("msvcrt|rbatchfiles", files)]
  root <- gsub("\\\\", "\\\\\\\\", qgis_env$root)
  ls <- lapply(files, function(file) {
    tmp <- readr::read_file(file)
    tmp <- gsub("%OSGEO4W_ROOT%", root, tmp)
    tmp <- strsplit(tmp, split = "\r\n|\n")[[1]]
    tmp
    })
  cmds <- do.call(c, ls)
  # remove everything followed by a semi-colon but not if the colon is followed 
  # by %PATH%
  cmds <- gsub(";%([^PATH]).*", "", cmds)
  cmds <- gsub(";%PYTHONPATH%", "", cmds)  # well, not really elegant...
  for (i in cmds) {
    if (grepl("^(SET|set)", i)) {
      tmp <- gsub("^(SET|set) ", "", i)
      tmp <- strsplit(tmp, "=")[[1]]
      args <- list(tmp[2])
      names(args) <- tmp[1]
      if (Sys.getenv(names(args)) != "") {
        args[[1]] <- paste(args[[1]], Sys.getenv(names(args)), sep = ";")
      } 
      do.call(Sys.setenv, args)
    }
    if (grepl("^(path|PATH)", i)) {
      tmp <- gsub("^(PATH|path) ", "", i)
      path <- Sys.getenv("PATH")
      path <- gsub("\\\\", "\\\\\\\\", path)
      tmp <- gsub("%PATH%", path, tmp)
      Sys.setenv(PATH = tmp)
    }
    if (grepl("^if not defined HOME", i)) {
      if (Sys.getenv("HOME") == "") {
        use_prof <- shell("ECHO %USERPROFILE%", intern = TRUE)
        Sys.setenv(HOME = use_prof)
      }
    }
  }
}
