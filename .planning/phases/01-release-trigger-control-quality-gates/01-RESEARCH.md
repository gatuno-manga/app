# Phase 1: Release Trigger Control & Quality Gates - Research

**Researched:** 2026-04-14  
**Domain:** GitHub Actions release trigger governance + Flutter quality gates  
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
### Regra de tags semanticas
- **D-01:** O workflow de release aceita apenas tags estaveis no formato `vMAJOR.MINOR.PATCH`.
- **D-02:** Tags invalidas devem falhar imediatamente com mensagem clara, antes de qualquer job de build.

### Politica de concorrencia
- **D-03:** Para a mesma versao, a execucao mais antiga deve ser cancelada e a mais nova deve continuar.
- **D-04:** A chave de concorrencia deve ser `workflow + tag` para evitar colisao com outros workflows.

### Quality gate
- **D-05:** O gate obrigatorio da Fase 1 e `flutter analyze` + `flutter test` (suite completa).
- **D-06:** Os gates rodam em job dedicado de validacao antes de qualquer build.
- **D-07:** Falha no gate encerra o release imediatamente; rerun somente manual apos correcao.

### Permissoes e seguranca
- **D-08:** O workflow deve usar permissoes minimas por job, com `contents: write` apenas onde houver necessidade real de publicacao.
- **D-09:** O release so deve aceitar tags que apontem para commits alcancaveis pela `main`.
- **D-10:** O projeto deve registrar a exigencia de proteger o padrao de tags `v*` no repositorio.

### the agent's Discretion
- Implementacao exata do regex de validacao da tag.
- Formato detalhado das mensagens de erro do gate de validacao.
- Nome dos jobs e organizacao final do YAML dentro das decisoes acima.

