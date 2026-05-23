"""Exception types raised by kiahk."""


class InvalidCopticDateError(ValueError):
    """Raised when a CopticDate is constructed with out-of-range month/day."""


class InvalidGregorianDateError(ValueError):
    """Raised when a GregorianDate is constructed with out-of-range month/day."""


class UnsupportedLocaleError(KeyError):
    """Raised when Feast.name is asked for a locale that has no translation."""
