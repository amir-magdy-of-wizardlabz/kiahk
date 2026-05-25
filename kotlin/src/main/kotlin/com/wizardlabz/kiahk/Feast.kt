package com.wizardlabz.kiahk

/** A feast occurrence in a specific Gregorian year. */
data class Feast(
    val definition: FeastDefinition,
    val gregorianDate: GregorianDate,
    val copticDate: CopticDate,
) {
    /** Feast identifier (e.g. "easter", "nativity"). */
    val id: String get() = definition.id

    /** "fixed" or "moveable". */
    val type: String get() = definition.type

    /** Currently always "major". */
    val category: String get() = definition.category

    /**
     * Localized feast name. Supported locales: `"en"`, `"ar"`.
     * @throws UnsupportedLocaleException for any other locale code.
     */
    fun name(locale: String): String =
        definition.names[locale] ?: throw UnsupportedLocaleException(locale)
}
