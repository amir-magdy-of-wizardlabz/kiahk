import Foundation

/// A calendar-resolved feast: a `FeastRecord`'s metadata paired with the
/// Gregorian date on which it falls for a particular year.
public struct Feast: Equatable, Hashable, Sendable {
    public let id: String
    public let type: String            // "fixed" | "moveable"
    public let category: String        // "major" | "minor"
    public let names: [String: String]
    public let gregorianDate: GregorianDate

    public init(
        id: String,
        type: String,
        category: String,
        names: [String: String],
        gregorianDate: GregorianDate
    ) {
        self.id = id
        self.type = type
        self.category = category
        self.names = names
        self.gregorianDate = gregorianDate
    }

    /// Return the feast's localized name for `locale`. Supported: "en", "ar".
    /// Unknown locales throw `KiahkError.unsupportedLocale`.
    public func name(locale: String) throws -> String {
        guard let n = names[locale] else {
            throw KiahkError.unsupportedLocale(feastID: id, locale: locale)
        }
        return n
    }
}
