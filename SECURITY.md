# Security Policy

## Supported versions

kiahk follows lockstep versioning across all 9 language ports. Security fixes are only backported to the **latest released minor version**.

| Version | Supported |
|---|---|
| 0.1.x (latest minor) | ✅ |
| earlier | ❌ (please upgrade) |

The current latest version is shown in the badges at the top of [`README.md`](README.md) and on every port's package page (npm, PyPI, Packagist, Maven Central, etc.).

## Threat model

kiahk is a pure calendar-arithmetic library. It has **no network I/O, no filesystem I/O at runtime, no native code dependencies, and no dynamic execution**. The realistic threat surface is therefore narrow:

- **Numeric overflow or underflow** in the Gregorian↔Coptic conversion (e.g. very large or negative year inputs producing wrong but apparently valid output).
- **Validation bypass** allowing construction of an invalid `CopticDate` / `GregorianDate` that downstream code treats as trusted.
- **Algorithm divergence** between ports — a bug producing different results on the same input across languages would be a correctness issue with security implications for systems that cross-check.
- **Supply chain** — compromise of a maintainer publishing token (npm, NuGet, Maven, Sonatype, etc.).

If you've found something that fits any of the above, treat it as security-relevant and report it privately.

## Reporting a vulnerability

**Please do NOT open a public GitHub issue.** Use one of:

1. **GitHub Security Advisories** (preferred): <https://github.com/amir-magdy-of-wizardlabz/kiahk/security/advisories/new>
   - Lets you privately collaborate on the fix and get a CVE assigned via the GitHub CNA.
2. **Email**: `amir.magdy@wizardlabz.com` with subject `[kiahk-security]`.
   - PGP key: `285B0611CBD481E6` on [keys.openpgp.org](https://keys.openpgp.org/search?q=amir.magdy%40wizardlabz.com).

Please include:

- Which port(s) are affected (e.g. `js`, `kotlin`, all of them).
- The version you tested against.
- A minimal reproduction (input + observed vs expected output).
- An assessment of impact if you have one — happy to discuss.

## What to expect

| Step | Timeline |
|---|---|
| Initial acknowledgement | within **72 hours** |
| Confirmation or rejection of the report | within **7 days** |
| Coordinated fix + release across all 9 ports | within **30 days** of confirmation (calendar-arithmetic fixes tend to be small) |
| Public disclosure (advisory + CVE if applicable) | after the fix is published to every registry |

Because every port ships from the same canonical spec in [`core/`](core/), a fix usually means: amend `core/algorithms.md` or `core/test-vectors.json`, then propagate the equivalent code change to every port. Lockstep releases ensure no port lingers on a vulnerable version.

## Responsible disclosure credit

If you'd like to be credited in the advisory and/or the release notes for the fix, let me know in your report.
