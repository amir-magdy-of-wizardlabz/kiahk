using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text.Json;
using System.Text.Json.Serialization;
using Kiahk;
using Xunit;

namespace Kiahk.Tests;

// ----------------------------------------------------------------------
// Shared test-vector loader.
//
// [CallerFilePath] resolves at compile time to this source file's path.
// From csharp/Kiahk.Tests/KiahkTests.cs we walk up two levels to reach
// the repo root, then into core/.
// ----------------------------------------------------------------------

internal static class Paths
{
    private static string CallerDir([CallerFilePath] string callerPath = "")
        => new FileInfo(callerPath).Directory!.FullName;

    public static string CoreDir
    {
        get
        {
            // CallerDir() → .../csharp/Kiahk.Tests
            var testsDir = new DirectoryInfo(CallerDir());
            return Path.Combine(testsDir.Parent!.Parent!.FullName, "core");
        }
    }
}

internal sealed record YMD(int Year, int Month, int Day);
internal sealed record GregCoptic(YMD Gregorian, YMD Coptic);
internal sealed record EasterVec(int Gregorian_Year, YMD Date);
internal sealed record MoveableVec(int Gregorian_Year, string Feast_Id, YMD Date);
internal sealed record MonthNameVec(int Month, string Locale, string Name);
internal sealed record MonthLocaleVec(int Month, string Locale);
internal sealed record Vectors(
    GregCoptic[] Gregorian_To_Coptic,
    GregCoptic[] Coptic_To_Gregorian,
    EasterVec[] Easter,
    MoveableVec[] Moveable_Feasts,
    YMD[] Invalid_Coptic_Dates,
    YMD[] Invalid_Gregorian_Dates,
    MonthNameVec[] Coptic_Month_Names,
    MonthLocaleVec[] Invalid_Coptic_Month_Locales,
    int[] Invalid_Coptic_Months_For_Name);

internal static class TestVectors
{
    public static readonly Vectors V = LoadVectors();

    private static Vectors LoadVectors()
    {
        var path = Path.Combine(Paths.CoreDir, "test-vectors.json");
        var json = File.ReadAllText(path);
        var opts = new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true,
        };
        return JsonSerializer.Deserialize<Vectors>(json, opts)!;
    }
}

// ----------------------------------------------------------------------
// Error classes
// ----------------------------------------------------------------------

public class ErrorsTests
{
    [Fact]
    public void InvalidCopticDateExceptionExtendsException()
    {
        var ex = new InvalidCopticDateException("bad");
        Assert.IsAssignableFrom<Exception>(ex);
        Assert.Equal("bad", ex.Message);
    }

    [Fact]
    public void InvalidGregorianDateExceptionExtendsException()
    {
        var ex = new InvalidGregorianDateException("bad");
        Assert.IsAssignableFrom<Exception>(ex);
    }

    [Fact]
    public void UnsupportedLocaleExceptionExtendsException()
    {
        var ex = new UnsupportedLocaleException("easter", "fr");
        Assert.IsAssignableFrom<Exception>(ex);
        Assert.Contains("easter", ex.Message);
        Assert.Contains("fr", ex.Message);
    }
}

// ----------------------------------------------------------------------
// Algorithms.GregorianToJdn
// ----------------------------------------------------------------------

public class GregorianToJdnTests
{
    [Theory]
    [InlineData(2000, 1, 1, 2451545)]
    [InlineData(1900, 1, 1, 2415021)]
    [InlineData(2025, 1, 11, 2460687)]
    public void KnownValues(int y, int m, int d, int expectedJdn)
    {
        Assert.Equal(expectedJdn, Algorithms.GregorianToJdn(y, m, d));
    }
}

public class JdnToGregorianTests
{
    public static readonly object[][] RoundTripData =
    {
        new object[] { 2000, 1, 1 },
        new object[] { 1900, 1, 1 },
        new object[] { 2025, 1, 11 },
        new object[] { 2024, 12, 25 },
        new object[] { 2025, 9, 11 },
    };

    [Theory]
    [MemberData(nameof(RoundTripData))]
    public void RoundTrip(int y, int m, int d)
    {
        int jdn = Algorithms.GregorianToJdn(y, m, d);
        var r = Algorithms.JdnToGregorian(jdn);
        Assert.Equal((y, m, d), (r.Year, r.Month, r.Day));
    }
}

