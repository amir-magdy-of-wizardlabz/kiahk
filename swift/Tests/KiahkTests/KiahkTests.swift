import XCTest
import Foundation
@testable import Kiahk

// ----------------------------------------------------------------------
// Shared test-vector loader.
//
// `#file` resolves at compile time to this source file's path. From
// swift/Tests/KiahkTests/KiahkTests.swift we walk up three levels to
// reach the repo root, then into core/.
// ----------------------------------------------------------------------

private let coreDir: URL = {
    let thisFile = URL(fileURLWithPath: #file)
    return thisFile
        .deletingLastPathComponent() // KiahkTests
        .deletingLastPathComponent() // Tests
        .deletingLastPathComponent() // swift
        .deletingLastPathComponent() // repo root
        .appendingPathComponent("core")
}()

private struct GregCoptic: Decodable {
    let gregorian: YMD
    let coptic: YMD
}
private struct YMD: Decodable {
    let year: Int
    let month: Int
    let day: Int
}
private struct EasterVec: Decodable {
    let gregorian_year: Int
    let date: YMD
}
private struct MoveableVec: Decodable {
    let gregorian_year: Int
    let feast_id: String
    let date: YMD
}
private struct InvalidDate: Decodable {
    let year: Int
    let month: Int
    let day: Int
}
private struct Vectors: Decodable {
    let gregorian_to_coptic: [GregCoptic]
    let coptic_to_gregorian: [GregCoptic]
    let easter: [EasterVec]
    let moveable_feasts: [MoveableVec]
    let invalid_coptic_dates: [InvalidDate]
    let invalid_gregorian_dates: [InvalidDate]
}

private let vectors: Vectors = {
    let url = coreDir.appendingPathComponent("test-vectors.json")
    let data = try! Data(contentsOf: url)
    return try! JSONDecoder().decode(Vectors.self, from: data)
}()

// ----------------------------------------------------------------------
// Error cases
// ----------------------------------------------------------------------

final class ErrorsTests: XCTestCase {
    func testInvalidCopticDateCaseExists() {
        let err = KiahkError.invalidCopticDate(year: 1741, month: 14, day: 1, reason: "month out of range")
        if case .invalidCopticDate = err {} else { XCTFail("expected .invalidCopticDate, got \(err)") }
    }

    func testInvalidGregorianDateCaseExists() {
        let err = KiahkError.invalidGregorianDate(year: 2025, month: 2, day: 29, reason: "not a leap year")
        if case .invalidGregorianDate = err {} else { XCTFail("expected .invalidGregorianDate, got \(err)") }
    }

    func testUnsupportedLocaleCaseExists() {
        let err = KiahkError.unsupportedLocale(feastID: "easter", locale: "fr")
        if case .unsupportedLocale = err {} else { XCTFail("expected .unsupportedLocale, got \(err)") }
    }

    func testErrorTypeConformsToErrorProtocol() {
        let err: Error = KiahkError.invalidCopticDate(year: 0, month: 0, day: 0, reason: "")
        XCTAssertNotNil(err)
    }
}

// ----------------------------------------------------------------------
// algorithms / gregorianToJdn
// ----------------------------------------------------------------------

final class GregorianToJdnTests: XCTestCase {
    func testKnownValues() {
        XCTAssertEqual(gregorianToJdn(year: 2000, month: 1, day: 1), 2451545)
        XCTAssertEqual(gregorianToJdn(year: 1900, month: 1, day: 1), 2415021)
        XCTAssertEqual(gregorianToJdn(year: 2025, month: 1, day: 11), 2460687)
    }
}

final class JdnToGregorianTests: XCTestCase {
    func testRoundTrip() {
        let cases: [(Int, Int, Int)] = [
            (2000, 1, 1), (1900, 1, 1), (2025, 1, 11), (2024, 12, 25), (2025, 9, 11),
        ]
        for (y, m, d) in cases {
            let jdn = gregorianToJdn(year: y, month: m, day: d)
            let r = jdnToGregorian(jdn)
            XCTAssertEqual(r.year, y, "round trip year for \(y)-\(m)-\(d)")
            XCTAssertEqual(r.month, m, "round trip month for \(y)-\(m)-\(d)")
            XCTAssertEqual(r.day, d, "round trip day for \(y)-\(m)-\(d)")
        }
    }
}

final class CopticToJdnTests: XCTestCase {
    func testEpoch() {
        // 1 Tout 1 AM is JDN 1_825_030 (the Coptic epoch).
        XCTAssertEqual(copticToJdn(year: 1, month: 1, day: 1), 1_825_030)
    }
}

final class JdnToCopticTests: XCTestCase {
    func testCopticRoundTripVectors() {
        for vec in vectors.gregorian_to_coptic {
            let c = vec.coptic
            let jdn = copticToJdn(year: c.year, month: c.month, day: c.day)
            let r = jdnToCoptic(jdn)
            XCTAssertEqual(r.year, c.year, "year for \(c.year)/\(c.month)/\(c.day)")
            XCTAssertEqual(r.month, c.month, "month")
            XCTAssertEqual(r.day, c.day, "day")
        }
    }
}

final class GregorianToCopticTests: XCTestCase {
    func testVectors() {
        for vec in vectors.gregorian_to_coptic {
            let g = vec.gregorian
            let c = vec.coptic
            let r = gregorianToCoptic(year: g.year, month: g.month, day: g.day)
            XCTAssertEqual(r.year, c.year, "G \(g.year)-\(g.month)-\(g.day) → C year")
            XCTAssertEqual(r.month, c.month, "G \(g.year)-\(g.month)-\(g.day) → C month")
            XCTAssertEqual(r.day, c.day, "G \(g.year)-\(g.month)-\(g.day) → C day")
        }
    }
}

final class CopticToGregorianTests: XCTestCase {
    func testVectors() {
        for vec in vectors.coptic_to_gregorian {
            let c = vec.coptic
            let g = vec.gregorian
            let r = copticToGregorian(year: c.year, month: c.month, day: c.day)
            XCTAssertEqual(r.year, g.year, "C \(c.year)/\(c.month)/\(c.day) → G year")
            XCTAssertEqual(r.month, g.month)
            XCTAssertEqual(r.day, g.day)
        }
    }
}

final class ComputeEasterTests: XCTestCase {
    func testVectors() {
        for vec in vectors.easter {
            let r = computeEaster(gregorianYear: vec.gregorian_year)
            XCTAssertEqual(r.year, vec.date.year, "easter \(vec.gregorian_year) year")
            XCTAssertEqual(r.month, vec.date.month, "easter \(vec.gregorian_year) month")
            XCTAssertEqual(r.day, vec.date.day, "easter \(vec.gregorian_year) day")
        }
    }
}

final class AddDaysTests: XCTestCase {
    func testKnownOffsets() {
        var r = addDays(year: 2025, month: 1, day: 1, days: 10)
        XCTAssertEqual(r.year, 2025); XCTAssertEqual(r.month, 1); XCTAssertEqual(r.day, 11)

        r = addDays(year: 2025, month: 1, day: 1, days: -1)
        XCTAssertEqual(r.year, 2024); XCTAssertEqual(r.month, 12); XCTAssertEqual(r.day, 31)

        // 2024 is a leap year
        r = addDays(year: 2024, month: 2, day: 28, days: 1)
        XCTAssertEqual(r.year, 2024); XCTAssertEqual(r.month, 2); XCTAssertEqual(r.day, 29)
    }
}

// ----------------------------------------------------------------------
// GregorianDate
// ----------------------------------------------------------------------

final class GregorianDateTests: XCTestCase {
    func testBasicConstruction() throws {
        let g = try GregorianDate(year: 2025, month: 1, day: 11)
        XCTAssertEqual(g.year, 2025)
        XCTAssertEqual(g.month, 1)
        XCTAssertEqual(g.day, 11)
    }

    func testRejectsInvalidDates() {
        for bad in vectors.invalid_gregorian_dates {
            XCTAssertThrowsError(try GregorianDate(year: bad.year, month: bad.month, day: bad.day)) { err in
                guard case KiahkError.invalidGregorianDate = err else {
                    XCTFail("expected .invalidGregorianDate for \(bad), got \(err)")
                    return
                }
            }
        }
    }

    func testToDate() throws {
        let g = try GregorianDate(year: 2025, month: 1, day: 11)
        let date = g.toDate()
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let comps = cal.dateComponents([.year, .month, .day], from: date)
        XCTAssertEqual(comps.year, 2025)
        XCTAssertEqual(comps.month, 1)
        XCTAssertEqual(comps.day, 11)
    }

    func testFromDate() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let date = cal.date(from: DateComponents(year: 2025, month: 1, day: 11, hour: 12))!
        let g = GregorianDate(date: date)
        XCTAssertEqual(g.year, 2025)
        XCTAssertEqual(g.month, 1)
        XCTAssertEqual(g.day, 11)
    }

    func testEquatable() throws {
        let a = try GregorianDate(year: 2025, month: 1, day: 11)
        let b = try GregorianDate(year: 2025, month: 1, day: 11)
        XCTAssertEqual(a, b)
        XCTAssertEqual(a.hashValue, b.hashValue)
    }
}

