#' @title Build command skeletons
#' @description This function simply builds the raw Python and batch commands 
#'   needed to acces the Python QGIS API.
#' @param qgis_env Environment containing all the paths to run the QGIS API. For
#'   more information, refer to \link{\code{set_env}}.
#' @return The function returns a list with two elements. The first contains a 
#'   raw batch file and the second the python raw command both of which are 
#'   later on needed to access QGIS from within R via Python (see
#'   \code{\link{execute_cmds}}.
#' @author Jannes Muenchow
#' @examples 
#' build_cmds()
build_cmds <- function(qgis_env = set_env()) { 
    
    if (Sys.info()["sysname"] == "Windows") {
        # check if GRASS path is correct and which version is available on
        # the system
        vers <- dir(paste0(qgis_env, "\\apps\\grass"))
        # check if grass-7 is available
        ind <- grepl("grass-7..*\\d$", vers)
        if (any(grepl("grass-7..*[0-9]$", vers))) {
            grass <- vers[ind]
        } else {
            # if not, simply use the older version
            grass <- vers[1]
        }
        # construct the batch file
        cmd <- 
            c("@echo off",
              # defining a root variable
              paste0("SET OSGEO4W_ROOT=", qgis_env$root),
              # calling batch files from with a batchfile
              "call \"%OSGEO4W_ROOT%\"\\bin\\o4w_env.bat",
              paste0("call \"%OSGEO4W_ROOT%\"\\apps\\grass\\", grass, 
                     "\\etc\\env.bat"),
              "@echo off",
              # adding QGIS and GRASS to PATH
              "path %PATH%;%OSGEO4W_ROOT%\\apps\\qgis\\bin",
              paste0("path %PATH%;%OSGEO4W_ROOT%\\apps\\grass\\", grass, "\\lib"),
              # setting a PYTHONPATH variable
              "set PYTHONPATH=%PYTHONPATH%;%OSGEO4W_ROOT%\\apps\\qgis\\python;",
              # adding a few more python paths to PYTHONPATH
              paste0("set PYTHONPATH=%PYTHONPATH%;", 
                     "%OSGEO4W_ROOT%\\apps\\Python27\\Lib\\site-packages"),
              # defining QGIS prefix path (i.e. without bin)
              "set QGIS_PREFIX_PATH=%OSGEO4W_ROOT%\\apps\\qgis",
              # finally adding Git and Vim to PATH, not sure if this is really
              # necessary
              paste0("set PATH=C:\\Program Files (x86)\\Git\\cmd;", 
                     "C:\\Program Files (x86)\\Vim\\vim74;%PATH%"))
        
        # construct the Python script
        py_cmd <- c(
            # import all the libraries you need
            "import os",
            "from qgis.core import *",
            "from osgeo import ogr",
            "from PyQt4.QtCore import *",
            "from PyQt4.QtGui import *",
            "from qgis.gui import *",
            "import sys",
            "import os",
            # initialize QGIS application
            paste0("QgsApplication.setPrefixPath('", qgis_env$root, 
                   "\\apps\\qgis', True)"),
            "app = QgsApplication([], True)",
            "QgsApplication.initQgis()",
            # add the path to the processing framework
            paste0("sys.path.append(r'", qgis_env$root, 
                   "\\apps\\qgis\\python\\plugins')"),
            # import and initialize the processing framework
            "from processing.core.Processing import Processing",
            "Processing.initialize()",
            "import processing")
        
        # return your result
        list("cmd" = cmd,
             "py_cmd" = py_cmd)
    }
    
    if (Sys.info()["sysname"] == "Darwin") {
       
        # construct the batch file
        cmd <- 
            c(# set framework (not sure if necessary)
              paste0("export DYLD_LIBRARY_PATH=", qgis_env,
                     "", "/MacOS/lib/:/Applications/QGIS.app/Contents/Frameworks/"),
              # append pythonpath to import qgis.core etc. packages
              paste0("export PYTHONPATH=",qgis_env,"/Resources/python/"),
              # add QGIS Prefix path (not sure if necessary)
              paste0("export QGIS_PREFIX_PATH=", qgis_env, "/MacOS/"), 
              paste0("export PATH='", qgis_env, "/MacOS/bin:$PATH'"))
        
        # construct the Python script
        py_cmd <- c(
            # import all the libraries you need
            "import os",
            "from qgis.core import *",
            "from osgeo import ogr",
            "from PyQt4.QtCore import *",
            "from PyQt4.QtGui import *",
            "from qgis.gui import *",
            "import sys",
            "import os",
            # initialize QGIS application
            paste0("QgsApplication.setPrefixPath('",qgis_env, "True)"),
            "app = QgsApplication([], True)",
            "QgsApplication.initQgis()",
            # add the path to the processing framework
            paste0("sys.path.append('", qgis_env, 
                   "/Resources/python/plugins')"),
            paste0("sys.path.append('", qgis_env, "/Resources/python/')"),
            # import and initialize the processing framework
            "from processing.core.Processing import Processing",
            "Processing.initialize()",
            "import processing")
        
        # return your result
        list("cmd" = cmd,
             "py_cmd" = py_cmd)
    }
    
    if (Sys.info()["sysname"] == "Linux") {
        
        # construct the batch file
        cmd <- 
            c(# set framework (not sure if necessary)
                paste0("export PYTHONPATH=", qgis_env, "/share/qgis/python"),
                # append pythonpath to import qgis.core etc. packages
                paste0("export LD_LIBRARY_PATH=", qgis_env, "/lib"))
        
        # construct the Python script
        py_cmd <- c(
            # import all the libraries you need
            "import os",
            "from qgis.core import *",
            "from osgeo import ogr",
            "from PyQt4.QtCore import *",
            "from PyQt4.QtGui import *",
            "from qgis.gui import *",
            "import sys",
            "import os",
            # initialize QGIS application
            paste0("QgsApplication.setPrefixPath('",qgis_env,
                   "/bin'", ", True)"),
            "app = QgsApplication([], True)",
            "QgsApplication.initQgis()",
            # add the path to the processing framework
            paste0("sys.path.append('", qgis_env, 
                   "/share/qgis/resources/python/plugins')"),
            paste0("sys.path.append('", qgis_env, 
                   "/share/qgis/resources/python/')"),
            # import and initialize the processing framework
            "from processing.core.Processing import Processing",
            "Processing.initialize()",
            "import processing")
        
        # return your result
        list("cmd" = cmd,
             "py_cmd" = py_cmd)
    }
}


