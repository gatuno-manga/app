# NOTICE

These skills are derived from [Impeccable](https://github.com/pbakaus/impeccable) by Paul Bakaus, licensed under the Apache License 2.0 (<https://www.apache.org/licenses/LICENSE-2.0>).

- Upstream version adapted: skill 4.8.0, engine v0.1.18 (npm `impeccable` 4.8.0), installed with `npx impeccable install --project --providers=gemini --no-hooks` on 2026-11-07.
- This is a modified version, adapted for native Flutter in gatuno-manga/app (issue #39). Files were changed; see below. Upstream copyright and license apply to the unmodified portions.

## Layout

One real copy lives in `.agents/skills/impeccable/`. `.claude/skills` and `.gemini/skills` are symlinks to `.agents/skills`.

## Changes from upstream

Re-apply upstream updates by running the install in a scratch directory and diffing against these files; do not run `npx impeccable update` in place (it would overwrite the Flutter adaptation).

**Removed (web-only or needs the upstream binary):**
- `scripts/` entirely: the `impeccable` CLI binary (context loader and the 62-rule slop detector for HTML/CSS), live-browser scripts, screenshot library, font index.
- `reference/live.md`, `live-setup.md`, `generate.md` (live browser variants), `hooks.md` (detector hook), `doctor.md`, `visualize.md`, `region-map.md`, `component-review.md` (image-generated comps), `craft.md` (deprecated alias), `degraded/`, `mode-persuade.md`, `mode-read.md`, `mode-operate.md` (needed `concept-seed`).
- Commands `live`, `generate`, `pin`, `hooks`, `doctor`.

**Replaced:**
- Slop detector -> `reference/flutter-checklist.md` plus stock lints in `analysis_options.yaml`. A custom_lint rule set is tracked in Refs gatuno-manga/app#41.
- `audit.native.md` and `adapt.native.md` merged into `audit.md` and `adapt.md`.

**Adapted to Flutter (every remaining file):** CSS/Tailwind tokens -> `ThemeData`/`ColorScheme`/`TextTheme`/`ThemeExtension`; DOM/ARIA -> widget tree and `Semantics`; breakpoints -> `MediaQuery`/`LayoutBuilder`; web performance -> frame build/raster times, `const`, `RepaintBoundary`; accessibility -> 48dp targets, text scaling, TalkBack/VoiceOver; motion -> implicit/explicit animations and `Hero`; Impeccable's levels -> Atomic Design mapping in `SKILL.md`.

**Added:** `NOTICE.md`, `reference/flutter-checklist.md`.
