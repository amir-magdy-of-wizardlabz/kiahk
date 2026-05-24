"""Exception types raised by kiahk."""


class InvalidCopticDateError(ValueError):
    """Raised when a CopticDate is constructed with out-of-range month/day."""


class InvalidGregorianDateError(ValueError):
    """Raised when a GregorianDate is constructed with out-of-range month/day."""


class UnsupportedLocaleError(KeyError):
    """Raised when Feast.name is asked for a locale that has no translation."""


class InvalidCopticMonthError(ValueError):
    """Raised when a Coptic month outside 1..13 is passed to a month-name lookup."""
