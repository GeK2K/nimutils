##[
============
nuexceptions
============
Some useful tools related to exception handling 
(the prefix `nu` stands for `Nim utils`).

Motivation
==========

Nim is a multi-paradigm programming language that does not favor                                                     
any paradigm over others. As a result, there is no `Exception` 
specifically dedicated to the problems that can be encountered 
in object-oriented programming.

Abstract
========

We provide a new `Exception` type (namely `MethodWoImplemDefect`) which is 
intended to be raised (via the `raise newMethodWoImplemDefect()` statement) 
if a method is called when it has not been implemented. 

Use case
========
]##

runnableExamples:

  # An inheritable type with a base method (namely 
  # 'methodToImplem') that subtypes should implement.
  type InheritableType {.inheritable.} = ref object

  method methodToImplem(x: InheritableType) {.base.} = 
    raise newMethodWoImplemDefect()
  
  # Subtype without an override of base method 'methodToImplem'. Due 
  # to lack of this override, the 'x.methodToImplem' statement below
  # compiles but raises a 'MethodWoImplemDefect' object at runtime.
  type SubTypeA = ref object of InheritableType
  let x = new(SubTypeA)
  doAssertRaises(MethodWoImplemDefect): x.methodToImplem

  # Subtype with an override of base method 'methodToImplem'.
  type SubTypeB = ref object of InheritableType
  method methodToImplem(x: SubTypeB) = discard  
  let y = new(SubTypeB)
  y.methodToImplem  # no Exception is raised
  
##[
This approach has the advantage of simplicity but the disadvantage of detecting 
unimplemented methods only during program execution. In some cases *the* 
`concept <https://nim-lang.org/docs/manual_experimental.html#concepts>`_  
*feature is probably a good native alternative*.
]##


# =======================     MethodWoImplemDefect     ======================= #

type
  MethodWoImplemDefect* = object of Defect
    ## This exception is intended to be raised at runtime if 
    ## a method is called when it has not been implemented.

const methodWoImplemMsg* = "Method without implementation override."

func  newMethodWoImplemDefect*(msg = methodWoImplemMsg): ref MethodWoImplemDefect =
  newException(MethodWoImplemDefect, msg)