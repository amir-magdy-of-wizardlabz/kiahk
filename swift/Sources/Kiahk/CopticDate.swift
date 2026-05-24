import Foundation

private func _isCopticLeap(_ y: Int) -> Bool { y % 4 == 3 }

/// A calendar date on the Coptic (Anno Martyrum) calendar.
///
/// Coptic months 1..12 are 30 days each. Month 13 (Nasie) is 5 days, or 6 in a
/// leap year (`Y mod 4 == 3`, Julian-style).
public struct CopticDate: Equatable, Hashable, Sendable {
    public let year: Int
    public let month: Int
    public let day: Int

    /// Construct and validate. Throws `KiahkError.invalidCopticDate` on bad input.
    public init(year: Int, month: Int, day: Int) throws {
        guard (1...13).contains(month) else {
            throw KiahkError.invalidCopticDate(
                year: year, month: month, day: day,
                reason: "coptic month must be 1..13, got \(month)"
            )
        }
        var maxDay = 30
        if month == 13 {
            maxDay = _isCopticLeap(year) ? 6 : 5
        }
        guard (1...maxDay).contains(day) else {
            throw KiahkError.invalidCopticDate(
                year: year, month: month, day: day,
                reason: "coptic day must be 1..\(maxDay) for year \(year) month \(month)"
            )
        }
        self.year = year
        self.month = month
        self.day = day
    }

    /// Convert this Coptic date to a Gregorian date.
    public func toGregorian() throws -> GregorianDate {
        let r = copticToGregorian(year: year, month: month, day: day)
        return try GregorianDate(year: r.year, month: r.month, day: r.day)
    }
}

/// Extension on `GregorianDate` that adds `toCoptic()`. Lives here so that
/// `GregorianDate.swift` has no dependency on `CopticDate`.
extension GregorianDate {
    /// Convert this Gregorian date to a Coptic date.
    public func toCoptic() throws -> CopticDate {
        let r = gregorianToCoptic(year: year, month: month, day: day)
        return try CopticDate(year: r.year, month: r.month, day: r.day)
    }
}
