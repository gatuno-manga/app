---
phase: 1
slug: release-trigger-control-quality-gates
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-04-14
---

# Phase 1 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | flutter_test (Flutter SDK) |
| **Config file** | none explicit (Flutter defaults) |
| **Quick run command** | `flutter analyze && flutter test` |
| **Full suite command** | `flutter test` |
| **Estimated runtime** | ~120 seconds |

---

## Sampling Rate

- **After every task commit:** Run `flutter analyze && flutter test`
- **After every plan wave:** Run `flutter test`
- **Before `/gsd-verify-work`:** Full suite must be green
- **Max feedback latency:** 180 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 01-01-01 | 01 | 1 | TRIG-01 | T-01-01 | Trigger only semantic tag `vX.Y.Z` path | workflow integration | `gh workflow run` / tag-based run evidence | ❌ W0 | ⬜ pending |
| 01-01-02 | 01 | 1 | TRIG-02 | T-01-02 | Invalid tag fails before build jobs | workflow integration | run validation job and inspect skipped downstream jobs | ❌ W0 | ⬜ pending |
| 01-01-03 | 01 | 1 | TRIG-03 | T-01-03 | Only one active run per tag with cancellation policy | workflow integration | create concurrent runs and verify cancellation | ❌ W0 | ⬜ pending |
| 01-01-04 | 01 | 1 | TRIG-04 | T-01-04 | Quality gate blocks release path on analyze/test failure | CI gate | `flutter analyze && flutter test` | ✅ | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `.github/workflows/release.yml` — create validation-first workflow skeleton
- [ ] `docs/release-validation-checklist.md` — evidence checklist for TRIG-01/02/03 run verification
- [ ] `actionlint` local optional setup (or CI lint fallback) for YAML static checks

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Tag push acceptance path | TRIG-01 | Requires GitHub Actions runtime event behavior | Push valid and invalid tags in test repository; compare workflow run outcomes |
| Concurrency cancellation | TRIG-03 | Depends on overlapping cloud-run timing | Trigger two runs for same tag/ref and verify earlier run cancellation |
| Main ancestry enforcement | TRIG-02 | Requires git history and remote branch state | Tag non-main ancestor and verify validation failure message |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 180s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
