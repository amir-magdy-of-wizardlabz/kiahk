/*
 * Minimal hand-rolled test runner.
 *
 * Each test is a `static void test_<name>(int *failed)` function. The
 * KIAHK_TEST_RUN(name) macro invokes it and prints PASS/FAIL. main()
 * calls every test and returns non-zero if any failed.
 *
 * Assertion macros set *failed and `return` from the current test on
 * failure — they don't abort the runner, so all tests get a chance.
 */
#ifndef KIAHK_TEST_RUNNER_H
#define KIAHK_TEST_RUNNER_H

#include <stdio.h>
#include <string.h>

static int g_total = 0;
static int g_passed = 0;
static int g_failed = 0;

#define KIAHK_TEST_RUN(name) \
    do { \
        int _failed = 0; \
        g_total++; \
        test_##name(&_failed); \
        if (_failed) { \
            g_failed++; \
            fprintf(stderr, "[FAIL] %s\n", #name); \
        } else { \
            g_passed++; \
            printf("[ OK ] %s\n", #name); \
        } \
    } while (0)

#define KIAHK_ASSERT_EQ_INT(actual, expected) \
    do { \
        int _a = (int)(actual); int _e = (int)(expected); \
        if (_a != _e) { \
            fprintf(stderr, "  %s:%d: expected %d, got %d\n", __FILE__, __LINE__, _e, _a); \
            *failed = 1; \
            return; \
        } \
    } while (0)

#define KIAHK_ASSERT_EQ_STR(actual, expected) \
    do { \
        const char *_a = (actual); const char *_e = (expected); \
        if (_a == NULL || _e == NULL || strcmp(_a, _e) != 0) { \
            fprintf(stderr, "  %s:%d: expected \"%s\", got \"%s\"\n", __FILE__, __LINE__, \
                _e ? _e : "(null)", _a ? _a : "(null)"); \
            *failed = 1; \
            return; \
        } \
    } while (0)

#define KIAHK_ASSERT_TRUE(cond) \
    do { \
        if (!(cond)) { \
            fprintf(stderr, "  %s:%d: expected true: %s\n", __FILE__, __LINE__, #cond); \
            *failed = 1; \
            return; \
        } \
    } while (0)

#define KIAHK_TEST_REPORT_AND_EXIT() \
    do { \
        printf("\n--- %d tests, %d passed, %d failed ---\n", g_total, g_passed, g_failed); \
        return g_failed == 0 ? 0 : 1; \
    } while (0)

#endif /* KIAHK_TEST_RUNNER_H */
