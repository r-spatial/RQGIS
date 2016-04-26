#' @title Read command skeletons
#' @description This function simply reads prefabricated Python and batch
#'   commands.
#' @param qgis_env Environment containing all the paths to run the QGIS API. For
#'   more information, refer to \link{\code{set_env}}.
#' @author Jannes Muenchow
read_cmds <- function(qgis_env = set_env()) {
  
    if (Sys.info()["sysname"] == "Windows") {
        # load raw Python file
        py_cmd <- system.file("python", "raw_py.py", package = "RQGIS")
        py_cmd <- readLines(py_cmd)
        # change paths if necessary
        if (qgis_env$root != "C:/OSGeo4W64") {
            py_cmd[11] <- paste0("QgsApplication.setPrefixPath('",
                                 qgis_env$root, "\\apps\\qgis'", ", True)")
            py_cmd[15] <- paste0("sys.path.append(r'", qgis_env$root,
                                 "\\apps\\qgis\\python\\plugins')")
        }
        
        # load windows batch command
        cmd <- system.file("win", "init.cmd", package = "RQGIS")
        cmd <- readLines(cmd)
        # check osgewo4w_root
        
        # check if GRASS path is correct and which version is available on the system
        vers <- dir(paste0(qgis_env, "\\apps\\grass"))
        # check if grass-7 is available
        ind <- grepl("grass-7..*\\d$", vers)
        if (any(grepl("grass-7..*[0-9]$", vers))) {
            cmd <- gsub("grass-\\d.\\d.\\d", vers[ind], cmd)
            
        } else {
            # if not, simply use the older version
            cmd <- gsub("grass-\\d.\\d.\\d", vers[1], cmd)
        }
        
        # return your result
        list("cmd" = cmd,
             "py_cmd" = py_cmd)
    }
    
    
    if (Sys.info()["sysname"] == "Darwin") {
        # load raw Python file
        py_cmd <- system.file("python", "raw_py.py", package = "RQGIS")
        py_cmd <- readLines(py_cmd)
        # change paths if necessary
        if (qgis_env$root != "C:/OSGeo4W64") {
            py_cmd[11] <- paste0("QgsApplication.setPrefixPath('",
                                 "/Applications/QGIS.app'", ", True)")
            py_cmd[15] <- paste0("sys.path.append('", "/Applications/QGIS.app/Contents/Resources/python/plugins')")
        }
        
        # load windows batch command
        cmd <- system.file("unix", "init.sh", package = "RQGIS")
        cmd <- readLines(cmd)
        
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
                         env = qgis_env,
                         intern = FALSE) {
 if (is.null(qgis_env)) {
     qgis_env = set_env()
 } else(env = qgis_env)
    
    if (Sys.info()["sysname"] == "Windows") {
        cwd <- getwd()
        on.exit(setwd(cwd))
        tmp_dir <- tempdir()
        setwd(tmp_dir)
        # load raw Python file (has to be called from the command line)
        cmds <- read_cmds(qgis_env = qgis_env)
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
    
    if (Sys.info()["sysname"] == "Darwin") {
        cwd <- getwd()
        on.exit(setwd(cwd))
        tmp_dir <- tempdir()
        setwd(tmp_dir)
        # load raw Python file (has to be called from the command line)
        cmds <- read_cmds(qgis_env = qgis_env)
        py_cmd <- c(cmds$py_cmd,
                    paste0(processing_name, "(", params, ")",
                           "\n"))
        py_cmd <- paste(py_cmd, collapse = "\n")
        cat(py_cmd, file = "py_cmd.py")
        
        # write batch command
        cmd <- c(cmds$cmd, "/usr/bin/python py_cmd.py")
        cmd <- paste(cmd, collapse = "\n")
        cat(cmd, file = "batch_cmd.sh")
        system("sh batch_cmd.sh", intern = T)
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
        
        cmd <- paste0("find ", path_apps, " -type d \\( ! -name '*.*' -a -name 'qgis' \\)")
        path <- system(cmd, intern = TRUE)
        out <- lapply(apps, function(app) {
            cmd <- paste0("find ", path_apps, " -type d \\( ! -name '*.*' -a -name ", "'", app,"' ", "\\)")
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




