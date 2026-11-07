# Android platform

For the Flutter app running on Android hardware. Flutter draws its own UI, so Material 3 conformance is a choice made in code: use Material widgets, `ThemeData(useMaterial3: true)`, and theme the brand through them.

Material Design 3 governs structure, navigation, and interaction; brand expresses through Material's theming (`ColorScheme`, `TextTheme`, shape, motion) set up in `AppTheme`. Because the same codebase ships to iPhone, iOS still gets its OS guarantees there: see [ios.md](ios.md) for safe-area insets, reduced motion, and edge-swipe back, and prefer adaptive widgets where idiom differs.

## The Android slop test

Would a fluent Android user trust this app, or trip on off-spec components? The most common tell is an iOS app wearing Android's skin: bottom-only navigation copied from iPhone, a back arrow that ignores the system Back gesture, Cupertino-shaped switches and dialogs. Material 3 is the rulebook; follow its components and theme the brand through it.

## Layout and structure

- **Material navigation, matched to size.** `NavigationBar` (bottom, 3-5 destinations) on compact width; `NavigationRail` or `NavigationDrawer` on expanded width. Never ship a phone bottom bar untouched on a tablet (see [adapt.md](adapt.md)).
- **System Back always works.** Honor the predictive Back gesture and Back button (`PopScope`, `onPopInvokedWithResult`); never trap the user or hijack the gesture. Enable predictive back in the manifest and use `PredictiveBackPageTransitionsBuilder` where supported.
- **Edge-to-edge with insets.** Apply status bar, navigation bar, display cutout, and keyboard insets (`SafeArea`, `MediaQuery.viewInsetsOf`) so content never hides behind system bars or the keyboard; keep system bar icon contrast right via `SystemUiOverlayStyle`.
- **`AppBar` / `SliverAppBar` for screen context**; pair with a `FloatingActionButton` when the screen has a single primary action.

## Touch targets and accessibility

- **48x48 dp minimum** for every tap target, with at least 8 dp between them (`kMinInteractiveDimension`).
- **TalkBack**: every interactive widget needs a clear label (`Semantics`, `tooltip`, `semanticLabel`), role, and state; logical traversal order; announce dynamic changes; group compound controls with `MergeSemantics`. Test with TalkBack on, and with a large font scale.
- Honor the system Remove animations setting via `MediaQuery.disableAnimationsOf(context)`.

## Typography

- **Material type scale.** Display, Headline, Title, Body, Label roles (large, medium, small each) via `Theme.of(context).textTheme`. Map text to roles; never hand-pick sizes per screen.
- **Roboto is the system face**; the brand face (Inknut Antiqua via `AppTheme`) is themed in through the type scale, keeping body, labels, and controls legible and consistent.
- **Scaled with the system font-size setting.** Text follows `MediaQuery.textScaler`; layouts must not clip or overlap at 1.3 to 2.0.

## Color and theming

- **Material 3 color roles** (`primary`, `onPrimary`, `surface`, `surfaceContainer*`, `secondaryContainer`, `outline`, `error`) from `ColorScheme`. Roles resolve light and dark and contrast variants; hardcoded `Color(0x...)` breaks there.
- **Dynamic Color (Material You)** where it fits: derive the scheme from the user's wallpaper on Android 12+ (for example `dynamic_color`), with a static fallback scheme.
- **Dark theme is a first-class scheme.** Design and test it; never a quick invert.
- **Tonal elevation.** Convey elevation through surface tint and `surfaceContainer` levels (plus shadow where appropriate); no arbitrary drop shadows.

## Components and motion

- **Material components.** Filled, tonal, outlined, and text buttons, FAB, `Switch`, chips, `SnackBar`, bottom sheets, Material dialogs, navigation bar/rail/drawer. Prefer the shared `App*` components that wrap them over raw widgets. Never port iOS controls or invent equivalents.
- **One FAB, one primary action.** Never stack FABs or spend one on a secondary task.
- **Snackbars for transient feedback** (with an action when useful; no toast-style overlays); dialogs only for decisions that must interrupt.
- **Material motion patterns.** Container transform, shared-axis, fade-through, with standard `Curves` and `Durations`; honor reduced motion with a crossfade or instant cut.

## Verifying the build

- **Screenshots come from the emulator or a connected device.** Run `flutter run -d <device>` and capture with `adb exec-out screencap -p > <path>` (pick a device with `adb -s <serial>` when several are attached). Capture every device class the app ships to: at least one phone and, when tablets are a target, one tablet.
- **Dark theme and font scale belong in the pass.** `adb shell cmd uimode night yes` flips the theme; `adb shell settings put system font_scale 1.3` (read the current values first with `adb shell cmd uimode night` and `adb shell settings get system font_scale`, and restore them after) catches the clipped labels a fixed layout hides. With several targets attached, pass `-s <serial>` to these too.
- **Goldens** (`flutter test`) at compact and expanded widths add repeatable layout evidence, but prove layout only.
- **Emulators give breadth; gestures, refresh rates, and performance need hardware.** Profile with `flutter run --profile`. Say which one produced the evidence.
