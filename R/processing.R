#' @title Retrieve the environment settings to run QGIS from within R
#' @description \code{set_env} tries to find all the paths necessary to run QGIS
#'   from within R.
#' @param root Root path to the QGIS-installation.
#' @details If you do not specify function parameter \code{path}, the function 
#'   looks for \code{qgis.bat}-file on your C: drive. However, this only works 
#'   if you have used the OSGeo4W-installation. That means, if you installed 
#'   QGIS on your system without using the OSGeo4W-routine, the function might 
#'   still be able to find the QGIS-installation. However, RQGIS will throw an 
#'   error message since \code{check_apps} will not find the dependencies 
#'   necessary to use the Python QGIS API. If you are running RQGIS under Linux
#'   or on a Mac, \code{set_env} assumes that your root path is "/usr" and
#'   "/applications/QGIS.app/Contents", respectively.
#' @examples 
#' set_env()
#' @export
#' @author Jannes Muenchow
set_env <- function(root = NULL,
                    qgis_prefix_path = NULL,
                    python_plugins = NULL,
                    python27 = NULL,
                    qt4 = NULL,
                    msys = NULL,
                    grass = NULL) {

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
      raw <- "dir /s /b | findstr"
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
        stop("Sorry, OSGeo4W and QGIS are not installed on the C: drive.",
             " Please specify the root to your OSGeo4W-installation", 
             " manually.")
      } else if (length(root) > 1) {
        stop("There are several QGIS installations on your system:\n",
             paste(root, collapse = "\n"))
      } else {
        # define root, i.e. OSGeo4W-installation
        root <-  gsub("\\\\bin.*", "", root)
      }
    }
    # harmonize root syntax
    root <- gsub("/|//", "\\\\", root)
    # make sure that the root path does not end with some sort of slash
    root <- gsub("/$|//$|\\$|\\\\$", "", root)
    qgis_env <- list(root = root)
    qgis_env <- c(qgis_env, check_apps(root = root))
  }
  
  if (Sys.info()["sysname"] == "Darwin") {
    if (is.null(root)) {
      root <- "/applications/QGIS.app"
    }
    # print result to the console
    paste0("QGIS Installation root: ", root)

    qgis_env <- list(root = root)
    qgis_env <- c(qgis_env, qgis_prefix_path = check_apps(root = root) [[1]], 
                  python_plugins = check_apps(root = root) [[2]])
    paste0("QGIS Installation path: ", qgis_env)
  }
  
  if (Sys.info()["sysname"] == "Linux") {
    if (is.null(root)) {
      message("Assuming that your root path is '/usr'!")
      root <- "/usr"
    }
    qgis_env <- list(root = root)
    qgis_env <- c(qgis_env, check_apps(root = root))
  }
  # return your result
  qgis_env
}

#' @title Find and list available QGIS algorithms
#' @description \code{find_algorithms} lists or queries all algorithms which can
#'   be used via the command line and the QGIS API.
#' @param qgis_env Environment containing all the paths to run the QGIS API. For
#'   more information, refer to \code{\link{set_env}}.
#' @param search_term A character to query QGIS functions, i.e. to list only 
#'   functions which contain the indicated string.
#' @param name_only If \code{TRUE}, the function returns only the name(s) of the
#'   found algorithms. Otherwise, a short function description will be returned
#'   as well (default).
#' @param intern Logical which indicates whether to capture the output of the 
#'   command as an \code{R} character vector (see also 
#'   \code{\link[base]{system}}.
#' @details Function \code{find_algorithms} simply calls 
#'   \code{processing.alglist} using Python.
#' @return Python console output will be captured as an R character vector.
#' @author Jannes Muenchow, QGIS developer team
#' @examples
#' # list all available QGIS algorithms on your system
#' algs <- find_algorithms()
#' algs[1:15]
#' # just find all native, i.e. QGIS-algorithms
#' grep("qgis:", algs, value = TRUE)
#' # find a function which adds coordinates
#' find_algorithms(search_term = "add")
#' @export
find_algorithms <- function(search_term = "",
                            qgis_env = set_env(),
                            name_only = FALSE,
                            intern = 
                              ifelse(Sys.info()["sysname"] == "Windows",
                                     TRUE, FALSE)) {
  
    algs <- execute_cmds(processing_name = "processing.alglist",
                         params = shQuote(search_term),
                         qgis_env = qgis_env,
                         intern = intern)
    if (name_only) {
      algs <- gsub(".*>", "", algs)
    }
    # return your result
    algs
}


#' @title Get usage of a specific GIS function
#' @description \code{get_usage} lists all function parameters of a specific GIS
#'   function.
#' @param algorithm_name Name of the function whose parameters are being
#'   searched for.
#' @param qgis_env Environment containing all the paths to run the QGIS API. For
#'   more information, refer to \code{\link{set_env}}.
#' @param intern Logical which indicates whether to capture the output of the
#'   command as an \code{R} character vector (see also
#'   \code{\link[base]{system}}.
#' @details Function \code{get_usage} simply calls
#'   \code{processing.alghelp} using Python.
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
               qgis_env = qgis_env,
               intern = intern)
}

