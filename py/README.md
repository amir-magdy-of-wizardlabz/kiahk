<p align="center">
  <img src="https://raw.githubusercontent.com/amir-magdy-of-wizardlabz/kiahk/master/assets/kiahk.png" alt="Kiahk logo" width="160">
</p>

# kiahk (Python)

[![PyPI version](https://img.shields.io/pypi/v/kiahk.svg)](https://pypi.org/project/kiahk/)
[![PyPI downloads](https://img.shields.io/pypi/dm/kiahk.svg)](https://pypi.org/project/kiahk/)
[![Python versions](https://img.shields.io/pypi/pyversions/kiahk.svg)](https://pypi.org/project/kiahk/)
[![license](https://img.shields.io/pypi/l/kiahk.svg)](../LICENSE)

Coptic calendar arithmetic — date conversion, Easter, and feast days. Python port of [kiahk](https://github.com/amir-magdy-of-wizardlabz/kiahk). Identical results to all other ports against `core/test-vectors.json`.

**Package:** <https://pypi.org/project/kiahk/>

## Install

```bash
pip install kiahk
```

Or from this repo for development:

```bash
cd py
python3 -m venv .venv
.venv/bin/pip install -e ".[dev]"
```

## Quick start

```python
from kiahk import CopticDate, GregorianDate, CopticCalendar

# Convert Gregorian → Coptic
g = GregorianDate(2025, 1, 11)
c = g.to_coptic()
print(c.year, c.month, c.day)  # 1741 5 3

# Convert Coptic → Gregorian
c2 = CopticDate(1742, 1, 1)
g2 = c2.to_gregorian()
print(g2.year, g2.month, g2.day)  # 2025 9 11

# Coptic Easter for a Gregorian year
easter = CopticCalendar.easter_date(2025)
print(easter.year, easter.month, easter.day)  # 2025 4 20

# All major feasts for a Gregorian year, sorted by date
for feast in CopticCalendar.year_feasts(2025):
    g = feast.gregorian_date
    print(f"{g.year}-{g.month:02d}-{g.day:02d}  {feast.name('en')}")
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

The library exposes Coptic month names in `en` + `ar` via `CopticCalendar.month_name(month, locale)`. The full 13-entry table is also re-exported as `COPTIC_MONTHS` for callers that prefer raw data.

```python
from kiahk import GregorianDate, CopticCalendar

g = GregorianDate(2025, 4, 20)
c = g.to_coptic()
print(f"{c.day} {CopticCalendar.month_name(c.month, 'en')} {c.year} AM")
print(f"{c.day} {CopticCalendar.month_name(c.month, 'ar')} {c.year} للشهداء")
```

**Sample output:**

```
12 Parmouti 1741 AM
12 برمودة 1741 للشهداء
```

## API at a glance

| Type / method | Purpose |
| --- | --- |
| `GregorianDate(y, m, d)` | Value type; raises `InvalidGregorianDateError` on bad input |
| `GregorianDate.to_coptic()` → `CopticDate` | Convert |
| `GregorianDate.to_native_date()` / `from_native_date(date)` | Interop with `datetime.date` |
| `CopticDate(y, m, d)` | Value type; raises `InvalidCopticDateError` on bad input |
| `CopticDate.to_gregorian()` → `GregorianDate` | Convert |
| `Feast` | `id`, `type`, `category`, `gregorian_date`, `.name(locale)` |
| `Feast.name("fr")` | Raises `UnsupportedLocaleError` for unknown locale |
| `CopticCalendar.easter_date(year)` → `GregorianDate` | Coptic Easter |
| `CopticCalendar.moveable_feast(feast_id, year)` → `Feast` | One moveable feast |
| `CopticCalendar.year_feasts(year)` → `list[Feast]` | All feasts, sorted ascending |
| `CopticCalendar.month_name(month, locale)` → `str` | Coptic month name; raises `InvalidCopticMonthError` / `UnsupportedLocaleError` |
| `COPTIC_MONTHS` | 13-entry list of dicts (mirrors `core/coptic_months.json`) |

Supported locales for `Feast.name(...)` and `CopticCalendar.month_name(...)`: `en`, `ar`.

## Run tests

```bash
cd py
.venv/bin/pytest -v
```

## License

Licensed under the [MIT License](LICENSE).

Maintained by Amir Magdy at WizardLabz.
