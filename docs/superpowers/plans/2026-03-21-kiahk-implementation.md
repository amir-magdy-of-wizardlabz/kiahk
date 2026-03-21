# Kiahk Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build Kiahk — a zero-dependency, multi-language Coptic calendar library — across TypeScript, Python, Dart, Swift, Kotlin, and C#, with shared test vectors and a polished README.

**Architecture:** Monorepo with a `core/` layer (algorithm docs, feast registry, test vectors JSON) shared across all 6 language implementations. Each language is an independent package with its own build tooling and test suite, all reading `../../core/test-vectors.json` for data-driven correctness tests.

**Tech Stack:** TypeScript + Vitest, Python + pytest, Dart + dart test, Swift + XCTest, Kotlin + JUnit5, C# + xUnit. All packages published independently (npm, PyPI, pub.dev, SwiftPM, Maven, NuGet).

---

## File Map

```text
kiahk/
├── .gitignore
├── README.md
├── assets/
│   └── icon.svg                        # A4-R1 amber calendar icon
├── core/
│   ├── algorithms.md                   # Canonical algorithm docs (JDN, Butcher, feasts)
│   ├── feasts.json                     # Master feast registry (id, names, type, category, offsets)
│   └── test-vectors.json               # Cross-language test oracle (Easter 2025-2037)
├── js/
│   ├── package.json                    # npm: kiahk
│   ├── tsconfig.json
│   ├── vitest.config.ts
│   ├── README.md
│   └── src/
│       ├── index.ts                    # Public exports
│       ├── CopticDate.ts
│       ├── GregorianDate.ts
│       ├── Feast.ts                    # Feast, FeastType, FeastCategory
│       ├── CopticCalendar.ts           # Static calendar methods
│       ├── algorithms.ts               # JDN conversion + Butcher's Easter
│       ├── feasts-data.ts              # Loads feasts.json at build time
│       └── errors.ts                  # Typed exceptions
│   └── tests/
│       └── kiahk.test.ts               # Data-driven from test-vectors.json
├── python/
│   ├── pyproject.toml                  # PyPI: kiahk
│   ├── README.md
│   └── kiahk/
│       ├── __init__.py                 # Public exports
│       ├── _algorithms.py              # JDN + Butcher
│       ├── _feasts_data.py             # Loads feasts.json
│       ├── coptic_date.py
│       ├── gregorian_date.py
│       ├── feast.py                    # Feast, FeastType, FeastCategory
│       ├── coptic_calendar.py
│       └── errors.py
│   └── tests/
│       ├── conftest.py                 # Loads test-vectors.json as fixtures
│       └── test_kiahk.py
├── dart/
│   ├── pubspec.yaml                    # pub.dev: kiahk
│   ├── README.md
│   └── lib/
│       ├── kiahk.dart                  # Public exports
│       ├── src/
│       │   ├── algorithms.dart
│       │   ├── coptic_date.dart
│       │   ├── gregorian_date.dart
│       │   ├── feast.dart
│       │   ├── coptic_calendar.dart
│       │   └── errors.dart
│   └── test/
│       └── kiahk_test.dart
├── swift/
│   ├── Package.swift                   # SwiftPM: Kiahk
│   ├── README.md
│   └── Sources/Kiahk/
│       ├── Algorithms.swift
│       ├── CopticDate.swift
│       ├── GregorianDate.swift
│       ├── Feast.swift
│       ├── CopticCalendar.swift
│       └── Errors.swift
│   └── Tests/KiahkTests/
│       └── KiahkTests.swift
├── kotlin/
│   ├── build.gradle.kts                # Maven: io.kiahk:calendar
│   ├── settings.gradle.kts
│   ├── README.md
│   └── src/main/kotlin/io/kiahk/
│       ├── Algorithms.kt
│       ├── CopticDate.kt
│       ├── GregorianDate.kt
│       ├── Feast.kt
│       ├── CopticCalendar.kt
│       └── Errors.kt
│   └── src/test/kotlin/io/kiahk/
│       └── KiahkTest.kt
└── csharp/
    ├── Kiahk.csproj                    # NuGet: Kiahk
    ├── README.md
    └── src/
        ├── Algorithms.cs
        ├── CopticDate.cs
        ├── GregorianDate.cs
        ├── Feast.cs
        ├── CopticCalendar.cs
        └── Errors.cs
    └── tests/
        ├── Kiahk.Tests.csproj
        └── KiahkTests.cs
```

---

## Task 1: Repo Foundation

**Files:**
- Create: `.gitignore`
- Create: `assets/icon.svg`

- [ ] **Step 1: Create .gitignore**

```text
# Node
node_modules/
dist/
*.tsbuildinfo

# Python
__pycache__/
*.pyc
.venv/
dist/
*.egg-info/

# Dart
.dart_tool/
build/

# Swift
.build/
*.xcodeproj/

# Kotlin/Gradle
.gradle/
build/

# C#
bin/
obj/
*.user

# General
.DS_Store
.superpowers/
```

- [ ] **Step 2: Create `assets/icon.svg`**

```svg
<svg width="88" height="88" viewBox="0 0 88 88" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="4" y="10" width="80" height="72" rx="9" fill="#fff7ed" stroke="#d97706" stroke-width="2"/>
  <rect x="4" y="10" width="80" height="24" rx="9" fill="#b45309"/>
  <rect x="4" y="26" width="80" height="8" fill="#b45309"/>
  <rect x="24" y="4" width="6" height="14" rx="3" fill="#92400e"/>
  <rect x="58" y="4" width="6" height="14" rx="3" fill="#92400e"/>
  <text x="44" y="23.5" text-anchor="middle" font-family="Georgia, serif" font-size="14" font-weight="bold" fill="#fef9c3" letter-spacing="2">ⲔⲒⲀϨⲔ</text>
  <rect x="41" y="38" width="6" height="30" rx="2.5" fill="#92400e"/>
  <rect x="28" y="49" width="32" height="6" rx="2.5" fill="#92400e"/>
  <rect x="38.5" y="38" width="11" height="3.5" rx="2" fill="#d97706"/>
  <rect x="38.5" y="64.5" width="11" height="3.5" rx="2" fill="#d97706"/>
  <rect x="28" y="47" width="3.5" height="11" rx="2" fill="#d97706"/>
  <rect x="56.5" y="47" width="3.5" height="11" rx="2" fill="#d97706"/>
</svg>
```

- [ ] **Step 3: Commit**

```bash
git init
git add .gitignore assets/icon.svg
git commit -m "chore: repo foundation — gitignore and icon"
```

---

## Task 2: Core Layer

**Files:**
- Create: `core/algorithms.md`
- Create: `core/feasts.json`
- Create: `core/test-vectors.json`

- [ ] **Step 1: Create `core/algorithms.md`**

```markdown
# Kiahk — Canonical Algorithms

## 1. Gregorian → Coptic (Julian Day Number method)

Epoch: JDN 1825030 = 1 Toot 1 AM (Coptic year 1, month 1, day 1).

### Steps

1. Compute JDN from Gregorian date:
   - a = floor((14 - month) / 12)
   - y = year + 4800 - a
   - m = month + 12*a - 3
   - JDN = day + floor((153*m + 2)/5) + 365*y + floor(y/4) - floor(y/100) + floor(y/400) - 32045

2. Subtract epoch and derive Coptic fields:
   - r = JDN - 1825030
   - copticYear  = floor((r - 1) / 365.25) treated as: floor(4*(r-1) + 3) / 1461  [i.e. floor((4*r+1463)/1461) - 1]
     Precisely: copticYear = floor((4*(JDN - 1825030) + 1463) / 1461) - 1
   - dayOfYear = JDN - 1825030 - 365*copticYear - floor(copticYear/4)
   - copticMonth = floor(dayOfYear / 30) + 1
   - copticDay   = dayOfYear - 30*(copticMonth - 1) + 1
   Note: if copticMonth > 13 clamp to 13 (Nasie/intercalary month).

### Reference implementation (pseudocode)

```
function gregorianToCoptic(gYear, gMonth, gDay):
  a   = (14 - gMonth) / 12          # integer division
  y   = gYear + 4800 - a
  m   = gMonth + 12*a - 3
  jdn = gDay + (153*m + 2)/5 + 365*y + y/4 - y/100 + y/400 - 32045

  cYear  = (4*(jdn - 1825030) + 1463) / 1461 - 1   # integer division
  remain = jdn - 1825030 - 365*cYear - cYear/4
  cMonth = remain / 30 + 1
  cDay   = remain - 30*(cMonth - 1) + 1
  return (cYear, cMonth, cDay)
```

## 2. Coptic → Gregorian (Reverse JDN)

```
function copticToGregorian(cYear, cMonth, cDay):
  jdn = cDay + 30*(cMonth - 1) + 365*cYear + cYear/4 + 1825030 - 1
  # Convert JDN to Gregorian:
  a   = jdn + 32044
  b   = (4*a + 3) / 146097
  c   = a - (146097*b) / 4
  d   = (4*c + 3) / 1461
  e   = c - (1461*d) / 4
  m   = (5*e + 2) / 153
  gDay   = e - (153*m + 2)/5 + 1
  gMonth = m + 3 - 12*(m/10)
  gYear  = 100*b + d - 4800 + m/10
  return (gYear, gMonth, gDay)
```

## 3. Coptic Easter (Butcher's Algorithm)

Based on the Julian calendar, then offset +13 days to Gregorian.

```
function copticEaster(gregorianYear):
  # Work in Julian calendar
  a = gregorianYear % 4
  b = gregorianYear % 7
  c = gregorianYear % 19
  d = (19*c + 15) % 30
  e = (2*a + 4*b - d + 34) % 7
  f = (d + e + 114) / 31          # integer division → month (3=March, 4=April)
  g = (d + e + 114) % 31 + 1      # day

  # Julian Easter: month=f, day=g
  # Add 13-day offset for Gregorian calendar
  julianDate = GregorianDate(gregorianYear, f, g)   # treat as Julian
  return julianDate + 13 days
```

## 4. Moveable Feasts

All moveable feasts are derived from Easter Sunday:

```
feastDate = easterDate + easterOffset (days)
```

Negative offset = before Easter. Positive = after.

Key offsets (see feasts.json for full list):
| Feast             | Offset |
|-------------------|--------|
| Nineveh Fast      | -69    |
| Great Lent        | -55    |
| Palm Sunday       | -7     |
| Easter            | 0      |
| Ascension         | +39    |
| Pentecost         | +49    |
```

- [ ] **Step 2: Create `core/feasts.json`**

Include all Coptic feasts — major fixed, minor fixed, and all moveable. At minimum:

```json
[
  {
    "id": "nativity",
    "names": { "en": "Nativity of Christ", "ar": "عيد الميلاد المجيد" },
    "type": "fixed", "category": "major",
    "coptic_month": 4, "coptic_day": 29
  },
  {
    "id": "epiphany",
    "names": { "en": "Epiphany (Theophany)", "ar": "عيد الغطاس" },
    "type": "fixed", "category": "major",
    "coptic_month": 5, "coptic_day": 11
  },
  {
    "id": "annunciation",
    "names": { "en": "Annunciation", "ar": "عيد البشارة" },
    "type": "fixed", "category": "major",
    "coptic_month": 7, "coptic_day": 29
  },
  {
    "id": "assumption",
    "names": { "en": "Assumption of Mary", "ar": "عيد انتقال العذراء" },
    "type": "fixed", "category": "major",
    "coptic_month": 12, "coptic_day": 16
  },
  {
    "id": "cross",
    "names": { "en": "Feast of the Cross", "ar": "عيد الصليب" },
    "type": "fixed", "category": "major",
    "coptic_month": 1, "coptic_day": 17
  },
  {
    "id": "nineveh_fast",
    "names": { "en": "Nineveh Fast", "ar": "صوم نينوى" },
    "type": "moveable", "category": "major",
    "easter_offset": -69
  },
  {
    "id": "great_lent",
    "names": { "en": "Great Lent (start)", "ar": "بداية الصوم الكبير" },
    "type": "moveable", "category": "major",
    "easter_offset": -55
  },
  {
    "id": "palm_sunday",
    "names": { "en": "Palm Sunday", "ar": "أحد الشعانين" },
    "type": "moveable", "category": "major",
    "easter_offset": -7
  },
  {
    "id": "easter",
    "names": { "en": "Easter Sunday", "ar": "عيد القيامة المجيد" },
    "type": "moveable", "category": "major",
    "easter_offset": 0
  },
  {
    "id": "ascension",
    "names": { "en": "Ascension", "ar": "عيد الصعود" },
    "type": "moveable", "category": "major",
    "easter_offset": 39
  },
  {
    "id": "pentecost",
    "names": { "en": "Pentecost", "ar": "عيد العنصرة" },
    "type": "moveable", "category": "major",
    "easter_offset": 49
  }
]
```

