import  std/math
import  nufpcmp

# limit cases with 'NaN'
doAssert:  not NaN.eq(NaN) and not NaN.neq(NaN) and not NaN.eq(Inf) and not NaN.neq(-Inf)
doAssert:  not Inf.eq(NaN) and not (-Inf).eq(NaN) and not NaN.eq(1.0)
doAssert:  not (-1.0).eq(NaN) and not (-Inf).eq(NaN) and not NaN.eq(1.0)
doAssertRaises(AssertionDefect):  discard NaN.fpCmp(NaN)
doAssertRaises(AssertionDefect):  discard Inf.fpCmp(NaN)
doAssertRaises(AssertionDefect):  discard (-1.0).fpCmp(NaN)

# limit cases with 'Inf'
doAssert:  Inf.eq(Inf) and Inf.gt(-Inf) and Inf.gt(1.0)
doAssert:  (-Inf).eq(-Inf) and (-Inf).lt(Inf) and (-Inf).lt(1.0)
