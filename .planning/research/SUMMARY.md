# Project Research Summary

**Project:** Gatuno  
**Domain:** Flutter mobile CI/CD release automation for semantic-tag releases  
**Researched:** 2026-04-14  
**Confidence:** MEDIUM

## Executive Summary

Research indicates the safest path is a tag-driven GitHub Actions workflow that separates validation, platform builds, and release publication into distinct jobs. For this project stage, unsigned artifacts are a valid and pragmatic milestone because signing infrastructure is not yet provisioned.

A strong v1 release automation baseline should: validate semver tags, run quality gates, build Android and iOS artifacts in parallel, then create/update a GitHub Release and attach deterministic assets. This approach minimizes accidental releases and keeps reruns predictable.

Main risks are semver misconfiguration, non-idempotent release uploads, and confusion around iOS unsigned outputs. These are mitigated by strict trigger guards, concurrency controls, explicit artifact naming, and documented release behavior.

## Key Findings

### Recommended Stack

Use GitHub Actions with pinned setup actions, a macOS-capable build environment, and an idempotent release publishing step. Keep workflow logic split by responsibility and move brittle shell logic into `scripts/release/` helpers for maintainability.

**Core technologies:**
- **GitHub Actions:** Orchestrates tag-triggered release flow — native integration with Releases and permissions
- **`subosito/flutter-action@v2`:** Standard Flutter runtime setup — stable cross-project baseline
- **`softprops/action-gh-release@v2` (or `gh` CLI):** Reliable release create/update and asset upload — supports rerun-safe publishing
- **`upload/download-artifact@v4`:** Clean artifact handoff between jobs — improves debuggability

### Expected Features

From research, table stakes include semver tag trigger, reproducible toolchain, parallel Android+iOS builds, auto release creation, and artifact upload. Differentiators (later) include release notes automation, checksums/provenance, and channel-aware prereleases.

**Must have (table stakes):**
- Semantic tag trigger with strict validation
- Quality gate (`flutter analyze`, `flutter test`) before build
- Parallel Android+iOS build outputs
- Idempotent GitHub Release create-or-update
- Deterministic artifact naming and upload

**Should have (competitive):**
- Auto-generated release notes
- Checksums/provenance metadata

**Defer (v2+):**
- App Store / Play Store publishing
- Full signing automation with protected environments

### Architecture Approach

Recommended architecture is a three-layer release pipeline: (1) Trigger & control, (2) Platform builds, (3) Publish & audit. Each layer has clear contracts and job dependencies, enabling partial reruns and reducing blast radius of failures.

**Major components:**
1. **Trigger controller** — validates tags and enforces concurrency
2. **Build workers** — produce Android/iOS artifacts independently
3. **Publish orchestrator** — creates/updates release and uploads assets

### Critical Pitfalls

1. **Semver trigger mismatch** — enforce one canonical validation rule
2. **Non-reproducible toolchain** — pin actions and runtime versions
3. **iOS unsigned expectation mismatch** — label/document artifacts clearly
4. **Duplicate release assets** — enforce idempotent publish behavior
5. **Missing concurrency controls** — use per-tag concurrency groups

## Implications for Roadmap

Based on research, suggested phase structure:

### Phase 1: Release Workflow Foundation
**Rationale:** Prevent accidental or inconsistent releases before adding build complexity.  
**Delivers:** Tag trigger, semver guard, permissions, concurrency, quality gate.  
**Addresses:** Trigger correctness and reliability table stakes.  
**Avoids:** Semver mismatch and concurrency pitfalls.

### Phase 2: Multi-Platform Unsigned Build
**Rationale:** Produce the core release outputs required by the user.  
**Delivers:** Android and iOS unsigned artifact generation with stable naming.  
**Uses:** Flutter setup stack and macOS runner strategy.  
**Implements:** Build layer architecture component.

### Phase 3: Release Publish & Asset Management
**Rationale:** Close the loop from build to consumable release output.  
**Delivers:** Release create-or-update and artifact upload logic.  
**Uses:** Idempotent publish pattern and artifact handoff.  
**Implements:** Publish & audit layer.

### Phase 4: Hardening and Readiness for Signed Distribution (optional next milestone)
**Rationale:** Add maturity once baseline flow is stable.  
**Delivers:** Signing-ready structure, checksums/provenance, improved governance.

### Phase Ordering Rationale

- Ordering follows dependency chain: trigger correctness before builds, builds before publishing.
- Isolating publish phase prevents release corruption while build behavior stabilizes.
- Early focus on deterministic outputs reduces technical debt before signing/store automation.

### Research Flags

Phases likely needing deeper research during planning:
- **Phase 2:** iOS unsigned artifact expectations and best packaging format for internal release assets.
- **Phase 4:** Signing and store-distribution integration once credentials are available.

Phases with standard patterns (skip research-phase):
- **Phase 1:** Tag triggers, quality gates, and concurrency are well-documented GitHub Actions patterns.
- **Phase 3:** Release create/upload flow is standard using GitHub APIs/actions.

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | MEDIUM | Official docs are clear; version specifics may evolve quickly |
| Features | HIGH | Strong cross-project consensus for CI/CD table stakes |
| Architecture | MEDIUM | Pattern is established; repo-specific refinements expected |
| Pitfalls | MEDIUM | Common industry failures, but team process impacts severity |

**Overall confidence:** MEDIUM

### Gaps to Address

- Exact iOS artifact format policy for unsigned releases should be validated during planning.
- Desired Android output matrix (APK only vs APK + AAB) should be finalized in phase planning.

## Sources

### Primary (HIGH confidence)
- GitHub Actions docs — workflow syntax, concurrency, permissions
- GitHub Releases docs — create/update/upload asset behavior
- Flutter deployment docs — Android/iOS build output behavior

### Secondary (MEDIUM confidence)
- Existing `.planning/research/FEATURES.md` domain synthesis
- Existing `.planning/PROJECT.md` scope and constraints

---
*Research completed: 2026-04-14*
*Ready for roadmap: yes*
