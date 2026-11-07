# Flutter anti-pattern checklist

Replaces upstream's web-only slop detector (62 rules, CLI + hook). Run it by reading and grepping `lib/` for the target, then run `flutter analyze`. Cite `file:line` for every finding. Rules enforced by the analyzer (`analysis_options.yaml`) are marked **[lint]**; the rest are judgment calls for `critique` and `audit`. A custom_lint rule set may replace this later (Refs gatuno-manga/app#41).

## Theming and tokens
- Hardcoded `Color(0x...)` / `Colors.xxx` in widgets instead of `Theme.of(context).colorScheme` (grep `Color(0x`, `Colors\.`).
- Inline `TextStyle(fontSize: ..., fontWeight: ...)` instead of `textTheme` roles (grep `TextStyle(`).
- Magic spacing numbers repeated across files instead of a shared spacing scale or `ThemeExtension`.
- Gradients, shadows or `BorderRadius.circular(n)` with arbitrary `n` that differs per widget.
- Pure `Colors.black`/`Colors.white` for surfaces or text instead of `surface`/`onSurface`; dark theme not checked.
- Decoration for its own sake: gradient text, glow shadows, glass blur, side-stripe card borders, identical card grids, emoji as icons.

## Accessibility
- Tap targets under 48x48dp (small `IconButton` with custom constraints, tiny `GestureDetector`s). Prefer `InkWell`/`IconButton`/`AppIconButton` and always set `tooltip` or `Semantics` (the `tooltip` parameter is optional, so check it is passed). `AppClickableAction` has no built-in 48dp hit area: wrap or pad it.
- `GestureDetector`/`InkWell` without `Semantics(button: true, label: ...)` or a `tooltip`.
- Icon-only controls and images without `semanticLabel`/`Tooltip`; decorative images not wrapped in `ExcludeSemantics`.
- Text that breaks at `textScaler` 1.5-2.0: fixed-height containers, `maxLines` clipping essential text, no `Flexible`/`Expanded` in `Row`.
- Contrast below 4.5:1 body / 3:1 large text and UI; meaning conveyed by color alone.
- Animation ignoring `MediaQuery.disableAnimationsOf(context)`.

## Layout and adaptivity
- Fixed `width`/`height` literals sized for one phone; no `LayoutBuilder`/`MediaQuery.sizeOf` for tablet/desktop; content not wrapped in `SafeArea`.
- `Column` of unbounded children without scroll (overflow stripes), `shrinkWrap: true` lists nested in scroll views.
- Orientation or window-size changes untested (golden at compact and expanded widths).

## Performance
- Missing `const` constructors **[lint: prefer_const_constructors, prefer_const_literals_to_create_immutables]**.
- `ListView(children: [...])` for long or dynamic lists instead of `ListView.builder` / the shared scrollable list.
- Network images without `cacheWidth`/`cacheHeight` or a placeholder (use `AppImage`, `AppSkeleton`).
- `setState`/`notifyListeners` rebuilding a whole screen for a small change; heavy work inside `build`.
- Missing `RepaintBoundary` around expensive, frequently animating subtrees; `Opacity`/`ClipRRect` over big subtrees on every frame.
- Unawaited controllers: `AnimationController`, streams, text controllers not disposed **[lint: cancel_subscriptions, close_sinks]**.

## States, copy and i18n
- Missing loading, empty or error state (use `AppSkeleton`; `AppErrorView` needs `onGoBack`, so on a tab root build an inline error with a retry action); spinner where a skeleton fits.
- User-facing string literals in widgets instead of l10n ARB keys (EN + PT, feature-prefixed). grep `Text\('`.
- Vague copy ("Error", "Something went wrong" with no next step), em dashes, filler.
- `print` **[lint: avoid_print]**; use `AppLogger`.

## Structure (Atomic Design)
- Reusable widget duplicated in a feature instead of living in `lib/shared/components/{atoms,molecules,organisms}`; new component built where an `App*` atom exists.
- Page (`views/*_screen.dart`) holding layout that belongs in a template under `presentation/components/templates/`.
- Business logic or data calls inside widgets instead of the ViewModel.

## Scope notes
- Shared components found while auditing a screen (e.g. `pagination.dart`) are in scope; flag them as shared.
- Reports go in `docs/reports/`. Verify theme-level claims (e.g. snackbar contrast) in `lib/core/theme/theme.dart` before citing them.
- Severity: use one rubric across critique and audit. P1 = blocks a task or fails WCAG AA; P2 = degrades the experience; P3 = polish.
