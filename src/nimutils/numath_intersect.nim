##[
================
numath_intersect
================
This module responds to a very specific need that we sometimes encounter:
making the intersection between a sequence and a real bounded interval 
(the prefix `nu` stands for `Nim utils`).
]##


# ==============================     Imports     ============================= #

import  std/[algorithm, sequtils, sugar]


# ===========================     Enumerations     =========================== #

type
  BoundedRealInterval* = enum
    ## All bounded intervals of the set of real numbers are of one of the above forms.
    BoundedClosed,  ## Intervals of the form `[a;b]`
    BoundedOpen,  ## Intervals of the form `(a;b)`
    BoundedRightOpen,  ## Intervals of the form `[a;b)` (same as 'BoundedLeftClosed')
    BoundedLeftClosed,  ## Intervals of the form `[a;b)` (same as 'BoundedRightOpen')
    BoundedLeftOpen,  ## Intervals of the form `(a;b]` (same as 'BoundedRightClosed')
    BoundedRightClosed,  ## Intervals of the form `(a;b]` (same as 'BoundedLeftOpen')

  UnboundedRealInterval* = enum
    ## All unbounded intervals of the set of real numbers are of one of the above forms.
    UnboundedLeftOpen,  ## Intervals of the form `(a;->)`
    UnboundedRightOpen,  ## Intervals of the form `(<-;a)`
    UnboundedLeftClosed,  ## Intervals of the form `[a;->)`
    UnboundedRightClosed,  ## Intervals of the form `(<-;a]`

  RealInterval* = BoundedRealInterval | UnboundedRealInterval
    ## All intervals of the set of real numbers are of one of the above forms.


# ===============================     Procs     ============================== #

proc  intersection[T](oa: openArray[T]; lowerBound, upperBound: T; cmp: (T, T) -> int): seq[T] =
  #[
  Returns the intersection between the `oa` openArray and 
  the bounded closed interval `[lowerBound; upperBound]`.
  
  **Assertions:**
    - `oa` is not empty
    - The elements of the `oa` openArray are in strictly ascending order.
    - `lowerBound` and `upperBound` are in ascending order.
  ]#
  # assertions
  assert:  oa.len != 0
  assert:  isSorted(oa, cmp = (x,y:T) => (if cmp(x,y) == -1: -1 else: 1))
  assert:  lowerBound.cmp(upperBound) <= 0
  # limit cases:
  # 1. max(oa) < lowerBound  =>  result = @[]
  # 2. max(oa) = lowerBound  =>  result = @[max(oa)]
  # 3. upperBound < min(oa)  =>  result = @[]
  # 4. upperBound = min(oa)  =>  result = @[min(oa)]
  # 5. upperBound = lowerBound  =>
  #      result = @[lowerBound]  if lowerBound in oa
  #      result = @[]            if lowerBound notin oa
  let
    oaMin = oa[0]
    oaMax = oa[^1]
  if oaMax.cmp(lowerBound) < 0:  return @[]
  if oaMax.cmp(lowerBound) == 0:  return @[oaMax]
  if upperBound.cmp(oaMin) < 0:  return @[]
  if upperBound.cmp(oaMin) == 0:  return @[oaMin]
  if lowerBound.cmp(upperBound) == 0:
    let idx = oa.binarySearch(lowerBound, cmp)
    if idx == -1:  return @[]
    else:  return @[lowerBound]
  # other assertions
  let lowerIdx = oa.lowerBound(lowerBound, cmp)
  let upperIdx = oa.upperBound(upperBound, cmp)
  doAssert: lowerIdx < oa.len  # lowerIdx == oa.len  <=>  limit case No 1
  doAssert: upperIdx > 0  # upperIdx == 0  <=>  limit cases Nos 3 and 4
  # limit case No 6:
  # oa[i] < lowerBound < upperBound < oa[i+1]  (=> oa[lowerIdx] = oa[i+1])  =>  result = @[]
  if oa[lowerIdx].cmp(upperBound) > 0:  return @[]
  # all other cases:  
  #   oa[0] < .. < oa[i] < lowerBound < oa[i+1] < .. < oa[j] < upperBound < oa[j+1] <  .. < oa[^1]
  return oa[lowerIdx..upperIdx-1].toSeq  # oa[i+1..j]


