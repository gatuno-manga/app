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

# Static analysis
analyze:
    flutter analyze

# Run unit and widget tests
test:
    flutter test

# Run tests with coverage (lcov at coverage/lcov.info)
coverage:
    flutter test --coverage

# Format Dart files (defaults to the whole project)
fmt *files='.':
    dart format {{ files }}

# Apply automated Dart fixes (defaults to the whole project)
fix *files='.':
    dart fix --apply {{ files }}

# Verify repo settings, labels and milestones against tools.toml (needs a token that can read merge settings)
repo-check:
    repo-sync --check
