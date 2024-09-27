##[
=======
nudates
=======
Some useful tools when working with `dates` 
(the prefix `nu` stands for `Nim utils`).

Motivation
==========

In the standard library, dates can be handled with the `DateTime` type 
of the `times <https://nim-lang.org/docs/times.html>`_ module. As its 
name suggests, this type actually allows us to manage dates and times 
at the same time. But sometimes intra-day information (hours, minutes, 
seconds, etc.) is not important to us. For example 
`dt1 = dateTime(2025, mDec, 25, 2)` and `dt2 = dateTime(2025, mDec, 25, 4)` 
represent the same date (Christmas of the year 2025) while `dt1 == dt2` is 
`false` because the hours are not the same (resp. `2` and `4`). There are 
therefore situations for which it is appropriate to be able to compare two 
objects of type `DateTime` without taking into account intra-day information.

Abstract
========

We have defined new comparison operators (`==~`, `!==~`, `<<`, `<<==~`, 
`>>`, `>>==~`) which do the same job as the original comparison operators 
of the `times <https://nim-lang.org/docs/times.html>`_ module (resp. `==`, 
`!=`, `<`, `<=`, `>`, `>=`), but which do not take intraday information 
(hours, minutes, seconds, etc.) into account in their processing 
(the reader will find a justification of the notations adopted in the 
respective documentation of these operators).
]##

runnableExamples:

  let dt1 = dateTime(2011, mSep, 18, 2)  # 2011-09-18T:02:00:00
  let dt2 = dateTime(2011, mSep, 18, 5)  # 2011-09-18T:05:00:00
  let dt3 = dateTime(2011, mOct, 18, 1)  # 2011-10-18T:01:00:00

  doAssert:  dt1 == dt1  and  dt1 ==~ dt1
  doAssert:  dt1 != dt2  and  dt1 ==~ dt2
  doAssert:  dt1  < dt3  and  dt1 <<  dt3 
  doAssert:  dt3  > dt1  and  dt3 >>  dt1

##[
Are there any alternatives?
===========================

It is obviously possible to do without the tools made available
here but the alternatives that one might think of spontaneously
have certain obvious disadvantages. Let's give examples.
]##

runnableExamples:
  import times

  # the two `date` procedures below allow you to create `DateTime` 
  # objects with default values for intraday information
  proc date*(year: int; month: Month; monthday: MonthdayRange;
             zone: Timezone = local()): DateTime =
    dateTime(year, month, monthday, zone = zone)

  proc date*(dt: DateTime): DateTime =
    dateTime(dt.year, dt.month, dt.monthday, zone = dt.timeZone)

  # we can repeat some of the comparisons made in the previous section
  let dt1 = dateTime(2011, mSep, 18, 2)  # 2011-09-18T:02:00:00
  let dt2 = dateTime(2011, mSep, 18, 5)  # 2011-09-18T:05:00:00
  doAssert:  dt1 != dt2  and  dt1.date == dt2.date

  # We exclusively used the operators of the `times` module. 
  # But there is a price to pay: the number of additional objects 
  # to create through the `dt1.date` and `dt2.date` statements.
  #
  # To avoid the creation of additional objects through `date` procs, 
  # we can impose ourselves to systematically create `DateTime` objects 
  # without intra-day information. But this means depriving oneself 
  # de facto information that could be useful for other modules.

##[
The choices made in the `nudates` module should therefore be clear 
to the user. We are not changing anything about how we create `DateTime` 
objects with or without intraday information. But we provide the user 
with new comparison operators which do not take this intra-day information 
into account.

MonthMonthday type
==================

Sometimes we deal with special dates which do not vary from 
one year to the next. For example: New Year's Day, January 1st; 
Labour Day, May 1st; Christmas Day, December 25th. 
The `MonthMonthday` type allows special dates to be supported, 
and the operators defined in the previous section are also valid 
here (the year is not taken into account in the calculations).
]##

runnableExamples:

  let dt1 = newMonthMonthday(mMay, 1)  # Labour Day, May 1st
  let dt2 = dateTime(2020, mMay, 1, 3)  # 2020-05-01T:03:00:00
  let dt3 = dateTime(2020, mFeb, 18)  # 2020-02-18T:00:00:00
  let dt4 = dateTime(2011, mOct, 11)  # 2021-10-11T:00:00:00

  doAssert:  dt1 ==~ dt2  and  dt1 >> dt3  and  dt1 << dt4

