#' @importFrom tools file_ext file_path_sans_ext
#' @importFrom reticulate py_run_string py_run_file py_capture_output r_to_py
#' @importFrom reticulate py_config use_python py_unicode
NULL


.RQGIS_cache <- new.env(FALSE, parent = globalenv())

# .onLoad = function(libname, pkgname) {
#   assign("settings", Sys.getenv(), envir = .RQGIS_cache)
#   if (Sys.info()["sysname"] == "Windows") {
#     # run Windows setup
#     setup_win(qgis_env = qgis_env)
#
#     # Ok, basically, we added a few new paths (especially under Windows) but
#     # that's about it, we don't have to change that back. Only under Windows we
#     # start with a clean, i.e. empty PATH, and delete everything what was in
#     # there before, so maybe we should at least add the old PATH to our newly
#     # created one?
#     # There might be problems when importing later on Python modules...
#     reset_path(as.list(get("settings", envir = .RQGIS_cache)))
#   } else if (Sys.info()["sysname"] == "Linux" | Sys.info()["sysname"] == "FreeBSD") {
#     setup_linux(qgis_env = qgis_env)
#   } else if (Sys.info()["sysname"] == "Darwin") {
#     setup_mac(qgis_env = qgis_env)
#   }
# }

# .onUnload <- function(libname, pkgname) {
#   do.call(Sys.setenv, as.list(get("settings", envir = .RQGIS_cache)))
#   }
