library("devtools")
Sys.setenv(NOT_CRAN = FALSE)
revdep_check()
# when installing revdep automatically uses the source version 
# Installing 1 package: reticulate
# 
# There is a binary version available (and will be installed) but the source version is
# later:
#   binary source
# reticulate    0.7    0.8

# However, we needed reticulate 0.8, since revdep installs reticulate 0.7 this
# leads to a cryptic error message:
# Installing RQGIS 1.0.0 to C:\Users\pi37pat\AppData\Local\Temp\RtmpWCQm5q\revdepa9034fc70b8
# Error: Command failed (1)

# To solve the issue, I had to manually install the reticulate source file
install.packages("reticulate", lib = file.path(tempdir(), "R-lib"))
revdep_check_resume()
# readRDS("revdep/checks.rds")
revdep_check_save_summary()
revdep_check_print_problems()
