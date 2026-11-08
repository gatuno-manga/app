# Common development tasks. Run `just` to list them.
# Enter the dev shell first: `nix develop` (or use direnv).

default:
    @just --list

# Install git hooks and fetch dependencies
setup:
    lefthook install
    flutter pub get

# Run code generation (drift, freezed, etc.)
gen:
    dart run build_runner build --delete-conflicting-outputs

# Generate localization files
l10n:
    flutter gen-l10n

# Static analysis, including the gatuno_lints plugin rules.
# `dart analyze` is used instead of `flutter analyze` because the latter exits
# before analyzer plugins report, so plugin diagnostics would be dropped.
analyze:
    dart analyze

# Run unit and widget tests
test:
    flutter test

# Run tests with coverage (lcov at coverage/lcov.info)
coverage:
    flutter test --coverage

# Format Dart files (defaults to the whole project)
fmt *files='.':
    dart format {{ files }}

# Unit tests of the gatuno_lints analyzer plugin (tool/gatuno_lints)
test-lints:
    cd tool/gatuno_lints && dart pub get && dart test

# Check design token consistency (DESIGN.md, .impeccable/design.json, theme)
design-tokens:
    python3 tool/check_design_tokens.py

# Full local gate: analysis, tests, lint-rule tests and design tokens
check: analyze test test-lints design-tokens

# Apply automated Dart fixes (defaults to the whole project)
# `dart fix` accepts a single path, so run it once per argument.
fix *files='.':
    #!/usr/bin/env bash
    set -euo pipefail
    for f in {{ files }}; do
        dart fix --apply "$f"
    done

# Verify repo settings, labels and milestones against tools.toml (needs a token that can read merge settings)
repo-check:
    repo-sync --check
