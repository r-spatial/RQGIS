#' @title Checking paths to QGIS applications
#' @description `check_apps` checks if software applications necessary to
#'   run QGIS (QGIS and Python plugins) are installed in the correct
#'   locations.
#' @param root Path to the root directory. Usually, this is 'C:/OSGEO4~1', 
#'   '/usr' and '/Applications/QGIS.app/' for the different platforms.
#' @param ... Optional arguments used in `check_apps`. Under Windows,
#'   `set_env` passes function argument `dev` to `check_apps`.
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
    if (length(dots) > 0 && !isTRUE(dots$dev)) {
      my_qgis <- ifelse("qgis-ltr" %in% my_qgis, "qgis-ltr", my_qgis[1])  
    } else {
      # use ../apps/qgis, i.e. most likely the most recent QGIS version
      my_qgis <- my_qgis[1]
    }
    apps <- c(file.path(path_apps, my_qgis),
              file.path(path_apps, my_qgis, "python/plugins"))
  } else if (Sys.info()["sysname"] == "Linux" | Sys.info()["sysname"] == "FreeBSD") {
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

#' @title Open the GRASS online help
#' @description `open_grass_help` opens the GRASS online help for a specific
#'   GRASS geoalgorithm.
#' @param alg The name of the GRASS geoalgorithm for which one wishes to open
#'   the online help.
#' @keywords internal
#' @examples 
#' \dontrun{
#' open_grass_help("grass7:r.sunmask")
#' }
#' @author Jannes Muenchow
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
  
  Sys.setenv(PATH = paste(file.path(qgis_env$root, "bin"), 
                          file.path(windir, "system32"),
                          windir,
                          file.path(windir, "WBem"),
                          sep = ";"))
  # call all bat-files
  run_ini(qgis_env = qgis_env)
  
  # we need to make sure that qgis-ltr can also be used...
  my_qgis <- gsub(".*/", "", qgis_env$qgis_prefix_path)
  # add the directories where the QGIS libraries reside to search path 
  # of the dynamic linker
  Sys.setenv(PATH = paste(Sys.getenv("PATH"),
                          file.path(qgis_env$root, "apps", my_qgis, "bin"),
                          sep = ";"))
  # set the PYTHONPATH variable, so that QGIS knows where to search for
  # QGIS libraries and appropriate Python modules
  python_path <- Sys.getenv("PYTHONPATH")
  python_add <- file.path(qgis_env$root, "apps", my_qgis, "python")
  if (!grepl(python_add, python_path)) {
    python_path <- paste(python_path, python_add, sep = ";")    
    Sys.setenv(PYTHONPATH = python_path)
    }

  # defining QGIS prefix path (i.e. without bin)
  Sys.setenv(QGIS_PREFIX_PATH = file.path(qgis_env$root, "apps", my_qgis))
  # shell.exec("python")  # yeah, it works!!!
  # !!!Try to make sure that the right Python version is used!!!
  use_python(file.path(qgis_env$root, "bin/python.exe"), 
             required = TRUE)
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


#' @title Reproduce o4w_env.bat script in R
#' @description Windows helper function to start QGIS application. Basically, 
#'   the code found in all .bat files found in etc/ini (most likely
#'   "C:/OSGEO4~1/etc/ini") is reproduced within R.
#' @importFrom readr read_file
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
  # root <- gsub("\\\\", "\\\\\\\\", qgis_env$root)
  ls <- lapply(files, function(file) {
    tmp <- read_file(file)
    tmp <- gsub("%OSGEO4W_ROOT%", qgis_env$root, tmp)
    tmp <- strsplit(tmp, split = "\r\n|\n")[[1]]
    tmp
  })
  cmds <- do.call(c, ls)
  # remove everything followed by a semi-colon but not if the colon is followed 
  # by %PATH%
  cmds <- gsub(";%([^PATH]).*", "", cmds)
  cmds <- gsub(";%PYTHONPATH%", "", cmds)  # well, not really elegant...
  cmds <- gsub("\\\\", "/", cmds)
  for (i in cmds) {
    if (grepl("^(SET|set)", i)) {
      tmp <- gsub("^(SET|set) ", "", i)
      tmp <- strsplit(tmp, "=")[[1]]
      args <- list(tmp[2])
      names(args) <- tmp[1]
      # if the environment variable exists but does not contain our path, add it
      # to the already existing one
      if (Sys.getenv(names(args)) != "" &
          !grepl(gsub("\\\\", "\\\\\\\\", args[[1]]), 
                 Sys.getenv((names(args))))) {
        args[[1]] <- paste(args[[1]], Sys.getenv(names(args)), sep = ";")
        
      } else if (Sys.getenv(names(args)) != "" &
                 grepl(gsub("\\\\", "\\\\\\\\", args[[1]]), 
                        Sys.getenv((names(args))))) {
        # if the environment variable already exists and already contains the
        # correct path, do nothing
        next
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

#' @title Reset PATH
#' @description Since [run_ini()] starts with a clean PATH, this function makes 
#'   sure to add the original paths to PATH. Note that this function is a
#'   Windows-only function.
#' @param settings A list as derived from `as.list(Sys.getenv())`.
#' @author Jannes Muenchow
reset_path <- function(settings) {
  # PATH re-setting: not the most elegant solution...
  
  if (Sys.info()["sysname"] == "Windows") {
    # first delete any other Anaconda or Python installations from PATH
    tmp <- grep("Anaconda|Python", unlist(strsplit(settings$PATH, ";")),
                value = TRUE)
    # we don't want to delete any paths containing OSGEO (and Python)
    if (any(grepl("OSGeo", tmp))) {
      tmp <- tmp[-grep("OSGeo", tmp)]  
    }
      # replace \\ by \\\\ and collapse by |
    tmp <- paste(gsub("\\\\", "\\\\\\\\", tmp), collapse = "|")
    # delete it from settings
    repl <- gsub(tmp, "", settings$PATH)
    # get rid off repeated semi-colons
    settings$PATH <- gsub(";+", ";", repl)
    
    # We need to make sure to not append over and over again the same paths
    # when running open_app several times
    if (grepl(gsub("\\\\", "\\\\\\\\", Sys.getenv("PATH")), settings$PATH)) {
      # if the OSGeo stuff is already in PATH (which is the case after having
      # run open_app for the fist time), use exactly this PATH
      Sys.setenv(PATH = settings$PATH)
    } else {
      # if the OSGeo stuff has not already been appended (as is the case when
      # running open_app for the first time), append it
      paths <- paste(Sys.getenv("PATH"), settings$PATH, sep = ";")  
      Sys.setenv(PATH = paths)
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


#' @title Set all Mac paths necessary to start QGIS
#' @description Helper function to start QGIS application under macOS.
#' @param qgis_env Environment settings containing all the paths to run the QGIS
#'   API. For more information, refer to [set_env()].
#' @return The function changes the system settings using [base::Sys.setenv()].
#' @keywords internal
#' @author Patrick Schratz
#' @examples 
#' \dontrun{
#' setup_mac()
#' }

setup_mac <- function(qgis_env = set_env()) {
  
  # append PYTHONPATH to import qgis.core etc. packages
  python_path <- Sys.getenv("PYTHONPATH")
  
  qgis_python_path <- 
    paste0(qgis_env$root, paste("/Contents/Resources/python/", 
                                "/usr/local/lib/qt-4/python2.7/site-packages",
                                "/usr/local/lib/python2.7/site-packages",
                                "$PYTHONPATH", sep = ":"))
  if (python_path != "" & !grepl(qgis_python_path, python_path)) {
    qgis_python_path <- paste(qgis_python_path, Sys.getenv("PYTHONPATH"), 
                              sep = ":")
  }
  
  Sys.setenv(QGIS_PREFIX_PATH = paste0(qgis_env$root, "/Contents/MacOS/"))
  Sys.setenv(PYTHONPATH = qgis_python_path)
  
  # define path where QGIS libraries reside to search path of the
  # dynamic linker
  ld_library <- Sys.getenv("LD_LIBRARY_PATH")
  
  qgis_ld <- paste(paste0(qgis_env$qgis_prefix_path, 
                          file.path("/MacOS/lib/:/Applications/QGIS.app/", 
                                    "Contents/Frameworks/"))) # homebrew
  if (ld_library != "" & !grepl(paste0(qgis_ld, ":"), ld_library)) {
    qgis_ld <- paste(paste0(qgis_env$root, "/lib"),
                     Sys.getenv("LD_LIBRARY_PATH"), sep = ":")
  }
  Sys.setenv(LD_LIBRARY_PATH = qgis_ld)
  
  # suppress verbose QGIS output for homebrew
  Sys.setenv(QGIS_DEBUG = -1)
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
#'   \item Were the right parameter names used? 
#'   \item Were the correct argument values provided? 
#'   \item The function collects all necessary arguments (to run QGIS) and
#'   respective default values which were not set by the user with the help of
#'   [get_args_man()].
#'   \item If an argument value corresponds to a spatial object residing in R 
#'   (`sp`-, `sf`- or `raster`-objects are supported), the function will save 
#'   the spatial object to a temporary folder, and use the corresponding file 
#'   path to replace the spatial object in the parameter-argument list. If the 
#'   QGIS geoalgorithm parameter belongs to the 
#'   `ParameterMultipleInput`-instance class (see for example 
#'   `get_usage(grass7:v.patch)`) you may either use a character-string 
#'   containing the paths to the spatial objects separated by a semi-colon 
#'   (e.g., "shape1.shp;shape2.shp;shape3.shp" - see also [QGIS 
#'   documentation](https://docs.qgis.org/2.8/en/docs/user_manual/processing/console.html))
#'   or provide a [base::list()] containing the spatial objects.
#'   \item If the user only specified the name of an output file (e.g.
#'   "slope.asc") and not a complete path, the function will save the output in
#'   the temporary folder, i.e. to `file.path(tempdir(), "slope.asc")`.
#'   \item If a parameter accepts as arguments values from a selection, the
#'   function replaces verbal input by the corresponding number (required by the
#'   QGIS Python API). Please refer to the example section for more details, and
#'   to [get_options()] for valid options for a given geoalgorithm.
#'  \item If `GRASS_REGION_PARAMETER` is "None" (the QGIS default), `run_qgis` 
#'  will automatically determine the region extent based on the user-specified 
#'  input layers. If you do want to specify the `GRASS_REGION_PARAMETER` 
#'  yourself, please do it in accordance with the [QGIS 
#'  documentation](https://docs.qgis.org/2.8/en/docs/user_manual/processing/console.html),
#'  i.e., use a character string and separate the coordinates with a comma: 
#'  "xmin, xmax, ymin, ymax".
#'   }
#' @note The function was inspired by [rgrass7::doGRASS()].
#' @author Jannes Muenchow
#' @importFrom sp SpatialPointsDataFrame SpatialPolygonsDataFrame
#' @importFrom sp SpatialLinesDataFrame
#' @importFrom raster raster writeRaster extent
#' @importFrom sf write_sf st_as_sf
#' @importFrom rgdal ogrInfo writeOGR readOGR GDALinfo
#' @importFrom utils capture.output
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
  
  # Save Spatial-Objects (sp, sf and raster)
  # here, we would like to retrieve the type type of the argument (which is list
  # element 4)
  out <- py_run_string(sprintf("out = RQGIS.get_args_man('%s')", alg))$out
  # just run through list elements which might be an input file (i.e. which are
  # certainly not an output file)
  params[!out$output] <- save_spatial_objects(params = params[!out$output], 
                                              type_name = out$type_name)
  
  # if the user has only specified an output filename without a directory path,
  # make sure that the output will be saved to the temporary R folder (not doing
  # so could sometimes save the output in the temporary QGIS folder)
  # if the user has not specified any output files, nothing happens
  params[out$output] <- lapply(params[out$output], function(x) {
    if (basename(x) != "None" && dirname(x) == ".") {
      normalizePath(file.path(tempdir(), x), winslash = "/", mustWork = FALSE)
    } else if (basename(x) != "None") {
      normalizePath(x, winslash = "/", mustWork = FALSE)
    } else {
      x
    }
  })
  
  # set the bbox in the case of GRASS functions if it hasn't already been 
  # provided (if there are more of these 3rd-party based specifics, put them in
  # a new function)
  if (grepl("grass7?:", alg) &&
      grepl("None", params$GRASS_REGION_PARAMETER)) {
    # run through the arguments and check if we can extract a bbox. While doing
    # so, dismiss the output arguments. Not doing so could cause R to crash
    # since the output-file might already exist. For instance, the already
    # existing output might have another CRS.
    ext <- get_grp(params = params[!out$output], 
                   type_name = out$type_name[!out$output])
    # final bounding box in the QGIS/GRASS notation
    params$GRASS_REGION_PARAMETER <- paste(ext, collapse = ",")
  }
  # make sure function arguments are in the correct order is not srictly
  # necessary any longer since we use a Python dictionary to pass our arguments.
  # However, otherwise, the user might become confused... and for
  # RQGIS.check_args the correct order is important as well! Doing the check
  # here has also the advantage that the function tells the user all missing
  # function arguments, QGIS returns only one at a time
  params <- params[names(params_all)]
  
  check <- py_run_string(sprintf("check = RQGIS.check_args('%s', %s)", alg,
                                 py_unicode(r_to_py(unlist(params)))))$check
  # stop the function if wrong arguments were supplied, e.g.,
  # 'grass7:r.slope.aspect":
  # format must be an integer, so you cannot supply "hallo", the same goes for
  # the precision and the the GRASS_REGION_PARAMETER
  if (length(check) > 0) {
    stop(sprintf("Invalid argument value '%s' for parameter '%s'\n",
                 check, names(check)))
  }
  # # clean up after yourself!!
  py_run_string(
    "try:\n  del(out, opts, check)\nexcept:\  pass")  
  # return your result
  params
}

#' @title Save spatial objects
#' @description The function saves spatial objects (`sp`, `sf` and `raster`) to 
#'   a temporary folder on the computer's hard drive.
#' @param params A parameter-argument list as returned by [pass_args()].
#' @param type_name A character string containing the QGIS parameter type for
#'   each parameter (boolean, multipleinput, extent, number, etc.) of `params`.
#'   The Python method `RQGIS.get_args_man` returns a Python dictionary with one
#'   of its elements corresponding to the type_name (see also the example
#'   section).
#' @keywords internal
#' @examples 
#' \dontrun{
#' library("RQGIS")
#' library("raster")
#' library("reticulate")
#' r <- raster(ncol = 100, nrow = 100)
#' r1 <- crop(r, extent(-10, 11, -10, 11))
#' r2 <- crop(r, extent(0, 20, 0, 20))
#' r3 <- crop(r, extent(9, 30, 9, 30))
#' r1[] <- 1:ncell(r1)
#' r2[] <- 1:ncell(r2)
#' r3[] <- 1:ncell(r3)
#' alg <- "grass7:r.patch"
#' out <- py_run_string(sprintf("out = RQGIS.get_args_man('%s')", alg))$out
#' params <- get_args_man(alg)
#' params$input <- list(r1, r2, r3)
#' params[] <- save_spatial_objects(params = params, 
#'                                  type_name = out$type_name)
#' }
#' @author Jannes Muenchow
save_spatial_objects <- function(params, type_name) {
  
  lapply(seq_along(params), function(i) {
    tmp <- class(params[[i]])
    if (tmp == "list" && type_name[i] == "multipleinput") {
      names(params[[i]]) <- paste0("inp", 1:length(params[[i]]))
      out <- save_spatial_objects(params = params[[i]])
      return(paste(unlist(out), collapse = ";"))
    }
    
    # GEOMETRY and GEOMETRYCOLLECTION not supported
    if (any(tmp %in% c("sfc_GEOMETRY", "sfc_GEOMETRYCOLLECTION"))) {
      stop("RQGIS does not support GEOMETRY or GEOMETRYCOLLECTION classes")
    }
    # check if the function argument is a SpatialObject
    if (any(grepl("^Spatial(Points|Lines|Polygons)DataFrame$", tmp)) | 
        any(tmp %in% c("sf", "sfc", "sfg"))) {
      # if it is an sp-object convert it into sf, if it already is an attributed
      # sf-object, nothing happens
      params[[i]] <- st_as_sf(params[[i]])
      # write sf as a shapefile to a temporary location while overwriting any
      # previous versions, I don't know why but sometimes the overwriting does 
      # not work...
      fname <- file.path(tempdir(), paste0(names(params)[i], ".shp"))
      cap <- capture.output({
        suppressWarnings(
          test <- 
            try(write_sf(params[[i]], fname, quiet = TRUE), silent = TRUE)
        )
      })
      if (inherits(test, "try-error")) {
        while (tolower(basename(fname)) %in% tolower(dir(tempdir()))) {
          fname <- paste0(gsub(".shp", "", fname), 1, ".shp")  
        }
        write_sf(params[[i]], fname, quiet = TRUE)
      }
      # return the result
      normalizePath(fname, winslash = "/")
    } else if (tmp == "RasterLayer") {
      fname <- file.path(tempdir(), paste0(names(params)[[i]], ".tif"))
      suppressWarnings(
        test <- 
          try(writeRaster(params[[i]], filename = fname, format = "GTiff", 
                          prj = TRUE, overwrite = TRUE), silent = TRUE)
      )
      if (inherits(test, "try-error")) {
        while (tolower(basename(fname)) %in% tolower(dir(tempdir()))) {
          fname <- paste0(gsub(".tif", "", fname), 1, ".tif")  
        }
        writeRaster(params[[i]], filename = fname, format = "GTiff", 
                    prj = TRUE, overwrite = TRUE)
      }
      # return the result
      normalizePath(fname, winslash = "/")
    } else if (type_name[i] %in% c("vector", "raster", "table") && 
               file.exists(params[[i]])) {
      # if the user provided a path to a vector or a raster (and its not an 
      # output file: we use save_spatial_objects only for non-output files in 
      # pass_args), then normalize this path in case a Windows user has 
      # used backslashes which might lead to trouble when sth. like \t \n or
      # alike appears in the path
      normalizePath(params[[i]], winslash = "/")
    } else {
      params[[i]]
    }
  })
}

#' @title Load and register spatial objects in QGIS
#' @description The function loads and registers vector and raster files in an 
#'   open Python QGIS API session.
#' @param params A parameter-argument list as returned by [pass_args()].
#' @param type_name A character string containing the QGIS parameter type for 
#'   each parameter (boolean, multipleinput, extent, number, vector, raster, 
#'   etc.) of `params`. The Python method `RQGIS.get_args_man` returns a Python 
#'   dictionary with one of its elements corresponding to the type_name (see 
#'   also the example section).
#' @return The function loads and registers geometry data in a QGIS session 
#'   using raster and vector input paths as indicated in the input 
#'   parameter-argument list. The function returns the same list, however, it 
#'   replaces the original paths to the input raster and vector files on disk by
#'   the layer names in the QGIS session.
#' @keywords internal
#' @examples 
#' \dontrun{
#' alg <- "saga:sagawetnessindex"
#' params <- get_args_man(alg)
#' params$DEM <- dem
#' params <- pass_args(alg, params = params)
#' out <- py_run_string(sprintf("out = RQGIS.get_args_man('%s')", alg))$out
#' # make sure to only use input parameters, and not output parameters
#' params[!out$output] <- qgis_load_geom(params = params[!out$output], 
#'                                       type_name = out$type_name[!out$output])

qgis_load_geom <- function(params, type_name) {
  lapply(seq_along(params), function(i) {
    if (type_name[i] == "vector" && params[[i]] != "None") {
      # import raster into QGIS and register it
      file = params[[i]]
      # choose a name that is unlikely to be used
      layer = paste0("qgisvlayer45653", i)
      py_run_string(sprintf("%s = QgsVectorLayer('%s', '%s', 'ogr')",
                            layer, file, layer))
      py_run_string(sprintf("QgsMapLayerRegistry.instance().addMapLayer(%s)",
                            layer))
      py_run_string(
        sprintf("if not %s.isValid(): raise Exception('Failed to load %s')", 
                layer, file))
      # return layer
      layer
    } else if (type_name[i] == "raster" && params[[i]] != "None") {
      # import raster into QGIS and register it
      file = params[[i]]
      base_name = basename(file)
      layer = paste0("qgisrlayer45653", i)
      py_run_string(sprintf("%s = QgsRasterLayer('%s', '%s')",
                            layer, file, base_name))
      py_run_string(sprintf("QgsMapLayerRegistry.instance().addMapLayer(%s)",
                            layer))
      py_run_string(
        sprintf("if not %s.isValid(): raise Exception('Failed to load %s')", 
                layer, file))
      # return layer
      layer
    } else if (type_name[i] == "multipleinput") {
      # ok, here we should do something
      params[[i]]
      } else {
      # just return the input
      params[[i]]
      }
    })
}

#' @title Retrieve the `GRASS_REGION_PARAMETER`
#' @description Retrieve the `GRASS_REGION_PARAMETER` by running through a 
#'   parameter-argument list while merging the extents of all spatial objects.
#' @param params A parameter-argument list as returned by [pass_args()].
#' @param type_name A character string containing the QGIS parameter type for 
#'   each parameter (boolean, multipleinput, extent, number, etc.) of `params`. 
#'   The Python method `RQGIS.get_args_man` returns a Python dictionary with one
#'   of its elements corresponding to the type_name (see also the example
#'   section).
#' @keywords internal
#' @examples 
#' \dontrun{
#' library("RQGIS")
#' library("raster")
#' library("reticulate")
#' r <- raster(ncol = 100, nrow = 100)
#' r1 <- crop(r, extent(-10, 11, -10, 11))
#' r2 <- crop(r, extent(0, 20, 0, 20))
#' r3 <- crop(r, extent(9, 30, 9, 30))
#' r1[] <- 1:ncell(r1)
#' r2[] <- 1:ncell(r2)
#' r3[] <- 1:ncell(r3)
#' alg <- "grass7:r.patch"
#' out <- py_run_string(sprintf("out = RQGIS.get_args_man('%s')", alg))$out
#' params <- get_args_man(alg)
#' params$input <- list(r1, r2, r3)
#' params[] <- save_spatial_objects(alg = alg, params = params, 
#'                                  type_name = out$type_name)
#' get_grp(params = params, type_name = out$type_name)
#' }
#' @author Jannes Muenchow
get_grp <- function(params, type_name) {
  ext <- mapply(function(x, y) {
    if (y == "multipleinput") {
      get_grp(unlist(strsplit(x, split = ";")), "")
    } else {
      # We cannot simply use gsub as we have done before (gsub("[.].*",
      # "",basename(x))) if the filename itself also contains dots, e.g.,
      # gis.osm_roads_free_1.shp 
      # We could use regexp to cut off the file extension
      # my_layer <- stringr::str_extract(basename(x), "[A-z].+[^\\.[A-z]]")
      # but let's use an already existing function
      my_layer <- file_path_sans_ext(basename(as.character(x)))
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
    }
  }, x = params, y = type_name)
  # now that we have possibly several extents, union them
  ext <- ext[!is.na(ext)]
  ext <- Reduce(raster::merge, ext)
  if (is.null(ext)) {
    stop("Either you forgot to specify an input shapefile/raster or the", 
         " input file does not exist")
  }
  # sometimes the extent is given back with dec = ","; you need to change that
  ext <- gsub(",", ".", ext[1:4])
  ext
}


#' @title Check if RQGIS is loaded on a server 
#' @description Performs cross-platform (Unix, Windows) and OS (Debian/Ubuntu) checks for a server infrastructure 
#' @importFrom parallel detectCores
#' @keywords internal
#' @author Patrick Schratz
#' @export
check_for_server <- function() {
  
  # try to get an output of 'lsb_release -a'
  if (detectCores() > 10 && .Platform$OS.type == "unix") {
    test <- try(suppressWarnings(system2("lsb_release", "-a", stdout = TRUE,
                                         stderr = TRUE)), 
                silent = TRUE)
    if (!inherits(test, "try-error")) { 
      get_regex <- grep("Distributor ID:", test, value = TRUE) 
      platform <- gsub("Distributor ID:\t", "", get_regex) 
      
      # check for Debian | Ubuntu
      if (platform == "Debian") {
        warning(paste0("Hey there! According to our internal checks, you are trying to run RQGIS on a server.\n", 
                       "Please note that this is only possible if you imitate a x-display.\n", 
                       "QGIS needs this in the background to be able to execute its processing modules.\n", 
                       "Since we detected you are running a Debian server, the following R command should solve the problem:\n",
                       "system('export DISPLAY=:99 && xdpyinfo -display $DISPLAY > /dev/null || Xvfb $DISPLAY -screen 99 1024x768x16 &').\n", 
                       "Note that you need to run this as root.", collapse = "\n"))
        # set warn = -1 to only display this warning once per session (warn = -1 ignores warnings commands)
        options(warn = -1)
      }
      if (platform == "Ubuntu") {
        warning(paste0("Hey there! According to our internal checks, you are trying to run RQGIS on a server.\n", 
                       "Please note that this is only possible if you imitate a x-display.\n", 
                       "QGIS needs this in the background to be able to execute its processing modules.\n", 
                       "Since we detected you are running a Debian server, the following R command should solve the problem:\n",
                       "system('export DISPLAY=:99 && /etc/init.d/xvfb && start && sleep 3').\n", 
                       "Note that you need to run this as root.", collapse = "\n"))
        # set warn = -1 to only display this warning once per session (warn = -1 ignores warnings commands)
        options(warn = -1)
      }
    } 
  }
  if (detectCores() > 10 && Sys.info()["sysname"] == "Windows") {
    warning(paste0("Hey there! According to our internal checks, you are trying to run RQGIS on a Windows server.\n", 
                   "Please note that this is only possible if you imitate a x-display.\n", 
                   "QGIS needs this in the background to be able to execute its processing modules.\n", 
                   "Note that you need to start the x-display with admin rights", collapse = "\n"))
    # set warn = -1 to only display this warning once per session (warn = -1 ignores warnings commands)
    options(warn = -1)
  }
}


