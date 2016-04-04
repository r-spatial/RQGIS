#' @title Looking for OSGEO on your system
#' @description \code{find_root} looks for OSGeo on your system under C:,
#'   C:/Program Files and C:/Program Files (x86). So far, this function is only
#'   available for Windows.
#' @param root_name Name of the folder where QGIS, SAGA, GRASS, etc. is
#'   installed.
#' @author Jannes Muenchow
#' @examples
#' find_root()
find_root <- function(root_name = "OSGeo4W") {
  osgeo4w_root <- NULL

  if (Sys.info()["sysname"] == "Windows") {
    if (any(grepl(root_name, dir("C:/")))) {
      osgeo4w_root <- paste0("C:\\",
                             grep(root_name, dir("C:/"), value = TRUE)[1])
    } else if (any(grepl(root_name, dir("C:/Program Files")))) {
      osgeo4w_root <-
        paste0("C:\\Program Files\\",
               grep(root_name, dir("C:/Program Files"), value = TRUE)[1])
    } else if (any(grepl(root_name, dir("C:/Program Files (x86)")))) {
      osgeo4w_root <-
        paste0("C:\\Program Files (x86)\\",
               grep(root_name, dir("C:/Program Files (x86)"), value = TRUE)[1])
    }
  }
  if (is.null(osgeo4w_root)) {
    stop("Sorry, I could not find ", root_name, " on your system!
         Please provide the path to OSGeo4W yourself!")
  }
  osgeo4w_root
}

#' @title Read command skeletons
#' @description This function simply reads prefabricated Python and batch
#'   commands.
#' @param osgeo4w_root Path to the OSGeo folder or QGIS folder
#' @author Jannes Muenchow
read_cmds <- function(osgeo4w_root = find_root()) {

  # load raw Python file
  py_cmd <- system.file("python", "raw_py.py", package = "RQGIS")
  py_cmd <- readLines(py_cmd)
  # change paths if necessary
  if (osgeo4w_root != "C:\\OSGeo4W64") {
    py_cmd[11] <- paste0("QgsApplication.setPrefixPath('",
                         osgeo4w_root, "\\apps\\qgis'", "True)")
    py_cmd[15] <- paste0("sys.path.append(r'", osgeo4w_root,
                         "\\apps\\qgis\\python\\plugins')")
  }

  # load windows batch command
  cmd <- system.file("win", "init.cmd", package = "RQGIS")
  cmd <- readLines(cmd)
  # check osgewo4w_root

  # check if GRASS path is correct and which version is available on the system
  vers <- dir(paste0(osgeo4w_root, "\\apps\\grass"))
  if (length(vers) < 1) {
    stop("Please install at least one GRASS version under '../OSGeo4W/apps/'!")
  }
  # check if grass-7.0.3 is available
  if (!any(grepl("grass-7.0.3", vers))) {
    # if not, simply use the older version
    cmd <- gsub("grass.*\\d", vers[1], cmd)
  }

  # return your result
  list("cmd" = cmd,
       "py_cmd" = py_cmd)
}

#' @title Building and executing cmd and Python scripts
#' @description This helper function constructs the batch and Python scripts
#'   which are necessary to run QGIS from the command line.
#' @param processing_name Name of the function from the processing library that
#'   should be used.
#' @param params Parameter to be used with the processing function.
#' @param osgeo4w_root Path to the OSGeo4W installation on your system.
#' @param intern Logical which indicates whether to capture the output of the
#'   command as an \code{R} character vector (see also \code{\link[base]{system}}.
#' @author Jannes Muenchow
execute_cmds <- function(processing_name = "",
                         params = "",
                         osgeo4w_root = find_root(),
                         intern = FALSE) {
  cwd <- getwd()
  on.exit(setwd(cwd))
  tmp_dir <- tempdir()
  setwd(tmp_dir)
  # load raw Python file (has to be called from the command line)
  cmds <- read_cmds(osgeo4w_root = osgeo4w_root)
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