##[
Other tools
===========

We encourage the user to browse the documentation to discover 
the few other features that exist. We will only mention here 
the following `proc`s: `diffDays <#diffDays,DateTime,DateTime>`_,
`nthWeekday <#nthWeekday,int,WeekDay,Month,int>`_ and
`gregorianEasterSundayMMDD <#gregorianEasterSundayMMDD,int>`_.
]##


# =========================     Imports / Exports     ======================== #

import  std/[math, options, times], ./[numisc]
export  options, times


# ===========================     MonthMonthday     ========================== #

type 
  MonthMonthday* = object of RootObj 
    ##[
    Special dates that do not change from year to year 
    can be represented using this type. For example:
      - New Year's Day, January 1st.
      - Labour Day, May 1st.
      - Christmas Day, December 25th.

  **See also:**
    - `newMonthMonthday <#newMonthMonthday%2CMonth%2CMonthdayRange%2COption[Timezone]>`_
    ]##
    month: Month = mJan
    monthday: MonthdayRange = 1.MonthdayRange
    zone: Option[TimeZone] = none(TimeZone)


proc  month*(mmd: MonthMonthday): Month {.inline.} = mmd.month
  ## Returns the `month` of the `mmd` object.

proc  monthday*(mmd: MonthMonthday): MonthdayRange {.inline.} = mmd.monthday
  ## Returns the `monthday` of the `mmd` object.

proc  timeZone*(mmd: MonthMonthday): Option[TimeZone] {.inline.} = mmd.zone
  ## Returns the `time zone` of the `mmd` object.


proc  newMonthMonthday*(month: Month = mJan, monthday: MonthdayRange = 1, 
                        zone: Option[TimeZone] = none(TimeZone)): MonthMonthday =
  ##[
  Returns a new object of type `MonthMonthday <#MonthMonthday>`_.

  **Assertions:**
    - `doAssert <https://nim-lang.org/docs/assertions.html#doAssert.t%2Cuntyped%2Cstring>`_:
    ```nim
    (month == mJan and monthday <= 31) or (month == mFeb and monthday <= 29) or 
    (month == mMar and monthday <= 31) or (month == mApr and monthday <= 30) or
    (month == mMay and monthday <= 31) or (month == mJun and monthday <= 30) or
    (month == mJul and monthday <= 31) or (month == mAug and monthday <= 31) or
    (month == mSep and monthday <= 30) or (month == mOct and monthday <= 31) or 
    (month == mNov and monthday <= 30) or (month == mDec and monthday <= 31)
    ```
  ]##
  doAssert:
    (month == mJan and monthday <= 31) or (month == mFeb and monthday <= 29) or 
    (month == mMar and monthday <= 31) or (month == mApr and monthday <= 30) or 
    (month == mMay and monthday <= 31) or (month == mJun and monthday <= 30) or 
    (month == mJul and monthday <= 31) or (month == mAug and monthday <= 31) or 
    (month == mSep and monthday <= 30) or (month == mOct and monthday <= 31) or 
    (month == mNov and monthday <= 30) or (month == mDec and monthday <= 31)
  result = MonthMonthday(month: month, monthday: monthday, zone: zone)


# =========================     Date comparisons     ========================= #

proc  cmpDate*(dt1, dt2: MonthMonthday): int = 
  ##[ 
  Compares `dt1` and `dt2`.

  **Assertions:**
    - `doAssert <https://nim-lang.org/docs/assertions.html#doAssert.t%2Cuntyped%2Cstring>`_:  
      `dt1.timeZone.isNone or dt2.timeZone.isNone or get(dt1.timeZone) == get(dt2.timeZone)`
  ]##

  runnableExamples:
    let dt1 = newMonthMonthday(mMay, 15.MonthdayRange)
    let dt2 = newMonthMonthday(mMay, 20.MonthdayRange)
    let dt3 = newMonthMonthday(mOct, 5.MonthdayRange)

    doAssert:  dt1.cmpDate(dt1) ==  0   
    doAssert:  dt1.cmpDate(dt2) == -1
    doAssert:  dt2.cmpDate(dt1) ==  1
    doAssert:  dt2.cmpDate(dt3) == -1
    doAssert:  dt3.cmpDate(dt2) ==  1

  doAssert:  
    dt1.zone.isNone or dt2.zone.isNone or get(dt1.zone) == get(dt2.zone)

  if  dt1.month.ord < dt2.month.ord:  return -1
  elif  dt1.month.ord > dt2.month.ord:  return 1
  # From now on:  dt1.month.ord == dt2.month.ord
  elif dt1.monthday < dt2.monthday:  return  -1
  elif dt1.monthday > dt2.monthday:  return 1
  # From now on:  dt1.monthday == dt2.monthday
  else:  return 0


