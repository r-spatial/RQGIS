# RQGIS 0.2.0.9000

* RQGIS now supports QGIS `osgeo4mac` homebrew installations. This is also the recommended installation way from now on as it does not cause irritating error messages like the Kyngchaos QGIS binary. 
* set_env now caches its output, so calling it again, will load the cached output

# RQGIS 0.2.0

## General 
* `build_cmds` now retrieves the working directory on the command line from where the script has been called (temporary folder), and makes it the working directory at the end of the batch script. This ensures that py_cmd.py can be found and executed (necessary since QGIS 2.18.2 since they somehow change the wd in one of their .bat-files) (#26, @eivindhammers).
* RQGIS now also does testing using the `testthat`-package (#20).
* `run_qgis` stops if the user specifies one of the interactive QGIS Select-by operations.
* `run_qgis` now stops if the output shapefile created by QGIS is empty.
* `run_qgis`-message: Use qgis:creategrid instead of qgis:vectorgrid.
* Fine-tuning of the documentation files
* Deleting redundancies in functions `build_cmds`, `check_apps` and `execute_cmds`
* Removing empty string from `find_algorithms` output
* Added a `NEWS.md` file to track changes to the package.
* vignette update (MacOSX and homebrew installation) (#14, @pat-s)

## Bug fixes
* bug fix: we replaced `findstr` in `set_env` by the more general `%SystemRoot%\\System32\\findstr`
* bug fix: when constructing the cmd-command (in `run_qgis`), we need to avoid "double" shell quotes. This happened e.g., with `grass7:r.viewshed`. Additionally, we made sure that None, True and False are not shellquoted.
* bug fix: when determining the GRASS REGION PARAMETER in `run_qgis`. To extract the extent of a spatial object `ogrInfo` needs the layer name without the file extension. To do that we now use the `file_path_sans_ext` of the `tools` package instead of a simple `gsub`-command. Previously, we simply returned everything in front of a colon. This caused problems with filenames such as gis.osm_roads_free_1.shp.
* bug fix: `run_qgis` function argument `load_output` now checks if the QGIS output was really created before trying to load it.
* bug fix: There was a problem when using QGIS/Grass on a MacOS. Deleting one bash statement (`paste0("export PATH='", qgis_env$root, "/Contents/MacOS/bin:$PATH'"))`) solved the problem.
* bug fix: `qgis_session_info` now also runs on MacOS (#34)

# RQGIS 0.1.0

Initial CRAN release