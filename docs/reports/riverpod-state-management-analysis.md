# Riverpod vs. current state management: StatefulWidget audit and verdict

- Issue: #13 (analyze the replacement of state management with Riverpod)
- Inventory base: `main` @ `5394918` (all `file:line` references below are valid at that commit; other branches edit `lib/` in parallel, so re-grep before acting on them)
- Method: repo-wide grep of `extends State<`, `StatefulWidget`, `ChangeNotifier`, `setState(`, `context.read`, `StreamBuilder`, `package:provider`; manual read of every stateful widget; one throwaway spike (not committed).

## 1. Verdict

**Do not migrate the app to Riverpod now.** Adopt it only if a concrete need appears (see §6).

Reasons, in order of weight:

1. **The `StatefulWidget`s are not where the app's state lives.** Business and screen state is already in 13 view models extending `BaseStreamViewModel<T>` (`lib/core/base/base_stream_view_model.dart:6`, an immutable-state `BehaviorSubject` wrapper), rendered with `StreamBuilder`. Only 4 of the 24 stateful files exist because of a view model (§3, category B); the rest hold framework objects (controllers, timers, observers) that Riverpod does not replace.
2. **`provider` is used only as dependency injection**, not as a state container: `Provider<XViewModel>(create: ...)` in feature routers and `context.read<...>()` in widgets (20 files use `package:provider` or `context.read`, by grep; none uses `watch`, `Consumer`, `Selector` or `ChangeNotifierProvider`). The "state management" being replaced is mostly `get_it` + `Provider` wiring plus `StreamBuilder`.
3. **Measured spike cost is low per feature but the benefit is small** (§5): a net reduction of 20 lines in one feature, at the price of a new dependency, a second DI mechanism living beside `get_it` and `provider`, and one name collision.
4. The remaining `ChangeNotifier`s (§4) are services/infra, not UI state, and are covered by the existing view models.

## 2. Current architecture (evidence)

| Concern | Mechanism | Evidence |
| --- | --- | --- |
| Global DI | `get_it` (`sl`) | `lib/core/di/injection.dart` plus per-feature `*_injection.dart` (33 `register*` calls in total); `Provider.value`/`MultiProvider` for `AuthService`/`SettingsService` at `lib/main.dart:22-25` |
| Scoped DI / lifetime of a view model | `provider`'s `Provider<VM>(create:)` per route | e.g. `lib/features/certificates/certificates_router.dart:11`, `lib/features/books/books_router.dart:18`, `lib/shared/components/organisms/navigation_shell.dart:19` |
| Screen state | `BaseStreamViewModel<State>` + `Equatable` state + `copyWith` | `lib/core/base/base_stream_view_model.dart:6`, `lib/features/certificates/presentation/view_models/certificates_view_model.dart:54` |
| Rendering | `StreamBuilder<State>` with `initialData: vm.state` | `lib/features/certificates/presentation/views/certificates_screen.dart:67` |
| Side effects from state (snackbars, navigation) | manual `stateStream.listen` in `initState` | §3 category B |

`BaseStreamViewModel` already gives what Riverpod's `Notifier` gives for this app: immutable state, synchronous read (`state`), explicit disposal, and view models that are unit-testable without Flutter (`test/features/certificates/presentation/view_models/certificates_view_model_test.dart`).

## 3. `StatefulWidget` inventory (24 files, 25 `State` classes, 14 `setState` call sites)

Each row is the `State` class declaration line at `5394918`. "Replaceable by Riverpod?" asks whether the *state* could move into a provider; controllers/timers still need a widget-owned lifecycle (Riverpod has no equivalent besides `flutter_hooks`, which would be a second new dependency).

### A1. Text input controllers in forms and dialogs (9): keep as is

`TextEditingController`/`GlobalKey<FormState>` created in `initState`, disposed in `dispose`. This is ephemeral, widget-local state, and the Flutter-recommended place for it.

- `lib/features/authentication/presentation/components/organisms/signin_form.dart:23`
- `lib/features/authentication/presentation/components/organisms/signup_form.dart:23`
- `lib/features/book_requests/presentation/components/organisms/create_book_request_form.dart:17` (`setState(() {})` at `:41` only to refresh the submit-button enablement)
- `lib/features/books/presentation/components/molecules/books_search_field.dart:18` (`setState` at `:33`)
- `lib/features/books/presentation/components/organisms/books_filter_sheet.dart:52` (4 `setState` calls, `:72-103`; local draft of filter options, committed on apply)
- `lib/features/certificates/presentation/components/molecules/certificate_add_dialog.dart:24` (`_isLoading`, `_isValid`)
- `lib/features/settings/presentation/components/organisms/settings_api_form.dart:20`
- `lib/shared/components/organisms/certificate_trust_dialog.dart:33`
- `lib/features/welcome/presentation/views/welcome_screen.dart:14`

