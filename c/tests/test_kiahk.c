/*
 * Kiahk C port — single test binary. Loads core/test-vectors.json via cJSON
 * (vendored), then runs every test group. CMake passes KIAHK_CORE_DIR as
 * an absolute path so we don't depend on cwd.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "kiahk.h"
#include "test_runner.h"
#include "cJSON.h"

#ifndef KIAHK_CORE_DIR
#error "KIAHK_CORE_DIR must be defined by the build system (CMake)"
#endif

/* --- Vector loader ------------------------------------------------------- */

static cJSON *g_vectors = NULL;

static char *read_file_to_string(const char *path) {
    FILE *f = fopen(path, "rb");
    if (!f) {
        fprintf(stderr, "cannot open %s\n", path);
        return NULL;
    }
    fseek(f, 0, SEEK_END);
    long size = ftell(f);
    fseek(f, 0, SEEK_SET);
    char *buf = (char *)malloc((size_t)size + 1);
    if (!buf) { fclose(f); return NULL; }
    size_t n = fread(buf, 1, (size_t)size, f);
    buf[n] = '\0';
    fclose(f);
    return buf;
}

static void load_vectors(void) {
    char path[1024];
    snprintf(path, sizeof(path), "%s/test-vectors.json", KIAHK_CORE_DIR);
    char *json = read_file_to_string(path);
    if (!json) { fprintf(stderr, "FATAL: cannot read %s\n", path); exit(2); }
    g_vectors = cJSON_Parse(json);
    free(json);
    if (!g_vectors) {
        fprintf(stderr, "FATAL: cJSON_Parse failed for %s\n", path);
        exit(2);
    }
}

/* Helpers to navigate the vectors JSON cleanly. */
static cJSON *vec_array(const char *key) {
    return cJSON_GetObjectItemCaseSensitive(g_vectors, key);
}
static int ymd_year(const cJSON *obj)  { return cJSON_GetObjectItemCaseSensitive(obj, "year")->valueint; }
static int ymd_month(const cJSON *obj) { return cJSON_GetObjectItemCaseSensitive(obj, "month")->valueint; }
static int ymd_day(const cJSON *obj)   { return cJSON_GetObjectItemCaseSensitive(obj, "day")->valueint; }

/* --- Tests --------------------------------------------------------------- */

static void test_error_messages_are_non_null(int *failed) {
    KIAHK_ASSERT_TRUE(kiahk_error_message(KIAHK_OK) != NULL);
    KIAHK_ASSERT_TRUE(kiahk_error_message(KIAHK_ERR_INVALID_COPTIC_DATE) != NULL);
    KIAHK_ASSERT_TRUE(kiahk_error_message(KIAHK_ERR_INVALID_GREGORIAN_DATE) != NULL);
    KIAHK_ASSERT_TRUE(kiahk_error_message(KIAHK_ERR_UNSUPPORTED_LOCALE) != NULL);
    KIAHK_ASSERT_TRUE(kiahk_error_message(KIAHK_ERR_UNKNOWN_FEAST) != NULL);
    KIAHK_ASSERT_TRUE(kiahk_error_message(KIAHK_ERR_NOT_MOVEABLE) != NULL);
    KIAHK_ASSERT_TRUE(kiahk_error_message(KIAHK_ERR_INVALID_COPTIC_MONTH) != NULL);
}

static void test_error_messages_distinct(int *failed) {
    KIAHK_ASSERT_TRUE(strcmp(kiahk_error_message(KIAHK_OK),
                             kiahk_error_message(KIAHK_ERR_INVALID_COPTIC_DATE)) != 0);
    KIAHK_ASSERT_TRUE(strcmp(kiahk_error_message(KIAHK_ERR_INVALID_COPTIC_DATE),
                             kiahk_error_message(KIAHK_ERR_INVALID_GREGORIAN_DATE)) != 0);
}

static void test_gregorian_to_jdn_known_values(int *failed) {
    KIAHK_ASSERT_EQ_INT(kiahk_gregorian_to_jdn(2000, 1, 1), 2451545);
    KIAHK_ASSERT_EQ_INT(kiahk_gregorian_to_jdn(1900, 1, 1), 2415021);
    KIAHK_ASSERT_EQ_INT(kiahk_gregorian_to_jdn(2025, 1, 11), 2460687);
}

