#' @title Retrieve the environment settings to run QGIS from within R
#' @description \code{set_env} tries to find all the paths necessary to run QGIS
#'   from within R.
#' @param path Path to the OSGeo4W-installation (only for machines running on
#'   Windows). 
#' @details If you do not specify function parameter \code{path}, the function 
#'   looks for \code{qgis.bat}-file on your C: drive. However, this only works 
#'   if you have used the OSGeo4W-installation. That means, if you installed
#'   QGIS on your system without using the OSGeo4W-routine, the function might
#'   still be able to find the QGIS-installation. However, RQGIS will throw an
#'   error message since \code{check_apps} will not find the dependencies
#'   necessary to use the Python QGIS API.
#' @examples 
#' set_env()
#' @export
#' @author Jannes Muenchow
set_env <- function(path = NULL,
                    qgis = NULL,
                    python27 = NULL,
                    qt4 = NULL,
                    gdal = NULL,
                    msys = NULL,
                    grass = NULL,
                    saga = NULL) {
    if (Sys.info()["sysname"] == "Windows") {
        
        if (is.null(path)) {
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
            raw <- "dir /s /b | findstr"
            # search QGIS on the the C: drive
            cmd <- paste(raw, shQuote("bin\\\\qgis.bat$"))
            path <- shell(cmd, intern = TRUE)
            # # search GRASS
            # cmd <- paste(raw, shQuote("grass-[0-9].*\\bin$"))
            # tmp <- shell(cmd, intern = TRUE)
            # # look for Python27
            # cmd <- paste(raw, shQuote("Python27$"))
            # shell(cmd, intern = TRUE)
            
            if (length(path) == 0) {
                stop("Sorry, OSGeo4W and QGIS are not installed on the C: drive.",
                     " Please specify the path to your OSGeo4W-installation", 
                     " manually.")
            } else if (length(path) > 1) {
                stop("There are several QGIS installations on your system:\n",
                     paste(path, collapse = "\n"))
            } else {
                # define root, i.e. OSGeo4W-installation
                path <-  gsub("\\\\bin.*", "", path)
            }
        }
        # harmonize path syntax
        path <- gsub("/|//", "\\\\", path)
        # make sure that the root path does not end with some sort of slash
        path <- gsub("/$|//$|\\$|\\\\$", "", path)
        out <- list(root = path)
        
        # return your result
        c(out, check_apps(osgeo4w_root = path))
    }
    
    if (Sys.info()["sysname"] == "Darwin") {
        
        if (is.null(path)) {
            message("Trying to find QGIS on your PC. This may take a moment.")
            
            # ok, it's better to just set the working directory and change it back
            # to the directory when exiting the function
            cwd <- getwd()
            on.exit(setwd(cwd))
            setwd("/")
            # search QGIS on the the /applications folder
            cmd <- "find /applications -type f \\( ! -name '*.*' -a -name 'QGIS' \\)"
            qgis_env <- gsub("/MacOS/QGIS", "", system(cmd, intern = TRUE))
        }
        # return result
        paste0("QGIS Installation path: ", qgis_env)
    }
    
    if (Sys.info()["sysname"] == "Linux") {
        
        if (is.null(path)) {
            qgis_env = "/usr"
        }
        # return result
        paste0("QGIS Installation path: ", qgis_env)
    }
}

#' @title Find and list available QGIS algorithms
#' @description \code{find_algorithms} lists or queries all algorithms which
#'   can be used via the command line and the QGIS API.
#' @param qgis_env Environment containing all the paths to run the QGIS API. For
#'   more information, refer to \link{\code{set_env}}.
#' @param search_term A character to query QGIS functions, i.e. to list only
#'   functions which contain the indicated string.
#' @details Function \code{find_algorithms} simply calls
#'   \code{processing.alglist} using Python.
#' @return Python console output will be captured as an R character vector.
#' @author Jannes Muenchow, QGIS developer team
#' @examples
#' # list all available QGIS algorithms
#' find_algorithms()
#' # find a function which adds coordinates
#' find_algorithms(search_term = "add")
#' @export
find_algorithms <- function(search_term = "", qgis_env = set_env()) {
  
    execute_cmds(processing_name = "processing.alglist",
                 params = shQuote(search_term),
                 qgis_env = set_env(),
                 intern = F)
}

