"""Kiahk Python port — all tests in one module, parametrized over core/test-vectors.json."""
from __future__ import annotations

import json
from pathlib import Path

import pytest

VECTORS_PATH = Path(__file__).resolve().parent.parent.parent / "core" / "test-vectors.json"
VECTORS = json.loads(VECTORS_PATH.read_text(encoding="utf-8"))


# ---- error class smoke tests -------------------------------------------------


def test_error_classes_exist_and_subclass_exception():
    from kiahk.errors import (
        InvalidCopticDateError,
        InvalidGregorianDateError,
        UnsupportedLocaleError,
    )

    assert issubclass(InvalidCopticDateError, Exception)
    assert issubclass(InvalidGregorianDateError, Exception)
    assert issubclass(UnsupportedLocaleError, Exception)


# ---- algorithms: gregorian_to_jdn -------------------------------------------


def test_gregorian_to_jdn_known_values():
    from kiahk.algorithms import gregorian_to_jdn

    # 2000-01-01 → JDN 2451545
    assert gregorian_to_jdn(2000, 1, 1) == 2451545
    # 1900-01-01 → JDN 2415021
    assert gregorian_to_jdn(1900, 1, 1) == 2415021
    # 2025-01-11 → JDN 2460687
    assert gregorian_to_jdn(2025, 1, 11) == 2460687


# ---- algorithms: jdn_to_gregorian + round trip ------------------------------


@pytest.mark.parametrize(
    "y,m,d",
    [(2000, 1, 1), (1900, 1, 1), (2025, 1, 11), (2024, 12, 25), (2025, 9, 11)],
)
def test_jdn_round_trip(y, m, d):
    from kiahk.algorithms import gregorian_to_jdn, jdn_to_gregorian

    assert jdn_to_gregorian(gregorian_to_jdn(y, m, d)) == (y, m, d)


# ---- algorithms: gregorian_to_coptic ----------------------------------------


@pytest.mark.parametrize("vec", VECTORS["gregorian_to_coptic"])
def test_gregorian_to_coptic_vectors(vec):
    from kiahk.algorithms import gregorian_to_coptic

    g, c = vec["gregorian"], vec["coptic"]
    assert gregorian_to_coptic(g["year"], g["month"], g["day"]) == (
        c["year"],
        c["month"],
        c["day"],
    )


# ---- algorithms: coptic_to_gregorian ----------------------------------------


@pytest.mark.parametrize("vec", VECTORS["coptic_to_gregorian"])
def test_coptic_to_gregorian_vectors(vec):
    from kiahk.algorithms import coptic_to_gregorian

    c, g = vec["coptic"], vec["gregorian"]
    assert coptic_to_gregorian(c["year"], c["month"], c["day"]) == (
        g["year"],
        g["month"],
        g["day"],
    )


# ---- algorithms: compute_easter ---------------------------------------------


@pytest.mark.parametrize("vec", VECTORS["easter"])
def test_compute_easter_vectors(vec):
    from kiahk.algorithms import compute_easter

    d = vec["date"]
    assert compute_easter(vec["gregorian_year"]) == (d["year"], d["month"], d["day"])


# ---- algorithms: add_days ---------------------------------------------------


def test_add_days_known_offsets():
    from kiahk.algorithms import add_days

    assert add_days(2025, 1, 1, 10) == (2025, 1, 11)
    assert add_days(2025, 1, 1, -1) == (2024, 12, 31)
    assert add_days(2024, 2, 28, 1) == (2024, 2, 29)  # leap year


# ---- algorithms: coptic_to_jdn / jdn_to_coptic round trip --------------------


@pytest.mark.parametrize("vec", VECTORS["gregorian_to_coptic"])
def test_coptic_jdn_round_trip(vec):
    """Every Coptic vector round-trips through JDN."""
    from kiahk.algorithms import coptic_to_jdn, jdn_to_coptic

    c = vec["coptic"]
    jdn = coptic_to_jdn(c["year"], c["month"], c["day"])
    assert jdn_to_coptic(jdn) == (c["year"], c["month"], c["day"])