proc  intersection*[T](oa: openArray[T]; lowerBound, upperBound: T; interval: BoundedRealInterval; 
                       cmp: (T, T) -> int; isSortedUnique = true): seq[T] =
  ##[
  Returns the intersection between the `oa` `openArray` (a finite set of
  values) and the bounded interval `(lowerBound; upperBound)` (an infinite
  and continuous set of values) which can actually be open, closed, or 
  half-open depending on the value of the `interval` parameter.

  **Notes:**
    - `isSortedUnique` is a technical parameter:
      - when `true`, the `oa` parameter is used as is;  
      - when `false`, the `oa` parameter is sorted using
        the `cmp` procedure and duplicates are removed.
    - When `lowerBound` and `upperBound` are not in ascending order,
      they are reversed before use.
  ]##
  
  runnableExamples:
    # intersection with an empty sequence is an empty sequence
    let emptySeq = newSeq[float64](0)
    doAssert:  emptySeq.intersection(1.0, 2.0, BoundedClosed, cmp[float64]) == @[]

    # most of the possible scenarios
    let oa = [1.0, 2.0, 3.0, 4.0]
    # bounded closed intervals
    doAssert:  oa.intersection(0.0, 0.5, BoundedClosed, cmp[float64]) == @[]
    doAssert:  oa.intersection(1.0, 0.0, BoundedClosed, cmp[float64]) == @[1.0]
    doAssert:  oa.intersection(0.0, 3.5, BoundedClosed, cmp[float64]) == @[1.0, 2.0, 3.0]
    doAssert:  oa.intersection(3.0, 0.0, BoundedClosed, cmp[float64]) == @[1.0, 2.0, 3.0]
    doAssert:  oa.intersection(4.0, 0.0, BoundedClosed, cmp[float64]) == oa
    doAssert:  oa.intersection(4.5, 0.0, BoundedClosed, cmp[float64]) == oa
    doAssert:  oa.intersection(1.0, 1.0, BoundedClosed, cmp[float64]) == @[1.0]
    doAssert:  oa.intersection(1.0, 1.5, BoundedClosed, cmp[float64]) == @[1.0]
    doAssert:  oa.intersection(1.0, 2.0, BoundedClosed, cmp[float64]) == @[1.0, 2.0]
    doAssert:  oa.intersection(1.0, 3.5, BoundedClosed, cmp[float64]) == @[1.0, 2.0, 3.0]
    doAssert:  oa.intersection(1.0, 4.5, BoundedClosed, cmp[float64]) == oa
    doAssert:  oa.intersection(2.5, 2.75, BoundedClosed, cmp[float64]) == @[]
    doAssert:  oa.intersection(2.5, 3.0, BoundedClosed, cmp[float64]) == @[3.0]
    doAssert:  oa.intersection(2.5, 4.0, BoundedClosed, cmp[float64]) == @[3.0, 4.0]
    doAssert:  oa.intersection(2.5, 4.5, BoundedClosed, cmp[float64]) == @[3.0, 4.0]
    doAssert:  oa.intersection(4.0, 4.0, BoundedClosed, cmp[float64]) == @[4.0]
    doAssert:  oa.intersection(4.0, 4.5, BoundedClosed, cmp[float64]) == @[4.0]
    # bounded open intervals
    doAssert:  oa.intersection(0.0, 4.0, BoundedOpen, cmp[float64]) == @[1.0, 2.0, 3.0]
    doAssert:  oa.intersection(1.0, 1.0, BoundedOpen, cmp[float64]) == @[]
    doAssert:  oa.intersection(1.0, 2.0, BoundedOpen, cmp[float64]) == @[]
    doAssert:  oa.intersection(2.5, 3.5, BoundedOpen, cmp[float64]) == @[3.0]
    doAssert:  oa.intersection(4.0, 4.5, BoundedOpen, cmp[float64]) == @[]
    doAssert:  oa.intersection(4.5, 5.5, BoundedOpen, cmp[float64]) == @[]
    # half-open intervals
    doAssert:  oa.intersection(0.0, 1.0, BoundedLeftOpen, cmp[float64]) == @[1.0]
    doAssert:  oa.intersection(0.0, 1.0, BoundedRightOpen, cmp[float64]) == @[]
    doAssert:  oa.intersection(0.0, 3.0, BoundedRightOpen, cmp[float64]) == @[1.0, 2.0]
    doAssert:  oa.intersection(1.0, 2.0, BoundedRightOpen, cmp[float64]) == @[1.0]
    doAssert:  oa.intersection(1.0, 2.0, BoundedLeftOpen, cmp[float64]) == @[2.0]
    doAssert:  oa.intersection(1.0, 3.0, BoundedLeftOpen, cmp[float64]) == @[2.0, 3.0]
    doAssert:  oa.intersection(2.5, 3.0, BoundedLeftOpen, cmp[float64]) == @[3.0]
    doAssert:  oa.intersection(2.5, 3.0, BoundedRightOpen, cmp[float64]) == @[]

  # empty input => empty result
  if oa.len == 0:  return @[]
  # 'lowerBound' and 'upperBound' are listed in ascending order
  let (lowBound, uppBound) = 
    if lowerBound.cmp(upperBound) == 1:  (upperBound, lowerBound) 
    else:  (lowerBound, upperBound)
  # if necessary, the 'oa' parameter is sorted
  let oaSorted = 
    if isSortedUnique:  oa.toSeq
    else:  oa.sorted(cmp).deduplicate(isSorted = true)
  # intersection with the bounded closed interval [lowBound; uppBound]   
  var tmpResult = oaSorted.intersection(lowBound, uppBound, cmp)
  # if 'tmpResult' is empty, there is no point in continuing
  if tmpResult.len == 0:  return tmpResult
  case interval
    of BoundedClosed:
      result = tmpResult
    of BoundedRightOpen, BoundedLeftClosed:
      if cmp(tmpResult[^1], uppBound) == 0:  tmpResult.delete(high(tmpResult))
      result = tmpResult
    of BoundedLeftOpen, BoundedRightClosed:
      if cmp(tmpResult[0], lowBound) == 0:  tmpResult.delete(0)
      result = tmpResult
    of BoundedOpen:
      if cmp(tmpResult[^1], uppBound) == 0:  tmpResult.delete(high(tmpResult))
      if tmpResult.len == 0:  return tmpResult  # if 'tmpResult' is empty, there is no point in continuing 
      if cmp(tmpResult[0], lowBound) == 0:  tmpResult.delete(0)
      result = tmpResult
