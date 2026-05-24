import Foundation

/// One entry of the Coptic month-name table
/// (mirror of one entry in core/coptic_months.json).
public struct CopticMonthRecord: Equatable, Hashable, Sendable {
    public let month: Int
    public let names: [String: String]

    public init(month: Int, names: [String: String]) {
        self.month = month
        self.names = names
    }
}

/// Hand-maintained mirror of core/coptic_months.json.
/// Keep order identical (months 1..13) for cross-port test parity.
public let kCopticMonths: [CopticMonthRecord] = [
    CopticMonthRecord(month: 1,  names: ["en": "Thout",    "ar": "توت"]),
    CopticMonthRecord(month: 2,  names: ["en": "Paopi",    "ar": "بابة"]),
    CopticMonthRecord(month: 3,  names: ["en": "Hathor",   "ar": "هاتور"]),
    CopticMonthRecord(month: 4,  names: ["en": "Koiak",    "ar": "كيهك"]),
    CopticMonthRecord(month: 5,  names: ["en": "Tobi",     "ar": "طوبة"]),
    CopticMonthRecord(month: 6,  names: ["en": "Meshir",   "ar": "أمشير"]),
    CopticMonthRecord(month: 7,  names: ["en": "Paremhat", "ar": "برمهات"]),
    CopticMonthRecord(month: 8,  names: ["en": "Parmouti", "ar": "برمودة"]),
    CopticMonthRecord(month: 9,  names: ["en": "Pashons",  "ar": "بشنس"]),
    CopticMonthRecord(month: 10, names: ["en": "Paoni",    "ar": "بؤونة"]),
    CopticMonthRecord(month: 11, names: ["en": "Epip",     "ar": "أبيب"]),
    CopticMonthRecord(month: 12, names: ["en": "Mesori",   "ar": "مسرى"]),
    CopticMonthRecord(month: 13, names: ["en": "Nasie",    "ar": "نسيء"]),
]
