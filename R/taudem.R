# What to do next:
# 1. SilentProgress
# 2. function documentation run_taudem, set_env
# 3. taudem so far only works for Windows
# 4. save loglines to temp and load it into R to report what went wrong/good
# 5. test run_taudem with other taudem functions

# qgis_env <- set_env("C:/OSGeo4W64/",
#                     mpiexec_path = "C:\\Program Files\\Microsoft MPI\\Bin\\mpiexec",
#                     taudem_path = "C:\\Program Files\\TauDEM\\TauDEM5Exe")
# params <- get_args_man("taudem:d8flowdirections", options = TRUE,
#                        qgis_env = qgis_env)
# params$`-fel` <- "C:/Users/pi37pat/Desktop/dem.tif"
# params$`-p` <- "D:/out_1.tif"
# params$`-sd8` <- "D:/out_2.tif"
# run_qgis(alg = "taudem:d8flowdirections", params = params, qgis_env = qgis_env)

run_taudem <- 
  function(alg, params,
           qgis_env) {
  
  if (is.na(qgis_env$mpiexec_path) | is.na(qgis_env$taudem_path)) {
    stop("Please specify the full path to mpiexec and to Taudem on your 
         computer")
  }  
    
  # work in the temporary folder
  cwd <- getwd()
  on.exit(setwd(cwd))
  tmp_dir <- tempdir()
  setwd(tmp_dir)
  
  # build the raw scripts
  cmds <- build_cmds(qgis_env)
  
  # extend the python command by libraries & Co.
  py_cmd <- 
    c(cmds$py_cmd,
      "from qgis.PyQt.QtCore import QCoreApplication",
      "from qgis.PyQt.QtGui import QIcon",
      "from processing.core.GeoAlgorithm import GeoAlgorithm",
      "from processing.core.ProcessingLog import ProcessingLog",
      "from processing.core.ProcessingConfig import ProcessingConfig",
      paste("from processing.core.GeoAlgorithmExecutionException", 
            "import GeoAlgorithmExecutionException"),
      "from processing.core.parameters import ParameterRaster",
      "from processing.core.parameters import ParameterVector",
      "from processing.core.parameters import ParameterBoolean",
      "from processing.core.parameters import ParameterString",
      "from processing.core.parameters import ParameterNumber",
      "from processing.core.parameters import getParameterFromString",
      "from processing.core.outputs import getOutputFromString",
      "from processing.core.Processing import Processing",
      "from processing.algs.taudem.TauDEMUtils import TauDEMUtils",
      # Please note that SilentProgress is in core since QGIS > 2.14
      # from processing.core.SilentProgress import SilentProgress
      "from processing.gui.SilentProgress import SilentProgress",
      "import subprocess",
      "",
      "progress = SilentProgress()",
      # retrieve the algorithm
      paste0("alg = Processing.getAlgorithm('", alg,"')"),
      # retrieve function input and output arguments
      "inp = []",
      "out = []",
      "for param in alg.parameters:",
      "  inp.append(param.name)",
      "for param in alg.outputs:",
      "  out.append(param.name)"
    )
# now specify arguments
keys <- paste0(paste("'", names(params), "'", sep = ""), collapse = ", ")
vals <- paste0(paste("'", unlist(params), "'", sep = ""), collapse = ", ")
# and futher extend the python command
py_cmd <- 
  c(py_cmd,
    paste0("d = dict(zip([", keys, "], ", "[", vals, "]))"),
    "for keys, vals in d.items():",
    "  if keys in inp:",
    "    alg.setParameterValue(keys, vals)",
    "  if keys in out:",
    "    alg.setOutputValue(keys, vals)",
    # and now we replichate TauDEMAlgorith.processAlgorithm
    "commands = []",
    # commands.append(os.path.join(TauDEMUtils.mpiexecPath(), 'mpiexec'))
    paste0("commands.append('", qgis_env$mpiexec_path, "')"),
    paste0("processNum = int(ProcessingConfig.getSetting(", 
           "TauDEMUtils.MPI_PROCESSES))"),
    "if processNum <= 0:",
    "  raise GeoAlgorithmExecutionException(self.tr('Wrong number of MPI processes used. Please set '
                                                    'correct number before running TauDEM algorithms.'))",
    "commands.append('-n')",
    "commands.append(unicode(processNum))",
    # commands.append(os.path.join(TauDEMUtils.taudemPath(), alg.cmdName))
    paste0("commands.append(os.path.join('", qgis_env$taudem_path, "', ",
           "alg.cmdName))"),
    "for param in alg.parameters:",
    "  if param.value is None or param.value == '':",
    "    continue",
    "  if isinstance(param, ParameterNumber):",
    "    commands.append(param.name)",
    "    commands.append(unicode(param.value))",
    "  if isinstance(param, (ParameterRaster, ParameterVector)):",
    "    commands.append(param.name)",
    "    commands.append(param.value)",
    "  elif isinstance(param, ParameterBoolean):",
    "    if not param.value:",
    "      commands.append(param.name)",
    "  elif isinstance(param, ParameterString):",
    "    commands.append(param.name)",
    "    commands.append(unicode(param.value))",
    "",
    "for out in alg.outputs:",
    "  commands.append(out.name)",
    "  commands.append(out.value)",
    
    # This doesn't work
    # alg.execute(progress)
    # But this works:
    # TauDEMUtils.executeTauDEM(commands, progress)
    # this works as well (manual way, and maybe better since we retrive the 
    # loglines) 
    # here, we replicate TauDEMUtils.executeTauDEM
    
    "command = commands",
    "loglines = []",
    "loglines.append(TauDEMUtils.tr('TauDEM execution console output'))",
    paste0("fused_command = ''.join(['", 
           shQuote("%s")," ' % c for c in command])"),
    "progress.setInfo(TauDEMUtils.tr('TauDEM command:'))",
    # seems to work, though it is not exactly the same...
    # progress.setCommand(fused_command.replace('" "', ' ').strip('"'))
    paste0("progress.setCommand(fused_command.replace('", 
           shQuote(" "), "', ' ').strip('", shQuote(""), "'))"),
    "proc = subprocess.Popen(",
    "  fused_command,",
    "  shell=True,",
    "  stdout=subprocess.PIPE,",
    "  stdin=open(os.devnull),",
    "  stderr=subprocess.STDOUT,",
    "  universal_newlines=True,",
    ").stdout",
    "",
    "for line in iter(proc.readline, ''):",
    "  progress.setConsoleInfo(line)",
    "  loglines.append(line)"
    )
# each py_cmd element should go on its own line
py_cmd <- paste(py_cmd, collapse = "\n")
# harmonize slashes
py_cmd <- gsub("\\\\", "/", py_cmd)
py_cmd <- gsub("//", "/", py_cmd)
# save the Python script
cat(py_cmd, file = "py_cmd.py")          
# build the batch/shell command to run the Python script
if (Sys.info()["sysname"] == "Windows") {
  cmd <- c(cmds$cmd, "python py_cmd.py")
  # filename
  f_name <- "batch_cmd.cmd"
  batch_call <- f_name
} else {
  cmd <- c(cmds$cmd, "/usr/bin/python py_cmd.py")
  # filename
  f_name <- "batch_cmd.sh"
  batch_call <- "sh batch_cmd.sh"
}


# put each element on its own line
cmd <- paste(cmd, collapse = "\n")
# save the batch file to the temporary location
cat(cmd, file = f_name)
# run Python via the command line
system(batch_call, intern = TRUE)
}
