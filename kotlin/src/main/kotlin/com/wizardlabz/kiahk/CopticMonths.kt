package com.wizardlabz.kiahk

/** One row of the Coptic month-name table. */
data class CopticMonthRecord(
    /** Coptic month number, 1..13. */
    val month: Int,
    /** Localized month names keyed by ISO 639-1 locale code. */
    val names: Map<String, String>,
)

/**
 * Hand-maintained mirror of `core/coptic_months.json`. Order matters
 * (months 1..13) for cross-port test parity.
 */
object CopticMonths {
    @JvmStatic
    val ALL: List<CopticMonthRecord> = listOf(
        CopticMonthRecord(1,  mapOf("en" to "Thout",    "ar" to "توت")),
        CopticMonthRecord(2,  mapOf("en" to "Paopi",    "ar" to "بابة")),
        CopticMonthRecord(3,  mapOf("en" to "Hathor",   "ar" to "هاتور")),
        CopticMonthRecord(4,  mapOf("en" to "Koiak",    "ar" to "كيهك")),
        CopticMonthRecord(5,  mapOf("en" to "Tobi",     "ar" to "طوبة")),
        CopticMonthRecord(6,  mapOf("en" to "Meshir",   "ar" to "أمشير")),
        CopticMonthRecord(7,  mapOf("en" to "Paremhat", "ar" to "برمهات")),
        CopticMonthRecord(8,  mapOf("en" to "Parmouti", "ar" to "برمودة")),
        CopticMonthRecord(9,  mapOf("en" to "Pashons",  "ar" to "بشنس")),
        CopticMonthRecord(10, mapOf("en" to "Paoni",    "ar" to "بؤونة")),
        CopticMonthRecord(11, mapOf("en" to "Epip",     "ar" to "أبيب")),
        CopticMonthRecord(12, mapOf("en" to "Mesori",   "ar" to "مسرى")),
        CopticMonthRecord(13, mapOf("en" to "Nasie",    "ar" to "نسيء")),
    )
}
