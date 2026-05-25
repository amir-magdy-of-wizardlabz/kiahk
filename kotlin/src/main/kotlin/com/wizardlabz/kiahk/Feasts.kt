package com.wizardlabz.kiahk

/** Definition of one Coptic feast. Either [copticMonth]+[copticDay] (fixed) or [easterOffset] (moveable) is set. */
data class FeastDefinition(
    val id: String,
    val names: Map<String, String>,
    /** `"fixed"` or `"moveable"`. */
    val type: String,
    /** `"major"` for now (kept for future expansion). */
    val category: String,
    val copticMonth: Int? = null,
    val copticDay: Int? = null,
    val easterOffset: Int? = null,
)

/**
 * Hand-maintained mirror of `core/feasts.json`. Order matters for cross-port
 * test parity.
 */
object Feasts {
    @JvmStatic
    val ALL: List<FeastDefinition> = listOf(
        FeastDefinition("nativity",     mapOf("en" to "Nativity of Christ",   "ar" to "عيد الميلاد المجيد"),   "fixed",    "major", copticMonth = 4,  copticDay = 29),
        FeastDefinition("epiphany",     mapOf("en" to "Epiphany (Theophany)", "ar" to "عيد الغطاس"),          "fixed",    "major", copticMonth = 5,  copticDay = 11),
        FeastDefinition("annunciation", mapOf("en" to "Annunciation",         "ar" to "عيد البشارة"),         "fixed",    "major", copticMonth = 7,  copticDay = 29),
        FeastDefinition("assumption",   mapOf("en" to "Assumption of Mary",   "ar" to "عيد انتقال العذراء"),  "fixed",    "major", copticMonth = 12, copticDay = 16),
        FeastDefinition("cross",        mapOf("en" to "Feast of the Cross",   "ar" to "عيد الصليب"),          "fixed",    "major", copticMonth = 1,  copticDay = 17),
        FeastDefinition("nineveh_fast", mapOf("en" to "Nineveh Fast",         "ar" to "صوم نينوى"),           "moveable", "major", easterOffset = -69),
        FeastDefinition("great_lent",   mapOf("en" to "Great Lent (start)",   "ar" to "بداية الصوم الكبير"),  "moveable", "major", easterOffset = -55),
        FeastDefinition("palm_sunday",  mapOf("en" to "Palm Sunday",          "ar" to "أحد الشعانين"),        "moveable", "major", easterOffset = -7),
        FeastDefinition("easter",       mapOf("en" to "Easter Sunday",        "ar" to "عيد القيامة المجيد"), "moveable", "major", easterOffset = 0),
        FeastDefinition("ascension",    mapOf("en" to "Ascension",            "ar" to "عيد الصعود"),          "moveable", "major", easterOffset = 39),
        FeastDefinition("pentecost",    mapOf("en" to "Pentecost",            "ar" to "عيد العنصرة"),         "moveable", "major", easterOffset = 49),
    )
}
