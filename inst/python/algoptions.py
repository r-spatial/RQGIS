alg = Processing.getAlgorithm(name)
if alg is not None:
  s = ''
  for param in alg.parameters:
    if isinstance(param, ParameterSelection):
      s += param.name + '(' + param.description + ')\n'
      i = 0
      for option in param.options:
        s += '\t' + unicode(i) + ' - ' + unicode(option) + '\n'
        i += 1
else:
  s = 'Algorithm not found'