proc  cmpDate*(dt1, dt2: DateTime): int = 
  ##[
  Compares `dt1` and `dt2` ignoring intraday information 
  (hours, minutes, seconds, etc.).

  **Assertions:**
    - `doAssert <https://nim-lang.org/docs/assertions.html#doAssert.t%2Cuntyped%2Cstring>`_:  
      `dt1.timeZone == dt2.timeZone`
  ]##

  runnableExamples:
    let dt1 = dateTime(2011, mSep, 18, 2)  # 2011-09-18T:02:00:00
    let dt2 = dateTime(2011, mSep, 18, 5)  # 2011-09-18T:05:00:00
    let dt3 = dateTime(2011, mOct, 18, 1)  # 2011-10-18T:01:00:00

    doAssert:  dt1 == dt1  and  dt1.cmpDate(dt1) ==  0
    doAssert:  dt1 != dt2  and  dt1.cmpDate(dt2) ==  0
    doAssert:  dt1  < dt3  and  dt1.cmpDate(dt3) == -1
    doAssert:  dt3  > dt1  and  dt3.cmpDate(dt1) ==  1

  doAssert: dt1.timeZone == dt2.timeZone

  if (dt1.year, dt1.month.ord, dt1.monthday) == (dt2.year, dt2.month.ord, dt2.monthday):  return 0
  elif dt1 < dt2:  return -1
  else:  return 1


proc  cmpDate*(dt1: DateTime, dt2: MonthMonthday): int {.inline.} = 
  ##[ 
  Compares `dt1` and `dt2` ignoring `dt1.year` and intraday
  information of `dt1` (hours, minutes, seconds, etc.).

  **See also:**
    - `cmpDate <#cmpDate,MonthMonthday,MonthMonthday>`_
  ]##

  runnableExamples:
    let dt1 = newMonthMonthday(mMay, 1)  # Labour Day, May 1st
    let dt2 = dateTime(2020, mMay, 1, 3)  # 2020-05-01T:03:00:00
    let dt3 = dateTime(2020, mFeb, 18)  # 2020-02-18T:00:00:00
    let dt4 = dateTime(2011, mOct, 11)  # 2021-10-11T:00:00:00

    doAssert:  dt1.cmpDate(dt2) == 0
    doAssert:  dt1.cmpDate(dt3) == 1
    doAssert:  dt1.cmpDate(dt4) == -1 

  newMonthMonthday(dt1.month, dt1.monthday, some(dt1.timeZone)).cmpDate(dt2)


template  cmpDate*(dt1: MonthMonthday, dt2: DateTime): untyped =
  ##[ 
  A shorcut for `-cmpDate(dt2, dt1)`.

  **See also:**
    - `cmpDate <#cmpDate,DateTime,MonthMonthday>`_
  ]##
  -cmpDate(dt2, dt1)


