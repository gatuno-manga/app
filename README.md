# Gatuno

Flutter client (Android and iOS) for Gatuno Manga, a self-hosted reader for
manga and books. The app browses the library, tracks reading progress and
reads chapters, with progress synced across devices. On first launch you
supply your own server URL; nothing is tied to a hosted service. See
[PRODUCT.md](PRODUCT.md) for the product context.

## Getting started

The project ships a [Nix](https://nixos.org) flake that provides Flutter, JDK 17,
the Android SDK, `just`, `lefthook`, Python 3 and the `jaoppb/tools` binaries.

```sh
nix develop            # enter the dev shell
just setup             # install git hooks and run flutter pub get
```

With [direnv](https://direnv.net), run `direnv allow` once and the shell loads
automatically (see `.envrc`).

The flake supports x86_64/aarch64 Linux and macOS, but only x86_64-linux is
tested. iOS builds are not provided by Nix.

## Development workflow

Run `just` to list every task. Common ones:

| Task | What it does |
| --- | --- |
| `just gen` | Run code generation (`build_runner`) |
| `just l10n` | Generate localization files |
| `just fmt` | Format Dart files |
| `just fix` | Apply automated Dart fixes |
| `just analyze` | Static analysis (`flutter analyze`) |
| `just test` | Unit and widget tests |
| `just coverage` | Tests with coverage (`coverage/lcov.info`) |
| `just design-tokens` | Check design token consistency |
| `just check` | Analyze, tests and design tokens |
| `just repo-check` | Verify repo settings, labels and milestones against `tools.toml` |

### Git hooks

[lefthook](https://github.com/evilmartians/lefthook) calls `just` and Flutter,
so commit from inside the dev shell.

- `pre-commit`: formats and fixes staged `lib/` and `test/` Dart files, then
  runs `just analyze`.
- `pre-push`: runs `issues-check`, which validates the label and cycle rules configured
  in `tools.toml`.

### CI

The CI workflow runs the shared Flutter pipeline (`just check` is a local gate,
not a CI mirror: the design token check does not run in CI). The Tools workflow's
repo-sync step only checks labels and milestones: the default CI token cannot read repository
merge settings. Verify those locally with `just repo-check` (needs a token that
can read them).

## Project structure

```text
lib/
  main.dart, router.dart   App entry point and routing
  core/                    Cross-cutting infrastructure: config, DI, network,
                           theme, logging, image handling, base classes
  features/                One folder per feature (authentication, books,
                           reading, sync, settings, ...)
  shared/                  Reusable components, data, domain, validators and icons
  l10n/                    ARB files and generated localizations (en, pt)
test/                      Unit and widget tests
specs/                     Feature specifications
docs/                      Reports and checklists
tool/                      Repository scripts
```

Design and product context live in [DESIGN.md](DESIGN.md) and
[PRODUCT.md](PRODUCT.md); the Impeccable design context is under
`.impeccable/`.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for branches, commits, labels and the
pull request flow.
