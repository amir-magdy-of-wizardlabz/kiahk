using System;
using System.Collections.Generic;

namespace Kiahk;

/// <summary>Static metadata for a feast (mirror of one entry in core/feasts.json).</summary>
public sealed record FeastRecord(
    string Id,
    IReadOnlyDictionary<string, string> Names,
    string Type,
    string Category,
    int? CopticMonth = null,
    int? CopticDay = null,
    int? EasterOffset = null);

/// <summary>Hand-maintained mirror of core/feasts.json. Keep order identical for test parity.</summary>
public static class FeastsData
{
    /// <summary>The 11 canonical Coptic feasts, in the same order as core/feasts.json.</summary>
    public static readonly IReadOnlyList<FeastRecord> Feasts = new FeastRecord[]
    {
        new("nativity",
            new Dictionary<string, string> { ["en"] = "Nativity of Christ", ["ar"] = "عيد الميلاد المجيد" },
            "fixed", "major", CopticMonth: 4, CopticDay: 29),
        new("epiphany",
            new Dictionary<string, string> { ["en"] = "Epiphany (Theophany)", ["ar"] = "عيد الغطاس" },
            "fixed", "major", CopticMonth: 5, CopticDay: 11),
        new("annunciation",
            new Dictionary<string, string> { ["en"] = "Annunciation", ["ar"] = "عيد البشارة" },
            "fixed", "major", CopticMonth: 7, CopticDay: 29),
        new("assumption",
            new Dictionary<string, string> { ["en"] = "Assumption of Mary", ["ar"] = "عيد انتقال العذراء" },
            "fixed", "major", CopticMonth: 12, CopticDay: 16),
        new("cross",
            new Dictionary<string, string> { ["en"] = "Feast of the Cross", ["ar"] = "عيد الصليب" },
            "fixed", "major", CopticMonth: 1, CopticDay: 17),
        new("nineveh_fast",
            new Dictionary<string, string> { ["en"] = "Nineveh Fast", ["ar"] = "صوم نينوى" },
            "moveable", "major", EasterOffset: -69),
        new("great_lent",
            new Dictionary<string, string> { ["en"] = "Great Lent (start)", ["ar"] = "بداية الصوم الكبير" },
            "moveable", "major", EasterOffset: -55),
        new("palm_sunday",
            new Dictionary<string, string> { ["en"] = "Palm Sunday", ["ar"] = "أحد الشعانين" },
            "moveable", "major", EasterOffset: -7),
        new("easter",
            new Dictionary<string, string> { ["en"] = "Easter Sunday", ["ar"] = "عيد القيامة المجيد" },
            "moveable", "major", EasterOffset: 0),
        new("ascension",
            new Dictionary<string, string> { ["en"] = "Ascension", ["ar"] = "عيد الصعود" },
            "moveable", "major", EasterOffset: 39),
        new("pentecost",
            new Dictionary<string, string> { ["en"] = "Pentecost", ["ar"] = "عيد العنصرة" },
            "moveable", "major", EasterOffset: 49),
    };

    /// <summary>Look up a feast record by ID. Throws <see cref="ArgumentException"/> if not found.</summary>
    public static FeastRecord FeastById(string id)
    {
        foreach (var f in Feasts)
        {
            if (f.Id == id) return f;
        }
        throw new ArgumentException($"Kiahk: unknown feast id \"{id}\"", nameof(id));
    }
}