- [ ] **Step 3: Create `core/test-vectors.json`**

Verified against printed Coptic calendars. Nineveh Fast used as ground truth.

```json
{
  "gregorian_to_coptic": [
    { "gregorian": { "year": 2025, "month": 1,  "day": 11 }, "coptic": { "year": 1741, "month": 5,  "day": 2  } },
    { "gregorian": { "year": 2025, "month": 9,  "day": 11 }, "coptic": { "year": 1742, "month": 1,  "day": 1  } },
    { "gregorian": { "year": 2000, "month": 1,  "day": 1  }, "coptic": { "year": 1716, "month": 4,  "day": 22 } },
    { "gregorian": { "year": 2024, "month": 12, "day": 25 }, "coptic": { "year": 1741, "month": 4,  "day": 15 } },
    { "gregorian": { "year": 1900, "month": 1,  "day": 1  }, "coptic": { "year": 1616, "month": 4,  "day": 22 } }
  ],
  "coptic_to_gregorian": [
    { "coptic": { "year": 1741, "month": 5,  "day": 2  }, "gregorian": { "year": 2025, "month": 1,  "day": 11 } },
    { "coptic": { "year": 1742, "month": 1,  "day": 1  }, "gregorian": { "year": 2025, "month": 9,  "day": 11 } },
    { "coptic": { "year": 1716, "month": 4,  "day": 22 }, "gregorian": { "year": 2000, "month": 1,  "day": 1  } },
    { "coptic": { "year": 1741, "month": 4,  "day": 15 }, "gregorian": { "year": 2024, "month": 12, "day": 25 } }
  ],
  "easter": [
    { "gregorian_year": 2025, "date": { "year": 2025, "month": 4,  "day": 20 } },
    { "gregorian_year": 2026, "date": { "year": 2026, "month": 4,  "day": 5  } },
    { "gregorian_year": 2027, "date": { "year": 2027, "month": 4,  "day": 25 } },
    { "gregorian_year": 2028, "date": { "year": 2028, "month": 4,  "day": 16 } },
    { "gregorian_year": 2029, "date": { "year": 2029, "month": 5,  "day": 6  } },
    { "gregorian_year": 2030, "date": { "year": 2030, "month": 4,  "day": 21 } },
    { "gregorian_year": 2031, "date": { "year": 2031, "month": 4,  "day": 13 } },
    { "gregorian_year": 2032, "date": { "year": 2032, "month": 5,  "day": 2  } },
    { "gregorian_year": 2033, "date": { "year": 2033, "month": 4,  "day": 17 } },
    { "gregorian_year": 2034, "date": { "year": 2034, "month": 4,  "day": 9  } },
    { "gregorian_year": 2035, "date": { "year": 2035, "month": 4,  "day": 29 } },
    { "gregorian_year": 2036, "date": { "year": 2036, "month": 4,  "day": 20 } },
    { "gregorian_year": 2037, "date": { "year": 2037, "month": 4,  "day": 5  } }
  ],
  "moveable_feasts": [
    { "gregorian_year": 2025, "feast_id": "nineveh_fast", "date": { "year": 2025, "month": 2,  "day": 10 } },
    { "gregorian_year": 2025, "feast_id": "palm_sunday",  "date": { "year": 2025, "month": 4,  "day": 13 } },
    { "gregorian_year": 2025, "feast_id": "ascension",    "date": { "year": 2025, "month": 5,  "day": 29 } },
    { "gregorian_year": 2025, "feast_id": "pentecost",    "date": { "year": 2025, "month": 6,  "day": 8  } },
    { "gregorian_year": 2026, "feast_id": "nineveh_fast", "date": { "year": 2026, "month": 1,  "day": 26 } },
    { "gregorian_year": 2026, "feast_id": "easter",       "date": { "year": 2026, "month": 4,  "day": 5  } }
  ],
  "invalid_coptic_dates": [
    { "year": 1741, "month": 0,  "day": 1  },
    { "year": 1741, "month": 14, "day": 1  },
    { "year": 1741, "month": 1,  "day": 31 },
    { "year": 1741, "month": 13, "day": 7  }
  ],
  "invalid_gregorian_dates": [
    { "year": 2025, "month": 0,  "day": 1  },
    { "year": 2025, "month": 13, "day": 1  },
    { "year": 2025, "month": 2,  "day": 29 },
    { "year": 2025, "month": 4,  "day": 31 }
  ]
}
```

- [ ] **Step 4: Commit**

```bash
git add core/
git commit -m "feat(core): algorithms doc, feast registry, and test vectors"
```

---

## Task 3: TypeScript/JS Package

**Files:**
- Create: `js/package.json`, `js/tsconfig.json`, `js/vitest.config.ts`
- Create: `js/src/errors.ts`, `js/src/algorithms.ts`, `js/src/CopticDate.ts`
- Create: `js/src/GregorianDate.ts`, `js/src/Feast.ts`, `js/src/CopticCalendar.ts`
- Create: `js/src/index.ts`
- Create: `js/tests/kiahk.test.ts`

- [ ] **Step 1: Create package config files**

`js/package.json`:

```json
{
  "name": "kiahk",
  "version": "0.1.0",
  "description": "Coptic calendar arithmetic — date conversion, Easter, and feast days",
  "type": "module",
  "main": "./dist/index.cjs",
  "module": "./dist/index.js",
  "types": "./dist/index.d.ts",
  "exports": {
    ".": {
      "import": "./dist/index.js",
      "require": "./dist/index.cjs",
      "types": "./dist/index.d.ts"
    }
  },
  "scripts": {
    "build": "tsc",
    "test": "vitest run",
    "test:watch": "vitest"
  },
  "keywords": ["coptic", "calendar", "easter", "coptic-calendar", "kiahk"],
  "license": "MIT",
  "devDependencies": {
    "typescript": "^5.4.0",
    "vitest": "^1.6.0",
    "@types/node": "^20.0.0"
  }
}
```

`js/tsconfig.json`:

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "strict": true,
    "declaration": true,
    "outDir": "./dist",
    "resolveJsonModule": true
  },
  "include": ["src"]
}
```

`js/vitest.config.ts`:

```typescript
import { defineConfig } from 'vitest/config'
export default defineConfig({
  test: { globals: true }
})
```

- [ ] **Step 2: Write failing tests**

`js/tests/kiahk.test.ts`:

```typescript
import { describe, it, expect } from 'vitest'
import { readFileSync } from 'fs'
import { resolve } from 'path'
import {
  CopticDate, GregorianDate, CopticCalendar,
  InvalidCopticDateException, InvalidGregorianDateException, UnsupportedLocaleException
} from '../src/index.js'

const vectors = JSON.parse(
  readFileSync(resolve(__dirname, '../../core/test-vectors.json'), 'utf8')
)

describe('Gregorian → Coptic', () => {
  it.each(vectors.gregorian_to_coptic)('converts $gregorian to $coptic', ({ gregorian, coptic }) => {
    const g = new GregorianDate(gregorian.year, gregorian.month, gregorian.day)
    const c = g.toCoptic()
    expect(c.year).toBe(coptic.year)
    expect(c.month).toBe(coptic.month)
    expect(c.day).toBe(coptic.day)
  })
})

describe('Coptic → Gregorian', () => {
  it.each(vectors.coptic_to_gregorian)('converts $coptic to $gregorian', ({ coptic, gregorian }) => {
    const c = new CopticDate(coptic.year, coptic.month, coptic.day)
    const g = c.toGregorian()
    expect(g.year).toBe(gregorian.year)
    expect(g.month).toBe(gregorian.month)
    expect(g.day).toBe(gregorian.day)
  })
})

describe('Easter', () => {
  it.each(vectors.easter)('easter $gregorian_year', ({ gregorian_year, date }) => {
    const easter = CopticCalendar.easterDate(gregorian_year)
    expect(easter.year).toBe(date.year)
    expect(easter.month).toBe(date.month)
    expect(easter.day).toBe(date.day)
  })
})

describe('Moveable feasts', () => {
  it.each(vectors.moveable_feasts)('$feast_id in $gregorian_year', ({ gregorian_year, feast_id, date }) => {
    const feast = CopticCalendar.moveableFeast(feast_id, gregorian_year)
    expect(feast.gregorianDate.year).toBe(date.year)
    expect(feast.gregorianDate.month).toBe(date.month)
    expect(feast.gregorianDate.day).toBe(date.day)
  })
})

describe('Feast.name()', () => {
  it('returns English name', () => {
    const feast = CopticCalendar.moveableFeast('easter', 2025)
    expect(feast.name('en')).toBe('Easter Sunday')
  })
  it('returns Arabic name', () => {
    const feast = CopticCalendar.moveableFeast('easter', 2025)
    expect(feast.name('ar')).toBe('عيد القيامة المجيد')
  })
  it('throws UnsupportedLocaleException for unknown locale', () => {
    const feast = CopticCalendar.moveableFeast('easter', 2025)
    expect(() => feast.name('fr')).toThrow(UnsupportedLocaleException)
  })
})

describe('Invalid dates', () => {
  it.each(vectors.invalid_coptic_dates)('throws for invalid coptic $month/$day', ({ year, month, day }) => {
    expect(() => new CopticDate(year, month, day)).toThrow(InvalidCopticDateException)
  })
  it.each(vectors.invalid_gregorian_dates)('throws for invalid gregorian $month/$day', ({ year, month, day }) => {
    expect(() => new GregorianDate(year, month, day)).toThrow(InvalidGregorianDateException)
  })
})

describe('GregorianDate.toNativeDate()', () => {
  it('returns a JS Date', () => {
    const g = new GregorianDate(2025, 1, 11)
    const d = g.toNativeDate()
    expect(d).toBeInstanceOf(Date)
    expect(d.getFullYear()).toBe(2025)
    expect(d.getMonth()).toBe(0) // 0-indexed
    expect(d.getDate()).toBe(11)
  })
})

describe('GregorianDate.fromNativeDate()', () => {
  it('round-trips a JS Date', () => {
    const native = new Date(2025, 0, 11)
    const g = GregorianDate.fromNativeDate(native)
    expect(g.year).toBe(2025)
    expect(g.month).toBe(1)
    expect(g.day).toBe(11)
  })
})

describe('yearFeasts', () => {
  it('returns feasts sorted by date', () => {
    const feasts = CopticCalendar.yearFeasts(2025)
    expect(feasts.length).toBeGreaterThan(0)
    for (let i = 1; i < feasts.length; i++) {
      const a = feasts[i - 1].gregorianDate
      const b = feasts[i].gregorianDate
      const aMs = new Date(a.year, a.month - 1, a.day).getTime()
      const bMs = new Date(b.year, b.month - 1, b.day).getTime()
      expect(aMs).toBeLessThanOrEqual(bMs)
    }
  })
})
```

- [ ] **Step 3: Run tests to confirm they fail**

```bash
cd js && npm install && npm test
```

Expected: module not found errors — src files don't exist yet.

- [ ] **Step 4: Implement `src/errors.ts`**

```typescript
export class InvalidCopticDateException extends Error {
  constructor(year: number, month: number, day: number) {
    super(`Invalid Coptic date: ${year}/${month}/${day}`)
    this.name = 'InvalidCopticDateException'
  }
}