static void test_jdn_round_trip(int *failed) {
    int cases[][3] = {
        {2000, 1, 1}, {1900, 1, 1}, {2025, 1, 11}, {2024, 12, 25}, {2025, 9, 11}
    };
    for (size_t i = 0; i < sizeof(cases) / sizeof(cases[0]); i++) {
        int y = cases[i][0], m = cases[i][1], d = cases[i][2];
        int jdn = kiahk_gregorian_to_jdn(y, m, d);
        int ry, rm, rd;
        kiahk_jdn_to_gregorian(jdn, &ry, &rm, &rd);
        KIAHK_ASSERT_EQ_INT(ry, y);
        KIAHK_ASSERT_EQ_INT(rm, m);
        KIAHK_ASSERT_EQ_INT(rd, d);
    }
}

static void test_coptic_to_jdn_epoch(int *failed) {
    KIAHK_ASSERT_EQ_INT(kiahk_coptic_to_jdn(1, 1, 1), 1825030);
}

static void test_coptic_jdn_round_trip(int *failed) {
    cJSON *arr = vec_array("gregorian_to_coptic");
    KIAHK_ASSERT_TRUE(arr != NULL);
    cJSON *vec;
    cJSON_ArrayForEach(vec, arr) {
        cJSON *c = cJSON_GetObjectItemCaseSensitive(vec, "coptic");
        int cy = ymd_year(c), cm = ymd_month(c), cd = ymd_day(c);
        int jdn = kiahk_coptic_to_jdn(cy, cm, cd);
        int ry, rm, rd;
        kiahk_jdn_to_coptic(jdn, &ry, &rm, &rd);
        KIAHK_ASSERT_EQ_INT(ry, cy);
        KIAHK_ASSERT_EQ_INT(rm, cm);
        KIAHK_ASSERT_EQ_INT(rd, cd);
    }
}

static void test_gregorian_to_coptic_vectors(int *failed) {
    cJSON *arr = vec_array("gregorian_to_coptic");
    cJSON *vec;
    cJSON_ArrayForEach(vec, arr) {
        cJSON *g = cJSON_GetObjectItemCaseSensitive(vec, "gregorian");
        cJSON *c = cJSON_GetObjectItemCaseSensitive(vec, "coptic");
        int cy, cm, cd;
        kiahk_gregorian_to_coptic(ymd_year(g), ymd_month(g), ymd_day(g), &cy, &cm, &cd);
        KIAHK_ASSERT_EQ_INT(cy, ymd_year(c));
        KIAHK_ASSERT_EQ_INT(cm, ymd_month(c));
        KIAHK_ASSERT_EQ_INT(cd, ymd_day(c));
    }
}

static void test_coptic_to_gregorian_vectors(int *failed) {
    cJSON *arr = vec_array("coptic_to_gregorian");
    cJSON *vec;
    cJSON_ArrayForEach(vec, arr) {
        cJSON *c = cJSON_GetObjectItemCaseSensitive(vec, "coptic");
        cJSON *g = cJSON_GetObjectItemCaseSensitive(vec, "gregorian");
        int gy, gm, gd;
        kiahk_coptic_to_gregorian(ymd_year(c), ymd_month(c), ymd_day(c), &gy, &gm, &gd);
        KIAHK_ASSERT_EQ_INT(gy, ymd_year(g));
        KIAHK_ASSERT_EQ_INT(gm, ymd_month(g));
        KIAHK_ASSERT_EQ_INT(gd, ymd_day(g));
    }
}

static void test_compute_easter_vectors(int *failed) {
    cJSON *arr = vec_array("easter");
    cJSON *vec;
    cJSON_ArrayForEach(vec, arr) {
        int year = cJSON_GetObjectItemCaseSensitive(vec, "gregorian_year")->valueint;
        cJSON *d = cJSON_GetObjectItemCaseSensitive(vec, "date");
        int ry, rm, rd;
        kiahk_compute_easter(year, &ry, &rm, &rd);
        KIAHK_ASSERT_EQ_INT(ry, ymd_year(d));
        KIAHK_ASSERT_EQ_INT(rm, ymd_month(d));
        KIAHK_ASSERT_EQ_INT(rd, ymd_day(d));
    }
}

