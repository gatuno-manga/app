# AGENTS.md

Instructions for coding agents working on this repository. Humans should read
[README.md](README.md) and [CONTRIBUTING.md](CONTRIBUTING.md) first; this file
adds the conventions an agent needs to change code safely.

Gatuno is the Flutter client (Android and iOS) for Gatuno Manga, a self-hosted
reader for manga and books. Product context: [PRODUCT.md](PRODUCT.md). Design
system: [DESIGN.md](DESIGN.md). Dependencies and versions: `pubspec.yaml`.

## Environment and commands

Work inside the Nix dev shell (`nix develop`, or direnv via `.envrc`). It
provides Flutter, JDK 17, the Android SDK, `just`, `lefthook` and Python 3.
Run `just` to list every task. The ones you need most:

| Command | Use it when |
| --- | --- |
| `just setup` | First checkout: installs git hooks and runs `flutter pub get` |
| `just gen` | You changed a `@JsonSerializable` model or the drift database |
| `just l10n` | You added or changed strings in `lib/l10n/*.arb` |
| `just fmt` / `just fix` | Formatting and automated fixes (the pre-commit hook runs both on staged files) |
| `just analyze` | Static analysis |
| `just test` | Unit and widget tests |
| `just design-tokens` | You touched `DESIGN.md`, `PRODUCT.md`, anything under `.impeccable/`, or `lib/core/theme/` |
| `just check` | Before pushing: analyze, tests and design tokens |

Git hooks (`lefthook.yml`): pre-commit runs `just fmt` and `just fix` on staged
`lib/` and `test/` Dart files, then `just analyze`; pre-push runs
`issues-check`.

## Workflow

Follow [CONTRIBUTING.md](CONTRIBUTING.md):

1. Work from a GitHub issue.
2. Branch from `main` as `<type>/<issue>` (for example `docs/42`).
3. Commit with Conventional Commits: `type(scope): subject`, using the
   `type:*` label names (`feat`, `fix`, `docs`, `chore`, `refactor`, `test`,
   `ci`).
4. Run `just check`.
5. Open a pull request with a conventional title and `Closes #N` in the body.
   Merges are merge commits only.

## Project layout

```text
lib/
  main.dart, router.dart   Entry point and root GoRouter
  core/                    Config, DI, network, exceptions, logging, theme,
                           router keys, image loading, base classes, utils
  features/<feature>/      One folder per feature (see below)
  shared/                  Cross-feature components, presentation (ErrorScreen,
                           NavigationViewModel), domain, data, validators,
                           icons, utils
  l10n/                    ARB files and generated AppLocalizations (en, pt)
test/                      Mirrors lib/ (test/core, test/features, test/shared);
                           helpers in test/helpers/
specs/                     Feature specifications
docs/                      Reports and checklists
tool/                      Repository scripts (design token check)
```

A feature folder:

```text
lib/features/<feature>/
  <feature>_injection.dart  Registers the feature in GetIt (usually)
  <feature>_router.dart     GoRoute(s) / StatefulShellBranch (when it has routes)
  domain/                   entities/, value_objects/, repositories/ (abstract),
                            use_cases/ (services)
  data/                     models/, repositories/ (implementations),
                            data_sources/, database/ (drift)
  presentation/             views/, view_models/, components/
  exceptions/               Feature-specific exceptions (when needed)
```

Not every feature has every file or folder: `home` and `welcome` have no
domain, `welcome` has no injection file, `users`, `sync` and `app_lock` have no router, `settings` is
registered inline in `initDI()`, and `authentication` pairs
`authentication_injection.dart` with `auth_router.dart`.

## Architecture rules

- **Layers.** `domain` is the contract: abstract repositories, entities, value
  objects and use cases. `data` implements it. `presentation` depends on
  `domain`, not on `data`. Many existing files break this (use cases in
  several features import `data/` sources, some view models import
  `UserModel`); do not add more. New code depends on an abstract interface in
  `domain/repositories/` instead.
- **Dependency injection.** GetIt, via the global `sl` in
  `lib/core/di/injection.dart`. `initDI()` registers core services, then the
  features (mostly through `init<Feature>Injection(sl)`; reading and sync use
  `initReadingDI` / `initSyncDI`), then the Dio interceptors. Order matters;
  read the comments in `initDI()` before moving anything. Services and
  repositories are lazy singletons. Prefer registering view models as
  factories (`registerFactory` / `registerFactoryParam`); some features still
  construct them directly in the router or screen.
- **View models.** Extend `BaseStreamViewModel<State>`
  (`lib/core/base/base_stream_view_model.dart`). State is an immutable
  `Equatable` class with `copyWith` and an `initial()` factory; the view model
  calls `emit()` and the UI reads `stateStream` (usually with `StreamBuilder`)
  or `state`. A view model is not a `ChangeNotifier`, so nothing closes it
  for you: whoever creates it calls `dispose()` (see Routing). A view model
  that subscribes to streams cancels them in its own `dispose()` override and
  calls `super.dispose()`; widgets cancel their own subscriptions in their
  `State.dispose`. `SafeChangeNotifier` in the same folder is
  no longer used by any view model; do not build new ones on it.
- **Routing.** go_router. `lib/router.dart` builds the root router with a
  `StatefulShellRoute` for the bottom navigation; each feature exposes its
  routes or branch from `<feature>_router.dart`. For new routes, provide the
  view model from the route builder with
  `Provider<VM>(create: (_) => sl<VM>(), dispose: (_, vm) => vm.dispose(), child: ...)`
  and read it in the screen with `context.read`. Existing routes omit
  `dispose:`; do not copy that. There is no global redirect, so guests can
  browse. Protect a route with its own `redirect:` that returns
  `'/auth/signin'` when `!sl<AuthService>().authenticated` (see
  `settings_router.dart`).
