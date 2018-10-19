#' @title Random points.
#'
#' @name random_points
#' @description An [sf] (EPSG:32717) object
#'   with 100 randomly sampled points (stratified by altitude). For more
#'   details, please refer to Muenchow et al. (2013).
#'
#' @format An [sf] object with 100 rows and 3 variables:
#' \describe{
#'   \item{id}{Plot ID.}
#'   \item{spri}{Number of vascular plant species per plot (species richness).}
#'   \item{geometry}{Simple feature point geometry.}
#'   }
#'
#'
#' @references
#' Muenchow, J., Bräuning, A., Rodríguez, E.F. & von Wehrden, H. (2013):
#' Predictive mapping of species richness and plant species' distributions of a
#' Peruvian fog oasis along an altitudinal gradient. Biotropica 45, 5, 557-566,
#' doi: 10.1111/btp.12049.
NULL

#' @title Digital elevation model (DEM) of the Mongón study area.
#' @name dem
#'
#' @description A [raster::raster()] object (EPSG:32717) representing
#'   altitude (ASTER GDEM, LP DAAC 2012).  For more details, please refer to
#'   Muenchow et al. (2013).
#'
#' @format A [raster::raster()] with 117 rows and 117 columns:
#' \describe{
#'   \item{dem}{Altitude in m asl.}
#' }
#' @importFrom raster raster
#' @references
#' Muenchow, J., Bräuning, A., Rodríguez, E.F. & von Wehrden, H. (2013):
#' Predictive mapping of species richness and plant species' distributions of a
#' Peruvian fog oasis along an altitudinal gradient. Biotropica 45, 5, 557-566,
#' doi: 10.1111/btp.12049.
#'
#' LP DAAC (2012): Land Processes Distributed Active Archive Center, located
#' at the U.S. Geological Survey (USGS) Earth Resources Observation
#' and Science (EROS) Center. Available at: https://lpdaac.usgs.gov/
#' (last accessed 25 January 2012).
NULL

#' @title Normalized difference vegetation index for the Mongón study area.
#' @name ndvi
#'
#' @description NDVI [raster::raster()] (EPSG:32717) computed from a
#'   Landsat scene (path 9, row 67, acquisition date: 09/22/2000; USGS 2013).
#'   For more details, please refer to Muenchow et al. (2013).
#'
#' @format A [raster::raster()] with 117 rows and 117 columns:
#' \describe{
#'   \item{ndvi}{Normalized difference vegetation index.}
#' }
#' @importFrom raster raster
#' @references
#' Muenchow, J., Bräuning, A., Rodríguez, E.F. & von Wehrden, H. (2013):
#' Predictive mapping of species richness and plant species' distributions of a
#' Peruvian fog oasis along an altitudinal gradient. Biotropica 45, 5, 557-566,
#' doi: 10.1111/btp.12049.
#'
#' USGS (2013): U.S. Geological Survey. Earth Explorer. Available at:
#' http://earthexplorer.usgs.gov/ (last accessed 1 March 2013).
NULL

#' @title Mask of the study area
#'
#' @name study_area
#' @description An [sf] (EPSG:32717) object of geometry class polygon.
#'
#' @format An [sf] object with 1 row and 2 variables:
#' \describe{
#'   \item{name}{Name.}
#'   \item{geometry}{Simple feature polygon geometry.}
#'   }
#'
#' @references
#' Muenchow, J., Bräuning, A., Rodríguez, E.F. & von Wehrden, H. (2013):
#' Predictive mapping of species richness and plant species' distributions of a
#' Peruvian fog oasis along an altitudinal gradient. Biotropica 45, 5, 557-566,
#' doi: 10.1111/btp.12049.
NULL

#' @title Community matrix of the Mt. Mongón
#'
#' @name comm
#' @description A community matrix with species as columns and sites as rows.
#'   The rownames correspond to the id which can be also found in
#'   [random_points]. Please note that in fact 100 sites have been
#'   visited but in 16 of them no species could be found (see again
#'   [random_points]).
#' @format An dataframe with 84 sites (rows) and 69 species (columns). Species
#'   presence is given in percentage points.
#'
#' @references Muenchow, J., Bräuning, A., Rodríguez, E.F. & von Wehrden, H.
#' (2013): Predictive mapping of species richness and plant species'
#' distributions of a Peruvian fog oasis along an altitudinal gradient.
#' Biotropica 45, 5, 557-566, doi: 10.1111/btp.12049.
NULL