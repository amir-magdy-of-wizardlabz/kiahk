import Foundation

/// JDN of 1 Tout, year 1 AM (Coptic epoch).
internal let copticEpoch = 1_825_030

/// Gregorian date → Julian Day Number (Fliegel & Van Flandern).
public func gregorianToJdn(year: Int, month: Int, day: Int) -> Int {
    let a = (14 - month) / 12
    let y = year + 4800 - a
    let m = month + 12 * a - 3
    return day
        + (153 * m + 2) / 5
        + 365 * y
        + y / 4
        - y / 100
        + y / 400
        - 32045
}

/// Julian Day Number → Gregorian (year, month, day).
public func jdnToGregorian(_ jdn: Int) -> (year: Int, month: Int, day: Int) {
    let a = jdn + 32044
    let b = (4 * a + 3) / 146097
    let c = a - (146097 * b) / 4
    let d = (4 * c + 3) / 1461
    let e = c - (1461 * d) / 4
    let m = (5 * e + 2) / 153
    let day = e - (153 * m + 2) / 5 + 1
    let month = m + 3 - 12 * (m / 10)
    let year = 100 * b + d - 4800 + m / 10
    return (year: year, month: month, day: day)
}

/// Coptic date → Julian Day Number.
///
/// Days before Coptic year `year` (within the AM era):
///   365*(year-1) full years + one extra day per Coptic leap year in [1, year-1].
/// Leap rule: Y mod 4 == 3; count of leaps in [1, year-1] = year / 4.
public func copticToJdn(year: Int, month: Int, day: Int) -> Int {
    return copticEpoch
        - 1
        + 365 * (year - 1)
        + year / 4
        + 30 * (month - 1)
        + day
}

/// Julian Day Number → Coptic (year, month, day).
///
/// Let r = jdn - copticEpoch (0 = 1 Tout 1 AM). Solve
///   r = 365*(year-1) + floor(year/4) + dayOfYear, 0 <= dayOfYear <= 365.
/// Closed form: year = (4*r + 1463) / 1461.
public func jdnToCoptic(_ jdn: Int) -> (year: Int, month: Int, day: Int) {
    let r = jdn - copticEpoch
    let year = (4 * r + 1463) / 1461
    let dayOfYear = r - 365 * (year - 1) - year / 4 // 0-indexed
    let month = dayOfYear / 30 + 1
    let day = dayOfYear - 30 * (month - 1) + 1
    return (year: year, month: month, day: day)
}

/// Gregorian → Coptic.
public func gregorianToCoptic(year: Int, month: Int, day: Int) -> (year: Int, month: Int, day: Int) {
    return jdnToCoptic(gregorianToJdn(year: year, month: month, day: day))
}

/// Coptic → Gregorian.
public func copticToGregorian(year: Int, month: Int, day: Int) -> (year: Int, month: Int, day: Int) {
    return jdnToGregorian(copticToJdn(year: year, month: month, day: day))
}

/// Coptic / Orthodox Easter (Meeus's Julian computus + 13-day Julian→Gregorian shift).
/// Valid for any date in 1900-03-01..2100-02-28.
public func computeEaster(gregorianYear: Int) -> (year: Int, month: Int, day: Int) {
    let a = gregorianYear % 4
    let b = gregorianYear % 7
    let c = gregorianYear % 19
    let d = (19 * c + 15) % 30
    let e = (2 * a + 4 * b - d + 34) % 7
    let f = (d + e + 114) / 31      // Julian-calendar month
    let g = (d + e + 114) % 31 + 1  // Julian-calendar day
    let jdn = gregorianToJdn(year: gregorianYear, month: f, day: g) + 13
    return jdnToGregorian(jdn)
}

/// Add N days to a Gregorian date and return the new date.
public func addDays(year: Int, month: Int, day: Int, days: Int) -> (year: Int, month: Int, day: Int) {
    return jdnToGregorian(gregorianToJdn(year: year, month: month, day: day) + days)
}
