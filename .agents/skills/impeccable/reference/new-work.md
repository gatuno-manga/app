# New visual work

Use this flow for a new screen or a replacement visual identity in this Flutter app. PRODUCT.md (when it exists) owns product truth. DESIGN.md (when it exists) owns durable visual decisions. The theme code in `lib/core/theme` is the implemented authority. There is no context CLI and no image generation step: read the files directly, and build in code. Complete [init.md](init.md) first when PRODUCT.md is missing; a missing DESIGN.md does not route back to init.

## 1. Decide what is already true

Read DESIGN.md (if present), `lib/core/theme`, shared components, and a representative screen in the nearest feature.

- **Redesign:** preserve product truth, content, function, constraints, and explicit brand commitments; replace the old visual world rather than polishing it.
- **Established world:** inherit it. A missing DESIGN.md does not erase a coherent identity already in the theme; record it with [document.md](document.md) instead of inventing a replacement.
- **Incomplete brand:** preserve confirmed assets and recognizable traits, then expand the system with the user for this screen.
- **No visual authority:** create a new world with the user.

A section, component, feature, or state inside an established screen inherits that screen. Never turn a local addition into a new identity exercise.

## 2. Ask what will change the work

Before implementation, get the user's answer through the structured question tool when available. Ask two or three related questions; a precise request needs only a compact confirmation. DESIGN.md settles the visual world, not this screen's purpose or structure.

- **Persuade** (onboarding, welcome, empty states, paywalls): who must act, what they should believe, which real proof earns it.
- **Operate** (lists, forms, settings, tools): the task, information, key states, frequency, constraints.
- **Read** (a reader, long text, help): the reader's question, source material, structure, wayfinding.
- **Experience:** what leads, how exploration unfolds, which interaction or transition matters.

Across modes ask what success looks like, what must stay untouched, and what would make a polished result feel wrong. Never ask for raw color or size values or canned aesthetic lanes.

## 3. Choose the right amount of invention

### Extend an existing screen

Inherit its world and composition. Resolve only the new purpose, content, hierarchy, states, interaction, and how the addition joins its surroundings. No concept tournament, and no DESIGN.md change unless the user approves a durable system change.

### Create a whole screen inside an established world

Keep the visual system fixed. Derive three to five materially different structures from the content, task, and user behavior (for example list-detail versus stepped flow versus a single focused action), and name which you recommend and why. Present them as short written options, let the user pick one, and proceed. Every option must vary composition, not identity.

### Create or replace the visual world

1. Name the product's unique mechanism in one sentence, the audience's real scene (where, one hand or two, what light), its cultural home, and what this first screen must prove. Note the screen this category always ships and its predictable opposite; both are the rut.
2. From that cultural world, list five to seven concrete visual systems, artifacts, places, or rituals the audience knows by heart, each with one line on why it can carry the mechanism and one on how it looks (ground and main colors, type voice, the one signature that makes it recognizable). Include graphic and screen traditions (publications, identity programs, notation), not only physical objects. On Operate and Read screens do not hand the audience's own tools back to them as a costume.
3. Turn that material into two or three complete directions, each joining a reusable visual world to a concrete first-screen experience. Each must be viable: every claim it visualizes true, a real palette and component family, workable within available assets and performance.
4. Present the directions to the user with a clear recommendation, plus one quiet standing alternative: the category standard, played straight. Never recommend it or let it soften the others; when the user picks it, execute it at full fidelity and record the preference as a brand commitment in PRODUCT.md.
5. The user chooses. Re-offer only on named factual grounds, and after two rejected rounds ask what quality is missing.

Truth binds claims, not demonstrations. In greenfield work, author illustrative content (titles, names, sample data) at full fidelity, label it synthetic where it could be mistaken for real, and hand the user the list of what to replace. Commercial and factual claims (prices, customers, endpoints, capabilities the product lacks) are never invented.

## 4. Commit the world

Pick a color strategy before picking colors: Restrained (tinted neutrals plus one accent; the usual choice on screens people operate or read), Committed (one saturated color carries 30-60% of the screen), Full palette (3-4 named roles), or Drenched (the screen is the color). Persuade and Experience screens may take the bolder strategies. Express the strategy through `ColorScheme` roles and ThemeExtensions, not scattered constants. Dark or light is never a default: write one sentence of physical scene and let it force the answer, then make both themes work.

Choose type from the subject's world, in the screen's register. The app default (Inknut Antiqua via AppTheme) is the established voice; change or add faces only with a reason and a theme-level change, never per widget. On Operate and Read screens a workhorse face is often right. The training-data defaults mean you stopped looking: Fraunces, Playfair Display, Cormorant, Lora, Crimson, Newsreader, Syne, Space Grotesk, Space Mono, IBM Plex, Inter-as-display, DM Sans, DM Serif, Outfit, Plus Jakarta Sans, Instrument Sans.

Calibration: AI-generated interfaces cluster around a few looks regardless of subject: warm cream ground with a high-contrast serif and terracotta accent; near-black with one neon accent and glowing edges; editorial hairlines with italic display serif and tiny tracked labels; flat saturated ink with black boxes and hard offset shadows. All are legitimate when the brief calls for them. Where the brief leaves the aesthetic free, landing in one means the self-check failed: if someone could guess your aesthetic from the category alone, rework until neither answer is obvious.

