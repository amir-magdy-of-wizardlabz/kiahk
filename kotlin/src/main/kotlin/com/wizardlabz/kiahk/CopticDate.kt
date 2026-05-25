package com.wizardlabz.kiahk

/** A calendar date on the Coptic (Anno Martyrum) calendar. */
data class CopticDate(val year: Int, val month: Int, val day: Int) {

    init {
        if (month !in 1..13) throw InvalidCopticDateException(year, month, day)
        val maxDay = if (month == 13) (if (isCopticLeap(year)) 6 else 5) else 30
        if (day < 1 || day > maxDay) throw InvalidCopticDateException(year, month, day)
    }

    /** Convert this Coptic date to a Gregorian date. */
    fun toGregorian(): GregorianDate {
        val (gy, gm, gd) = Algorithms.jdnToGregorian(
            Algorithms.copticToJdn(year, month, day)
        )
        return GregorianDate(gy, gm, gd)
    }

    private companion object {
        /** Coptic leap year: Y mod 4 == 3 (Julian-style). */
        fun isCopticLeap(year: Int): Boolean = year % 4 == 3
    }
}
