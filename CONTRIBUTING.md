# Contributing

## Setup

Enter the dev shell and install the hooks (see the [README](README.md)):

```sh
nix develop
just setup
```

### Flutter version in CI

The Flutter version comes from `flake.lock` (nixpkgs). `ci.yml` and
`lints.yml` run through `nix develop .#ci`, a lean shell in `flake.nix` with
Flutter only, so CI and your local shell use the same version.
`release.yml` builds for Android and iOS without Nix (the flake shell is
unverified on macOS), so it pins `flutter-version` literally. When a flake bump
changes Flutter (check `flutter --version` in `nix develop`), update the pin in
`release.yml` too.

## Claude Code setup

The repo ships `.claude/settings.json` for [Claude Code](https://claude.com/claude-code).
It is read after you trust the folder, and it sets:

- **Allowed without a prompt**: the `just` recipes (without arguments),
  `dart format|analyze|fix`, `flutter pub get`, `flutter test`, a fixed set of
  `git diff|log|show|branch` forms, `git status`, `git fetch [origin]` and
  read-only `gh` (`issue view|list`, `pr view|list|checks`). Push, merge,
  `gh pr create`, `gh issue edit`, `gh api` and other git or `just` forms still
  ask. Test and analyze run Dart code, so approving an edit to a test file is
  approving code that runs.
- **Denied**: reading or editing secrets (`.env` files, keystores,
  `key.properties`, `*.p12`, `*.p8`, `*.mobileprovision`, `*.cer`, `*.pem`,
  `*.key`, `google-services.json`, `GoogleService-Info.plist`). This is not a
  sandbox: it covers the file tools and the shell readers Claude Code
  recognises (`cat`, `head`, ...), not `grep -r` or scripts.
- **Figma plugin**: `figma@claude-plugins-official` is enabled for the project
  (it bundles the Figma MCP server and skills such as `figma-use`). Enabling
  does not install it: run this once per clone, then restart Claude Code or run
  `/reload-plugins`, and sign in to Figma when asked:

  ```sh
  claude plugin install figma@claude-plugins-official --scope project
  ```

  The project setting overrides a user-level `false`. To opt out on your
  machine, set the plugin to `false` in `.claude/settings.local.json`.

Keep personal overrides in `.claude/settings.local.json`; it is gitignored.
Never commit tokens or personal paths.

## Issues

Open an issue with one of the forms in `.github/ISSUE_TEMPLATE/`. Each form
sets a `type:*` label; add one `area:*` label too. The labels are defined in
`tools.toml`:

- Types: `type:feat`, `type:fix`, `type:docs`, `type:chore`, `type:refactor`,
  `type:test`, `type:ci`, `type:design`
- Areas: `area:app`, `area:reader`, `area:library`, `area:auth`, `area:sync`,
  `area:ci`, `area:docs`

The `epic` form applies `type:feat`, since there is no epic label.

### Design issues

`type:design` is for work whose deliverable lives in the Gatuno Figma file:
frames, components, variable bindings, breakpoints. File it with the `design`
form.

- Use the area of the feature being designed, or `area:app` for cross-cutting
  work (navigation shell, shared components, token bindings). Never
  `area:docs`, even when `DESIGN.md` also changes.
- An issue that changes both Figma and code keeps its code type (`type:fix`,
  `type:refactor`, ...).
- `type:design` has no branch or commit type. If the issue also updates
  `DESIGN.md` or `.impeccable/`, that change goes on a `docs/<issue>` branch
  with `docs(scope): ...` commits.
- Close it with a comment that links the finished frames (Figma node-id URLs)
  and ticks the acceptance criteria. A Figma-only issue has no pull request, so
  close it by hand; when a `docs` pull request closes it, post the comment
  before merging.

The pre-push hook runs `issues-check`, which validates the label and cycle rules.

## Branches and commits

- Branch from `main`, named `<type>/<issue>` (for example `docs/42`).
- Use [Conventional Commits](https://www.conventionalcommits.org):
  `type(scope): subject`, with the same types as the `type:*` labels except
  `design`, which is a label only (see [Design issues](#design-issues)).
- Reference the issue in the pull request body with `Closes #N`. A parent
  issue is only `Refs`.

## Checks

Run `just check` before pushing. It runs `dart analyze` (which, unlike
`flutter analyze`, reports the `gatuno_lints` plugin diagnostics), the tests, the
lint-rule tests and the design token check.

If you add or change user-facing strings, run `just l10n`. If you change
generated code inputs, run `just gen`.

## Pull requests

- Title in conventional format, for example `docs: improve project documentation`.
- Fill in the pull request template.
- Merge commits only: squash and rebase merges are disabled, and branches are
  deleted after merge (see `tools.toml`).