Replaceable by Riverpod? Not meaningfully. Moving a draft form value into a provider adds global-looking state for something that must die with the dialog. **Not worth it.**

### A2. Scroll, animation, timer and lifecycle objects (5): keep as is

- `lib/features/book_requests/presentation/views/book_requests_list_page.dart:15` (`ScrollController` + infinite-scroll trigger)
- `lib/features/books/presentation/views/book_details_screen.dart:16` (`ScrollController`)
- `lib/shared/components/organisms/app_scrollable_positioned_list.dart:24` and `:239` (`_ItemVisibilityTracker`; `ScrollController`, `GlobalKey`s per item)
- `lib/features/home/presentation/components/organisms/featured_carousel.dart:16` (`PageController` + `Timer.periodic`, `setState` at `:61`)
- `lib/shared/utils/app_activity_observer.dart:27` (`WidgetsBindingObserver` + idle `Timer`)

Replaceable by Riverpod? No: these are objects with widget lifecycle, which is exactly what `State` is for. **Not worth it.**

### A3. Props-derived or presentational state (4): keep as is

- `lib/features/reading/presentation/components/molecules/image_reader_item.dart:19` (reacts to prop change in `didUpdateWidget`, `setState` at `:64`)
- `lib/features/reading/presentation/components/organisms/text_reader.dart:17`
- `lib/shared/components/atoms/app_image_placeholder.dart:26` (async decode into `_bytes`, `setState` at `:63`, `:68`)
- `lib/features/reading/presentation/components/organisms/reader_overlay_wrapper.dart:20` (one `bool`, `setState` at `:24`; the textbook case for local state)

**Not worth it.**

### B. Widgets that exist only to bridge a view model's stream to UI side effects (4): the only real candidates

Pattern: `initState` → `context.read<VM>()` → `stateStream.listen(_onStateChanged)` → `dispose` cancels. This is the boilerplate Riverpod's `ref.listen` removes.

- `lib/features/authentication/presentation/views/signin_screen.dart:22`
- `lib/features/authentication/presentation/views/signup_screen.dart:22`
- `lib/features/certificates/presentation/views/certificates_screen.dart:18`
- `lib/features/books/presentation/views/books_screen.dart:17` (also owns a search controller, so it would stay stateful or need hooks)

Replaceable by Riverpod? Yes, mechanically (spike in §5). Gain: about 15 lines each and no manual subscription cancel. Note that the same result is reachable *without* Riverpod: a small `StreamListener<T>` widget (or `StreamSubscription` helper in the base class) would remove the same boilerplate for ~30 lines total.

### C. Widgets that only trigger an initial load (2): marginal

- `lib/features/users/presentation/views/me_screen.dart:17` (`context.read<MeViewModel>().init()` in a post-frame callback, `:22`)
- `lib/features/reading/presentation/views/reading_screen.dart:50` (`didUpdateWidget` → `loadChapter`, `:52-55`)

With a Riverpod `Notifier.build()` or a `family` provider keyed by chapter id the load could be declarative and the widgets could become stateless. Real but small gain; `reading_screen` also owns the `Provider<ReadingViewModel>` at `:25` and reloads by hand in `didUpdateWidget` when the chapter id changes, so it is the one place where `family` semantics would replace manual reload plumbing (it is not a current bug).

### Summary

| Category | Files | Verdict |
| --- | ---: | --- |
| A1 form controllers | 9 | keep |
| A2 scroll/animation/timer/observer | 5 | keep |
| A3 presentational / prop-derived | 4 | keep |
| B stream-listener bridges | 4 | only real candidates |
| C init-load triggers | 2 | marginal |
| **Total** | **24** | **18 keep, 4 candidates, 2 marginal** |

## 4. `ChangeNotifier` usage (4 files)

- `lib/core/base/safe_change_notifier.dart:4`: guard helper for disposal-safe notifications.
- `lib/core/utils/go_router_refresh_stream.dart:5`: router refresh adapter required by `go_router`'s `refreshListenable`; stays regardless of the state library.
- `lib/features/certificates/domain/use_cases/certificates_service.dart:14`: domain service observed by `CertificatesViewModel` via `addListener`.
- `lib/core/base/base_stream_view_model.dart:5`: doc comment only (it says the base class *replaces* `ChangeNotifier`, i.e. the repo already moved off it once).

None is UI state held in a widget.

## 5. Spike: migrate the certificates feature to Riverpod (not committed)

Done on `main` @ `5394918` in this worktree, then discarded (`git checkout -- .`). Scope: `flutter_riverpod ^3.5.0` added, `CertificatesViewModel` turned into `Notifier<CertificatesState>` behind `NotifierProvider.autoDispose`, `CertificatesService` exposed via a `Provider` that wraps `sl<CertificatesService>()`, `CertificatesPage` turned into `ConsumerWidget` with `ref.listen` for the snackbar, `ProviderScope` added in `main.dart`, existing view-model test adapted to a `ProviderContainer`.

