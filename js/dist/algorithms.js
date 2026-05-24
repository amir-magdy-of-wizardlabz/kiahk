/**
 * Calendar conversion primitives for the Coptic (Alexandrian) calendar.
 *
 * The Coptic calendar:
 *   - 12 months of 30 days, plus a 13th "little month" (Nasie) of 5 days
 *     (6 in leap years).
 *   - Leap rule: Coptic year Y is a leap year iff Y mod 4 == 3 (Julian rule).
 *   - Era: Anno Martyrum (AM), starting 29 August 284 CE (Julian) =
 *     11 September 284 CE (proleptic Gregorian) = JDN 1825030
 *     (= 1 Tout 1 AM).
 *
 * Algorithm references:
 *   - Reingold & Dershowitz, "Calendrical Calculations" (3rd ed., 2008),
 *     §4.1 (Coptic calendar).
 *   - Fourmilab/Meeus port in the Python `convertdate` package
 *     (https://github.com/fitnr/convertdate, src/convertdate/coptic.py).
 *   - Wikipedia: https://en.wikipedia.org/wiki/Coptic_calendar
 */
/** Gregorian date → Julian Day Number (Fliegel & Van Flandern). */
export function gregorianToJdn(year, month, day) {
    const a = Math.floor((14 - month) / 12);
    const y = year + 4800 - a;
    const m = month + 12 * a - 3;
    return day + Math.floor((153 * m + 2) / 5) + 365 * y +
        Math.floor(y / 4) - Math.floor(y / 100) + Math.floor(y / 400) - 32045;
}
/** Julian Day Number → Gregorian date. */
export function jdnToGregorian(jdn) {
    const a = jdn + 32044;
    const b = Math.floor((4 * a + 3) / 146097);
    const c = a - Math.floor((146097 * b) / 4);
    const d = Math.floor((4 * c + 3) / 1461);
    const e = c - Math.floor((1461 * d) / 4);
    const m = Math.floor((5 * e + 2) / 153);
    const day = e - Math.floor((153 * m + 2) / 5) + 1;
    const month = m + 3 - 12 * Math.floor(m / 10);
    const year = 100 * b + d - 4800 + Math.floor(m / 10);
    return [year, month, day];
}
/** JDN of 1 Tout, year 1 AM (Coptic epoch). */
const COPTIC_EPOCH = 1825030;
/** Coptic date → Julian Day Number. */
export function copticToJdn(cYear, cMonth, cDay) {
    // Days before year cYear (within the AM era):
    //   365 * (cYear - 1) full years + one extra day for every leap year
    //   in [1, cYear - 1] (Coptic leap year: Y mod 4 == 3).
    // The count of leap years in [1, cYear - 1] equals floor(cYear / 4).
    return COPTIC_EPOCH - 1
        + 365 * (cYear - 1)
        + Math.floor(cYear / 4)
        + 30 * (cMonth - 1)
        + cDay;
}
/** Julian Day Number → Coptic date. */
export function jdnToCoptic(jdn) {
    const r = jdn - COPTIC_EPOCH; // 0 = 1 Tout 1 AM
    // Solve for cYear given r = 365*(cYear-1) + floor(cYear/4) + dayOfYear (0..365).
    // Closed form: cYear = floor((4*r + 1463) / 1461).
    const cYear = Math.floor((4 * r + 1463) / 1461);
    const dayOfYear = r - 365 * (cYear - 1) - Math.floor(cYear / 4); // 0-indexed
    const cMonth = Math.floor(dayOfYear / 30) + 1;
    const cDay = dayOfYear - 30 * (cMonth - 1) + 1;
    return [cYear, cMonth, cDay];
}
/** Gregorian → Coptic. */
export function gregorianToCoptic(gYear, gMonth, gDay) {
    return jdnToCoptic(gregorianToJdn(gYear, gMonth, gDay));
}
/** Coptic → Gregorian. */
export function copticToGregorian(cYear, cMonth, cDay) {
    return jdnToGregorian(copticToJdn(cYear, cMonth, cDay));
}
/**
 * Coptic / Orthodox Easter (Meeus's Julian computus + Julian-to-Gregorian shift).
 *
 * The Meeus formula yields Easter Sunday in the *Julian* calendar. To express
 * the same instant on the *Gregorian* calendar we add the Julian-Gregorian
 * offset (13 days for any date in the 20th–21st century: 1900-03-01 through
 * 2100-02-28). Since this library targets the modern era we hard-code +13.
 */
export function computeEaster(gregorianYear) {
    const a = gregorianYear % 4;
    const b = gregorianYear % 7;
    const c = gregorianYear % 19;
    const d = (19 * c + 15) % 30;
    const e = (2 * a + 4 * b - d + 34) % 7;
    const f = Math.floor((d + e + 114) / 31); // Julian-calendar month
    const g = ((d + e + 114) % 31) + 1; // Julian-calendar day
    const jdn = gregorianToJdn(gregorianYear, f, g) + 13;
    return jdnToGregorian(jdn);
}
/** Add N days to a Gregorian date, returning [year, month, day]. */
export function addDays(year, month, day, days) {
    return jdnToGregorian(gregorianToJdn(year, month, day) + days);
}
