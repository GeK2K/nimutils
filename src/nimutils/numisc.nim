##[
======
numisc
======
Grouping certain tools into coherent modules would result in a 
large number of very small modules. In these cases, we prefer to 
group these tools here. The prefix `nu` stands for `Nim utils`.
]##


import  std/[parsecfg, strformat]


type RecordType* = (tuple or object)


template  notSupposedToGetHere*(): untyped =
  ## A shortcut for `doAssert(false, "The algorithm did not work as expected.")`.
  doAssert(false, "The algorithm did not work as expected.")


proc  readAndCheckCfgParamValue*(config: Config; section, paramName: string; defaultValue = ""): string =
  ## See also the `getSectionValue 
  ## <https://nim-lang.org/docs/parsecfg.html#getSectionValue%2CConfig%2Cstring%2Cstring%2Cstring>`_
  ## proc of the `parsecfg` module.
  result = config.getSectionValue(section = section, key = paramName, defaultVal = defaultValue)
  if result == defaultValue:
    raise newException(ValueError, fmt"No value found for config. parameter '{paramName}'.")
