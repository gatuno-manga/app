Run systematic **technical** quality checks on the Flutter app and generate a comprehensive report. Don't fix issues; document them for other commands to address.

This is a code-level audit, not a design critique. Check what's measurable and verifiable in the Dart source. Run `flutter analyze <target path>` first and fold its output into the findings (if it cannot run, write `Analyzer: not run, <reason>`), then grep `lib/` using [flutter-checklist.md](flutter-checklist.md). Cite `file:line` for every finding. Score platform conformance against [android.md](android.md) and [ios.md](ios.md); read them first if you have not. Read `PRODUCT.md` and `DESIGN.md` if they exist (never invent them).

## Diagnostic Scan

Score each of 5 dimensions 0-4 using the criteria below.

### 1. Accessibility (TalkBack / VoiceOver)

**Check for**:
- **Missing semantics**: `GestureDetector`/`InkWell`/icon buttons without `Semantics`, `tooltip`, or `semanticLabel`; decorative images not in `ExcludeSemantics`; related widgets that should be one `MergeSemantics` node
- **Reading and focus order**: illogical traversal, unreachable controls, focus lost after navigation or dialog dismissal, state changes not announced
- **Text scaling**: fixed-height containers, `maxLines` clipping essential text, `Row`s without `Flexible`/`Expanded` that overflow at `MediaQuery.textScaler` 1.5-2.0
- **Tap targets**: below 48x48dp (Android) / 44pt (iOS), or crammed with no spacing
- **Reduced motion**: animation ignoring `MediaQuery.disableAnimationsOf(context)`; give a crossfade or instant alternative that preserves the state change, not a blanket kill; flag flashing and motion that blocks reading or task completion
- **Contrast**: text below 4.5:1 (3:1 for large text and UI components) in light or dark; meaning conveyed by color alone
- **Forms**: fields without labels, poor error messaging, missing required indicators

**Score 0-4**: 0=Screen reader unusable, 1=Major gaps (unlabeled controls, no scaling), 2=Partial (labels exist, order or scaling breaks), 3=Good (WCAG AA mostly met, minor gaps), 4=Excellent (labeled, ordered, scales cleanly, reduced motion honored)

### 2. Performance

**Check for**:
- **Slow startup**: heavy work before the first frame
- **Unvirtualized lists**: `ListView(children: [...])` or `Column` over long or dynamic content instead of `ListView.builder` / lazy slivers; `shrinkWrap: true` lists nested in scroll views
- **Build cost**: heavy work in `build`, `setState`/`notifyListeners` rebuilding a whole screen for a small change, missing `const` constructors
- **Raster cost**: missing `RepaintBoundary` on frequently animating subtrees, `Opacity`/`ClipRRect`/`BackdropFilter` over large subtrees every frame, unbounded blur and shadows
- **Images**: full-size network images for thumbnails (no `cacheWidth`/`cacheHeight`), no caching or placeholder
- **Leaks and weight**: undisposed `AnimationController`, streams, or text controllers; unused dependencies; frame times verified only in debug (profile with `flutter run --profile` and DevTools)

**Score 0-4**: 0=Janky everywhere, 1=Major problems (unvirtualized lists, slow launch), 2=Partial (some optimization, gaps remain), 3=Good (minor improvements possible), 4=Excellent (fast launch, smooth scroll, lean)

### 3. Theming

**Check for**:
- **Hardcoded colors and styles**: `Color(0x...)`, `Colors.xxx`, inline `TextStyle(fontSize: ...)` in widgets instead of `Theme.of(context).colorScheme` and `textTheme`; magic spacing and radii instead of a shared scale or `ThemeExtension`
- **Broken dark theme**: missing dark scheme, pure `Colors.black`/`Colors.white` instead of `surface`/`onSurface`, poor dark contrast, a quick invert
- **Dynamic Color** (Android 12+): ignored where it fits, or no static fallback scheme
- **Off-platform materials**: hand-rolled glass, arbitrary shadows where tonal elevation is expected
- **Theme switching**: values captured once that do not update on theme change

**Score 0-4**: 0=Hard-coded everything, 1=Minimal tokens, 2=Partial (tokens exist, inconsistently used), 3=Good (minor hard-coded values), 4=Excellent (semantic roles throughout, both themes first-class)

### 4. Platform Conformance and Implementation Integrity (CRITICAL)

Score against [android.md](android.md) and [ios.md](ios.md), including their slop tests, and against this repo's structure. **Check for**:
- **Broken system gestures**: edge-swipe back disabled (iOS), predictive Back hijacked (Android), `PopScope` traps
- **Inset violations**: content under the notch, Dynamic Island, home indicator, status bar, or keyboard; missing `SafeArea`
- **Off-platform navigation**: custom global nav, overloaded tab bars, one platform's patterns forced on the other without `.adaptive` widgets
- **Icon drift**: mixed icon sets instead of Material Symbols (or SF Symbols via Cupertino icons where adaptive)
- **Design-system drift**: new components built where an `App*` atom exists (`AppButton`, `AppTextField`, `AppSkeleton`, `AppErrorView`); reusable widgets duplicated inside a feature instead of `lib/shared/components/{atoms,molecules,organisms}`; layout in a page that belongs in a template; business logic in widgets instead of the ViewModel
- **i18n**: user-facing string literals instead of l10n ARB keys (EN + PT, feature-prefixed); `print` instead of `AppLogger`
- **Decorative sameness**: repeated gradients, glow shadows, identical card grids, emoji as icons, side-stripe borders
- Separate deterministic findings (analyzer, grep) from visual judgment, and call out false positives.

