# Surface: Profile

Anchors a single app surface for `/impeccable critique` and related commands. Facts come from the Gatuno Figma file (page "04 · Telas Mobile (App)", file key `QlUrvomONqwfefHCwTg0Hh`) and the repo; nothing here is new design. Token keys refer to `.impeccable/design.json`.

## Route
- Figma: /users/:userId (mobile section 3 is empty)
- Code: `/settings/profile` (`lib/features/users`, `me_screen.dart`)

> Designed-but-empty section: Figma mobile section `859:36` has no frames.

## Figma frames
- None. No frame exists in Figma for this surface yet (see gap `figma-surfaces-empty`).

## Figma components used
- None drawn.

## Code
`lib/features/users/presentation/views/me_screen.dart`, components under `lib/features/users/presentation/components/{molecules,templates}`. Redirects to `/auth/signin` when unauthenticated.

## Tokens used
- Not designed. Use only the shared tokens in `design.json`.

## States in Figma
- None drawn.

## Accessibility
- Not audited.

## Gaps (Figma vs code)
- No Figma frame for profile (mobile section `859:36` is empty).
- Figma route `/users/:userId` (any user) differs from code `/settings/profile` (current user only).
