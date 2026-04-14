# Stack Research

**Domain:** Flutter mobile CI/CD release automation on GitHub Actions (Android + iOS)  
**Researched:** 2026-04-14  
**Confidence:** MEDIUM

## Recommended Stack

### Core Technologies

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| GitHub Actions | Workflow syntax v2 + pinned actions | Orchestrate tag-triggered pipelines | Native integration with tags, releases, artifacts, and permissions |
| `subosito/flutter-action` | v2 | Install/pin Flutter SDK in CI jobs | Standard choice for Flutter setup in Actions workflows |
| `actions/setup-java` | v4 | Provision Java for Android build tooling | Required for Gradle/Android toolchain stability |
| macOS GitHub-hosted runners | `macos-14` (or pinned current stable) | Build iOS and Android in one platform-capable runner set | iOS builds require macOS/Xcode; consistent hosted environment |
| `softprops/action-gh-release` (or GitHub CLI) | v2 | Create/update GitHub Release and upload assets | Idempotent release flows with simple asset upload semantics |
| `actions/upload-artifact` / `actions/download-artifact` | v4 | Pass build outputs across jobs | Clean separation between build jobs and publish job |

### Supporting Libraries

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `actions/cache` | v4 | Cache pub, Gradle, and CocoaPods data | Use when release runs are frequent and cold-start time is high |
| `ruby/setup-ruby` | v1 | Fastlane/tooling runtime | Use if introducing store publication or advanced metadata later |
| `jq` (CLI) | system package | Parse semver tags / release metadata | Useful for robust tag validation and manifest extraction |
| GitHub REST API / `gh` CLI | latest compatible | Release lookup/create/update fallback | Use for stricter control beyond one-action defaults |

### Development Tools

| Tool | Purpose | Notes |
|------|---------|-------|
| `flutter analyze` + `flutter test` in CI | Quality gate before release artifacts | Run before expensive build steps |
| Local `scripts/release/` helpers | Keep workflow YAML small and maintainable | Put tag parsing and naming rules into scripts |
| Branch/tag protection rules | Prevent accidental release triggers | Protect `main` and enforce annotated semver tags |

## Installation

```bash
# Workflow files
mkdir -p .github/workflows scripts/release

# Optional local validation tools
flutter --version
dart --version
gh --version
```

## Alternatives Considered

| Recommended | Alternative | When to Use Alternative |
|-------------|-------------|-------------------------|
| `softprops/action-gh-release` | GitHub CLI (`gh release create/upload`) | When you need custom retry/error handling in shell scripts |
| Hosted macOS runners | Self-hosted macOS runners | When build volume/cost justifies infra ownership |
| Single release pipeline by tag | Multi-pipeline orchestration (build + publish workflows) | When governance or approval gates require separated workflows |
| GitHub Actions only | Codemagic/Bitrise/fastlane-first pipelines | When deep mobile distribution workflows are required immediately |

## What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| Floating action refs (e.g., `@master`) | Non-deterministic builds and breakage risk | Pin major versions or commit SHAs |
| Release pipeline on every push | High CI cost and accidental publishing attempts | Trigger only on semantic tags |
| One giant build-and-publish step | Poor debuggability and weak retry strategy | Split: validate → build → publish |
| Forcing mandatory signing now | Blocks delivery while secrets are not provisioned | Support unsigned artifacts first, add signing later |

## Stack Patterns by Variant

**If no signing secrets exist (current milestone):**
- Build unsigned Android artifacts (`apk`/`aab`) and iOS archive/artifact path that is valid for internal release packaging.
- Publish with explicit naming (`unsigned`) to avoid distribution ambiguity.

**If signing secrets become available later:**
- Keep same pipeline shape.
- Enable signing via conditional steps and protected environments.

## Version Compatibility

| Package A | Compatible With | Notes |
|-----------|-----------------|-------|
| Flutter stable channel | Xcode on `macos-14` | Pin Flutter channel/version to reduce breakage |
| `actions/setup-java@v4` | Android Gradle plugin from repo | Prefer Java 17 for modern Android toolchains |
| `upload-artifact@v4` | `download-artifact@v4` | Keep matching major versions for reliability |

## Sources

- GitHub Actions workflow syntax: https://docs.github.com/actions/using-workflows/workflow-syntax-for-github-actions
- GitHub Releases REST API: https://docs.github.com/rest/releases
- Flutter deployment docs: https://docs.flutter.dev/deployment
- Flutter iOS deployment/signing notes: https://docs.flutter.dev/deployment/ios

---
*Stack research for: Flutter CI/CD release automation*
*Researched: 2026-04-14*
