# RQGIS 0.1.0.9000

* RQGIS now also does testing using the `testthat`-package
* bug fix: when constructing the cmd-command (in `run_qgis`), we need to avoid "double" shell quotes. This happened e.g., with `grass7:r.viewshed`.
* bug fix: when determining the GRASS REGION PARAMETER in `run_qgis`. To extract the extent of a spatial object `ogrInfo` needs the layer name without the file extension. To do that we now use the `file_path_sans_ext` of the `tools` package instead of a simple `gsub`-command.
* `run_qgis` stops if the user specifies one of the interactive QGIS Select-by operations.
* `run_qgis` now stops if the output shapefile created by QGIS is empty.
* Removing a bug from `run_qgis`. Function argument `load_output` now checks if the QGIS output was really created before trying to load it.
* `run_qgis`-message: Use qgis:creategrid instead of qgis:vectorgrid.
* vignette update (MacOSX and homebrew installation)
* Fine-tuning of the documentation files
* Deleting redundancies in functions `build_cmds`, `check_apps` and `execute_cmds`
* Removing empty string from `find_algorithms` output
* Added a `NEWS.md` file to track changes to the package.




