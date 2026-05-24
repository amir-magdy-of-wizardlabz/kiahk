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
export declare function gregorianToJdn(year: number, month: number, day: number): number;
/** Julian Day Number → Gregorian date. */
export declare function jdnToGregorian(jdn: number): [number, number, number];
/** Coptic date → Julian Day Number. */
export declare function copticToJdn(cYear: number, cMonth: number, cDay: number): number;
/** Julian Day Number → Coptic date. */
export declare function jdnToCoptic(jdn: number): [number, number, number];
/** Gregorian → Coptic. */
export declare function gregorianToCoptic(gYear: number, gMonth: number, gDay: number): [number, number, number];
/** Coptic → Gregorian. */
export declare function copticToGregorian(cYear: number, cMonth: number, cDay: number): [number, number, number];
/**
 * Coptic / Orthodox Easter (Meeus's Julian computus + Julian-to-Gregorian shift).
 *
 * The Meeus formula yields Easter Sunday in the *Julian* calendar. To express
 * the same instant on the *Gregorian* calendar we add the Julian-Gregorian
 * offset (13 days for any date in the 20th–21st century: 1900-03-01 through
 * 2100-02-28). Since this library targets the modern era we hard-code +13.
 */
export declare function computeEaster(gregorianYear: number): [number, number, number];
/** Add N days to a Gregorian date, returning [year, month, day]. */
export declare function addDays(year: number, month: number, day: number, days: number): [number, number, number];
