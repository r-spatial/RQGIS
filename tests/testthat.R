library("testthat")
library("RQGIS")

# manually env specification for appveyor
# not sure if this really helps!
if(Sys.getenv("R_ARCH") == "x64") {
  set_env("C:\\Program Files\\QGIS 2.18")
}

test_check("RQGIS")