proc  cmpDateNoZero*(dt1: DateTime | MonthMonthday, dt2: DateTime | MonthMonthday): int = 
  ##[
  **Returns:**
    - `-1` if `dt1.cmpDate(dt2) == -1`
    - `1` else

  **Notes:**
    - By definition this `proc` can only take the values 1 or -1, 
      but never the value 0 as the `cmpDate` `proc` does. 
    - This `proc` can help differentiate sequences of increasing 
      dates from sequences of strictly increasing dates.

  **Assertions:**
  
  When provided time zones must be identical.

  **See also:**
    - `cmpDate <#cmpDate,DateTime,DateTime>`_
  ]##

  runnableExamples:
    let dt1 = dateTime(2011, mSep, 18, 2)  # 2011-09-18T:02:00:00
    let dt2 = dateTime(2011, mSep, 18, 5)  # 2011-09-18T:05:00:00
    let dt3 = dateTime(2011, mOct, 18, 1)  # 2011-10-18T:01:00:00

    doAssert:  dt1 == dt1  and  dt1.cmpDate(dt1) ==  0  and  dt1.cmpDateNoZero(dt1) ==  1
    doAssert:  dt1 != dt2  and  dt1.cmpDate(dt2) ==  0  and  dt1.cmpDateNoZero(dt2) ==  1
    doAssert:  dt1  < dt3  and  dt1.cmpDate(dt3) == -1  and  dt1.cmpDateNoZero(dt3) == -1
    doAssert:  dt3  > dt1  and  dt3.cmpDate(dt1) ==  1  and  dt3.cmpDateNoZero(dt1) ==  1


    import algorithm
    doAssert:  [dt2].isSorted(cmpDate)  # single element
    doAssert:  [dt2].isSorted(cmpDateNoZero)  # single element
    doAssert:  [dt2, dt2].isSorted(cmpDate)  # duplicates
    doassert:  not [dt2, dt2].isSorted(cmpDateNoZero)  # duplicates
    doAssert:  [dt2, dt3].isSorted(cmpDate)  # strictly ascending array
    doAssert:  [dt2, dt3].isSorted(cmpDateNoZero)  # strictly ascending array
    # [dt1, dt2, dt3] is an ascending array but not strictly ascending
    # since dt1.cmpDate(dt2) == 0
    doAssert:  [dt1, dt2, dt3].isSorted(cmpDate)
    doAssert:  not [dt1, dt2, dt3].isSorted(cmpDateNoZero)

  when dt1 is DateTime and dt2 is DateTime:
    doAssert:  
      dt1.timeZone == dt2.timeZone
  elif dt1 is DateTime and dt2 is MonthMonthday:
    doAssert:
      dt2.timeZone.isNone or dt1.timeZone == get(dt2.timeZone)
  elif dt2 is DateTime and dt1 is MonthMonthday:
    doAssert:
      dt1.timeZone.isNone or dt2.timeZone == get(dt1.timeZone)
  else:  # dt1 is MonthMonthday and dt2 is MonthMonthday
    doAssert:
      dt1.zone.isNone or dt2.zone.isNone or get(dt1.zone) == get(dt2.zone)

  result = if dt1.cmpDate(dt2) == -1: -1 else: 1


template  `==~`*(dt1: DateTime | MonthMonthday, dt2: DateTime | MonthMonthday): untyped = 
  ##[ 
  A shortcut for `dt1.cmpDate(dt2) == 0`, 
  meaning `dt1` is `equal to` `dt2`.

  There are therefore two ways of expressing 
  the relationship `dt1` is `equal to` `dt2`:
  `dt1.cmpDate(dt2) == 0` or `dt1 ==~ dt2`.

  **Notes:**
  
  Intra-day information (hours, minutes, seconds, etc.) are not taken
  into account. The equality mentioned here is therefore less demanding
  than that of the `DateTime` type (`dt1 == dt2` implies `dt1 ==~ dt2` 
  but the opposite is not true). We can speak of quasi-equality, hence 
  the notation chosen: `==~` rather than `==`.
  ]##
  dt1.cmpDate(dt2) == 0


template  `!==~`*(dt1: DateTime | MonthMonthday, dt2: DateTime | MonthMonthday): untyped = 
  ##[ 
  A shortcut for `dt1.cmpDate(dt2) != 0`, 
  meaning `dt1` is `not equal to` `dt2`.

  There are therefore two ways of expressing 
  the relationship `dt1` is `not equal to` `dt2`:
  `dt1.cmpDate(dt2) != 0` or `dt1 !==~ dt2`.

  **Notes:**

  The`!==~` operator is the negation of the 
  `==~` operator, hence the notation adopted.

  **See also:**
    - `==~` template
  ]##
  dt1.cmpDate(dt2) != 0


template  `<<`*(dt1: DateTime | MonthMonthday, dt2: DateTime | MonthMonthday): untyped =
  ##[ 
  A shortcut for `dt1.cmpDate(dt2) == -1`,
  meaning `dt1` is `less than` `dt2`.

  There are therefore two ways of expressing 
  the relationship `dt1` is `less than` `dt2`:
  `dt1.cmpDate(dt2) == -1` or `dt1 << dt2`.

  **Notes:**

  Intra-day information (hours, minutes, seconds, etc.) are not taken 
  into account. The inequality mentioned here is therefore more demanding 
  than that of the `DateTime` type (`dt1 << dt2` implies `dt1 < dt2` but 
  the opposite is not true). Hence the notation chosen: `<<` rather than `<`.
  ]##
  dt1.cmpDate(dt2) == -1


