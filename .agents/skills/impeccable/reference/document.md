# Document

Describe how to write a `DESIGN.md` at the repo root that captures the current visual design system of this Flutter app, so agents building new screens stay on-brand. This file only describes the process: do not create DESIGN.md while merely reading it, and never invent one from memory. Write it only when the user asked for `document` (or approved it at the end of new-work).

The source of truth for tokens is code: `ThemeData`, `ColorScheme` (Material 3), `TextTheme`, and `ThemeExtension` classes, normally under `lib/core/theme` (here `lib/core/theme/theme.dart`: `AppColors` palette, `AppTheme.lightTheme` / `darkTheme`, and extensions such as `GatunoColors`). **The theme code is normative; DESIGN.md prose explains how to apply it.** Never restate a color value in prose with a different value than the code holds.

## When to run

- New-work found a coherent incumbent visual system but no DESIGN.md.
- The first implementation of a new world is done and its provisional decisions need recording.
- An existing DESIGN.md is stale (the design drifted).
- Before a large redesign, to capture the current state.

If a DESIGN.md exists, do not silently overwrite it. Show it, then ask the user: refresh, overwrite, or merge.

## Two paths

- **Scan mode** (default): the project has theme code, shared components, or screens. Extract, then confirm descriptive language.
- **Seed mode**: pre-implementation. Ensure PRODUCT.md exists (load [init.md](init.md) if not), run new-work's world workshop with the user, and write a directional DESIGN.md seed. Do not offer seed mode when a coherent incumbent theme exists; offer scan mode.

Decide by scanning first. If there is no theme and no components, offer seed mode; do not switch silently.

## Scan mode

### Step 1: Find the design assets

In priority order:

1. **Theme files:** `lib/core/theme/*` (`ThemeData`, `ColorScheme` construction, `ColorScheme.fromSeed` seed and overrides, `TextTheme`, component themes such as `ElevatedButtonThemeData`, `InputDecorationTheme`, `CardTheme`).
2. **ThemeExtensions:** custom semantic tokens (status colors, badge colors, overlays, gradients, spacing). Record `copyWith` / `lerp` coverage and whether light and dark both define them.
3. **Palette classes:** raw `Color` constants (like `AppColors`). Note which are mapped into the scheme and which are only used directly, since direct use is drift to flag.
4. **Fonts and assets:** `pubspec.yaml` font families and weights (default is Inknut Antiqua), icon set, image assets.
5. **Shared components:** `lib/shared/components/{atoms,molecules,organisms}` (AppButton, AppTextField, AppSkeleton, AppErrorView, ...). Note variant APIs and default styles.
6. **Feature components and screens:** representative ones under `lib/features/<feature>/presentation/components` and `views`.
7. **Running app:** if useful, screenshots from `flutter run` or golden tests catch values the theme does not show.

### Step 2: Auto-extract

For each token class:

- **Colors:** group by Material roles (primary, secondary, tertiary, error, surface and containers, outline) plus the ThemeExtension semantic colors. If the project has one accent, document Primary plus Neutral and omit the rest rather than inventing roles. Note light versus dark.
- **Typography:** map `TextTheme` roles (display, headline, title, body, label) to observed families, sizes (in logical pixels, dp), weights, and line heights; note scale ratio and the default font.
- **Elevation:** list the elevation vocabulary (Material surface tint, tonal containers, explicit shadows). Flat and tonal is a valid answer; state it.
- **Shapes:** corner radii (`BorderRadius`, `shape` in component themes), borders, clipping.
- **Layout and spacing:** spacing scale, screen padding, `SafeArea` use, density, adaptive behavior (phone, tablet, desktop size classes).
- **Components:** for each common component, shape, color roles used, pressed/focused/disabled treatment, internal padding.
- **Motion:** durations and curves actually used.

Skip anything the project does not have. Do not extract every value; stop at what is reused, since one-offs pollute the system.

### Step 3: Ask for qualitative language

These need creative input. Ask in at most two structured rounds of up to three questions, waiting between rounds:

- **Creative North Star:** one named metaphor for the whole system. Offer 2-3 options that honor PRODUCT.md's brand personality.
- **Overview voice:** mood adjectives, a 2-3 sentence philosophy, any confirmed visual anti-reference.
- **Color character:** descriptive names for the key colors ("Deep Muted Plum", not "lilac"). Suggest 2-3 options per key color.
- **Elevation philosophy:** flat, layered, or lifted; ambient or structural shadows.
- **Component philosophy:** the feel of buttons, cards, and inputs in one phrase.

