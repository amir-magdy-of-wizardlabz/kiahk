# Kiahk — Canonical Algorithms

## 1. Gregorian → Coptic (Julian Day Number method)

Epoch: JDN 1825030 = 1 Toot 1 AM (Coptic year 1, month 1, day 1).

### Steps

1. Compute JDN from Gregorian date:
   - a = floor((14 - month) / 12)
   - y = year + 4800 - a
   - m = month + 12*a - 3
   - JDN = day + floor((153*m + 2)/5) + 365*y + floor(y/4) - floor(y/100) + floor(y/400) - 32045

2. Subtract epoch and derive Coptic fields:
   - r = JDN - 1825030
   - copticYear = floor((4*(JDN - 1825030) + 1463) / 1461) - 1
   - dayOfYear = JDN - 1825030 - 365*copticYear - floor(copticYear/4)
   - copticMonth = floor(dayOfYear / 30) + 1
   - copticDay   = dayOfYear - 30*(copticMonth - 1) + 1
   - Note: if copticMonth > 13 clamp to 13 (Nasie/intercalary month).

### Reference implementation (pseudocode)

```
function gregorianToCoptic(gYear, gMonth, gDay):
  a   = (14 - gMonth) / 12
  y   = gYear + 4800 - a
  m   = gMonth + 12*a - 3
  jdn = gDay + (153*m + 2)/5 + 365*y + y/4 - y/100 + y/400 - 32045
  cYear  = (4*(jdn - 1825030) + 1463) / 1461 - 1
  remain = jdn - 1825030 - 365*cYear - cYear/4
  cMonth = remain / 30 + 1
  cDay   = remain - 30*(cMonth - 1) + 1
  return (cYear, cMonth, cDay)
```

## 2. Coptic → Gregorian (Reverse JDN)

```
function copticToGregorian(cYear, cMonth, cDay):
  jdn = cDay + 30*(cMonth - 1) + 365*cYear + cYear/4 + 1825030 - 1
  a   = jdn + 32044
  b   = (4*a + 3) / 146097
  c   = a - (146097*b) / 4
  d   = (4*c + 3) / 1461
  e   = c - (1461*d) / 4
  m   = (5*e + 2) / 153
  gDay   = e - (153*m + 2)/5 + 1
  gMonth = m + 3 - 12*(m/10)
  gYear  = 100*b + d - 4800 + m/10
  return (gYear, gMonth, gDay)
```

## 3. Coptic Easter (Butcher's Algorithm)

Based on the Julian calendar, then offset +13 days to Gregorian.

```
function copticEaster(gregorianYear):
  a = gregorianYear % 4
  b = gregorianYear % 7
  c = gregorianYear % 19
  d = (19*c + 15) % 30
  e = (2*a + 4*b - d + 34) % 7
  f = (d + e + 114) / 31
  g = (d + e + 114) % 31 + 1
  jdn = gregorianToJdn(gregorianYear, f, g) + 13
  return jdnToGregorian(jdn)
```

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
