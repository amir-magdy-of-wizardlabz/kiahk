/*
 * kiahk.h — Coptic calendar arithmetic.
 *
 * Pure C99 library. All public symbols are prefixed with `kiahk_` (functions
 * and types) or `KIAHK_` (macros, enum cases, and constants). Functions that
 * can fail return a kiahk_error code; outputs are written via *out pointer
 * parameters following standard C convention.
 *
 * Cross-port spec: docs/superpowers/specs/2026-05-23-multi-language-ports-design.md
 */
#ifndef KIAHK_H
#define KIAHK_H

#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

/* --- Error codes --------------------------------------------------------- */

typedef enum {
    KIAHK_OK = 0,
    KIAHK_ERR_INVALID_COPTIC_DATE = 1,
    KIAHK_ERR_INVALID_GREGORIAN_DATE = 2,
    KIAHK_ERR_UNSUPPORTED_LOCALE = 3,
    KIAHK_ERR_UNKNOWN_FEAST = 4,
    KIAHK_ERR_NOT_MOVEABLE = 5,
    KIAHK_ERR_BUFFER_TOO_SMALL = 6,
    KIAHK_ERR_INVALID_COPTIC_MONTH = 7
} kiahk_error;

/* Human-readable static string for a given error code (never NULL). */
const char *kiahk_error_message(kiahk_error err);

/* --- Value types --------------------------------------------------------- */

typedef struct {
    int year;
    int month;
    int day;
} kiahk_coptic_date;

typedef struct {
    int year;
    int month;
    int day;
} kiahk_gregorian_date;

/* Localized feast names. Currently English + Arabic. */
typedef struct {
    const char *en;
    const char *ar;
} kiahk_feast_names;

/* Static metadata for a feast (mirror of one entry in core/feasts.json). */
typedef struct {
    const char *id;
    kiahk_feast_names names;
    const char *type;        /* "fixed" | "moveable" */
    const char *category;    /* "major" | "minor" */
    int coptic_month;        /* valid when type == "fixed" */
    int coptic_day;          /* valid when type == "fixed" */
    int easter_offset;       /* valid when type == "moveable" */
} kiahk_feast_record;

/* A calendar-resolved feast (record + Gregorian date for a specific year). */
typedef struct {
    const char *id;
    const char *type;
    const char *category;
    const kiahk_feast_names *names;
    kiahk_gregorian_date gregorian_date;
} kiahk_feast;

/* --- Algorithms (low-level conversions) --------------------------------- */

/* Gregorian date → Julian Day Number (Fliegel & Van Flandern). */
int kiahk_gregorian_to_jdn(int year, int month, int day);

/* Julian Day Number → Gregorian (year, month, day) via out pointers. */
void kiahk_jdn_to_gregorian(int jdn, int *out_year, int *out_month, int *out_day);

/* Coptic date → JDN. No validation; pure arithmetic. */
int kiahk_coptic_to_jdn(int year, int month, int day);

void kiahk_jdn_to_coptic(int jdn, int *out_year, int *out_month, int *out_day);

void kiahk_gregorian_to_coptic(int gy, int gm, int gd, int *cy, int *cm, int *cd);

void kiahk_coptic_to_gregorian(int cy, int cm, int cd, int *gy, int *gm, int *gd);

void kiahk_compute_easter(int gregorian_year, int *out_year, int *out_month, int *out_day);

void kiahk_add_days(int year, int month, int day, int days,
                    int *out_year, int *out_month, int *out_day);

/* --- GregorianDate ------------------------------------------------------- */

/* Construct + validate a Gregorian date.
 * On success returns KIAHK_OK and writes to *out.
 * On invalid month/day returns KIAHK_ERR_INVALID_GREGORIAN_DATE; *out is zeroed.
 */
kiahk_error kiahk_gregorian_date_init(kiahk_gregorian_date *out, int year, int month, int day);

/* Convert a Gregorian date to a Coptic date. */
kiahk_error kiahk_gregorian_date_to_coptic(const kiahk_gregorian_date *g, kiahk_coptic_date *out);

/* --- CopticDate ---------------------------------------------------------- */

/* Construct + validate a Coptic date.
 * Coptic month range: 1..13 (13 = Nasie). Day range: 1..30 for months 1..12,
 * 1..5 for month 13 (1..6 in a leap year, where Y mod 4 == 3).
 */
kiahk_error kiahk_coptic_date_init(kiahk_coptic_date *out, int year, int month, int day);

/* Convert a Coptic date to a Gregorian date. */
kiahk_error kiahk_coptic_date_to_gregorian(const kiahk_coptic_date *c, kiahk_gregorian_date *out);

/* --- Coptic months data -------------------------------------------------- */

/* One entry of the Coptic month-name table
 * (mirror of one entry in core/coptic_months.json). */
typedef struct {
    int month;                /* 1..13 */
    kiahk_feast_names names;  /* re-uses {en, ar} struct */
} kiahk_coptic_month_record;

extern const kiahk_coptic_month_record KIAHK_COPTIC_MONTHS[];
extern const size_t KIAHK_COPTIC_MONTHS_COUNT;

/* Look up the localized name of a Coptic month.
 * Supported locales: "en", "ar".
 * On success *out points to a static string.
 * Returns KIAHK_ERR_INVALID_COPTIC_MONTH if month is outside 1..13,
 * KIAHK_ERR_UNSUPPORTED_LOCALE if locale has no translation. */
kiahk_error kiahk_coptic_month_name(int month, const char *locale, const char **out);

/* --- Feasts data --------------------------------------------------------- */

extern const kiahk_feast_record KIAHK_FEASTS[];
extern const size_t KIAHK_FEASTS_COUNT;

/* Find a feast record by id. On success returns KIAHK_OK and *out points
 * to a static entry in KIAHK_FEASTS. On unknown id returns KIAHK_ERR_UNKNOWN_FEAST. */
kiahk_error kiahk_feast_by_id(const char *id, const kiahk_feast_record **out);

/* --- Feast --------------------------------------------------------------- */

/* Look up the localized name of a feast. Supported locales: "en", "ar".
 * On success *out points to a static string. Unknown locale returns
 * KIAHK_ERR_UNSUPPORTED_LOCALE. */
kiahk_error kiahk_feast_name(const kiahk_feast *f, const char *locale, const char **out);

/* --- Calendar entry points ---------------------------------------------- */

/* Return the Gregorian date of Coptic / Orthodox Easter for the given year. */
kiahk_error kiahk_easter_date(int gregorian_year, kiahk_gregorian_date *out);

/* Resolve a moveable feast by id to its Gregorian date in the given year.
 * Returns KIAHK_ERR_UNKNOWN_FEAST if id is unknown,
 * KIAHK_ERR_NOT_MOVEABLE if id refers to a fixed feast. */
kiahk_error kiahk_moveable_feast(const char *id, int gregorian_year, kiahk_feast *out);

/* Fill out_buf with every feast (fixed + moveable) in gregorian_year,
 * sorted ascending by date. Writes the count to *out_count.
 * If cap < KIAHK_FEASTS_COUNT, returns KIAHK_ERR_BUFFER_TOO_SMALL and
 * *out_count is set to the required size. */
kiahk_error kiahk_year_feasts(int gregorian_year, kiahk_feast *out_buf,
                              size_t cap, size_t *out_count);

#ifdef __cplusplus
}
#endif

#endif /* KIAHK_H */