**Score 0-4**: 0=Systemic drift, nothing native, 1=Heavy violations (3-4 kinds), 2=Several verified issues, 3=Minor isolated issues, 4=Coherent, intentional, a fluent user trusts every screen

### 5. Adaptivity

**Check for**:
- **Stretched phone layouts**: tablet or desktop rendering a scaled-up phone UI instead of using `LayoutBuilder` / `MediaQuery.sizeOf` and window size classes
- **Fixed sizes**: width/height literals sized for one phone; content not wrapped in `SafeArea`
- **Overflow**: `Column` of unbounded children without scroll (overflow stripes)
- **Orientation**: landscape clipped, or locked without reason
- **Keyboard/IME**: inputs hidden behind the keyboard, no inset handling
- **Multitasking and foldables**: split-screen or hinge changes breaking layout
- **Broken touch interaction**: custom sliders and drag surfaces that swallow scroll, lose the drag to a parent scrollable, or stay stuck after an interrupted gesture (no cancel handling in `onPanCancel`/`onHorizontalDragCancel`)

**Score 0-4**: 0=One screen size only, 1=Major breakage (landscape or tablet broken), 2=Partial, 3=Good (minor edge cases), 4=Excellent (adapts across sizes, orientations, and windowing; gestures hold up)

## Generate Report

### Audit Health Score

| # | Dimension | Score | Key Finding |
|---|-----------|-------|-------------|
| 1 | Accessibility | ? | [most critical issue or "--"] |
| 2 | Performance | ? | |
| 3 | Theming | ? | |
| 4 | Platform Conformance and Integrity | ? | |
| 5 | Adaptivity | ? | |
| **Total** | | **??/20** | **[Rating band]** |

**Rating bands**: 18-20 Excellent (minor polish), 14-17 Good (address weak dimensions), 10-13 Acceptable (significant work needed), 6-9 Poor (major overhaul), 0-5 Critical (fundamental issues)

### Conformance Verdict
**Start here.** Pass/fail: does the app read as native Flutter with a coherent product-specific system, or as a ported website with generic defaults? Cite verified evidence (`flutter analyze` results, checklist hits) and be brutally honest.

### Executive Summary
- Audit Health Score: **??/20** ([rating band])
- Total issues found (count by severity: P0/P1/P2/P3)
- Top 3-5 critical issues
- Recommended next steps

### Detailed Findings by Severity

Tag every issue with **P0-P3 severity**:
- **P0 Blocking**: Prevents task completion. Fix immediately
- **P1 Major**: Significant difficulty or WCAG AA / platform-guideline violation. Fix before release
- **P2 Minor**: Annoyance, workaround exists. Fix in next pass
- **P3 Polish**: Nice-to-fix, no real user impact. Fix if time permits

For each issue, document:
- **[P?] Issue name**
- **Location**: `file:line`, widget
- **Category**: Accessibility / Performance / Theming / Conformance / Adaptivity
- **Impact**: How it affects users
- **Standard**: WCAG or Material/HIG rule it violates (if applicable)
- **Recommendation**: How to fix it, naming the theme role or shared component to use
- **Suggested command**: prefer /impeccable adapt, animate, audit, bolder, clarify, colorize, critique, delight, distill, document, harden, layout, onboard, optimize, overdrive, polish, quieter, shape, typeset

### Patterns & Systemic Issues

Recurring problems that indicate systemic gaps rather than one-offs:
- "Hardcoded `Color(0x...)` appears in 15+ widgets, should read `colorScheme`"
- "Tap targets consistently below 48dp across list rows and icon buttons"

### Positive Findings

Note what's working well: good practices to maintain and replicate.

## Recommended Actions

List recommended commands in priority order (P0 first, then P1, then P2):

1. **[P?] `/command-name`**: Brief description (specific context from audit findings)
2. **[P?] `/command-name`**: Brief description (specific context)

**Rules**: Only recommend commands from the list above. Map findings to the most appropriate command. End with `/impeccable polish` as the final step if any fixes were recommended.

After presenting the summary, tell the user:

> You can ask me to run these one at a time, all at once, or in any order you prefer.
>
> Re-run `/impeccable audit` after fixes to see your score improve.

Keep P3s few: a long tail of minor issues buries the ones that matter.

**Avoid**:
- Report issues without explaining impact (why does this matter?)
- Provide generic recommendations (be specific and actionable)
- Skip positive findings (celebrate what works)
- Forget to prioritize (everything can't be P0)
- Report false positives without verification
