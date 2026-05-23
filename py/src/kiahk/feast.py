"""Feast value type — id, type, category, gregorian_date, localized name lookup."""
from __future__ import annotations

from dataclasses import dataclass
from typing import Literal, Mapping

from kiahk.errors import UnsupportedLocaleError
from kiahk.gregorian_date import GregorianDate

FeastType = Literal["fixed", "moveable"]
FeastCategory = Literal["major", "minor"]


@dataclass(frozen=True)
class Feast:
    id: str
    type: FeastType
    category: FeastCategory
    names: Mapping[str, str]
    gregorian_date: GregorianDate

    def name(self, locale: str) -> str:
        try:
            return self.names[locale]
        except KeyError as e:
            raise UnsupportedLocaleError(
                f"feast {self.id!r} has no name for locale {locale!r}"
            ) from e
