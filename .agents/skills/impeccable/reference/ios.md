# iOS platform

For the Flutter app running on iPhone and iPad. Flutter draws its own UI, so iOS conformance is a choice made in code: the app is Material 3 by default, and on iOS it should adapt where the platform idiom clearly differs (Cupertino or `.adaptive` widgets) rather than look like Android.

HIG conformance governs structure, navigation, and interaction on this hardware; brand expresses through the layer the platform leaves open (tint, type, motion, content), set up in `AppTheme`. See [android.md](android.md) for the Material rulebook and [adapt.md](adapt.md) for the platform translation table.

## The iOS slop test

Would a fluent iPhone user trust this app, or pause at off-spec controls? The tell is a Material app dropped onto iOS unchanged, or a ported website: reinvented navigation bars, custom back gestures, hover-dependent affordances. Default to the platform's idioms; depart only for a reason the user would thank you for.

## Material vs Cupertino adaptivity

- **Use adaptive widgets where the idiom differs**: `Switch.adaptive`, `Slider.adaptive`, `CircularProgressIndicator.adaptive`, `showAdaptiveDialog`, `CupertinoSliverNavigationBar` or adaptive scaffolds where navigation chrome matters, `showCupertinoModalPopup` for action sheets, `CupertinoPicker`/date pickers where native feel counts. Wrap the choice in the shared `App*` components so features do not branch on platform themselves.
- **Page transitions**: `PageTransitionsTheme` with `CupertinoPageTransitionsBuilder` on iOS gives the push slide and the interactive edge-swipe back for free.
- **Scroll physics**: iOS bounce (`BouncingScrollPhysics`) is the platform default via `ScrollConfiguration`; do not force clamping.
- **Branch on `Theme.of(context).platform`** (testable) rather than `Platform.isIOS` in widgets.
- Do not half-convert: a screen is either coherent Material with adaptive controls or coherent Cupertino; mixed metaphors in one view read as slop.

## Layout and structure

- **Safe area.** Lay out inside the safe-area insets (`SafeArea`, `MediaQuery.paddingOf`). No controls under the notch, Dynamic Island, home indicator, or rounded corners.
- **System navigation.** A tab bar for 2-5 top-level sections (sections, never actions), a navigation stack for hierarchy, a sheet for self-contained tasks. No custom global nav, no mixed metaphors.
- **Edge-swipe back stays alive.** The left-edge back gesture is muscle memory; never disable or overlay it (`PopScope` with `canPop: false` needs a real reason).
- **Large titles** on top-level screens, collapsing to inline on scroll; deep detail screens stay inline.

## Touch targets and accessibility

- **44x44 pt minimum** for every tappable control, with breathing room between adjacent targets (the app-wide 48dp target satisfies both platforms).
- **VoiceOver**: every control needs a label (`Semantics`, `semanticLabel`, `Tooltip`), a role (`button`, `header`, `image`), and state (`selected`, `toggled`, `value`); logical reading order; announce dynamic changes (`SemanticsService.announce`); group compound rows with `MergeSemantics`; hide decoration with `ExcludeSemantics`. Test with VoiceOver on.
- **Reduce Motion**: honor `MediaQuery.disableAnimationsOf(context)`; use a crossfade instead of parallax and large slides.
- **Bold Text and increased contrast**: honor `MediaQuery.boldTextOf` and `highContrast`.

## Typography

- **Dynamic Type.** Text follows the system size via `MediaQuery.textScaler`; use `textTheme` roles, never hard-coded sizes. Layouts must not clip or overlap at the largest accessibility sizes.
- **San Francisco carries platform UI**; a brand face (Inknut Antiqua via `AppTheme`) belongs in display and content moments, with body, labels, and controls staying legible and consistent.
- Body text about 17 pt; nothing below 11 pt.

## Color and materials

- **Semantic roles over hex.** Read `Theme.of(context).colorScheme` (and `CupertinoDynamicColor`/`CupertinoColors` where Cupertino widgets are used) so light, dark, and increased contrast resolve automatically; raw hex breaks there.
- **Dark appearance is first-class.** Design and test both.
- **One tint color** drives interactive elements (`primary`); decoration is not its job.
- **System-style blur** only behind bars and sheets, bounded in size; no hand-rolled glassmorphism.

## Components and controls

- **Platform controls.** Switch, segmented control, stepper, pickers, action sheets, alerts, context menus, swipe actions. Reinventing these for flavor is the most common native slop.
- **Iconography**: one consistent set (Material Symbols, or Cupertino icons on Cupertino surfaces); never mix sets within a view.
- **Deliberate modality.** A sheet for a focused dismissible sub-task, a full-screen dialog for immersion. Clear Cancel/Done; honor swipe-to-dismiss unless data loss requires a guard.
- **Grouped/inset lists** for settings-shaped content; no bespoke card stacks.

## Motion

- **System transitions.** Push slides, sheets rise, dismiss reverses the entrance. Custom transitions that fight the navigation model disorient.
- **Reduce Motion honored** (see above).

## Verifying the build

- **Screenshots come from the Simulator or a device.** Run `flutter run -d <simulator-id>` and capture with `xcrun simctl io booted screenshot <path>` (with several running, replace `booted` with the target's UDID from `xcrun simctl list devices booted`; display names can collide, the UDID never does). Capture every device class the app ships to: at least one iPhone and, when iPad is a target, one iPad.
- **Dark appearance and Dynamic Type belong in the pass.** `xcrun simctl ui booted appearance dark` flips appearance (reuse the UDID when several are booted); a check at a large text scale catches the truncation a fixed layout hides.
- **Goldens** (`flutter test`) add repeatable layout evidence, but prove layout only.
- **Simulators give breadth; posture, gestures, and performance need hardware.** Profile with `flutter run --profile`. Say which one produced the evidence.