// ----------------------------------------------------------------------
// CopticDate
// ----------------------------------------------------------------------

final class CopticDateTests: XCTestCase {
    func testBasicConstruction() throws {
        let c = try CopticDate(year: 1741, month: 5, day: 3)
        XCTAssertEqual(c.year, 1741)
        XCTAssertEqual(c.month, 5)
        XCTAssertEqual(c.day, 3)
    }

    func testRejectsInvalidDates() {
        for bad in vectors.invalid_coptic_dates {
            XCTAssertThrowsError(try CopticDate(year: bad.year, month: bad.month, day: bad.day)) { err in
                guard case KiahkError.invalidCopticDate = err else {
                    XCTFail("expected .invalidCopticDate for \(bad), got \(err)")
                    return
                }
            }
        }
    }

    func testToGregorian() throws {
        let c = try CopticDate(year: 1741, month: 5, day: 3)
        let g = try c.toGregorian()
        XCTAssertEqual(g.year, 2025)
        XCTAssertEqual(g.month, 1)
        XCTAssertEqual(g.day, 11)
    }

    func testGregorianToCopticInstance() throws {
        let g = try GregorianDate(year: 2025, month: 1, day: 11)
        let c = try g.toCoptic()
        XCTAssertEqual(c.year, 1741)
        XCTAssertEqual(c.month, 5)
        XCTAssertEqual(c.day, 3)
    }
}

