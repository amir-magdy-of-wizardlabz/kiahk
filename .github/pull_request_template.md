<!--
Thanks for the PR! A few quick checks before you click Submit.
See CONTRIBUTING.md for the full guide.
-->

## Summary

<!-- One or two sentences: what does this PR change, and why? -->

## Type of change

<!-- Tick whatever applies. -->

- [ ] Bug fix in an existing port
- [ ] New language port (added a new sibling directory)
- [ ] Algorithm / `core/` spec change (affects every port)
- [ ] Tooling, CI, or release infrastructure
- [ ] Docs / README only

## Affected ports

<!-- List the directories you touched: e.g. js/, kotlin/, all of them, none (docs-only). -->

## How I tested this

<!--
- Did you run the affected port's tests locally? Paste pass/fail counts.
- For algorithm changes, did you add new entries to core/test-vectors.json so every port checks the new case?
- Edge cases considered?
-->

## Cross-port impact (only if you touched `core/` or an algorithm)

<!--
- [ ] core/algorithms.md updated
- [ ] core/test-vectors.json updated with the new case
- [ ] EVERY port updated to match (mark which ports you've propagated to and which still need it)
-->

## Checklist

- [ ] My code follows the patterns of the existing ports (naming, error types, public surface)
- [ ] I added tests that cover the change (or explained why they aren't needed)
- [ ] Touched port's CI passes locally
- [ ] If a new port: added the row to the main README distributions table + badge rows + CHANGELOG entry
- [ ] No secrets, tokens, or PII committed
- [ ] No unrelated formatting churn

## Related issue

<!-- Closes #N -->