#' @title Building and executing cmd and Python scripts
#' @description This helper function constructs the batch and Python scripts
#'   which are necessary to run QGIS from the command line.
#' @param processing_name Name of the function from the processing library that
#'   should be used.
#' @param params Parameter to be used with the processing function.
#' @param qgis_env Environment containing all the paths to run the QGIS API. For
#'   more information, refer to \link{\code{set_env}}.
#' @param intern Logical which indicates whether to capture the output of the
#'   command as an \code{R} character vector (see also \code{\link[base]{system}}.
#' @author Jannes Muenchow
execute_cmds <- function(processing_name = "processing.alglist",
                         params = "",
                         qgis_env = set_env(),
                         intern = FALSE) {

  if (Sys.info()["sysname"] == "Windows") {
    cwd <- getwd()
    on.exit(setwd(cwd))
    tmp_dir <- tempdir()
    setwd(tmp_dir)
    # load raw Python file (has to be called from the command line)
    cmds <- build_cmds(qgis_env = qgis_env)
    py_cmd <- c(cmds$py_cmd,
                paste0(processing_name, "(", params, ")",
                       "\n"))
    py_cmd <- paste(py_cmd, collapse = "\n")
    cat(py_cmd, file = "py_cmd.py")
    
    # write batch command
    cmd <- c(cmds$cmd, "python py_cmd.py")
    cmd <- paste(cmd, collapse = "\n")
    cat(cmd, file = "batch_cmd.cmd")
    system("batch_cmd.cmd", intern = intern)
  }
  
  if (Sys.info()["sysname"] == "Darwin ∣ Linux") {
    cwd <- getwd()
    on.exit(setwd(cwd))
    tmp_dir <- tempdir()
    setwd(tmp_dir)
    # load raw Python file (has to be called from the command line)
    cmds <- build_cmds(qgis_env = qgis_env)
    py_cmd <- c(cmds$py_cmd,
                paste0(processing_name, "(", params, ")",
                       "\n"))
    py_cmd <- paste(py_cmd, collapse = "\n")
    cat(py_cmd, file = "py_cmd.py")
    
    # write batch command
    cmd <- c(cmds$cmd, "/usr/bin/python py_cmd.py")
    cmd <- paste(cmd, collapse = "\n")
    cat(cmd, file = "batch_cmd.sh")
    system("sh batch_cmd.sh", intern = TRUE)
  }
  
}

