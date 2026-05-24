// go.mod at repo root so the module's versions track repo-wide tags
// (v0.1.4, v0.1.5, …) without needing subdirectory-prefixed tags.
// The Go source files live in go/ — that's a subpackage at import path
// `github.com/amir-magdy-of-wizardlabz/kiahk/go`. Same pattern as
// Kiahk.podspec (root) + Package.swift (root) with sources in subdirs.
module github.com/amir-magdy-of-wizardlabz/kiahk

go 1.22
