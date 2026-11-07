> **Additional context needed**: target platforms/devices and usage contexts.

Adapt an existing Flutter design to a different context: another device class, window size, orientation, platform, or use case. The trap is treating adaptation as scaling. The job is rethinking the experience for the new context, inside the platform conventions of [android.md](android.md) and [ios.md](ios.md); read the target platform's reference first.

---

## Assess Adaptation Challenge

1. **Source context**: what was it designed for, and what assumptions did it make? (Phone-only? Portrait-only? One platform's idioms? Touch only?)
2. **Target context**:
   - **Device**: phone, tablet, foldable, desktop window
   - **Input**: touch, stylus, mouse and trackpad, hardware keyboard
   - **Orientation and window size**: portrait, landscape, split-screen, resizable window
   - **Connection**: fast, slow, offline
   - **Usage posture**: one-handed on the go vs two-handed at rest, glance vs focused reading
3. **What breaks**: navigation that does not fit, layouts that stretch instead of restructure, gestures or controls that do not exist there.

Adaptation is rethinking the experience for the new context, not scaling logical pixels.

## Adaptation Strategies

Drive structure from **window size classes** (compact, medium, expanded) computed with `LayoutBuilder` or `MediaQuery.sizeOf(context)`, never from device-model checks. Keep one shared size-class helper rather than scattering magic widths across widgets.

### Phone (compact)

- Single column, vertical stacking, full-width components
- Bottom navigation bar (3-5 destinations); back via system Back / edge swipe
- Thumb-first: primary controls in the lower half; bottom sheets instead of dropdowns
- Progressive disclosure; primary content first, secondary behind tabs or expansion
- Tap targets 48x48dp minimum (44pt on iOS), with spacing
- Body text never below the theme's `bodyMedium`; honor `textScaler`

### Tablet and foldable (medium / expanded)

- **Restructure, don't stretch.** A scaled-up phone UI is the failure mode.
- Navigation changes shape: navigation bar becomes a `NavigationRail` (medium) or drawer/sidebar (expanded)
- Use the width: list-detail panes, two or three column grids, popovers or side sheets where phones used full-screen sheets
- Cap content width on very wide windows with `ConstrainedBox`/`Center`; do not stretch lines of text to full width
- Multitasking is a size, not an edge case: split-screen can hand a phone-width window to a tablet; size-class-driven layout handles it for free
- Foldables: react to posture and hinge via `MediaQuery.displayFeatures`; test folded, unfolded, and tabletop

### Orientation

Landscape restructures (side-by-side panes, repositioned controls); never clip or letterbox. Lock orientation only when the task truly demands it, never to dodge a layout bug.

### Desktop (optional target)

- Multi-column layouts, persistent side navigation, multiple panels at once
- Hover is an optional enhancement (tooltips, `InkWell` hover color via `WidgetState.hovered`), never required for function
- Hardware keyboard: `Shortcuts`/`Actions`, `FocusTraversalGroup`, visible focus states
- Context menus, drag and drop, multi-select where useful
- Show more information upfront (denser tables, richer detail) than on phones

### Platform to platform (iOS and Android)

Translate idioms; never transplant them. Prefer Flutter's adaptive widgets (`Switch.adaptive`, `showAdaptiveDialog`, `CupertinoPage` transitions via `PageTransitionsTheme`) where the platform difference is idiomatic.

| iOS | Android |
|---|---|
| Tab bar | Navigation bar / rail / drawer |
| Edge-swipe back, back chevron | Predictive Back gesture / button |
| Switch, segmented control, system pickers | Material switch, chips, Material pickers |
| Action sheet | Bottom sheet / Material dialog |
| SF Symbols, SF Pro, Dynamic Type | Material Symbols, Roboto, system font scale |
| Semantic system colors, materials | Material color roles, tonal elevation |
| System push/sheet transitions | Container transform, shared-axis, fade-through |

Rebuild navigation and controls in the target's vocabulary; carry the brand's expressive layer (palette intent, type accent, motion personality) through `ThemeData`.

## Implement Adaptations

- Reuse shared components (`AppButton`, `AppTextField`, `AppSkeleton`, `AppErrorView`, ...) and make them adaptive, rather than forking per-size copies. Layout differences belong in templates under `lib/features/<feature>/presentation/components/templates/`; the screen picks the template by size class.
- Respect `SafeArea` and `MediaQuery.viewInsetsOf` (keyboard) in every new configuration: notch, hinge, status bar, keyboard.
- Progressive enhancement: core content first, richer treatment as space grows. Avoid building widgets only to hide them; build lazily (`ListView.builder`, conditional widgets).
- Images: size to the displayed dimensions (`cacheWidth`/`cacheHeight`), not the largest asset.
- Touch feedback: ink ripples and pressed states (`InkWell`, `WidgetState.pressed`); thumb-reachable controls.
- Keep the information architecture the same across contexts; change presentation, not where things live.
- Add goldens at compact and expanded widths for adapted screens (`flutter test --update-goldens` when intended).

## Verify Adaptations

Emulators and `flutter run` give breadth; hardware gives truth. Test on:
- At least one phone and one tablet per shipped platform (a cheap Android phone reveals performance you will never see on an emulator)
- Portrait and landscape, split-screen where supported, a resizable desktop window if desktop is a target
- Touch, plus keyboard and mouse where relevant
- Smallest supported width (about 320dp) and very wide windows
- Text scale 1.5-2.0, light and dark themes
- Slow network and offline

**Custom controls** (sliders, drag surfaces, scrollable control strips): a before/after slider can pass every size check and still refuse to drag inside a scroll view, so exercise each one in scope:
- **Primary gesture**: tap it and confirm it responds, then drag it; the drag must complete, not just start
- **Scroll across it**: a swipe along the scroll axis across the control scrolls the parent without activating it; a drag starting on the control along its axis moves the control, not the parent. Neither failure throws an error, so try both
- **Evidence**: say what produced it (widget test with `tester.drag`, emulator, physical device). Goldens and screenshots verify layout, never a gesture. Name what stayed untested; unreachable hardware is a reported gap, not a blocker

When the adaptation feels native to each context, hand off to `/impeccable polish` for the final pass.

**Avoid**:
- Ship a stretched phone layout on a tablet
- Port one platform's controls or navigation onto the other
- Hide core functionality on smaller devices (if it matters, make it work)
- Lock orientation to dodge a layout bug
- Branch on device model instead of window size class
- Different information architecture across contexts
- Assume desktop means a powerful device, or ignore touch on desktop
- Trust emulators alone (posture, gestures, and performance need hardware)

---

## Reference Material

### Adaptive layout patterns

- **Size classes**: choose thresholds where the design actually breaks (start narrow, widen until it fails, add a class there). Two or three classes usually suffice; define them once in a shared helper.
- **Navigation**: three stages: bottom navigation bar on compact, `NavigationRail` on medium, full drawer or sidebar with labels on expanded.
- **Tables to cards**: on compact, render rows as stacked cards; on expanded, a real data table.
- **Fluid values**: scale spacing or type smoothly between a min and max with `lerpDouble` over the available width instead of hard steps, but keep text on `textTheme` roles.
- **Safe areas**: `SafeArea` for system insets; `MediaQuery.viewPaddingOf` for custom handling; `Scaffold` resizes for the keyboard by default, so verify long forms scroll.
- **Detect input, not just size**: a tablet may have a keyboard and a laptop a touchscreen. Branch on `MediaQuery`/`defaultTargetPlatform` and available pointers for density and hover affordances, never on size alone; never rely on hover for function.