| Metric | Value |
| --- | --- |
| Files touched | 5 under `lib/` and `test/` (router, view model, screen, `main.dart`, test) + `pubspec.yaml`/`pubspec.lock`; the service provider lives in the view-model file |
| Lines | +55 / −75 (net −20) |
| `certificates_screen.dart` | 99 → ~72 lines: `State` class, `initState`/`dispose`, `StreamSubscription`, `StreamBuilder` removed |
| `certificates_router.dart` | `Provider<…>(create:)` wrapper removed (−8 lines) |
| Test file | 7 changed lines; 14/14 certificates tests passed after migration, `flutter analyze lib test` clean |
| Time to working | one pass plus two fixes |

Friction found (each would repeat across the app):

1. **Name collision while both libraries coexist.** `Provider` is exported by both `provider` and `flutter_riverpod`; `lib/main.dart` failed `analyze` (`ambiguous_import`) until `flutter_riverpod` was imported with `hide Provider`. Every file that imports both needs the same treatment until `provider` is removed entirely.
2. **`late final` fields in a `Notifier` break on rebuild** (`LateInitializationError: Field '_certificatesService' has already been initialized`, because `build()` runs again when a watched provider changes or the provider is invalidated). They must be plain `late`/getters. This is a documented Riverpod gotcha and is easy to hit when porting view models that were written with `final` constructor injection.
3. **`get_it` is not replaced, it is wrapped.** The service still comes from `sl<…>()`; a `Provider` shim was needed per injected dependency. Dropping `get_it` too would turn this into a full DI rewrite (33 registrations across `injection.dart` and the per-feature `*_injection.dart` files).
4. **Lifetime semantics change.** `Provider<VM>(create:)` ties the view model to the route's widget subtree; `NotifierProvider.autoDispose` ties it to listeners, and tests now need `ProviderContainer`/overrides instead of `Mock` constructor injection.

Extrapolation to the whole app (13 view models, 4 category-B + 2 category-C screens, 20 files using `provider`/`context.read`): roughly 13 × (one view model + one router + one screen + one test) ≈ 50–60 files and a coordinated change of the DI model, for an estimated ~260 net removed lines (13 × the −20 observed per feature). This is an extrapolation from one feature, not a measurement; the certificates feature has no parameterized (`family`) state, which is where the effort would grow.

## 6. Impact, gains and risks

| Dimension | Migrate everything | Do nothing | Targeted alternative |
| --- | --- | --- | --- |
| Risk of regressions | High: 13 view models, DI model, lifetimes | None | Low |
| New dependencies | `flutter_riverpod` (+ `riverpod`, possibly `hooks_riverpod`/`flutter_hooks`) | None | None |
| Boilerplate removed | ~20 lines/feature | 0 | ~30 lines total for category B |
| Testability | Same as today (view models are already framework-free) | Same | Same |
| Conflicts with parallel work | Very high: touches routers, screens and tests everywhere | None | Low |
| Team/learning cost | New paradigm (`ref`, providers, codegen question) | None | None |

Revisit the verdict if any of these becomes true:

- State must be shared between screens that are not in a parent/child relation (today shared state goes through `get_it` singletons and services).
- Parameterized state (`family`) appears in several places, e.g. per-chapter or per-book caches with automatic disposal.
- The team wants first-class async state (`AsyncValue`) instead of hand-written `isLoading`/`error` flags in each `State` class.
- Widget tests need to override dependencies at arbitrary depth (`ProviderScope.overrides`) instead of constructor injection.

## 7. Recommended next steps (not part of this PR)

1. **Optional, low risk, no new dependency:** add a small `StreamListener<T>` widget (or a base-class helper) and convert the four category-B screens to stateless widgets. This captures most of the boilerplate reduction Riverpod would give.
2. **Optional:** convert `reading_screen.dart` so the view model follows the chapter id declaratively (the one plumbing simplification identified in §3 C).
3. **If the team still wants Riverpod:** migrate one feature at a time, coexisting with `provider` (`hide Provider` in files importing both), `get_it` kept as the service locator behind `Provider` shims, starting with certificates (the spike path above); remove `provider` last.
4. Leave all category A files untouched.

These would be separate issues; this PR changes documentation only.

## 8. Verification

- Inventory: `grep -rnE "extends State<|StatefulWidget|ChangeNotifier|setState\(" lib` at `5394918` (24 files with `State`, 25 `State` classes, 14 `setState` call sites, 4 `ChangeNotifier` files).
- Spike: `flutter analyze lib test` clean and `flutter test test/features/certificates` 14/14 passing on the spike tree; spike discarded, no `lib/`, `test/` or dependency change is part of this PR.
