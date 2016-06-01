#' @title Build command skeletons
#' @description This function simply builds the raw Python and batch commands 
#'   needed to acces the Python QGIS API.
#' @param qgis_env Environment settings containing all the paths to run the QGIS
#'   API. For more information, refer to \code{\link{set_env}}.
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
    vers <- dir(paste0(qgis_env$root, "\\apps\\grass"))
    # check if grass-7 is available
    ind <- grepl("grass-7..*\\d$", vers)
    if (any(grepl("grass-7..*[0-9]$", vers))) {
      grass <- vers[ind]
    } else {
      # if not, simply use the older version
      grass <- vers[1]
    }
    # construct the batch file
    # = wrapper to set up the required environment variables before running
    # Python
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
        paste0("path %PATH%;%OSGEO4W_ROOT%\\apps\\grass\\", grass,
               "\\lib"),
        # setting a PYTHONPATH variable
        "set PYTHONPATH=%PYTHONPATH%;%OSGEO4W_ROOT%\\apps\\qgis\\python;",
        # adding a few more python paths to PYTHONPATH
        paste0("set PYTHONPATH=%PYTHONPATH%;", 
               "%OSGEO4W_ROOT%\\apps\\Python27\\Lib\\site-packages"),
        # defining QGIS prefix path (i.e. without bin)
        "set QGIS_PREFIX_PATH=%OSGEO4W_ROOT%\\apps\\qgis")
    
    # construct the Python script
    py_cmd <- build_py(qgis_env)
    # return your result
    cmds <- list("cmd" = cmd, "py_cmd" = py_cmd)
  } else if (Sys.info()["sysname"] == "Darwin") {
    # construct the batch file
    cmd <- 
      c(# set framework (not sure if necessary)
        paste0("export DYLD_LIBRARY_PATH=", qgis_env$root,
               "", "/Contents/MacOS/lib/:/Applications/QGIS.app/Contents/Frameworks/"),
        # append pythonpath to import qgis.core etc. packages
        paste0("export PYTHONPATH=", qgis_env$root, "/Contents/Resources/python/"),
        # add QGIS Prefix path (not sure if necessary)
        paste0("export QGIS_PREFIX_PATH=", qgis_env$root, "/Contents/MacOS/"), 
        paste0("export PATH='", qgis_env$root, "/Contents/MacOS/bin:$PATH'"))
    
    # construct the Python script
    py_cmd <- build_py(qgis_env)
    
    # return your result
    cmds <- list("cmd" = cmd,
                 "py_cmd" = py_cmd)
  } else if (Sys.info()["sysname"] == "Linux") {
    # construct the batch file
    cmd <- 
      c(# append pythonpath to import qgis.core etc. packages
        paste0("export PYTHONPATH=", qgis_env$root, "/share/qgis/python"),
        # define path where QGIS libraries reside to search path of the
        # dynamic linker
        paste0("export LD_LIBRARY_PATH=", qgis_env$root, "/lib"))
    
    # construct the Python script
    py_cmd <- build_py(qgis_env)
    # return your result
    cmds <- list("cmd" = cmd,
                 "py_cmd" = py_cmd)
  } else {
    stop("Sorry, you can use RQGIS only under Windows and UNIX-based
         operating systems.")
  }
  # return your result
  cmds
  }


#' @title Building and executing cmd and Python scripts
#' @description This helper function constructs the batch and Python scripts
#'   which are necessary to run QGIS from the command line.
#' @param processing_name Name of the function from the processing library that
#'   should be used.
#' @param params Parameter to be used with the processing function.
#' @param qgis_env Environment containing all the paths to run the QGIS API. For
#'   more information, refer to \code{\link{set_env}}.
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
    res <- system("batch_cmd.cmd", intern = intern)
  }
  
  if ((Sys.info()["sysname"] == "Darwin") | (Sys.info()["sysname"] =="Linux")) {
    cwd <- getwd()
    on.exit(setwd(cwd))
    tmp_dir <- tempdir()
    setwd(tmp_dir)
    # load raw Python file (has to be called from the command line)
    cmds <- build_cmds(qgis_env = qgis_env)
    py_cmd <- c(cmds$py_cmd,
                paste0(processing_name, "(", params, ")", "\n"))
    py_cmd <- paste(py_cmd, collapse = "\n")
    # harmonize path slashes
    py_cmd <- gsub("\\\\", "/", py_cmd)
    py_cmd <- gsub("//", "/", py_cmd)
    cat(py_cmd, file = "py_cmd.py")
    
    # write batch command
    cmd <- c(cmds$cmd, "/usr/bin/python py_cmd.py")
    cmd <- paste(cmd, collapse = "\n")
    cat(cmd, file = "batch_cmd.sh")
    res <- system("sh batch_cmd.sh", intern = TRUE)
  }
  # return your result
  res
}