// ----------------------------------------------------------------------
// feasts data parity with core/feasts.json
// ----------------------------------------------------------------------

final class FeastsDataTests: XCTestCase {
    func testMatchesCoreFeastsJSON() throws {
        let url = coreDir.appendingPathComponent("feasts.json")
        let data = try Data(contentsOf: url)
        let core = try JSONSerialization.jsonObject(with: data) as! [[String: Any]]

        XCTAssertEqual(kFeasts.count, core.count)
        for (i, f) in kFeasts.enumerated() {
            let ref = core[i]
            XCTAssertEqual(f.id, ref["id"] as? String, "id [\(i)]")
            XCTAssertEqual(f.type, ref["type"] as? String, "type [\(i)]")
            XCTAssertEqual(f.category, ref["category"] as? String, "category [\(i)]")
            let refNames = ref["names"] as! [String: String]
            XCTAssertEqual(f.names["en"], refNames["en"], "en [\(i)]")
            XCTAssertEqual(f.names["ar"], refNames["ar"], "ar [\(i)]")
        }
    }
}

// ----------------------------------------------------------------------
// Feast struct + name(locale:)
// ----------------------------------------------------------------------

final class FeastTests: XCTestCase {
    func testBasicFieldsAndName() throws {
        let g = try GregorianDate(year: 2025, month: 4, day: 20)
        let rec = try feastByID("easter")
        let feast = Feast(
            id: rec.id, type: rec.type, category: rec.category,
            names: rec.names, gregorianDate: g
        )
        XCTAssertEqual(feast.id, "easter")
        XCTAssertEqual(feast.type, "moveable")
        XCTAssertEqual(feast.category, "major")
        XCTAssertEqual(try feast.name(locale: "en"), "Easter Sunday")
        XCTAssertEqual(try feast.name(locale: "ar"), "عيد القيامة المجيد")
    }