Shape, depth, and motion come from the same world: corner radii, tonal versus shadowed depth, and one authored motion moment. Decide them once, in the theme.

## 5. Record the decision

Before code, summarize the chosen direction in the brief or in your reply, in six short blocks (roughly 150 words): THESIS (the one idea this screen owns and the default arrangement it refuses), OWN-WORLD (palette roles, type, component language), FIRST VIEW (what the user sees in the first screenful on a phone and how it demonstrates the mechanism), SIGNATURE (one memorable interaction or moment), STATES (empty, loading, error, offline, extreme content), RISK (what could go wrong). Keep it out of source files and comments.

A new world is written to DESIGN.md at the finish, from the built theme, via [document.md](document.md) and with the user's approval; a rulebook written before the build gets defended against reality instead of describing it. An ordinary extension does not rewrite DESIGN.md.

For `shape`, return the selected direction to [shape.md](shape.md) and stop before implementation.

## 6. Place and build

Build the chosen direction, not a safer interpretation. The form supplies structure and reading order; the product supplies every fact. Land the first build fully committed; later passes make the committed thing clear, never diluted.

### Atomic Design placement

Decide the level of every piece before writing it.

| Level | Reusable across features | Feature-specific |
| --- | --- | --- |
| Atoms (button, field, badge, skeleton) | `lib/shared/components/atoms/` | `lib/features/<feature>/presentation/components/atoms/` |
| Molecules (atoms working together) | `lib/shared/components/molecules/` | `lib/features/<feature>/presentation/components/molecules/` |
| Organisms (self-contained sections) | `lib/shared/components/organisms/` | `lib/features/<feature>/presentation/components/organisms/` |
| Templates (page layout skeletons) | n/a | `lib/features/<feature>/presentation/components/templates/` |
| Pages | n/a | `lib/features/<feature>/presentation/views/*_screen.dart` |

Rules:

- **Reuse first.** Check `lib/shared/components` (AppButton, AppTextField, AppSkeleton, AppErrorView, AppStatusBadge, AppBottomNavBar, ...) before creating anything. Extend an existing component with a variant before adding a near-duplicate.
- **Promote on second use.** A feature component needed by another feature moves to shared.
- **State lives in ViewModels** (`presentation/view_models`), not in widgets. Components are presentational and take data and callbacks.
- **All strings through l10n ARB** (`lib/l10n`, EN and PT, feature-prefixed keys). No literals in widgets.
- **Style from the theme only:** `Theme.of(context).colorScheme`, `textTheme`, and ThemeExtensions. A new token goes into the theme, not into the widget.
- Use `const` constructors, lazy lists (`ListView.builder`), and keep `setState` scope small.

### Build order

1. Theme changes first, if the world needs new tokens (`ColorScheme`, `TextTheme`, a ThemeExtension field with `copyWith` and `lerp`, both light and dark).
2. New atoms and molecules, each with its states.
3. Organisms and the template.
4. The screen and its ViewModel wiring; handle loading (skeleton), empty, error (AppErrorView), offline.
5. Adaptive layout across window size classes (`LayoutBuilder` or `MediaQuery`, `SafeArea`), then the one motion moment (implicit or explicit animations, `Hero`, honoring `MediaQuery.disableAnimationsOf(context)`).
6. Localization and semantics pass.

### Principles for every build

- **The first screenful is a thesis, not a header.** Demonstrate the mechanism immediately, at the scale it has in life. Memory test: if someone left after one screen, what would they describe an hour later? If the honest answer is a mood, the concept has not committed.
- **Prove, do not claim.** Show the subject doing its job; use specifics a competitor could not copy-paste.
- **Author the content; never substitute decoration.** Real-feeling titles, names, entries, covers, and copy beat gradients, generic icon tiles, and placeholder boxes.
- **Pace the scroll like a studio.** Vary density, scale, and quiet inside one grammar; one spacing rhythm, more space above a heading than below it.
- **Author motion as material.** One orchestrated moment rather than scattered effects; keep content visible by default.
- Follow [craft-floor.md](craft-floor.md), and [operate.md](operate.md) for task screens. Preserve semantics, accessibility, performance, project conventions, and working behavior.

## 7. Inspect and finish

1. Run `flutter analyze` and fix what is mechanical; run existing tests, and add a widget or golden test for new components when the project has them.
2. Run the app (`flutter run`, hot reload) on the shipped device classes: a small phone, a large phone, and a tablet or desktop window when supported; light and dark; largest text scale; EN and PT. Drive every reachable state (loading, empty, error, offline, long content, pressed, focused). Settle or disable entrance motion before judging a capture, and confirm each screenshot shows what it claims.
3. Check against [flutter-checklist.md](flutter-checklist.md) and the brief: every requirement present and findable within seconds.
4. After two inspection rounds stop polishing; report what remains rather than hunting more defects.
5. For a new or replaced world, offer to record it with [document.md](document.md). Report the final status at its actual scope: do not claim "no issues remain" when only a fix list was checked, and list any synthetic content the user must replace.
