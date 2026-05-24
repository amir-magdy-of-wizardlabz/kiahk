using System.Collections.Generic;
using System.Linq;

namespace Kiahk;

/// <summary>Entry points for Easter and feast lookups.</summary>
public static class CopticCalendar
{
    /// <summary>
    /// Return the Coptic month name for <paramref name="month"/> (1..13) in <paramref name="locale"/>.
    /// </summary>
    /// <exception cref="InvalidCopticMonthException">If <paramref name="month"/> is outside 1..13.</exception>
    /// <exception cref="UnsupportedLocaleException">If <paramref name="locale"/> has no translation.</exception>
    public static string MonthName(int month, string locale)
    {
        if (month < 1 || month > 13)
        {
            throw new InvalidCopticMonthException(month);
        }
        var record = CopticMonthsData.Months[month - 1];
        if (!record.Names.TryGetValue(locale, out var name))
        {
            throw new UnsupportedLocaleException(string.Empty, locale);
        }
        return name;
    }

    /// <summary>Return the Gregorian date of Coptic / Orthodox Easter for <paramref name="gregorianYear"/>.</summary>
    public static GregorianDate EasterDate(int gregorianYear)
    {
        var r = Algorithms.ComputeEaster(gregorianYear);
        return new GregorianDate(r.Year, r.Month, r.Day);
    }

    /// <summary>
    /// Resolve a moveable feast (by ID) to its Gregorian date in <paramref name="gregorianYear"/>.
    /// Throws if the ID is unknown or refers to a fixed (not moveable) feast.
    /// </summary>
    public static Feast MoveableFeast(string id, int gregorianYear)
    {
        var rec = FeastsData.FeastById(id);
        if (rec.Type != "moveable")
        {
            throw new System.ArgumentException(
                $"Kiahk: feast \"{id}\" is not moveable", nameof(id));
        }
        var easter = Algorithms.ComputeEaster(gregorianYear);
        var d = Algorithms.AddDays(easter.Year, easter.Month, easter.Day, rec.EasterOffset!.Value);
        return new Feast(
            rec.Id, rec.Type, rec.Category, rec.Names,
            new GregorianDate(d.Year, d.Month, d.Day));
    }

    /// <summary>
    /// Return every feast (fixed + moveable) in <paramref name="gregorianYear"/>, sorted ascending by date.
    /// </summary>
    public static IReadOnlyList<Feast> YearFeasts(int gregorianYear)
    {
        var list = new List<Feast>(FeastsData.Feasts.Count);
        foreach (var rec in FeastsData.Feasts)
        {
            if (rec.Type == "fixed")
            {
                list.Add(FixedFeast(rec, gregorianYear));
            }
            else
            {
                list.Add(MoveableFeast(rec.Id, gregorianYear));
            }
        }
        list.Sort((a, b) =>
        {
            int c = a.GregorianDate.Year.CompareTo(b.GregorianDate.Year);
            if (c != 0) return c;
            c = a.GregorianDate.Month.CompareTo(b.GregorianDate.Month);
            if (c != 0) return c;
            return a.GregorianDate.Day.CompareTo(b.GregorianDate.Day);
        });
        return list;
    }

    /// <summary>
    /// Resolve a fixed Coptic feast to its Gregorian date inside <paramref name="gregorianYear"/>.
    /// A Coptic month/day falls in two possible Coptic years that overlap with the same Gregorian
    /// year. Try both candidates, keep the one landing inside the target Gregorian year; fall back
    /// to the earlier candidate.
    /// </summary>
    private static Feast FixedFeast(FeastRecord rec, int gregorianYear)
    {
        int cYearA = Algorithms.GregorianToCoptic(gregorianYear, 1, 1).Year;
        int cYearB = Algorithms.GregorianToCoptic(gregorianYear, 12, 31).Year;
        var candidates = new List<(int Year, int Month, int Day)>(2);
        var seen = new HashSet<int>();
        foreach (var cy in new[] { cYearA, cYearB })
        {
            if (!seen.Add(cy)) continue;
            var d = Algorithms.CopticToGregorian(cy, rec.CopticMonth!.Value, rec.CopticDay!.Value);
            if (d.Year == gregorianYear)
            {
                candidates.Add(d);
            }
        }
        if (candidates.Count == 0)
        {
            candidates.Add(Algorithms.CopticToGregorian(cYearA, rec.CopticMonth!.Value, rec.CopticDay!.Value));
        }
        candidates.Sort((a, b) =>
        {
            int c = a.Year.CompareTo(b.Year);
            if (c != 0) return c;
            c = a.Month.CompareTo(b.Month);
            if (c != 0) return c;
            return a.Day.CompareTo(b.Day);
        });
        var picked = candidates[0];
        return new Feast(
            rec.Id, rec.Type, rec.Category, rec.Names,
            new GregorianDate(picked.Year, picked.Month, picked.Day));
    }
}
