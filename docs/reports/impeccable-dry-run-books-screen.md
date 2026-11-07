# Impeccable dry run: books screen (critique + audit)

Target: `lib/features/books/presentation/views/books_screen.dart` and the components it composes (`books_template.dart`, `books_app_bar.dart`, `books_content.dart`, `book_grid.dart`, `book_list.dart`, `book_card.dart`, `book_list_item.dart`, `book_cover.dart`, `books_*_action.dart`, `books_search_field.dart`, shared `pagination.dart`, `app_error_view.dart`, `app_clickable_action.dart`).
Read only. `flutter analyze` was NOT run (explicitly excluded by the requester); `analysis_options.yaml` lints (prefer_const_*, cancel_subscriptions, avoid_print...) were read, not executed. No PRODUCT.md or DESIGN.md exists; none invented. No device/golden evidence: layout claims are from the widget tree only.

---

## Part 1. Critique

Method: sequential (A then B)

### Assessment A (design review, from widget tree)

Design specificity verdict: category-interchangeable. Default AppBar + search TextField, `Card` grid with cover and a black scrim, default `ListTile`-like rows, numbered pagination. Nothing is wrong with familiarity (Operate surface), but the only product character is the Inknut Antiqua font inherited from the theme and the cover art. The screen is a clean, standard library browser.

Design Health Score

| # | Heuristic | Score | Key issue |
|---|-----------|-------|-----------|
| 1 | Visibility of System Status | 2 | Initial load is a bare `CircularProgressIndicator` (books_content.dart:18); page changes show only a 16dp spinner inside the selected page chip |
| 2 | Match System / Real World | 3 | Sort labels and copy are plain; "No books found" is fine |
| 3 | User Control and Freedom | 2 | Search has a clear button, but empty result gives no "clear filters / clear search" action (books_content.dart:27-38); no active-filter indicator on the filter icon |
| 4 | Consistency and Standards | 2 | Feature-local `BookErrorView` vs shared `AppErrorView`; raw `TextField` instead of `AppTextField`; hardcoded colors vs theme |
| 5 | Error Prevention | 3 | Sort via closed menu, filters in a sheet; nothing destructive |
| 6 | Recognition Rather Than Recall | 2 | Layout toggle and filter are icon-only with no tooltip; layout icon shows the TARGET mode (list icon while in grid), which is a known ambiguity |
| 7 | Flexibility and Efficiency | 2 | No grid density option, no scroll-to-top, no tablet columns; paging only via numbered footer |
| 8 | Aesthetic and Minimalist Design | 3 | Restrained; 4 app bar controls plus search crowd the bar on narrow phones |
| 9 | Error Recovery | 1 | Full-screen error is a raw `e.toString()` string with no retry (books_content.dart:21-23, books_view_model.dart:120) |
| 10 | Help and Documentation | 1 | No tooltips on 2 of 4 controls, no empty-state guidance |
| **Total** | | **21/40** | **Acceptable (significant improvement needed)** |

Cognitive load: 2 failures of 8 (minimal choices: app bar shows search + sort + layout + filter, plus 8 sort options in the menu, which is 8+ choices at one decision point; progressive disclosure is partly done via sheet and menu). Moderate.

Emotional journey: entry is a naked spinner (valley), content grid is pleasant (peak), failure is a dead end with technical text (worst valley; the end state on error is the worst moment).

Strengths
- Clean Atomic structure: page -> template -> organisms -> molecules -> atoms; ViewModel owns state; strings use ARB keys.
- Pull-to-refresh on both populated and empty states, and a snackbar for background errors when data exists (books_screen.dart:42-54), so existing content is never replaced by an error.
- `BookCover` handles blurHash, error widget and null cover; `Pagination` has tooltips and semantics.

### Assessment B (code evidence)

Analyzer: not run (excluded). Checklist grep hits are in the findings below; false positives ruled out: `Colors.transparent` (book_card.dart:38) is fine; `Pagination` returning `SizedBox.shrink` for one page is intended; `BooksTemplate` has no business logic (OK).

### Combined: Priority Issues

