package com.wizardlabz.kiahk

/** Thrown when a Gregorian date fails range/leap validation. */
class InvalidGregorianDateException(val year: Int, val month: Int, val day: Int) :
    IllegalArgumentException("Invalid Gregorian date: $year-$month-$day")

/** Thrown when a Coptic date fails range/leap validation. */
class InvalidCopticDateException(val year: Int, val month: Int, val day: Int) :
    IllegalArgumentException("Invalid Coptic date: $year-$month-$day")

/** Thrown when a Coptic month number is outside 1..13. */
class InvalidCopticMonthException(val month: Int) :
    IllegalArgumentException("Invalid Coptic month: $month (must be 1..13)")

/** Thrown when a locale code is not in the supported set (currently "en", "ar"). */
class UnsupportedLocaleException(val locale: String) :
    IllegalArgumentException("Unsupported locale: $locale (supported: 'en', 'ar')")

/** Thrown when [CopticCalendar.moveableFeast] is called with an unknown feast id. */
class UnknownFeastException(val feastId: String) :
    IllegalArgumentException("Unknown feast id: $feastId")
