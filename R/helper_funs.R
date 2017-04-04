#' @title Build command skeletons
#' @description This function simply builds the raw Python and batch commands 
#'   needed to acces the Python QGIS API.
#' @param qgis_env Environment settings containing all the paths to run the QGIS
#'   API. For more information, refer to [set_env()].
#' @return The function returns a list with two elements. The first contains a 
#'   raw batch file and the second the python raw command both of which are 
#'   later on needed to access QGIS from within R via Python (see 
#'   [execute_cmds()]).
#' @keywords internal
#' @author Jannes Muenchow, Patrick Schratz
#' @examples 
#' \dontrun{
#' build_cmds()
#' }

build_cmds <- function(qgis_env = set_env()) { 
  
  if (Sys.info()["sysname"] == "Windows") {
    # construct the batch file
    # = wrapper to set up the required environment variables before running
    # Python
    # more or less copied from:
    # browseURL(paste0("http://spatialgalaxy.net/2014/10/09/a-quick-guide-to", 
    #                  "-getting-started-with-pyqgis-on-windows/"))
    # some of the code can also be found in the pyqgis developer cookbook
    # browseURL(paste0("http://docs.qgis.org/2.14/en/docs/pyqgis_developer_",
    #                  "cookbook/intro.html#run-python-code-when-qgis-starts"))
    
    # we need to make sure that qgis-ltr can also be used...
    my_qgis <- gsub(".*\\\\", "", qgis_env$qgis_prefix_path)
    cmd <-
      c("@echo off",
        # remember R temp directory, i.e. use the directory from where cmd was
        # initialized
        "set wd=%~dp0",
        # defining a root variable
        paste0("SET OSGEO4W_ROOT=", qgis_env$root),
        # calling batch files from within a batchfile -> sets many paths
        "call \"%OSGEO4W_ROOT%\"\\bin\\o4w_env.bat",
        "@echo off",
        # add the directories where the QGIS libraries reside to search path 
        # of the dynamic linker
        paste0("path %PATH%;%OSGEO4W_ROOT%\\apps\\", my_qgis, "\\bin"),
        # set the PYTHONPATH variable, so that QGIS knows where to search for
        # QGIS libraries and appropriate Python modules
        paste0("set PYTHONPATH=%PYTHONPATH%;%OSGEO4W_ROOT%\\apps\\",
               my_qgis, "\\python;"),
        # defining QGIS prefix path (i.e. without bin)
        paste0("set QGIS_PREFIX_PATH=%OSGEO4W_ROOT%\\apps\\", my_qgis),
        # return to R temp directory to call later python py_cmd.py
        "pushd %wd%"
      )
    
  } else if (Sys.info()["sysname"] == "Darwin") {
    # construct the batch file
    cmd <- 
      c(# set framework (not sure if necessary)
        paste0("export DYLD_LIBRARY_PATH=", qgis_env$root,
               "/Contents/MacOS/lib/:/Applications/QGIS.app/Contents/",
               "Frameworks/"),
        ### append pythonpath to import qgis.core etc. packages
        # account for homebrew osgeo4mac installation in PYTHONPATH
        if (grepl("/usr/local/Cellar", qgis_env$root)) {
          paste0("export PYTHONPATH=", qgis_env$root, "/Contents/Resources/python/:/usr/local/lib/qt-4/python2.7/site-packages:/usr/local/lib/python2.7/site-packages:$PYTHONPATH")
        } else {
        paste0("export PYTHONPATH=", qgis_env$root, 
               "/Contents/Resources/python/")
          },
        # add QGIS Prefix path (not sure if necessary)
        # suppress debug messages for osgeo4mac homebrew installation setting QGIS env variable 'QGIS_DEBUG'
        paste0("export QGIS_PREFIX_PATH=", qgis_env$root, "/Contents/MacOS/"),
        "export QGIS_DEBUG=-1") 
    
  } else if (Sys.info()["sysname"] == "Linux") {
    # construct the batch file
    cmd <- 
      c(# append pythonpath to import qgis.core etc. packages
        paste0("export PYTHONPATH=", qgis_env$root, "/share/qgis/python"),
        # define path where QGIS libraries reside to search path of the
        # dynamic linker
        paste0("export LD_LIBRARY_PATH=", qgis_env$root, "/lib"))
  } 
  # construct the Python script
  py_cmd <- build_py(qgis_env)
  # return your result
  list("cmd" = cmd, "py_cmd" = py_cmd)
}