#' @title Checking paths to QGIS applications on Windows
#' @details \code{check_apps} checks if all the necessary applications (QGIS,
#'   Python27, Qt4, GDAL, GRASS, msys, SAGA) are installed in the correct
#'   locations.
#' @param osgeo4w_root Path to the root directory of the OSGeo4W-installation,
#'   usually C:/OSGeo4W64 or C:/OSGeo4w32.
#' @return The function returns a list with the paths to all the necessary
#'   QGIS-applications.
#'  @examples 
#' \dontrun{
#' check_apps("C:/OSGeo4W64)
#' }
#' @author Jannes Muenchow, Patrick Schratz
check_apps <- function(osgeo4w_root) { 
  
  if (Sys.info()["sysname"] == "Windows") {
    
    path_apps <- paste0(osgeo4w_root, "\\apps")
    
    # define apps to check
    apps <- c("qgis", "Python27", "Qt4", "gdal", "msys", "grass", "saga")
    out <- lapply(apps, function(app) {
      if (any(grepl(app, dir(path_apps)))) {
        path <- paste(path_apps, app, sep = "\\")
      }
      else {
        path <- NULL
        txt <- paste0("There is no ", app, "folder in ",
                      path_apps, ".")
        ifelse(app %in% c("qgis", "Python27", "Qt4"),
               stop(txt, " Please install ", app, 
                    " using the 'OSGEO4W' advanced installation", 
                    " routine."),
               message(txt, " You might want to install ", app,
                       " using the 'OSGEO4W' advanced installation", 
                       " routine."))
      }
      gsub("//|/", "\\\\", path)
    })
    names(out) <- tolower(apps)
    # return your result
    out
  }
  
  if (Sys.info()["sysname"] == "Darwin") {
    
    path_apps <- osgeo4w_root
    
    # define apps to check
    apps <- c('qgis', "python", "gdal", "grass", "saga")
    
    cmd <- paste0("find ", path_apps,
                  " -type d \\( ! -name '*.*' -a -name 'qgis' \\)")
    path <- system(cmd, intern = TRUE)
    out <- lapply(apps, function(app) {
      cmd <- 
        paste0("find ", path_apps,
               " -type d \\( ! -name '*.*' -a -name ", "'", app,"' ", "\\)")
      path <- system(cmd, intern = TRUE)
      
      if (length(path) == 0) {
        path <- NULL
        txt <- paste0("There is no ", app, " folder in ",
                      path_apps, ".")
      }
      gsub("//|/", "\\\\", path)
    })
    # correct path slashes
    out = lapply(out, function(x) gsub("\\\\", "/", x))
    names(out) <- tolower(apps)
    
  }
  names(out) <- tolower(apps)
  # return your result
  out 
}