export class InvalidGregorianDateException extends Error {
  constructor(year: number, month: number, day: number) {
    super(`Invalid Gregorian date: ${year}/${month}/${day}`)
    this.name = 'InvalidGregorianDateException'
  }
}

export class UnsupportedLocaleException extends Error {
  constructor(locale: string) {
    super(`Unsupported locale: ${locale}`)
    this.name = 'UnsupportedLocaleException'
  }
}
```

- [ ] **Step 5: Implement `src/algorithms.ts`**

```typescript
/** Gregorian date → Julian Day Number */
export function gregorianToJdn(year: number, month: number, day: number): number {
  const a = Math.floor((14 - month) / 12)
  const y = year + 4800 - a
  const m = month + 12 * a - 3
  return day + Math.floor((153 * m + 2) / 5) + 365 * y +
    Math.floor(y / 4) - Math.floor(y / 100) + Math.floor(y / 400) - 32045
}

/** Julian Day Number → Gregorian date */
export function jdnToGregorian(jdn: number): [number, number, number] {
  const a = jdn + 32044
  const b = Math.floor((4 * a + 3) / 146097)
  const c = a - Math.floor((146097 * b) / 4)
  const d = Math.floor((4 * c + 3) / 1461)
  const e = c - Math.floor((1461 * d) / 4)
  const m = Math.floor((5 * e + 2) / 153)
  const day = e - Math.floor((153 * m + 2) / 5) + 1
  const month = m + 3 - 12 * Math.floor(m / 10)
  const year = 100 * b + d - 4800 + Math.floor(m / 10)
  return [year, month, day]
}

const COPTIC_EPOCH = 1825030

/** Gregorian → Coptic via JDN */
export function gregorianToCoptic(gYear: number, gMonth: number, gDay: number): [number, number, number] {
  const jdn = gregorianToJdn(gYear, gMonth, gDay)
  const r = jdn - COPTIC_EPOCH
  const cYear = Math.floor((4 * r + 1463) / 1461) - 1
  const remain = r - 365 * cYear - Math.floor(cYear / 4)
  const cMonth = Math.floor(remain / 30) + 1
  const cDay = remain - 30 * (cMonth - 1) + 1
  return [cYear, Math.min(cMonth, 13), cDay]
}

/** Coptic → Gregorian via JDN */
export function copticToGregorian(cYear: number, cMonth: number, cDay: number): [number, number, number] {
  const jdn = cDay + 30 * (cMonth - 1) + 365 * cYear + Math.floor(cYear / 4) + COPTIC_EPOCH - 1
  return jdnToGregorian(jdn)
}

/** Coptic Easter (Butcher's algorithm + 13-day Gregorian offset) */
export function computeEaster(gregorianYear: number): [number, number, number] {
  const a = gregorianYear % 4
  const b = gregorianYear % 7
  const c = gregorianYear % 19
  const d = (19 * c + 15) % 30
  const e = (2 * a + 4 * b - d + 34) % 7
  const f = Math.floor((d + e + 114) / 31)  // month
  const g = ((d + e + 114) % 31) + 1        // day
  // Julian Easter date, add 13 days for Gregorian
  const jdn = gregorianToJdn(gregorianYear, f, g) + 13
  return jdnToGregorian(jdn)
}

/** Add N days to a Gregorian date, returns new [year, month, day] */
export function addDays(year: number, month: number, day: number, days: number): [number, number, number] {
  const jdn = gregorianToJdn(year, month, day) + days
  return jdnToGregorian(jdn)
}
```

- [ ] **Step 6: Implement `src/CopticDate.ts`**

ESM handles mutual imports between `CopticDate` and `GregorianDate` correctly because
neither class's module-level code instantiates the other — only method bodies do, and by
then both modules are fully initialised. Direct top-level imports are safe here.

```typescript
import { copticToGregorian } from './algorithms.js'
import { InvalidCopticDateException } from './errors.js'
import { GregorianDate } from './GregorianDate.js'

function daysInCopticMonth(month: number, year: number): number {
  if (month >= 1 && month <= 12) return 30
  if (month === 13) return year % 4 === 3 ? 6 : 5
  return 0
}

export class CopticDate {
  readonly year: number
  readonly month: number
  readonly day: number

  constructor(year: number, month: number, day: number) {
    const maxDay = daysInCopticMonth(month, year)
    if (month < 1 || month > 13 || day < 1 || day > maxDay) {
      throw new InvalidCopticDateException(year, month, day)
    }
    this.year = year
    this.month = month
    this.day = day
  }

  toGregorian(): GregorianDate {
    const [y, m, d] = copticToGregorian(this.year, this.month, this.day)
    return new GregorianDate(y, m, d)
  }

  toString(): string {
    return `${this.year}/${String(this.month).padStart(2,'0')}/${String(this.day).padStart(2,'0')}`
  }
}
```

- [ ] **Step 7: Implement `src/GregorianDate.ts`**

```typescript
import { gregorianToCoptic } from './algorithms.js'
import { InvalidGregorianDateException } from './errors.js'
import { CopticDate } from './CopticDate.js'

const DAYS_IN_MONTH = [0,31,28,31,30,31,30,31,31,30,31,30,31]
function isLeap(y: number) { return (y%4===0 && y%100!==0) || y%400===0 }
function daysInGregorianMonth(month: number, year: number): number {
  if (month === 2 && isLeap(year)) return 29
  return DAYS_IN_MONTH[month] ?? 0
}

export class GregorianDate {
  readonly year: number
  readonly month: number
  readonly day: number

  constructor(year: number, month: number, day: number) {
    const maxDay = daysInGregorianMonth(month, year)
    if (month < 1 || month > 12 || day < 1 || day > maxDay) {
      throw new InvalidGregorianDateException(year, month, day)
    }
    this.year = year
    this.month = month
    this.day = day
  }

  toCoptic(): CopticDate {
    const [y, m, d] = gregorianToCoptic(this.year, this.month, this.day)
    return new CopticDate(y, m, d)
  }

  toNativeDate(): Date {
    return new Date(this.year, this.month - 1, this.day)
  }

  static fromNativeDate(date: Date): GregorianDate {
    return new GregorianDate(date.getFullYear(), date.getMonth() + 1, date.getDate())
  }

  toString(): string {
    return `${this.year}-${String(this.month).padStart(2,'0')}-${String(this.day).padStart(2,'0')}`
  }
}
```

- [ ] **Step 8: Implement `src/Feast.ts`**

```typescript
import { UnsupportedLocaleException } from './errors.js'
import type { GregorianDate } from './GregorianDate.js'
import type { CopticDate } from './CopticDate.js'

export type FeastType = 'moveable' | 'fixed'
export type FeastCategory = 'major' | 'minor'

export interface FeastData {
  id: string
  names: Record<string, string>
  type: FeastType
  category: FeastCategory
  easter_offset?: number
  coptic_month?: number
  coptic_day?: number
}

export class Feast {
  readonly id: string
  readonly type: FeastType
  readonly category: FeastCategory
  readonly easterOffset: number | null
  readonly gregorianDate: GregorianDate
  readonly copticDate: CopticDate
  private readonly _names: Record<string, string>

  constructor(
    data: FeastData,
    gregorianDate: GregorianDate,
    copticDate: CopticDate
  ) {
    this.id = data.id
    this.type = data.type
    this.category = data.category
    this.easterOffset = data.easter_offset ?? null
    this.gregorianDate = gregorianDate
    this.copticDate = copticDate
    this._names = data.names
  }

  name(locale: string): string {
    if (!(locale in this._names)) throw new UnsupportedLocaleException(locale)
    return this._names[locale]
  }
}
```

- [ ] **Step 9: Implement `src/feasts-data.ts`**

```typescript
import { readFileSync } from 'fs'
import { resolve, dirname } from 'path'
import { fileURLToPath } from 'url'
import type { FeastData } from './Feast.js'

const __dirname = dirname(fileURLToPath(import.meta.url))
const feastsPath = resolve(__dirname, '../../../core/feasts.json')
export const FEASTS: FeastData[] = JSON.parse(readFileSync(feastsPath, 'utf8'))
```

- [ ] **Step 10: Implement `src/CopticCalendar.ts`**

```typescript
import { computeEaster, addDays } from './algorithms.js'
import { GregorianDate } from './GregorianDate.js'
import { Feast } from './Feast.js'
import { FEASTS } from './feasts-data.js'

export class CopticCalendar {
  private constructor() {}

  static easterDate(gregorianYear: number): GregorianDate {
    const [y, m, d] = computeEaster(gregorianYear)
    return new GregorianDate(y, m, d)
  }

  static moveableFeast(feastId: string, gregorianYear: number): Feast {
    const data = FEASTS.find(f => f.id === feastId && f.type === 'moveable')
    if (!data) throw new Error(`Unknown moveable feast: ${feastId}`)
    const easter = this.easterDate(gregorianYear)
    const [y, m, d] = addDays(easter.year, easter.month, easter.day, data.easter_offset!)
    const gDate = new GregorianDate(y, m, d)
    return new Feast(data, gDate, gDate.toCoptic())
  }

  static fixedFeasts(gregorianYear: number): Feast[] {
    return FEASTS
      .filter(f => f.type === 'fixed')
      .map(data => {
        const gDate = new GregorianDate(gregorianYear, data.coptic_month!, data.coptic_day!)
          .toCoptic()
          .toGregorian()
        return new Feast(data, gDate, gDate.toCoptic())
      })
  }

  static yearFeasts(gregorianYear: number): Feast[] {
    const moveable = FEASTS
      .filter(f => f.type === 'moveable')
      .map(data => this.moveableFeast(data.id, gregorianYear))
    const fixed = this.fixedFeasts(gregorianYear)
    return [...fixed, ...moveable].sort((a, b) => {
      const ag = a.gregorianDate, bg = b.gregorianDate
      return new Date(ag.year, ag.month - 1, ag.day).getTime()
           - new Date(bg.year, bg.month - 1, bg.day).getTime()
    })
  }
}
```

- [ ] **Step 11: Create `src/index.ts`**

```typescript
export { CopticDate } from './CopticDate.js'
export { GregorianDate } from './GregorianDate.js'
export { Feast, FeastType, FeastCategory } from './Feast.js'
export { CopticCalendar } from './CopticCalendar.js'
export {
  InvalidCopticDateException,
  InvalidGregorianDateException,
  UnsupportedLocaleException
} from './errors.js'
```

- [ ] **Step 12: Run tests**

```bash
cd js && npm test
```

Expected: all tests pass.

- [ ] **Step 13: Commit**

```bash
git add js/
git commit -m "feat(js): TypeScript/npm package with full test suite"
```

---

## Task 4: Python Package

**Files:**
- Create: `python/pyproject.toml`
- Create: `python/kiahk/__init__.py`, `_algorithms.py`, `_feasts_data.py`
- Create: `python/kiahk/coptic_date.py`, `gregorian_date.py`, `feast.py`, `coptic_calendar.py`, `errors.py`
- Create: `python/tests/conftest.py`, `test_kiahk.py`

- [ ] **Step 1: Create `python/pyproject.toml`**

```toml
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "kiahk"
version = "0.1.0"
description = "Coptic calendar arithmetic — date conversion, Easter, and feast days"
readme = "README.md"
license = { text = "MIT" }
requires-python = ">=3.9"
keywords = ["coptic", "calendar", "easter", "coptic-calendar"]

[project.optional-dependencies]
dev = ["pytest>=8.0", "pytest-cov"]