#' @title Building and executing cmd and Python scripts
#' @description This helper function constructs the batch and Python scripts
#'   which are necessary to run QGIS from the command line.
#' @param processing_name Name of the function from the processing library that
#'   should be used.
#' @param params Parameter to be used with the processing function.
#' @param qgis_env Environment containing all the paths to run the QGIS API. For
#'   more information, refer to [set_env()].
#' @param intern Logical, if `TRUE` the function captures the command line
#'   output as an `R` character vector (see also 
#'   [base::system()]).
#' @keywords internal
#' @author Jannes Muenchow, Patrick Schratz
#' @export
execute_cmds <- function(processing_name = "processing.alglist",
                         params = "",
                         qgis_env = set_env(),
                         intern = FALSE) {
  
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
  
  if (Sys.info()["sysname"] == "Windows") {
    # write batch command
    # cmd <- c(cmds$cmd, paste("python", file.path(tmp_dir, "py_cmd.py")))
    cmd <- c(cmds$cmd, "python py_cmd.py")
    cmd <- paste(cmd, collapse = "\n")
    cat(cmd, file = "batch_cmd.cmd")
    res <- system("batch_cmd.cmd", intern = intern)
  }
  
  if ((Sys.info()["sysname"] == "Darwin") | (Sys.info()["sysname"] == "Linux")) {
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
#' @description `check_apps` checks if software applications necessary to
#'   run QGIS (QGIS and Python plugins) are installed in the correct
#'   locations.
#' @param root Path to the root directory. Usually, this is 'C:/OSGEO4~1', 
#'   '/usr' and '/Applications/QGIS.app/' for the different platforms.
#' @param ... Optional arguments used in `check_apps`. Under Windows,
#'   `set_env` passes function argument `ltr` to `check_apps`.
#' @return The function returns a list with the paths to all the necessary 
#'   QGIS-applications.
#' @keywords internal
#' @examples 
#' \dontrun{
#' check_apps()
#' }
#' @author Jannes Muenchow, Patrick Schratz

check_apps <- function(root, ...) { 
  
  if (Sys.info()["sysname"] == "Windows") {
    path_apps <- file.path(root, "apps")
    my_qgis <- grep("qgis", dir(path_apps), value = TRUE)
    # use the LTR (default), if available
    dots <- list(...)
    if (length(dots) > 0 && isTRUE(dots$ltr)) {
      my_qgis <- ifelse("qgis-ltr" %in% my_qgis, "qgis-ltr", my_qgis[1])  
    } else {
      # use ../apps/qgis, i.e. most likely the most recent QGIS version
      my_qgis <- my_qgis[1]
    }
    apps <- c(file.path(path_apps, my_qgis),
              file.path(path_apps, my_qgis, "python\\plugins"))
    apps <- gsub("//|/", "\\\\", apps)
  } else if (Sys.info()["sysname"] == "Linux") {
    # paths to check
    apps <- file.path(root, c("bin/qgis", "share/qgis/python/plugins"))
  } else if (Sys.info()["sysname"] == "Darwin") {
    # paths to check
    apps <- file.path(root, c("Contents", "Contents/Resources/python/plugins"))
  } else {
    stop("Sorry, you can use RQGIS only under Windows and UNIX-based
         operating systems.")
  }
  
  out <- 
    lapply(apps, function(app) {
      if (file.exists(app)) {
        app
      } else {
        path <- NULL
        # apps necessary to run the QGIS-API
        stop("Folder ", dirname(app), " could not be found under ",
             basename(app)," Please install it.")
      }
    })
  names(out) <- c("qgis_prefix_path", "python_plugins")
  # return your result
  out
  }

#' @title Little helper function to construct the Python-skeleton
#' @description This helper function simply constructs the Python-skeleton 
#'   necessary to run the QGIS-Python API.
#' @param qgis_env Environment settings containing all the paths to run the QGIS
#'   API. For more information, refer to [set_env()].
#' @author Jannes Muenchow
#' @keywords internal
#' @examples 
#' \dontrun{
#' build_py()
#' }

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
    # supply path to qgis install location
    paste0("QgsApplication.setPrefixPath(r'", qgis_env$qgis_prefix_path, 
           "', True)"),
    # create a reference to the QgsApplication, setting the
    # second argument to True enables the GUI, which we need to do
    # since this is a custom application
    "app = QgsApplication([], True)",
    # load providers
    "QgsApplication.initQgis()",
    # add the path to the processing framework
    paste0("sys.path.append(r'", qgis_env$python_plugins, "')"),
    # import and initialize the processing framework
    "from processing.core.Processing import Processing",
    "Processing.initialize()",
    "import processing")
}

#' @title Open the GRASS online help
#' @description `open_grass_help` opens the GRASS online help for a 
#'   specific GRASS geoalgorithm.
#' @param alg The name of the algorithm for which one wishes to retrieve
#'   arguments and default values.
#' @keywords internal
#' @examples 
#' \dontrun{
#' open_grass_help("grass7:r.sunmask")
#' }
#' @author Jannes Muenchow 
#' @keywords export
open_grass_help <- function(alg) {
  grass_name <- gsub(".*:", "", alg)
  url <- ifelse(grepl(7, alg),
                "http://grass.osgeo.org/grass72/manuals/",
                "http://grass.osgeo.org/grass64/manuals/")
  url_ind <- paste0(url, "full_index.html")
  doc <- RCurl::getURL(url_ind)
  doc2 <- XML::htmlParse(doc)
  root <- XML::xmlRoot(doc2)
  grass_funs <- XML::xpathSApply(root[["body"]], "//a/@href")
  grass_funs <- gsub(".html", "", grass_funs)
  # grass_funs <- grep(".*\\..*", grass_funs, value = TRUE)
  # grass_funs <- grass_funs[!grepl("^http:", grass_funs)]
  # grep("^(d.|db.|g\\.|i.|m.|ps.|r.|r3.|t.|v.)", grass_funs, value = TRUE)
  
  # ind <- paste0(c("d", "db", "g", "i", "m", "ps", "r", "r3", "t", "v"), "\\.")
  # ind <- paste(ind, collapse = "|")
  # ind <- paste0("^(", ind, ")")
  # grass_funs <- grep(ind, grass_funs, value = TRUE)
  if (!grass_name %in% grass_funs) {
    grass_name <- gsub("(.*?*)\\..*", "\\1", grass_name)
  }
  # if the name can still not be found, terminate
  if (!grass_name %in% grass_funs) {
    stop(gsub(".*:", "", alg), " could not be found in the online help!")
  }
  url <- paste0(url, grass_name, ".html")
  utils::browseURL(url)
}

#' @title Set all Windows paths necessary to start QGIS
#' @description Windows helper function to start QGIS application by setting all
#'   necessary path especially through running [run_ini()].
#' @param qgis_env Environment settings containing all the paths to run the QGIS
#'   API. For more information, refer to [set_env()].
#' @return The function changes the system settings using [base::Sys.setenv()].
#' @keywords internal
#' @importFrom reticulate use_python
#' @author Jannes Muenchow
#' @examples 
#' \dontrun{
#' setup_win()
#' }

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
  python_add <- file.path(qgis_env$root, "apps", my_qgis, "python", 
                          fsep = "\\")
  if (!grepl(gsub("\\\\", "\\\\\\\\", python_add), python_path)) {
    python_path <- paste(python_path, python_add, sep = ";")    
    Sys.setenv(PYTHONPATH = python_path)
    }

  # defining QGIS prefix path (i.e. without bin)
  Sys.setenv(QGIS_PREFIX_PATH = file.path(qgis_env$root, "apps", my_qgis,
                                          fsep = "\\"))
  # shell.exec("python")  # yeah, it works!!!
  # !!!Try to make sure that the right Python version is used!!!
  use_python(file.path(qgis_env$root, "bin\\python.exe", fsep = "\\"), 
             required = TRUE)
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
      if (Sys.getenv(names(args)) != "" &
          !grepl(gsub("\\\\", "\\\\\\\\", args[[1]]), 
                 Sys.getenv((names(args))))) {
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

#' @title Set all Linux paths necessary to start QGIS
#' @description Helper function to start QGIS application under Linux.
#' @param qgis_env Environment settings containing all the paths to run the QGIS
#'   API. For more information, refer to [set_env()].
#' @return The function changes the system settings using [base::Sys.setenv()].
#' @keywords internal
#' @author Jannes Muenchow
#' @examples 
#' \dontrun{
#' setup_linux()
#' }

setup_linux <- function(qgis_env = set_env()) {
  # append PYTHONPATH to import qgis.core etc. packages
  python_path <- Sys.getenv("PYTHONPATH")
  qgis_python_path <- paste0(qgis_env$root, "/share/qgis/python")
  reg_exp <- grepl(paste0(qgis_python_path, ":"), python_path) | 
    grepl(paste0(qgis_python_path, "$"), python_path)
  if (python_path != "" & reg_exp) {
    qgis_python_path <- python_path
  } else if (python_path != "" & !reg_exp) {
    qgis_python_path <- paste(qgis_python_path, Sys.getenv("PYTHONPATH"), 
                              sep = ":")
  }
  Sys.setenv(PYTHONPATH = qgis_python_path)
  # append LD_LIBRARY_PATH
  ld_lib_path <- Sys.getenv("LD_LIBRARY_PATH")
  qgis_ld_path <-  file.path(qgis_env$root, "lib")
  reg_exp <- grepl(paste0(qgis_ld_path, ":"), ld_lib_path) | 
    grepl(paste0(qgis_ld_path, "$"), ld_lib_path)
  if (ld_lib_path != "" & reg_exp) {
    qgis_ld_path <- ld_lib_path
  } else if (ld_lib_path != "" & !reg_exp) {
    qgis_ld_path <- paste(qgis_ld_path, Sys.getenv("LD_LIBRARY_PATH"), 
                          sep = ":")
  }
  Sys.setenv(LD_LIBRARY_PATH = qgis_ld_path)
  # setting here the QGIS_PREFIX_PATH also works instead of running it twice
  # later on
  Sys.setenv(QGIS_PREFIX_PATH = qgis_env$root)
}
