> **Additional context needed**: existing brand colors.

Introduce color as hierarchy, meaning, and atmosphere. Preserve confirmed brand and semantic conventions; do not replace a visual world under the guise of colorizing it.

---

## Product mode

- **Persuade + Experience:** color may carry the voice and own large regions when the selected world calls for it.
- **Operate + Read:** color primarily encodes action, selection, status, wayfinding, and reading hierarchy. Rarity gives an accent force.

## Audit before choosing

Read DESIGN.md directly if it exists (never invent it), plus `AppTheme`, `ColorScheme` definitions, assets, current light and dark themes, and representative states. Identify:

- which colors are confirmed brand commitments;
- current surface, text, action, and semantic roles;
- places where grayscale obscures hierarchy or state;
- contrast failures and color-only communication;
- light/dark or data-visualization requirements;
- whether the task asks for more color or a new identity.

If a new identity is required, use [new-work.md](new-work.md). Ask only when a binding brand decision cannot be inferred.

## Choose a strategy

Name the intended emotional temperature, dominant relationship, contrast range, and color dosage before editing. The strategy may be restrained or immersive; it must follow the brief and selected world rather than a fixed percentage rule.

Build roles, not a bag of swatches, as Material 3 `ColorScheme` roles:

- canvas and elevated surfaces (`surface`, `surfaceContainer*`);
- primary and secondary text (`onSurface`, `onSurfaceVariant`);
- action, focus, and selection (`primary`, `secondary`, `tertiary` and their containers);
- borders and separators (`outline`, `outlineVariant`);
- success, warning, error, and information (`error` plus a `ThemeExtension` for the rest);
- data categories or scales when needed (also a `ThemeExtension`).

Use the project's existing scheme generation (e.g. `ColorScheme.fromSeed`) and adjust the seed or specific roles rather than overriding colors in widgets. Choose hue from product meaning and visual direction, never from a default category association.

## Apply at system scale

- Let the strongest color own a deliberate region or role instead of scattering tiny accents.
- Keep the primary action easy to find; do not spend its color on decoration.
- Tint neutrals only when the brand hue genuinely creates cohesion. Neutral gray is valid when it serves the world.
- On colored surfaces, use the matching `on*` role rather than washed-out generic gray.
- Keep semantic meanings consistent, but respect platform and domain conventions instead of assuming fixed hues.
- For data, use distinct lightness, chroma, shape, label, or pattern so color is not the only code.
- In dark mode, design surface elevation and contrast explicitly; do not invert the light theme mechanically.
- Never hardcode `Color(0x...)` in widgets; read `Theme.of(context).colorScheme` or the theme extension. Theme changes should normally remap roles in one place.

Decoration without a relationship to hierarchy, state, content, or the visual world is not a color strategy.

## Contrast and perception

Verify computed foreground/background pairs:

| Content | WCAG AA minimum |
|---|---|
| body text | 4.5:1 |
| large text | 3:1 |
| controls, icons, focus indicators | 3:1 |

Do not rely on eyesight alone. Check interactive states, overlays, text on images, disabled content, and both themes. Simulate common vision deficiencies. Information conveyed by color also needs text, shape, iconography, or position.

When deriving tonal ramps, vary lightness and reduce chroma near white and black (Material's tonal palettes already do this; prefer them over hand-mixed values). Prefer explicit colors over chains of `withValues(alpha: ...)` overlays when alpha would make contrast context-dependent.

## Verify

- Every color has a stable role or a world-specific atmospheric purpose.
- Attention lands on the intended action, content, or state.
- The palette works across quiet, dense, interactive, error, and empty states.
- Light and dark themes are each composed, not mechanically inverted.
- Contrast and non-color cues pass in all relevant states.
- The result is recognizably this product, not a generic "colorful" treatment.

When the palette earns its place, hand off to `/impeccable polish` for the final pass.
