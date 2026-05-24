import Foundation

private let _daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

private func _isGregLeap(_ y: Int) -> Bool {
    return y % 4 == 0 && (y % 100 != 0 || y % 400 == 0)
}

/// A calendar date on the proleptic Gregorian calendar.
///
/// Immutable value type; initializer validates month/day for the given year.
public struct GregorianDate: Equatable, Hashable, Sendable {
    public let year: Int
    public let month: Int
    public let day: Int

    /// Construct and validate. Throws `KiahkError.invalidGregorianDate` on bad input.
    public init(year: Int, month: Int, day: Int) throws {
        guard (1...12).contains(month) else {
            throw KiahkError.invalidGregorianDate(
                year: year, month: month, day: day,
                reason: "month must be 1..12, got \(month)"
            )
        }
        var maxDay = _daysInMonth[month - 1]
        if month == 2 && _isGregLeap(year) {
            maxDay = 29
        }
        guard (1...maxDay).contains(day) else {
            throw KiahkError.invalidGregorianDate(
                year: year, month: month, day: day,
                reason: "day must be 1..\(maxDay) for \(year)-\(String(format: "%02d", month))"
            )
        }
        self.year = year
        self.month = month
        self.day = day
    }

    /// Construct from a Foundation `Date` (calendar date only; time-of-day discarded).
    /// Uses the UTC Gregorian calendar so the result is deterministic regardless of the
    /// device timezone.
    public init(date: Date) {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let comps = cal.dateComponents([.year, .month, .day], from: date)
        self.year = comps.year ?? 0
        self.month = comps.month ?? 0
        self.day = comps.day ?? 0
    }

    /// Return a `Date` at 00:00:00 UTC on this date.
    public func toDate() -> Date {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = day
        return cal.date(from: comps)!
    }
}