template  `>>`*(dt1: DateTime | MonthMonthday, dt2: DateTime | MonthMonthday): untyped =
  ##[ 
  A shortcut for `dt1.cmpDate(dt2) == 1`,
  meaning `dt1` is `greater than` `dt2`.

  There are therefore two ways of expressing 
  the relationship `dt1` is `greater than` `dt2`:
  `dt1.cmpDate(dt2) == 1` or `dt1 >> dt2`.

  **Notes:**

  Intra-day information (hours, minutes, seconds, etc.) are not taken 
  into account. The inequality mentioned here is therefore more demanding 
  than that of the `DateTime` type (`dt1 >> dt2` implies `dt1 > dt2` but 
  the opposite is not true). Hence the notation chosen: `>>` rather than `>`.
  ]##
  dt1.cmpDate(dt2) == 1


template  `<<==~`*(dt1: DateTime | MonthMonthday, dt2: DateTime | MonthMonthday): untyped =
  ##[ 
  A shortcut for `dt1.cmpDate(dt2) <= 0`,
  meaning `dt1` is `less than or equal to` `dt2`.

  There are therefore two ways of expressing 
  the relationship `dt1` is `less than or equal to` `dt2`:
  `dt1.cmpDate(dt2) <= 0` or `dt1 <<==~ dt2`.

  **Notes:**
  
  The operator `<<==~` is the combination of the 
  operators `<<` (less than) and `==~` (equal to).
  ]##
  dt1.cmpDate(dt2) <= 0


template  `>>==~`*(dt1: DateTime | MonthMonthday, dt2: DateTime | MonthMonthday): untyped =
  ##[ 
  A shortcut for `dt1.cmpDate(dt2) >= 0`,
  meaning `dt1` is `greater than or equal to` `dt2`.

  There are therefore two ways of expressing 
  the relationship `dt1` is `greater than or equal to` `dt2`:
  `dt1.cmpDate(dt2) >= 0` or `dt1 >>==~ dt2`.
		
  **Notes:**

  The operator `>>==~` is the combination of the operators 
  `>>` (greater than) and `==~` (equal to).
  ]##
  dt1.cmpDate(dt2) >= 0


# ==============================     Easter     ============================== #

func  gregorianEasterSundayMMDD*(year: int): Option[tuple[month: int, monthday: int]] =
  ##[
  **Returns:**
    - The date of *Gregorian Easter Sunday* of the 
      year given in parameter if `year >= 1583`.
    - `none((int, int))` if `year < 1583`.

  **Algorithm:**

    Unlike Christmas which is always on December 25, the date of Easter Sunday 
    varies from year to year. However, there are algorithms that allow you to 
    calculate this date for any past, present or future year.
    The algorithm that was implemented here is described on this `wikipedia page
	<https://en.wikipedia.org/wiki/Date_of_Easter#Anonymous_Gregorian_algorithm>`_
    and its results were *successfully compared to the 518 Easter Sunday 
    dates* that can be found `here 
	<http://palluy.fr/index.php?page=1583-a-1600-apres-paques>`_ and `there 
    <https://www.census.gov/data/software/x13as/genhol/easter-dates.html>`_.

  **Notes:**

    From a historical point of view, the Gregorian calendar 
    came into effect on October 15th, 1582. *The Gregorian 
    Easter day therefore only makes sense from the year 1583*.
    This is why the function returns `none((int, int))` for 
    all years before 1583.
  ]##
  runnableExamples:
    doAssert:  gregorianEasterSundayMMDD(1200).isNone
    doAssert:  gregorianEasterSundayMMDD(1582).isNone
    doAssert:  gregorianEasterSundayMMDD(2000).get == (month: 4, monthday: 23)
    doAssert:  gregorianEasterSundayMMDD(2018).get == (month: 4, monthday: 1) 
    doAssert:  gregorianEasterSundayMMDD(2036).get == (month: 4, monthday: 13)
    doAssert:  gregorianEasterSundayMMDD(2054).get == (month: 3, monthday: 29)
    doAssert:  gregorianEasterSundayMMDD(2071).get == (month: 4, monthday: 19) 
    doAssert:  gregorianEasterSundayMMDD(2097).get == (month: 3, monthday: 31)
  if year >= 1583:
    let a = year mod 19
    let b = year div 100
    let c = year mod 100
    let (d,e) = divmod(b,4)  # instead of: d = b div 4; e = b mod 4
    #let f = (b+8) div 25
    let g = (8*b+13) div 25
    let h = (19*a+b-d-g+15) mod 30
    let (i,k) = divmod(c,4)  # instead of: i = c div 4; k = c mod 4
    let l = (32+2*e+2*i-h-k) mod 7
    let m = (a+11*h+19*l) div 433
    let n = (h+l-7*m+90) div 25
    #let o = (h+l-7*m+114) mod 31
    let p = (h+l-7*m+33*n+19) mod 32
    result = some((n, p))