1. **[P1] Dead-end error state.** books_content.dart:21-23 shows raw exception text, no retry, no `l10n`. Fix: show a recovery view with retry calling `viewModel.fetchBooks(refresh: true)`; map the error to a localized message in the ViewModel. Note `AppErrorView` requires `onGoBack` (wrong for a tab root), so either make `onGoBack` optional or reuse the feature `BookErrorView` (book_error_view.dart:8, retry only). Suggested command: `/impeccable harden`.
2. **[P1] Unlabeled icon-only controls.** books_layout_action.dart:16 and books_filter_action.dart:10 have no `tooltip`; search clear (books_search_field.dart:47) too. Fix: `tooltip:` from new ARB keys (EN + PT), or `AppIconButton(tooltip:)`. Suggested command: `/impeccable clarify`.
3. **[P1] Fixed sizes break at large text and on tablets.** book_list.dart:16 `itemExtent: 116`, book_list_item.dart:20 `SizedBox(height: 100)`, book_grid.dart:17-22 `crossAxisCount: 2`. Fix: list row min-height with `ConstrainedBox` and no `itemExtent` (or scale with `MediaQuery.textScalerOf`), grid `SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: ~180)`. Suggested command: `/impeccable adapt`.
4. **[P2] Loading and empty states are generic.** books_content.dart:18 spinner where `AppSkeleton` grid/list placeholders fit; :27-38 "No books found" with no next action. Fix: skeleton cards matching layout; empty state with "Clear filters" / "Clear search" button. Suggested command: `/impeccable onboard`.
5. **[P2] Token drift in the card.** book_card.dart:38-39,47-50 hardcoded `Colors.black`/`Colors.white` and inline `TextStyle(fontWeight...)`; book_list_item.dart:36-39 inline `fontSize: 16`. Fix: scrim from `colorScheme.scrim`, title style `textTheme.titleSmall?.copyWith(color: colorScheme.onInverseSurface)`, drop the `fontSize`. Suggested command: `/impeccable typeset`.

Persona red flags
- Sam (a11y): layout/filter buttons announced as "button" only; cover images and placeholder `Icons.book` (book_cover.dart:42,48) not marked decorative or labeled (not verified in `AppImage`); pagination chips 36dp.
- Casey (mobile): search, sort, layout and filter all in the top edge, nothing in the thumb zone; pagination footer needs precise 36dp taps; no infinite scroll.
- Alex (power user): grid fixed at 2 columns on any device, no density toggle, 20+ pages require several taps.
- Riley (stress): very long PT titles in 2-line scrim are truncated, list row clips at text scale 2.0, error + empty list shows raw exception.

Minor observations: search only fires on submit and has no `textInputAction: TextInputAction.search`; no active-filter badge; layout icon shows target mode.

Questions to consider: should pagination be infinite scroll for a reading library? Should the screen show reading progress on cards (the app already syncs progress via MQTT)?

Questions skipped: headless dry run (the requester asked for a report only; no interactive user). 5 priority issues were listed, so the skill would normally require questions here.

---

## Part 2. Audit

### Audit Health Score

| # | Dimension | Score | Key finding |
|---|-----------|-------|-------------|
| 1 | Accessibility | 2 | Missing tooltips, 36dp pagination targets, row clipping at large text |
| 2 | Performance | 3 | Builders used, `const` mostly right; whole screen rebuilds per state; placeholder icons fine |
| 3 | Theming | 2 | Hardcoded black/white/grey and inline text styles in card, list item, pagination |
| 4 | Platform conformance and integrity | 2 | Duplicate error view, raw TextField, string literal, error text unlocalized |
| 5 | Adaptivity | 2 | Fixed 2-col grid, fixed row extent; no size classes |
| **Total** | | **11/20** | **Acceptable (significant work needed)** |

Conformance verdict: partial pass. Reads as native Flutter with a coherent Atomic structure, but with default Material styling and several unverified-by-analyzer drifts. Analyzer was not run, so this verdict rests on grep and reading only.

Counts: P0 0, P1 4, P2 9, P3 3 (16 findings).

### Detailed findings

P1
1. **Dead-end error state.** books_content.dart:21-23; books_view_model.dart:120. Category: Conformance/Recovery. Impact: user cannot retry without pull-to-refresh (not available in this branch since it returns a plain `Center`). Fix: retry view (see Critique 1); localize message. Command: harden.
2. **Icon-only buttons without tooltip.** books_layout_action.dart:16; books_filter_action.dart:10; books_search_field.dart:47. Category: Accessibility. Standard: WCAG 4.1.2, Material a11y. Fix: `tooltip` via l10n or `AppIconButton(tooltip: ...)`. Command: clarify.
3. **Pagination tap target 36dp.** shared pagination.dart:106-107 (`Container` 36x36 inside `GestureDetector` in `AppClickableAction`, app_clickable_action.dart:24-31; outer 4dp padding is outside the hit area). Standard: Material 48dp. Fix: wrap with `ConstrainedBox(minWidth/minHeight 48)` in `AppClickableAction` or pad the child. Command: polish.
4. **Text-scale clipping in list row.** book_list_item.dart:20 (`height: 100`), book_list.dart:16 (`itemExtent: 116.0`); title 2 lines + description 3 lines (book_info.dart:16-17) overflow or clip at textScaler 1.5-2.0. Fix: min height, remove `itemExtent`, let `IntrinsicHeight`/min constraints grow the row. Command: adapt.