static void test_add_days(int *failed) {
    int ry, rm, rd;
    kiahk_add_days(2025, 1, 1, 10, &ry, &rm, &rd);
    KIAHK_ASSERT_EQ_INT(ry, 2025); KIAHK_ASSERT_EQ_INT(rm, 1); KIAHK_ASSERT_EQ_INT(rd, 11);

    kiahk_add_days(2025, 1, 1, -1, &ry, &rm, &rd);
    KIAHK_ASSERT_EQ_INT(ry, 2024); KIAHK_ASSERT_EQ_INT(rm, 12); KIAHK_ASSERT_EQ_INT(rd, 31);

    /* 2024 is a leap year. */
    kiahk_add_days(2024, 2, 28, 1, &ry, &rm, &rd);
    KIAHK_ASSERT_EQ_INT(ry, 2024); KIAHK_ASSERT_EQ_INT(rm, 2); KIAHK_ASSERT_EQ_INT(rd, 29);
}

static void test_gregorian_date_basic(int *failed) {
    kiahk_gregorian_date g;
    KIAHK_ASSERT_EQ_INT(kiahk_gregorian_date_init(&g, 2025, 1, 11), KIAHK_OK);
    KIAHK_ASSERT_EQ_INT(g.year, 2025);
    KIAHK_ASSERT_EQ_INT(g.month, 1);
    KIAHK_ASSERT_EQ_INT(g.day, 11);
}

static void test_gregorian_date_rejects_invalid(int *failed) {
    cJSON *arr = vec_array("invalid_gregorian_dates");
    cJSON *vec;
    cJSON_ArrayForEach(vec, arr) {
        kiahk_gregorian_date g;
        kiahk_error err = kiahk_gregorian_date_init(&g, ymd_year(vec), ymd_month(vec), ymd_day(vec));
        KIAHK_ASSERT_EQ_INT(err, KIAHK_ERR_INVALID_GREGORIAN_DATE);
    }
}

static void test_gregorian_date_to_coptic(int *failed) {
    kiahk_gregorian_date g;
    kiahk_coptic_date c;
    KIAHK_ASSERT_EQ_INT(kiahk_gregorian_date_init(&g, 2025, 1, 11), KIAHK_OK);
    KIAHK_ASSERT_EQ_INT(kiahk_gregorian_date_to_coptic(&g, &c), KIAHK_OK);
    KIAHK_ASSERT_EQ_INT(c.year, 1741);
    KIAHK_ASSERT_EQ_INT(c.month, 5);
    KIAHK_ASSERT_EQ_INT(c.day, 3);
}

static void test_coptic_date_basic(int *failed) {
    kiahk_coptic_date c;
    KIAHK_ASSERT_EQ_INT(kiahk_coptic_date_init(&c, 1741, 5, 3), KIAHK_OK);
    KIAHK_ASSERT_EQ_INT(c.year, 1741);
    KIAHK_ASSERT_EQ_INT(c.month, 5);
    KIAHK_ASSERT_EQ_INT(c.day, 3);
}

static void test_coptic_date_rejects_invalid(int *failed) {
    cJSON *arr = vec_array("invalid_coptic_dates");
    cJSON *vec;
    cJSON_ArrayForEach(vec, arr) {
        kiahk_coptic_date c;
        kiahk_error err = kiahk_coptic_date_init(&c, ymd_year(vec), ymd_month(vec), ymd_day(vec));
        KIAHK_ASSERT_EQ_INT(err, KIAHK_ERR_INVALID_COPTIC_DATE);
    }
}

static void test_coptic_date_to_gregorian(int *failed) {
    kiahk_coptic_date c;
    kiahk_gregorian_date g;
    KIAHK_ASSERT_EQ_INT(kiahk_coptic_date_init(&c, 1741, 5, 3), KIAHK_OK);
    KIAHK_ASSERT_EQ_INT(kiahk_coptic_date_to_gregorian(&c, &g), KIAHK_OK);
    KIAHK_ASSERT_EQ_INT(g.year, 2025);
    KIAHK_ASSERT_EQ_INT(g.month, 1);
    KIAHK_ASSERT_EQ_INT(g.day, 11);
}

