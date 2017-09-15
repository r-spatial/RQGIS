# RQGIS 1.0.1.9000

## Bugs
  * making sure that `setup_win()` works properly when the working directory is a server (commit  ccc1baa & 263a1cf)
  * solving winslash problems occurring in conjunction with Python, e.g., when in tempdir() directory names start with \\n or \\t (see commit 484e1d3 and issue #71)
  * making sure under Linux that the decimal operator is a colon not a comma with the help of Sys.setlocale (see commit f3c7e15)
  * making sure that default parameter values will not be overwritten by `RQGIS.check_args`  (commit 29fb26a and issue #79)


# RQGIS 1.0.1

## Features
  * merging python_funs.py and import_setup.py into python_funs.py
  * New function parameter `show_output_paths` in `run_qgis`. Setting it to `FALSE` suppresses the printing of the output file paths.
  * `random_points` is now an sf-object (required also some adjustments in run_qgis and our tests)
  * `run_qgis` doesn't print a space any longer if the Python message is empty
  * developing and improving test coverage
  * adding GDAL version to `qgis_session_info`
  * `load_output` now supports all GDAL-supported drivers. Of course, this depends on the system setup (#72).
  * deleting deprecated function arguments `show_msg` and `check_params` (`run_qgis`)
  * deleting deprecated function argument `ltr` (`set_env`)

# RQGIS 1.0.0

## General
  * RQGIS now uses [reticulate](https://github.com/rstudio/reticulate) to establish a tunnel to the QGIS Python API (instead of starting a new Python session each time a function is called; #59). Consequently, we had to rewrite all RQGIS functions. Internally, the Python session is established by calling the new function `open_app`. `open_app` in turn makes advantage of various new helper functions (`setup_win()`, `run_ini()`, `setup_linux()`, `setup_mac()`). Additionally, we put much of the Python code into inst/python. `import_setup` contains much of the necessary import statements to run QGIS from within R. `python_funs` contains the RQGIS class (#32) containing several methods to call from within R (`get_args_man()`, `open_help()`, `qgis_session_info()`, etc.).

## Features
  * The user can now specify QGIS geoalgorithm parameters as R named arguments using the ellipsis-argument `...` (#58).
  
  * We rewrote the `load_output`-argument of `run_qgis`. It is now a logical argument. If `TRUE`, `run_qgis()` will automatically load all the output layers explicitly specified by the user back into R (#60).
  
  * Extensive error-/misspecification checking. To do so, we now submit a Python-dictionary - containing all parameters and arguments - to `processing.runalg`. This also allows to check parameter names. Before the **args-argument simply converted our input in a list containing the arguments (but not the parameter names). Using the Python dictionary has the additional benefit that we no longer have to take care of the order in which the function parameters are specified. Besides, we now also make sure that the user can only specify available options. And if the user provides the verbal notation, `pass_args` internally converts this input in the corresponding number notation as required by the QGIS API (#64, @tim-salabim; #65).
  
  * RQGIS now supports simple features (`sf`; #43, @einvindhammers).
  
  * support for MultiParameterInput through two new helper functions `save_spatial_objects` and `get_grp` (https://gis.stackexchange.com/questions/240303/defining-grass-region-in-rqgis)
  
  * RQGIS now supports QGIS `osgeo4mac` homebrew installations. This is also the recommended installation way from now on as it does not cause irritating error messages like the Kyngchaos QGIS binary. 
  
  * `find_algorithms` now accepts regular expressions as argument for its `search_term` parameter
  
  * `set_env()` now caches its output, so calling it a second time, will load the cached output. 
  
  * Under Windows `set_env()` now first searches the most likely places to find a QGIS installation.
  
  * changing `set_env`'s parameter name from `ltr` to `dev`. When having multiple homebrew installations on mac (LTR and dev), the user can select which one to use with the `dev` argument in `set_env()`. Default uses the LTR version.
  
  * `qgis_session_info()` now warns Linux users that they might have to use a softlink when using grass7 in conjunction with QGIS (#52, @thengl)
  
  * changing the default for parameter `options` from `FALSE` to `TRUE` in `get_args_man`
  
  * `reset_paths` tries to restore the PATH environment variable, i.e. at least to make sure that all paths within PATH will still be available after having run `open_app`.

## Miscellaneous
  * Adding new tests.

# RQGIS 0.2.0

## General 
  * `build_cmds` now retrieves the working directory on the command line from where the script has been called (temporary folder), and makes it the working directory at the end of the batch script. This ensures that py_cmd.py can be found and executed (necessary since QGIS 2.18.2 since they somehow change the wd in one of their .bat-files) (#26, @eivindhammers).
  
  * RQGIS now also does testing using the `testthat`-package (#20).
  
  * `run_qgis` stops if the user specifies one of the interactive QGIS Select-by operations.
  
  * `run_qgis` now stops if the output shapefile created by QGIS is empty.
  
  * `run_qgis`-message: Use qgis:creategrid instead of qgis:vectorgrid.
  
  * Fine-tuning of the documentation files.
  
  * Deleting redundancies in functions `build_cmds`, `check_apps` and `execute_cmds`.
  
  * Removing empty string from `find_algorithms` output.
  
  * Added a `NEWS.md` file to track changes to the package.
  
  * vignette update (MacOSX and homebrew installation) (#14, @pat-s)

## Bug fixes
  * bug fix: we replaced `findstr` in `set_env` by the more general `%SystemRoot%\\System32\\findstr`.
  
  * bug fix: when constructing the cmd-command (in `run_qgis`), we need to avoid "double" shell quotes. This happened e.g., with `grass7:r.viewshed`. Additionally, we made sure that None, True and False are not shellquoted.
  
  * bug fix: when determining the GRASS REGION PARAMETER in `run_qgis`. To extract the extent of a spatial object `ogrInfo` needs the layer name without the file extension. To do that we now use the `file_path_sans_ext` of the `tools` package instead of a simple `gsub`-command. Previously, we simply returned everything in front of a colon. This caused problems with file names such as gis.osm_roads_free_1.shp.
  
  * bug fix: `run_qgis` function argument `load_output` now checks if the QGIS output was really created before trying to load it.
  
  * bug fix: There was a problem when using QGIS/Grass on a MacOS. Deleting one bash statement (`paste0("export PATH='", qgis_env$root, "/Contents/MacOS/bin:$PATH'"))`) solved the problem.
  
  * bug fix: `qgis_session_info` now also runs on MacOS (#34)

# RQGIS 0.1.0

  * Initial CRAN release