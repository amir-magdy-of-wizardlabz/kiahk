package com.wizardlabz.kiahk

import com.google.gson.JsonArray
import com.google.gson.JsonObject
import com.google.gson.JsonParser
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertThrows
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.DynamicTest
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.TestFactory
import java.io.File
import java.time.LocalDate

/**
 * Cross-port test suite — every assertion is data-driven from
 * `core/test-vectors.json`. Identical contract to the JS / Python / Go /
 * Dart / Swift / C# / C / PHP ports.
 */
class KiahkTest {

    // -------------------------------------------------------------------------
    // Test vector loading
    // -------------------------------------------------------------------------

    private companion object {
        // Gradle runs tests with cwd = the `kotlin/` module directory,
        // so the shared spec is one level up at ../core/test-vectors.json.
        val vectors: JsonObject by lazy {
            val text = File("../core/test-vectors.json").readText()
            JsonParser.parseString(text).asJsonObject
        }
    }

    // -------------------------------------------------------------------------
    // Gregorian ↔ Coptic
    // -------------------------------------------------------------------------

    @TestFactory
    fun gregorianToCoptic(): List<DynamicTest> =
        vectors.array("gregorian_to_coptic").mapIndexed { i, raw ->
            DynamicTest.dynamicTest("vector#$i") {
                val v = raw.asJsonObject
                val g = v.obj("gregorian"); val exp = v.obj("coptic")
                val c = GregorianDate(g.int("year"), g.int("month"), g.int("day")).toCoptic()
                assertEquals(exp.int("year"), c.year)
                assertEquals(exp.int("month"), c.month)
                assertEquals(exp.int("day"), c.day)
            }
        }

    @TestFactory
    fun copticToGregorian(): List<DynamicTest> =
        vectors.array("coptic_to_gregorian").mapIndexed { i, raw ->
            DynamicTest.dynamicTest("vector#$i") {
                val v = raw.asJsonObject
                val c = v.obj("coptic"); val exp = v.obj("gregorian")
                val g = CopticDate(c.int("year"), c.int("month"), c.int("day")).toGregorian()
                assertEquals(exp.int("year"), g.year)
                assertEquals(exp.int("month"), g.month)
                assertEquals(exp.int("day"), g.day)
            }
        }

    // -------------------------------------------------------------------------
    // Round-trip identity
    // -------------------------------------------------------------------------

    @TestFactory
    fun roundTripGregorianCopticGregorian(): List<DynamicTest> {
        val cases = listOf(
            Triple(1900, 1, 1), Triple(1950, 6, 15), Triple(2000, 2, 29),
            Triple(2024, 12, 31), Triple(2025, 1, 11), Triple(2050, 7, 4),
            Triple(2099, 12, 31),
        )
        return cases.map { (y, m, d) ->
            DynamicTest.dynamicTest("$y-$m-$d") {
                val g = GregorianDate(y, m, d)
                assertEquals(g, g.toCoptic().toGregorian())
            }
        }
    }

    // -------------------------------------------------------------------------
    // Easter
    // -------------------------------------------------------------------------

    @TestFactory
    fun easter(): List<DynamicTest> =
        vectors.array("easter").map { raw ->
            val v = raw.asJsonObject
            val year = v.int("gregorian_year")
            DynamicTest.dynamicTest("easter_$year") {
                val exp = v.obj("date")
                val e = CopticCalendar.easterDate(year)
                assertEquals(exp.int("year"), e.year)
                assertEquals(exp.int("month"), e.month)
                assertEquals(exp.int("day"), e.day)
            }
        }

    // -------------------------------------------------------------------------
    // Moveable feasts
    // -------------------------------------------------------------------------

