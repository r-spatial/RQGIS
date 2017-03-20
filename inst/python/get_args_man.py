import processing
from processing.core.Processing import Processing
from processing.core.parameters import ParameterSelection
from itertools import izip
import csv
alg = Processing.getAlgorithm('saga:slopeaspectcurvature')
vals = []
params = []
opts = list()
alg = alg.getCopy()
for param in alg.parameters:
  params.append(param.name)
  vals.append(param.getValueAsCommandLineParameter())
  opts.append(isinstance(param, ParameterSelection))
for out in alg.outputs:
  params.append(out.name)
  vals.append(out.getValueAsCommandLineParameter())
  opts.append(isinstance(out, ParameterSelection))