P2
5. **Fixed 2-column grid.** book_grid.dart:17-22. Stretched phone UI on tablet. Fix: `SliverGridDelegateWithMaxCrossAxisExtent`. Command: adapt.
6. **Hardcoded colors.** book_card.dart:38-39,48-49; pagination.dart:108 (`Colors.grey.shade400`). Fix: `colorScheme.scrim`, `onInverseSurface`, `outlineVariant`. Command: colorize.
7. **Inline TextStyle / fontSize.** book_card.dart:47-50; book_list_item.dart:36-39; pagination.dart:127-130; 4dp/8dp/16dp radii and spacing magic numbers (book_card/pagination `BorderRadius.circular(4)`, book_cover.dart:24 default 4). Fix: `textTheme` roles, shared spacing/radius extension. Command: typeset.
8. **Snackbar contrast.** books_screen.dart:48 sets `backgroundColor: colorScheme.error` but not text color; default text uses the snackbar theme's color, possibly not `onError`. Fix: `contentTextStyle` with `colorScheme.onError`, or rely on a themed error snackbar (theme.dart:231,327). Command: harden.
9. **Spinner instead of skeleton.** books_content.dart:18. Fix: `AppSkeleton` grid/list matching the active layout. Command: onboard.
10. **Empty state without recovery.** books_content.dart:27-38; also `MediaQuery.of(context).size.height * 0.8` (line 33) subscribes to all MediaQuery changes; use `MediaQuery.sizeOf` or `CustomScrollView` + `SliverFillRemaining`. Command: onboard.
11. **Search field details.** books_search_field.dart:41-57: raw `TextField` instead of `AppTextField`, no `textInputAction: search`, searches only on submit, `setState` per keystroke to toggle the clear button (cheap, but `ValueListenableBuilder` is cleaner). Command: polish.
12. **Whole-screen rebuild and split state source.** books_screen.dart:26 (manual subscription) plus :58-64 (`StreamBuilder`) both listen to the same stream; `BooksContent` ignores `state` and re-reads `viewModel` getters (books_content.dart:17-25,47-55), so app bar, template and content rebuild together. Fix: pass `state` down, or split two `StreamBuilder`s with `select`-style `distinct()`. Command: optimize.
13. **Template wraps an already-`PreferredSizeWidget` in `PreferredSize`.** books_template.dart:12-17. Redundant, and hardcodes `kToolbarHeight` so a taller app bar (text scale, future search bar) would be clipped. Fix: type the field `PreferredSizeWidget?` and pass straight through. Command: polish.

P3
14. **Decorative semantics.** book_cover.dart:42,48 `Icons.book` placeholder not wrapped in `ExcludeSemantics`; cover image has no `semanticLabel` (BookCard could merge title + cover with `Semantics(label: title, button: true)`; `AppImage` internals not verified). Command: harden.
15. **String literal.** pagination.dart:77 `Text('...')` ellipsis glyph is not a localizable string in practice but fails the grep `Text\('`; false-positive-grade, document and move on. Command: polish.
16. **Formatting / naming.** books_screen.dart:63 trailing whitespace (`dart format`), class `BooksPage` lives in `books_screen.dart`, `BooksFilterSheet.show(context, _viewModel)` passes the ViewModel into a static sheet (acceptable, but couples sheet to VM). Command: polish.

### Systemic patterns
- Hardcoded colors and inline `TextStyle` repeat in 3 files of this slice (card, list item, pagination).
- Icon-only controls lack tooltips by default; `AppIconButton.tooltip` is nullable (app_icon_button.dart:8), so the shared atom does not enforce the rule it is recommended for.
- Fixed pixel sizes (116, 100, 70x100, 36, crossAxisCount 2) are repeated across list, grid and pagination.
- Error handling is split: `AppErrorView` (needs `onGoBack`), `BookErrorView` (retry only), and raw `Text(error)` in `BooksContent`.

### Positive findings
- `ListView.builder`/`GridView.builder` with `AlwaysScrollableScrollPhysics` so pull-to-refresh works with short lists.
- Controllers and subscription disposed (books_screen.dart:35-40); `cancel_subscriptions` lint satisfied by inspection.
- l10n used for sort options, hint, empty text; `PopupMenuButton` has a tooltip.
- Reuse of `AppImage`, `AppSkeleton`, blurHash for covers.

