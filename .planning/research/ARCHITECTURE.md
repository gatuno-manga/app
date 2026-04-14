# Architecture Research

**Domain:** Flutter mobile CI/CD release automation on GitHub Actions  
**Researched:** 2026-04-14  
**Confidence:** MEDIUM

## Standard Architecture

### System Overview

```text
┌─────────────────────────────────────────────────────────────┐
│                    Trigger & Control Layer                 │
├─────────────────────────────────────────────────────────────┤
│  ┌───────────────┐   ┌────────────────┐   ┌──────────────┐ │
│  │ Tag Trigger   │   │ Version Guard  │   │ Concurrency   │ │
│  │ (vX.Y.Z)      │   │ + Preconditions│   │ Lock per tag  │ │
│  └──────┬────────┘   └──────┬─────────┘   └──────┬───────┘ │
│         │                   │                    │          │
├─────────┴───────────────────┴────────────────────┴──────────┤
│                        Build Layer                           │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐    ┌──────────────────┐                │
│  │ Android Build   │    │ iOS Build        │                │
│  │ (unsigned)      │    │ (unsigned path)  │                │
│  └────────┬────────┘    └─────────┬────────┘                │
│           │                       │                         │
│           └──────────────┬────────┘                         │
├──────────────────────────┴───────────────────────────────────┤
│                     Publish & Audit Layer                    │
│  ┌────────────────┐  ┌────────────────────┐  ┌────────────┐ │
│  │ Release Create │  │ Asset Upload       │  │ Metadata    │ │
│  │ (idempotent)   │  │ (per platform)     │  │ + Checksums │ │
│  └────────────────┘  └────────────────────┘  └────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### Component Responsibilities

| Component | Responsibility | Typical Implementation |
|-----------|----------------|------------------------|
| Tag trigger + validation | Ensure workflow runs only for valid semantic tags | `on.push.tags` + regex guard in first job |
| Quality gate | Stop release if code is unhealthy | `flutter analyze` + `flutter test` |
| Android build job | Produce Android artifacts for release | `flutter build apk` / `flutter build appbundle` |
| iOS build job | Produce iOS artifact path for release packaging | `flutter build ios --no-codesign` + archive handling |
| Release publish job | Create/update release and upload assets | `softprops/action-gh-release` or `gh release` |
| Naming/metadata | Prevent artifact ambiguity and aid traceability | deterministic file names + tag metadata |

## Recommended Project Structure

```text
.github/
└── workflows/
    ├── release-tag.yml          # Full tag-triggered release flow
    └── ci-quality.yml           # Optional shared CI checks

scripts/
└── release/
    ├── validate-tag.sh          # Semver checks and normalization
    ├── collect-artifacts.sh     # Gather outputs into release bundle
    └── release-notes.sh         # Optional release notes helper

docs/
└── release-process.md           # Human-facing release policy and outputs
```

### Structure Rationale

- **`.github/workflows/`:** Keeps automation declarative, reviewable, and enforceable in PRs.
- **`scripts/release/`:** Moves fragile shell logic out of YAML, improving readability and testability.
- **`docs/release-process.md`:** Aligns engineering and product expectations around what each release produces.

## Architectural Patterns

### Pattern 1: Split Jobs with Artifact Handoff

**What:** Independent jobs for validation, Android build, iOS build, and publish.  
**When to use:** Always for multi-platform releases.  
**Trade-offs:** Slightly more YAML, but much better debuggability and retry control.

### Pattern 2: Idempotent Publish Step

**What:** Publish job can safely re-run for the same tag without duplicate/broken assets.  
**When to use:** Any production release flow.  
**Trade-offs:** Requires explicit release lookup + overwrite strategy decisions.

### Pattern 3: Capability Flags for Signing

**What:** Conditional paths for unsigned vs signed artifact generation.  
**When to use:** Teams migrating gradually toward full store distribution.  
**Trade-offs:** More branch logic, but safer evolution without blocking initial delivery.

## Data Flow

### Request Flow

```text
Git tag push (vX.Y.Z)
    ↓
Validate tag + lock concurrency
    ↓
Run quality checks
    ↓
Build Android + build iOS (parallel)
    ↓
Collect artifacts
    ↓
Create/update GitHub Release
    ↓
Upload artifacts + metadata
```

### State Management

```text
Workflow run context
    ↓
Job outputs (version, artifact names)
    ↓
Artifacts storage
    ↓
Release assets (persistent distribution point)
```

### Key Data Flows

1. **Version flow:** Git tag value becomes release name/title and artifact suffix.
2. **Artifact flow:** Platform build outputs move from job workspace to uploaded release assets.
3. **Failure flow:** Any failed quality/build gate prevents publish step.

## Scaling Considerations

| Scale | Architecture Adjustments |
|-------|--------------------------|
| 0-10 releases/month | Single workflow file with split jobs is sufficient |
| 10-50 releases/month | Introduce reusable workflows/composite actions and stronger caching |
| 50+ releases/month | Add environment approvals, governance, and potentially self-hosted capacity |

### Scaling Priorities

1. **First bottleneck:** macOS build time/cost — optimize cache and parallelism.
2. **Second bottleneck:** release reliability — add stronger retry/idempotency for asset upload.

## Anti-Patterns

### Anti-Pattern 1: Build and publish in one monolithic job

**What people do:** One step does everything serially.  
**Why it's wrong:** Hard to diagnose failures and rerun only failed portions.  
**Do this instead:** Separate jobs with explicit artifact handoff.

### Anti-Pattern 2: Implicit release behavior

**What people do:** Assume release exists or let steps fail unpredictably.  
**Why it's wrong:** Causes flaky runs and manual repair.  
**Do this instead:** Explicit "create-or-update" release logic.

## Integration Points

### External Services

| Service | Integration Pattern | Notes |
|---------|---------------------|-------|
| GitHub Releases | REST API or release action in publish job | Must be idempotent for reruns |
| GitHub Artifact service | upload/download artifact actions | Use deterministic naming |
| Flutter toolchain | setup action + flutter commands | Pin version/channel for stability |

### Internal Boundaries

| Boundary | Communication | Notes |
|----------|---------------|-------|
| Validate ↔ Build jobs | Job dependencies + shared outputs | Prevent build on invalid tag |
| Build ↔ Publish jobs | Uploaded artifacts | Decouples build failure from release logic |
| Workflow ↔ Repo policy | Protected tags/branches + permissions | Avoid accidental release triggers |

## Sources

- GitHub Actions docs: https://docs.github.com/actions
- GitHub Releases docs: https://docs.github.com/repositories/releasing-projects-on-github
- Flutter deployment docs: https://docs.flutter.dev/deployment

---
*Architecture research for: Flutter CI/CD release automation*
*Researched: 2026-04-14*