- **Network.** All HTTP goes through `DioClient` (`lib/core/network/`).
  Endpoints are `static const` strings in `api_constants.dart` (a few
  repositories still hardcode paths; do not add more). Interceptors
  (auth with token refresh, cache, cookies, logging, bad certificate) live in
  `lib/core/network/interceptors/`. The server URL is set at runtime by the
  user (welcome screen, then `SettingsService`), never at compile time;
  `AppConfig` only holds `--dart-define` values such as `REFERER`. Network
  images use the `AppImage` atom with `sl<ImageLoadingStrategy>()` so they
  also go through `DioClient`; `user_banner.dart` still uses `Image.network`,
  do not copy it.
- **Models.** New models that read or write JSON use `json_serializable`
  (`@JsonSerializable`, generated `*.g.dart` via `just gen`); `UserModel` and
  the MFA models are older hand-written exceptions. Value objects expose
  `fromJson` / `toJson` so generated code can use them. Use
  `explicitToJson: true` when a model nests other custom objects. Data models
  extend or convert to domain entities; repositories return domain types.
  Commit the generated files.

## Errors and logging

- Exceptions extend `AppExceptions` (`lib/core/exceptions/exceptions.dart`).
  Network ones (`NetworkException`, `ValidationException`, `ServerException`,
  `TooManyRequestsException`) are in `lib/core/network/exceptions.dart`;
  feature ones in `lib/features/<feature>/exceptions/`.
- Repositories catch `DioException` and convert it with
  `ApiExceptionHandler.handle(e)`. Rethrow `AppExceptions` unchanged so a
  generic `catch` does not swallow them.
- View models catch everything, log it, and put a user-facing message in
  state. Screens show it (SnackBar or an error view).
- Log with `AppLogger` (`lib/core/logging/logger.dart`). A class that logs
  declares `static const String _logTag = 'ClassName'` and passes it as the
  tag: `AppLogger.i('message', _logTag)`; for errors,
  `AppLogger.e('message', error, stackTrace, _logTag)`.
- Never log PII in release builds: wrap emails in
  `AppLogger.redactEmail(email)`. `print` is flagged by `avoid_print` and
  fails `just analyze`.

## Code style

- `analysis_options.yaml` turns on `strict-casts`, `strict-inference` and
  `strict-raw-types`, and requires trailing commas, explicit return types,
  `sort_child_properties_last`, and cancelled subscriptions and closed sinks.
  `dart format` is the formatter.
- File names are `snake_case.dart`; classes are PascalCase with role suffixes
  (`...Service`, `...ViewModel`, `...Repository` / `...RepositoryImpl`,
  `...Exception`). Screens live in `presentation/views/`, mostly as
  `*_screen.dart` holding a `...Page` widget.
- Single quotes. Private members start with `_`. Prefer named parameters and
  `required` for mandatory ones.
- Inside `lib/`, use relative imports (the dominant style; the
  `AppLocalizations` import is often `package:gatuno/l10n/...`, so do not churn
  existing imports); tests import `package:gatuno/...`.
- Comments explain why, not what. Use `///` doc comments on public APIs and
  abstract classes.

## UI, theme and localization

- **Design tokens.** The Gatuno Figma file is the source of truth;
  `DESIGN.md` documents it, including known gaps, and `lib/core/theme/`
  implements it (`theme.dart`,
  `app_palette.dart`, `app_typography.dart`, the `GatunoColors` extension).
  Use theme colors and text styles, never raw hex values in widgets. If you
  change tokens, keep `DESIGN.md` and `.impeccable/design.json` in sync and run
  `just design-tokens`. For design work, the tool-neutral `impeccable` skill
  lives in `.agents/skills/` (linked from `.claude/` and `.gemini/`).
- **Strings.** Every user-facing string goes in `lib/l10n/app_en.arb` and
  `lib/l10n/app_pt.arb`. Keys are camelCase with a feature prefix
  (`authSignInTitle`, `booksSearchHint`, `settingsTitle`, `commonLoading`). Run
  `just l10n` after editing and commit the regenerated
  `lib/l10n/app_localizations*.dart`.

### Atomic Design

UI components follow Atomic Design:

| Tier | Where | Example |
| --- | --- | --- |
| Atoms | `lib/shared/components/atoms/`, `lib/features/<feature>/presentation/components/atoms/` | `AppButton`, `BookTypeBadge` |
| Molecules | `lib/shared/components/molecules/`, `.../components/molecules/` | `AppErrorView`, `BookCard` |
| Organisms | `lib/shared/components/organisms/`, `.../components/organisms/` | `NavigationShell`, `BooksAppBar` |
| Templates | `lib/features/<feature>/presentation/components/templates/` | `BooksTemplate` |
| Pages | `lib/features/<feature>/presentation/views/` | `BooksPage` (`books_screen.dart`) |

Shared tiers live in `lib/shared/components/`; feature-specific ones in the
feature's `presentation/components/`. About half the pages delegate layout to
a template (`BooksPage` → `BooksTemplate`); the rest build it directly.

<!-- Atomic Design composition rules: see issue #67. -->

## Tests

- Framework: `flutter_test` with `mocktail` for mocks.
- Test files mirror `lib/` paths and end in `_test.dart`.
- Widget tests use `tester.pumpApp(...)` from `test/helpers/pump_app.dart`
  (router, localizations, providers); `test/helpers/test_injection.dart` holds
  shared GetIt setup and mocks.
- Add or update tests with every behaviour change, and run `just test` (or
  `just check`) before you finish.
