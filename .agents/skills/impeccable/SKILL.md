---
name: impeccable
description: "Use when the user wants to design, redesign, shape, critique, audit, polish, simplify, harden, animate, or otherwise improve a native Flutter screen or widget: product UI, components, forms, settings, onboarding, empty states, theming. Handles UX review, hierarchy, layout, typography, color, motion, UX copy, accessibility, adaptive layouts, edge cases, and documenting the design system (ThemeData tokens, DESIGN.md). Also for making bland UI bolder or loud UI quieter. Not for backend-only or non-UI tasks."
version: 4.8.0-flutter.1
---

This skill is Impeccable adapted for native Flutter (Material 3, Dart). Work as a design director who writes production Flutter: a clear point of view, deep grasp of the users, exceptional craft. See [NOTICE.md](NOTICE.md) for what changed from upstream.

Core principles:
- Finish the job. No hedging, no shortcuts.
- This app is an **Operate** surface (a tool people use to complete tasks, here reading manga). Scanability, consistency, platform expectations and the real usage scene outrank expression. Brand lives in precise details. See [reference/operate.md](reference/operate.md).
- Verify on the running app (`flutter run`, hot reload) or committed goldens, at phone and tablet widths, light and dark, and large text scale. Batch the checks.

## Setup

1. Read `PRODUCT.md` and `DESIGN.md` at the repo root if they exist. Never invent missing context; if PRODUCT.md is absent and the task is a new surface, offer [reference/init.md](reference/init.md) as an opt-in first step (never create PRODUCT.md or DESIGN.md unless the user chooses it). A narrow refinement of existing code can proceed on the incumbent implementation.
2. Read the target code and the theme (`lib/core/theme`, `ThemeData`, `ColorScheme`, `TextTheme`, `ThemeExtension`s) and reuse `lib/shared/components/` before creating widgets.
3. Load the request's playbook from the Commands table, or [reference/new-work.md](reference/new-work.md) for a new screen.
4. Before any UI edit, read [reference/craft-floor.md](reference/craft-floor.md). After editing, run `dart format`, `flutter analyze` and the relevant tests.

## Where things live (Atomic Design)

| Level | Reusable across features | Feature-specific |
|---|---|---|
| Atoms | `lib/shared/components/atoms/` | `lib/features/<f>/presentation/components/atoms/` |
| Molecules | `lib/shared/components/molecules/` | `.../components/molecules/` |
| Organisms | `lib/shared/components/organisms/` | `.../components/organisms/` |
| Templates | n/a | `lib/features/<f>/presentation/components/templates/` |
| Pages | n/a | `lib/features/<f>/presentation/views/*_screen.dart` |

Reuse shared components first. State lives in ViewModels (`presentation/view_models`), never in widgets. All strings go through the l10n ARB files (EN and PT).

## How to design

- **The brief wins.** Honor pinned aesthetics, fonts and palettes. Redirecting a clear brief toward your taste is failure.
- **Refinement preserves; redesign replaces.** Refinement keeps identity, behavior, copy and everything outside scope. Ask before replacing factual copy.
- **Tokens, not literals.** Colors, text styles, spacing and radii come from the theme, never inline.
- **Loaded symbols stay out of the decoration** (militarism, supremacy or hate-movement emblems as motifs).

## Commands

| Command | Category | Description | Reference |
|---|---|---|---|
| `shape [feature]` | Build | Plan UX/UI before writing code | [reference/shape.md](reference/shape.md) |
| `init` | Build | Capture durable product context in PRODUCT.md | [reference/init.md](reference/init.md) |
| `document` | Build | Generate DESIGN.md from the existing theme and code | [reference/document.md](reference/document.md) |
| `extract [target]` | Build | Pull reusable tokens and components into the design system | [reference/extract.md](reference/extract.md) |
| `critique [target]` | Evaluate | UX design review with heuristic scoring | [reference/critique.md](reference/critique.md) |
| `audit [target]` | Evaluate | Technical quality: accessibility, performance, adaptivity | [reference/audit.md](reference/audit.md) |
| `polish [target]` | Refine | Final quality pass before shipping | [reference/polish.md](reference/polish.md) |
| `bolder [target]` | Refine | Amplify safe or bland designs | [reference/bolder.md](reference/bolder.md) |
| `quieter [target]` | Refine | Tone down aggressive or overstimulating designs | [reference/quieter.md](reference/quieter.md) |
| `distill [target]` | Refine | Strip to essence, remove complexity | [reference/distill.md](reference/distill.md) |
| `harden [target]` | Refine | Production-ready: errors, i18n, edge cases | [reference/harden.md](reference/harden.md) |
| `onboard [target]` | Refine | First-run flows, empty states, activation | [reference/onboard.md](reference/onboard.md) |
| `animate [target]` | Enhance | Purposeful implicit/explicit animation and motion | [reference/animate.md](reference/animate.md) |
| `colorize [target]` | Enhance | Strategic color via ColorScheme | [reference/colorize.md](reference/colorize.md) |
| `typeset [target]` | Enhance | Typography hierarchy via TextTheme | [reference/typeset.md](reference/typeset.md) |
| `layout [target]` | Enhance | Spacing, rhythm and visual hierarchy | [reference/layout.md](reference/layout.md) |
| `delight [target]` | Enhance | Personality and memorable touches | [reference/delight.md](reference/delight.md) |
| `overdrive [target]` | Enhance | Push past conventional limits | [reference/overdrive.md](reference/overdrive.md) |
| `clarify [target]` | Fix | Improve UX copy, labels and error messages | [reference/clarify.md](reference/clarify.md) |
| `adapt [target]` | Fix | Adapt to phone, tablet, desktop and platforms | [reference/adapt.md](reference/adapt.md) |
| `optimize [target]` | Fix | Diagnose and fix frame build/raster performance | [reference/optimize.md](reference/optimize.md) |

Platform notes: [reference/android.md](reference/android.md), [reference/ios.md](reference/ios.md). Static checks: [reference/flutter-checklist.md](reference/flutter-checklist.md).

Routing:

- **No argument:** read [routing.md](reference/routing.md) and present its menu; never auto-run a command.
- **Explicit or clearly implied command:** load its reference and follow it. Ask once if two commands fit.
- **Otherwise:** treat as general design work.

## Not supported (dropped from upstream)

`live`, `generate`, `hooks`, `doctor`, `pin`, the `impeccable` CLI binary and its detector, image-generated comps and region maps, and the Persuade/Read/Experience modes. They need a browser, HTML or an external binary. Flutter replacement for the detector: [reference/flutter-checklist.md](reference/flutter-checklist.md) plus `flutter analyze`; a custom_lint rule set is tracked in Refs gatuno-manga/app#41.

Invocation: commands are written `/impeccable <command> [target]` and in the table as `<command> [target]`; both mean the same thing. In Claude Code, say "run impeccable critique on books_screen.dart".
