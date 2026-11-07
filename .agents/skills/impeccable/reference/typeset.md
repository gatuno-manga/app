Typography carries information, hierarchy, and voice. Improve it inside the established visual world; do not replace the identity unless the user asked to.

---

## Product mode

- **Persuade + Experience:** display type may carry the voice. Use decisive contrast and scale when the composition benefits.
- **Operate + Read:** stability, scanability, and line length come first. A single well-tuned family and a fixed role scale are often right.
- **Platform:** follow [ios.md](ios.md) or [android.md](android.md), including platform text scaling and accessibility behavior.

The default family is Inknut Antiqua via `AppTheme`. If typography replacement would create a new identity, route through [new-work.md](new-work.md) and update DESIGN.md if it exists. Otherwise preserve confirmed families and improve their use.

## Two isolated assessments

When a sub-agent tool is available and permitted, run these independently; otherwise run them yourself in this order. Do not let analyzer findings anchor the design assessment.

1. **Typographic assessment:** inspect representative screens and styles. Answer every question below with a file, widget, or `TextTheme` role:
   - **Authority and fit:** Which faces, weights, and roles are established? Do they fit the product and selected world, or are they unexamined defaults? Is every family necessary?
   - **Hierarchy:** Can heading, body, label, metadata, and data roles be distinguished at a glance? Are adjacent sizes or weights too close to carry different jobs?
   - **Scale and consistency:** Is there a deliberate role scale (`TextTheme`), or a collection of arbitrary `TextStyle(fontSize: ...)` values? Do repeated roles stay identical across screens and states?
   - **Reading:** Does body copy stay within a comfortable 45-75 character line length? Are line height (`TextStyle.height`), paragraph rhythm, contrast, and letter spacing tuned to the actual face, width, language, and surface?
   - **Stress:** What happens with long headings, localization expansion (EN and PT), large text scale, narrow containers, missing weights, and font fallback?
   - **Delivery:** Are only used font assets and weights declared in `pubspec.yaml`? Does fallback avoid missing glyphs and disruptive reflow?
2. **Mechanical scan:** run `flutter analyze` and grep widgets for hardcoded `TextStyle(` with `fontSize`, `fontFamily`, or `fontWeight`; check against `flutter-checklist.md`. Also inspect dynamic values the grep cannot interpret. Synthesize both assessments before editing, noting what each caught alone. A clean scan is a floor, not proof of good typography.

## Set the system

Before editing, state:

- the roles the interface needs;
- the intended contrast between those roles;
- the line length and density;
- which existing faces and weights are authoritative;
- any performance, localization, or accessibility constraints.

Use the fewest roles and families that make the hierarchy unmistakable. Combine size, weight, space, and tone deliberately instead of asking size alone to do all the work. Roles live in `ThemeData.textTheme` (and a `ThemeExtension` for app-specific roles); widgets read `Theme.of(context).textTheme.bodyMedium` and adjust with `copyWith` only for tone, never to invent a new size.

## Apply

- Keep body copy comfortably readable and scalable. Use the Material 3 body roles (bodyLarge 16sp) as the ordinary body floor unless a dense role, platform convention, or user setting justifies otherwise.
- Keep prose in the 45-75 character range; constrain width with `ConstrainedBox` on tablets and desktop. Tune line height inversely with line length: wider lines generally need more leading.
- Compensate light text on dark surfaces on all three perceptual axes: slightly more line height, a touch more letter spacing, and one step more weight when the face needs it.
- Tune line height to the face, width, language, and contrast, not a universal ratio.
- Keep repeated roles consistent across screens and states.
- Use `FontFeature.tabularFigures()` for numbers that align and monospace for code when content benefits.
- Declare only used font assets and weights in `pubspec.yaml`.
- Let display type respond to available space when useful; keep dense and reading surfaces spatially predictable.
- Preserve user font settings and platform text scaling (`MediaQuery.textScaler`); never clamp it below what accessibility needs, and test layouts at 200% scale without overflow.
- Use paragraph spacing or first-line indentation as the primary paragraph rhythm; combining both usually double-marks the boundary.

Do not make type decorative at the expense of comprehension, or introduce a second family without a clear role it alone can perform.

## Line breaks

After Matthew Butterick's *Practical Typography*, paraphrased.

- Avoid lone last words (widows) in headings and short centered blocks by editing copy or adjusting width; check at every supported size class.
- In a column too narrow to help, edit the copy or widen the column.
- Break a heading by hand only between phrases, and check the break at every width the heading renders at. A hard break that lands mid-line on a phone is worse than the default wrap.
- An uneven break can carry meaning: a headline that lands on one word for weight, a poster line, a pull quote. Make it deliberate and keep it rare. Strings with deliberate breaks belong in the ARB file with that break explicit.
- Set `maxLines` with `TextOverflow.ellipsis` only where truncation is acceptable; never truncate essential content.

## Verify

- Primary, secondary, body, and metadata roles are recognizable without reading the copy.
- Long text remains comfortable across size classes and languages.
- The typography belongs to the product and its established world.
- Font loading does not create missing glyphs or disruptive reflow.
- Text scaling, focus, contrast, and tablet paths remain usable.
- No hardcoded text styles remain in widgets; the analyzer is clean.

Answer each item with rendered or source evidence, then rerun the checks. Do not substitute a bare "yes" for verification.

When the hierarchy holds, hand off to `/impeccable polish`.