static void test_feasts_data_parity(int *failed) {
    /* Verify KIAHK_FEASTS mirrors core/feasts.json by id/type/category in order. */
    char path[1024];
    snprintf(path, sizeof(path), "%s/feasts.json", KIAHK_CORE_DIR);
    char *json = read_file_to_string(path);
    KIAHK_ASSERT_TRUE(json != NULL);
    cJSON *arr = cJSON_Parse(json);
    free(json);
    KIAHK_ASSERT_TRUE(arr != NULL);

    size_t core_count = (size_t)cJSON_GetArraySize(arr);
    KIAHK_ASSERT_EQ_INT((int)KIAHK_FEASTS_COUNT, (int)core_count);

    for (size_t i = 0; i < core_count; i++) {
        cJSON *ref = cJSON_GetArrayItem(arr, (int)i);
        const kiahk_feast_record *f = &KIAHK_FEASTS[i];
        KIAHK_ASSERT_EQ_STR(f->id, cJSON_GetObjectItemCaseSensitive(ref, "id")->valuestring);
        KIAHK_ASSERT_EQ_STR(f->type, cJSON_GetObjectItemCaseSensitive(ref, "type")->valuestring);
        KIAHK_ASSERT_EQ_STR(f->category, cJSON_GetObjectItemCaseSensitive(ref, "category")->valuestring);
        cJSON *names = cJSON_GetObjectItemCaseSensitive(ref, "names");
        KIAHK_ASSERT_EQ_STR(f->names.en, cJSON_GetObjectItemCaseSensitive(names, "en")->valuestring);
        KIAHK_ASSERT_EQ_STR(f->names.ar, cJSON_GetObjectItemCaseSensitive(names, "ar")->valuestring);
    }
    cJSON_Delete(arr);
}

static void test_feast_by_id(int *failed) {
    const kiahk_feast_record *easter = NULL;
    KIAHK_ASSERT_EQ_INT(kiahk_feast_by_id("easter", &easter), KIAHK_OK);
    KIAHK_ASSERT_EQ_STR(easter->id, "easter");
    KIAHK_ASSERT_EQ_STR(easter->type, "moveable");

    const kiahk_feast_record *unknown = NULL;
    KIAHK_ASSERT_EQ_INT(kiahk_feast_by_id("not_a_real_feast", &unknown), KIAHK_ERR_UNKNOWN_FEAST);
}

static void test_feast_name_en_ar(int *failed) {
    const kiahk_feast_record *rec;
    KIAHK_ASSERT_EQ_INT(kiahk_feast_by_id("easter", &rec), KIAHK_OK);
    kiahk_gregorian_date g;
    KIAHK_ASSERT_EQ_INT(kiahk_gregorian_date_init(&g, 2025, 4, 20), KIAHK_OK);
    kiahk_feast feast = {
        rec->id, rec->type, rec->category, &rec->names, g
    };
    const char *name = NULL;
    KIAHK_ASSERT_EQ_INT(kiahk_feast_name(&feast, "en", &name), KIAHK_OK);
    KIAHK_ASSERT_EQ_STR(name, "Easter Sunday");
    KIAHK_ASSERT_EQ_INT(kiahk_feast_name(&feast, "ar", &name), KIAHK_OK);
    KIAHK_ASSERT_EQ_STR(name, "عيد القيامة المجيد");
}

static void test_feast_name_unknown_locale(int *failed) {
    const kiahk_feast_record *rec;
    KIAHK_ASSERT_EQ_INT(kiahk_feast_by_id("easter", &rec), KIAHK_OK);
    kiahk_gregorian_date g;
    kiahk_gregorian_date_init(&g, 2025, 4, 20);
    kiahk_feast feast = {
        rec->id, rec->type, rec->category, &rec->names, g
    };
    const char *name = NULL;
    KIAHK_ASSERT_EQ_INT(kiahk_feast_name(&feast, "fr", &name), KIAHK_ERR_UNSUPPORTED_LOCALE);
}

static void test_easter_date_vectors(int *failed) {
    cJSON *arr = vec_array("easter");
    cJSON *vec;
    cJSON_ArrayForEach(vec, arr) {
        int year = cJSON_GetObjectItemCaseSensitive(vec, "gregorian_year")->valueint;
        cJSON *d = cJSON_GetObjectItemCaseSensitive(vec, "date");
        kiahk_gregorian_date g;
        KIAHK_ASSERT_EQ_INT(kiahk_easter_date(year, &g), KIAHK_OK);
        KIAHK_ASSERT_EQ_INT(g.year, ymd_year(d));
        KIAHK_ASSERT_EQ_INT(g.month, ymd_month(d));
        KIAHK_ASSERT_EQ_INT(g.day, ymd_day(d));
    }
}