Carry a line from PRODUCT.md only when it is a durable brand commitment that constrains the visual system.

### Step 4: Write DESIGN.md

Optional frontmatter names the project and maps the key Flutter tokens, then eight sections in this fixed order. Omit irrelevant sections; do not rename them.

```markdown
---
name: [Project Title]
description: [one-line tagline]
theme:
  source: lib/core/theme/theme.dart
  seed: "[seed color token, e.g. AppColors.lilac]"
  fontFamily: "[default family]"
  extensions: [GatunoColors]
---

# Design System: [Project Title]

## Overview
**Creative North Star: "[Named metaphor]"**
[2-3 paragraphs: personality, density, philosophy. State only confirmed visual rejections. End with a **Key Characteristics:** bullet list.]

## Colors
[One sentence on palette character.]
### Primary / Secondary / Tertiary / Neutral
- **[Descriptive Name]** (`colorScheme.primary`, #HEX): [where and why it is used]
### Semantic (ThemeExtension)
- **[Name]** (`GatunoColors.x`): [role]
### Named Rules (optional)
**The [Rule Name] Rule.** [Short doctrine, e.g. accent used on 10% or less of any screen.]

## Typography
**Default Font:** [Family] via AppTheme. **Character:** [1-2 sentences.]
### Hierarchy
- **Headline** (`textTheme.headlineSmall`, [weight], [size]dp, [line height]): [purpose]
- **Title / Body / Label:** [same pattern]

## Layout
[Spacing scale, screen padding, density, phone/tablet/desktop adaptation, SafeArea. Exact values only when observed.]

## Elevation & Depth
[Shadows, tonal layering, or hybrid; say "no shadows" explicitly when true.]

## Shapes
[Corner radius strategy, borders, clipping, recurring silhouettes.]

## Components
For each: character line, shape, color roles, states (pressed, focused, disabled, loading, error), distinctive behavior. Name the file (for example `lib/shared/components/atoms/app_button.dart`).
### Buttons / Inputs / Cards / Navigation / [Signature Component]

## Do's and Don'ts
### Do
- **Do** [prescription grounded in the incumbent system].
### Don't
- **Don't** [prohibition confirmed by the system or the user].
```

### Step 5: Confirm and refine

Show the user the full file and highlight the non-obvious creative choices (names, rules). Offer to revise a section or add components you missed. Also report theme drift you found (hardcoded colors in widgets, tokens defined but unused) as follow-ups for `extract` or `audit`; do not fix them as part of documenting.

## Seed mode

For projects with no visual system yet. Produces a user-chosen scaffold, not fabricated tokens.

1. PRODUCT.md is the prerequisite; if missing, complete [init.md](init.md) first.
2. Load [new-work.md](new-work.md), resolve the first screen to design, run its **Create or replace the visual world** flow with the user, and stop after the directional seed. Do not implement.
3. Write DESIGN.md with the canonical sections, opening with this marker: `<!-- SEED: established with the user before implementation; re-run /impeccable document once there is code to capture actual tokens and components. -->`
4. Frontmatter carries only `name` and `description`. Leave unresolved values as `[to be resolved during implementation]`. Omit Components.
5. Tell the user to re-run `document` once the theme exists.

## Style guidelines

- **Code first, prose second.** Do not redefine a token value in two places.
- **Descriptive over technical:** "Gently curved edges (12dp radius)" beats "BorderRadius.circular(12)". Lead with the description, put the exact value in parentheses.
- **Functional over decorative:** for each token say where and why it is used, and which `ColorScheme` role or extension field it maps to.
- **Use Named Rules:** `**The [Name] Rule.** [short doctrine]`; aim for 1-3 per section.
- **Be decisive where evidence is decisive,** softer where guidance is provisional. Use a concrete test only when grounded in the observed system.
- **Group colors by role,** not hex order or hue order.
- **Do not duplicate PRODUCT.md.** DESIGN.md is strictly visual.

## Pitfalls

- Do not paste raw widget code; translate to descriptive language.
- Do not invent components that do not exist.
- Do not overwrite an existing DESIGN.md without asking.
- Do not rename canonical sections.
- Do not promote a single screen's composition into a global rule.
