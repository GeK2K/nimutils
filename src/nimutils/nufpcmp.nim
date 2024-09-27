##[
=======
nufpcmp
=======
Floating point comparisons (the prefix `nu` stands for `Nim utils`).

Motivation
==========

Floating point comparisons are a recurring need. The problem 
is much more difficult than it seems. Several solutions exist 
but none is suitable for all possible situations. It's up to 
each individual to find the solution best suited to his or 
her needs.

Abstract
========

For the test of equality of two floating point numbers 
we have retained the algorithm which has been discussed 
`here <https://stackoverflow.com/questions/4915462/how-should-i-do-floating-point-comparison>`_.
]##


# ==============================     Imports     ============================= #

import  std/[fenv, math]
  

# ====================     Floating point comparisons     ==================== #

func  eq*[T: SomeFloat](x, y: T; eps = epsilon(T), mpv = minimumPositiveValue(T)): bool =
  ## Tests if `x` is `equal to` `y` (returns `false` if `x.isNaN or y.isNaN`).
  runnableExamples:
    import std/math
    doAssert: PI.eq(3.141592653589793)  # 15 decimal places
    doAssert: not PI.eq(3.14159265358979)  # 14 decimal places
    doAssert: PI.eq[:float64](3.14159265358979, eps=1e-15)  # 14 decimal places
    doAssert: Inf.eq(Inf)
    doAssert: not NaN.eq(NaN)
  # limit cases: 'NaN' and 'infinity'
  if x.isNaN or y.isNaN:  return false
  elif x == y:  return true
  let xClass = classify(x)
  let yClass = classify(y)
  let infClass = {fcInf, fcNegInf}
  if xClass in infClass or yClass in infClass:  return false
  # assertions
  doAssert: eps >= epsilon(T) and mpv >= minimumPositiveValue(T) and eps < 1.0
  # algorithm
  let diff = abs(x-y);
  let norm = min(abs(x) + abs(y), maximumPositiveValue(T))
  result = diff < eps * max(mpv, norm)


func  fpCmp*[T: SomeFloat](x, y: T; eps = epsilon(T), mpv = minimumPositiveValue(T)): int =
  ##[ 
  Floating point comparison.

  **Assertions:**
    - `doAssert <https://nim-lang.org/docs/assertions.html#doAssert.t%2Cuntyped%2Cstring>`_:  
      `not x.isNaN and not y.isNaN`
  ]##
  runnableExamples:
    import std/math
    doAssert: PI.fpCmp(3.141592653589793) == 0
    doAssert: PI.fpCmp(1.0) == 1
    doAssert: (1.0).fpCmp(PI) == -1
    doAssert: Inf.fpCmp(Inf) == 0
    doAssertRaises(AssertionDefect): discard PI.fpCmp(NaN)
  doAssert:  not x.isNaN  and  not y.isNaN
  if x.eq(y, eps, mpv): 0
  elif x > y: 1
  else: -1


func  neq*[T: SomeFloat](x, y: T; eps = epsilon(T), mpv = minimumPositiveValue(T)): bool =
  ## Tests if `x` is `not equal to` `y` (returns `false` if `x.isNaN or y.isNaN`).
  runnableExamples:
    import std/math
    doAssert: PI.neq(3.0)
    doAssert: Inf.neq(PI)
    doAssert: not NaN.neq(NaN)
  if x.isNaN or y.isNaN:  return false
  fpCmp(x=x, y=y, eps=eps, mpv=mpv) != 0


func  lt*[T: SomeFloat](x, y: T; eps = epsilon(T), mpv = minimumPositiveValue(T)): bool =
  ## Tests if `x` is `less than` `y` (returns `false` if `x.isNaN or y.isNaN`).
  runnableExamples:
    import std/math
    doAssert: PI.lt(4.0)
    doAssert: not NaN.lt(Inf)
  if x.isNaN or y.isNaN:  return false
  fpCmp(x=x, y=y, eps=eps, mpv=mpv) < 0


func  leq*[T: SomeFloat](x, y: T; eps = epsilon(T), mpv = minimumPositiveValue(T)): bool =
  ## Tests if `x` is `less than or equal to` `y` (returns `false` if `x.isNaN or y.isNaN`).
  runnableExamples:
    import std/math
    doAssert: PI.leq(PI)
    doAssert: not PI.leq(1.0)
    doAssert: not NaN.leq(Inf)
  if x.isNaN or y.isNaN:  return false
  fpCmp(x=x, y=y, eps=eps, mpv=mpv) <= 0


func  gt*[T: SomeFloat](x, y: T; eps = epsilon(T), mpv = minimumPositiveValue(T)): bool =
  ## Tests if `x` is `greater than` `y` (returns `false` if `x.isNaN or y.isNaN`).
  runnableExamples:
    import std/math
    doAssert: (4.0).gt(PI)
    doAssert: not NaN.gt(-Inf)
  if x.isNaN or y.isNaN:  return false
  fpCmp(x=x, y=y, eps=eps, mpv=mpv) > 0


func  geq*[T: SomeFloat](x, y: T; eps = epsilon(T), mpv = minimumPositiveValue(T)): bool =
  ## Tests if `x` is `greater than or equal to` `y` (returns `false` if `x.isNaN or y.isNaN`).
  runnableExamples:
    import std/math
    doAssert: PI.geq(PI)
    doAssert: not (1.0).geq(PI)
    doAssert: not Inf.geq(NaN)
  if x.isNaN or y.isNaN:  return false
  fpCmp(x=x, y=y, eps=eps, mpv=mpv) >= 0