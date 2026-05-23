"""Calendar conversion primitives for the Coptic (Alexandrian) calendar.

The Coptic calendar:
  - 12 months of 30 days, plus a 13th "little month" (Nasie) of 5 days
    (6 in leap years).
  - Leap rule: Coptic year Y is a leap year iff Y mod 4 == 3 (Julian rule).
  - Era: Anno Martyrum (AM), starting 29 August 284 CE (Julian) =
    11 September 284 CE (proleptic Gregorian) = JDN 1825030 (= 1 Tout 1 AM).

References:
  - Reingold & Dershowitz, "Calendrical Calculations" (3rd ed., 2008), §4.1.
  - Fourmilab/Meeus port in `convertdate` (src/convertdate/coptic.py).
  - Wikipedia: https://en.wikipedia.org/wiki/Coptic_calendar
"""
from __future__ import annotations

# JDN of 1 Tout, year 1 AM.
COPTIC_EPOCH = 1825030


def gregorian_to_jdn(year: int, month: int, day: int) -> int:
    """Gregorian date → Julian Day Number (Fliegel & Van Flandern)."""
    a = (14 - month) // 12
    y = year + 4800 - a
    m = month + 12 * a - 3
    return (
        day
        + (153 * m + 2) // 5
        + 365 * y
        + y // 4
        - y // 100
        + y // 400
        - 32045
    )


def jdn_to_gregorian(jdn: int) -> tuple[int, int, int]:
    """Julian Day Number → Gregorian (year, month, day)."""
    a = jdn + 32044
    b = (4 * a + 3) // 146097
    c = a - (146097 * b) // 4
    d = (4 * c + 3) // 1461
    e = c - (1461 * d) // 4
    m = (5 * e + 2) // 153
    day = e - (153 * m + 2) // 5 + 1
    month = m + 3 - 12 * (m // 10)
    year = 100 * b + d - 4800 + m // 10
    return year, month, day


def coptic_to_jdn(c_year: int, c_month: int, c_day: int) -> int:
    """Coptic date → Julian Day Number.

    Days before year `c_year` (within the AM era):
      365 * (c_year - 1) full years
      + one extra day for every Coptic leap year in [1, c_year - 1].
    The count of leap years in that range equals floor(c_year / 4).
    """
    return (
        COPTIC_EPOCH - 1
        + 365 * (c_year - 1)
        + c_year // 4
        + 30 * (c_month - 1)
        + c_day
    )


def jdn_to_coptic(jdn: int) -> tuple[int, int, int]:
    """Julian Day Number → Coptic (year, month, day).

    Let r = jdn - COPTIC_EPOCH (0 = 1 Tout 1 AM).
    Solve r = 365*(cYear-1) + floor(cYear/4) + dayOfYear, 0 <= dayOfYear <= 365.
    Closed form: cYear = floor((4*r + 1463) / 1461).
    """
    r = jdn - COPTIC_EPOCH
    c_year = (4 * r + 1463) // 1461
    day_of_year = r - 365 * (c_year - 1) - c_year // 4  # 0-indexed
    c_month = day_of_year // 30 + 1
    c_day = day_of_year - 30 * (c_month - 1) + 1
    return c_year, c_month, c_day


def gregorian_to_coptic(g_year: int, g_month: int, g_day: int) -> tuple[int, int, int]:
    """Gregorian → Coptic."""
    return jdn_to_coptic(gregorian_to_jdn(g_year, g_month, g_day))


def coptic_to_gregorian(c_year: int, c_month: int, c_day: int) -> tuple[int, int, int]:
    """Coptic → Gregorian."""
    return jdn_to_gregorian(coptic_to_jdn(c_year, c_month, c_day))


def compute_easter(gregorian_year: int) -> tuple[int, int, int]:
    """Coptic Easter (Meeus's Julian computus + 13-day Gregorian shift).

    The Meeus formula yields Easter in the Julian calendar; for any date
    in 1900-03-01..2100-02-28 the Julian-Gregorian offset is +13 days.
    """
    a = gregorian_year % 4
    b = gregorian_year % 7
    c = gregorian_year % 19
    d = (19 * c + 15) % 30
    e = (2 * a + 4 * b - d + 34) % 7
    f = (d + e + 114) // 31  # Julian-calendar month
    g = (d + e + 114) % 31 + 1  # Julian-calendar day
    jdn = gregorian_to_jdn(gregorian_year, f, g) + 13
    return jdn_to_gregorian(jdn)


def add_days(year: int, month: int, day: int, days: int) -> tuple[int, int, int]:
    """Add N days to a Gregorian date, return new (year, month, day)."""
    return jdn_to_gregorian(gregorian_to_jdn(year, month, day) + days)
