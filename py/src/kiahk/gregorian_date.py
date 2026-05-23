"""GregorianDate value type with validating constructor and native-date interop."""
from __future__ import annotations

import datetime as _dt
from dataclasses import dataclass

from kiahk.errors import InvalidGregorianDateError

_DAYS_IN_MONTH = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)


def _is_leap(year: int) -> bool:
    return year % 4 == 0 and (year % 100 != 0 or year % 400 == 0)


def _validate(year: int, month: int, day: int) -> None:
    if not 1 <= month <= 12:
        raise InvalidGregorianDateError(f"month must be 1..12, got {month}")
    max_day = _DAYS_IN_MONTH[month - 1]
    if month == 2 and _is_leap(year):
        max_day = 29
    if not 1 <= day <= max_day:
        raise InvalidGregorianDateError(
            f"day must be 1..{max_day} for {year}-{month:02d}, got {day}"
        )


@dataclass(frozen=True)
class GregorianDate:
    year: int
    month: int
    day: int

    def __post_init__(self) -> None:
        _validate(self.year, self.month, self.day)

    def to_coptic(self) -> "CopticDate":  # noqa: F821
        from kiahk.algorithms import gregorian_to_coptic
        from kiahk.coptic_date import CopticDate

        return CopticDate(*gregorian_to_coptic(self.year, self.month, self.day))

    def to_native_date(self) -> _dt.date:
        return _dt.date(self.year, self.month, self.day)

    @classmethod
    def from_native_date(cls, native: _dt.date) -> "GregorianDate":
        return cls(native.year, native.month, native.day)