#' @title Checking paths to QGIS applications
#' @description \code{check_apps} checks if platform-dependent applications
#'   (e.g, QGIS, Python27, Qt4, GRASS, msys, etc.) are installed in the correct 
#'   locations.
#' @param root Path to the root directory. Usually, this is 'C:/OSGeo4W64' 
#'   ('C:/OSGeo4w32'), '/usr' and '/Applications/QGIS.app/' for the different 
#'   platforms.
#' @return The function returns a list with the paths to all the necessary 
#'   QGIS-applications.
#' @examples 
#' \dontrun{
#' check_apps("C:/OSGeo4W64")
#' }
#' @author Jannes Muenchow, Patrick Schratz
check_apps <- function(root) { 
  
  if (Sys.info()["sysname"] == "Windows") {
    path_apps <- paste0(root, "\\apps")
    
    # define apps to check
    # \\apps\\qgis\\bin
    # apps\\qgis\\python
    # apps\\Python27\\Lib\\site-packages
    # \\apps\\qgis
    # \apps\\qgis\\python\\plugins
    # \\apps\\grass\\
    
    # qgis_prefix_path = C:\\OSGeo4W64\\apps\\qgis & usr/bin
    # python_plugins = C:\\OSGeo4W64\\apps\\qgis\\python\\plugins & /usr/share/qgis/python/plugins
    apps <- c("qgis", "qgis\\python\\plugins", "Python27",
              "Qt4", "msys", "grass")
    out <- lapply(apps, function(app) {
      if (dir.exists(paste(path_apps, app, sep = "\\"))) {
        path <- paste(path_apps, app, sep = "\\")
      }
      else {
        path <- NULL
        # Aside from msys and grass all apps are necessary to run the QGIS-API
        if (!app %in% c("msys", "grass")) {
          stop("Please install ", app, 
               " using the 'OSGEO4W' advanced installation", 
               " routine.")
        }
      }
      gsub("//|/", "\\\\", path)
    })
    names(out) <- c("qgis_prefix_path", "python_plugins", "python27", "qt4",
                    "msys", "grass")
  }
  
  if (Sys.info()["sysname"] == "Linux") {
    # find out what is better: /usr/bin or usr/bin/qgis
    # paths to check
    root <- gsub("/$", "", root)  # make sure root doesn't end with a slash
    paths <- paste0(root, c("/bin/qgis", "/share/qgis/python/plugins"))
    out <- lapply(paths, function(x) {
      if (file.exists(x)) {
        x
      } else {
        stop("I could not find: '", x, "' on your system. 
             Please specify all necessary paths yourself")
      }
    })
    names(out) <- c("qgis_prefix_path", "python_plugins")
  }
  
  if (Sys.info()["sysname"] == "Darwin") {
    # paths to check
    root <- gsub("/$", "", root)  # make sure root doesn't end with a slash
    paths <- paste0(root, c("/Contents", "/Contents/Resources/python/plugins"))
    out <- lapply(paths, function(x) {
      if (file.exists(x)) {
        x
      } else {
        stop("I could not find: '", x, "' on your system. 
             Please specify all necessary paths yourself")
      }
    })
    names(out) <- c("qgis_prefix_path", "python_plugins")
  }
  # return your result
  out
}

#' @title Little helper function to construct the python-skeleton
#' @description This helper function simply constructs the python-skeleton 
#'   necessary to run the QGIS-Python API.
#' @param qgis_env Environment settings containing all the paths to run the QGIS
#'   API. For more information, refer to \code{\link{set_env}}.
#' @author Jannes Muenchow
#' @examples 
#' build_py()
build_py <- function(qgis_env = set_env()) {
  c(# import all the libraries you need
    "import os",
    "import sys",
    "from qgis.core import *",
    "from osgeo import ogr",
    "from PyQt4.QtCore import *",
    "from PyQt4.QtGui import *",
    "from qgis.gui import *",
    # initialize QGIS application
    # alter prefix path used by 3rd party apps
    paste0("QgsApplication.setPrefixPath('", qgis_env$qgis_prefix_path, 
           "', True)"),
    "app = QgsApplication([], True)",
    "QgsApplication.initQgis()",
    # add the path to the processing framework
    paste0("sys.path.append(r'", qgis_env$python_plugins, "')"),
    # import and initialize the processing framework
    "from processing.core.Processing import Processing",
    "Processing.initialize()",
    "import processing")
}