static void test_moveable_feast_vectors(int *failed) {
    cJSON *arr = vec_array("moveable_feasts");
    cJSON *vec;
    cJSON_ArrayForEach(vec, arr) {
        const char *id = cJSON_GetObjectItemCaseSensitive(vec, "feast_id")->valuestring;
        int year = cJSON_GetObjectItemCaseSensitive(vec, "gregorian_year")->valueint;
        cJSON *d = cJSON_GetObjectItemCaseSensitive(vec, "date");
        kiahk_feast feast;
        KIAHK_ASSERT_EQ_INT(kiahk_moveable_feast(id, year, &feast), KIAHK_OK);
        KIAHK_ASSERT_EQ_STR(feast.id, id);
        KIAHK_ASSERT_EQ_INT(feast.gregorian_date.year, ymd_year(d));
        KIAHK_ASSERT_EQ_INT(feast.gregorian_date.month, ymd_month(d));
        KIAHK_ASSERT_EQ_INT(feast.gregorian_date.day, ymd_day(d));
    }
}

static void test_year_feasts_non_empty_and_sorted(int *failed) {
    kiahk_feast buf[32];
    size_t count = 0;
    KIAHK_ASSERT_EQ_INT(kiahk_year_feasts(2025, buf, 32, &count), KIAHK_OK);
    KIAHK_ASSERT_TRUE(count > 0);
    for (size_t i = 1; i < count; i++) {
        kiahk_gregorian_date a = buf[i - 1].gregorian_date;
        kiahk_gregorian_date b = buf[i].gregorian_date;
        int ok = (a.year < b.year)
              || (a.year == b.year && a.month < b.month)
              || (a.year == b.year && a.month == b.month && a.day <= b.day);
        KIAHK_ASSERT_TRUE(ok);
    }
}

static void test_year_feasts_includes_easter(int *failed) {
    kiahk_feast buf[32];
    size_t count = 0;
    KIAHK_ASSERT_EQ_INT(kiahk_year_feasts(2025, buf, 32, &count), KIAHK_OK);
    int found = 0;
    for (size_t i = 0; i < count; i++) {
        if (strcmp(buf[i].id, "easter") == 0) {
            kiahk_gregorian_date d = buf[i].gregorian_date;
            KIAHK_ASSERT_EQ_INT(d.year, 2025);
            KIAHK_ASSERT_EQ_INT(d.month, 4);
            KIAHK_ASSERT_EQ_INT(d.day, 20);
            found = 1;
            break;
        }
    }
    KIAHK_ASSERT_TRUE(found);
}

static void test_year_feasts_buffer_too_small(int *failed) {
    kiahk_feast buf[2]; /* deliberately too small */
    size_t count = 0;
    KIAHK_ASSERT_EQ_INT(kiahk_year_feasts(2025, buf, 2, &count), KIAHK_ERR_BUFFER_TOO_SMALL);
    KIAHK_ASSERT_EQ_INT((int)count, (int)KIAHK_FEASTS_COUNT);
}

static void test_coptic_months_data_parity(int *failed) {
    /* Verify KIAHK_COPTIC_MONTHS mirrors core/coptic_months.json by month/en/ar in order. */
    char path[1024];
    snprintf(path, sizeof(path), "%s/coptic_months.json", KIAHK_CORE_DIR);
    char *json = read_file_to_string(path);
    KIAHK_ASSERT_TRUE(json != NULL);
    cJSON *arr = cJSON_Parse(json);
    free(json);
    KIAHK_ASSERT_TRUE(arr != NULL);

    size_t core_count = (size_t)cJSON_GetArraySize(arr);
    KIAHK_ASSERT_EQ_INT((int)KIAHK_COPTIC_MONTHS_COUNT, (int)core_count);

    for (size_t i = 0; i < core_count; i++) {
        cJSON *ref = cJSON_GetArrayItem(arr, (int)i);
        const kiahk_coptic_month_record *m = &KIAHK_COPTIC_MONTHS[i];
        KIAHK_ASSERT_EQ_INT(m->month, cJSON_GetObjectItemCaseSensitive(ref, "month")->valueint);
        cJSON *names = cJSON_GetObjectItemCaseSensitive(ref, "names");
        KIAHK_ASSERT_EQ_STR(m->names.en, cJSON_GetObjectItemCaseSensitive(names, "en")->valuestring);
        KIAHK_ASSERT_EQ_STR(m->names.ar, cJSON_GetObjectItemCaseSensitive(names, "ar")->valuestring);
    }
    cJSON_Delete(arr);
}

