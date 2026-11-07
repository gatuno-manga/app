# Operate depth

When design SERVES the product: app screens, settings, lists and tables, tools, any place where the user is in a task. The essentials sit in SKILL.md and [craft-floor.md](craft-floor.md); this file is extended depth for Operate screens.

## The product slop test

Familiarity is often a feature here. The test is whether a category-fluent user can trust the interface immediately or must pause at every subtly-off component.

Product UI's failure mode is not flatness, it is strangeness without purpose: over-decorated buttons, mismatched form controls, gratuitous motion, display fonts where labels belong, invented affordances for standard tasks. The bar is earned familiarity. The tool should disappear into the task.

## Typography

- **One family is often right.** Product UIs rarely need display/body pairing. Read the family from `TextTheme`; the app default comes from AppTheme. The app default (Inknut Antiqua, set in AppTheme) is a pinned brand choice: do not flag it.
- **Fixed scale, not fluid.** Use the `TextTheme` roles (`titleMedium`, `bodyMedium`, `labelLarge`, ...) rather than sizes computed from screen width. Always respect the user's text scale.
- **Tighter scale ratio.** About 1.125-1.2 between steps. Exaggerated contrast creates noise in dense screens.
- **Line length still applies for prose** (65-75 characters) on tablet and desktop. Data and compact UI can run denser.

## Color

Product defaults to Restrained. A single screen can earn Committed (a dashboard where one category color carries a report), but Restrained is the floor.

- State-rich semantic vocabulary from `ColorScheme` and ThemeExtensions: pressed, focused, disabled, selected, loading, error, warning, success, info. Standardize these.
- Accent color for primary actions, current selection, and state indicators, not decoration.
- A second neutral layer (`surfaceContainer*`) for navigation, app bars, and panels.

## Layout

- Adaptive behavior is structural: bottom navigation on phones, navigation rail on tablets and desktop, one pane versus two panes, driven by `MediaQuery` or `LayoutBuilder` size classes, not fluid type.
- Respect `SafeArea`, keyboard insets, and system gesture areas.

## Components

Every interactive component has: default, pressed, focused, disabled, loading, error. Do not ship half of these.

- Skeleton states for loading (AppSkeleton), not spinners in the middle of content.
- Empty states that teach the interface, not "nothing here". Error states use AppErrorView with a recovery action.
- Consistent affordances across the app: same button shape, same form-control vocabulary, same icon style. Reuse shared components before creating new ones.
- Prefer inline and progressive alternatives to dialogs; when an overlay is right, use a bottom sheet or the platform dialog.

## Motion

- 150-250 ms on most transitions. Users are in flow; do not make them wait for choreography.
- Motion conveys state, not decoration: state change, feedback, loading, reveal.
- No orchestrated screen-load sequences. The app loads into a task.
- Honor `MediaQuery.disableAnimationsOf(context)`.

## Product constraints

- Decorative motion that does not convey state.
- Inconsistent component vocabulary across screens. If the "save" button looks different in two places, one is wrong.
- Display fonts in labels, buttons, and data.
- Reinventing standard affordances for flavor (custom scroll physics, odd form controls, non-standard dialogs, broken back gestures).
- Heavy color or full-saturation accents on inactive states.
- Dialog as first thought. Exhaust inline alternatives first.

## Product permissions

Product can afford things expressive surfaces cannot.

- Familiar platform patterns: app bar plus bottom navigation, tabs, search, swipe actions, pull to refresh.
- Density. Long lists, many labels, dense information when users need it, while keeping 48dp tap targets.
- Consistency over surprise. The same visual vocabulary screen to screen is a virtue; delight is saved for moments, not whole screens.
