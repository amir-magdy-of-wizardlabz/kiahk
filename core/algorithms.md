# Kiahk — Canonical Algorithms

All algorithms are expressed against a shared intermediary: the **Julian Day
Number (JDN)**, the integer count of days since noon UTC on 1 January 4713 BC
(proleptic Julian).

References:

- Dershowitz & Reingold, *Calendrical Calculations* (3rd ed., 2008), §4.1
  (Coptic calendar).
- Fourmilab / Jean Meeus port in the Python `convertdate` package
  (https://github.com/fitnr/convertdate, `src/convertdate/coptic.py`).
- Wikipedia: https://en.wikipedia.org/wiki/Coptic_calendar
- Orthodox Easter (Pascha) tables: https://www.qppstudio.net/global-holidays-observances/orthodox-easter.htm

## 0. Coptic calendar facts

- Era: **Anno Martyrum (AM)**. Year 1 begins **29 August 284 CE (Julian)** =
  **11 September 284 CE (proleptic Gregorian)** = **JDN 1825030**.
- Each year has 12 months of exactly 30 days, plus a 13th "little month"
  (**Nasie**) of **5 days** in common years and **6 days** in leap years.
- Leap rule (Julian-style): year `Y` is a leap year iff `Y mod 4 == 3`.
  Equivalently, the 13th month has 6 days iff `Y mod 4 == 3`.
- For Gregorian years 1900–2099, 1 Tout falls on **11 September**, or on
  **12 September** when the next Gregorian year is a leap year.

## 1. Gregorian ↔ JDN

```
function gregorianToJdn(year, month, day):
  a = floor((14 - month) / 12)
  y = year + 4800 - a
  m = month + 12*a - 3
  return day
       + floor((153*m + 2) / 5)
       + 365*y
       + floor(y/4) - floor(y/100) + floor(y/400)
       - 32045
```

```
function jdnToGregorian(jdn):
  a = jdn + 32044
  b = floor((4*a + 3) / 146097)
  c = a - floor((146097*b) / 4)
  d = floor((4*c + 3) / 1461)
  e = c - floor((1461*d) / 4)
  m = floor((5*e + 2) / 153)
  day   = e - floor((153*m + 2) / 5) + 1
  month = m + 3 - 12*floor(m/10)
  year  = 100*b + d - 4800 + floor(m/10)
  return (year, month, day)
```

## 2. Coptic ↔ JDN

Let `COPTIC_EPOCH = 1825030` (JDN of 1 Tout, year 1 AM).

Days elapsed before the start of Coptic year `cYear` (i.e. between 1 Tout 1 AM
and 1 Tout `cYear` AM):

```
365 * (cYear - 1) + floor(cYear / 4)
```

The `floor(cYear / 4)` term counts the number of Coptic leap years in
`[1, cYear - 1]`, since `Y` is leap iff `Y mod 4 == 3`.

```
function copticToJdn(cYear, cMonth, cDay):
  return COPTIC_EPOCH - 1
       + 365 * (cYear - 1)
       + floor(cYear / 4)
       + 30 * (cMonth - 1)
       + cDay
```

For the inverse, let `r = jdn - COPTIC_EPOCH` be the 0-indexed day count
since 1 Tout 1 AM. Solving `r = 365*(cYear - 1) + floor(cYear/4) + dayOfYear`
with `0 <= dayOfYear < 366` gives the closed form:

```
function jdnToCoptic(jdn):
  r        = jdn - COPTIC_EPOCH
  cYear    = floor((4*r + 1463) / 1461)
  dayOfYr  = r - 365*(cYear - 1) - floor(cYear / 4)   // 0-indexed
  cMonth   = floor(dayOfYr / 30) + 1
  cDay     = dayOfYr - 30*(cMonth - 1) + 1
  return (cYear, cMonth, cDay)
```

The `dayOfYr` is in `[0, 364]` for common years and `[0, 365]` for leap
years; both cases yield `cMonth ∈ [1, 13]` and a valid `cDay`.

### Conversions

```
function gregorianToCoptic(gYear, gMonth, gDay):
  return jdnToCoptic(gregorianToJdn(gYear, gMonth, gDay))

function copticToGregorian(cYear, cMonth, cDay):
  return jdnToGregorian(copticToJdn(cYear, cMonth, cDay))
```

## 3. Coptic Easter (Pascha)

The Coptic Orthodox Church follows the **Julian computus** for Easter, then
expresses the result on the civil (Gregorian) calendar. Meeus's compact form
of the Julian computus:

```
function copticEaster(gregorianYear):
  a = gregorianYear mod 4
  b = gregorianYear mod 7
  c = gregorianYear mod 19
  d = (19*c + 15) mod 30
  e = (2*a + 4*b - d + 34) mod 7
  f = floor((d + e + 114) / 31)        // Julian-calendar month (3 or 4)
  g = ((d + e + 114) mod 31) + 1       // Julian-calendar day
  // Julian → Gregorian: for 1900-03-01 .. 2100-02-28 the offset is +13 days.
  jdn = gregorianToJdn(gregorianYear, f, g) + 13
  return jdnToGregorian(jdn)
```

The constant `+13` is the Julian-Gregorian difference valid for all dates
this library targets (20th–21st century). The trick of running `f, g` through
`gregorianToJdn` works because both calendars share month lengths; the +13
shift handles the proleptic offset.

## 4. Moveable Feasts

All moveable feasts are derived from Easter Sunday:

```
feastDate = easterDate + easterOffset (days)
```

Negative offset = before Easter. Positive = after.

| Feast        | Offset |
|--------------|--------|
| Nineveh Fast | -69    |
| Great Lent   | -55    |
| Palm Sunday  | -7     |
| Easter       | 0      |
| Ascension    | +39    |
| Pentecost    | +49    |