    func testUnknownLocaleThrows() throws {
        let g = try GregorianDate(year: 2025, month: 4, day: 20)
        let rec = try feastByID("easter")
        let feast = Feast(
            id: rec.id, type: rec.type, category: rec.category,
            names: rec.names, gregorianDate: g
        )
        XCTAssertThrowsError(try feast.name(locale: "fr")) { err in
            guard case KiahkError.unsupportedLocale = err else {
                XCTFail("expected .unsupportedLocale, got \(err)")
                return
            }
        }
    }
}

// ----------------------------------------------------------------------
// CopticCalendar.easterDate
// ----------------------------------------------------------------------

final class CopticCalendarEasterDateTests: XCTestCase {
    func testVectors() throws {
        for vec in vectors.easter {
            let g = try CopticCalendar.easterDate(gregorianYear: vec.gregorian_year)
            XCTAssertEqual(g.year, vec.date.year, "easter \(vec.gregorian_year) year")
            XCTAssertEqual(g.month, vec.date.month, "easter \(vec.gregorian_year) month")
            XCTAssertEqual(g.day, vec.date.day, "easter \(vec.gregorian_year) day")
        }
    }
}

// ----------------------------------------------------------------------
// CopticCalendar.moveableFeast
// ----------------------------------------------------------------------

final class CopticCalendarMoveableFeastTests: XCTestCase {
    func testVectors() throws {
        for vec in vectors.moveable_feasts {
            let feast = try CopticCalendar.moveableFeast(id: vec.feast_id, gregorianYear: vec.gregorian_year)
            XCTAssertEqual(feast.id, vec.feast_id)
            let g = feast.gregorianDate
            XCTAssertEqual(g.year, vec.date.year, "\(vec.feast_id) \(vec.gregorian_year) year")
            XCTAssertEqual(g.month, vec.date.month)
            XCTAssertEqual(g.day, vec.date.day)
        }
    }
}

// ----------------------------------------------------------------------
// CopticCalendar.yearFeasts
// ----------------------------------------------------------------------

final class CopticCalendarYearFeastsTests: XCTestCase {
    func testNonEmptyAndSorted() {
        let feasts = CopticCalendar.yearFeasts(gregorianYear: 2025)
        XCTAssertFalse(feasts.isEmpty)
        for i in 1..<feasts.count {
            let a = feasts[i - 1].gregorianDate
            let b = feasts[i].gregorianDate
            XCTAssertTrue(_lessOrEqual(a, b), "feasts not sorted at \(i): \(a) > \(b)")
        }
    }

    func testIncludesEaster() {
        let feasts = CopticCalendar.yearFeasts(gregorianYear: 2025)
        guard let easter = feasts.first(where: { $0.id == "easter" }) else {
            XCTFail("Easter not in yearFeasts(2025)")
            return
        }
        XCTAssertEqual(easter.gregorianDate.year, 2025)
        XCTAssertEqual(easter.gregorianDate.month, 4)
        XCTAssertEqual(easter.gregorianDate.day, 20)
    }

    private func _lessOrEqual(_ a: GregorianDate, _ b: GregorianDate) -> Bool {
        if a.year != b.year { return a.year < b.year }
        if a.month != b.month { return a.month < b.month }
        return a.day <= b.day
    }
}