def test_coptic_to_jdn_known_value():
    """1 Tout 1 AM is JDN 1825030 (Coptic epoch)."""
    from kiahk.algorithms import coptic_to_jdn

    assert coptic_to_jdn(1, 1, 1) == 1825030


# ---- GregorianDate ----------------------------------------------------------


def test_gregorian_date_basic_construction():
    from kiahk.gregorian_date import GregorianDate

    g = GregorianDate(2025, 1, 11)
    assert (g.year, g.month, g.day) == (2025, 1, 11)


@pytest.mark.parametrize("bad", VECTORS["invalid_gregorian_dates"])
def test_gregorian_date_rejects_invalid(bad):
    from kiahk.errors import InvalidGregorianDateError
    from kiahk.gregorian_date import GregorianDate

    with pytest.raises(InvalidGregorianDateError):
        GregorianDate(bad["year"], bad["month"], bad["day"])


def test_gregorian_date_to_native_date():
    import datetime as _dt
    from kiahk.gregorian_date import GregorianDate

    g = GregorianDate(2025, 1, 11)
    native = g.to_native_date()
    assert native == _dt.date(2025, 1, 11)


def test_gregorian_date_from_native_date():
    import datetime as _dt
    from kiahk.gregorian_date import GregorianDate

    g = GregorianDate.from_native_date(_dt.date(2025, 1, 11))
    assert (g.year, g.month, g.day) == (2025, 1, 11)


# ---- CopticDate -------------------------------------------------------------


def test_coptic_date_basic_construction():
    from kiahk.coptic_date import CopticDate

    c = CopticDate(1741, 5, 3)
    assert (c.year, c.month, c.day) == (1741, 5, 3)


@pytest.mark.parametrize("bad", VECTORS["invalid_coptic_dates"])
def test_coptic_date_rejects_invalid(bad):
    from kiahk.coptic_date import CopticDate
    from kiahk.errors import InvalidCopticDateError

    with pytest.raises(InvalidCopticDateError):
        CopticDate(bad["year"], bad["month"], bad["day"])


def test_coptic_date_to_gregorian_round_trip():
    from kiahk.coptic_date import CopticDate

    c = CopticDate(1741, 5, 3)
    g = c.to_gregorian()
    assert (g.year, g.month, g.day) == (2025, 1, 11)


def test_gregorian_to_coptic_round_trip_via_instance():
    from kiahk.gregorian_date import GregorianDate

    g = GregorianDate(2025, 1, 11)
    c = g.to_coptic()
    assert (c.year, c.month, c.day) == (1741, 5, 3)


# ---- feasts_data ------------------------------------------------------------


def test_feasts_data_matches_core_feasts_json():
    """feasts_data.py must be a structural mirror of core/feasts.json."""
    from kiahk.feasts_data import FEASTS

    core_feasts = json.loads(
        (VECTORS_PATH.parent / "feasts.json").read_text(encoding="utf-8")
    )
    assert [f["id"] for f in FEASTS] == [f["id"] for f in core_feasts]
    for f, ref in zip(FEASTS, core_feasts):
        assert f == ref


# ---- Feast ------------------------------------------------------------------


def test_feast_basic_fields_and_name_en_ar():
    from kiahk.feast import Feast
    from kiahk.feasts_data import by_id
    from kiahk.gregorian_date import GregorianDate

    feast = Feast(
        id="easter",
        type="moveable",
        category="major",
        names=by_id("easter")["names"],
        gregorian_date=GregorianDate(2025, 4, 20),
    )
    assert feast.id == "easter"
    assert feast.type == "moveable"
    assert feast.category == "major"
    assert feast.name("en") == "Easter Sunday"
    assert feast.name("ar") == "عيد القيامة المجيد"


def test_feast_name_unknown_locale_raises():
    from kiahk.errors import UnsupportedLocaleError
    from kiahk.feast import Feast
    from kiahk.feasts_data import by_id
    from kiahk.gregorian_date import GregorianDate

    feast = Feast(
        id="easter",
        type="moveable",
        category="major",
        names=by_id("easter")["names"],
        gregorian_date=GregorianDate(2025, 4, 20),
    )
    with pytest.raises(UnsupportedLocaleError):
        feast.name("fr")


