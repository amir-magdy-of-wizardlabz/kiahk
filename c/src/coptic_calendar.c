#include "kiahk.h"
#include <stdlib.h>
#include <string.h>

kiahk_error kiahk_easter_date(int gregorian_year, kiahk_gregorian_date *out) {
    if (!out) return KIAHK_ERR_INVALID_GREGORIAN_DATE;
    int y, m, d;
    kiahk_compute_easter(gregorian_year, &y, &m, &d);
    return kiahk_gregorian_date_init(out, y, m, d);
}

kiahk_error kiahk_moveable_feast(const char *id, int gregorian_year, kiahk_feast *out) {
    if (!id || !out) return KIAHK_ERR_UNKNOWN_FEAST;
    const kiahk_feast_record *rec;
    kiahk_error err = kiahk_feast_by_id(id, &rec);
    if (err != KIAHK_OK) return err;
    if (strcmp(rec->type, "moveable") != 0) return KIAHK_ERR_NOT_MOVEABLE;

    int ey, em, ed;
    kiahk_compute_easter(gregorian_year, &ey, &em, &ed);
    int gy, gm, gd;
    kiahk_add_days(ey, em, ed, rec->easter_offset, &gy, &gm, &gd);
    kiahk_gregorian_date g;
    err = kiahk_gregorian_date_init(&g, gy, gm, gd);
    if (err != KIAHK_OK) return err;

    out->id = rec->id;
    out->type = rec->type;
    out->category = rec->category;
    out->names = &rec->names;
    out->gregorian_date = g;
    return KIAHK_OK;
}

/* Resolve a fixed Coptic feast to its Gregorian date inside gregorian_year. */
static kiahk_error fixed_feast(const kiahk_feast_record *rec, int gregorian_year, kiahk_feast *out) {
    int cy_a, cm_a, cd_a;
    kiahk_gregorian_to_coptic(gregorian_year, 1, 1, &cy_a, &cm_a, &cd_a);
    int cy_b, cm_b, cd_b;
    kiahk_gregorian_to_coptic(gregorian_year, 12, 31, &cy_b, &cm_b, &cd_b);
    (void)cm_a; (void)cd_a; (void)cm_b; (void)cd_b;

    int candidate_years[2];
    int n_candidates = 0;
    candidate_years[n_candidates++] = cy_a;
    if (cy_b != cy_a) candidate_years[n_candidates++] = cy_b;

    int picked_y = 0, picked_m = 0, picked_d = 0;
    int found = 0;
    for (int i = 0; i < n_candidates; i++) {
        int gy, gm, gd;
        kiahk_coptic_to_gregorian(candidate_years[i], rec->coptic_month, rec->coptic_day, &gy, &gm, &gd);
        if (gy == gregorian_year) {
            if (!found) {
                picked_y = gy; picked_m = gm; picked_d = gd; found = 1;
            } else {
                /* Earlier date wins (sort ascending). */
                if ((gy < picked_y) ||
                    (gy == picked_y && gm < picked_m) ||
                    (gy == picked_y && gm == picked_m && gd < picked_d)) {
                    picked_y = gy; picked_m = gm; picked_d = gd;
                }
            }
        }
    }
    if (!found) {
        /* Fall back to the earlier candidate year. */
        kiahk_coptic_to_gregorian(cy_a, rec->coptic_month, rec->coptic_day,
                                  &picked_y, &picked_m, &picked_d);
    }
    kiahk_gregorian_date g;
    kiahk_error err = kiahk_gregorian_date_init(&g, picked_y, picked_m, picked_d);
    if (err != KIAHK_OK) return err;

    out->id = rec->id;
    out->type = rec->type;
    out->category = rec->category;
    out->names = &rec->names;
    out->gregorian_date = g;
    return KIAHK_OK;
}

static int feast_cmp(const void *a_, const void *b_) {
    const kiahk_feast *a = (const kiahk_feast *)a_;
    const kiahk_feast *b = (const kiahk_feast *)b_;
    if (a->gregorian_date.year != b->gregorian_date.year)
        return a->gregorian_date.year - b->gregorian_date.year;
    if (a->gregorian_date.month != b->gregorian_date.month)
        return a->gregorian_date.month - b->gregorian_date.month;
    return a->gregorian_date.day - b->gregorian_date.day;
}

kiahk_error kiahk_year_feasts(int gregorian_year, kiahk_feast *out_buf,
                              size_t cap, size_t *out_count) {
    if (!out_buf || !out_count) return KIAHK_ERR_BUFFER_TOO_SMALL;
    if (cap < KIAHK_FEASTS_COUNT) {
        *out_count = KIAHK_FEASTS_COUNT;
        return KIAHK_ERR_BUFFER_TOO_SMALL;
    }
    for (size_t i = 0; i < KIAHK_FEASTS_COUNT; i++) {
        const kiahk_feast_record *rec = &KIAHK_FEASTS[i];
        kiahk_error err;
        if (strcmp(rec->type, "fixed") == 0) {
            err = fixed_feast(rec, gregorian_year, &out_buf[i]);
        } else {
            err = kiahk_moveable_feast(rec->id, gregorian_year, &out_buf[i]);
        }
        if (err != KIAHK_OK) return err;
    }
    qsort(out_buf, KIAHK_FEASTS_COUNT, sizeof(kiahk_feast), feast_cmp);
    *out_count = KIAHK_FEASTS_COUNT;
    return KIAHK_OK;
}