proc  gregorianEasterSunday*(year: int; hour: HourRange = 0; minute: MinuteRange = 0; second: SecondRange = 0; 
                             nanosecond: NanosecondRange = 0; zone: Timezone = local()): Option[DateTime] =
  ##[
  **Returns:**
    - The date of Gregorian Easter Sunday of the 
      year given in parameter if `year >= 1583`.
    - `none(DateTime)` if `year < 1583`.

  **See also:**
    - `gregorianEasterSundayMMDD <#gregorianEasterSundayMMDD,int>`_
  ]##
  let easterOption = gregorianEasterSundayMMDD(year)
  if easterOption.isNone:
    result = none(DateTime)
  else:
    let easter = easterOption.get
    result = dateTime(year = year, month = Month(easter.month), monthday = easter.monthday, hour = hour,
                      minute = minute, second = second, nanosecond = nanosecond, zone = zone).some


func  julianEasterSundayMMDD*(year: int): Option[tuple[month: int, monthday: int]] =
  ##[
  **Returns:**
    - The date of *Julian Easter Sunday* of the 
      year given in parameter if `year >= 34`.
    - `none((int, int))` if `year < 34`.

  **Algorithm:**

    The algorithm that was implemented here is described on this `wikipedia page
	<https://en.wikipedia.org/wiki/Date_of_Easter#Meeus's_Julian_algorithm>`_.

  ]##

  runnableExamples:
    doAssert:  julianEasterSundayMMDD(33).isNone
    doAssert:  julianEasterSundayMMDD(2008).get == (month: 4, monthday: 14)
    doAssert:  julianEasterSundayMMDD(2009).get == (month: 4, monthday: 6) 
    doAssert:  julianEasterSundayMMDD(2010).get == (month: 3, monthday: 22)
    doAssert:  julianEasterSundayMMDD(2011).get == (month: 4, monthday: 11)
    doAssert:  julianEasterSundayMMDD(2016).get == (month: 4, monthday: 18) 
    doAssert:  julianEasterSundayMMDD(2024).get == (month: 4, monthday: 22) 
    doAssert:  julianEasterSundayMMDD(2025).get == (month: 4, monthday: 7)

  if year > 33:
    let a = year mod 4
    let b = year mod 7
    let c = year mod 19
    let d = (19*c + 15) mod 30
    let e = (2*a+4*b-d+34) mod 7
    let f = d+e+114
    let month = f div 31
    let day = (f mod 31) + 1
    result = some((month, day))


# ============================     Other Procs     =========================== #

func  isLastDayOfFebruary*(dt: DateTime): bool =
  ## Tests if `dt` is the last day of Frebruary.

  runnableExamples:
    let dt1 = dateTime(2023, mFeb, 28)
    let dt2 = dateTime(2024, mFeb, 28)
    let dt3 = dateTime(2024, mFeb, 29)

    doAssert:  dt1.isLastDayOfFebruary
    doAssert:  not dt2.isLastDayOfFebruary
    doAssert:  dt3.isLastDayOfFebruary

  if dt.month != mFeb:  return false
  elif dt.year.isLeapYear:  return (dt.monthday == 29)
  else:  return (dt.monthday == 28)


proc  getDayOfWeek*(dt: DateTime): WeekDay {.inline.} =
  ## Returns the day of the week of `dt`.
  getDayOfWeek(year = dt.year, month = dt.month, monthday = dt.monthday)


proc  isSaturdayOrSunday*(dt: DateTime): bool {.inline.} =
  ## Tests if `dt` is a Saturday or a Sunday.
  getDayOfWeek(dt) in {dSat, dSun}


