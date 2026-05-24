using System;

namespace Kiahk;

/// <summary>A calendar date on the proleptic Gregorian calendar.</summary>
/// <remarks>Immutable value type; constructor validates month/day for the given year.</remarks>
public sealed partial record GregorianDate
{
    public int Year { get; }
    public int Month { get; }
    public int Day { get; }

    private static readonly int[] DaysInMonth = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };

    private static bool IsLeap(int y) => y % 4 == 0 && (y % 100 != 0 || y % 400 == 0);

    /// <summary>Construct and validate. Throws <see cref="InvalidGregorianDateException"/> on bad input.</summary>
    public GregorianDate(int year, int month, int day)
    {
        if (month < 1 || month > 12)
        {
            throw new InvalidGregorianDateException(
                $"month must be 1..12, got {month}");
        }
        int maxDay = DaysInMonth[month - 1];
        if (month == 2 && IsLeap(year))
        {
            maxDay = 29;
        }
        if (day < 1 || day > maxDay)
        {
            throw new InvalidGregorianDateException(
                $"day must be 1..{maxDay} for {year}-{month:D2}, got {day}");
        }
        Year = year;
        Month = month;
        Day = day;
    }

    /// <summary>Return a <see cref="DateOnly"/> for this calendar date.</summary>
    public DateOnly ToDateOnly() => new DateOnly(Year, Month, Day);

    /// <summary>Construct from a <see cref="DateOnly"/>.</summary>
    public static GregorianDate FromDateOnly(DateOnly d) => new GregorianDate(d.Year, d.Month, d.Day);
}
