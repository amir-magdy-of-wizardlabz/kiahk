#include "kiahk.h"
#include <string.h>

/*
 * Hand-maintained mirror of core/coptic_months.json.
 * Keep order identical (months 1..13) for cross-port test parity.
 */
const kiahk_coptic_month_record KIAHK_COPTIC_MONTHS[] = {
    { 1,  { "Thout",    "توت" } },
    { 2,  { "Paopi",    "بابة" } },
    { 3,  { "Hathor",   "هاتور" } },
    { 4,  { "Koiak",    "كيهك" } },
    { 5,  { "Tobi",     "طوبة" } },
    { 6,  { "Meshir",   "أمشير" } },
    { 7,  { "Paremhat", "برمهات" } },
    { 8,  { "Parmouti", "برمودة" } },
    { 9,  { "Pashons",  "بشنس" } },
    { 10, { "Paoni",    "بؤونة" } },
    { 11, { "Epip",     "أبيب" } },
    { 12, { "Mesori",   "مسرى" } },
    { 13, { "Nasie",    "نسيء" } },
};

const size_t KIAHK_COPTIC_MONTHS_COUNT =
    sizeof(KIAHK_COPTIC_MONTHS) / sizeof(KIAHK_COPTIC_MONTHS[0]);

kiahk_error kiahk_coptic_month_name(int month, const char *locale, const char **out) {
    if (out == NULL || locale == NULL) {
        return KIAHK_ERR_UNSUPPORTED_LOCALE;
    }
    if (month < 1 || month > 13) {
        return KIAHK_ERR_INVALID_COPTIC_MONTH;
    }
    const kiahk_coptic_month_record *rec = &KIAHK_COPTIC_MONTHS[month - 1];
    if (strcmp(locale, "en") == 0) {
        *out = rec->names.en;
        return KIAHK_OK;
    }
    if (strcmp(locale, "ar") == 0) {
        *out = rec->names.ar;
        return KIAHK_OK;
    }
    return KIAHK_ERR_UNSUPPORTED_LOCALE;
}
