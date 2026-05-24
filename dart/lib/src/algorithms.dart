/// Low-level pure conversion functions. Tuple in, record out. No validation.
library;

/// JDN of 1 Tout, year 1 AM (Coptic epoch).
const int copticEpoch = 1825030;

/// Gregorian date → Julian Day Number (Fliegel & Van Flandern).
int gregorianToJdn(int year, int month, int day) {
  final a = (14 - month) ~/ 12;
  final y = year + 4800 - a;
  final m = month + 12 * a - 3;
  return day +
      (153 * m + 2) ~/ 5 +
      365 * y +
      y ~/ 4 -
      y ~/ 100 +
      y ~/ 400 -
      32045;
}

/// Coptic date → Julian Day Number.
///
/// Days before Coptic year [cYear] (within the AM era):
///   365*(cYear-1) full years + one extra day for every Coptic leap year in [1, cYear-1].
/// Leap rule: Y mod 4 == 3 (Julian-style); count of leaps in [1, cYear-1] = cYear ~/ 4.
int copticToJdn(int cYear, int cMonth, int cDay) {
  return copticEpoch -
      1 +
      365 * (cYear - 1) +
      cYear ~/ 4 +
      30 * (cMonth - 1) +
      cDay;
}

/// Julian Day Number → Gregorian (year, month, day).
({int year, int month, int day}) jdnToGregorian(int jdn) {
  final a = jdn + 32044;
  final b = (4 * a + 3) ~/ 146097;
  final c = a - (146097 * b) ~/ 4;
  final d = (4 * c + 3) ~/ 1461;
  final e = c - (1461 * d) ~/ 4;
  final m = (5 * e + 2) ~/ 153;
  final day = e - (153 * m + 2) ~/ 5 + 1;
  final month = m + 3 - 12 * (m ~/ 10);
  final year = 100 * b + d - 4800 + m ~/ 10;
  return (year: year, month: month, day: day);
}

/// Julian Day Number → Coptic (year, month, day).
///
/// Let r = jdn - copticEpoch (0 = 1 Tout 1 AM). Solve
///   r = 365*(cYear-1) + floor(cYear/4) + dayOfYear,  0 <= dayOfYear <= 365.
/// Closed form: cYear = floor((4*r + 1463) / 1461).
({int year, int month, int day}) jdnToCoptic(int jdn) {
  final r = jdn - copticEpoch;
  final year = (4 * r + 1463) ~/ 1461;
  final dayOfYear = r - 365 * (year - 1) - year ~/ 4; // 0-indexed
  final month = dayOfYear ~/ 30 + 1;
  final day = dayOfYear - 30 * (month - 1) + 1;
  return (year: year, month: month, day: day);
}

/// Gregorian → Coptic.
({int year, int month, int day}) gregorianToCoptic(int gYear, int gMonth, int gDay) =>
    jdnToCoptic(gregorianToJdn(gYear, gMonth, gDay));

/// Coptic → Gregorian.
({int year, int month, int day}) copticToGregorian(int cYear, int cMonth, int cDay) =>
    jdnToGregorian(copticToJdn(cYear, cMonth, cDay));

/// Coptic / Orthodox Easter (Meeus's Julian computus + 13-day Gregorian shift).
///
/// Valid for any date in 1900-03-01..2100-02-28.
({int year, int month, int day}) computeEaster(int gregorianYear) {
  final a = gregorianYear % 4;
  final b = gregorianYear % 7;
  final c = gregorianYear % 19;
  final d = (19 * c + 15) % 30;
  final e = (2 * a + 4 * b - d + 34) % 7;
  final f = (d + e + 114) ~/ 31; // Julian-calendar month
  final g = (d + e + 114) % 31 + 1; // Julian-calendar day
  final jdn = gregorianToJdn(gregorianYear, f, g) + 13;
  return jdnToGregorian(jdn);
}

/// Add N days to a Gregorian date and return the new date.
({int year, int month, int day}) addDays(int year, int month, int day, int days) =>
    jdnToGregorian(gregorianToJdn(year, month, day) + days);
