namespace Kiahk;

/// <summary>Low-level calendar conversion primitives. No validation; pure functions.</summary>
public static class Algorithms
{
    /// <summary>JDN of 1 Tout, year 1 AM (Coptic epoch).</summary>
    internal const int CopticEpoch = 1_825_030;

    /// <summary>Gregorian date → Julian Day Number (Fliegel &amp; Van Flandern).</summary>
    public static int GregorianToJdn(int year, int month, int day)
    {
        int a = (14 - month) / 12;
        int y = year + 4800 - a;
        int m = month + 12 * a - 3;
        return day
            + (153 * m + 2) / 5
            + 365 * y
            + y / 4
            - y / 100
            + y / 400
            - 32045;
    }

    /// <summary>Julian Day Number → Gregorian (year, month, day).</summary>
    public static (int Year, int Month, int Day) JdnToGregorian(int jdn)
    {
        int a = jdn + 32044;
        int b = (4 * a + 3) / 146097;
        int c = a - (146097 * b) / 4;
        int d = (4 * c + 3) / 1461;
        int e = c - (1461 * d) / 4;
        int m = (5 * e + 2) / 153;
        int day = e - (153 * m + 2) / 5 + 1;
        int month = m + 3 - 12 * (m / 10);
        int year = 100 * b + d - 4800 + m / 10;
        return (year, month, day);
    }

    /// <summary>Coptic date → Julian Day Number.</summary>
    /// <remarks>
    /// Days before Coptic year <paramref name="year"/> (within the AM era):
    ///   365*(year-1) full years + one extra day per Coptic leap year in [1, year-1].
    /// Leap rule: Y mod 4 == 3; count of leaps in [1, year-1] = year / 4.
    /// </remarks>
    public static int CopticToJdn(int year, int month, int day)
    {
        return CopticEpoch
            - 1
            + 365 * (year - 1)
            + year / 4
            + 30 * (month - 1)
            + day;
    }

    /// <summary>Julian Day Number → Coptic (year, month, day).</summary>
    /// <remarks>
    /// Let r = jdn - CopticEpoch (0 = 1 Tout 1 AM). Solve
    ///   r = 365*(year-1) + floor(year/4) + dayOfYear, 0 &lt;= dayOfYear &lt;= 365.
    /// Closed form: year = (4*r + 1463) / 1461.
    /// </remarks>
    public static (int Year, int Month, int Day) JdnToCoptic(int jdn)
    {
        int r = jdn - CopticEpoch;
        int year = (4 * r + 1463) / 1461;
        int dayOfYear = r - 365 * (year - 1) - year / 4;
        int month = dayOfYear / 30 + 1;
        int day = dayOfYear - 30 * (month - 1) + 1;
        return (year, month, day);
    }

    /// <summary>Gregorian → Coptic.</summary>
    public static (int Year, int Month, int Day) GregorianToCoptic(int year, int month, int day)
        => JdnToCoptic(GregorianToJdn(year, month, day));

    /// <summary>Coptic → Gregorian.</summary>
    public static (int Year, int Month, int Day) CopticToGregorian(int year, int month, int day)
        => JdnToGregorian(CopticToJdn(year, month, day));

    /// <summary>
    /// Coptic / Orthodox Easter (Meeus's Julian computus + 13-day Julian→Gregorian shift).
    /// Valid for any date in 1900-03-01..2100-02-28.
    /// </summary>
    public static (int Year, int Month, int Day) ComputeEaster(int gregorianYear)
    {
        int a = gregorianYear % 4;
        int b = gregorianYear % 7;
        int c = gregorianYear % 19;
        int d = (19 * c + 15) % 30;
        int e = (2 * a + 4 * b - d + 34) % 7;
        int f = (d + e + 114) / 31;
        int g = (d + e + 114) % 31 + 1;
        int jdn = GregorianToJdn(gregorianYear, f, g) + 13;
        return JdnToGregorian(jdn);
    }

    /// <summary>Add <paramref name="days"/> to a Gregorian date and return the new date.</summary>
    public static (int Year, int Month, int Day) AddDays(int year, int month, int day, int days)
        => JdnToGregorian(GregorianToJdn(year, month, day) + days);
}
