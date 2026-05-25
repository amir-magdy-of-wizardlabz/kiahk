<p align="center">
  <img src="https://raw.githubusercontent.com/amir-magdy-of-wizardlabz/kiahk/master/assets/kiahk.png" alt="Kiahk logo" width="160">
</p>

# Kiahk (Kotlin / JVM)

[![Maven Central](https://img.shields.io/maven-central/v/com.wizardlabz/kiahk.svg?label=Maven%20Central)](https://central.sonatype.com/artifact/com.wizardlabz/kiahk)
[![Sonatype Central](https://img.shields.io/maven-central/last-update/com.wizardlabz/kiahk?label=last%20publish)](https://central.sonatype.com/artifact/com.wizardlabz/kiahk)
[![Kotlin version](https://img.shields.io/badge/Kotlin-2.0+-7F52FF.svg?logo=kotlin)](https://kotlinlang.org)
[![JVM target](https://img.shields.io/badge/JVM-11+-007396.svg?logo=openjdk)](https://openjdk.org)
[![license](https://img.shields.io/github/license/amir-magdy-of-wizardlabz/kiahk.svg)](../LICENSE)

> Maven Central doesn't expose public download counts. Adoption tracked via [Sonatype Central](https://central.sonatype.com/artifact/com.wizardlabz/kiahk) artifact page.

Coptic calendar arithmetic — date conversion, Easter, and feast days. Kotlin/JVM port of [kiahk](https://github.com/amir-magdy-of-wizardlabz/kiahk). Identical results to all other ports against `core/test-vectors.json`.

Pure Kotlin, no Android-specific dependencies — runs on the **JVM (server, desktop, CLI) and on Android (API 26+, with desugaring for older)**. JVM target: 11.

**Package:** <https://central.sonatype.com/artifact/com.wizardlabz/kiahk>

## Install

### Gradle (Kotlin DSL)

```kotlin
dependencies {
    implementation("com.wizardlabz:kiahk:0.1.5")
}
```

### Gradle (Groovy DSL)

```groovy
dependencies {
    implementation 'com.wizardlabz:kiahk:0.1.5'
}
```

### Maven

```xml
<dependency>
    <groupId>com.wizardlabz</groupId>
    <artifactId>kiahk</artifactId>
    <version>0.1.5</version>
</dependency>
```

## Quick start

```kotlin
import com.wizardlabz.kiahk.CopticCalendar
import com.wizardlabz.kiahk.CopticDate
import com.wizardlabz.kiahk.GregorianDate

fun main() {
    // Convert Gregorian → Coptic
    val g = GregorianDate(2025, 1, 11)
    val c = g.toCoptic()
    println("${c.year} ${c.month} ${c.day}") // 1741 5 3

    // Convert Coptic → Gregorian
    val c2 = CopticDate(1742, 1, 1)
    val g2 = c2.toGregorian()
    println("${g2.year} ${g2.month} ${g2.day}") // 2025 9 11

    // Coptic Easter for a Gregorian year
    val easter = CopticCalendar.easterDate(2025)
    println("${easter.year} ${easter.month} ${easter.day}") // 2025 4 20

    // All major feasts for a Gregorian year, sorted by date
    for (feast in CopticCalendar.yearFeasts(2025)) {
        val d = feast.gregorianDate
        println("%04d-%02d-%02d  %s".format(d.year, d.month, d.day, feast.name("en")))
    }
}
```

**Sample output:**

```
1741 5 3
2025 9 11
2025 4 20
2025-01-07  Nativity of Christ
2025-01-19  Epiphany (Theophany)
2025-02-10  Nineveh Fast
2025-02-24  Great Lent (start)
2025-04-07  Annunciation
2025-04-13  Palm Sunday
2025-04-20  Easter Sunday
2025-05-29  Ascension
2025-06-08  Pentecost
2025-08-22  Assumption of Mary
2025-09-27  Feast of the Cross
```

## Render a date in English and Arabic

```kotlin
val c = GregorianDate(2025, 4, 20).toCoptic()
println("${c.day} ${CopticCalendar.monthName(c.month, "en")} ${c.year} AM")
println("${c.day} ${CopticCalendar.monthName(c.month, "ar")} ${c.year} للشهداء")
```

**Sample output:**

```
12 Parmouti 1741 AM
12 برمودة 1741 للشهداء
```

## Java interop

All public APIs are accessible from Java via standard Kotlin interop:

```java
import com.wizardlabz.kiahk.*;

GregorianDate g = new GregorianDate(2025, 1, 11);
CopticDate c = g.toCoptic();
System.out.println(c.getYear() + " " + c.getMonth() + " " + c.getDay());

GregorianDate easter = CopticCalendar.easterDate(2025);
String monthName = CopticCalendar.monthName(4, "en"); // "Koiak"
```

## API at a glance

| Type / method | Purpose |
| --- | --- |
| `GregorianDate(year, month, day)` | Validating constructor; throws `InvalidGregorianDateException` on bad input |
| `GregorianDate.toCoptic(): CopticDate` | Convert |
| `GregorianDate.toLocalDate()` / `.fromLocalDate(LocalDate)` | Interop with `java.time.LocalDate` |
| `CopticDate(year, month, day)` | Validating constructor; throws `InvalidCopticDateException` on bad input |
| `CopticDate.toGregorian(): GregorianDate` | Convert |
| `Feast` | `id`, `type`, `category`, `gregorianDate`, `copticDate`, `name(locale)` |
| `Feast.name("fr")` | Throws `UnsupportedLocaleException` for unknown locale |
| `CopticCalendar.easterDate(year)` | Coptic Easter |
| `CopticCalendar.moveableFeast(feastId, year)` | One moveable feast |
| `CopticCalendar.fixedFeasts(year)` | Fixed feasts in a Gregorian year |
| `CopticCalendar.yearFeasts(year)` | All feasts, sorted ascending |
| `CopticCalendar.monthName(month, locale)` | Coptic month name; throws `InvalidCopticMonthException` / `UnsupportedLocaleException` |

Supported locales for `Feast.name(...)` and `CopticCalendar.monthName(...)`: `en`, `ar`.

## Run tests

```bash
cd kotlin
gradle test
# or, after generating wrapper: ./gradlew test
```

## License

Licensed under the [MIT License](../LICENSE).

Maintained by Amir Magdy at WizardLabz.
