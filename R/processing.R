#' @title Retrieve the environment settings to run QGIS from within R
#' @description \code{set_env} tries to find all the paths necessary to run QGIS
#'   from within R.
#' @param root Root path to the QGIS-installation. If you do not specify 
#'   function parameter \code{root}, the function looks for \code{qgis.bat} on 
#'   your C: drive under Windows. If you are on a Mac, it looks for 
#'   \code{QGIS.app} under "Applications" and "/usr/local/Cellar/". On Linux,
#'   \code{set_env} assumes that your root path is "/usr".
#' @return The function returns a list containing all the path necessary to run 
#'   QGIS from within R. This is the root path, the QGIS prefix path and the 
#'   path to the Python plugins.
#' @examples 
#' # Letting set_env look for the QGIS installation might take a while depending
#' # on how full your C: drive is (Windows)
#' set_env()
#' # It is much faster (0 sec) to explicitly state the root path to the QGIS 
#' # installation on your machine
#' \dontrun{
#' set_env("C:/OSGEO4~1")  # Windows example
#' }
#' 
#' @export
#' @author Jannes Muenchow
set_env <- function(root = NULL) {

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
    root <- gsub("/|//", "\\\\", root)
    # make sure that the root path does not end with some sort of slash
    root <- gsub("/$|//$|\\$|\\\\$", "", root)
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
  c(qgis_env, check_apps(root = root))
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
#' \dontrun{
#' # list all available QGIS algorithms on your system
#' algs <- find_algorithms()
#' algs[1:15]
#' # just find all native, i.e. QGIS-algorithms
#' grep("qgis:", algs, value = TRUE)
#' # find a function which adds coordinates
#' find_algorithms(search_term = "add")
#' }

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
#' @param alg Name of the function whose parameters are being
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
#' \dontrun{
#' # find a function which adds coordinates
#' find_algorithms(search_term = "add")
#' # find function arguments of saga:addcoordinatestopoints
#' get_usage(alg = "saga:addcoordinatestopoints")
#' }

get_usage <- function(alg = NULL,
                      qgis_env = set_env(),
                      intern = FALSE) {
  
  execute_cmds(processing_name = "processing.alghelp",
               params = shQuote(alg),
               qgis_env = qgis_env,
               intern = intern)
}

#' @title Get options of parameters for a specific GIS option
#' @description \code{get_options} lists all available parameter options for
#'   the required GIS function.
#' @param alg Name of the GIS function for which options should be
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
#' \dontrun{
#' get_options(alg = "saga:slopeaspectcurvature")
#' }
#' @export
get_options <- function(alg = NULL,
                        qgis_env = set_env(),
                        intern = FALSE) {
  if (is.null(alg)) {
    stop("Please specify an algorithm!")
  }
  
  execute_cmds(processing_name = "processing.algoptions",
               params = shQuote(alg),
               qgis_env = qgis_env,
               intern = intern)
}

#' @title Access the QGIS/GRASS online help for a specific function
#' @description \code{open_help} opens the online help for a specific function. 
#'   This is the help you also encounter in the QGIS GUI. Please note that you 
#'   are referred to the GRASS documentation in the case of GRASS algorithms.
#' @param alg The name of the algorithm for which you wish to retrieve arguments
#'   and default values.
#' @param qgis_env Environment containing all the paths to run the QGIS API. For
#'   more information, refer to \code{\link{set_env}}.
#' @details Bar a few exceptions \code{open_help} works for all QGIS, GRASS and
#'   SAGA geoalgorithms. The online help of other third-party providers,
#'   however, has not been tested so far.
#' @return The function opens your default web browser and displays the help for
#'   the specified algorithm.
#' @note Please note that \code{open_help} requires a \strong{working Internet 
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
open_help <- function(alg = NULL, qgis_env = set_env()) {
  
  if (is.null(alg)) {
    stop("Please specify an algorithm!")
  }
  
  if (grepl("grass", alg)) {
    open_grass_help(alg)
  } else {
    algName <- alg
    
    # set the paths
    cwd <- getwd()
    on.exit(setwd(cwd))
    tmp_dir <- tempdir()
    setwd(tmp_dir)
    
    cmds <- build_cmds(qgis_env = qgis_env)
    py_cmd <- 
      c(cmds$py_cmd,
        "from processing.gui.Help2Html import *",
        "from processing.tools.help import createAlgorithmHelp",
        "import webbrowser",
        "import re",
        # from processing.tools.help import *
        paste0("alg = Processing.getAlgorithm('", algName, "')"), 
        # copied from baseHelpForAlgorithm in processing\tools\help.py
        # find the provider (qgis, saga, grass, etc.)
        "provider = alg.provider.getName().lower()",
        # to which group does the algorithm belong (e.g., vector_table_tools)
        "groupName = alg.group.lower()",
        # format the groupName in the QGIS way
        "groupName = groupName.replace('[', '').replace(']', '').replace(' - ', '_')",
        "groupName = groupName.replace(' ', '_')",
        "if provider == 'saga':",
        "  alg2 = alg.getCopy()",
        "  groupName = alg2.undecoratedGroup",
        "  groupName = groupName.replace('ta_', 'terrain_analysis_')",
        "  groupName = groupName.replace('statistics_kriging', 'kriging')",
        "  groupName = re.sub('^statistics_.*', 'geostatistics', groupName)",
        "  groupName = re.sub('visualisation', 'visualization', groupName)",
        "  groupName = re.sub('_preprocessor', '_hydrology', groupName)",
        "  groupName = groupName.replace('sim_', 'simulation_')",
        # retrieve the command line name (worked for 2.8...)
        # "cmdLineName = alg.commandLineName()",
        # "algName = cmdLineName[cmdLineName.find(':') + 1:].lower()",
        # for 2.14 we cannot use the algorithm name 
        # (now you have to test all SAGA and QGIS functions again...)
        "algName = alg.name.lower().replace(' ', '-')",
        
        # just use valid characters
        "validChars = ('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRS' +
        'TUVWXYZ0123456789_')",
        "safeGroupName = ''.join(c for c in groupName if c in validChars)",
        "validChars = validChars + '-'",
        "safeAlgName = ''.join(c for c in algName if c in validChars)",
        # which QGIS version are we using
        "version = '.'.join(QGis.QGIS_VERSION.split('.')[0:2])",
        # build the html to the help file
        "url = ('https:///docs.qgis.org/%s/en/docs/user_manual/' +
        'processing_algs/%s/%s.html#%s') % (version, provider,
        safeGroupName, safeAlgName)",
        
        
        # suppress error messages raised by the browser, e.g.,
        # console.error: CustomizableUI: 
        # TypeError: aNode.previousSibling is null -- 
        #  resource://app/modules/CustomizableUI.jsm:4294
        # Solution was found here:
        # paste0("http://stackoverflow.com/questions/2323080/",
        #        "how-can-i-disable-the-webbrowser-message-in-python")
        "savout = os.dup(1)",
        "os.close(1)",
        "os.open(os.devnull, os.O_RDWR)",
        "try:",
        "  webbrowser.open(url)",
        "finally:",
        "  os.dup2(savout, 1)"
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
  }
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
#' \dontrun{
#' get_args(alg = "qgis:addfieldtoattributestable")
#' }
get_args <- function(alg = NULL, qgis_env = set_env()) {
  
  if (is.null(alg)) {
    stop("Please specify an algorithm!")
  }
  
  # get the usage of a function
  tmp <- get_usage(alg = alg, qgis_env = qgis_env, intern = TRUE)
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
#' @param alg The name of the algorithm for which you wish to retrieve arguments
#'   and default values.
#' @param options Sometimes you can choose between various options for a 
#'   function argument. Setting option to \code{TRUE} will automatically assume 
#'   you wish to use the first option (default: \code{FALSE}).
#' @param qgis_env Environment containing all the paths to run the QGIS API. For
#'   more information, refer to \code{\link{set_env}}.
#' @details \code{get_args_man} basically mimics the behavior of the QGIS GUI. 
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
#' @note Please note that some default values can only be set after the user's
#'   input. For instance, the GRASS region extent will be determined
#'   automatically in \code{\link{run_qgis}} if left blank.
#' @export
#' @author Jannes Muenchow
#' @examples 
#' \dontrun{
#' get_args_man(alg = "qgis:addfieldtoattributestable")
#' # and using the option argument
#' get_args_man(alg = "qgis:addfieldtoattributestable", options = TRUE)
#' }
get_args_man <- function(alg = NULL, options = FALSE, qgis_env = set_env()) {

  if (is.null(alg)) {
    stop("Please specify an algorithm!")
  }
  # find out if it's necessary to obtain default values for
  # GRASS_REGION_CELLSIZE_PARAMETER, etc.

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
  tmp <- utils::read.csv(file.path(tmp_dir, "output.csv"), header = TRUE, 
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
  names(args) <- trimws(tmp$params)
  
  # sometime None, True or False might be 'shellquoted'
  # we have to take care of this
  # well, maybe not necessary:
  # http://stackoverflow.com/questions/28204507/remove-backslashes-from-character-string
  # args <- lapply(args, function(x) as.character(noquote(x)))
  # clean up after yourself
  unlink(file.path(tmp_dir, "output.csv"))
  # return your result
  args
}

#' @title Interface to QGIS commands
#' @description \code{run_qgis} calls QGIS algorithms from within R while 
#'   passing the corresponding function arguments.
#' @param alg Name of the GIS function to be used (see 
#'   \code{\link{find_algorithms}}).
#' @param params A list of geoalgorithm function arguments that should be used 
#'   in conjunction with the selected (Q)GIS function (see 
#'   \code{\link{get_args_man}}). Please make sure that you provide all function
#'   arguments in the correct order. To make sure this is the case, it is 
#'   recommended to use the convenience function \code{\link{get_args_man}}.
#' @param check_params If \code{TRUE} (default), it will be checked if all 
#'   geoalgorithm function arguments were provided in the correct order.
#' @param load_output Character vector containing paths to (an) output file(s) 
#'   to load the QGIS output directly into R (optional). If \code{load_output} 
#'   consists of more than one element, a list will be returned. See the example
#'   section for more details.
#' @param qgis_env Environment containing all the paths to run the QGIS API. For
#'   more information, refer to \code{\link{set_env}}.
#' @details This workhorse function calls QGIS via Python (QGIS API) using the 
#'   command line. Specifically, it calls \code{processing.runalg}.
#' @return If not otherwiese specified, the function saves the QGIS generated 
#'   output files in a temporary folder. Optionally, function parameter 
#'   \code{load_output} loads spatial QGIS output (vector and raster data) into
#'   R.
#' @note Please note that you can also pass spatial R objects as input 
#'   parameters where suitable (e.g., input layer, input raster). Supported 
#'   formats are \code{\link[sp]{SpatialPointsDataFrame}}, 
#'   \code{\link[sp]{SpatialLinesDataFrame}}, 
#'   \code{\link[sp]{SpatialPolygonsDataFrame}} and 
#'   \code{\link[raster]{raster}}. See the example section for more details.
#'   
#'   GRASS users do not have to specify manually the GRASS region extent 
#'   (function argument GRASS_REGION_PARAMETER). If "None", \code{run_qgis} will
#'   automatically retrieve the region extent based on the input layers.
#' @author Jannes Muenchow, QGIS developer team
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
#' # Here I specify a SpatialPointsDataFrame as input, but you could also
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
                     load_output = NULL,
                     qgis_env = set_env()) {
  
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
                  paste(setdiff(names(test), names(params)), collapse = ", ")),
             stop("Function argument(s) ", 
                  paste(setdiff(names(params), names(test)), collapse = ", "),
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
      # return your result
      file.path(tmp_dir, paste0(names(params)[[i]], ".shp"))
    } else if (tmp == "RasterLayer") {
      fname <- file.path(tmp_dir, paste0(names(params)[[i]], ".asc"))
      raster::writeRaster(params[[i]], filename = fname, format = "ascii", 
                          prj = TRUE, overwrite = TRUE)
      # return your result
      fname
    } else {
      params[[i]]
    }
  })
  
  # set the bbox in the case of GRASS functions if it hasn't already been
  # provided 
  # (if there are more of these 3rd-party based specifics, put them in a new
  # function)
  if ("GRASS_REGION_PARAMETER" %in% names(params) && 
      grepl("None", params$GRASS_REGION_PARAMETER)) {
    # dismiss the last argument since it frequently corresponds to the output
    # if the output was created before using another CRS, the function might
    # crash
    ext <- params[-length(params)]
    # run through the arguments and check if we can extract a bbox
    ext <- lapply(ext, function(x) {
      
      # determine bbox in the case of a vector layer
      tmp <- try(expr = 
                   rgdal::ogrInfo(dsn = x, 
                                  layer = gsub("[.].*", "",
                                               basename(x)))$extent,
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
  
  nm <- names(params)
  val <- as.character(unlist(params))
  # shellquote algorithm name
  start <- shQuote(alg)
  # True, False and None should not be put among parentheses!!
  ind <- !grepl("True|False|None", val)
  # shellquote paths and numeric input (the latter is not necessary but doen't
  # harm either)
  val[ind] <- shQuote(val[ind])
  # build the Python command
  args <- paste(val, collapse = ", ")
  args <- paste0(paste(start, args, sep = ", "))
  # run QGIS command
  execute_cmds(processing_name = "processing.runalg",
               params = args,
               qgis_env = qgis_env,
               intern = ifelse(Sys.info()["sysname"] == "Darwin", FALSE, TRUE))
  # load output
  if (!is.null(load_output)) {
    ls_1 <- lapply(load_output, function(x) {
      fname <- ifelse(dirname(x) == ".", 
                      file.path(tmp_dir, x),
                      x)
      test <- try(expr = 
                    rgdal::readOGR(dsn = dirname(fname),
                                   layer = gsub("\\..*", "", basename(fname)),
                                   verbose = FALSE),
                  silent = TRUE
      )
      if (inherits(test, "try-error")) {
        raster::raster(fname)
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


