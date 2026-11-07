# Surface: Settings

Anchors a single app surface for `/impeccable critique` and related commands. Facts come from the Gatuno Figma file (page "04 · Telas Mobile (App)", file key `QlUrvomONqwfefHCwTg0Hh`) and the repo; nothing here is new design. Token keys refer to `.impeccable/design.json`.

## Route
- Figma: /user (mobile section 5 and web section 4 are empty)
- Code: `/settings` (`lib/features/settings`), certificates under `/settings/certificates`

> Designed-but-empty section: Figma mobile section `859:38` and web section `859:28` have no frames.

## Figma frames
- None. No frame exists in Figma for this surface yet (see gap `figma-surfaces-empty`).

## Figma components used
- None drawn.

## Code
`lib/features/settings/presentation/views/settings_screen.dart`, components under `presentation/components/{molecules,organisms,templates}`; certificates in `lib/features/certificates`.

## Tokens used
- Not designed. Use only the shared tokens in `design.json`.

## States in Figma
- None drawn.

## Accessibility
- Not audited.

## Gaps (Figma vs code)
- No Figma frame for settings; Figma route `/user` differs from code `/settings`.
- Code settings include API URL, sensitive-content toggle and certificates; none appear in Figma.
