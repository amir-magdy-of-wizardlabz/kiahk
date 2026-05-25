#!/usr/bin/env bash
#
# Bump the kiahk version across all language ports + version-pinned READMEs.
#
# Usage:
#   scripts/bump-version.sh <OLD> <NEW>
#   e.g. scripts/bump-version.sh 0.1.5 0.1.6
#
# Files touched (lockstep — every port bumps together):
#   - js/package.json                 "version": "..."
#   - py/pyproject.toml               version = "..."
#   - dart/pubspec.yaml               version: ...
#   - csharp/Kiahk/Kiahk.csproj       <Version>...</Version>
#   - Kiahk.podspec                   s.version = '...'
#   - kotlin/gradle.properties        version=...
#   - Package.swift                   // .package(... from: "...")  (comment only)
#   - swift/README.md                 from: "..."  AND  ~> ...
#   - c/README.md                     kiahk-c-vX.Y.Z.tar.gz  AND  kiahk-c-vX.Y.Z subdir
#   - kotlin/README.md                kiahk:X.Y.Z in 3 install snippets
#   - README.md                       Kotlin row in distributions table
#   - dart/CHANGELOG.md               prepends a "## NEW" heading stub (you fill in body)
#
# Does NOT touch:
#   - composer.json (Packagist reads tags, not the manifest)
#   - .github/workflows/*.yml (only example text in input descriptions, not functional)
#   - "v0.1.4, v0.1.5, ..." example strings in go.mod and go/README.md (they're sequence illustrations)
#   - dart/CHANGELOG.md older entries (only prepends the new one)

set -euo pipefail

if [ $# -ne 2 ]; then
    echo "Usage: $0 <OLD> <NEW>"
    echo "Example: $0 0.1.5 0.1.6"
    exit 1
fi

OLD="$1"
NEW="$2"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if ! [[ "$OLD" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: OLD version must be semver (X.Y.Z), got: $OLD" >&2
    exit 1
fi
if ! [[ "$NEW" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: NEW version must be semver (X.Y.Z), got: $NEW" >&2
    exit 1
fi

# macOS sed needs '' after -i for in-place edits. GNU sed (Linux) doesn't.
# Probe once and reuse.
if sed --version >/dev/null 2>&1; then
    SED_INPLACE=(-i)        # GNU sed
else
    SED_INPLACE=(-i '')     # BSD/macOS sed
fi

bump_file() {
    local file="$1" pattern="$2" desc="$3"
    if [ ! -f "$file" ]; then
        echo "  skip:    $file (not found)" >&2
        return
    fi
    if ! grep -q "$OLD" "$file"; then
        echo "  no-op:   $file ($desc has no $OLD)"
        return
    fi
    sed "${SED_INPLACE[@]}" "$pattern" "$file"
    echo "  bumped:  $file ($desc)"
}

echo "Bumping kiahk: $OLD -> $NEW"
echo

# ----- canonical manifests -----
bump_file js/package.json              "s|\"version\": \"$OLD\"|\"version\": \"$NEW\"|"                "js npm version"
bump_file py/pyproject.toml            "s|^version = \"$OLD\"$|version = \"$NEW\"|"                  "PyPI version"
bump_file dart/pubspec.yaml            "s|^version: $OLD$|version: $NEW|"                            "pub.dev version"
bump_file csharp/Kiahk/Kiahk.csproj    "s|<Version>$OLD</Version>|<Version>$NEW</Version>|"          "NuGet version"
bump_file Kiahk.podspec                "s|s.version          = '$OLD'|s.version          = '$NEW'|"  "CocoaPods version"
bump_file kotlin/gradle.properties     "s|^version=$OLD$|version=$NEW|"                              "Maven Central version"

# ----- doc references that pin the version -----
bump_file Package.swift                "s|from: \"$OLD\"|from: \"$NEW\"|"                            "Package.swift comment"
bump_file swift/README.md              "s|from: \"$OLD\"|from: \"$NEW\"|"                            "Swift README SPM line"
bump_file swift/README.md              "s|'~> $OLD'|'~> $NEW'|"                                      "Swift README Podfile line"
bump_file c/README.md                  "s|kiahk-c-v$OLD\\.tar\\.gz|kiahk-c-v$NEW.tar.gz|"            "C README tarball URL"
bump_file c/README.md                  "s|kiahk-c-v$OLD|kiahk-c-v$NEW|g"                             "C README CMake subdir"
bump_file kotlin/README.md             "s|kiahk:$OLD|kiahk:$NEW|g"                                   "Kotlin README install snippets"
bump_file kotlin/README.md             "s|<version>$OLD</version>|<version>$NEW</version>|"          "Kotlin README Maven xml"
bump_file README.md                    "s|kiahk:$OLD|kiahk:$NEW|g"                                   "main README distributions table"

# ----- prepend a new entry stub to the Dart CHANGELOG so pub.dev's "Changelog" tab updates -----
CHANGELOG="dart/CHANGELOG.md"
if [ -f "$CHANGELOG" ] && ! grep -q "^## $NEW$" "$CHANGELOG"; then
    tmp=$(mktemp)
    {
        head -1 "$CHANGELOG"                              # "# Changelog"
        echo ""
        echo "## $NEW"
        echo ""
        echo "- (TODO: describe this release before tagging)"
        echo ""
        tail -n +2 "$CHANGELOG"
    } > "$tmp"
    mv "$tmp" "$CHANGELOG"
    echo "  prepended: $CHANGELOG (## $NEW stub — FILL IN BEFORE COMMITTING)"
fi

echo
echo "Done. Review with: git diff --stat"
echo "Then commit + tag v$NEW."
