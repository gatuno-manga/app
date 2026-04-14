# Release Validation Checklist (Phase 1)

Use this checklist to collect objective evidence for Phase 1 requirements: **TRIG-01**, **TRIG-02**, **TRIG-03**, **TRIG-04**.

## Preconditions

1. `.github/workflows/release.yml` is present on `main`.
2. You can push tags to the repository.
3. GitHub Actions is enabled for the repository.

## TRIG-01 — Valid semantic tag triggers release workflow

1. Create and push a valid tag:
   ```bash
   git checkout main
   git pull --ff-only
   git tag v1.2.3
   git push origin v1.2.3
   ```
2. Open **Actions → Release** run for `refs/tags/v1.2.3`.

**Expected evidence**
- Workflow is triggered by tag push.
- `validate_and_gate` job starts and completes successfully.
- `ready_for_builds` runs only after `validate_and_gate`.

## TRIG-02 — Invalid tag fails before any release path

1. Push an invalid tag:
   ```bash
   git tag v1.2
   git push origin v1.2
   ```
2. Open the corresponding run in **Actions → Release**.

**Expected evidence**
- `Validate release tag format` fails with `Invalid release tag`.
- No downstream release/build path runs after validation failure.
- `ready_for_builds` is skipped because it depends on `needs: validate_and_gate`.

## TRIG-03 — Only one active run per tag

1. Push the first run for a valid tag on commit A:
   ```bash
   git tag v1.2.4 <commit-A>
   git push origin v1.2.4
   ```
2. Move the same tag to commit B and push again:
   ```bash
   git tag -f v1.2.4 <commit-B>
   git push origin -f v1.2.4
   ```
3. Check **Actions → Release** run list.

**Expected evidence**
- Older run for `v1.2.4` is canceled.
- Newer run continues.
- Run details show the same concurrency key (`${{ github.workflow }}-${{ github.ref }}`).

## TRIG-04 — Quality gate blocks continuation on analysis/test failure

1. Push a valid tag for a commit that intentionally fails `flutter analyze` or `flutter test`.
2. Open the run logs for `validate_and_gate`.

**Expected evidence**
- `flutter analyze` and/or `flutter test` fails in `validate_and_gate`.
- No downstream release/build path runs after the gate failure.

## Tag protection

Configure a repository ruleset to protect `v*` tags:

1. Open **Settings → Rules → Rulesets → New ruleset → Tag**.
2. Target pattern: `v*`.
3. Restrict create/update/delete of matching tags to trusted maintainers/release automation.

**Expected evidence**
- Unauthorized users cannot create or force-update `v*` tags.
- Tag governance for release triggers is enforced before workflow execution.
