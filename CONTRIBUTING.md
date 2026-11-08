# Contributing

## Setup

Enter the dev shell and install the hooks (see the [README](README.md)):

```sh
nix develop
just setup
```

## Issues

Open an issue with one of the forms in `.github/ISSUE_TEMPLATE/`. Each form
sets a `type:*` label; add one `area:*` label too. The labels are defined in
`tools.toml`:

- Types: `type:feat`, `type:fix`, `type:docs`, `type:chore`, `type:refactor`,
  `type:test`, `type:ci`
- Areas: `area:app`, `area:reader`, `area:library`, `area:auth`, `area:sync`,
  `area:ci`, `area:docs`

The `epic` form applies `type:feat`, since there is no epic label.

The pre-push hook runs `issues-check`, which validates the label and cycle rules.

## Branches and commits

- Branch from `main`, named `<type>/<issue>` (for example `docs/42`).
- Use [Conventional Commits](https://www.conventionalcommits.org):
  `type(scope): subject`, with the same types as the `type:*` labels.
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