func  nthWeekday*(n: int, weekday: Weekday, month: Month, year: int): Option[MonthdayRange] =
  ##[ 
  **Returns:** 
    - The n-th occurence of `<weekday>` in the month  
      that is defined by parameters `month` and `year`.
    - `none(MonthdayRange)` if the search is unsuccessful
      (this is particularly the case if `n == 0 or abs(n) > 5`).

  **Notes:**
    - If `n > 0` then counting is performed from the beginning of the month.
    - If `n < 0` then counting is performed from the end of the month.
  ]##
  
  runnableExamples:
    # search from the beginning of the month
    doAssert:  nthWeekday(1, dMon, mAug, 2023).get == 7.MonthdayRange
    doAssert:  nthWeekday(3, dMon, mAug, 2023).get == 21.MonthdayRange
    doAssert:  nthWeekday(5, dMon, mAug, 2023).isNone
    doAssert:  nthWeekday(5, dTue, mAug, 2023).get == 29.MonthdayRange
    # search from the end of the month
    doAssert:  nthWeekday(-1, dMon, mAug, 2023).get == 28.MonthdayRange
    doAssert:  nthWeekday(-3, dMon, mAug, 2023).get == 14.MonthdayRange
    doAssert:  nthWeekday(-5, dMon, mAug, 2023).isNone
    doAssert:  nthWeekday(-1, dWed, mAug, 2023).get == 30.MonthdayRange
    doAssert:  nthWeekday(-5, dThu, mAug, 2023).get == 3.MonthdayRange
    doAssert:  nthWeekday(-1, dSat, mAug, 2023).get == 26.MonthdayRange
    doAssert:  nthWeekday(-3, dSat, mAug, 2023).get == 12.MonthdayRange

  if n == 0 or abs(n) > 5:  return none(MonthdayRange)

  let weekday1st = getDayOfWeek(1.MonthdayRange, month, year)
  let daysInMonth = getDaysInMonth(month, year)
  let weekdayLast = getDayOfWeek(daysInMonth.MonthdayRange, month, year)

  if n > 0:  # counting from the beginning of the month
    let deltaWeekday = weekday.ord - weekday1st.ord
    let N = (if deltaWeekday >= 0: n-1 else: n)
    let monthday = deltaWeekday + 7*N + 1
    if 1 <= monthday and monthday <= daysInMonth:  
      result = some(monthday.MonthdayRange)
    else:  
      result = none(MonthdayRange)
  else:  # counting from the end of the month
    let deltaWeekday = weekdayLast.ord - weekday.ord
    let N = (if deltaWeekday >= 0: n+1 else: n)
    let monthday = daysInMonth - deltaWeekday + 7*N
    if 1 <= monthday and monthday <= daysInMonth:  
      result = some(monthday.MonthdayRange)
    else:  
      result = none(MonthdayRange)


proc  diffDays*(dt1, dt2: DateTime): int =
  ##[ 
  **Returns:** 
    - `0`, if `dt1 ==~ dt2`
    - `-diffDays(dt2,dt1)`, if `dt1 << dt2`
    - the number of nights between dates `dt2` and `dt1`, if `dt1 >> dt2`
  ]##
  
  runnableExamples:
    # the examples below are based on short time intervals but 
    # the reasoning is the same with larger time intervals

    # same dates but different times
    let dt1 = dateTime(2023, mFeb, 28, 12)
    let dt2 = dateTime(2023, mFeb, 28, 20)
    doAssert:  (dt2-dt1).inDays == 0
    doAssert:  diffDays(dt2, dt1) == 0

    # the day after 'dt1' and a whole day (24 hours) has passed
    let dt3 = dateTime(2023, mMar, 1, 16)
    doAssert:  (dt3-dt1).inDays == 1  and  (dt1-dt3).inDays == -1
    doAssert:  diffDays(dt3, dt1) == 1  and  diffDays(dt1, dt3) == -1

    # the day after 'dt2' but a whole day (24 hours) has not passed
    doAssert:  (dt3-dt2).inDays == 0  and  (dt2-dt3).inDays == 0
    doAssert:  diffDays(dt3, dt2) == 1  and  diffDays(dt2, dt3) == -1

  if dt1 ==~ dt2:  return 0
  elif dt1 << dt2:  return -diffDays(dt2, dt1)
  else:
    let nbWholeDays = (dt1-dt2).inDays
    let dt1Test = dt2 + nbWholeDays.days
    if dt1Test ==~ dt1:  return nbWholeDays
    if dt1Test + 1.days ==~ dt1:  return (nbWholeDays+1)
    notSupposedToGetHere