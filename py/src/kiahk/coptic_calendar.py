"""CopticCalendar — static-method entry points for Easter and feast lookups."""
from __future__ import annotations

from kiahk.algorithms import add_days, compute_easter
from kiahk.feast import Feast
from kiahk.feasts_data import FEASTS, by_id
from kiahk.gregorian_date import GregorianDate


class CopticCalendar:
    @staticmethod
    def easter_date(gregorian_year: int) -> GregorianDate:
        return GregorianDate(*compute_easter(gregorian_year))

    @staticmethod
    def moveable_feast(feast_id: str, gregorian_year: int) -> Feast:
        record = by_id(feast_id)
        if record["type"] != "moveable":
            raise ValueError(f"feast {feast_id!r} is not moveable")
        easter = compute_easter(gregorian_year)
        date = add_days(easter[0], easter[1], easter[2], record["easter_offset"])
        return Feast(
            id=record["id"],
            type=record["type"],
            category=record["category"],
            names=record["names"],
            gregorian_date=GregorianDate(*date),
        )

    @staticmethod
    def _fixed_feast(record: dict, gregorian_year: int) -> Feast:
        """Resolve a fixed Coptic feast to its Gregorian date inside `gregorian_year`.

        A Coptic month/day falls in two possible Coptic years that overlap with
        the same Gregorian year (e.g. months at the start of the Coptic year
        belong to Coptic year ending in `gregorian_year`; later months belong
        to the Coptic year starting in `gregorian_year`). Try both candidates,
        keep the one whose Gregorian date is inside `gregorian_year`. Fall back
        to the earlier candidate if neither resolves cleanly (year boundaries).
        """
        from kiahk.algorithms import coptic_to_gregorian, gregorian_to_coptic

        c_year_a = gregorian_to_coptic(gregorian_year, 1, 1)[0]
        c_year_b = gregorian_to_coptic(gregorian_year, 12, 31)[0]
        candidates = []
        for cy in {c_year_a, c_year_b}:
            try:
                date = coptic_to_gregorian(cy, record["coptic_month"], record["coptic_day"])
            except Exception:
                continue
            if date[0] == gregorian_year:
                candidates.append(date)
        if not candidates:
            candidates.append(
                coptic_to_gregorian(c_year_a, record["coptic_month"], record["coptic_day"])
            )
        date = sorted(candidates)[0]
        return Feast(
            id=record["id"],
            type=record["type"],
            category=record["category"],
            names=record["names"],
            gregorian_date=GregorianDate(*date),
        )

    @staticmethod
    def year_feasts(gregorian_year: int) -> list[Feast]:
        out: list[Feast] = []
        for record in FEASTS:
            if record["type"] == "fixed":
                out.append(CopticCalendar._fixed_feast(record, gregorian_year))
            else:
                out.append(CopticCalendar.moveable_feast(record["id"], gregorian_year))
        out.sort(
            key=lambda f: (
                f.gregorian_date.year,
                f.gregorian_date.month,
                f.gregorian_date.day,
            )
        )
        return out
