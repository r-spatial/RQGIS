#' @title Retrieve the environment settings to run QGIS from within R
#' @description `set_env` tries to find all the paths necessary to run QGIS
#'   from within R.
#' @param root Root path to the QGIS-installation. If left empty, the function
#'   looks for `qgis.bat` on the C: drive under Windows. On a
#'   Mac, it looks for `QGIS.app` under "Applications" and
#'   "/usr/local/Cellar/". On Linux, `set_env` assumes that the root path
#'   is "/usr".
#' @param ltr If `TRUE`, `set_env` will use the long term release of 
#'   QGIS, if available (only for Windows).
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
set_env <- function(root = NULL, ltr = TRUE) {

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
      # check for homebrew QGIS installation
      path <- system("find /usr/local/Cellar/ -name 'QGIS.app'", intern = TRUE)
      if (length(path) > 0) {
        root <- path
      }
      if (is.null(root)) {
        # check for binary QGIS installation
        path <- system("find /Applications -name 'QGIS.app'", intern = TRUE)
        if(length(path) > 0) {
          root <- path
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
  # return your result
  c(qgis_env, check_apps(root = root, ltr = ltr))
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
#' @importFrom reticulate py_to_r py_run_file py_run_string
#' @export
#' @examples 
#' \dontrun{
#' qgis_session_info()
#' }
qgis_session_info <- function(qgis_env = set_env()) {
  tmp <- try(expr =  open_app(qgis_env = qgis_env), silent = TRUE)
  py_file <- system.file("python", "qgis_session_info.py", package = "RQGIS")
  out <- py_run_file(py_file)

  # retrieve the output
  out <- out$ls
  names(out) <- c("qgis_version", "grass6", "grass7", "saga",
                  "supported_saga_versions")
  
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
#' @importFrom reticulate py_run_string py_run_file
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
  # reticulate:::py_discover_config("C:/OSGeo4W64/bin/python.exe")
  # check if the QGIS application has already been started
  tmp <- try(expr =  open_app(qgis_env = qgis_env), silent = TRUE)
  
  # Advantage of this approach: we are using directly alglist and do not have to
  # save it in inst
  # Disadvantage: more processing
  py_file <- system.file("python", "capturing_barry.py", package = "RQGIS")
  py_run_file(py_file)
  code <- "with Capturing() as output:\n  processing.alglist()"

  algs <- as.character(py_run_string(code)$output)
  algs <- unlist(strsplit(algs, "', |, '"))
  algs <- unlist(strsplit(algs, '", '))
  algs <- gsub("\\['|'\\]|'", "", algs)
  algs = gsub('\\\\|"', "", shQuote(algs))
  algs <- algs[algs != ""]
  # clean up after yourself, just in case
  py_run_string("del(output)")
  
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
#' @param qgis_env Environment containing all the paths to run the QGIS API. For
#'   more information, refer to [set_env()].
#' @details Function `get_usage` simply calls
#'   `processing.alghelp` of the QGIS Python API.
#' @author Jannes Muenchow, Victor Olaya, QGIS core team
#' @importFrom reticulate py_run_string
#' @export
#' @examples
#' \dontrun{
#' # find a function which adds coordinates
#' find_algorithms(search_term = "add")
#' # find function arguments of saga:addcoordinatestopoints
#' get_usage(alg = "saga:addcoordinatestopoints")
#' }

get_usage <- function(alg = NULL,
                      qgis_env = set_env()) {
  tmp <- try(expr =  open_app(qgis_env = qgis_env), silent = TRUE)
  code <- sprintf("with Capturing() as output:\n  processing.alghelp('%s')", 
                  alg)
  out <- as.character(py_run_string(code)$output)
  out <- gsub("^\\[|\\]$|'", "", out)
  out <- gsub(", ", "\n", out)
  # clean up after yourself
  py_run_string("del(output)")
  cat(gsub("\\\\t", "\t", out))
}

#' @title Get options of parameters for a specific GIS option
#' @description `get_options` lists all available parameter options for
#'   the required GIS function.
#' @param alg Name of the GIS function for which options should be
#'   returned.
#' @param qgis_env Environment containing all the paths to run the QGIS API. For
#'   more information, refer to [set_env()].
#' @details Function `get_options` simply calls
#'   `processing.algoptions` of the QGIS Python API.
#' @author Jannes Muenchow, Victor Olaya, QGIS core team
#' @importFrom reticulate py_run_string
#' @examples
#' \dontrun{
#' get_options(alg = "saga:slopeaspectcurvature")
#' }
#' @export
get_options <- function(alg = "",
                        qgis_env = set_env()) {
  
  tmp <- try(expr =  open_app(qgis_env = qgis_env), silent = TRUE)
  code <- sprintf("with Capturing() as output:\n  processing.algoptions('%s')", 
                  alg)
  out <- as.character(py_run_string(code)$output)
  out <- gsub("^\\[|\\]$|'", "", out)
  out <- gsub(", ", "\n", out)
  # clean up after yourself
  py_run_string("del(output)")
  cat(gsub("\\\\t", "\t", out))
}

#' @title Access the QGIS/GRASS online help for a specific (Q)GIS geoalgorihm
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
    open_grass_help(alg)
  } else {
    algName <- alg
  }
  py_cmd <- sprintf("alg = Processing.getAlgorithm('%s')", algName)
  py_run_string(py_cmd)
  py_file <- system.file("python", "open_help.py", package = "RQGIS")
  out <- py_run_file(py_file)
  
  # clean up after yourself
  py_cmd <- paste0("del(provider, groupName, algName, safeGroupName, ", 
                   "validChars, safeAlgName, version, url, savout)")
  py_run_string(py_cmd)
}

#' @title Get GIS arguments and respective default values
#' @description`get_args_man` retrieves automatically function arguments 
#' and respective default values for a given QGIS geoalgorithm.
#' @param alg The name of the algorithm for which one wishes to retrieve
#'   arguments and default values.
#' @param options Sometimes one can choose between various options for a 
#'   function argument. Setting option to `TRUE` will automatically assume 
#'   one wishes to use the first option (default: `FALSE`).
#' @param qgis_env Environment containing all the paths to run the QGIS API. For
#'   more information, refer to [set_env()].
#' @details `get_args_man` basically mimics the behavior of the QGIS GUI. 
#'   That means, for a given GIS algorithm, it captures automatically all 
#'   arguments and default values. In the case that a function argument has
#'   several options, one can indicate to use the first option (see also
#'   [get_options()]), which is the QGIS GUI default behavior.
#' @return The function returns a list whose names correspond to the function 
#'   arguments one needs to specify. The list elements correspond to the argument
#'   specifications. The specified function arguments can serve as input for 
#'   [run_qgis()]'s params argument. Please note that although 
#'   `get_args_man` tries to retrieve default values, one still needs to 
#'   specify some function arguments manually such as the input and the output 
#'   layer.
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
  
  py_cmd <- sprintf("alg = Processing.getAlgorithm('%s')", alg)
  py_run_string(py_cmd)
  py_file <- system.file("python", "get_args_man.py", package = "RQGIS")
  
  # you have to be careful here, if you want to preserve True and False in
  # Python language... -> check!!!!!!!!!!! or maybe not, because reticulate is
  # taking care of it???
  args <- py_run_file(py_file)$args
  names(args) <- c("params", "vals", "opts")
  
  # If desired, select the first option if a function argument has several
  # options to choose from
  if (options) {
    args$vals[args$opts] <- "0"
  }
  # clean up after yoursef
  py_run_string("del(alg, args, params, vals, opts)")
  # return your result
  out <- as.list(args$vals)
  names(out) <- args$params
  out
}

#'@title Interface to QGIS commands
#'@description `run_qgis` calls QGIS algorithms from within R while passing
#'  the corresponding function arguments.
#'@param alg Name of the GIS function to be used (see 
#'  [find_algorithms()]).
#'@param params A list of geoalgorithm function arguments that should be used in
#'  conjunction with the selected (Q)GIS function (see 
#'  [get_args_man()]). Please make sure to provide all function 
#'  arguments in the correct order. To make sure this is the case, it is 
#'  recommended to use the convenience function [get_args_man()].
#'@param check_params If `TRUE` (default), it will be checked if all 
#'  geoalgorithm function arguments were provided in the correct order.
#'@param show_msg Logical, if `TRUE`, Python messages that occured during
#'  the algorithm execution will be shown.
#'@param load_output Character vector containing paths to (an) output file(s) in
#'  order to load the QGIS output directly into R (optional). If 
#'  `load_output` consists of more than one element, a list will be 
#'  returned. See the example section for more details.
#'@param qgis_env Environment containing all the paths to run the QGIS API. For
#'  more information, refer to [set_env()].
#'@details This workhorse function calls the QGIS Python API through the command
#'  line. Specifically, it calls `processing.runalg`.
#'@return If not otherwise specified, the function saves the QGIS generated 
#'  output files in a temporary folder. Optionally, function parameter 
#'  `load_output` loads spatial QGIS output (vector and raster data) into
#'  R.
#'@note Please note that one can also pass spatial R objects as input parameters
#'  where suitable (e.g., input layer, input raster). Supported formats are
#'  [sp::SpatialPointsDataFrame()]-, 
#'  [sp::SpatialLinesDataFrame()]-, 
#'  [sp::SpatialPolygonsDataFrame()]- and 
#'  [raster::raster()]-objects. See the example section for more 
#'  details.
#'  
#' GRASS users do not have to specify manually the GRASS region extent (function
#' argument GRASS_REGION_PARAMETER). If "None", `run_qgis` will
#' automatically retrieve the region extent based on the input layers.
#' @author Jannes Muenchow, Victor Olaya, QGIS core team
#' @export
#' @importFrom sp SpatialPointsDataFrame SpatialPolygonsDataFrame
#' @importFrom sp SpatialLinesDataFrame
#' @importFrom raster raster
#' @examples
#' \dontrun{
#' # set the environment
#' my_env <- set_env()
#' # find out how a function is called
#' find_algorithms(search_term = "add", qgis_env = my_env)
#' # specify parameters
#' params <- get_args_man("saga:addcoordinatestopoints", qgis_env = my_env)
#' # load random_points - a SpatialPointsDataFrame
#' data(random_points, package = "RQGIS")
#' params$INPUT <- random_points
#' # Here I specify a SpatialPointsDataFrame as input, but one could also
#' # specify the path to a spatial object file (e.g., shapefile), e.g.;
#' # params$INPUT <- "random_points.shp"
#' params$OUTPUT <- "output.shp"
#' # Run the QGIS API and load its output into R
#' run_qgis(alg = "saga:addcoordinatestopoints",
#'          params = params,
#'          load_output = params$OUTPUT,
#'          qgis_env = my_env)
#'}
run_qgis <- function(alg = NULL, params = NULL, check_params = TRUE,
                     show_msg = TRUE, load_output = NULL,
                     qgis_env = set_env()) {
  # check if alg is qgis:vectorgrid
  if (alg == "qgis:vectorgrid") {
    stop("Please use qgis:creategrid instead of qgis:vectorgrid!")
  }
  
  # check if alg belongs to the QGIS "select by.."-category
  if (grepl("^qgis\\:selectby", alg)) {
    stop(paste("The 'Select by' operations of QGIS are interactive.", 
               "Please use 'grass7:v.extract' instead."))
  }
  
  # check if all necessary function arguments were supplied
  args <- list(alg, params)
  ind <- mapply(is.null, args)
  if (any(ind)) {
    stop("Please specify: ", paste(args[ind], collapse = ", "))
  }
  
  # check if all arguments were specified in the correct order
  if (check_params) {
    test <- get_args_man(alg, qgis_env = qgis_env)  
    
    # check if there are too few/many function arguments
    if (length(params) != length(test)) {
      ifelse(length(params) > length(test),
             stop("Unknown function argument(s): ", 
                  paste(setdiff(names(params), names(test)), collapse = ", ")),
             stop("Function argument(s) ", 
                  paste(setdiff(names(test), names(params)), collapse = ", "),
                  "are missing"))
    }
    
    # check if all function arguments are in the correct order
    ind <- names(test) != names(params)
    if (any(ind)) {
      stop("Function argument(s) ", 
           paste(names(params)[ind], collapse = ", "),
           " should be ",
           paste(names(test)[ind], collapse = ", "))
    }
  }
  
  # save Spatial-Objects (sp and raster)
  # define temporary folder
  tmp_dir <- tempdir()
  params[] <- lapply(seq_along(params), function(i) {
    tmp <- class(params[[i]])
    # check if the function argument is a SpatialObject
    if (grepl("^Spatial(Points|Lines|Polygons)DataFrame$", tmp) && 
        attr(tmp, "package") == "sp") {
      rgdal::writeOGR(params[[i]], dsn = tmp_dir, 
                      layer = names(params)[[i]],
                      driver = "ESRI Shapefile",
                      overwrite_layer = TRUE)
      # return the result
      file.path(tmp_dir, paste0(names(params)[[i]], ".shp"))
    } else if (tmp == "RasterLayer") {
      fname <- file.path(tmp_dir, paste0(names(params)[[i]], ".asc"))
      raster::writeRaster(params[[i]], filename = fname, format = "ascii", 
                          prj = TRUE, overwrite = TRUE)
      # return the result
      fname
    } else {
      params[[i]]
    }
  })
  
  # set the bbox in the case of GRASS functions if it hasn't already been 
  # provided (if there are more of these 3rd-party based specifics, put them in
  # a new function)
  if ("GRASS_REGION_PARAMETER" %in% names(params) && 
      grepl("None", params$GRASS_REGION_PARAMETER)) {
    # dismiss the last argument since it frequently corresponds to the output if
    # the output was created before using another CRS, the function might crash
    ext <- params[-length(params)]
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
      tmp <- try(expr = rgdal::ogrInfo(dsn = x, layer = my_layer)$extent,
                 silent = TRUE)
      if (!inherits(tmp, "try-error")) {
        # check if this is always this way (xmin, ymin, xmax, ymax...)
        raster::extent(tmp[c(1, 3, 2, 4)])
      } else {
        # determine bbox in the case of a raster
        ext <- try(expr = rgdal::GDALinfo(x, returnStats = FALSE),
                   silent = TRUE)
        # check if it is still an error
        if (!inherits(ext, "try-error")) {
          # xmin, xmax, ymin, ymax
          raster::extent(c(ext["ll.x"], 
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
    # final bounding box in GRASS notation
    params$GRASS_REGION_PARAMETER <- 
      paste(c(ext@xmin, ext@xmax, ext@ymin, ext@ymax), collapse = ",")
  }
  
  # run QGIS
  
  # shellquote algorithm name
  start <- shQuote(alg)
  # retrieve specified function arguments, i.e. the values
  # Sometimes function arguments are already shellquoted. Shellquoting them 
  # again will result in an error, e.g., grass7:r.viewshed
  # Hence, get rid off shellQuotes (if there are any) before you shellQuote
  # again... and ShellQuotes (or at least quotes) are needed when using the
  # command line 
  val <- vapply(params, function(x) {
    # get rid off shellQuotes 
    tmp <- unlist(strsplit(as.character(x), ""))
    tmp <- tmp[tmp != "\""]
    # paste the argument together again
    tmp <- paste(tmp, collapse = "")
    # shellQuote argument if they are not True, False or None
    ifelse(grepl("True|False|None", tmp), tmp, shQuote(tmp))
  }, character(1))
  
  # build the Python command
  args <- paste(val, collapse = ", ")
  args <- paste0(paste(start, args, sep = ", "))
  # run QGIS command (while catching possible error messages)
  msg <- execute_cmds(processing_name = "processing.runalg",
                      params = args,
                      qgis_env = qgis_env,
                      intern = ifelse(Sys.info()["sysname"] == "Darwin",
                                      FALSE, TRUE))
  if (any(grepl("Error", msg))) {
    stop(msg)
  }
  # if a message was produced, show it in the console
  if (show_msg && length(msg) > 0 && !identical(msg, tempdir())) {
    message(msg)
  }
  
  
  # load output
  if (!is.null(load_output)) {
    ls_1 <- lapply(load_output, function(x) {
      
      fname <- ifelse(dirname(x) == ".", 
                      file.path(tmp_dir, x),
                      x)
       if (!file.exists(fname)) {
        stop("Unfortunately, QGIS did not produce: ", x)
      }
     
      test <- try(expr = 
                    rgdal::readOGR(dsn = dirname(fname),
                                   layer = gsub("\\..*", "", 
                                                basename(fname)),
                                   verbose = FALSE),
                  silent = TRUE
      )
      
      # stop the function if the output exists but is empty
      if (inherits(test, "try-error") && 
          grepl("no features found", attr(test, "condition"))) {
        stop("The output-file ", fname, " is empty, i.e. it has no features.")
      }
      # if the output exists and is not a vector try to load it as a raster
      if (inherits(test, "try-error")) {
        raster::raster(fname)
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