#' @title Get options of parameters for a specific GIS option
#' @description \code{get_options} lists all available parameter options for
#'   the required GIS function.
#' @param algorithm_name Name of the GIS function for which options should be
#'   returned.
#' @param qgis_env Environment containing all the paths to run the QGIS API. For
#'   more information, refer to \code{\link{set_env}}.
#' @param intern Logical which indicates whether to capture the output of the
#'   command as an \code{R} character vector (see also
#'   \code{\link[base]{system}}.
#' @details Function \code{get_options} simply calls
#'   \code{processing.algoptions} using Python.
#' @author Jannes Muenchow, QGIS devleoper team
#' @examples
#' get_options(algorithm_name = "saga:slopeaspectcurvature")
get_options <- function(algorithm_name = "",
                        qgis_env = set_env(),
                        intern = FALSE) {
  execute_cmds(processing_name = "processing.algoptions",
               params = shQuote(algorithm_name),
               qgis_env = qgis_env,
               intern = intern)
}

#' @title Automatically retrieve GIS function arguments
#' @description \code{get_args} uses \code{\link{get_usage}} to retrieve 
#'   function arguments of a GIS function.
#' @param alg A character specifying the GIS algorithm whose arguments you want
#'   to retrieve.
#' @param qgis_env Environment containing all the paths to run the QGIS API. For
#'   more information, refer to \code{\link{set_env}}.
#' @return The function returns a list whose names correspond to the function 
#'   arguments you need to specify. Later on, the specified function arguments 
#'   can serve as input for \code{\link{run_qgis}}'s params argument.
#' @author Jannes Muenchow
#' @export
#' @examples
#' get_args(alg = "qgis:addfieldtoattributestable")
get_args <- function(alg, qgis_env = set_env()) {
  # get the usage of a function
  tmp <- get_usage(algorithm_name = alg, qgis_env = qgis_env, intern = TRUE)
  # check if algorithm could be found
  if (any(grepl("Algorithm not found", tmp))) {
    stop("Specified algorithm was not found!")
  }
  
  # dismiss everything prior to ALGORITHM
  tmp <- tmp[grep("ALGORITHM: ", tmp):length(tmp)]
  # extract the arguments
  ind <- which(tmp == "")
  my_diff <- c(0, diff(ind))
  # extract the arguments
  if (any(my_diff == 1)) {
    ind <- ind[(my_diff == 1)] - 1
    # okay, for now let's hardcode it assuming that only the first double space
    # indicates the break between function arguments and options...
    args <- tmp[1:ind[1]]
    # extract the options
    # opts <- tmp[ind:length(tmp)]
  } else {
    args <- tmp
  }
  args <- grep("\t", args, value = TRUE)
  # extract the domain
  # domain <- gsub(".*<|>", "", args)
  # dismiss the tab and everything following a space
  args <- gsub(" .*|\t", "", args)
  
  # return your result, in this case just the arguments
  # in the future, we might want to return the options and the domains as well
  arg_list <- vector(mode = "list", length = length(args))
  names(arg_list) <- args
  # define the default values: If you have an instance of a QGIS object 
  # representing the layer, you can also pass it as parameter. If the input is 
  # optional and you do not want to use any data object, use None (see also
  # https://docs.qgis.org/2.8/en/docs/user_manual/processing/console.html).
  lapply(arg_list, function(x) x <- "None")
}

