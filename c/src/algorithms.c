#include "kiahk.h"

/* JDN of 1 Tout, year 1 AM (Coptic epoch). */
#define KIAHK_COPTIC_EPOCH 1825030

int kiahk_gregorian_to_jdn(int year, int month, int day) {
    int a = (14 - month) / 12;
    int y = year + 4800 - a;
    int m = month + 12 * a - 3;
    return day
        + (153 * m + 2) / 5
        + 365 * y
        + y / 4
        - y / 100
        + y / 400
        - 32045;
}

void kiahk_jdn_to_gregorian(int jdn, int *out_year, int *out_month, int *out_day) {
    int a = jdn + 32044;
    int b = (4 * a + 3) / 146097;
    int c = a - (146097 * b) / 4;
    int d = (4 * c + 3) / 1461;
    int e = c - (1461 * d) / 4;
    int m = (5 * e + 2) / 153;
    *out_day = e - (153 * m + 2) / 5 + 1;
    *out_month = m + 3 - 12 * (m / 10);
    *out_year = 100 * b + d - 4800 + m / 10;
}

int kiahk_coptic_to_jdn(int year, int month, int day) {
    return KIAHK_COPTIC_EPOCH - 1
        + 365 * (year - 1)
        + year / 4
        + 30 * (month - 1)
        + day;
}

void kiahk_jdn_to_coptic(int jdn, int *out_year, int *out_month, int *out_day) {
    int r = jdn - KIAHK_COPTIC_EPOCH;
    int year = (4 * r + 1463) / 1461;
    int day_of_year = r - 365 * (year - 1) - year / 4; /* 0-indexed */
    int month = day_of_year / 30 + 1;
    int day = day_of_year - 30 * (month - 1) + 1;
    *out_year = year;
    *out_month = month;
    *out_day = day;
}

void kiahk_gregorian_to_coptic(int gy, int gm, int gd, int *cy, int *cm, int *cd) {
    int jdn = kiahk_gregorian_to_jdn(gy, gm, gd);
    kiahk_jdn_to_coptic(jdn, cy, cm, cd);
}

void kiahk_coptic_to_gregorian(int cy, int cm, int cd, int *gy, int *gm, int *gd) {
    int jdn = kiahk_coptic_to_jdn(cy, cm, cd);
    kiahk_jdn_to_gregorian(jdn, gy, gm, gd);
}

void kiahk_compute_easter(int gregorian_year, int *out_year, int *out_month, int *out_day) {
    int a = gregorian_year % 4;
    int b = gregorian_year % 7;
    int c = gregorian_year % 19;
    int d = (19 * c + 15) % 30;
    int e = (2 * a + 4 * b - d + 34) % 7;
    int f = (d + e + 114) / 31;
    int g = (d + e + 114) % 31 + 1;
    int jdn = kiahk_gregorian_to_jdn(gregorian_year, f, g) + 13;
    kiahk_jdn_to_gregorian(jdn, out_year, out_month, out_day);
}

void kiahk_add_days(int year, int month, int day, int days,
                    int *out_year, int *out_month, int *out_day) {
    int jdn = kiahk_gregorian_to_jdn(year, month, day) + days;
    kiahk_jdn_to_gregorian(jdn, out_year, out_month, out_day);
}