public class CopticToJdnTests
{
    [Fact]
    public void EpochIs1825030()
    {
        Assert.Equal(1_825_030, Algorithms.CopticToJdn(1, 1, 1));
    }
}

public class JdnToCopticTests
{
    public static IEnumerable<object[]> CopticVectors() =>
        TestVectors.V.Gregorian_To_Coptic.Select(v => new object[] { v.Coptic.Year, v.Coptic.Month, v.Coptic.Day });

    [Theory]
    [MemberData(nameof(CopticVectors))]
    public void CopticRoundTrip(int cy, int cm, int cd)
    {
        int jdn = Algorithms.CopticToJdn(cy, cm, cd);
        var r = Algorithms.JdnToCoptic(jdn);
        Assert.Equal((cy, cm, cd), (r.Year, r.Month, r.Day));
    }
}

public class GregorianToCopticTests
{
    public static IEnumerable<object[]> Vectors() =>
        TestVectors.V.Gregorian_To_Coptic.Select(v => new object[]
        {
            v.Gregorian.Year, v.Gregorian.Month, v.Gregorian.Day,
            v.Coptic.Year, v.Coptic.Month, v.Coptic.Day,
        });

    [Theory]
    [MemberData(nameof(Vectors))]
    public void VectorMatch(int gy, int gm, int gd, int cy, int cm, int cd)
    {
        var r = Algorithms.GregorianToCoptic(gy, gm, gd);
        Assert.Equal((cy, cm, cd), (r.Year, r.Month, r.Day));
    }
}

public class CopticToGregorianTests
{
    public static IEnumerable<object[]> Vectors() =>
        TestVectors.V.Coptic_To_Gregorian.Select(v => new object[]
        {
            v.Coptic.Year, v.Coptic.Month, v.Coptic.Day,
            v.Gregorian.Year, v.Gregorian.Month, v.Gregorian.Day,
        });

    [Theory]
    [MemberData(nameof(Vectors))]
    public void VectorMatch(int cy, int cm, int cd, int gy, int gm, int gd)
    {
        var r = Algorithms.CopticToGregorian(cy, cm, cd);
        Assert.Equal((gy, gm, gd), (r.Year, r.Month, r.Day));
    }
}

public class ComputeEasterTests
{
    public static IEnumerable<object[]> Vectors() =>
        TestVectors.V.Easter.Select(v => new object[]
        {
            v.Gregorian_Year, v.Date.Year, v.Date.Month, v.Date.Day,
        });

    [Theory]
    [MemberData(nameof(Vectors))]
    public void EasterMatchesVectors(int year, int ey, int em, int ed)
    {
        var r = Algorithms.ComputeEaster(year);
        Assert.Equal((ey, em, ed), (r.Year, r.Month, r.Day));
    }
}

public class AddDaysTests
{
    [Theory]
    [InlineData(2025, 1, 1, 10, 2025, 1, 11)]
    [InlineData(2025, 1, 1, -1, 2024, 12, 31)]
    [InlineData(2024, 2, 28, 1, 2024, 2, 29)]
    public void KnownOffsets(int y, int m, int d, int n, int ey, int em, int ed)
    {
        var r = Algorithms.AddDays(y, m, d, n);
        Assert.Equal((ey, em, ed), (r.Year, r.Month, r.Day));
    }
}

// ----------------------------------------------------------------------
// GregorianDate
// ----------------------------------------------------------------------

public class GregorianDateTests
{
    [Fact]
    public void BasicConstruction()
    {
        var g = new GregorianDate(2025, 1, 11);
        Assert.Equal((2025, 1, 11), (g.Year, g.Month, g.Day));
    }

    public static IEnumerable<object[]> InvalidVectors() =>
        TestVectors.V.Invalid_Gregorian_Dates.Select(d => new object[] { d.Year, d.Month, d.Day });

    [Theory]
    [MemberData(nameof(InvalidVectors))]
    public void RejectsInvalidDates(int y, int m, int d)
    {
        Assert.Throws<InvalidGregorianDateException>(() => new GregorianDate(y, m, d));
    }

    [Fact]
    public void ToDateOnly()
    {
        var g = new GregorianDate(2025, 1, 11);
        var dt = g.ToDateOnly();
        Assert.Equal(new DateOnly(2025, 1, 11), dt);
    }

