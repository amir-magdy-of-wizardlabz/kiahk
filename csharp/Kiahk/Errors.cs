using System;

namespace Kiahk;

/// <summary>Thrown when a <see cref="CopticDate"/> is constructed with out-of-range month/day.</summary>
public sealed class InvalidCopticDateException : Exception
{
    public InvalidCopticDateException(string message) : base(message) { }
}

/// <summary>Thrown when a <see cref="GregorianDate"/> is constructed with out-of-range month/day.</summary>
public sealed class InvalidGregorianDateException : Exception
{
    public InvalidGregorianDateException(string message) : base(message) { }
}

/// <summary>Thrown when <see cref="Feast.Name"/> is asked for a locale with no translation.</summary>
public sealed class UnsupportedLocaleException : Exception
{
    public string FeastId { get; }
    public string Locale { get; }

    public UnsupportedLocaleException(string feastId, string locale)
        : base($"Kiahk: feast \"{feastId}\" has no name for locale \"{locale}\"")
    {
        FeastId = feastId;
        Locale = locale;
    }
}

/// <summary>Thrown when a Coptic month outside 1..13 is passed to a month-name lookup.</summary>
public sealed class InvalidCopticMonthException : Exception
{
    public int Month { get; }

    public InvalidCopticMonthException(int month)
        : base($"Kiahk: invalid coptic month {month} (expected 1..13)")
    {
        Month = month;
    }
}
