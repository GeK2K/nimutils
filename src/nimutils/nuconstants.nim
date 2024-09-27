##[
===========
nuconstants
===========
Some useful constants and enumerations (the prefix `nu` stands for `Nim utils`).
]##

# =============================     Constants     ============================ #

# ===========================     Enumerations     =========================== #

type
  YesNo* = enum
    ynYes = "yes"
    ynNo = "no" 

  FailureSuccess* = enum
    fsFailure = "failure"
    fsSuccess = "success" 

  OnOffSwitch* = enum
    swOn = "on"
    swOff = "off"