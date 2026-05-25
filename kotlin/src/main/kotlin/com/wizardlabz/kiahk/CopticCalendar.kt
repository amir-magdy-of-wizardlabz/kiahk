package com.wizardlabz.kiahk

/** Easter, feast lookups, and Coptic month names. */
object CopticCalendar {

    /**
     * Coptic month name in the requested locale (`"en"` or `"ar"`).
     * @throws InvalidCopticMonthException for month outside 1..13.
     * @throws UnsupportedLocaleException for an unknown locale.
     */
    @JvmStatic
    fun monthName(month: Int, locale: String): String {
        if (month !in 1..13) throw InvalidCopticMonthException(month)
        val record = CopticMonths.ALL[month - 1]
        return record.names[locale] ?: throw UnsupportedLocaleException(locale)
    }

    /** Coptic Easter (Pascha) for a Gregorian year. */
    @JvmStatic
    fun easterDate(gregorianYear: Int): GregorianDate {
        val (y, m, d) = Algorithms.computeEaster(gregorianYear)
        return GregorianDate(y, m, d)
    }

    /**
     * One moveable feast for the given Gregorian year.
     * @throws UnknownFeastException if no moveable feast has that id.
     */
    @JvmStatic
    fun moveableFeast(feastId: String, gregorianYear: Int): Feast {
        val def = Feasts.ALL.firstOrNull { it.id == feastId && it.type == "moveable" }
            ?: throw UnknownFeastException(feastId)
        val easter = easterDate(gregorianYear)
        val (y, m, d) = Algorithms.addDays(
            easter.year, easter.month, easter.day, def.easterOffset!!
        )
        val g = GregorianDate(y, m, d)
        return Feast(def, g, g.toCoptic())
    }

    /**
     * All fixed feasts that fall within the given Gregorian year.
     * A Gregorian year spans two Coptic years, so both are checked and
     * results deduped by feast id.
     */
    @JvmStatic
    fun fixedFeasts(gregorianYear: Int): List<Feast> {
        val cYearStart = GregorianDate(gregorianYear, 1, 1).toCoptic().year
        val seen = mutableSetOf<String>()
        val result = mutableListOf<Feast>()
        for (cYear in listOf(cYearStart, cYearStart + 1)) {
            for (def in Feasts.ALL.filter { it.type == "fixed" }) {
                try {
                    val c = CopticDate(cYear, def.copticMonth!!, def.copticDay!!)
                    val g = c.toGregorian()
                    if (g.year == gregorianYear && seen.add(def.id)) {
                        result += Feast(def, g, c)
                    }
                } catch (_: IllegalArgumentException) {
                    // Invalid date for this coptic year (e.g. nasie 6 in non-leap) — skip.
                }
            }
        }
        return result
    }

    /**
     * All major feasts (fixed + moveable) in the given Gregorian year,
     * sorted ascending by Gregorian date.
     */
    @JvmStatic
    fun yearFeasts(gregorianYear: Int): List<Feast> {
        val moveable = Feasts.ALL
            .filter { it.type == "moveable" }
            .map { moveableFeast(it.id, gregorianYear) }
        return (fixedFeasts(gregorianYear) + moveable)
            .sortedBy { Algorithms.gregorianToJdn(it.gregorianDate.year, it.gregorianDate.month, it.gregorianDate.day) }
    }
}