#' @title Get GIS arguments and respective default values
#' @description\code{get_args_man} retrieves automatically function arguments 
#' and respective default values for a given GIS algorithm.
#' @param alg The algorithm for which you wish to retrieve arguments and default
#'   values.
#' @param options Sometimes you can choose between various options for a 
#'   function argument. Setting option to \code{TRUE} will automatically assume 
#'   you wish to use the first option (default: \code{FALSE}).
#' @param qgis_env Environment containing all the paths to run the QGIS API. For
#'   more information, refer to \code{\link{set_env}}.
#' @details \code{get_args_man} basically mimicks the behavior of the QGIS GUI.
#'   That means, for a given GIS algorithm, it captures automatically all 
#'   arguments and default values. Additionally, you can indicate that you want 
#'   to use the first option if a function argument has several options (see
#'   also \code{\link{get_options}}), which is the QGIS GUI default behavior.
#' @return The function returns a list whose names correspond to the function 
#'   arguments you need to specify. The list elements correspond to the argument
#'   specifications. The specified function arguments can serve as input for 
#'   \code{\link{run_qgis}}'s params argument. Please note that although 
#'   \code{get_args_man} tries to retrieve default values, you still need to 
#'   specify some function arguments by your own such as input and output 
#'   layers.
#' @export
#' @author Jannes Muenchow
#' @examples 
#' get_args_man(alg = "qgis:addfieldtoattributestable")
#' # and using the option argument
#' get_args_man(alg = "qgis:addfieldtoattributestable", options = TRUE)
get_args_man <- function(alg, options = FALSE, qgis_env = set_env()) {

  # find out if it's necessary to obtain default values for
  # GRASS_REGION_PARAMETER, GRASS_REGION_CELLSIZE_PARAMETER, etc.
  
  # set the paths
  cwd <- getwd()
  on.exit(setwd(cwd))
  tmp_dir <- tempdir()
  setwd(tmp_dir)
  
  # build the raw scripts
  cmds <- build_cmds(qgis_env)
  
  # extend the python command
  py_cmd <- 
    c(cmds$py_cmd,
      "from processing.core.Processing import Processing",
      "from processing.core.parameters import ParameterSelection",
      "from itertools import izip",
      "import csv",
      # retrieve the algorithm
      paste0("alg = Processing.getAlgorithm('", alg, "')"),
      "vals = []",
      "params = []",
      "opts = list()",
      "if alg is None:",
      paste0("  with open('", tmp_dir, "\\output.csv'", ", 'wb') as f:"),
      "    writer = csv.writer(f)",
      "    writer.writerow(['params'])",
      "    writer.writerow(['Specified algorithm does not exist!'])",
      "    f.close()",
      "else:",
      "  alg = alg.getCopy()",
      # retrieve function arguments and defaults
      "  for param in alg.parameters:",
      "    params.append(param.name)",
      "    vals.append(param.getValueAsCommandLineParameter())",
      "    opts.append(isinstance(param, ParameterSelection))",
      "  for out in alg.outputs:",
      "    params.append(out.name)",
      "    vals.append(out.getValueAsCommandLineParameter())",
      "    opts.append(isinstance(out, ParameterSelection))",
      # write the three lists (arguments, defaults, options) to a csv-file
      paste0("  with open('", tmp_dir, "\\output.csv'", ", 'wb') as f:"),
      "    writer = csv.writer(f)",
      "    writer.writerow(['params', 'vals', 'opts'])",
      "    writer.writerows(izip(params, vals, opts))",
      "    f.close()",
      ""
    )
  # each py_cmd element should go on its own line
  py_cmd <- paste(py_cmd, collapse = "\n")
  # harmonize slashes
  py_cmd <- gsub("\\\\", "/", py_cmd)
  py_cmd <- gsub("//", "/", py_cmd)
  # save the Python script
  cat(py_cmd, file = "py_cmd.py")

  # build the batch/shell command to run the Python script
  if (Sys.info()["sysname"] == "Windows") {
    cmd <- c(cmds$cmd, "python py_cmd.py")
    # filename
    f_name <- "batch_cmd.cmd"
    batch_call <- f_name
  } else {
    cmd <- c(cmds$cmd, "/usr/bin/python py_cmd.py")
    # filename
    f_name <- "batch_cmd.sh"
    batch_call <- "sh batch_cmd.sh"
  }
  # put each element on its own line
  cmd <- paste(cmd, collapse = "\n")
  # save the batch file to the temporary location
  cat(cmd, file = f_name)
  # run Python via the command line
  system(batch_call, intern = TRUE)
  
  # retrieve the Python output
  tmp <- read.csv(paste0(tmp_dir, "/output.csv"), header = TRUE, 
                  stringsAsFactors = FALSE)
  # If a wrong algorithm (-> alg is None) name was provided, stop the function
  if (tmp$params[1] == "Specified algorithm does not exist!") {
    stop("Algorithm '", alg, "' does not exist")
  }
  
  # If desired, select the first option if a function argument has several
  # options to choose from
  if (options) {
    tmp[tmp$opts == "True", "vals"] <- "0"
  }
  
  # convert the dataframe into a list
  args <- as.list(tmp$vals)
  names(args) <- tmp$params
  
  # clean up after yourself
  unlink(paste0(tmp_dir, "/output.csv"))
  
  # return your result
  args
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
#'   more information, refer to \code{\link{set_env}}.
#' @details This workhorse function calls QGIS via Python (QGIS API) using the
#'   command line. Specifically, it calls \code{processing.runalg}.
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
#' params <- list(INPUT = "random_squares.shp",
#'                OUTPUT = "output.shp")
#' run_qgis(algorithm = "saga:addcoordinatestopoints",
#'          params = params,
#'          qgis_env = my_env)
#' }
run_qgis <- function(algorithm = NULL, params = list(),
                     qgis_env = set_env()) {
  nm <- names(params)
  val <- as.character(unlist(params))
  # adjust param paths
  # val <- gsub("//|\\\\", "/", val)  # really necessary???
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
               intern = ifelse(Sys.info()["sysname"] == "Darwin", FALSE, TRUE))
  
}