    @TestFactory
    fun moveableFeasts(): List<DynamicTest> =
        vectors.array("moveable_feasts").mapIndexed { i, raw ->
            DynamicTest.dynamicTest("moveable#$i") {
                val v = raw.asJsonObject
                val exp = v.obj("date")
                val feast = CopticCalendar.moveableFeast(
                    v["feast_id"].asString,
                    v.int("gregorian_year"),
                )
                assertEquals(exp.int("year"), feast.gregorianDate.year)
                assertEquals(exp.int("month"), feast.gregorianDate.month)
                assertEquals(exp.int("day"), feast.gregorianDate.day)
                assertEquals(v["feast_id"].asString, feast.id)
                assertEquals("moveable", feast.type)
            }
        }

    // -------------------------------------------------------------------------
    // Year feasts (sorting + completeness)
    // -------------------------------------------------------------------------

    @Test
    fun yearFeasts2025IsSortedAndIncludesMajor() {
        val feasts = CopticCalendar.yearFeasts(2025)
        assertTrue(feasts.size >= 11, "expected >= 11 major feasts in 2025, got ${feasts.size}")

        var prevJdn = Int.MIN_VALUE
        for (f in feasts) {
            val jdn = Algorithms.gregorianToJdn(f.gregorianDate.year, f.gregorianDate.month, f.gregorianDate.day)
            assertTrue(jdn >= prevJdn, "feasts must be sorted ascending")
            prevJdn = jdn
        }

        val ids = feasts.map { it.id }
        assertTrue("easter" in ids)
        assertTrue("nativity" in ids)
    }

    // -------------------------------------------------------------------------
    // Coptic month names (data-driven if the vector file exposes them)
    // -------------------------------------------------------------------------

    @TestFactory
    fun monthNames(): List<DynamicTest> {
        val list = vectors.getAsJsonArray("coptic_month_names") ?: return emptyList()
        return list.mapIndexed { i, raw ->
            val v = raw.asJsonObject
            DynamicTest.dynamicTest("month#$i") {
                assertEquals(
                    v["name"].asString,
                    CopticCalendar.monthName(v.int("month"), v["locale"].asString),
                )
            }
        }
    }

    @Test
    fun invalidMonthThrows() {
        assertThrows(InvalidCopticMonthException::class.java) {
            CopticCalendar.monthName(14, "en")
        }
    }

    @Test
    fun unsupportedLocaleThrows() {
        assertThrows(UnsupportedLocaleException::class.java) {
            CopticCalendar.monthName(1, "fr")
        }
    }

    @Test
    fun unknownMoveableFeastThrows() {
        assertThrows(UnknownFeastException::class.java) {
            CopticCalendar.moveableFeast("not_a_real_feast", 2025)
        }
    }

    // -------------------------------------------------------------------------
    // Validation negatives
    // -------------------------------------------------------------------------

    @TestFactory
    fun invalidGregorianDatesAreRejected(): List<DynamicTest> =
        vectors.array("invalid_gregorian_dates").mapIndexed { i, raw ->
            DynamicTest.dynamicTest("bad_g#$i") {
                val v = raw.asJsonObject
                assertThrows(InvalidGregorianDateException::class.java) {
                    GregorianDate(v.int("year"), v.int("month"), v.int("day"))
                }
            }
        }

    @TestFactory
    fun invalidCopticDatesAreRejected(): List<DynamicTest> =
        vectors.array("invalid_coptic_dates").mapIndexed { i, raw ->
            DynamicTest.dynamicTest("bad_c#$i") {
                val v = raw.asJsonObject
                assertThrows(InvalidCopticDateException::class.java) {
                    CopticDate(v.int("year"), v.int("month"), v.int("day"))
                }
            }
        }

    // -------------------------------------------------------------------------
    // LocalDate interop
    // -------------------------------------------------------------------------

    @Test
    fun localDateInterop() {
        val g = GregorianDate(2025, 1, 11)
        val ld = g.toLocalDate()
        assertEquals(LocalDate.of(2025, 1, 11), ld)
        assertEquals(g, GregorianDate.fromLocalDate(ld))
    }
}

private fun JsonObject.array(key: String): JsonArray = getAsJsonArray(key)
private fun JsonObject.obj(key: String): JsonObject = getAsJsonObject(key)
private fun JsonObject.int(key: String): Int = get(key).asInt