### Recommended actions
1. [P1] `/impeccable harden`: retry error state, localized message, snackbar contrast.
2. [P1] `/impeccable clarify`: tooltips for layout, filter, clear.
3. [P1] `/impeccable adapt`: grid `maxCrossAxisExtent`, remove fixed row height, 48dp pagination.
4. [P2] `/impeccable colorize` and `/impeccable typeset`: scrim and title tokens.
5. [P2] `/impeccable onboard`: skeleton and actionable empty state.
6. [P2] `/impeccable optimize`: single state source, scoped rebuilds.
7. `/impeccable polish` last.

---

## Skill feedback

> Status: the 'Wrong or inconsistent' items below were fixed in the skill files after this run (disableAnimationsOf everywhere, operate.md title and pinned-font note, AppErrorView/AppIconButton/AppClickableAction caveats in the checklist, #41 link in NOTICE, analyzer fallback and headless-question allowance, unified severity). `docs/reports/` was created by this report.

Wrong or inconsistent
- `operate.md` and `craft-floor.md` say `MediaQuery.disableAnimations`; `audit.md` and `flutter-checklist.md` say `MediaQuery.disableAnimationsOf(context)`. Pick the `...Of` form everywhere.
- `operate.md` title says "(and Read notes)" and describes Read screens, but SKILL.md "Not supported" drops the Read mode. Remove or reword.
- `operate.md` warns against display fonts in labels and recommends one family, but the app's default font is Inknut Antiqua (core/theme/theme.dart:199,295, a decorative serif) applied to everything. The skill should say this is pinned and not to be flagged.
- `flutter-checklist.md` recommends `AppErrorView` for errors, but its constructor requires `onGoBack` (app_error_view.dart:9), so it does not fit a tab root; the checklist also does not flag `AppClickableAction` (used for pagination) having no minimum 48dp hit area.
- `flutter-checklist.md` says "Prefer ... `AppIconButton` with `Semantics`" but `AppIconButton.tooltip` is optional, so following the advice does not guarantee a label.
- "Refs #41" appeared with no link or title (resolved: now named in NOTICE.md).

Web-leaning or low value for Flutter
- Critique's "Design specificity", "Cognitive load: 4-item chunking", "Persona" and "emotional journey (peak-end)" sections are generic and hard to apply to a list/browse screen; the hero-metric, kicker and section-number bans in `craft-floor.md` rarely apply.
- Audit's "Dynamic Color" check and "tabular figures" have no pointer to where to look (no `dynamic_color` mention in the repo).
- `/impeccable <cmd>` slash syntax in recommendations vs `critique [target]` syntax in SKILL.md; unclear how invoked in Claude Code.
- Line length 65-75 characters rule is not relevant on a grid/list screen.

Confusing or missing
- Both critique and audit mandate running `flutter analyze` first with no fallback when it cannot run (slow, whole-repo, or forbidden). Suggest `flutter analyze <path>` / `dart analyze <path>` and an explicit "analyzer: not run, reason" line in the report template. (Critique has the line, audit does not.)
- Critique requires Assessment A "before reading B's output" yet A says "Read the relevant source", so the code is already read; the anti-anchoring rule is only meaningful with two agents. Clarify that sequential means: write A's findings from the widget tree first, then grep.
- Critique requires questions as the last item and forbids ending without them, but gives no rule for headless or delegated runs (only "skip if fewer than 3 priority issues"). Add a `Questions skipped: non-interactive run` allowance.
- No guidance on where to save reports; `docs/reports/` did not exist in this repo.
- Audit says score against `android.md`/`ios.md` but does not say what to do when those files cover only platform feel and the code has no platform branches; I scored conformance on repo structure only.
- Audit severity rubric counts "WCAG AA violation = P1" but critique's rubric ("would a user contact support") gives different answers for the same issue (e.g. missing tooltip); unify.
- Nothing says whether shared components (here `pagination.dart`) found while auditing a screen are in scope; I included them and flagged them as shared.
- No instruction to verify theme-level claims before citing them (snackbar `onError` contrast depends on `theme.dart:231,327`, which I did not read in detail).

Things that referenced nonexistent items: none found. All linked reference files exist (`android.md`, `ios.md`, `init.md`, `routing.md`, ...); `PRODUCT.md`/`DESIGN.md` are optional by design and absent in the repo.
