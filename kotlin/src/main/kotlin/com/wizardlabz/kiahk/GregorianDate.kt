package com.wizardlabz.kiahk

import java.time.LocalDate

/** A calendar date on the proleptic Gregorian calendar. */
data class GregorianDate(val year: Int, val month: Int, val day: Int) {

    init {
        if (month !in 1..12) throw InvalidGregorianDateException(year, month, day)
        if (day < 1 || day > daysInMonth(year, month)) {
            throw InvalidGregorianDateException(year, month, day)
        }
    }

    /** Convert this Gregorian date to a Coptic date. */
    fun toCoptic(): CopticDate {
        val (cy, cm, cd) = Algorithms.jdnToCoptic(
            Algorithms.gregorianToJdn(year, month, day)
        )
        return CopticDate(cy, cm, cd)
    }

    /** Interop with `java.time.LocalDate`. */
    fun toLocalDate(): LocalDate = LocalDate.of(year, month, day)

    companion object {
        /** Build a [GregorianDate] from a [LocalDate]. */
        @JvmStatic
        fun fromLocalDate(date: LocalDate): GregorianDate =
            GregorianDate(date.year, date.monthValue, date.dayOfMonth)

        private fun daysInMonth(year: Int, month: Int): Int = when (month) {
            1, 3, 5, 7, 8, 10, 12 -> 31
            4, 6, 9, 11           -> 30
            2                     -> if (isLeap(year)) 29 else 28
            else                  -> 0
        }

        private fun isLeap(year: Int): Boolean =
            (year % 4 == 0 && year % 100 != 0) || year % 400 == 0
    }
}