static void test_coptic_month_name_vectors(int *failed) {
    cJSON *arr = vec_array("coptic_month_names");
    cJSON *vec;
    cJSON_ArrayForEach(vec, arr) {
        int month = cJSON_GetObjectItemCaseSensitive(vec, "month")->valueint;
        const char *locale = cJSON_GetObjectItemCaseSensitive(vec, "locale")->valuestring;
        const char *expected = cJSON_GetObjectItemCaseSensitive(vec, "name")->valuestring;
        const char *got = NULL;
        KIAHK_ASSERT_EQ_INT(kiahk_coptic_month_name(month, locale, &got), KIAHK_OK);
        KIAHK_ASSERT_EQ_STR(got, expected);
    }
}

static void test_coptic_month_name_rejects_invalid_month(int *failed) {
    cJSON *arr = vec_array("invalid_coptic_months_for_name");
    cJSON *vec;
    cJSON_ArrayForEach(vec, arr) {
        int bad = vec->valueint;
        const char *got = NULL;
        KIAHK_ASSERT_EQ_INT(kiahk_coptic_month_name(bad, "en", &got),
                            KIAHK_ERR_INVALID_COPTIC_MONTH);
    }
}

static void test_coptic_month_name_rejects_unsupported_locale(int *failed) {
    cJSON *arr = vec_array("invalid_coptic_month_locales");
    cJSON *vec;
    cJSON_ArrayForEach(vec, arr) {
        int month = cJSON_GetObjectItemCaseSensitive(vec, "month")->valueint;
        const char *locale = cJSON_GetObjectItemCaseSensitive(vec, "locale")->valuestring;
        const char *got = NULL;
        KIAHK_ASSERT_EQ_INT(kiahk_coptic_month_name(month, locale, &got),
                            KIAHK_ERR_UNSUPPORTED_LOCALE);
    }
}

/* --- main ---------------------------------------------------------------- */

int main(void) {
    load_vectors();

    KIAHK_TEST_RUN(error_messages_are_non_null);
    KIAHK_TEST_RUN(error_messages_distinct);
    KIAHK_TEST_RUN(gregorian_to_jdn_known_values);
    KIAHK_TEST_RUN(jdn_round_trip);
    KIAHK_TEST_RUN(coptic_to_jdn_epoch);
    KIAHK_TEST_RUN(coptic_jdn_round_trip);
    KIAHK_TEST_RUN(gregorian_to_coptic_vectors);
    KIAHK_TEST_RUN(coptic_to_gregorian_vectors);
    KIAHK_TEST_RUN(compute_easter_vectors);
    KIAHK_TEST_RUN(add_days);
    KIAHK_TEST_RUN(gregorian_date_basic);
    KIAHK_TEST_RUN(gregorian_date_rejects_invalid);
    KIAHK_TEST_RUN(gregorian_date_to_coptic);
    KIAHK_TEST_RUN(coptic_date_basic);
    KIAHK_TEST_RUN(coptic_date_rejects_invalid);
    KIAHK_TEST_RUN(coptic_date_to_gregorian);
    KIAHK_TEST_RUN(feasts_data_parity);
    KIAHK_TEST_RUN(feast_by_id);
    KIAHK_TEST_RUN(feast_name_en_ar);
    KIAHK_TEST_RUN(feast_name_unknown_locale);
    KIAHK_TEST_RUN(easter_date_vectors);
    KIAHK_TEST_RUN(moveable_feast_vectors);
    KIAHK_TEST_RUN(year_feasts_non_empty_and_sorted);
    KIAHK_TEST_RUN(year_feasts_includes_easter);
    KIAHK_TEST_RUN(year_feasts_buffer_too_small);
    KIAHK_TEST_RUN(coptic_months_data_parity);
    KIAHK_TEST_RUN(coptic_month_name_vectors);
    KIAHK_TEST_RUN(coptic_month_name_rejects_invalid_month);
    KIAHK_TEST_RUN(coptic_month_name_rejects_unsupported_locale);

    cJSON_Delete(g_vectors);
    KIAHK_TEST_REPORT_AND_EXIT();
}
