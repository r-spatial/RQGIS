import os
from qgis.PyQt.QtCore import QCoreApplication
from qgis.PyQt.QtGui import QIcon

from processing.core.GeoAlgorithm import GeoAlgorithm
from processing.core.ProcessingLog import ProcessingLog
from processing.core.ProcessingConfig import ProcessingConfig
from processing.core.GeoAlgorithmExecutionException import GeoAlgorithmExecutionException

from processing.core.parameters import ParameterRaster
from processing.core.parameters import ParameterVector
from processing.core.parameters import ParameterBoolean
from processing.core.parameters import ParameterString
from processing.core.parameters import ParameterNumber
from processing.core.parameters import getParameterFromString
from processing.core.outputs import getOutputFromString
from processing.core.Processing import Processing

from processing.algs.taudem.TauDEMUtils import TauDEMUtils
from processing.gui.SilentProgess import SilentProgress
import subprocess

progress = SilentProgress()
alg = Processing.getAlgorithm('taudem:d8flowdirections')

# use the names of the params to set the values (in R!)
alg.setParameterValue("-fel", "C:/Users/pi37pat/Desktop/dem.tif")
alg.setOutputValue("-p", "D:/flow.tif")
alg.setOutputValue("-sd8", "D:/slope.tif")
# just to make sure everything went ok
for i in alg.parameters:
  print(i.value)

for i in alg.outputs:
  print(i.value)

# here, we replichate TauDEMAlgorith.processAlgorithm
commands = []

# commands.append(os.path.join(TauDEMUtils.mpiexecPath(), 'mpiexec'))
commands.append('C:\Program Files\Microsoft MPI\Bin\mpiexec')

processNum = int(ProcessingConfig.getSetting(TauDEMUtils.MPI_PROCESSES))
if processNum <= 0:
  raise GeoAlgorithmExecutionException(self.tr('Wrong number of MPI processes used. Please set '
                        'correct number before running TauDEM algorithms.'))

commands.append('-n')
commands.append(unicode(processNum))
# commands.append(os.path.join(TauDEMUtils.taudemPath(), alg.cmdName))
commands.append(os.path.join('C:\\Program Files\\TauDEM\\TauDEM5Exe\\', alg.cmdName))

for param in alg.parameters:
  if param.value is None or param.value == '':
    continue
  if isinstance(param, ParameterNumber):
    commands.append(param.name)
    commands.append(unicode(param.value))
  if isinstance(param, (ParameterRaster, ParameterVector)):
    commands.append(param.name)
    commands.append(param.value)
  elif isinstance(param, ParameterBoolean):
    if not param.value:
      commands.append(param.name)
  elif isinstance(param, ParameterString):
    commands.append(param.name)
    commands.append(unicode(param.value))

for out in alg.outputs:
  commands.append(out.name)
  commands.append(out.value)

# This doesn't work
# alg.execute(progress)

# But this works:
TauDEMUtils.executeTauDEM(commands, progress)

# this works as well (manual way, and maybe better since we retrive the 
# loglines) 
# here, we replicate TauDEMUtils.executeTauDEM

command = commands
loglines = []
loglines.append(TauDEMUtils.tr('TauDEM execution console output'))
fused_command = ''.join(['"%s" ' % c for c in command])
progress.setInfo(TauDEMUtils.tr('TauDEM command:'))
progress.setCommand(fused_command.replace('" "', ' ').strip('"'))
proc = subprocess.Popen(
  fused_command,
  shell=True,
  stdout=subprocess.PIPE,
  stdin=open(os.devnull),
  stderr=subprocess.STDOUT,
  universal_newlines=True,
  ).stdout

for line in iter(proc.readline, ''):
  progress.setConsoleInfo(line)
  loglines.append(line)

# ProcessingLog.addToLog(ProcessingLog.LOG_INFO, loglines)
