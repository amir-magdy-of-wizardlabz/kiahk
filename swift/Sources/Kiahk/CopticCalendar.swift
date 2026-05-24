import Foundation

/// Namespace for Easter and feast-lookup entry points.
///
/// Implemented as a caseless enum: uninstantiable, used purely for static
/// dispatch (`CopticCalendar.easterDate(gregorianYear:)`).
public enum CopticCalendar {

    /// Return the Gregorian date of Coptic / Orthodox Easter for `gregorianYear`.
    public static func easterDate(gregorianYear: Int) throws -> GregorianDate {
        let r = computeEaster(gregorianYear: gregorianYear)
        return try GregorianDate(year: r.year, month: r.month, day: r.day)
    }

    /// Resolve a moveable feast (by ID) to its Gregorian date in `gregorianYear`.
    /// Throws if the ID is unknown or refers to a fixed (not moveable) feast.
    public static func moveableFeast(id: String, gregorianYear: Int) throws -> Feast {
        let rec = try feastByID(id)
        guard rec.type == "moveable" else {
            struct NotMoveableError: Error, CustomStringConvertible {
                let id: String
                var description: String { "Kiahk: feast \"\(id)\" is not moveable" }
            }
            throw NotMoveableError(id: id)
        }
        let easter = computeEaster(gregorianYear: gregorianYear)
        let d = addDays(year: easter.year, month: easter.month, day: easter.day, days: rec.easterOffset!)
        return Feast(
            id: rec.id,
            type: rec.type,
            category: rec.category,
            names: rec.names,
            gregorianDate: try GregorianDate(year: d.year, month: d.month, day: d.day)
        )
    }

    /// Return every feast (fixed + moveable) in `gregorianYear`, sorted ascending by date.
    public static func yearFeasts(gregorianYear: Int) -> [Feast] {
        var out: [Feast] = []
        out.reserveCapacity(kFeasts.count)
        for rec in kFeasts {
            if rec.type == "fixed" {
                if let f = try? _fixedFeast(rec, gregorianYear: gregorianYear) {
                    out.append(f)
                }
            } else {
                if let f = try? moveableFeast(id: rec.id, gregorianYear: gregorianYear) {
                    out.append(f)
                }
            }
        }
        out.sort { a, b in
            if a.gregorianDate.year != b.gregorianDate.year { return a.gregorianDate.year < b.gregorianDate.year }
            if a.gregorianDate.month != b.gregorianDate.month { return a.gregorianDate.month < b.gregorianDate.month }
            return a.gregorianDate.day < b.gregorianDate.day
        }
        return out
    }

    /// Resolve a fixed Coptic feast to its Gregorian date inside `gregorianYear`.
    ///
    /// A Coptic month/day falls in two possible Coptic years that overlap with the
    /// same Gregorian year. Try both candidates, keep the one landing inside
    /// `gregorianYear`; fall back to the earlier candidate.
    private static func _fixedFeast(_ rec: FeastRecord, gregorianYear: Int) throws -> Feast {
        let cYearA = gregorianToCoptic(year: gregorianYear, month: 1, day: 1).year
        let cYearB = gregorianToCoptic(year: gregorianYear, month: 12, day: 31).year

        var candidates: [(year: Int, month: Int, day: Int)] = []
        var seen = Set<Int>()
        for cy in [cYearA, cYearB] where seen.insert(cy).inserted {
            let d = copticToGregorian(year: cy, month: rec.copticMonth!, day: rec.copticDay!)
            if d.year == gregorianYear {
                candidates.append(d)
            }
        }
        if candidates.isEmpty {
            candidates.append(copticToGregorian(year: cYearA, month: rec.copticMonth!, day: rec.copticDay!))
        }
        candidates.sort { a, b in
            if a.year != b.year { return a.year < b.year }
            if a.month != b.month { return a.month < b.month }
            return a.day < b.day
        }
        let d = candidates[0]
        return Feast(
            id: rec.id,
            type: rec.type,
            category: rec.category,
            names: rec.names,
            gregorianDate: try GregorianDate(year: d.year, month: d.month, day: d.day)
        )
    }
}
