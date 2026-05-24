namespace Kiahk;

/// <summary>A calendar date on the Coptic (Anno Martyrum) calendar.</summary>
/// <remarks>
/// Coptic months 1..12 are 30 days each. Month 13 (Nasie) is 5 days, or 6 in a
/// leap year (Y mod 4 == 3, Julian-style).
/// </remarks>
public sealed record CopticDate
{
    public int Year { get; }
    public int Month { get; }
    public int Day { get; }

    private static bool IsCopticLeap(int y) => y % 4 == 3;

    /// <summary>Construct and validate. Throws <see cref="InvalidCopticDateException"/> on bad input.</summary>
    public CopticDate(int year, int month, int day)
    {
        if (month < 1 || month > 13)
        {
            throw new InvalidCopticDateException(
                $"coptic month must be 1..13, got {month}");
        }
        int maxDay = 30;
        if (month == 13)
        {
            maxDay = IsCopticLeap(year) ? 6 : 5;
        }
        if (day < 1 || day > maxDay)
        {
            throw new InvalidCopticDateException(
                $"coptic day must be 1..{maxDay} for year {year} month {month}, got {day}");
        }
        Year = year;
        Month = month;
        Day = day;
    }

    /// <summary>Convert this Coptic date to a Gregorian date.</summary>
    public GregorianDate ToGregorian()
    {
        var r = Algorithms.CopticToGregorian(Year, Month, Day);
        return new GregorianDate(r.Year, r.Month, r.Day);
    }
}

// Partial-class extension: adds GregorianDate.ToCoptic() here so GregorianDate.cs
// doesn't have a dependency on CopticDate.
public sealed partial record GregorianDate
{
    /// <summary>Convert this Gregorian date to a Coptic date.</summary>
    public CopticDate ToCoptic()
    {
        var r = Algorithms.GregorianToCoptic(Year, Month, Day);
        return new CopticDate(r.Year, r.Month, r.Day);
    }
}
