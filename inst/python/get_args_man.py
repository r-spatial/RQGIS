vals = []
params = []
opts = list()
if alg is None:
  sys.exit('Specified algorithm does not exist!')
alg = alg.getCopy()
for param in alg.parameters:
  params.append(param.name)
  vals.append(param.getValueAsCommandLineParameter())
  opts.append(isinstance(param, ParameterSelection))
for out in alg.outputs:
  params.append(out.name)
  vals.append(out.getValueAsCommandLineParameter())
  opts.append(isinstance(out, ParameterSelection))

args = [params, vals, opts]