    [Fact]
    public void FromDateOnly()
    {
        var dt = new DateOnly(2025, 1, 11);
        var g = GregorianDate.FromDateOnly(dt);
        Assert.Equal((2025, 1, 11), (g.Year, g.Month, g.Day));
    }

    [Fact]
    public void Equality()
    {
        var a = new GregorianDate(2025, 1, 11);
        var b = new GregorianDate(2025, 1, 11);
        Assert.Equal(a, b);
        Assert.Equal(a.GetHashCode(), b.GetHashCode());
    }
}

public class CopticDateTests
{
    [Fact]
    public void BasicConstruction()
    {
        var c = new CopticDate(1741, 5, 3);
        Assert.Equal((1741, 5, 3), (c.Year, c.Month, c.Day));
    }

    public static IEnumerable<object[]> InvalidVectors() =>
        TestVectors.V.Invalid_Coptic_Dates.Select(d => new object[] { d.Year, d.Month, d.Day });

    [Theory]
    [MemberData(nameof(InvalidVectors))]
    public void RejectsInvalidDates(int y, int m, int d)
    {
        Assert.Throws<InvalidCopticDateException>(() => new CopticDate(y, m, d));
    }

    [Fact]
    public void ToGregorian()
    {
        var c = new CopticDate(1741, 5, 3);
        var g = c.ToGregorian();
        Assert.Equal((2025, 1, 11), (g.Year, g.Month, g.Day));
    }

    [Fact]
    public void GregorianDateToCopticInstance()
    {
        var g = new GregorianDate(2025, 1, 11);
        var c = g.ToCoptic();
        Assert.Equal((1741, 5, 3), (c.Year, c.Month, c.Day));
    }
}

// ----------------------------------------------------------------------
// FeastsData parity with core/feasts.json
// ----------------------------------------------------------------------

public class FeastsDataTests
{
    [Fact]
    public void MatchesCoreFeastsJson()
    {
        var path = Path.Combine(Paths.CoreDir, "feasts.json");
        var json = File.ReadAllText(path);
        using var doc = JsonDocument.Parse(json);
        var coreArr = doc.RootElement;

        Assert.Equal(coreArr.GetArrayLength(), FeastsData.Feasts.Count);

        int i = 0;
        foreach (var el in coreArr.EnumerateArray())
        {
            var f = FeastsData.Feasts[i];
            Assert.Equal(el.GetProperty("id").GetString(), f.Id);
            Assert.Equal(el.GetProperty("type").GetString(), f.Type);
            Assert.Equal(el.GetProperty("category").GetString(), f.Category);
            var names = el.GetProperty("names");
            Assert.Equal(names.GetProperty("en").GetString(), f.Names["en"]);
            Assert.Equal(names.GetProperty("ar").GetString(), f.Names["ar"]);
            i++;
        }
    }
}

public class FeastTests
{
    [Fact]
    public void BasicFieldsAndName()
    {
        var g = new GregorianDate(2025, 4, 20);
        var rec = FeastsData.FeastById("easter");
        var feast = new Feast(rec.Id, rec.Type, rec.Category, rec.Names, g);
        Assert.Equal("easter", feast.Id);
        Assert.Equal("moveable", feast.Type);
        Assert.Equal("major", feast.Category);
        Assert.Equal("Easter Sunday", feast.Name("en"));
        Assert.Equal("عيد القيامة المجيد", feast.Name("ar"));
    }

    [Fact]
    public void UnknownLocaleThrows()
    {
        var g = new GregorianDate(2025, 4, 20);
        var rec = FeastsData.FeastById("easter");
        var feast = new Feast(rec.Id, rec.Type, rec.Category, rec.Names, g);
        Assert.Throws<UnsupportedLocaleException>(() => feast.Name("fr"));
    }
}

public class CopticCalendarEasterDateTests
{
    public static IEnumerable<object[]> Vectors() =>
        TestVectors.V.Easter.Select(v => new object[]
        {
            v.Gregorian_Year, v.Date.Year, v.Date.Month, v.Date.Day,
        });

    [Theory]
    [MemberData(nameof(Vectors))]
    public void EasterMatchesVectors(int year, int ey, int em, int ed)
    {
        var g = CopticCalendar.EasterDate(year);
        Assert.Equal((ey, em, ed), (g.Year, g.Month, g.Day));
    }
}

