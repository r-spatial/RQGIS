text = None
s = ''
for provider in Processing.algs.values():
  sortedlist = sorted(provider.values(), key=lambda alg: alg.name)
  for alg in sortedlist:
    if text is None or text.lower() in alg.name.lower():
      s += alg.name.ljust(50, '-') + '--->' + alg.commandLineName() + '\n'