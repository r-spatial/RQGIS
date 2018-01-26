qgis_load_geom <- function(params, type_name) {
  lapply(seq_along(params), function(i) {
    if (type_name[i] == "multipleinput") {
      # collect files
      files = unlist(strsplit(params[[i]], split = ";"))
      # raster or vector?
      type = vapply(files, vector_or_raster, FUN.VALUE = character(1))
      # run qgis_load_geom recursively
      res = qgis_load_geom(files, type_name = type) 
      # return your result as a Python list
      paste0("[", paste(res, collapse = ","), "]")
    } else {
      if (type_name[i] == "vector" && params[[i]] != "None") {
        # import raster into QGIS and register it
        file = params[[i]]
        # choose a name that is unlikely to be used
        layer = paste0("qgisvlayer45653", i)
        py_run_string(sprintf("%s = QgsVectorLayer('%s', '%s', 'ogr')",
                              layer, file, layer))
        py_run_string(sprintf("QgsMapLayerRegistry.instance().addMapLayer(%s)",
                              layer))
        py_run_string(
          sprintf("if not %s.isValid(): raise Exception('Failed to load %s')", 
                  layer, file))
        # return name of the QGIS vector layer as character string
        layer
      } else if (type_name[i] == "raster" && params[[i]] != "None") {
        # import raster into QGIS and register it
        file = params[[i]]
        base_name = basename(file)
        layer = paste0("qgisrlayer45653", i)
        py_run_string(sprintf("%s = QgsRasterLayer('%s', '%s')",
                              layer, file, base_name))
        py_run_string(sprintf("QgsMapLayerRegistry.instance().addMapLayer(%s)",
                              layer))
        py_run_string(
          sprintf("if not %s.isValid(): raise Exception('Failed to load %s')", 
                  layer, file))
        # return name of the QGIS raster layer as a character string
        layer
      } else {
        # if type_name is not "vector", "raster" or "mulipleinput" return the
        # original input
        params[[i]]
      }
    }
  })
}

# test it
library(raster)
r <- raster(ncol = 100, nrow = 100)
r1 <- crop(r, extent(-10, 11, -10, 11))
r2 <- crop(r, extent(0, 20, 0, 20))
r3 <- crop(r, extent(9, 30, 9, 30))
r1[] <- 1:ncell(r1)
r2[] <- 1:ncell(r2)
r3[] <- 1:ncell(r3)
alg <- "grass7:r.patch"
out <- py_run_string(sprintf("out = RQGIS.get_args_man('%s')", alg))$out
params <- get_args_man(alg)
params$input = list(r1, r2, r3)
params$output = file.path(tempdir(), "out.tif")
params = pass_args(alg = alg, params = params)
params[] = qgis_load_geom(params, out$type_name)
out = run_qgis(alg = alg, params = params, load_output = TRUE)
# now you have to also make sure to delete all registered layers in run_qgis

# write a function that finds out if a file stored on disk is a vector or a
# raster layer
# check shapefile, kml, gpkg
# check tif, asc, saga

vector_or_raster <- function(x) {
  stopifnot(file.exists(x))
  tmp <- try(
    expr = GDALinfo(x, returnStats = FALSE), silent = TRUE)
  if (!inherits(tmp, "try-error")) {
    return("raster")
  } else {
    tmp = try(
      expr <- {
        my_layer <- tools::file_path_sans_ext(basename(as.character(x)))
        ogrInfo(dsn = dirname(as.character(x)), layer = my_layer)
      }, silent = TRUE) 
  }
  if (!inherits(tmp, "try-error")) {
    "vector"
  } else {
    stop(x, " is not a valid spatial object.")
  }
}


# test
files = normalizePath(file.path(tempdir(),  paste0("r", 1:3, ".tif")), "/")
writeRaster(r1, files[1])
writeRaster(r2, files[2])
writeRaster(r3, files[3])
# import raster into QGIS and register it
py_run_string(sprintf("rlayer1 = QgsRasterLayer('%s', 'input')", files[1]))
py_run_string("QgsMapLayerRegistry.instance().addMapLayer(rlayer1)")
py_run_string(sprintf("rlayer2 = QgsRasterLayer('%s', 'input')", files[2]))
py_run_string("QgsMapLayerRegistry.instance().addMapLayer(rlayer2)")
py_run_string(sprintf("rlayer3 = QgsRasterLayer('%s', 'input')", files[3]))
py_run_string("QgsMapLayerRegistry.instance().addMapLayer(rlayer3)")

# run the processing
py_run_string(
  paste("processing.runalg('grass7:r.patch', {'input':[rlayer1,rlayer2,rlayer3]",
        "'-z':False",
        "'GRASS_REGION_PARAMETER':'-10.8,28.8,-10.8,30.6'",
        "'GRASS_REGION_CELLSIZE_PARAMETER':0.0",
        "'output':'out.tif'})",
        sep = ",")
)
# remove the input raster layer again
py_run_string("QgsMapLayerRegistry.instance().removeMapLayer(rlayer1.id())")
py_run_string("del rlayer")
