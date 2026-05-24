using System.Collections.Generic;

namespace Kiahk;

/// <summary>One entry of the Coptic month-name table
/// (mirror of one entry in core/coptic_months.json).</summary>
public sealed record CopticMonthRecord(
    int Month,
    IReadOnlyDictionary<string, string> Names);

/// <summary>Hand-maintained mirror of core/coptic_months.json.
/// Keep order identical (months 1..13) for cross-port test parity.</summary>
public static class CopticMonthsData
{
    /// <summary>The 13 Coptic month names, in order 1..13.</summary>
    public static readonly IReadOnlyList<CopticMonthRecord> Months = new CopticMonthRecord[]
    {
        new(1,  new Dictionary<string, string> { ["en"] = "Thout",    ["ar"] = "توت" }),
        new(2,  new Dictionary<string, string> { ["en"] = "Paopi",    ["ar"] = "بابة" }),
        new(3,  new Dictionary<string, string> { ["en"] = "Hathor",   ["ar"] = "هاتور" }),
        new(4,  new Dictionary<string, string> { ["en"] = "Koiak",    ["ar"] = "كيهك" }),
        new(5,  new Dictionary<string, string> { ["en"] = "Tobi",     ["ar"] = "طوبة" }),
        new(6,  new Dictionary<string, string> { ["en"] = "Meshir",   ["ar"] = "أمشير" }),
        new(7,  new Dictionary<string, string> { ["en"] = "Paremhat", ["ar"] = "برمهات" }),
        new(8,  new Dictionary<string, string> { ["en"] = "Parmouti", ["ar"] = "برمودة" }),
        new(9,  new Dictionary<string, string> { ["en"] = "Pashons",  ["ar"] = "بشنس" }),
        new(10, new Dictionary<string, string> { ["en"] = "Paoni",    ["ar"] = "بؤونة" }),
        new(11, new Dictionary<string, string> { ["en"] = "Epip",     ["ar"] = "أبيب" }),
        new(12, new Dictionary<string, string> { ["en"] = "Mesori",   ["ar"] = "مسرى" }),
        new(13, new Dictionary<string, string> { ["en"] = "Nasie",    ["ar"] = "نسيء" }),
    };
}
