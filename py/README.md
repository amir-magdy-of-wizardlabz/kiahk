# kiahk (Python)

Coptic calendar arithmetic — date conversion, Easter, and feast days. Python port of [kiahk](https://github.com/amir-magdy-of-wizardlabz/kiahk). Identical results to all other ports against `core/test-vectors.json`.

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

Supported locales for `Feast.name(...)`: `en`, `ar`.

## Run tests

```bash
cd py
.venv/bin/pytest -v
```

## License

MIT
