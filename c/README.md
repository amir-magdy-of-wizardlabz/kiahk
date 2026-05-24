<p align="center">
  <img src="https://raw.githubusercontent.com/amir-magdy-of-wizardlabz/kiahk/master/assets/kiahk.png" alt="Kiahk logo" width="160">
</p>

# kiahk (C)

[![GitHub release](https://img.shields.io/github/v/release/amir-magdy-of-wizardlabz/kiahk?label=release)](https://github.com/amir-magdy-of-wizardlabz/kiahk/releases/latest)
[![C standard](https://img.shields.io/badge/C-99-blue.svg)](https://en.cppreference.com/w/c)
[![license](https://img.shields.io/github/license/amir-magdy-of-wizardlabz/kiahk.svg)](../LICENSE)

Coptic calendar arithmetic — date conversion, Easter, and feast days. C99 port of [kiahk](https://github.com/amir-magdy-of-wizardlabz/kiahk). Identical results to all other ports against `core/test-vectors.json`.

**Releases:** <https://github.com/amir-magdy-of-wizardlabz/kiahk/releases> — each tagged release attaches `kiahk-c-vX.Y.Z.tar.gz` (C source tree + canonical spec, ready to drop into your build).

## Install

There's no central C package registry. Three options, in increasing order of pinning strictness:

**1. Download a release tarball** (recommended for vendoring):

```bash
curl -L -o kiahk-c.tar.gz \
  https://github.com/amir-magdy-of-wizardlabz/kiahk/releases/latest/download/kiahk-c-v0.1.4.tar.gz
tar xzf kiahk-c.tar.gz
```

Then add it as a CMake subproject:

```cmake
add_subdirectory(third_party/kiahk-c-v0.1.4)
target_link_libraries(your_target PRIVATE kiahk)
```

**2. Git submodule** (track upstream `master`):

```bash
git submodule add https://github.com/amir-magdy-of-wizardlabz/kiahk.git third_party/kiahk
```

```cmake
add_subdirectory(third_party/kiahk/c)
target_link_libraries(your_target PRIVATE kiahk)
```

**3. Build from this repo** (for development):

```bash
cd c
cmake -S . -B build
cmake --build build
ctest --test-dir build
```

## Quick start

```c
#include <stdio.h>
#include <kiahk.h>

int main(void) {
    /* Convert Gregorian → Coptic */
    kiahk_gregorian_date g;
    if (kiahk_gregorian_date_init(&g, 2025, 1, 11) != KIAHK_OK) return 1;

    kiahk_coptic_date c;
    kiahk_gregorian_date_to_coptic(&g, &c);
    printf("%d %d %d\n", c.year, c.month, c.day);  /* 1741 5 3 */

    /* Coptic → Gregorian */
    kiahk_coptic_date c2;
    kiahk_coptic_date_init(&c2, 1742, 1, 1);
    kiahk_gregorian_date g2;
    kiahk_coptic_date_to_gregorian(&c2, &g2);
    printf("%d %d %d\n", g2.year, g2.month, g2.day);  /* 2025 9 11 */

    /* Coptic Easter */
    kiahk_gregorian_date easter;
    kiahk_easter_date(2025, &easter);
    printf("%d %d %d\n", easter.year, easter.month, easter.day);  /* 2025 4 20 */

    /* All major feasts for a Gregorian year, sorted by date */
    kiahk_feast feasts[KIAHK_FEASTS_COUNT];
    size_t count = 0;
    kiahk_year_feasts(2025, feasts, KIAHK_FEASTS_COUNT, &count);
    for (size_t i = 0; i < count; i++) {
        const char *name = NULL;
        kiahk_feast_name(&feasts[i], "en", &name);
        printf("%04d-%02d-%02d  %s\n",
               feasts[i].gregorian_date.year,
               feasts[i].gregorian_date.month,
               feasts[i].gregorian_date.day,
               name);
    }
    return 0;
}
```

**Sample output:**

```
1741 5 3
2025 9 11
2025 4 20
2025-01-07  Nativity of Christ
2025-01-19  Epiphany (Theophany)
2025-02-10  Nineveh Fast
2025-02-24  Great Lent (start)
2025-04-07  Annunciation
2025-04-13  Palm Sunday
2025-04-20  Easter Sunday
2025-05-29  Ascension
2025-06-08  Pentecost
2025-08-22  Assumption of Mary
2025-09-27  Feast of the Cross
```

## Render a date in English and Arabic

The library exposes Coptic month names in `en` + `ar` via `kiahk_coptic_month_name(month, locale, &out)`. The full 13-entry table is also re-exported as the extern `KIAHK_COPTIC_MONTHS[]` (length `KIAHK_COPTIC_MONTHS_COUNT`) for callers that prefer raw data.

```c
#include <stdio.h>
#include <kiahk.h>

int main(void) {
    kiahk_gregorian_date g;
    kiahk_gregorian_date_init(&g, 2025, 4, 20);
    kiahk_coptic_date c;
    kiahk_gregorian_date_to_coptic(&g, &c);
    const char *en = NULL, *ar = NULL;
    kiahk_coptic_month_name(c.month, "en", &en);
    kiahk_coptic_month_name(c.month, "ar", &ar);
    printf("%d %s %d AM\n",      c.day, en, c.year);
    printf("%d %s %d للشهداء\n", c.day, ar, c.year);
    return 0;
}
```

**Sample output:**

```
12 Parmouti 1741 AM
12 برمودة 1741 للشهداء
```

## API at a glance

| Function | Purpose |
| --- | --- |
| `kiahk_gregorian_date_init(*out, y, m, d)` | Validating init; returns `KIAHK_ERR_INVALID_GREGORIAN_DATE` on bad input |
| `kiahk_gregorian_date_to_coptic(*g, *out)` | Convert |
| `kiahk_coptic_date_init(*out, y, m, d)` | Validating init; returns `KIAHK_ERR_INVALID_COPTIC_DATE` on bad input |
| `kiahk_coptic_date_to_gregorian(*c, *out)` | Convert |
| `kiahk_feast_name(*f, locale, *out)` | Localized name; unknown locale returns `KIAHK_ERR_UNSUPPORTED_LOCALE` |
| `kiahk_easter_date(year, *out)` | Coptic Easter on the Gregorian calendar |
| `kiahk_moveable_feast(id, year, *out)` | One moveable feast |
| `kiahk_year_feasts(year, buf, cap, *count)` | All feasts in the year, sorted ascending |
| `kiahk_coptic_month_name(month, locale, *out)` | Coptic month name; returns `KIAHK_ERR_INVALID_COPTIC_MONTH` / `KIAHK_ERR_UNSUPPORTED_LOCALE` |
| `KIAHK_COPTIC_MONTHS[]` + `KIAHK_COPTIC_MONTHS_COUNT` | 13-entry table (mirrors `core/coptic_months.json`) |

Supported locales for `kiahk_feast_name` and `kiahk_coptic_month_name`: `"en"`, `"ar"`.

**Algorithm primitives** are also public: `kiahk_gregorian_to_jdn`, `kiahk_jdn_to_gregorian`, `kiahk_coptic_to_jdn`, `kiahk_jdn_to_coptic`, `kiahk_gregorian_to_coptic`, `kiahk_coptic_to_gregorian`, `kiahk_compute_easter`, `kiahk_add_days`.

**Error pattern** — every fallible function returns a `kiahk_error` enum value (`KIAHK_OK` = 0). Use `kiahk_error_message(err)` for a human-readable string.

## Run tests

```bash
cd c
cmake -S . -B build
cmake --build build
ctest --test-dir build --output-on-failure
```

## License

Licensed under the [MIT License](LICENSE).

Maintained by Amir Magdy at WizardLabz.
