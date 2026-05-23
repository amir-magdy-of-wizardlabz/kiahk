"""CopticDate value type with validating constructor."""
from __future__ import annotations

from dataclasses import dataclass

from kiahk.errors import InvalidCopticDateError

# Coptic months 1..12 have 30 days. Month 13 (Nasie) has 5 days, or 6 in a
# leap year. Coptic leap year rule: Y mod 4 == 3 (Julian-style).


def _coptic_is_leap(c_year: int) -> bool:
    return c_year % 4 == 3


def _validate(year: int, month: int, day: int) -> None:
    if not 1 <= month <= 13:
        raise InvalidCopticDateError(f"coptic month must be 1..13, got {month}")
    if month <= 12:
        max_day = 30
    else:
        max_day = 6 if _coptic_is_leap(year) else 5
    if not 1 <= day <= max_day:
        raise InvalidCopticDateError(
            f"coptic day must be 1..{max_day} for year {year} month {month}, got {day}"
        )


@dataclass(frozen=True)
class CopticDate:
    year: int
    month: int
    day: int

    def __post_init__(self) -> None:
        _validate(self.year, self.month, self.day)

    def to_gregorian(self) -> "GregorianDate":  # noqa: F821
        from kiahk.algorithms import coptic_to_gregorian
        from kiahk.gregorian_date import GregorianDate

        return GregorianDate(*coptic_to_gregorian(self.year, self.month, self.day))
