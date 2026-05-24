#include "kiahk.h"

static const int DAYS_IN_MONTH[] = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };

static int is_greg_leap(int y) {
    return (y % 4 == 0) && (y % 100 != 0 || y % 400 == 0);
}

kiahk_error kiahk_gregorian_date_init(kiahk_gregorian_date *out, int year, int month, int day) {
    if (!out) return KIAHK_ERR_INVALID_GREGORIAN_DATE;
    if (month < 1 || month > 12) {
        out->year = 0; out->month = 0; out->day = 0;
        return KIAHK_ERR_INVALID_GREGORIAN_DATE;
    }
    int max_day = DAYS_IN_MONTH[month - 1];
    if (month == 2 && is_greg_leap(year)) max_day = 29;
    if (day < 1 || day > max_day) {
        out->year = 0; out->month = 0; out->day = 0;
        return KIAHK_ERR_INVALID_GREGORIAN_DATE;
    }
    out->year = year; out->month = month; out->day = day;
    return KIAHK_OK;
}

kiahk_error kiahk_gregorian_date_to_coptic(const kiahk_gregorian_date *g, kiahk_coptic_date *out) {
    if (!g || !out) return KIAHK_ERR_INVALID_GREGORIAN_DATE;
    int cy, cm, cd;
    kiahk_gregorian_to_coptic(g->year, g->month, g->day, &cy, &cm, &cd);
    /* Algorithm output is always in-range; mirror Swift/Dart pattern */
    extern kiahk_error kiahk_coptic_date_init(kiahk_coptic_date *, int, int, int);
    return kiahk_coptic_date_init(out, cy, cm, cd);
}
