#include "kiahk.h"

static int is_coptic_leap(int y) { return y % 4 == 3; }

kiahk_error kiahk_coptic_date_init(kiahk_coptic_date *out, int year, int month, int day) {
    if (!out) return KIAHK_ERR_INVALID_COPTIC_DATE;
    if (month < 1 || month > 13) {
        out->year = 0; out->month = 0; out->day = 0;
        return KIAHK_ERR_INVALID_COPTIC_DATE;
    }
    int max_day = 30;
    if (month == 13) {
        max_day = is_coptic_leap(year) ? 6 : 5;
    }
    if (day < 1 || day > max_day) {
        out->year = 0; out->month = 0; out->day = 0;
        return KIAHK_ERR_INVALID_COPTIC_DATE;
    }
    out->year = year; out->month = month; out->day = day;
    return KIAHK_OK;
}

kiahk_error kiahk_coptic_date_to_gregorian(const kiahk_coptic_date *c, kiahk_gregorian_date *out) {
    if (!c || !out) return KIAHK_ERR_INVALID_COPTIC_DATE;
    int gy, gm, gd;
    kiahk_coptic_to_gregorian(c->year, c->month, c->day, &gy, &gm, &gd);
    return kiahk_gregorian_date_init(out, gy, gm, gd);
}