public class CopticCalendarMoveableFeastTests
{
    public static IEnumerable<object[]> Vectors() =>
        TestVectors.V.Moveable_Feasts.Select(v => new object[]
        {
            v.Feast_Id, v.Gregorian_Year, v.Date.Year, v.Date.Month, v.Date.Day,
        });

    [Theory]
    [MemberData(nameof(Vectors))]
    public void MoveableFeastVectors(string id, int year, int ey, int em, int ed)
    {
        var feast = CopticCalendar.MoveableFeast(id, year);
        Assert.Equal(id, feast.Id);
        Assert.Equal((ey, em, ed), (feast.GregorianDate.Year, feast.GregorianDate.Month, feast.GregorianDate.Day));
    }
}

public class CopticCalendarYearFeastsTests
{
    [Fact]
    public void NonEmptyAndSorted()
    {
        var feasts = CopticCalendar.YearFeasts(2025);
        Assert.NotEmpty(feasts);
        for (int i = 1; i < feasts.Count; i++)
        {
            var a = feasts[i - 1].GregorianDate;
            var b = feasts[i].GregorianDate;
            Assert.True(LessOrEqual(a, b), $"feasts not sorted at {i}: {a} > {b}");
        }
    }

    [Fact]
    public void IncludesEasterOn20250420()
    {
        var feasts = CopticCalendar.YearFeasts(2025);
        var easter = feasts.First(f => f.Id == "easter");
        var g = easter.GregorianDate;
        Assert.Equal((2025, 4, 20), (g.Year, g.Month, g.Day));
    }

    private static bool LessOrEqual(GregorianDate a, GregorianDate b)
    {
        if (a.Year != b.Year) return a.Year < b.Year;
        if (a.Month != b.Month) return a.Month < b.Month;
        return a.Day <= b.Day;
    }
}

// ----------------------------------------------------------------------
// CopticMonthsData parity with core/coptic_months.json
// ----------------------------------------------------------------------

public class CopticMonthsDataTests
{
    [Fact]
    public void MatchesCoreCopticMonthsJson()
    {
        var path = Path.Combine(Paths.CoreDir, "coptic_months.json");
        var json = File.ReadAllText(path);
        using var doc = JsonDocument.Parse(json);
        var core = doc.RootElement;

        Assert.Equal(core.GetArrayLength(), CopticMonthsData.Months.Count);
        for (int i = 0; i < CopticMonthsData.Months.Count; i++)
        {
            var m = CopticMonthsData.Months[i];
            var refEl = core[i];
            Assert.Equal(refEl.GetProperty("month").GetInt32(), m.Month);
            var refNames = refEl.GetProperty("names");
            Assert.Equal(refNames.GetProperty("en").GetString(), m.Names["en"]);
            Assert.Equal(refNames.GetProperty("ar").GetString(), m.Names["ar"]);
        }
    }
}

// ----------------------------------------------------------------------
// CopticCalendar.MonthName
// ----------------------------------------------------------------------

public class CopticCalendarMonthNameTests
{
    public static IEnumerable<object[]> Vectors() =>
        TestVectors.V.Coptic_Month_Names.Select(v => new object[]
        {
            v.Month, v.Locale, v.Name,
        });

    [Theory]
    [MemberData(nameof(Vectors))]
    public void Vectors_Match(int month, string locale, string name)
    {
        Assert.Equal(name, CopticCalendar.MonthName(month, locale));
    }

    public static IEnumerable<object[]> InvalidMonths() =>
        TestVectors.V.Invalid_Coptic_Months_For_Name.Select(m => new object[] { m });

    [Theory]
    [MemberData(nameof(InvalidMonths))]
    public void RejectsInvalidMonth(int month)
    {
        Assert.Throws<InvalidCopticMonthException>(
            () => CopticCalendar.MonthName(month, "en"));
    }

    public static IEnumerable<object[]> InvalidLocales() =>
        TestVectors.V.Invalid_Coptic_Month_Locales.Select(v => new object[] { v.Month, v.Locale });

    [Theory]
    [MemberData(nameof(InvalidLocales))]
    public void RejectsUnsupportedLocale(int month, string locale)
    {
        Assert.Throws<UnsupportedLocaleException>(
            () => CopticCalendar.MonthName(month, locale));
    }
}