### Deferred Ideas (OUT OF SCOPE)
None — discussion stayed within phase scope.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| TRIG-01 | Trigger only from semantic tags `vX.Y.Z` | Use `on.push.tags` filter + explicit regex validation job because trigger filters are glob-based, not regex-based [CITED: https://raw.githubusercontent.com/github/docs/main/data/reusables/actions/workflows/run-on-specific-branches-or-tags1.md] |
| TRIG-02 | Block invalid tag before build | Dedicated `validate_tag` job first; downstream jobs use `needs` so build path is skipped on failure [CITED: https://raw.githubusercontent.com/github/docs/main/data/reusables/actions/jobs/section-using-jobs-in-a-workflow-needs.md] |
| TRIG-03 | Single active run per version tag | Workflow-level `concurrency.group: ${{ github.workflow }}-${{ github.ref }}` + `cancel-in-progress: true` [CITED: https://raw.githubusercontent.com/github/docs/main/data/reusables/actions/actions-group-concurrency.md] |
| TRIG-04 | Mandatory `flutter analyze` + `flutter test` before release artifacts | Reuse existing repo gate pattern from `.github/workflows/test.yml` in dedicated release validation job [VERIFIED: /home/luis/Documents/hand-on/gatuno/app/.github/workflows/test.yml] |
</phase_requirements>

## Project Constraints (from copilot-instructions.md)

- Use GSD workflow entrypoints; avoid direct repo edits outside flow unless explicitly requested [VERIFIED: /home/luis/Documents/hand-on/gatuno/app/copilot-instructions.md]  
- Keep CI style simple/declarative in YAML and aligned with existing Flutter CI commands [VERIFIED: /home/luis/Documents/hand-on/gatuno/app/.github/workflows/test.yml]  
- Maintain minimum-required permissions for automation tokens [VERIFIED: /home/luis/Documents/hand-on/gatuno/app/.planning/phases/01-release-trigger-control-quality-gates/01-CONTEXT.md][CITED: https://raw.githubusercontent.com/github/docs/main/data/reusables/actions/jobs/section-assigning-permissions-to-jobs.md]

## Summary

Phase 1 should be implemented as a **new release workflow** triggered by tag pushes, with an immediate validation job that enforces strict stable semver (`vMAJOR.MINOR.PATCH`) and blocks all downstream work if invalid [VERIFIED: /home/luis/Documents/hand-on/gatuno/app/.planning/phases/01-release-trigger-control-quality-gates/01-CONTEXT.md][CITED: https://raw.githubusercontent.com/github/docs/main/data/reusables/actions/workflows/run-on-specific-branches-or-tags1.md].  

GitHub Actions' tag filters are glob-based, so they cannot alone guarantee full semver correctness; regex validation in a shell step is required for D-01/D-02 [CITED: https://raw.githubusercontent.com/github/docs/main/data/reusables/actions/workflows/run-on-specific-branches-or-tags1.md].  

Concurrency and quality gates should be enforced at workflow/job graph level using `concurrency` and `needs`, reusing existing Flutter setup (`subosito/flutter-action`, `flutter analyze`, `flutter test`) already used in this repository CI [VERIFIED: /home/luis/Documents/hand-on/gatuno/app/.github/workflows/test.yml][CITED: https://raw.githubusercontent.com/github/docs/main/data/reusables/actions/actions-group-concurrency.md].

**Primary recommendation:** Create `.github/workflows/release.yml` with `on.push.tags: ['v*']`, `concurrency` keyed by workflow+ref, and a mandatory `validate_and_gate` job (`tag regex + main reachability + analyze + test`) that every future build job must `needs:` depend on [HIGH].

## Standard Stack

### Core

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| GitHub Actions workflow syntax | N/A (platform feature) | Trigger/filter/concurrency/permissions/job graph | Native control plane for this phase [CITED: https://docs.github.com/en/actions/writing-workflows/workflow-syntax-for-github-actions] |
| `actions/checkout` | v6.0.2 (2026-01-09) | Checkout and full git history when needed | Required for ancestry checks and tag/main verification [VERIFIED: GitHub API releases/actions/checkout] |
| `subosito/flutter-action` | v2.23.0 (2026-03-25) | Deterministic Flutter setup on runner | Already used in repo and purpose-built for Flutter CI [VERIFIED: GitHub API releases/subosito/flutter-action][VERIFIED: /home/luis/Documents/hand-on/gatuno/app/.github/workflows/test.yml] |

### Supporting

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| Git CLI on runner | 2.x+ | Ancestor/reachability checks (`merge-base --is-ancestor`) | Enforce D-09 in validation job [CITED: https://raw.githubusercontent.com/git/git/master/Documentation/git-merge-base.adoc] |
| Flutter CLI | 3.x | `flutter analyze` + `flutter test` quality gate | Required by TRIG-04 [VERIFIED: /home/luis/Documents/hand-on/gatuno/app/.github/workflows/test.yml] |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `on.push.tags: ['v*']` + regex check | Narrow glob like `v*.*.*` only | Still not strict semver; invalid forms can slip through glob semantics [CITED: https://raw.githubusercontent.com/github/docs/main/data/reusables/actions/workflows/run-on-specific-branches-or-tags1.md] |
| Workflow-level concurrency | Job-level concurrency only | Job-level can miss cross-job run cancellation intent for full release run [CITED: https://raw.githubusercontent.com/github/docs/main/data/reusables/actions/jobs/section-using-concurrency.md] |

**Installation:**  
No new app package installation is required for Phase 1 [VERIFIED: phase scope TRIG-01..04 in REQUIREMENTS].

## Architecture Patterns

### Recommended Project Structure

```text
.github/
└── workflows/
    ├── test.yml                 # existing baseline CI
    └── release.yml              # new phase-1 workflow
```

### Pattern 1: Validate-first release graph
**What:** First job validates tag format, tag type, tag commit reachability from `main`, and executes quality gates.  
**When to use:** Always for release workflows that must fail before build on invalid trigger.  
**Example:**
```yaml
on:
  push:
    tags:
      - 'v*'

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  validate_and_gate:
    runs-on: ubuntu-latest
    permissions:
      contents: read
    steps:
      - uses: actions/checkout@v6
        with:
          fetch-depth: 0
      - name: Validate tag format
        run: |
          TAG="${GITHUB_REF_NAME}"
          [[ "$GITHUB_REF_TYPE" == "tag" ]] || { echo "Not a tag"; exit 1; }
          [[ "$TAG" =~ ^v(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$ ]] || { echo "Invalid tag: $TAG"; exit 1; }
      - name: Ensure tag commit is reachable from main
        run: |
          git fetch origin main --depth=1
          git merge-base --is-ancestor "$GITHUB_SHA" "origin/main"
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
```
Source: GitHub workflow syntax, contexts, concurrency, and git docs [CITED: https://docs.github.com/en/actions/writing-workflows/workflow-syntax-for-github-actions][CITED: https://docs.github.com/en/actions/learn-github-actions/contexts][CITED: https://raw.githubusercontent.com/git/git/master/Documentation/git-merge-base.adoc]

### Anti-Patterns to Avoid
- **Only glob-filtering tags without regex validation:** glob is not strict semver validation [CITED: https://raw.githubusercontent.com/github/docs/main/data/reusables/actions/workflows/run-on-specific-branches-or-tags1.md].  
- **Allowing build jobs without `needs: validate_and_gate`:** breaks TRIG-02/TRIG-04 guarantees [CITED: https://raw.githubusercontent.com/github/docs/main/data/reusables/actions/jobs/section-using-jobs-in-a-workflow-needs.md].  
- **Global `contents: write` everywhere:** violates least-privilege decision D-08 [CITED: https://raw.githubusercontent.com/github/docs/main/data/reusables/actions/jobs/section-assigning-permissions-to-jobs.md].

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Concurrency locking | Custom lock files/artifacts | Native `concurrency` key | Built-in cancellation semantics and group scoping [CITED: https://raw.githubusercontent.com/github/docs/main/data/reusables/actions/actions-group-concurrency.md] |
| GitHub token scoping logic | Ad-hoc env/token hacks | `permissions` at workflow/job level | Official least-privilege mechanism [CITED: https://raw.githubusercontent.com/github/docs/main/data/reusables/actions/jobs/section-assigning-permissions-to-jobs.md] |
| Trigger dependency ordering | Script-chaining all logic in one step | `jobs.<job_id>.needs` DAG | Clear fail/skip propagation and maintainability [CITED: https://raw.githubusercontent.com/github/docs/main/data/reusables/actions/jobs/section-using-jobs-in-a-workflow-needs.md] |

**Key insight:** GitHub Actions already provides first-class primitives for trigger filters, dependency graphing, and run cancellation; custom implementations increase fragility without adding value [HIGH].

## Common Pitfalls

### Pitfall 1: Assuming tag filter equals semver validator
**What goes wrong:** Invalid semver-like tags still trigger workflow.  
**Why it happens:** `tags` uses glob patterns, not regex semantics.  
**How to avoid:** Trigger broad (`v*`) + explicit regex step.  
**Warning signs:** Tags like `v1`, `v01.2.3`, `v1.2.3.4` not rejected where expected.  
[CITED: https://raw.githubusercontent.com/github/docs/main/data/reusables/actions/workflows/run-on-specific-branches-or-tags1.md]

### Pitfall 2: Concurrency group collisions across workflows
**What goes wrong:** Unrelated workflows cancel each other.  
**Why it happens:** Reused generic group names.  
**How to avoid:** Prefix with `github.workflow`.  
**Warning signs:** Release runs canceled by non-release workflows.  
[CITED: https://raw.githubusercontent.com/github/docs/main/data/reusables/actions/actions-group-concurrency.md]

### Pitfall 3: Tag not on main passes release
**What goes wrong:** Release created from detached/non-main history.  
**Why it happens:** No ancestry validation.  
**How to avoid:** `git merge-base --is-ancestor "$GITHUB_SHA" origin/main`.  
**Warning signs:** Release tag points to commit unavailable from `main`.  
[CITED: https://raw.githubusercontent.com/git/git/master/Documentation/git-merge-base.adoc]

## Code Examples

### Strict semver tag check (`vMAJOR.MINOR.PATCH` only)
```bash
TAG="${GITHUB_REF_NAME}"
if [[ ! "$TAG" =~ ^v(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$ ]]; then
  echo "Invalid release tag '$TAG'. Expected vMAJOR.MINOR.PATCH (stable only)."
  exit 1
fi
```
Source: SemVer stable numeric component constraints [CITED: https://semver.org/]

### Dependency gate wiring
```yaml
jobs:
  validate_and_gate: ...
  build_android:
    needs: validate_and_gate
  build_ios:
    needs: validate_and_gate
```
Source: `jobs.<job_id>.needs` behavior [CITED: https://raw.githubusercontent.com/github/docs/main/data/reusables/actions/jobs/section-using-jobs-in-a-workflow-needs.md]

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Tag protection rules only | Rulesets for branches/tags governance | GitHub rulesets era (documented current) | Better layered governance and visibility [CITED: https://raw.githubusercontent.com/github/docs/main/content/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets.md] |
| Unbounded parallel runs | `concurrency` with cancellation | GitHub Actions workflow syntax current | Prevents duplicate runs per tag [CITED: https://raw.githubusercontent.com/github/docs/main/data/reusables/actions/actions-group-concurrency.md] |

**Deprecated/outdated:**
- Relying only on naming convention without enforced validation in CI gate [ASSUMED].

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | Using `on.push.tags: ['v*']` is preferable to stricter glob because D-02 requires explicit invalid-tag failure messaging | Architecture Patterns | Medium (workflow could miss some invalid tags if trigger too narrow) |
| A2 | Repository owners can practically enforce `v*` protection via rulesets in their GitHub plan/tier | Open Questions / Security | Medium (org plan limitations may require alternative governance) |

## Open Questions

1. **Should invalid tags fail as a visible failed run, or be ignored at trigger level?**  
   - What we know: D-02 asks immediate failure with clear message [VERIFIED: CONTEXT].  
   - What's unclear: team preference if non-`v*` tags should even trigger release workflow.  
   - Recommendation: keep trigger at `v*`, fail non-semver in first step for observability.

2. **How strict should “reachable by main” be for hotfix workflows?**  
   - What we know: D-09 requires reachability from `main` [VERIFIED: CONTEXT].  
   - What's unclear: whether release branches will exist later.  
   - Recommendation: implement strict main ancestry now; revisit in phase update if release-branch policy appears.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| git | Tag ancestry checks | ✓ | 2.53.0 | — |
| flutter | Local reproduction of quality gate | ✓ | 3.41.6 | CI-only validation if local unavailable |
| dart | Flutter tooling runtime | ✓ | 3.11.4 | via Flutter bundled SDK |
| actionlint | Workflow lint in local dev | ✗ | — | Use GitHub Actions run feedback + YAML review |

**Missing dependencies with no fallback:**
- None for phase implementation itself (YAML + GitHub-hosted execution path).

**Missing dependencies with fallback:**
- `actionlint` missing locally; fallback is CI run validation.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Flutter test (`flutter_test`) [VERIFIED: pubspec.yaml] |
| Config file | none explicit (Flutter defaults) [VERIFIED: repo files] |
| Quick run command | `flutter analyze && flutter test` |
| Full suite command | `flutter test` (full existing suite) |

### Phase Requirements -> Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| TRIG-01 | Release workflow triggers on tag pushes and validates semver format | workflow integration | Manual push of valid/invalid tags in test repo [ASSUMED] | ❌ Wave 0 |
| TRIG-02 | Invalid tags fail before build | workflow integration | Same run inspection (`validate_and_gate` fails, no build jobs) [ASSUMED] | ❌ Wave 0 |
| TRIG-03 | Single active run per tag | workflow integration | Push same tag sequence; verify older run canceled [ASSUMED] | ❌ Wave 0 |
| TRIG-04 | `flutter analyze` + `flutter test` mandatory before build | CI gate | `flutter analyze && flutter test` | ✅ (commands and CI pattern exist) |

### Sampling Rate
- **Per task commit:** `flutter analyze && flutter test`
- **Per wave merge:** Trigger workflow in dry-run tag scenario (non-production test tag strategy) [ASSUMED]
- **Phase gate:** Demonstrate required outcomes for TRIG-01..04 in GitHub Actions run history.

### Wave 0 Gaps
- [ ] Add workflow-level validation checklist doc/script for TRIG-01/02/03 evidence capture.
- [ ] Optional install: `actionlint` for local static linting (`go install github.com/rhysd/actionlint/cmd/actionlint@latest`) [ASSUMED].

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | no | N/A (no app auth logic changed) |
| V3 Session Management | no | N/A |
| V4 Access Control | yes | Workflow `permissions` least-privilege and controlled write scope [CITED: https://raw.githubusercontent.com/github/docs/main/data/reusables/actions/jobs/section-assigning-permissions-to-jobs.md] |
| V5 Input Validation | yes | Tag regex validation before execution path continuation |
| V6 Cryptography | no (Phase 1) | Checksums/signing deferred to later phases [VERIFIED: REQUIREMENTS.md] |

### Known Threat Patterns for GitHub Actions release workflows

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Unauthorized release publication via broad token scope | Elevation of Privilege | Restrict `GITHUB_TOKEN` permissions; only grant `contents: write` where needed [CITED: https://raw.githubusercontent.com/github/docs/main/data/reusables/actions/jobs/section-assigning-permissions-to-jobs.md] |
| Accidental duplicate/conflicting release runs | Tampering/DoS | Workflow `concurrency` with cancel-in-progress [CITED: https://raw.githubusercontent.com/github/docs/main/data/reusables/actions/actions-group-concurrency.md] |
| Non-main commit released via tag | Tampering | Ancestry check against `origin/main` using git ancestor test [CITED: https://raw.githubusercontent.com/git/git/master/Documentation/git-merge-base.adoc] |

## Sources

### Primary (HIGH confidence)
- Repo context and constraints files (CONTEXT, REQUIREMENTS, ROADMAP, STATE, PROJECT, config, existing CI) [VERIFIED: local files].
- GitHub Docs reusables for:
  - push tags filters
  - concurrency
  - needs
  - permissions
  - contexts (`ref`, `ref_name`, `ref_type`)
  [CITED: raw.githubusercontent.com/github/docs/...]
- Git official docs: `git merge-base --is-ancestor` behavior [CITED: https://raw.githubusercontent.com/git/git/master/Documentation/git-merge-base.adoc]
- SemVer official regex guidance [CITED: https://semver.org/]
- GitHub API releases for action versions:
  - `actions/checkout` latest `v6.0.2` published `2026-01-09`
  - `subosito/flutter-action` latest `v2.23.0` published `2026-03-25`
  [VERIFIED: api.github.com/repos/.../releases/latest]

### Secondary (MEDIUM confidence)
- None.

### Tertiary (LOW confidence)
- Any operational assumptions marked `[ASSUMED]` above.

## Metadata

**Confidence breakdown:**
- Standard stack: **HIGH** — verified in repo + official docs + current action release APIs.
- Architecture: **HIGH** — directly mapped to locked decisions and official workflow semantics.
- Pitfalls: **HIGH** — derived from documented GitHub Actions behavior and repo baseline.

**Research date:** 2026-04-14  
**Valid until:** 2026-05-14 (30 days)

---

### Concise summary
- Locked decisions are implementable with native GitHub Actions features (`on.push.tags`, `concurrency`, `needs`, `permissions`) plus one explicit regex validation step.  
- Existing `test.yml` already provides the exact quality gate commands required by TRIG-04.  
- Main technical risk is relying on tag glob matching as strict semver validation; this must be corrected with explicit gate logic.