# ---- CopticCalendar.easter_date ---------------------------------------------


@pytest.mark.parametrize("vec", VECTORS["easter"])
def test_coptic_calendar_easter_date_vectors(vec):
    from kiahk.coptic_calendar import CopticCalendar

    d = vec["date"]
    g = CopticCalendar.easter_date(vec["gregorian_year"])
    assert (g.year, g.month, g.day) == (d["year"], d["month"], d["day"])


# ---- CopticCalendar.moveable_feast ------------------------------------------


@pytest.mark.parametrize("vec", VECTORS["moveable_feasts"])
def test_coptic_calendar_moveable_feast_vectors(vec):
    from kiahk.coptic_calendar import CopticCalendar

    d = vec["date"]
    feast = CopticCalendar.moveable_feast(vec["feast_id"], vec["gregorian_year"])
    g = feast.gregorian_date
    assert (g.year, g.month, g.day) == (d["year"], d["month"], d["day"])
    assert feast.id == vec["feast_id"]


# ---- CopticCalendar.year_feasts ---------------------------------------------


def test_year_feasts_non_empty_and_sorted():
    from kiahk.coptic_calendar import CopticCalendar

    feasts = CopticCalendar.year_feasts(2025)
    assert len(feasts) > 0
    for prev, nxt in zip(feasts, feasts[1:]):
        a, b = prev.gregorian_date, nxt.gregorian_date
        assert (a.year, a.month, a.day) <= (b.year, b.month, b.day)


def test_year_feasts_includes_easter_with_correct_date():
    from kiahk.coptic_calendar import CopticCalendar

    feasts = CopticCalendar.year_feasts(2025)
    easter = next(f for f in feasts if f.id == "easter")
    assert (easter.gregorian_date.year, easter.gregorian_date.month, easter.gregorian_date.day) == (
        2025,
        4,
        20,
    )


# ---- public API surface -----------------------------------------------------


def test_public_api_surface():
    import kiahk

    expected = {
        "CopticDate",
        "GregorianDate",
        "Feast",
        "CopticCalendar",
        "COPTIC_MONTHS",
        "InvalidCopticDateError",
        "InvalidCopticMonthError",
        "InvalidGregorianDateError",
        "UnsupportedLocaleError",
    }
    assert expected.issubset(set(dir(kiahk)))


# ---- coptic_months_data ----------------------------------------------------


def test_coptic_months_data_matches_core_coptic_months_json():
    """coptic_months_data.py must be a structural mirror of core/coptic_months.json."""
    from kiahk.coptic_months_data import COPTIC_MONTHS

    core_months = json.loads(
        (VECTORS_PATH.parent / "coptic_months.json").read_text(encoding="utf-8")
    )
    assert COPTIC_MONTHS == core_months


# ---- CopticCalendar.month_name ---------------------------------------------


@pytest.mark.parametrize("vec", VECTORS["coptic_month_names"])
def test_coptic_calendar_month_name_vectors(vec):
    from kiahk.coptic_calendar import CopticCalendar

    assert CopticCalendar.month_name(vec["month"], vec["locale"]) == vec["name"]


@pytest.mark.parametrize("bad_month", VECTORS["invalid_coptic_months_for_name"])
def test_coptic_calendar_month_name_rejects_invalid_month(bad_month):
    from kiahk.coptic_calendar import CopticCalendar
    from kiahk.errors import InvalidCopticMonthError

    with pytest.raises(InvalidCopticMonthError):
        CopticCalendar.month_name(bad_month, "en")


@pytest.mark.parametrize("vec", VECTORS["invalid_coptic_month_locales"])
def test_coptic_calendar_month_name_rejects_unsupported_locale(vec):
    from kiahk.coptic_calendar import CopticCalendar
    from kiahk.errors import UnsupportedLocaleError

    with pytest.raises(UnsupportedLocaleError):
        CopticCalendar.month_name(vec["month"], vec["locale"])
