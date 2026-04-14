# Feature Landscape

**Domain:** Flutter mobile CI/CD and GitHub Actions release automation (Android + iOS)  
**Researched:** 2026-04-14

## Table Stakes

Features users/teams expect in a production-ready release automation baseline.

| Feature | Why Expected | Complexity | Dependencies | Notes |
|---------|--------------|------------|--------------|-------|
| Semantic tag trigger (`vX.Y.Z`) | Release pipelines should run only on intentional version tags | Low | Git tag convention; branch protection | Prevents noisy builds and accidental releases |
| Reproducible build environment (pinned Flutter + action versions) | CI/CD must be stable over time | Low | `subosito/flutter-action`; pinned action SHAs | Avoid floating `@main`/`@master` |
| Android + iOS build in same workflow run | Cross-platform artifact delivery is core for Flutter apps | Medium | macOS runner, Xcode, Android SDK | Use separate jobs with shared version metadata |
| Automatic GitHub Release creation/update | Teams expect tags to map 1:1 with release objects | Low | `gh` CLI or `actions/create-release`/REST API | Must be idempotent when release already exists |
| Artifact upload to Release (APK/AAB + iOS artifact) | Primary output of release automation | Medium | `actions/upload-artifact`; release upload step | Consistent naming: app-vX.Y.Z-platform.ext |
| Unsigned build path support | Early-stage teams often lack signing secrets initially | Medium | Conditional workflow logic; build flavor config | Keep path explicit to avoid signing-related failures |
| CI quality gate before publish (`flutter analyze`, `flutter test`) | Prevent shipping broken code from tag builds | Medium | test stability; analyzer config | Fail fast before expensive build steps |
| Concurrency + duplicate-run protection | Tag pipelines must not publish duplicate artifacts | Low | `concurrency` key in workflow | Cancel stale runs or block parallel runs per tag |

## Differentiators

Capabilities that improve reliability, speed, and auditability beyond baseline expectations.

| Feature | Value Proposition | Complexity | Dependencies | Notes |
|---------|-------------------|------------|--------------|-------|
| Auto-generated release notes from commits/PR labels | Faster release communication with less manual work | Low | GitHub Release notes API | Useful even without store publishing |
| Channel-aware releases (`-alpha`, `-beta`, stable) | Supports phased rollout strategy early | Medium | Tag parsing rules; prerelease flags | Maps semantic tags to GitHub prerelease state |
| Build provenance + checksums (SHA256) attached to release | Increases trust and traceability of binaries | Medium | checksum generation step; optional attestation | Strong differentiator for security-conscious teams |
| Workflow reuse/composite actions for mobile build steps | Scales better across repos/branches | Medium | reusable workflows; shared action repo | Reduces duplicated YAML and drift |
| Incremental caching strategy (pub, Gradle, CocoaPods) with hit metrics | Faster cycle time and lower CI cost | Medium | cache keys by lockfiles and tool versions | Needs careful invalidation to avoid flaky builds |
| Environment protection + manual approval for production tags | Better governance for formal releases | Medium | GitHub Environments; required reviewers | Keeps automation while adding control |

## Anti-Features

Things to explicitly avoid in this milestone.

| Anti-Feature | Why Avoid | What to Do Instead |
|--------------|-----------|-------------------|
| Direct Play Store/App Store publishing now | Out of scope; introduces credential/review complexity | Stop at GitHub Release artifact publication |
| Mandatory code-signing in first iteration | Secrets/certificates not ready; blocks delivery | Ship unsigned artifacts with clear naming and docs |
| Single mega-job workflow (build everything in one step) | Hard to debug, rerun, and scale | Split by job: validate → build_android/build_ios → publish |
| Auto-run on every push/PR for release workflow | Wastes CI budget and risks accidental release attempts | Trigger release pipeline only on semantic tags |
| Custom self-hosted runner setup for baseline | Increases ops burden and security surface too early | Use GitHub-hosted runners first; optimize later |

## Feature Dependencies

```text
Tag convention + versioning policy
  → Tag-triggered workflow
    → Quality gates (analyze/test)
      → Platform builds (Android, iOS)
        → Artifact packaging/naming
          → Release create-or-update
            → Artifact upload
              → (optional) release notes/checksums/provenance
```

## MVP Recommendation (for this milestone)

Prioritize:
1. Tag-triggered workflow with concurrency guard
2. Quality gate + parallel Android/iOS unsigned builds
3. Idempotent GitHub Release creation and artifact upload

Defer:
- Store publishing automation: out of scope for initial release automation milestone
- Full signing automation: depends on secret/certificate provisioning
- Advanced governance (manual approvals, provenance attestations): phase 2 hardening

## Sources

- GitHub Actions workflow syntax (events, concurrency): https://docs.github.com/actions/using-workflows/workflow-syntax-for-github-actions  
- GitHub Releases API/docs (create/update/upload assets): https://docs.github.com/rest/releases  
- GitHub automatic release notes: https://docs.github.com/repositories/releasing-projects-on-github/automatically-generated-release-notes  
- Flutter deployment docs (Android/iOS build outputs): https://docs.flutter.dev/deployment  