#' @title Get usage of a specific GIS function
#' @description \code{get_usage} lists all function parameters of a specific GIS
#'   function.
#' @param algorithm_name Name of the function whose parameters are being
#'   searched for.
#' @param qgis_env Environment containing all the paths to run the QGIS API. For
#'   more information, refer to \link{\code{set_env}}.
#' @param intern Logical which indicates whether to capture the output of the
#'   command as an \code{R} character vector (see also
#'   \code{\link[base]{system}}.
#' @author Jannes Muenchow, QGIS developer team
#' @export
#' @examples
#' # find a function which adds coordinates
#' find_algorithms(search_term = "add")
#' # find function arguments of saga:addcoordinatestopoints
#' get_usage(algorithm_name = "saga:addcoordinatestopoints")
get_usage <- function(algorithm_name = "",
                      qgis_env = set_env(),
                      intern = FALSE) {
  
  execute_cmds(processing_name = "processing.alghelp",
               params = shQuote(algorithm_name),
               qgis_env = set_env(),
               intern = intern)
}

#' @title Get options of parameters for a specific GIS option
#' @description \code{get_options} lists all available parameter options for
#'   the required GIS function.
#' @param algorithm_name Name of the GIS function for which options should be
#'   returned.
#' @param qgis_env Environment containing all the paths to run the QGIS API. For
#'   more information, refer to \link{\code{set_env}}.
#' @author Jannes Muenchow, QGIS devleoper team
#' @examples
#' get_options(algorithm_name = "saga:slopeaspectcurvature")
get_options <- function(algorithm_name = "",
                        qgis_env = set_env()) {
  
  execute_cmds(processing_name = "processing.algoptions",
               params = shQuote(algorithm_name),
               qgis_env = qgis_env)
}


#' @title Interface to QGIS commands
#' @description \code{run_qgis} is the workhorse of the R-QGIS interface: It
#'   calls the QGIS API from within R to run QGIS algorithms while passing the
#'   corresponding function arguments.
#' @param algorithm Name of the GIS function to be used (see
#'   \code{\link{find_algorithms}}).
#' @param params A list of function arguments that should be used in conjunction
#'   with the selected GIS function (see \code{\link{get_usage}} and
#'   \code{\link{get_options}}).
#' @param qgis_env Environment containing all the paths to run the QGIS API. For
#'   more information, refer to \link{\code{set_env}}.
#' @details This workhorse function calls QGIS via Python (QGIS API) using the
#'   command line.
#' @author Jannes Muenchow, QGIS developer team
#' @export
#' @examples
#' \dontrun{
#' # set the environment
#' my_env <- set_env()
#' # find out how a function is called
#' find_algorithms(search_term = "add", qgis_env = my_env)
#' # find out how it works
#' get_usage(algorithm_name = "saga:addcoordinatestopoints", qgis_env = my_env)
#' # specify the parameters in the exact same order as listed by get_usage
#' params <- list(INPUT = "C:/Users/pi37pat/Desktop/test/random_squares.shp",
#'      OUTPUT = "C:/Users/pi37pat/Desktop/test/qgis_testi2.shp")
#' run_qgis(algorithm = "saga:addcoordinatestopoints",
#'          params = params,
#'          qgis_env = my_env)
#' }
run_qgis <- function(algorithm = NULL, params = list(),
                     qgis_env = set_env()) {
  
    if (Sys.info()["sysname"] == "Windows") {
        nm = names(params)
        val = as.character(unlist(params))
        # build command
        # start <- paste0("processing.runalg('algOrName' = ", shQuote(algorithm))
        start <- shQuote(algorithm)
        # mmh, processing.runalg does not accept arguments... that's unfortunate
        # args <- paste(shQuote(nm), shQuote(val),  sep = " = ", collapse = ", ")
        args <- paste(shQuote(val), collapse = ", ")
        args <- paste0(paste(start, args, sep = ", "))
        # run QGIS command
        execute_cmds(processing_name = "processing.runalg",
                     params = args,
                     qgis_env = qgis_env)
    }
    
    if (Sys.info()["sysname"] == "Darwin") {
        nm = names(params)
        val = as.character(unlist(params))
        # renice param paths
        val = gsub("//", "/", val)
        val = gsub("\\\\", "/", val)
        # build command
        # start <- paste0("processing.runalg('algOrName' = ", shQuote(algorithm))
        start <- shQuote(algorithm)
        # mmh, processing.runalg does not accept arguments... that's unfortunate
        # args <- paste(shQuote(nm), shQuote(val),  sep = " = ", collapse = ", ")
        args <- paste(shQuote(val), collapse = ", ")
        args <- paste0(paste(start, args, sep = ", "))
        # run QGIS command
        execute_cmds(processing_name = "processing.runalg",
                     params = args,
                     qgis_env = qgis_env, 
                     intern = FALSE)
    }
    
}
