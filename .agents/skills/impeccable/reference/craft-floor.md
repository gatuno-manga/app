# Craft floor

Load this after the direction is settled, and build without announcing the checklist. A confirmed brief or the committed visual world (DESIGN.md, when it exists) overrides anything here except a line marked as a ban; your own habit does not. Run `flutter analyze` as you go, and see [flutter-checklist.md](flutter-checklist.md) for the mechanical anti-pattern list.

## Verify

Each of these is a check on the built result, not an intention. Check them together in one look at the running app (`flutter run`, hot reload, a device or emulator, or a golden test), not as separate trips.

- **Tokens:** every color, text style, radius, and spacing value comes from `Theme.of(context)` (`colorScheme`, `textTheme`, a `ThemeExtension`). No hardcoded `Color(0x...)` or `TextStyle(fontSize: ...)` in widgets.
- **Contrast:** body and placeholder text at least 4.5:1, large text at least 3:1, in light and dark. On colored surfaces, tint secondary text from that hue or the `on*` role; never plain gray.
- **Depth:** prefer tonal surfaces (`surfaceContainer*`) over heavy shadows. A shadow carries an offset and a soft blur; a zero-offset colored halo is decoration.
- **Spacing:** tight groups, generous separation, more space above a heading than below it. Use a consistent scale, not ad hoc values.
- **Type:** readable line length on tablets and desktop (cap prose width around 65-75 characters), obvious scale and weight steps, balanced headings. Run real copy (EN and PT; PT runs longer) at the largest text scale (`MediaQuery.textScaler`) and fix any overflow.
- **Motion:** one authored moment, not scattered effects or the same entrance on every item. Use ease-out curves from an already-visible default. Honor `MediaQuery.disableAnimationsOf(context)`.
- **States:** pressed, focused, disabled, loading (skeleton), error (AppErrorView or equivalent), empty, plus real content, working controls, adaptive layout across window size classes, and keyboard/screen-reader focus order.
- **Touch and semantics:** tap targets at least 48dp; icon-only controls have a Tooltip or Semantics label; decorative images are excluded from semantics.
- **System surfaces:** the parts you did not draw still carry the design: status bar and navigation bar styling, text selection handles and cursor color, scroll physics and overscroll, focus indication, tabular figures for numeric data. Theme them from the palette.
- **Copy:** the product's own language, through l10n ARB keys (feature-prefixed, EN and PT). Controls name their action; errors name the problem and the recovery.
- **Coverage:** every brief requirement present and findable within seconds.

## Refuse

These are the category's defaults, not bans: the brief's own words can earn any of them. Reaching for one when the axis is free means you were not deciding; rewrite the element rather than softening it.

Screen scaffolds:

- Same-size cards of icon plus heading plus text as the screen structure. Cards are the lazy container; nested cards are always wrong.
- The hero-metric template: big number, small label, supporting stats, accent.
- A kicker or eyebrow above a heading. This one is a ban: delete the label and let the heading carry its own weight.
- Section numbers (01 / 02 / 03) unless the sequence itself carries information.
- A modal dialog for a task that needs neither interruption nor protected focus; prefer inline or a bottom sheet.

Surface habits:

- Gradient text (ShaderMask on text). Emphasis comes from weight or size.
- Glass and blur (BackdropFilter) as decoration rather than as a specific, purposeful effect.
- A colored stripe wider than 1dp on one side of cards, list tiles, or banners.
- Hard offset shadows with zero blur outside a world that is actually neobrutalist.
- Sparklines, progress rings, and soft-shadowed rounded rectangles standing in for content.
- Monospace as a costume for "technical" rather than for code, data, or measurement.
- The platform default font as the display voice of a screen with its own identity. The app default is Inknut Antiqua via AppTheme; read it from the theme, do not override per widget.
- Emoji or Unicode glyphs standing in for an icon system. Use one icon set at one consistent size and weight.
- Light or dark picked by category. Pick it from the use scene: who, where, under what ambient light. Both themes must work.

The floor holds the mechanics; it never picks the direction. With every check green, spend the screen on the committed world, and when torn between refined and committed, commit.