[tool.pytest.ini_options]
testpaths = ["tests"]
```

- [ ] **Step 2: Write failing tests — `python/tests/conftest.py`**

```python
import json
import pathlib
import pytest

VECTORS_PATH = pathlib.Path(__file__).parent.parent.parent / "core" / "test-vectors.json"

@pytest.fixture(scope="session")
def vectors():
    return json.loads(VECTORS_PATH.read_text())
```

- [ ] **Step 3: Write failing tests — `python/tests/test_kiahk.py`**

```python
import pytest
import datetime
from kiahk import CopticDate, GregorianDate, CopticCalendar
from kiahk.errors import InvalidCopticDateException, InvalidGregorianDateException, UnsupportedLocaleException

def test_gregorian_to_coptic(vectors):
    for v in vectors["gregorian_to_coptic"]:
        g = GregorianDate(v["gregorian"]["year"], v["gregorian"]["month"], v["gregorian"]["day"])
        c = g.to_coptic()
        assert c.year == v["coptic"]["year"]
        assert c.month == v["coptic"]["month"]
        assert c.day == v["coptic"]["day"]

def test_coptic_to_gregorian(vectors):
    for v in vectors["coptic_to_gregorian"]:
        c = CopticDate(v["coptic"]["year"], v["coptic"]["month"], v["coptic"]["day"])
        g = c.to_gregorian()
        assert g.year == v["gregorian"]["year"]
        assert g.month == v["gregorian"]["month"]
        assert g.day == v["gregorian"]["day"]

def test_easter(vectors):
    for v in vectors["easter"]:
        easter = CopticCalendar.easter_date(v["gregorian_year"])
        assert easter.year == v["date"]["year"]
        assert easter.month == v["date"]["month"]
        assert easter.day == v["date"]["day"]

def test_moveable_feasts(vectors):
    for v in vectors["moveable_feasts"]:
        feast = CopticCalendar.moveable_feast(v["feast_id"], v["gregorian_year"])
        assert feast.gregorian_date.year == v["date"]["year"]
        assert feast.gregorian_date.month == v["date"]["month"]
        assert feast.gregorian_date.day == v["date"]["day"]

def test_feast_name_en():
    feast = CopticCalendar.moveable_feast("easter", 2025)
    assert feast.name("en") == "Easter Sunday"

def test_feast_name_ar():
    feast = CopticCalendar.moveable_feast("easter", 2025)
    assert feast.name("ar") == "عيد القيامة المجيد"

def test_feast_name_unsupported_locale():
    feast = CopticCalendar.moveable_feast("easter", 2025)
    with pytest.raises(UnsupportedLocaleException):
        feast.name("fr")

def test_invalid_coptic_dates(vectors):
    for v in vectors["invalid_coptic_dates"]:
        with pytest.raises(InvalidCopticDateException):
            CopticDate(v["year"], v["month"], v["day"])

def test_invalid_gregorian_dates(vectors):
    for v in vectors["invalid_gregorian_dates"]:
        with pytest.raises(InvalidGregorianDateException):
            GregorianDate(v["year"], v["month"], v["day"])

def test_to_native_date():
    g = GregorianDate(2025, 1, 11)
    d = g.to_native_date()
    assert isinstance(d, datetime.date)
    assert d.year == 2025
    assert d.month == 1
    assert d.day == 11

def test_from_native_date():
    native = datetime.date(2025, 1, 11)
    g = GregorianDate.from_native_date(native)
    assert g.year == 2025
    assert g.month == 1
    assert g.day == 11

def test_year_feasts_sorted():
    feasts = CopticCalendar.year_feasts(2025)
    assert len(feasts) > 0
    dates = [datetime.date(f.gregorian_date.year, f.gregorian_date.month, f.gregorian_date.day) for f in feasts]
    assert dates == sorted(dates)
```

- [ ] **Step 4: Run tests to confirm they fail**

```bash
cd python && pip install -e ".[dev]" && pytest
```

Expected: ImportError — kiahk module not yet implemented.

- [ ] **Step 5: Implement `python/kiahk/errors.py`**

```python
class InvalidCopticDateException(ValueError):
    def __init__(self, year, month, day):
        super().__init__(f"Invalid Coptic date: {year}/{month}/{day}")

class InvalidGregorianDateException(ValueError):
    def __init__(self, year, month, day):
        super().__init__(f"Invalid Gregorian date: {year}/{month}/{day}")

class UnsupportedLocaleException(KeyError):
    def __init__(self, locale):
        super().__init__(f"Unsupported locale: {locale}")
```

- [ ] **Step 6: Implement `python/kiahk/_algorithms.py`**

```python
def _gregorian_to_jdn(year, month, day):
    a = (14 - month) // 12
    y = year + 4800 - a
    m = month + 12 * a - 3
    return day + (153 * m + 2) // 5 + 365 * y + y // 4 - y // 100 + y // 400 - 32045

