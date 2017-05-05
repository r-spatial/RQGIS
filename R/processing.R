#' @title Retrieve the environment settings to run QGIS from within R
#' @description `set_env` tries to find all the paths necessary to run QGIS from
#'   within R.
#' @importFrom stringr str_detect
#' @param root Root path to the QGIS-installation. If left empty, the function 
#'   looks for `qgis.bat` on the C: drive under Windows. On a Mac, it looks for 
#'   `QGIS.app` under "Applications" and "/usr/local/Cellar/". On Linux, 
#'   `set_env` assumes that the root path is "/usr".
#' @param new When called for the first time in an R session, `set_env` caches 
#'   its output. Setting `new` to `TRUE` resets the cache when calling `set_env`
#'   again. Otherwise, the cached output will be loaded back into R even if you
#'   used new values for function arguments `root` and/or `dev`.
#' @param dev If set to `TRUE`, `set_env` will use the development version of
#'   QGIS (if available).
#' @param ... Currently not in use.
#' @return The function returns a list containing all the path necessary to run 
#'   QGIS from within R. This is the root path, the QGIS prefix path and the 
#'   path to the Python plugins.
#' @examples 
#' \dontrun{
#' # Letting set_env look for the QGIS installation might take a while depending
#' # on how full the C: drive is (Windows)
#' set_env()
#' # It is much faster (0 sec) to explicitly state the root path to the QGIS 
#' # installation
#' set_env("C:/OSGEO4~1")  # Windows example
#' }
#' 
#' @export
#' @author Jannes Muenchow, Patrick Schratz
set_env <- function(root = NULL, new = FALSE, dev = FALSE, ...) {
  
  dots <- list(...)
  if (length(dots) > 0 && any(grepl("ltr", names(dots)))) {
    warning("Function argument 'ltr' is deprecated. Please use 'dev' instead.", 
            call. = FALSE)
    # we have to reverse the specified input, e.g., if ltr = TRUE, then dev 
    # has to be FALSE
    dev <- !isTRUE(dots$ltr)
  }
  
  # load cached qgis_env if possible
  if (file.exists(file.path(tempdir(), "qgis_env.Rdata")) && new == FALSE) {
    load(file.path(tempdir(), "qgis_env.Rdata"))
    return(qgis_env)
  }
  
  if (Sys.info()["sysname"] == "Windows") {
    
    if (is.null(root)) {
      message("Trying to find OSGeo4W on your C: drive.")
      
      # raw command
      # change to C: drive and (&) list all subfolders of C:
      # /b bare format (no heading, file sizes or summary)
      # /s include all subfolders
      # findstr allows you to use regular expressions
      # raw <- "C: & dir /s /b | findstr"
      
      # ok, it's better to just set the working directory and change it back
      # to the directory when exiting the function
      cwd <- getwd()
      on.exit(setwd(cwd))
      setwd("C:/")
      # raw <- "dir /s /b | findstr"
      # make it more general, since C:/WINDOWS/System32 might not be part of
      # PATH on every Windows machine
      raw <- "dir /s /b | %SystemRoot%\\System32\\findstr"
      # search QGIS on the the C: drive
      cmd <- paste(raw, shQuote("bin\\\\qgis.bat$"))
      root <- shell(cmd, intern = TRUE)
      # # search GRASS
      # cmd <- paste(raw, shQuote("grass-[0-9].*\\bin$"))
      # tmp <- shell(cmd, intern = TRUE)
      # # look for Python27
      # cmd <- paste(raw, shQuote("Python27$"))
      # shell(cmd, intern = TRUE)
      
      if (length(root) == 0) {
        stop("Sorry, I could not find QGIS on your C: drive.",
             " Please specify the root to your QGIS-installation", 
             " manually.")
      } else if (length(root) > 1) {
        stop("There are several QGIS installations on your system.", 
             "Please choose one of them:\n",
             paste(root, collapse = "\n"))
      } else {
        # define root, i.e. OSGeo4W-installation
        root <-  gsub("\\\\bin.*", "", root)
      }
    }
    # harmonize root syntax
    root <- normalizePath(root)
    # make sure that the root path does not end with some sort of slash
    root <- gsub("\\\\$", "", root)
  }
  
  if (Sys.info()["sysname"] == "Darwin") {
    if (is.null(root)) {
      
      message("Checking for homebrew osgeo4mac installation on your system. \n")
      # check for homebrew QGIS installation
      path <- suppressWarnings(system2('find', c('/usr/local/Cellar', '-name', 'QGIS.app'), 
                                       stdout = TRUE, stderr = TRUE))
      
      no_homebrew <- str_detect(path, "find: /usr/local")
      
      if (no_homebrew[1] == TRUE) {
        message("Found no QGIS homebrew installation. 
                Checking for QGIS Kyngchaos version now.")
      }
      if (no_homebrew == FALSE && length(path) == 1) {
        root <- path
        message("Found QGIS osgeo4mac installation. Setting environment...")
      } 
      
      # check for multiple homebrew installations
      if (length(path) == 2) {
        
        # extract version out of root path
        path1 <- 
          as.numeric(regmatches(path[1], gregexpr("[0-9]+", path[1]))[[1]][3])
        path2 <- 
          as.numeric(regmatches(path[2], gregexpr("[0-9]+", path[2]))[[1]][3])
        
        # account for 'dev' arg installations are not constant within path ->
        # depend on which version was installed first/last hence we have to
        # catch all possibilites
        if (dev == TRUE && path1 > path2) {
          root <- path[1]
          message("Found QGIS osgeo4mac DEV installation. Setting environment...")
        } else if (dev == TRUE && path1 < path2) {
          root <- path[2]
          message("Found QGIS osgeo4mac DEV installation. Setting environment...")
        } else if (dev == FALSE && path1 > path2) {
          root <- path[2]
          message("Found QGIS osgeo4mac LTR installation. Setting environment...")
        } else if (dev == FALSE && path1 < path2) {
          root <- path[1]
          message("Found QGIS osgeo4mac LTR installation. Setting environment...")
        }
      }
      # just in case if someone has more than 2 QGIS homebrew installations
      # (very unlikely though)
      if (length(path) > 2) {
        stop("Found more than 2 QGIS homebrew installations. 
             Please clean up or set 'set_env()' manually.")
      }
      
      # check for Kyngchaos installation
      if (is.null(root)) {
        path <- system("find /Applications -name 'QGIS.app'", intern = TRUE)
        if (length(path) > 0) {
          root <- path
          message("Found QGIS Kyngchaos installation. Setting environment...")
        }
      }
      }
    }
  
  if (Sys.info()["sysname"] == "Linux") {
    if (is.null(root)) {
      message("Assuming that your root path is '/usr'!")
      root <- "/usr"
    }
  }
  qgis_env <- list(root = root)
  qgis_env <- c(qgis_env, check_apps(root = root, dev = dev))
  save(qgis_env, file = file.path(tempdir(), "qgis_env.Rdata"))
  
  
  # write warning if Kyngchaos QGIS for Mac is installed
  if (any(grepl("/Applications", qgis_env))) {
    warning(
      paste0("We recognized that you are using the Kyngchaos QGIS binary.\n",
             "Please consider installing QGIS from homebrew:", 
             "'https://github.com/OSGeo/homebrew-osgeo4mac'.",
             " Run 'vignette(install_guide)' for installation instructions.\n",
             "The Kyngchaos installation throws some warnings during ", 
             "processing. However, usage/outcome is not affected and you can ", 
             "continue using the Kyngchaos installation."))
  }
  
  # return your result
  qgis_env
  }

#' @title Open a QGIS application
#' @description `open_app` first sets all the correct paths to the QGIS Python
#'   binary, and secondly opens a QGIS application while importing the most
#'   common Python modules.
#' @param qgis_env Environment settings containing all the paths to run the QGIS
#'   API. For more information, refer to [set_env()].
#' @return The function enables a 'tunnel' to the Python QGIS API.
#' @author Jannes Muenchow
#' @importFrom reticulate py_run_string py_run_file
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
  
  # Well, well, not sure if we should change it back or if we at least have to 
  # get rid off Anaconda Python or other Python binaries (I guess not) 
  
  # on.exit(do.call(Sys.setenv, settings))
  
  # resetting system settings causes that SAGA algorithms cannot be processed
  # anymore, find out why this is!!!
  
  if (Sys.info()["sysname"] == "Windows") {
    # run Windows setup
    setup_win(qgis_env = qgis_env)
  } else if (Sys.info()["sysname"] == "Linux") {
    setup_linux(qgis_env = qgis_env)
  } else if (Sys.info()["sysname"] == "Darwin") { 
    setup_mac(qgis_env = qgis_env)
  }
  
  # make sure that QGIS is not already running (this would crash R)
  # app = QgsApplication([], True)  # see below
  tmp <- try(expr =  py_run_string("app")$app,
             silent = TRUE)
  if (!inherits(tmp, "try-error")) {
    stop("Python QGIS application is already running.")
  }
  
  py_run_string("import os, sys, re, webbrowser")
  py_run_string("from qgis.core import *")
  py_run_string("from osgeo import ogr")
  py_run_string("from PyQt4.QtCore import *")
  py_run_string("from PyQt4.QtGui import *")
  py_run_string("from qgis.gui import *")
  # interestingly, under Linux the app would start also without running the next
  # two lines
  set_prefix <- paste0("QgsApplication.setPrefixPath(r'",
                       qgis_env$qgis_prefix_path, "', True)")
  py_run_string(set_prefix)
  # not running the next line will produce following error message under Linux
  # QSqlDatabase: QSQLITE driver not loaded
  # QSqlDatabase: available drivers: 
  # ERROR: Opening of authentication db FAILED
  # QSqlQuery::prepare: database not open
  # WARNING: Auth db query exec() FAILED
  py_run_string("QgsApplication.showSettings()")
  py_run_string("app = QgsApplication([], True)")
  py_run_string("QgsApplication.initQgis()")
  code <- paste0("sys.path.append(r'", qgis_env$python_plugins, "')")
  py_run_string(code)
  
  # attach further modules 
  py_file <- system.file("python", "import_setup.py", package = "RQGIS")
  py_run_file(py_file)
  # attach our RQGIS class (needed for alglist, algoptions, alghelp)
  py_file <- system.file("python", "python_funs.py", package = "RQGIS")
  py_run_file(py_file)
  # initialize our RQGIS class
  py_run_string("RQGIS = RQGIS()")
}

#' @title QGIS session info
#' @description `qgis_session_info` reports the version of QGIS and
#'   installed third-party providers (so far GRASS 6, GRASS 7, and SAGA). 
#'   Additionally, it figures out with which SAGA versions the QGIS installation
#'   is compatible.
#' @param qgis_env Environment settings containing all the paths to run the QGIS
#'   API. For more information, refer to [set_env()].
#' @return The function returns a list with following elements:
#' \enumerate{
#'  \item{qgis_version: Name and version of QGIS used by RQGIS.}
#'  \item{grass6: GRASS 6 version number. Under Linux, the function only checks if
#'  GRASS 6 modules can be executed, therefore it simply returns TRUE instead of
#'  a version number.}
#'  \item{grass7: GRASS 7 version number. Under Linux, the function only checks if
#'  GRASS 6 modules can be executed, therefore it simply returns TRUE instead of
#'  a version number}
#'  \item{saga: The installed SAGA version used by QGIS.}
#'  \item{supported_saga_versions: character vector representing the SAGA
#'  versions supported by the QGIS installation.}
#' }
#' @author Jannes Muenchow, Victor Olaya, QGIS core team
#' @importFrom reticulate py_run_string
#' @export
#' @examples 
#' \dontrun{
#' qgis_session_info()
#' }
qgis_session_info <- function(qgis_env = set_env()) {
  tmp <- try(expr =  open_app(qgis_env = qgis_env), silent = TRUE)
  
  # retrieve the output
  out <- 
    py_run_string("my_session_info = RQGIS.qgis_session_info()")$my_session_info
  names(out) <- c("qgis_version", "grass6", "grass7", "saga",
                  "supported_saga_versions")
  if (Sys.info()["sysname"] == "Linux" && out$grass7) {
    # find out which GRASS version is available
    # my_grass <- searchGRASSX()
    my_grass <- system(paste0("find /usr ! -readable -prune -o -type f ", 
                              "-executable -iname 'grass??' -print"),
                       intern = TRUE)
    if (grepl("72", my_grass)) {
      warning(paste0("QGIS might be still pointing to grass70. In this case ",
                     "you might want to consider using a softlink by running: ",
                     "'sudo ln -s /usr/bin/grass72 /usr/bin/grass70' on the ",
                     "commandline. See also ", 
                     "'https://lists.osgeo.org/pipermail/qgis-user/2017-", 
                     "January/038907.html'. Then restart R again."))
    }
    
    # more or less copied from link2GI::searchGRASSX
    # Problem: sometimes the batch command is interrupted or does not finish...
    if (length(my_grass) > 0) {
      install <- lapply(seq(length(my_grass)), function(i) {
        cmd <- grep(readLines(my_grass), pattern = "cmd_name = \"", 
                    value = TRUE)
        cmd <- substr(cmd, gregexpr(pattern = "\"", cmd)[[1]][1] + 
                        1, nchar(cmd) - 1)
      })
    }
    out$grass7 <- grep("7", unlist(install), value = TRUE)
  }
  
  # clean up after yourself!!
  py_run_string(
    "try:\n  del(my_session_info)\nexcept:\  pass")
  out
}

#' @title Find and list available QGIS algorithms
#' @description `find_algorithms` lists or queries all QGIS algorithms which can
#'   be accessed via the QGIS Python API.
#' @param search_term If (`NULL`), the default, all available functions will be 
#'   returned. If `search_term` is a character, all available functions will be
#'   queried accordingly. The character string might also contain a regular
#'   expression (see examples).
#' @param name_only If `TRUE`, the function returns only the name(s) of the
#'   found algorithms. Otherwise, a short function description will be returned
#'   as well (default).
#' @param qgis_env Environment settings containing all the paths to run the QGIS
#'   API. For more information, refer to [set_env()].
#' @details Function `find_algorithms` simply calls `processing.alglist` using 
#'   Python.
#' @return The function returns QGIS function names and short descriptions as an
#'   R character vector.
#' @author Jannes Muenchow, Victor Olaya, QGIS core team
#' @importFrom reticulate py_run_string py_run_file py_capture_output
#' @examples
#' \dontrun{
#' # list all available QGIS algorithms on your system
#' algs <- find_algorithms()
#' algs[1:15]
#' # find a function which adds coordinates
#' find_algorithms(search_term = "add")
#' # find only QGIS functions
#' find_algorithms(search_term = "qgis:")
#' # find QGIS and SAGA functions related to centroid computations
#' find_algorithms(search_term = "centroid.+(qgis:|saga:)")
#' }
#' @export

find_algorithms <- function(search_term = NULL, name_only = FALSE,
                            qgis_env = set_env()) {
  # check if the QGIS application has already been started
  tmp <- try(expr =  open_app(qgis_env = qgis_env), silent = TRUE)
  
  # Advantage of this approach: we are using directly alglist and do not have to
  # save it in inst
  # Disadvantage: more processing
  algs <- py_capture_output(py_run_string("processing.alglist()"))
  algs <- gsub("\n", "', '", algs)
  algs <- unlist(strsplit(algs, "', |, '"))
  algs <- unlist(strsplit(algs, '", '))
  algs <- gsub("\\['|'\\]|'", "", algs)
  
  # quick-and-dirty, maybe there is more elegant approach...
  if (Sys.info()["sysname"] == "Windows") {
    algs <- gsub('\\\\|"', "", shQuote(algs))
  } else {
    algs <- gsub('\\\\|"', "", algs)
  }
  algs <- algs[algs != ""]
  
  # use regular expressions to query all available algorithms
  if (!is.null(search_term)) {
    algs <- grep(search_term, algs, value = TRUE)
  }
  
  if (name_only) {
    algs <- gsub(".*>", "", algs)
  }
  
  # py_run_string(sprintf("text = '%s'", search_term))
  # py_file <- system.file("python", "alglist.py", package = "RQGIS")
  # algs_2 <- py_run_file(py_file)
  # algs_2 <- strsplit(algs_2$s, split = "\n")[[1]]
  # if (name_only) {
  #   algs_2 <- gsub(".*>", "", algs_2)
  # }
  # all.equal(algs, algs_2)  # TRUE for name_only, perfect!
  # # clean up after yourself, just in case
  # py_run_string("del(text, s)")
  
  # return your result
  algs
}


#' @title Get usage of a specific QGIS geoalgorithm
#' @description `get_usage` lists all function parameters of a specific 
#'   QGIS geoalgorithm.
#' @param alg Name of the function whose parameters are being searched for.
#' @param intern Logical, if `TRUE` the function captures the command line 
#'   output as an `R` character vector`. If `FALSE`, the default, the ouptut is
#'   printed to the console in a pretty way.
#' @param qgis_env Environment containing all the paths to run the QGIS API. For
#'   more information, refer to [set_env()].
#' @details Function `get_usage` simply calls
#'   `processing.alghelp` of the QGIS Python API.
#' @author Jannes Muenchow, Victor Olaya, QGIS core team
#' @importFrom reticulate py_capture_output py_run_string
#' @export
#' @examples
#' \dontrun{
#' # find a function which adds coordinates
#' find_algorithms(search_term = "add")
#' # find function arguments of saga:addcoordinatestopoints
#' get_usage(alg = "saga:addcoordinatestopoints")
#' }

get_usage <- function(alg = NULL, intern = FALSE,
                      qgis_env = set_env()) {
  tmp <- try(expr =  open_app(qgis_env = qgis_env), silent = TRUE)
  out <- 
    py_capture_output(py_run_string(sprintf("processing.alghelp('%s')", alg)))
  out <- gsub("^\\[|\\]$|'", "", out)
  out <- gsub(", ", "\n", out)
  if (intern) {
    out
  } else {
    cat(gsub("\\\\t", "\t", out))
  }
  
}

#' @title Get options of parameters for a specific GIS option
#' @description `get_options` lists all available parameter options for the 
#'   required GIS function.
#' @param alg Name of the GIS function for which options should be returned.
#' @param intern Logical, if `TRUE` the function captures the command line 
#'   output as an `R` character vector. If `FALSE`, the default, the ouptut is
#'   printed to the console in a pretty way.
#' @param qgis_env Environment containing all the paths to run the QGIS API. For
#'   more information, refer to [set_env()].
#' @details Function `get_options` simply calls `processing.algoptions` of the 
#'   QGIS Python API.
#' @author Jannes Muenchow, Victor Olaya, QGIS core team
#' @importFrom reticulate py_capture_output py_run_string
#' @examples
#' \dontrun{
#' get_options(alg = "saga:slopeaspectcurvature")
#' }
#' @export
get_options <- function(alg = "", intern = FALSE,
                        qgis_env = set_env()) {
  
  tmp <- try(expr =  open_app(qgis_env = qgis_env), silent = TRUE)
  out <- 
    py_capture_output(py_run_string(
      sprintf("processing.algoptions('%s')", alg)))
  out <- gsub("^\\[|\\]$|'", "", out)
  out <- gsub(", ", "\n", out)
  if (intern) {
    out
  } else {
    cat(gsub("\\\\t", "\t", out))
  }
}

#' @title Access the QGIS/GRASS online help for a specific (Q)GIS geoalgorithm
#' @description `open_help` opens the online help for a specific (Q)GIS 
#'   geoalgorithm. This is the online help one also encounters in the QGIS GUI.
#'   In the case of GRASS algorithms this is actually the GRASS online
#'   documentation.
#' @param alg The name of the algorithm for which one wishes to retrieve 
#'   arguments and default values.
#' @param qgis_env Environment containing all the paths to run the QGIS API. For
#'   more information, refer to [set_env()].
#' @details Bar a few exceptions `open_help` works for all QGIS, GRASS and
#'   SAGA geoalgorithms. The online help of other third-party providers,
#'   however, has not been tested so far.
#' @return The function opens the default web browser, and displays the help for
#'   the specified algorithm.
#' @note Please note that `open_help` requires a \strong{working Internet 
#'   connection}.
#' @author Jannes Muenchow, Victor Olaya, QGIS core team
#' @export
#' @examples 
#' \dontrun{
#' # QGIS example
#' open_help(alg = "qgis:addfieldtoattributestable")
#' # GRASS example
#' open_help(alg = "grass:v.overlay")
#' }
open_help <- function(alg = "", qgis_env = set_env()) {
  
  # check if the QGIS application has already been started
  tmp <- try(expr =  open_app(qgis_env = qgis_env), silent = TRUE)
  
  algs <- find_algorithms(name_only = TRUE, qgis_env = qgis_env)
  if (!alg %in% algs) {
    stop("The specified algorithm ", alg, " does not exist.")
  }
  
  if (grepl("grass", alg)) {
    # open GRASS online help
    open_grass_help(alg)
  } else {
    algName <- alg
    # open the QGIS online help
    py_run_string(sprintf("RQGIS.open_help('%s')", algName))
  }
}

#' @title Get GIS arguments and respective default values
#' @description`get_args_man` retrieves automatically function arguments and
#' respective default values for a given QGIS geoalgorithm.
#' @param alg The name of the algorithm for which one wishes to retrieve 
#'   arguments and default values.
#' @param options Sometimes one can choose between various options for a 
#'   function argument. Setting option to `TRUE` will automatically assume one
#'   wishes to use the first option (default: `FALSE`).
#' @param qgis_env Environment containing all the paths to run the QGIS API. For
#'   more information, refer to [set_env()].
#' @details `get_args_man` basically mimics the behavior of the QGIS GUI. That
#'   means, for a given GIS algorithm, it captures automatically all arguments
#'   and default values. In the case that a function argument has several
#'   options, one can indicate to use the first option (see also 
#'   [get_options()]), which is the QGIS GUI default behavior.
#' @return The function returns a list whose names correspond to the function 
#'   arguments one needs to specify. The list elements correspond to the
#'   argument specifications. The specified function arguments can serve as
#'   input for [run_qgis()]'s params argument. Please note that although 
#'   `get_args_man` tries to retrieve default values, one still needs to specify
#'   some function arguments manually such as the input and the output layer.
#' @note Please note that some default values can only be set after the user's 
#'   input. For instance, the GRASS region extent will be determined
#'   automatically by [run_qgis()] if left blank.
#' @importFrom reticulate py_run_string py_run_file
#' @export
#' @author Jannes Muenchow, Victor Olaya, QGIS core team
#' @examples 
#' \dontrun{
#' get_args_man(alg = "qgis:addfieldtoattributestable")
#' # and using the option argument
#' get_args_man(alg = "qgis:addfieldtoattributestable", options = TRUE)
#' }
get_args_man <- function(alg = "", options = FALSE, 
                         qgis_env = set_env()) {
  # check if the QGIS application has already been started
  tmp <- try(expr =  open_app(qgis_env = qgis_env), silent = TRUE)
  
  algs <- find_algorithms(name_only = TRUE, qgis_env = qgis_env)
  if (!alg %in% algs) {
    stop("The specified algorithm ", alg, " does not exist.")
  }
  
  # you have to be careful here, if you want to preserve True and False in
  # Python language... -> check!!!!!!!!!!! or maybe not, because reticulate is
  # taking care of it???
  
  # args <- py_run_string(
  #   sprintf("algorithm_params = get_args_man('%s')", alg))$algorithm_params
  # using the RQGIS class
  
  args <- py_run_string(
    sprintf("algorithm_params = RQGIS.get_args_man('%s')",
            alg))$algorithm_params
  names(args) <- c("params", "vals", "opts")
  
  # If desired, select the first option if a function argument has several
  # options to choose from
  if (options) {
    args$vals[args$opts] <- "0"
  }
  # clean up after yourself!!
  py_run_string(
    "try:\n  del(algorithm_params)\nexcept:\  pass")
  # return your result
  out <- as.list(args$vals)
  names(out) <- args$params
  out
}

#' @title Specifying QGIS geoalgorithm parameters the R way
#' @description The function lets the user specify QGIS geoalgorithm parameters 
#'   as R named arguments or a a parameter-argument list. When omitting required
#'   parameters, defaults will be used if available as derived from 
#'   [get_args_man()]. Additionally, the function checks thoroughly the
#'   user-provided parameters and arguments.
#' @param alg The name of the geoalgorithm to use.
#' @param ... Triple dots can be used to specify QGIS geoalgorithm arguments as 
#'   R named arguments.
#' @param params Parameter-argument list for a specific geoalgorithm, see 
#'   [get_args_man()] for more details. Please note that you can either specify 
#'   R arguments directly via the triple dots (see above) or via the
#'   parameter-argument list. However, you may not mix the two methods.
#' @param qgis_env Environment containing all the paths to run the QGIS API. For
#'   more information, refer to [set_env()].
#' @return The function returns the complete parameter-argument list for a given
#'   QGIS geoalgorithm. The list is constructed with the help of 
#'   [get_args_man()] while considering the R named arguments or the 
#'   `params`-parameter specified by the user as additional input. If available,
#'   the function returns the default values for all parameters which were not 
#'   specified.
#' @details In detail, the function performs following actions and
#'   parameter-argument checks:
#'   \itemize{
#'     \item Were the right parameter names used?
#'     \item Were the correct argument values provided?
#'     \item The function collects all necessary arguments (to run QGIS) and 
#'     respective default values which were not set by the user with the help of
#'     [get_args_man()].
#'     \item If an argument value corresponds to a spatial object residing in R,
#'     the function will save the spatial object to a temporary folder, and use
#'     the corresponding file path to replace the spatial object in the 
#'     parameter-argument list.
#'     \item If the user only specified the name of an output file (e.g. 
#'     "slope.asc") and not a complete path, the function will save the output
#'     in the temporary folder, i.e. to `file.path(tempdir(), "slope.asc")`.
#'     \item If a parameter accepts as arguments values from a selection, the 
#'     function replaces verbal input by the corresponding number (required by 
#'     the QGIS Python API). Please refer to the example section for more
#'     details, and to [get_options()] for valid options for a given
#'     geoalgorithm.
#'     \item In case of a GRASS-geoalgorithm, the function determines the
#'     `GRASS_REGION_PARAMETER` based on the user input.
#'   }
#' @note The function was inspired by [rgrass7::doGRASS()].
#' @author Jannes Muenchow
#' @export
#' @importFrom raster raster writeRaster 
#' @importFrom rgdal writeOGR
#' @examples
#' \dontrun{
#' data(dem, package = "RQGIS")
#' alg <- "grass7:r.slope.aspect"
#' get_usage(alg)
#' # 1. using R named arguments
#' pass_args(alg, elevation = dem, slope = "slope.asc")
#' # 2. doing the same with a parameter argument list
#' pass_args(alg, params = list(elevation = dem, slope = "slope.asc"))
#' # 3. verbal input replacement (note that "degrees" will be replaced by 0)
#' get_options(alg)
#' pass_args(alg, elevation = dem, format = "degrees")
#' }

pass_args <- function(alg, ..., params = NULL, qgis_env = set_env()) {
  dots <- list(...)
  if (!is.null(params) && (length(dots) > 0))
    stop(paste("Use either QGIS parameters as R arguments,",
               "or as a parameter argument list object, but not both"))
  if (length(dots) > 0) {
    params <- dots
  }
  
  dups <- duplicated(names(params))
  if (any(dups)) {
    stop("You have specified following parameter(s) more than once: ",
         paste(names(params)[dups], collapse = ", "))
  }
  
  # collect all the function arguments and respective default values for the
  # specified geoalgorithm
  params_all <- get_args_man(alg, options = TRUE)
  
  # check if there are too few/many function arguments
  ind <- setdiff(names(params), names(params_all))
  if (length(ind) > 0) {
    stop(paste(sprintf("'%s'", ind), collapse = ", "), 
         " is/are (an) invalid function argument(s). \n\n",
         sprintf("'%s'", alg), " allows following function arguments: ",
         paste(sprintf("'%s'", names(params_all)), collapse = ", "))
  }
  
  # if function arguments are missing, QGIS will use the default since we submit
  # our parameter-arguments as a Python-dictionary (see Processing.runAlgorithm)
  # nevertheless, we will indicate them already here since we have already 
  # retrieved them, it makes our processing more transparent, and it makes life
  # easier in run_qgis
  ind <- setdiff(names(params_all), names(params))
  if (length(ind) > 0) {
    params_2 <- params_all
    params_2[names(params)] <- params
    params <- params_2
    rm(params_2)
  }
  
  # retrieve the options for a specific parameter
  opts <- py_run_string(sprintf("opts = RQGIS.get_options('%s')", alg))$opts
  # add number notation in Python lingo, i.e. count from 0 to the length of the
  # vector minus 1
  opts <- lapply(opts, function(x) {
    data.frame(name = x, number = 0:(length(x) - 1), stringsAsFactors = FALSE)
  })
  
  int <- intersect(names(params), names(opts))
  ls_1 <- lapply(int, function(x) {
    # if the user specified a named notation replace it by number notation if
    # the option does not appear in the dictionary due to a typo (e.g., area2
    # instead of area), Python will inform the user that area2 is a wrong
    # parameter value
    if (grepl("saga:", alg)) {
      saga_test <- gsub("\\[\\d\\] ", "", opts[[x]]$name)
    } else {
      # otherwise just duplicate the possible argument values
      saga_test <- opts[[x]]$name
    }
    # replace verbal notation by number notation
    if (params[[x]] %in% c(opts[[x]]$name, saga_test)) {
      opts[[x]][opts[[x]]$name == params[[x]] | saga_test == params[[x]],
                "number"]
    } else {
      # otherwise return the user input but check if the number is ok given the
      # user has specified a number
      test <- suppressWarnings(try(as.numeric(params[[x]]), silent = TRUE))
      if (!is.na(test)) {
        if (!test %in% opts[[x]]$number) {
          stop(x, " only accepts these values: ",
               paste(opts[[x]]$number, collapse = ", "), 
               "\nYou specified: ", test)
        }
      }
      params[[x]]
    }
  })
  # replace the named input by number input in the parameter-argument list
  params[int] <- ls_1
  
  # save Spatial-Objects (sp and raster)
  params[] <- lapply(seq_along(params), function(i) {
    tmp <- class(params[[i]])
    # check if the function argument is a SpatialObject
    if (grepl("^Spatial(Points|Lines|Polygons)DataFrame$", tmp) && 
        attr(tmp, "package") == "sp") {
      # just in case try to delete any previous files
      suppressWarnings(
        file.remove(list.files(path = tempdir(), pattern = names(params)[[i]], 
                               full.names = TRUE)))
      writeOGR(params[[i]], dsn = tempdir(), layer = names(params)[[i]],
               driver = "ESRI Shapefile", overwrite_layer = TRUE)
      # return the result
      file.path(tempdir(), paste0(names(params)[[i]], ".shp"))
    } else if (tmp == "RasterLayer") {
      fname <- file.path(tempdir(), paste0(names(params)[[i]], ".asc"))
      writeRaster(params[[i]], filename = fname, format = "ascii", 
                  prj = TRUE, overwrite = TRUE)
      # return the result
      fname
    } else {
      params[[i]]
    }
  })
  
  # Find out what the output names are
  out_names <- 
    py_run_string(
      sprintf("out_names = RQGIS.get_output_names('%s')", alg))$out_names
  # clean up after yourself!!
  py_run_string(
    "try:\n  del(out_names)\nexcept:\  pass")  
  
  # if the user has only specified an output filename without a directory path,
  # make sure that the output will be saved to the temporary R folder (not doing
  # so could sometimes save the output in the temporary QGIS folder)
  # if the user has not specified any output files, nothing happens
  int <- intersect(names(params), out_names)
  params[int] <- lapply(params[int], function(x) {
    if (basename(x) != "None" && dirname(x) == ".") {
      file.path(tempdir(), x)
    } else {
      x
    }
  })
  
  # set the bbox in the case of GRASS functions if it hasn't already been 
  # provided (if there are more of these 3rd-party based specifics, put them in
  # a new function)
  if (grepl("grass7?:", alg) &&
      grepl("None", params$GRASS_REGION_PARAMETER)) {
    # dismiss the output arguments. Not doing so could cause R to crash since 
    # the output-file might already exist. For instance, the already existing
    # output might have another CRS.
    ext <- params[setdiff(names(params), out_names)]
    # run through the arguments and check if we can extract a bbox
    ext <- lapply(ext, function(x) {
      # We cannot simply use gsub as we have done before (gsub("[.].*",
      # "",basename(x))) if the filename itself also contains dots, e.g.,
      # gis.osm_roads_free_1.shp 
      # We could use regexp to cut off the file extension
      # my_layer <- stringr::str_extract(basename(x), "[A-z].+[^\\.[A-z]]")
      # but let's use an already existing function
      my_layer <- tools::file_path_sans_ext(basename(as.character(x)))
      # determine bbox in the case of a vector layer
      tmp <- try(expr = ogrInfo(dsn = x, layer = my_layer)$extent, 
                 silent = TRUE)
      if (!inherits(tmp, "try-error")) {
        # check if this is always this way (xmin, ymin, xmax, ymax...)
        extent(tmp[c(1, 3, 2, 4)])
      } else {
        # determine bbox in the case of a raster
        ext <- try(expr = GDALinfo(x, returnStats = FALSE),
                   silent = TRUE)
        # check if it is still an error
        if (!inherits(ext, "try-error")) {
          # xmin, xmax, ymin, ymax
          extent(c(ext["ll.x"], 
                   ext["ll.x"] + ext["columns"] * ext["res.x"],
                   ext["ll.y"],
                   ext["ll.y"] + ext["rows"] * ext["res.y"]))
        } else {
          NA
        }
      }
    })
    # now that we have possibly several extents, union them
    ext <- ext[!is.na(ext)]
    ext <- Reduce(raster::merge, ext)
    if (is.null(ext)) {
      stop("Either you forgot to specify an input shapefile/raster or the", 
           " input file does not exist")
    }
    # sometimes the extent is given back with dec = ","; you need to change that
    ext <- gsub(",", ".", c(ext@xmin, ext@xmax, ext@ymin, ext@ymax))
    # final bounding box in GRASS notation
    params$GRASS_REGION_PARAMETER <- paste(ext, collapse = ",")
  }
  
  # make sure function arguments are in the correct order not longer necessary
  # since we use a Python dictionary to pass our arguments however, otherwise,
  # the user might become confused... and for RQGIS.check_args the correct order
  # is important as well! Doing the check here has also the advantage that the
  # function tells the user all missing function arguments, QGIS returns only
  # one at a time
  params <- params[names(params_all)]
  check <- py_run_string(sprintf("check = RQGIS.check_args('%s', %s)",
                                 alg, r_to_py(unlist(params))))$check
  # stop the function if required arguments were not supplied
  if (length(check) > 0) {
    stop(sprintf("Invalid argument value %s for parameter %s\n", 
                 check, names(check)))
  }
  # return your result
  params
}

#'@title Interface to QGIS commands
#'@description `run_qgis` calls QGIS algorithms from within R while passing the 
#'  corresponding function arguments.
#'@param alg Name of the GIS function to be used (see [find_algorithms()]).
#'@param ... Triple dots can be used to specify QGIS geoalgorithm arguments as R
#'  named arguments. For more details, please refer to [pass_args()].
#'@param params Parameter-argument list for a specific geoalgorithm. Please note
#'  that you can either specify R named arguments directly via the triple dots 
#'  (see above) or via a parameter-argument list. However, you may not mix the 
#'  two methods. See the example section, [pass_args()] and [get_args_man()] for
#'  more details.
#'@param load_output If `TRUE`, all QGIS output files (vector and raster data) 
#'  specified by the user (i.e. the user has to indicate output files) will be 
#'  loaded into R. A list will be returned if there is more than one output file
#'  (e.g., `grass7:r.slope.aspect`). See the example section for more details.
#'@param check_params If `TRUE` (default), it will be checked if all 
#'  geoalgorithm function arguments were provided in the correct order 
#'  (deprecated).
#'@param show_msg Logical, if `TRUE`, Python messages that occured during the 
#'  algorithm execution will be shown (deprecated).
#'@param qgis_env Environment containing all the paths to run the QGIS API. For 
#'  more information, refer to [set_env()].
#'@details This workhorse function calls the QGIS Python API, and specifically 
#'  `processing.runalg`.
#'@return The function prints a list (named according to the output parameters)
#'  containing the paths to the files created by QGIS. If not otherwise
#'  specified, the function saves the QGIS generated output files in the
#'  temporary folder (created by QGIS). Optionally, function parameter
#'  `load_output` loads spatial QGIS output (vector and raster data) into R.
#'@note Please note that one can also pass spatial R objects as input parameters
#'  where suitable (e.g., input layer, input raster). Supported formats are 
#'  [sp::SpatialPointsDataFrame()]-, [sp::SpatialLinesDataFrame()]-, 
#'  [sp::SpatialPolygonsDataFrame()]- and [raster::raster()]-objects. See the 
#'  example section for more details.
#'  
#'  GRASS users do not have to specify manually the GRASS region extent 
#'  (function argument GRASS_REGION_PARAMETER). If "None" (the QGIS default), 
#'  `run_qgis` (see [pass_args()] for more details) will automatically determine
#'  the region extent based on the user-specified input layers.
#'@author Jannes Muenchow, Victor Olaya, QGIS core team
#'@export
#'@importFrom sp SpatialPointsDataFrame SpatialPolygonsDataFrame
#'@importFrom sp SpatialLinesDataFrame
#'@importFrom raster raster writeRaster extent
#'@importFrom rgdal ogrInfo writeOGR readOGR GDALinfo
#'@importFrom reticulate py_run_string py_capture_output r_to_py
#' @examples
#' \dontrun{
#' # calculate the slope of a DEM
#' # load dem - a raster object
#' data(dem, package = "RQGIS")
#' # find out the name of a GRASS function with which to calculate the slope
#' find_algorithms(search_term = "grass7.*slope")
#' # find out how to use the function
#' alg <- "grass7:r.slope.aspect"
#' get_usage(alg)
#' # 1. run QGIS using R named arguments, and load the QGIS output back into R
#' slope <- run_qgis(alg, elevation = dem, slope = "slope.asc", 
#'                   load_output = TRUE)
#' # 2. doing the same with a parameter-argument list
#' params <- list(elevation = dem, slope = "slope.asc")
#' slope <- run_qgis(alg, params = params, load_output = TRUE)
#' # 3. calculate the slope, the aspect and the pcurvature. 
#' terrain <- run_qgis(alg, elevation = dem, slope = "slope.asc", 
#'                     aspect = "aspect.asc", pcurvature = "pcurv.asc",
#'                     load_output = TRUE)
#' # the three output rasters are returned in a list of length 3
#' terrain
#'}

run_qgis <- function(alg = NULL, ..., params = NULL, load_output = FALSE,
                     check_params = TRUE, show_msg = TRUE,
                     qgis_env = set_env()) {

  if (!missing(check_params)) {
    warning(paste("Argument check_params is deprecated; please do not use it", 
                  "any longer. run_qgis now automatically checks all given", 
                  "QGIS parameters."), 
            call. = FALSE)
  }
  # check if the QGIS application has already been started
  tmp <- try(expr =  open_app(qgis_env = qgis_env), silent = TRUE)
  
  # check under Linux which GRASS version is in use. If its GRASS72 the user
  # might have to add a softlink due to as QGIS bug
  if (Sys.info()["sysname"] == "Linux" & grepl("grass7", alg)) {
    qgis_session_info(qgis_env)
  }

  if (!missing(show_msg)) {
    warning(paste("Argument show_msg is deprecated; please do not use it", 
                  "any longer. run_qgis now always return any Python (error)", 
                  "output"), 
            call. = FALSE)
  }
  
  # check if alg is qgis:vectorgrid
  if (alg == "qgis:vectorgrid") {
    stop("Please use qgis:creategrid instead of qgis:vectorgrid!")
  }
  
  # check if alg belongs to the QGIS "select by.."-category
  if (grepl("^qgis\\:selectby", alg)) {
    stop(paste("The 'Select by' operations of QGIS are interactive.", 
               "Please use 'grass7:v.extract' instead."))
  }
  
  
  # construct a parameter-argument list using get_args_man and user input
  params <- pass_args(alg, ..., params = params, qgis_env = qgis_env)  

  # build the Python command 
  # r_to_py(params) would also create a dictionary which would be a rather
  # elegant solution. But there are two problems: First, we did not get rid off
  # strange/incomplete shell quotes (though that might not be an issue here,
  # since we are going to use Python via the tunnel and the strange/incomplete
  # shellquotes were returned by Python). Secondly, True, False and None should
  # be unquoted which can be only achieved in R by collapsing all arguments into
  # one long string. Maybe it would work even if we did not explicitly take care
  # of this. But to be on the safe side, we proceed as follows:
  
  vals <- vapply(params, function(x) {
    # get rid off 'strange' or incomplete shellQuotes
    tmp <- unlist(strsplit(as.character(x), ""))
    tmp <- tmp[tmp != "\""]
    # paste the argument together again
    tmp <- paste(tmp, collapse = "")
    # shellQuote argument if is not True, False or None
    ifelse(grepl("True|False|None", tmp), tmp, shQuote(tmp))
  }, character(1))
  # paste the function arguments together
  args <- paste(vals, collapse = ", ")

  # convert R parameter-argument list into a Python dictionary
  py_run_string(paste("args = ", r_to_py(args)))
  py_run_string(paste0("params = ", r_to_py(names(params))))
  py_run_string("params = dict((x, y) for x, y in zip(params, args))")
  
  cmd <- paste(sprintf("res = processing.runalg('%s', params)", alg))
  
  # run QGIS
  msg <- py_capture_output(py_run_string(cmd))
  # If QGIS produces an error message, stop and report it
  if (grepl("Unable to execute algorithm|Error", msg)) {
    stop(msg)
  }
  # res contains all the output paths of the files created by QGIS
  res <- py_run_string("res")$res
  # show the output files to the user
  print(res)
  # if there is a message, show it (if msg = "", nothing will be shown)
  message(msg)
  # clean up after yourself!!
  py_run_string(
    "try:\n  del(res, args, params)\nexcept:\  pass")

  # load output
  if (load_output) {
    # just keep the output files
    # Find out what the output names are
    out_names <- 
      py_run_string(
        sprintf("out_names = RQGIS.get_output_names('%s')", alg))$out_names
    # clean up after yourself!!
    py_run_string(
      "try:\n  del(out_names)\nexcept:\  pass")  
    params_out <- params[out_names]
    # just keep the files which were actually specified by the user
    out_files <- params_out[params_out != "None"]
    ls_1 <- lapply(out_files, function(x) {
      # even if the user only specified an output name without an output
      # directory, we have made sure above that the output is written to the
      # temporary folder
      if (!file.exists(x)) {
        stop("Unfortunately, QGIS did not produce: ", x)
      }
      
      test <- try(expr = readOGR(dsn = dirname(x),
                                 layer = gsub("\\..*", "", 
                                              basename(x)),
                                 verbose = FALSE),
                  silent = TRUE)
      
      # stop the function if the output exists but is empty
      if (inherits(test, "try-error") && 
          grepl("no features found", attr(test, "condition"))) {
        stop("The output-file ", x, " is empty, i.e. it has no features.")
      }
      # if the output exists and is not a vector try to load it as a raster
      if (inherits(test, "try-error")) {
        raster(x)
        # well, well, if this doesn't work, you need to do something...
      } else {
        test
      }   
    })
    # only return a list if the list contains several elements
    if (length(ls_1) == 1) {
      ls_1[[1]]
    } else {
      ls_1
    }
  }
}
