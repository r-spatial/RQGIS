devtools::load_all()
set_env(dev = TRUE)
open_app3()

alg = "grass7:r.slope.aspect"
params = pass_args(alg, elevation = "C:/Users/pi37pat/Desktop/dem.tif", 
                   slope = "C:/Users/pi37pat/Desktop/slope.tif")

alg = "qgis:aspect"
get_args_man(alg)
params = pass_args(alg, INPUT = "C:/Users/pi37pat/Desktop/dem.tif", OUTPUT = "aspect.tif")

# find_algorithms("voronoi")
alg = "qgis:voronoipolygons"
get_usage(alg)
get_args_man(alg)
py_run_string("from processing.tests import TestData")
p = py_run_string("p = TestData.points()")$p
params = pass_args(alg, INPUT = p)
params$OUTPUT = "memory:"


alg = "native:centroids"
get_args_man(alg)
params = pass_args(alg, INPUT = "C:/Users/pi37pat/Desktop/polys.shp", 
                   OUTPUT = "C:/Users/pi37pat/Desktop/points.shp")

file = "C:/Users/pi37pat/Desktop/dem.tif"
base_name = basename(file)
layer = "dem"
py_run_string(sprintf("%s = QgsRasterLayer('%s', '%s')",
                      layer, file, base_name))
py_run_string(sprintf("QgsProject.instance().addMapLayer(%s)",
                      layer))
# ok, hier scheint der Hund begraben zu liegen, warum kann ich das raster nicht einladen?
py_run_string(
  sprintf("if not %s.isValid(): raise Exception('Failed to load %s')", 
          layer, file))

file = 'r"C:/Users/pi37pat/Desktop/polys.shp"'
base_name = basename(file)
layer = "poly"
py_run_string(sprintf("%s = QgsVectorLayer('%s', '%s', 'ogr')",
                      layer, file, layer))
py_run_string(sprintf("QgsProject.instance().addMapLayer(%s)",
                      layer))
py_run_string(
  sprintf("if not %s.isValid(): raise Exception('Failed to load %s')", 
          layer, file))


# load input rasters and/or vectors into QGIS and register them
out <- py_run_string(sprintf("out = RQGIS.get_args_man('%s')", alg))$out
params[!out$output] <- qgis_load_geom(params = params[!out$output], 
                                      type_name = out$type_name[!out$output])


qgis_load_geom <- function(params, type_name) {
  lapply(seq_along(params), function(i) {
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
      # return layer
      layer
    } else if (type_name[i] == "raster" && params[[i]] != "None") {
      # import raster into QGIS and register it
      file = params[[i]]
      base_name = basename(file)
      layer = paste0("qgisrlayer45653", i)
      py_run_string(sprintf("%s = QgsRasterLayer('%s', '%s')",
                            layer, file, base_name))
      py_run_string(sprintf("QgsProject.instance().addMapLayer(%s)",
                            layer))
      py_run_string(
        sprintf("if not %s.isValid(): raise Exception('Failed to load %s')", 
                layer, file))
      # return layer
      layer
    } else if (type_name[i] == "multipleinput") {
      # ok, here we should do something
      params[[i]]
    } else {
      # just return the input
      params[[i]]
    }
  })
}


