import Foundation

/// All errors thrown by Kiahk's public API.
public enum KiahkError: Error, Equatable, Sendable {
    /// A `CopticDate` was constructed with out-of-range month/day.
    case invalidCopticDate(year: Int, month: Int, day: Int, reason: String)

    /// A `GregorianDate` was constructed with out-of-range month/day.
    case invalidGregorianDate(year: Int, month: Int, day: Int, reason: String)

    /// `Feast.name(locale:)` was asked for a locale that has no translation.
    case unsupportedLocale(feastID: String, locale: String)

    /// `CopticCalendar.monthName(month:locale:)` was asked for a month outside 1..13.
    case invalidCopticMonth(month: Int)
}

extension KiahkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidCopticDate(let y, let m, let d, let reason):
            return "Kiahk: invalid coptic date \(y)/\(m)/\(d): \(reason)"
        case .invalidGregorianDate(let y, let m, let d, let reason):
            return "Kiahk: invalid gregorian date \(y)-\(String(format: "%02d", m))-\(String(format: "%02d", d)): \(reason)"
        case .unsupportedLocale(let id, let locale):
            return "Kiahk: feast \"\(id)\" has no name for locale \"\(locale)\""
        case .invalidCopticMonth(let month):
            return "Kiahk: invalid coptic month \(month) (expected 1..13)"
        }
    }
}