def _jdn_to_gregorian(jdn):
    a = jdn + 32044
    b = (4 * a + 3) // 146097
    c = a - (146097 * b) // 4
    d = (4 * c + 3) // 1461
    e = c - (1461 * d) // 4
    m = (5 * e + 2) // 153
    day   = e - (153 * m + 2) // 5 + 1
    month = m + 3 - 12 * (m // 10)
    year  = 100 * b + d - 4800 + m // 10
    return year, month, day

_COPTIC_EPOCH = 1825030

def gregorian_to_coptic(g_year, g_month, g_day):
    jdn = _gregorian_to_jdn(g_year, g_month, g_day)
    r = jdn - _COPTIC_EPOCH
    c_year  = (4 * r + 1463) // 1461 - 1
    remain  = r - 365 * c_year - c_year // 4
    c_month = remain // 30 + 1
    c_day   = remain - 30 * (c_month - 1) + 1
    return c_year, min(c_month, 13), c_day

def coptic_to_gregorian(c_year, c_month, c_day):
    jdn = c_day + 30 * (c_month - 1) + 365 * c_year + c_year // 4 + _COPTIC_EPOCH - 1
    return _jdn_to_gregorian(jdn)

def compute_easter(gregorian_year):
    a = gregorian_year % 4
    b = gregorian_year % 7
    c = gregorian_year % 19
    d = (19 * c + 15) % 30
    e = (2 * a + 4 * b - d + 34) % 7
    f = (d + e + 114) // 31
    g = (d + e + 114) % 31 + 1
    jdn = _gregorian_to_jdn(gregorian_year, f, g) + 13
    return _jdn_to_gregorian(jdn)

def add_days(year, month, day, days):
    jdn = _gregorian_to_jdn(year, month, day) + days
    return _jdn_to_gregorian(jdn)
```

- [ ] **Step 7: Implement `python/kiahk/coptic_date.py`**

```python
from .errors import InvalidCopticDateException
from ._algorithms import coptic_to_gregorian

def _days_in_coptic_month(month, year):
    if 1 <= month <= 12:
        return 30
    if month == 13:
        return 6 if year % 4 == 3 else 5
    return 0

class CopticDate:
    def __init__(self, year: int, month: int, day: int):
        max_day = _days_in_coptic_month(month, year)
        if not (1 <= month <= 13) or not (1 <= day <= max_day):
            raise InvalidCopticDateException(year, month, day)
        self.year = year
        self.month = month
        self.day = day

    def to_gregorian(self):
        from .gregorian_date import GregorianDate
        y, m, d = coptic_to_gregorian(self.year, self.month, self.day)
        return GregorianDate(y, m, d)

    def __str__(self):
        return f"{self.year}/{self.month:02d}/{self.day:02d}"

    def __repr__(self):
        return f"CopticDate({self.year}, {self.month}, {self.day})"
```

- [ ] **Step 8: Implement `python/kiahk/gregorian_date.py`**

```python
import datetime
from .errors import InvalidGregorianDateException
from ._algorithms import gregorian_to_coptic

_DAYS_IN_MONTH = [0,31,28,31,30,31,30,31,31,30,31,30,31]

def _is_leap(year):
    return (year % 4 == 0 and year % 100 != 0) or year % 400 == 0

def _days_in_gregorian_month(month, year):
    if month == 2 and _is_leap(year):
        return 29
    return _DAYS_IN_MONTH[month] if 1 <= month <= 12 else 0

class GregorianDate:
    def __init__(self, year: int, month: int, day: int):
        max_day = _days_in_gregorian_month(month, year)
        if not (1 <= month <= 12) or not (1 <= day <= max_day):
            raise InvalidGregorianDateException(year, month, day)
        self.year = year
        self.month = month
        self.day = day

    def to_coptic(self):
        from .coptic_date import CopticDate
        y, m, d = gregorian_to_coptic(self.year, self.month, self.day)
        return CopticDate(y, m, d)

    def to_native_date(self) -> datetime.date:
        return datetime.date(self.year, self.month, self.day)

    @classmethod
    def from_native_date(cls, d: datetime.date) -> "GregorianDate":
        return cls(d.year, d.month, d.day)

    def __str__(self):
        return f"{self.year}-{self.month:02d}-{self.day:02d}"

    def __repr__(self):
        return f"GregorianDate({self.year}, {self.month}, {self.day})"
```

- [ ] **Step 9: Implement `python/kiahk/feast.py`**

```python
from enum import Enum
from .errors import UnsupportedLocaleException

class FeastType(str, Enum):
    MOVEABLE = "moveable"
    FIXED = "fixed"

class FeastCategory(str, Enum):
    MAJOR = "major"
    MINOR = "minor"

class Feast:
    def __init__(self, data: dict, gregorian_date, coptic_date):
        self.id = data["id"]
        self.type = FeastType(data["type"])
        self.category = FeastCategory(data["category"])
        self.easter_offset = data.get("easter_offset")
        self.gregorian_date = gregorian_date
        self.coptic_date = coptic_date
        self._names = data["names"]

    def name(self, locale: str) -> str:
        if locale not in self._names:
            raise UnsupportedLocaleException(locale)
        return self._names[locale]
```

- [ ] **Step 10: Implement `python/kiahk/_feasts_data.py` and `coptic_calendar.py`**

`_feasts_data.py`:

```python
import json, pathlib
_FEASTS_PATH = pathlib.Path(__file__).parent.parent.parent / "core" / "feasts.json"
FEASTS = json.loads(_FEASTS_PATH.read_text())
```

`coptic_calendar.py`:

```python
from ._algorithms import compute_easter, add_days
from ._feasts_data import FEASTS
from .gregorian_date import GregorianDate
from .feast import Feast
import datetime

class CopticCalendar:
    def __init__(self): raise TypeError("CopticCalendar is a static class")

    @staticmethod
    def easter_date(gregorian_year: int) -> GregorianDate:
        y, m, d = compute_easter(gregorian_year)
        return GregorianDate(y, m, d)

    @staticmethod
    def moveable_feast(feast_id: str, gregorian_year: int) -> Feast:
        data = next((f for f in FEASTS if f["id"] == feast_id and f["type"] == "moveable"), None)
        if not data:
            raise ValueError(f"Unknown moveable feast: {feast_id}")
        easter = CopticCalendar.easter_date(gregorian_year)
        y, m, d = add_days(easter.year, easter.month, easter.day, data["easter_offset"])
        g = GregorianDate(y, m, d)
        return Feast(data, g, g.to_coptic())

    @staticmethod
    def fixed_feasts(gregorian_year: int):
        """Return all fixed feasts whose Gregorian date falls within gregorian_year.

        Strategy: a fixed feast is defined by (coptic_month, coptic_day). A Gregorian
        year overlaps two Coptic years (e.g. 2025 spans parts of AM 1741 and AM 1742).
        We check both Coptic years and keep feasts whose Gregorian equivalent falls
        within [Jan 1, Dec 31] of gregorian_year.
        """
        from .coptic_date import CopticDate
        import datetime

        # The Gregorian year gregorian_year starts in Coptic year C and ends in C+1.
        # Coptic New Year (Toot 1) falls around Sep 11 Gregorian.
        # Approximate both Coptic years that overlap this Gregorian year:
        jan1 = GregorianDate.from_native_date(datetime.date(gregorian_year, 1, 1))
        c_year_start = jan1.to_coptic().year

        result = []
        seen = set()
        for coptic_year in (c_year_start, c_year_start + 1):
            for data in (f for f in FEASTS if f["type"] == "fixed"):
                try:
                    c = CopticDate(coptic_year, data["coptic_month"], data["coptic_day"])
                    g = c.to_gregorian()
                    if g.year == gregorian_year and data["id"] not in seen:
                        seen.add(data["id"])
                        result.append(Feast(data, g, c))
                except Exception:
                    pass
        return result

    @staticmethod
    def year_feasts(gregorian_year: int):
        moveable = [CopticCalendar.moveable_feast(f["id"], gregorian_year)
                    for f in FEASTS if f["type"] == "moveable"]
        fixed = CopticCalendar.fixed_feasts(gregorian_year)
        all_feasts = fixed + moveable
        all_feasts.sort(key=lambda f: datetime.date(
            f.gregorian_date.year, f.gregorian_date.month, f.gregorian_date.day))
        return all_feasts
```

- [ ] **Step 11: Implement `python/kiahk/__init__.py`**

```python
from .coptic_date import CopticDate
from .gregorian_date import GregorianDate
from .feast import Feast, FeastType, FeastCategory
from .coptic_calendar import CopticCalendar

__all__ = ["CopticDate", "GregorianDate", "Feast", "FeastType", "FeastCategory", "CopticCalendar"]
```

- [ ] **Step 12: Run tests**

```bash
cd python && pytest -v
```

Expected: all tests pass.

- [ ] **Step 13: Commit**

```bash
git add python/
git commit -m "feat(python): Python/PyPI package with pytest suite"
```

---

## Task 5: Dart Package

**Files:**
- Create: `dart/pubspec.yaml`
- Create: `dart/lib/kiahk.dart`, `dart/lib/src/*.dart`
- Create: `dart/test/kiahk_test.dart`

- [ ] **Step 1: Create `dart/pubspec.yaml`**

```yaml
name: kiahk
description: Coptic calendar arithmetic — date conversion, Easter, and feast days.
version: 0.1.0
repository: https://github.com/amir-magdy-of-wizardlabz/kiahk

environment:
  sdk: '>=3.0.0 <4.0.0'

dev_dependencies:
  test: ^1.24.0
  lints: ^3.0.0
```

- [ ] **Step 2: Write failing tests — `dart/test/kiahk_test.dart`**

```dart
import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';
import 'package:kiahk/kiahk.dart';

void main() {
  final vectorsFile = File('../../core/test-vectors.json');
  final vectors = jsonDecode(vectorsFile.readAsStringSync()) as Map<String, dynamic>;

  group('Gregorian → Coptic', () {
    for (final v in vectors['gregorian_to_coptic'] as List) {
      test('${v['gregorian']} → ${v['coptic']}', () {
        final g = GregorianDate(v['gregorian']['year'], v['gregorian']['month'], v['gregorian']['day']);
        final c = g.toCoptic();
        expect(c.year,  equals(v['coptic']['year']));
        expect(c.month, equals(v['coptic']['month']));
        expect(c.day,   equals(v['coptic']['day']));
      });
    }
  });

  group('Coptic → Gregorian', () {
    for (final v in vectors['coptic_to_gregorian'] as List) {
      test('converts', () {
        final c = CopticDate(v['coptic']['year'], v['coptic']['month'], v['coptic']['day']);
        final g = c.toGregorian();
        expect(g.year,  equals(v['gregorian']['year']));
        expect(g.month, equals(v['gregorian']['month']));
        expect(g.day,   equals(v['gregorian']['day']));
      });
    }
  });

  group('Easter', () {
    for (final v in vectors['easter'] as List) {
      test('year ${v['gregorian_year']}', () {
        final e = CopticCalendar.easterDate(v['gregorian_year'] as int);
        expect(e.year,  equals(v['date']['year']));
        expect(e.month, equals(v['date']['month']));
        expect(e.day,   equals(v['date']['day']));
      });
    }
  });

  group('Feast.name()', () {
    test('English', () {
      final f = CopticCalendar.moveableFeast('easter', 2025);
      expect(f.name('en'), equals('Easter Sunday'));
    });
    test('throws UnsupportedLocaleException', () {
      final f = CopticCalendar.moveableFeast('easter', 2025);
      expect(() => f.name('fr'), throwsA(isA<UnsupportedLocaleException>()));
    });
  });

  group('Invalid dates', () {
    for (final v in vectors['invalid_coptic_dates'] as List) {
      test('invalid coptic', () {
        expect(() => CopticDate(v['year'], v['month'], v['day']),
            throwsA(isA<InvalidCopticDateException>()));
      });
    }
  });

  test('toNativeDate returns DateTime', () {
    final g = GregorianDate(2025, 1, 11);
    final dt = g.toNativeDate();
    expect(dt, isA<DateTime>());
    expect(dt.year, equals(2025));
    expect(dt.month, equals(1));
    expect(dt.day, equals(11));
  });
}
```

- [ ] **Step 3: Run tests to confirm they fail**

```bash
cd dart && dart test
```

- [ ] **Step 4: Implement `dart/lib/src/algorithms.dart`**

```dart
const int _copticEpoch = 1825030;

int _gregorianToJdn(int year, int month, int day) {
  final a = (14 - month) ~/ 12;
  final y = year + 4800 - a;
  final m = month + 12 * a - 3;
  return day + (153 * m + 2) ~/ 5 + 365 * y + y ~/ 4 - y ~/ 100 + y ~/ 400 - 32045;
}

(int, int, int) _jdnToGregorian(int jdn) {
  final a = jdn + 32044;
  final b = (4 * a + 3) ~/ 146097;
  final c = a - (146097 * b) ~/ 4;
  final d = (4 * c + 3) ~/ 1461;
  final e = c - (1461 * d) ~/ 4;
  final m = (5 * e + 2) ~/ 153;
  final day   = e - (153 * m + 2) ~/ 5 + 1;
  final month = m + 3 - 12 * (m ~/ 10);
  final year  = 100 * b + d - 4800 + m ~/ 10;
  return (year, month, day);
}

(int, int, int) gregorianToCoptic(int gYear, int gMonth, int gDay) {
  final jdn = _gregorianToJdn(gYear, gMonth, gDay);
  final r = jdn - _copticEpoch;
  final cYear  = (4 * r + 1463) ~/ 1461 - 1;
  final remain = r - 365 * cYear - cYear ~/ 4;
  final cMonth = remain ~/ 30 + 1;
  final cDay   = remain - 30 * (cMonth - 1) + 1;
  return (cYear, cMonth.clamp(1, 13), cDay);
}

(int, int, int) copticToGregorian(int cYear, int cMonth, int cDay) {
  final jdn = cDay + 30 * (cMonth - 1) + 365 * cYear + cYear ~/ 4 + _copticEpoch - 1;
  return _jdnToGregorian(jdn);
}

(int, int, int) computeEaster(int gregorianYear) {
  final a = gregorianYear % 4;
  final b = gregorianYear % 7;
  final c = gregorianYear % 19;
  final d = (19 * c + 15) % 30;
  final e = (2 * a + 4 * b - d + 34) % 7;
  final f = (d + e + 114) ~/ 31;
  final g = (d + e + 114) % 31 + 1;
  final jdn = _gregorianToJdn(gregorianYear, f, g) + 13;
  return _jdnToGregorian(jdn);
}

(int, int, int) addDays(int year, int month, int day, int days) {
  return _jdnToGregorian(_gregorianToJdn(year, month, day) + days);
}
```

- [ ] **Step 5: Implement `dart/lib/src/errors.dart`**

```dart
class InvalidCopticDateException implements Exception {
  final String message;
  InvalidCopticDateException(int y, int m, int d) : message = 'Invalid Coptic date: $y/$m/$d';
  @override String toString() => 'InvalidCopticDateException: $message';
}
class InvalidGregorianDateException implements Exception {
  final String message;
  InvalidGregorianDateException(int y, int m, int d) : message = 'Invalid Gregorian date: $y/$m/$d';
  @override String toString() => 'InvalidGregorianDateException: $message';
}
class UnsupportedLocaleException implements Exception {
  final String locale;
  UnsupportedLocaleException(this.locale);
  @override String toString() => 'UnsupportedLocaleException: $locale';
}
```

- [ ] **Step 6: Implement `dart/lib/src/coptic_date.dart`**

```dart
import 'algorithms.dart';
import 'errors.dart';
import 'gregorian_date.dart';

int _daysInCopticMonth(int month, int year) {
  if (month >= 1 && month <= 12) return 30;
  if (month == 13) return year % 4 == 3 ? 6 : 5;
  return 0;
}

class CopticDate {
  final int year, month, day;

  CopticDate(this.year, this.month, this.day) {
    final max = _daysInCopticMonth(month, year);
    if (month < 1 || month > 13 || day < 1 || day > max) {
      throw InvalidCopticDateException(year, month, day);
    }
  }

  GregorianDate toGregorian() {
    final (y, m, d) = copticToGregorian(year, month, day);
    return GregorianDate(y, m, d);
  }

  @override String toString() =>
      '$year/${month.toString().padLeft(2,'0')}/${day.toString().padLeft(2,'0')}';
}
```

- [ ] **Step 7: Implement `dart/lib/src/gregorian_date.dart`**

```dart
import 'algorithms.dart';
import 'errors.dart';
import 'coptic_date.dart';

const _daysInMonth = [0,31,28,31,30,31,30,31,31,30,31,30,31];
bool _isLeap(int y) => (y % 4 == 0 && y % 100 != 0) || y % 400 == 0;

int _daysInGregorianMonth(int month, int year) {
  if (month == 2 && _isLeap(year)) return 29;
  return (month >= 1 && month <= 12) ? _daysInMonth[month] : 0;
}

class GregorianDate {
  final int year, month, day;

  GregorianDate(this.year, this.month, this.day) {
    final max = _daysInGregorianMonth(month, year);
    if (month < 1 || month > 12 || day < 1 || day > max) {
      throw InvalidGregorianDateException(year, month, day);
    }
  }

  CopticDate toCoptic() {
    final (y, m, d) = gregorianToCoptic(year, month, day);
    return CopticDate(y, m, d);
  }

  DateTime toNativeDate() => DateTime(year, month, day);

  static GregorianDate fromNativeDate(DateTime dt) =>
      GregorianDate(dt.year, dt.month, dt.day);

  @override String toString() =>
      '$year-${month.toString().padLeft(2,'0')}-${day.toString().padLeft(2,'0')}';
}
```

- [ ] **Step 8: Implement `dart/lib/src/feast.dart`**

```dart
import 'errors.dart';
import 'gregorian_date.dart';
import 'coptic_date.dart';

enum FeastType { moveable, fixed }
enum FeastCategory { major, minor }

class Feast {
  final String id;
  final FeastType type;
  final FeastCategory category;
  final int? easterOffset;
  final GregorianDate gregorianDate;
  final CopticDate copticDate;
  final Map<String, String> _names;

  Feast({
    required this.id,
    required this.type,
    required this.category,
    required this.gregorianDate,
    required this.copticDate,
    required Map<String, String> names,
    this.easterOffset,
  }) : _names = names;

  String name(String locale) {
    if (!_names.containsKey(locale)) throw UnsupportedLocaleException(locale);
    return _names[locale]!;
  }
}
```

- [ ] **Step 9: Implement `dart/lib/src/coptic_calendar.dart`**

```dart
import 'dart:convert';
import 'dart:io';
import 'algorithms.dart';
import 'gregorian_date.dart';
import 'coptic_date.dart';
import 'feast.dart';
import 'errors.dart';

final _feastsPath = '${File(Platform.script.toFilePath()).parent.parent.parent.path}/core/feasts.json';
final _feasts = (jsonDecode(File(_feastsPath).readAsStringSync()) as List)
    .cast<Map<String, dynamic>>();

Feast _buildFeast(Map<String, dynamic> data, GregorianDate g) => Feast(
  id: data['id'] as String,
  type: FeastType.values.byName(data['type'] as String),
  category: FeastCategory.values.byName(data['category'] as String),
  gregorianDate: g,
  copticDate: g.toCoptic(),
  names: Map<String, String>.from(data['names'] as Map),
  easterOffset: data['easter_offset'] as int?,
);

class CopticCalendar {
  CopticCalendar._();

  static GregorianDate easterDate(int gregorianYear) {
    final (y, m, d) = computeEaster(gregorianYear);
    return GregorianDate(y, m, d);
  }

  static Feast moveableFeast(String feastId, int gregorianYear) {
    final data = _feasts.firstWhere(
      (f) => f['id'] == feastId && f['type'] == 'moveable',
      orElse: () => throw ArgumentError('Unknown moveable feast: $feastId'),
    );
    final easter = easterDate(gregorianYear);
    final (y, m, d) = addDays(easter.year, easter.month, easter.day, data['easter_offset'] as int);
    final g = GregorianDate(y, m, d);
    return _buildFeast(data, g);
  }

  static List<Feast> fixedFeasts(int gregorianYear) {
    final jan1 = GregorianDate(gregorianYear, 1, 1);
    final cYearStart = jan1.toCoptic().year;
    final result = <Feast>[];
    final seen = <String>{};
    for (final copticYear in [cYearStart, cYearStart + 1]) {
      for (final data in _feasts.where((f) => f['type'] == 'fixed')) {
        try {
          final c = CopticDate(copticYear, data['coptic_month'] as int, data['coptic_day'] as int);
          final g = c.toGregorian();
          final id = data['id'] as String;
          if (g.year == gregorianYear && !seen.contains(id)) {
            seen.add(id);
            result.add(_buildFeast(data, g));
          }
        } catch (_) {}
      }
    }
    return result;
  }

  static List<Feast> yearFeasts(int gregorianYear) {
    final moveable = _feasts
        .where((f) => f['type'] == 'moveable')
        .map((f) => moveableFeast(f['id'] as String, gregorianYear))
        .toList();
    final fixed = fixedFeasts(gregorianYear);
    return [...fixed, ...moveable]
      ..sort((a, b) {
        final ag = a.gregorianDate, bg = b.gregorianDate;
        return DateTime(ag.year, ag.month, ag.day)
            .compareTo(DateTime(bg.year, bg.month, bg.day));
      });
  }
}
```

- [ ] **Step 10: Create `dart/lib/kiahk.dart`**

```dart
export 'src/coptic_date.dart';
export 'src/gregorian_date.dart';
export 'src/feast.dart';
export 'src/coptic_calendar.dart';
export 'src/errors.dart';
```

- [ ] **Step 11: Run tests**

```bash
cd dart && dart test
```

Expected: all tests pass.

- [ ] **Step 12: Commit**

```bash
git add dart/
git commit -m "feat(dart): Dart/pub.dev package with test suite"
```

---

## Task 6: Swift Package

**Files:**
- Create: `swift/Package.swift`
- Create: `swift/Sources/Kiahk/*.swift`
- Create: `swift/Tests/KiahkTests/KiahkTests.swift`

- [ ] **Step 1: Create `swift/Package.swift`**

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Kiahk",
    products: [.library(name: "Kiahk", targets: ["Kiahk"])],
    targets: [
        .target(name: "Kiahk", path: "Sources/Kiahk"),
        .testTarget(
            name: "KiahkTests",
            dependencies: ["Kiahk"],
            path: "Tests/KiahkTests"
        ),
    ]
)
```

- [ ] **Step 2: Write failing tests — `swift/Tests/KiahkTests/KiahkTests.swift`**

```swift
import XCTest
@testable import Kiahk

final class KiahkTests: XCTestCase {
    var vectors: [String: Any] = [:]

    override func setUp() {
        let url = URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("core/test-vectors.json")
        let data = try! Data(contentsOf: url)
        vectors = try! JSONSerialization.jsonObject(with: data) as! [String: Any]
    }

    func testGregorianToCoptic() throws {
        for v in vectors["gregorian_to_coptic"] as! [[String: [String: Int]]] {
            let g = try GregorianDate(v["gregorian"]!["year"]!, v["gregorian"]!["month"]!, v["gregorian"]!["day"]!)
            let c = g.toCoptic()
            XCTAssertEqual(c.year,  v["coptic"]!["year"]!)
            XCTAssertEqual(c.month, v["coptic"]!["month"]!)
            XCTAssertEqual(c.day,   v["coptic"]!["day"]!)
        }
    }

    func testEaster() throws {
        for v in vectors["easter"] as! [[String: Any]] {
            let year = v["gregorian_year"] as! Int
            let date = v["date"] as! [String: Int]
            let e = CopticCalendar.easterDate(year)
            XCTAssertEqual(e.year,  date["year"]!)
            XCTAssertEqual(e.month, date["month"]!)
            XCTAssertEqual(e.day,   date["day"]!)
        }
    }

    func testFeastNameEn() throws {
        let f = CopticCalendar.moveableFeast("easter", gregorianYear: 2025)
        XCTAssertEqual(try f.name("en"), "Easter Sunday")
    }

    func testUnsupportedLocale() {
        let f = CopticCalendar.moveableFeast("easter", gregorianYear: 2025)
        XCTAssertThrowsError(try f.name("fr"))
    }

    func testToNativeDate() throws {
        let g = try GregorianDate(2025, 1, 11)
        let d = g.toNativeDate()
        let cal = Calendar(identifier: .gregorian)
        let comps = cal.dateComponents([.year, .month, .day], from: d)
        XCTAssertEqual(comps.year, 2025)
        XCTAssertEqual(comps.month, 1)
        XCTAssertEqual(comps.day, 11)
    }
}
```

- [ ] **Step 3: Implement `swift/Sources/Kiahk/Errors.swift`**

```swift
import Foundation

public struct InvalidCopticDateException: Error {
    public let message: String
    public init(_ y: Int, _ m: Int, _ d: Int) { message = "Invalid Coptic date: \(y)/\(m)/\(d)" }
}
public struct InvalidGregorianDateException: Error {
    public let message: String
    public init(_ y: Int, _ m: Int, _ d: Int) { message = "Invalid Gregorian date: \(y)/\(m)/\(d)" }
}
public struct UnsupportedLocaleException: Error {
    public let locale: String
    public init(_ locale: String) { self.locale = locale }
}
```

- [ ] **Step 4: Implement `swift/Sources/Kiahk/Algorithms.swift`**

```swift
private let copticEpoch = 1825030

func gregorianToJdn(_ year: Int, _ month: Int, _ day: Int) -> Int {
    let a = (14 - month) / 12
    let y = year + 4800 - a
    let m = month + 12 * a - 3
    return day + (153 * m + 2) / 5 + 365 * y + y / 4 - y / 100 + y / 400 - 32045
}

func jdnToGregorian(_ jdn: Int) -> (Int, Int, Int) {
    let a = jdn + 32044
    let b = (4 * a + 3) / 146097
    let c = a - (146097 * b) / 4
    let d = (4 * c + 3) / 1461
    let e = c - (1461 * d) / 4
    let m = (5 * e + 2) / 153
    let day   = e - (153 * m + 2) / 5 + 1
    let month = m + 3 - 12 * (m / 10)
    let year  = 100 * b + d - 4800 + m / 10
    return (year, month, day)
}

func gregorianToCoptic(_ gYear: Int, _ gMonth: Int, _ gDay: Int) -> (Int, Int, Int) {
    let jdn = gregorianToJdn(gYear, gMonth, gDay)
    let r = jdn - copticEpoch
    let cYear  = (4 * r + 1463) / 1461 - 1
    let remain = r - 365 * cYear - cYear / 4
    let cMonth = remain / 30 + 1
    let cDay   = remain - 30 * (cMonth - 1) + 1
    return (cYear, min(cMonth, 13), cDay)
}

func copticToGregorian(_ cYear: Int, _ cMonth: Int, _ cDay: Int) -> (Int, Int, Int) {
    let jdn = cDay + 30 * (cMonth - 1) + 365 * cYear + cYear / 4 + copticEpoch - 1
    return jdnToGregorian(jdn)
}

func computeEaster(_ gregorianYear: Int) -> (Int, Int, Int) {
    let a = gregorianYear % 4
    let b = gregorianYear % 7
    let c = gregorianYear % 19
    let d = (19 * c + 15) % 30
    let e = (2 * a + 4 * b - d + 34) % 7
    let f = (d + e + 114) / 31
    let g = (d + e + 114) % 31 + 1
    let jdn = gregorianToJdn(gregorianYear, f, g) + 13
    return jdnToGregorian(jdn)
}

func addDays(_ year: Int, _ month: Int, _ day: Int, _ days: Int) -> (Int, Int, Int) {
    return jdnToGregorian(gregorianToJdn(year, month, day) + days)
}
```

- [ ] **Step 5: Implement `swift/Sources/Kiahk/CopticDate.swift`**

```swift
public struct CopticDate {
    public let year: Int
    public let month: Int
    public let day: Int

    public init(_ year: Int, _ month: Int, _ day: Int) throws {
        let maxDay: Int
        if month >= 1 && month <= 12 { maxDay = 30 }
        else if month == 13 { maxDay = year % 4 == 3 ? 6 : 5 }
        else { throw InvalidCopticDateException(year, month, day) }
        guard day >= 1 && day <= maxDay else { throw InvalidCopticDateException(year, month, day) }
        self.year = year; self.month = month; self.day = day
    }

    public func toGregorian() throws -> GregorianDate {
        let (y, m, d) = copticToGregorian(year, month, day)
        return try GregorianDate(y, m, d)
    }
}
```

- [ ] **Step 6: Implement `swift/Sources/Kiahk/GregorianDate.swift`**

```swift
import Foundation

private let daysInMonth = [0,31,28,31,30,31,30,31,31,30,31,30,31]
private func isLeap(_ y: Int) -> Bool { (y % 4 == 0 && y % 100 != 0) || y % 400 == 0 }

public struct GregorianDate {
    public let year: Int
    public let month: Int
    public let day: Int

    public init(_ year: Int, _ month: Int, _ day: Int) throws {
        guard month >= 1 && month <= 12 else { throw InvalidGregorianDateException(year, month, day) }
        let maxDay = month == 2 && isLeap(year) ? 29 : daysInMonth[month]
        guard day >= 1 && day <= maxDay else { throw InvalidGregorianDateException(year, month, day) }
        self.year = year; self.month = month; self.day = day
    }

    public func toCoptic() throws -> CopticDate {
        let (y, m, d) = gregorianToCoptic(year, month, day)
        return try CopticDate(y, m, d)
    }

    public func toNativeDate() -> Date {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        var comps = DateComponents()
        comps.year = year; comps.month = month; comps.day = day
        return cal.date(from: comps)!
    }

    public static func fromNativeDate(_ date: Date) throws -> GregorianDate {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let comps = cal.dateComponents([.year, .month, .day], from: date)
        return try GregorianDate(comps.year!, comps.month!, comps.day!)
    }
}
```

- [ ] **Step 7: Implement `swift/Sources/Kiahk/Feast.swift`**

```swift
import Foundation

public enum FeastType: String { case moveable, fixed }
public enum FeastCategory: String { case major, minor }

public struct Feast {
    public let id: String
    public let type: FeastType
    public let category: FeastCategory
    public let easterOffset: Int?
    public let gregorianDate: GregorianDate
    public let copticDate: CopticDate
    private let names: [String: String]

    init(data: [String: Any], gregorianDate: GregorianDate, copticDate: CopticDate) {
        self.id = data["id"] as! String
        self.type = FeastType(rawValue: data["type"] as! String)!
        self.category = FeastCategory(rawValue: data["category"] as! String)!
        self.easterOffset = data["easter_offset"] as? Int
        self.gregorianDate = gregorianDate
        self.copticDate = copticDate
        self.names = data["names"] as! [String: String]
    }

    public func name(_ locale: String) throws -> String {
        guard let n = names[locale] else { throw UnsupportedLocaleException(locale) }
        return n
    }
}
```

- [ ] **Step 8: Implement `swift/Sources/Kiahk/CopticCalendar.swift`**

```swift
import Foundation

private func loadFeasts() -> [[String: Any]] {
    // Load feasts.json relative to this source file at build time
    let url = URL(fileURLWithPath: #file)
        .deletingLastPathComponent()   // Sources/Kiahk
        .deletingLastPathComponent()   // Sources
        .deletingLastPathComponent()   // swift/
        .deletingLastPathComponent()   // repo root
        .appendingPathComponent("core/feasts.json")
    let data = try! Data(contentsOf: url)
    return try! JSONSerialization.jsonObject(with: data) as! [[String: Any]]
}

private let feasts = loadFeasts()

public enum CopticCalendar {
    public static func easterDate(_ gregorianYear: Int) -> GregorianDate {
        let (y, m, d) = computeEaster(gregorianYear)
        return try! GregorianDate(y, m, d)
    }

    public static func moveableFeast(_ feastId: String, gregorianYear: Int) -> Feast {
        let data = feasts.first { $0["id"] as? String == feastId && $0["type"] as? String == "moveable" }!
        let easter = easterDate(gregorianYear)
        let offset = data["easter_offset"] as! Int
        let (y, m, d) = addDays(easter.year, easter.month, easter.day, offset)
        let g = try! GregorianDate(y, m, d)
        let c = try! g.toCoptic()
        return Feast(data: data, gregorianDate: g, copticDate: c)
    }

    public static func fixedFeasts(_ gregorianYear: Int) -> [Feast] {
        let jan1 = try! GregorianDate(gregorianYear, 1, 1)
        let cYearStart = (try! jan1.toCoptic()).year
        var result: [Feast] = []
        var seen = Set<String>()
        for copticYear in [cYearStart, cYearStart + 1] {
            for data in feasts where data["type"] as? String == "fixed" {
                guard let cm = data["coptic_month"] as? Int, let cd = data["coptic_day"] as? Int,
                      let id = data["id"] as? String else { continue }
                guard let copticDate = try? CopticDate(copticYear, cm, cd),
                      let g = try? copticDate.toGregorian(),
                      g.year == gregorianYear, !seen.contains(id) else { continue }
                seen.insert(id)
                result.append(Feast(data: data, gregorianDate: g, copticDate: copticDate))
            }
        }
        return result
    }

    public static func yearFeasts(_ gregorianYear: Int) -> [Feast] {
        let moveable = feasts.filter { $0["type"] as? String == "moveable" }
            .map { moveableFeast($0["id"] as! String, gregorianYear: gregorianYear) }
        let fixed = fixedFeasts(gregorianYear)
        return (fixed + moveable).sorted {
            let a = $0.gregorianDate, b = $1.gregorianDate
            if a.year != b.year { return a.year < b.year }
            if a.month != b.month { return a.month < b.month }
            return a.day < b.day
        }
    }
}
```

- [ ] **Step 4: Run tests**

```bash
cd swift && swift test
```

Expected: all tests pass.

- [ ] **Step 5: Commit**

```bash
git add swift/
git commit -m "feat(swift): Swift Package with XCTest suite"
```

---

## Task 7: Kotlin Package

**Files:**
- Create: `kotlin/build.gradle.kts`, `kotlin/settings.gradle.kts`
- Create: `kotlin/src/main/kotlin/io/kiahk/*.kt`
- Create: `kotlin/src/test/kotlin/io/kiahk/KiahkTest.kt`

- [ ] **Step 1: Create Gradle config**

`kotlin/settings.gradle.kts`:

```kotlin
rootProject.name = "kiahk"
```

`kotlin/build.gradle.kts`:

```kotlin
plugins {
    kotlin("jvm") version "1.9.23"
}

group = "io.kiahk"
version = "0.1.0"

repositories { mavenCentral() }

dependencies {
    testImplementation(kotlin("test"))
    testImplementation("org.junit.jupiter:junit-jupiter:5.10.2")
    testImplementation("com.google.code.gson:gson:2.10.1")
}

tasks.test {
    useJUnitPlatform()
}

kotlin { jvmToolchain(17) }
```

- [ ] **Step 2: Write failing tests — `kotlin/src/test/kotlin/io/kiahk/KiahkTest.kt`**

```kotlin
package io.kiahk

import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import org.junit.jupiter.api.Test
import java.io.File
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith

class KiahkTest {
    data class DateVec(val year: Int, val month: Int, val day: Int)
    data class GtoCVec(val gregorian: DateVec, val coptic: DateVec)
    data class CtogVec(val coptic: DateVec, val gregorian: DateVec)
    data class EasterVec(val gregorian_year: Int, val date: DateVec)
    data class MoveableVec(val gregorian_year: Int, val feast_id: String, val date: DateVec)
    data class Vectors(
        val gregorian_to_coptic: List<GtoCVec>,
        val coptic_to_gregorian: List<CtogVec>,
        val easter: List<EasterVec>,
        val moveable_feasts: List<MoveableVec>,
        val invalid_coptic_dates: List<DateVec>,
        val invalid_gregorian_dates: List<DateVec>
    )

    private val vectors: Vectors by lazy {
        val path = File("../../core/test-vectors.json")
        Gson().fromJson(path.readText(), object : TypeToken<Vectors>() {}.type)
    }

    @Test fun gregorianToCoptic() {
        for (v in vectors.gregorian_to_coptic) {
            val g = GregorianDate(v.gregorian.year, v.gregorian.month, v.gregorian.day)
            val c = g.toCoptic()
            assertEquals(v.coptic.year, c.year)
            assertEquals(v.coptic.month, c.month)
            assertEquals(v.coptic.day, c.day)
        }
    }

    @Test fun easter() {
        for (v in vectors.easter) {
            val e = CopticCalendar.easterDate(v.gregorian_year)
            assertEquals(v.date.year, e.year)
            assertEquals(v.date.month, e.month)
            assertEquals(v.date.day, e.day)
        }
    }

    @Test fun feastNameEn() {
        val f = CopticCalendar.moveableFeast("easter", 2025)
        assertEquals("Easter Sunday", f.name("en"))
    }

    @Test fun unsupportedLocale() {
        val f = CopticCalendar.moveableFeast("easter", 2025)
        assertFailsWith<UnsupportedLocaleException> { f.name("fr") }
    }

    @Test fun invalidCopticDates() {
        for (v in vectors.invalid_coptic_dates) {
            assertFailsWith<InvalidCopticDateException> { CopticDate(v.year, v.month, v.day) }
        }
    }

    @Test fun toNativeDate() {
        val g = GregorianDate(2025, 1, 11)
        val d = g.toNativeDate()
        assertEquals(2025, d.year)
        assertEquals(1, d.monthValue)
        assertEquals(11, d.dayOfMonth)
    }
}
```

- [ ] **Step 3: Run tests to confirm they fail**

```bash
cd kotlin && ./gradlew test
```

- [ ] **Step 4: Implement `kotlin/src/main/kotlin/io/kiahk/Errors.kt`**

```kotlin
package io.kiahk

class InvalidCopticDateException(y: Int, m: Int, d: Int)
    : Exception("Invalid Coptic date: $y/$m/$d")

class InvalidGregorianDateException(y: Int, m: Int, d: Int)
    : Exception("Invalid Gregorian date: $y/$m/$d")

class UnsupportedLocaleException(locale: String)
    : Exception("Unsupported locale: $locale")
```

- [ ] **Step 5: Implement `kotlin/src/main/kotlin/io/kiahk/Algorithms.kt`**

```kotlin
package io.kiahk

private const val COPTIC_EPOCH = 1825030

fun gregorianToJdn(year: Int, month: Int, day: Int): Int {
    val a = (14 - month) / 12
    val y = year + 4800 - a
    val m = month + 12 * a - 3
    return day + (153 * m + 2) / 5 + 365 * y + y / 4 - y / 100 + y / 400 - 32045
}

fun jdnToGregorian(jdn: Int): Triple<Int, Int, Int> {
    val a = jdn + 32044
    val b = (4 * a + 3) / 146097
    val c = a - (146097 * b) / 4
    val d = (4 * c + 3) / 1461
    val e = c - (1461 * d) / 4
    val m = (5 * e + 2) / 153
    val day   = e - (153 * m + 2) / 5 + 1
    val month = m + 3 - 12 * (m / 10)
    val year  = 100 * b + d - 4800 + m / 10
    return Triple(year, month, day)
}

fun gregorianToCoptic(gYear: Int, gMonth: Int, gDay: Int): Triple<Int, Int, Int> {
    val jdn = gregorianToJdn(gYear, gMonth, gDay)
    val r = jdn - COPTIC_EPOCH
    val cYear  = (4 * r + 1463) / 1461 - 1
    val remain = r - 365 * cYear - cYear / 4
    val cMonth = remain / 30 + 1
    val cDay   = remain - 30 * (cMonth - 1) + 1
    return Triple(cYear, cMonth.coerceAtMost(13), cDay)
}

fun copticToGregorian(cYear: Int, cMonth: Int, cDay: Int): Triple<Int, Int, Int> {
    val jdn = cDay + 30 * (cMonth - 1) + 365 * cYear + cYear / 4 + COPTIC_EPOCH - 1
    return jdnToGregorian(jdn)
}

fun computeEaster(gregorianYear: Int): Triple<Int, Int, Int> {
    val a = gregorianYear % 4
    val b = gregorianYear % 7
    val c = gregorianYear % 19
    val d = (19 * c + 15) % 30
    val e = (2 * a + 4 * b - d + 34) % 7
    val f = (d + e + 114) / 31
    val g = (d + e + 114) % 31 + 1
    val jdn = gregorianToJdn(gregorianYear, f, g) + 13
    return jdnToGregorian(jdn)
}

fun addDays(year: Int, month: Int, day: Int, days: Int): Triple<Int, Int, Int> =
    jdnToGregorian(gregorianToJdn(year, month, day) + days)
```

- [ ] **Step 6: Implement `CopticDate.kt`, `GregorianDate.kt`, `Feast.kt`, `CopticCalendar.kt`**

`kotlin/src/main/kotlin/io/kiahk/CopticDate.kt`:

```kotlin
package io.kiahk

private fun daysInCopticMonth(month: Int, year: Int): Int = when {
    month in 1..12 -> 30
    month == 13    -> if (year % 4 == 3) 6 else 5
    else           -> 0
}

class CopticDate(val year: Int, val month: Int, val day: Int) {
    init {
        val max = daysInCopticMonth(month, year)
        if (month < 1 || month > 13 || day < 1 || day > max)
            throw InvalidCopticDateException(year, month, day)
    }

    fun toGregorian(): GregorianDate {
        val (y, m, d) = copticToGregorian(year, month, day)
        return GregorianDate(y, m, d)
    }

    override fun toString() = "$year/${month.toString().padStart(2,'0')}/${day.toString().padStart(2,'0')}"
}
```

`kotlin/src/main/kotlin/io/kiahk/GregorianDate.kt`:

```kotlin
package io.kiahk
import java.time.LocalDate

private val DAYS_IN_MONTH = intArrayOf(0,31,28,31,30,31,30,31,31,30,31,30,31)
private fun isLeap(y: Int) = (y % 4 == 0 && y % 100 != 0) || y % 400 == 0

class GregorianDate(val year: Int, val month: Int, val day: Int) {
    init {
        val max = if (month == 2 && isLeap(year)) 29
                  else if (month in 1..12) DAYS_IN_MONTH[month] else 0
        if (month < 1 || month > 12 || day < 1 || day > max)
            throw InvalidGregorianDateException(year, month, day)
    }

    fun toCoptic(): CopticDate {
        val (y, m, d) = gregorianToCoptic(year, month, day)
        return CopticDate(y, m, d)
    }

    fun toNativeDate(): LocalDate = LocalDate.of(year, month, day)

    override fun toString() = "$year-${month.toString().padStart(2,'0')}-${day.toString().padStart(2,'0')}"

    companion object {
        fun fromNativeDate(d: LocalDate) = GregorianDate(d.year, d.monthValue, d.dayOfMonth)
    }
}
```

`kotlin/src/main/kotlin/io/kiahk/Feast.kt`:

```kotlin
package io.kiahk

enum class FeastType { MOVEABLE, FIXED }
enum class FeastCategory { MAJOR, MINOR }

class Feast(
    val id: String,
    val type: FeastType,
    val category: FeastCategory,
    val easterOffset: Int?,
    val gregorianDate: GregorianDate,
    val copticDate: CopticDate,
    private val names: Map<String, String>
) {
    fun name(locale: String): String =
        names[locale] ?: throw UnsupportedLocaleException(locale)
}
```

`kotlin/src/main/kotlin/io/kiahk/CopticCalendar.kt`:

```kotlin
package io.kiahk
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import java.io.File
import java.time.LocalDate

private val feastsPath = File("../../core/feasts.json")
private val feasts: List<Map<String, Any>> = Gson().fromJson(
    feastsPath.readText(), object : TypeToken<List<Map<String, Any>>>() {}.type)

private fun buildFeast(data: Map<String, Any>, g: GregorianDate): Feast {
    val names = (data["names"] as Map<*, *>).entries.associate { it.key.toString() to it.value.toString() }
    val offset = (data["easter_offset"] as? Double)?.toInt()
    return Feast(
        id = data["id"] as String,
        type = if (data["type"] == "moveable") FeastType.MOVEABLE else FeastType.FIXED,
        category = if (data["category"] == "major") FeastCategory.MAJOR else FeastCategory.MINOR,
        easterOffset = offset,
        gregorianDate = g,
        copticDate = g.toCoptic(),
        names = names
    )
}

object CopticCalendar {
    fun easterDate(gregorianYear: Int): GregorianDate {
        val (y, m, d) = computeEaster(gregorianYear)
        return GregorianDate(y, m, d)
    }

    fun moveableFeast(feastId: String, gregorianYear: Int): Feast {
        val data = feasts.first { it["id"] == feastId && it["type"] == "moveable" }
        val easter = easterDate(gregorianYear)
        val offset = (data["easter_offset"] as Double).toInt()
        val (y, m, d) = addDays(easter.year, easter.month, easter.day, offset)
        val g = GregorianDate(y, m, d)
        return buildFeast(data, g)
    }

    fun fixedFeasts(gregorianYear: Int): List<Feast> {
        val cYearStart = GregorianDate(gregorianYear, 1, 1).toCoptic().year
        val result = mutableListOf<Feast>()
        val seen = mutableSetOf<String>()
        for (copticYear in listOf(cYearStart, cYearStart + 1)) {
            for (data in feasts.filter { it["type"] == "fixed" }) {
                val cm = (data["coptic_month"] as Double).toInt()
                val cd = (data["coptic_day"] as Double).toInt()
                val id = data["id"] as String
                try {
                    val c = CopticDate(copticYear, cm, cd)
                    val g = c.toGregorian()
                    if (g.year == gregorianYear && seen.add(id)) result.add(buildFeast(data, g))
                } catch (_: Exception) {}
            }
        }
        return result
    }

    fun yearFeasts(gregorianYear: Int): List<Feast> {
        val moveable = feasts.filter { it["type"] == "moveable" }
            .map { moveableFeast(it["id"] as String, gregorianYear) }
        return (fixedFeasts(gregorianYear) + moveable)
            .sortedWith(compareBy({ it.gregorianDate.year }, { it.gregorianDate.month }, { it.gregorianDate.day }))
    }
}
```

- [ ] **Step 5: Run tests**

```bash
cd kotlin && ./gradlew test
```

Expected: all tests pass.

- [ ] **Step 6: Commit**

```bash
git add kotlin/
git commit -m "feat(kotlin): Kotlin/Maven package with JUnit5 suite"
```

---

## Task 8: C# Package

**Files:**
- Create: `csharp/Kiahk.csproj`, `csharp/tests/Kiahk.Tests.csproj`
- Create: `csharp/src/*.cs`
- Create: `csharp/tests/KiahkTests.cs`

- [ ] **Step 1: Create `csharp/Kiahk.csproj`**

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <LangVersion>12</LangVersion>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
    <PackageId>Kiahk</PackageId>
    <Version>0.1.0</Version>
    <Description>Coptic calendar arithmetic — date conversion, Easter, and feast days</Description>
    <PackageTags>coptic;calendar;easter;coptic-calendar</PackageTags>
  </PropertyGroup>
</Project>
```

`csharp/tests/Kiahk.Tests.csproj`:

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
    <IsPackable>false</IsPackable>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Microsoft.NET.Test.Sdk" Version="17.9.0" />
    <PackageReference Include="xunit" Version="2.7.0" />
    <PackageReference Include="xunit.runner.visualstudio" Version="2.5.7" />
  </ItemGroup>
  <ItemGroup>
    <ProjectReference Include="../Kiahk.csproj" />
  </ItemGroup>
</Project>
```

- [ ] **Step 2: Write failing tests — `csharp/tests/KiahkTests.cs`**

```csharp
using System.Text.Json;
using Xunit;
using Kiahk;

public class KiahkTests
{
    record DateVec(int year, int month, int day);
    record GtoCVec(DateVec gregorian, DateVec coptic);
    record CtogVec(DateVec coptic, DateVec gregorian);
    record EasterVec(int gregorian_year, DateVec date);
    record MoveableVec(int gregorian_year, string feast_id, DateVec date);
    record InvalidVec(int year, int month, int day);
    record Vectors(
        List<GtoCVec> gregorian_to_coptic,
        List<CtogVec> coptic_to_gregorian,
        List<EasterVec> easter,
        List<MoveableVec> moveable_feasts,
        List<InvalidVec> invalid_coptic_dates,
        List<InvalidVec> invalid_gregorian_dates);

    private static readonly Vectors V = JsonSerializer.Deserialize<Vectors>(
        File.ReadAllText(Path.Combine("..", "..", "..", "..", "core", "test-vectors.json")),
        new JsonSerializerOptions { PropertyNameCaseInsensitive = true })!;

    [Fact] public void GregorianToCoptic() {
        foreach (var v in V.gregorian_to_coptic) {
            var g = new GregorianDate(v.gregorian.year, v.gregorian.month, v.gregorian.day);
            var c = g.ToCoptic();
            Assert.Equal(v.coptic.year, c.Year);
            Assert.Equal(v.coptic.month, c.Month);
            Assert.Equal(v.coptic.day, c.Day);
        }
    }

    [Fact] public void Easter() {
        foreach (var v in V.easter) {
            var e = CopticCalendar.EasterDate(v.gregorian_year);
            Assert.Equal(v.date.year, e.Year);
            Assert.Equal(v.date.month, e.Month);
            Assert.Equal(v.date.day, e.Day);
        }
    }

    [Fact] public void FeastNameEn() {
        var f = CopticCalendar.MoveableFeast("easter", 2025);
        Assert.Equal("Easter Sunday", f.Name("en"));
    }

    [Fact] public void UnsupportedLocaleThrows() {
        var f = CopticCalendar.MoveableFeast("easter", 2025);
        Assert.Throws<UnsupportedLocaleException>(() => f.Name("fr"));
    }

    [Fact] public void InvalidCopticDates() {
        foreach (var v in V.invalid_coptic_dates)
            Assert.Throws<InvalidCopticDateException>(() => new CopticDate(v.year, v.month, v.day));
    }

    [Fact] public void ToNativeDate() {
        var g = new GregorianDate(2025, 1, 11);
        var d = g.ToNativeDate();
        Assert.IsType<DateOnly>(d);
        Assert.Equal(2025, d.Year);
        Assert.Equal(1, d.Month);
        Assert.Equal(11, d.Day);
    }
}
```

- [ ] **Step 3: Run tests to confirm they fail**

```bash
cd csharp && dotnet test
```

- [ ] **Step 4: Implement all C# source files**

`src/Errors.cs`:

```csharp
namespace Kiahk;
public class InvalidCopticDateException(int y, int m, int d)
    : Exception($"Invalid Coptic date: {y}/{m}/{d}");
public class InvalidGregorianDateException(int y, int m, int d)
    : Exception($"Invalid Gregorian date: {y}/{m}/{d}");
public class UnsupportedLocaleException(string locale)
    : Exception($"Unsupported locale: {locale}");
```

`src/Algorithms.cs` — all JDN and Easter logic using integer division (C# `/` for ints).
`src/CopticDate.cs` — `public record CopticDate` with validation in constructor throwing `InvalidCopticDateException`, `ToGregorian()`.
`src/GregorianDate.cs` — `public record GregorianDate` with `ToCoptic()`, `ToNativeDate()` returning `DateOnly`, `static FromNativeDate(DateOnly)`.
`src/Feast.cs` — `public enum FeastType`, `FeastCategory`, `public class Feast` with `string Name(string locale)`.
`src/CopticCalendar.cs` — `public static class CopticCalendar`, load feasts from `../../../../core/feasts.json` relative path.

- [ ] **Step 5: Run tests**

```bash
cd csharp && dotnet test
```

Expected: all tests pass.

- [ ] **Step 6: Commit**

```bash
git add csharp/
git commit -m "feat(csharp): C#/NuGet package with xUnit suite"
```

---

## Task 9: Top-Level README

**Files:**
- Create: `README.md`
- Create: `js/README.md`, `python/README.md`, `dart/README.md`, `swift/README.md`, `kotlin/README.md`, `csharp/README.md`

- [ ] **Step 1: Write `README.md`**

The README must include:
- Header with icon (`assets/icon.svg`) and tagline
- Brief description (Coptic calendar arithmetic, zero-dependency, multi-language)
- Package install badges for all 6 languages (npm, PyPI, pub.dev, SwiftPM, Maven, NuGet)
- Quick-start code snippets for each language showing: date conversion, Easter, feast name
- Supported locales table (en, ar)
- Link to `core/algorithms.md` for algorithm documentation
- License (MIT)

- [ ] **Step 2: Write per-language READMEs**

Each `<lang>/README.md` must include:
- Install command for that package manager
- Full quick-start example in that language
- API reference table (classes, methods, return types)
- Link to root README for full docs

- [ ] **Step 3: Commit**

```bash
git add README.md js/README.md python/README.md dart/README.md swift/README.md kotlin/README.md csharp/README.md
git commit -m "docs: top-level README and per-language READMEs"
```

---

## Task 10: Final Verification

- [ ] **Step 1: Run all test suites**

```bash
cd js     && npm test
cd ../python && pytest -v
cd ../dart   && dart test
cd ../swift  && swift test
cd ../kotlin && ./gradlew test
cd ../csharp && dotnet test
```

Expected: all pass across all 6 languages.

- [ ] **Step 2: Verify test vector coverage**

Confirm that Easter dates 2025–2037 all match, and Nineveh Fast 2025–2026 match printed Coptic calendars.

- [ ] **Step 3: Final commit**

```bash
git add -A
git commit -m "chore: final verification — all 6 language test suites passing"
```
