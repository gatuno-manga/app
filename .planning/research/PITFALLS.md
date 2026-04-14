# Pitfalls Research

**Domain:** Flutter mobile CI/CD release automation on GitHub Actions  
**Researched:** 2026-04-14  
**Confidence:** MEDIUM

## Critical Pitfalls

### Pitfall 1: Semver trigger mismatch

**What goes wrong:** Release workflow triggers on malformed tags or misses valid tags, causing missing or accidental releases.  
**Why it happens:** Tag pattern and validation logic are inconsistent across YAML and scripts.  
**How to avoid:** Use a single semver validation rule and fail fast before build jobs.  
**Warning signs:** Workflow runs for tags like `test` or fails on expected tags like `v1.2.3`.  
**Phase to address:** Phase 1 (Release workflow foundation).

---

### Pitfall 2: Non-reproducible build toolchain

**What goes wrong:** Same commit produces different outcomes across runs.  
**Why it happens:** Floating action refs and unpinned Flutter/Xcode assumptions.  
**How to avoid:** Pin Flutter channel/version, pin major action versions, document runner assumptions.  
**Warning signs:** Intermittent CI failures with no code changes.  
**Phase to address:** Phase 1 (Foundation) + Phase 2 (Platform builds).

---

### Pitfall 3: iOS unsigned artifact confusion

**What goes wrong:** Team expects App Store-ready IPA but pipeline outputs non-distributable artifact without signing.  
**Why it happens:** No certificate/provisioning profile strategy defined upfront.  
**How to avoid:** Explicitly label outputs as unsigned and document intended consumption.  
**Warning signs:** Stakeholders cannot install/use iOS artifact as expected.  
**Phase to address:** Phase 2 (Build implementation).

---

### Pitfall 4: Duplicate/partial release assets

**What goes wrong:** Re-running workflow creates duplicate files or leaves release with mixed old/new assets.  
**Why it happens:** Publish job is not idempotent and lacks asset replace policy.  
**How to avoid:** Enforce deterministic artifact names and replace/cleanup strategy before upload.  
**Warning signs:** Same release has multiple similarly named assets with conflicting timestamps.  
**Phase to address:** Phase 3 (Release publish and hardening).

---

### Pitfall 5: Missing concurrency controls

**What goes wrong:** Concurrent runs for same tag race and corrupt release state.  
**Why it happens:** `concurrency` is omitted or keyed incorrectly.  
**How to avoid:** Use tag-scoped concurrency group and cancel or block duplicates.  
**Warning signs:** Multiple runs active for identical tag, inconsistent release content.  
**Phase to address:** Phase 1 (Foundation).

---

### Pitfall 6: Over-scoped first milestone

**What goes wrong:** Team includes store publishing, signing automation, and release governance too early; delivery stalls.  
**Why it happens:** Trying to solve all release maturity levels in one iteration.  
**How to avoid:** Keep milestone focused on build + release asset publication only.  
**Warning signs:** Long-lived branch, repeated YAML rewrites, no shippable result.  
**Phase to address:** Phase 0 planning and roadmap validation.

## Technical Debt Patterns

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Hardcoding Flutter/tool versions in many places | Fast initial setup | Drift and painful upgrades | Acceptable only if centralized quickly |
| Publishing directly from build jobs | Less YAML upfront | Weak observability and rerun control | Acceptable only in throwaway experiments |
| Silent fallback from signed to unsigned | Reduced failures | Artifact trust ambiguity | Never acceptable for production releases |

## Integration Gotchas

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| GitHub Releases | Assume release always exists | Implement create-or-update idempotent logic |
| Flutter builds | Run iOS build on non-macOS runner | Keep iOS on macOS runner explicitly |
| Artifact upload | Upload from ephemeral paths late | Collect artifacts to deterministic staging path first |

## Performance Traps

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| No dependency caching | Very long pipeline durations | Cache pub, Gradle, CocoaPods by lock/tool versions | Frequent releases or cold runners |
| Over-serial workflow | 2x+ runtime growth | Parallelize Android/iOS builds after quality gate | Medium release volume |
| Running release checks after build | Wasted runner minutes | Validate tag + test/analyze first | Any failed quality run |

## Security Mistakes

| Mistake | Risk | Prevention |
|---------|------|------------|
| Broad default `GITHUB_TOKEN` permissions | Excessive blast radius on compromise | Principle of least privilege per job |
| Logging sensitive env variables | Secret leakage in build logs | Mask secrets and avoid echoing env values |
| Uploading ambiguous artifacts without integrity info | Supply-chain confusion | Include checksums and deterministic names |

## UX Pitfalls

| Pitfall | User Impact | Better Approach |
|---------|-------------|-----------------|
| Inconsistent asset naming per run | Users download wrong file | Standard naming with version/platform/build type |
| No release notes or context | Hard to understand what changed | Auto-generate concise release notes |
| Mixing signed and unsigned assets without labels | Installation failures and confusion | Explicit suffixes (`unsigned`, `signed`) |

## "Looks Done But Isn't" Checklist

- [ ] **Tag trigger:** Validates strict semver before any build starts
- [ ] **Android artifact:** Output path stable and uploaded successfully
- [ ] **iOS artifact:** Explicitly documented as unsigned (if no signing)
- [ ] **Release publish:** Re-run for same tag does not duplicate/corrupt assets
- [ ] **Permissions:** Workflow uses minimal token scope
- [ ] **Observability:** Failed stage is obvious from job names and logs

## Recovery Strategies

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| Duplicate assets in release | LOW | Delete wrong assets, rerun publish job with overwrite strategy |
| Bad tag triggered release | MEDIUM | Remove release/tag, fix semver guard, recreate tag |
| Broken iOS output expectation | MEDIUM | Update docs/naming, communicate unsigned limitation, rerun with clear labels |

## Pitfall-to-Phase Mapping

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| Semver trigger mismatch | Phase 1 | Invalid tags fail before build jobs |
| Non-reproducible toolchain | Phase 1-2 | Same commit/tag produces stable outputs |
| iOS unsigned confusion | Phase 2 | Release assets and docs clearly mark unsigned status |
| Duplicate release assets | Phase 3 | Re-running publish remains idempotent |
| Missing concurrency controls | Phase 1 | Only one run per tag active |

## Sources

- GitHub Actions workflow syntax: https://docs.github.com/actions/using-workflows/workflow-syntax-for-github-actions
- GitHub Releases docs: https://docs.github.com/repositories/releasing-projects-on-github
- Flutter deployment docs: https://docs.flutter.dev/deployment

---
*Pitfalls research for: Flutter CI/CD release automation*
*Researched: 2026-04-14*
