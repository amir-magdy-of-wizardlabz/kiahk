package com.wizardlabz.kiahk

/**
 * Calendar conversion primitives for the Coptic (Alexandrian) calendar.
 *
 * Identical results to the JS / Python / Go / Dart / Swift / C# / C / PHP
 * ports against `core/test-vectors.json`. See `core/algorithms.md` for the
 * full spec including references (Reingold-Dershowitz, Meeus).
 *
 * All conversions go through the Julian Day Number (JDN), the integer day
 * count since noon UTC on 1 January 4713 BC (proleptic Julian).
 */
object Algorithms {

    /** JDN of 1 Tout, year 1 AM (Coptic epoch). */
    const val COPTIC_EPOCH: Int = 1825030

    /** Gregorian date → Julian Day Number (Fliegel & Van Flandern). */
    fun gregorianToJdn(year: Int, month: Int, day: Int): Int {
        val a = (14 - month).floorDiv(12)
        val y = year + 4800 - a
        val m = month + 12 * a - 3
        return day +
            (153 * m + 2).floorDiv(5) +
            365 * y +
            y.floorDiv(4) - y.floorDiv(100) + y.floorDiv(400) -
            32045
    }

    /** Julian Day Number → Gregorian date (year, month, day). */
    fun jdnToGregorian(jdn: Int): Triple<Int, Int, Int> {
        val a = jdn + 32044
        val b = (4 * a + 3).floorDiv(146097)
        val c = a - (146097 * b).floorDiv(4)
        val d = (4 * c + 3).floorDiv(1461)
        val e = c - (1461 * d).floorDiv(4)
        val m = (5 * e + 2).floorDiv(153)
        val day = e - (153 * m + 2).floorDiv(5) + 1
        val month = m + 3 - 12 * m.floorDiv(10)
        val year = 100 * b + d - 4800 + m.floorDiv(10)
        return Triple(year, month, day)
    }

    /** Coptic date → Julian Day Number. */
    fun copticToJdn(cYear: Int, cMonth: Int, cDay: Int): Int =
        COPTIC_EPOCH - 1 +
            365 * (cYear - 1) +
            cYear.floorDiv(4) +
            30 * (cMonth - 1) +
            cDay

    /** Julian Day Number → Coptic date (cYear, cMonth, cDay). */
    fun jdnToCoptic(jdn: Int): Triple<Int, Int, Int> {
        val r = jdn - COPTIC_EPOCH
        val cYear = (4 * r + 1463).floorDiv(1461)
        val dayOfYr = r - 365 * (cYear - 1) - cYear.floorDiv(4)
        val cMonth = dayOfYr.floorDiv(30) + 1
        val cDay = dayOfYr - 30 * (cMonth - 1) + 1
        return Triple(cYear, cMonth, cDay)
    }

    /**
     * Coptic Easter (Pascha) for a Gregorian year.
     *
     * Julian computus (Meeus's compact form) + a fixed +13 day Julian→Gregorian
     * shift, which is correct for 1900-03-01 .. 2100-02-28.
     */
    fun computeEaster(gregorianYear: Int): Triple<Int, Int, Int> {
        val a = gregorianYear % 4
        val b = gregorianYear % 7
        val c = gregorianYear % 19
        val d = (19 * c + 15) % 30
        val e = (2 * a + 4 * b - d + 34).mod(7)
        val f = (d + e + 114).floorDiv(31)
        val g = ((d + e + 114) % 31) + 1
        val jdn = gregorianToJdn(gregorianYear, f, g) + 13
        return jdnToGregorian(jdn)
    }

    /** Add `days` to a Gregorian date (negative for "before"). */
    fun addDays(year: Int, month: Int, day: Int, days: Int): Triple<Int, Int, Int> =
        jdnToGregorian(gregorianToJdn(year, month, day) + days)
}
