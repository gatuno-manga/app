# Surface: Auth

Anchors a single app surface for `/impeccable critique` and related commands. Facts come from the Gatuno Figma file (page "04 · Telas Mobile (App)", file key `QlUrvomONqwfefHCwTg0Hh`) and the repo; nothing here is new design. Token keys refer to `.impeccable/design.json`.

## Route
- Figma: /auth/login, /auth/register (mobile section 4 and web section 3 are empty)
- Code: `/auth/signin`, `/auth/signup` (`lib/features/authentication`); also `/welcome` (API URL setup)

> Designed-but-empty section: Figma mobile section `859:37` and web section `859:27` have no frames.

## Figma frames
- None. No frame exists in Figma for this surface yet (see gap `figma-surfaces-empty`).

## Figma components used
- None drawn.

## Code
`lib/features/authentication/presentation/views/{signin_screen,signup_screen}.dart`, templates and organisms under `presentation/components`; shared `app_text_field.dart`, `app_button.dart`. Welcome: `lib/features/welcome/presentation/views/welcome_screen.dart`.

## Tokens used
- Not designed. Use only the shared tokens in `design.json` (inputs and buttons: `color/border`, `color/primary`, `color/on-primary`, `color/danger`, `Interface/Botão`, `Interface/Rótulo`, `radius/md`).

## States in Figma
- None drawn.

## Accessibility
- Code supports password-manager autofill (autofillHints) and a 'go back' action to `/home`; preserve both.
- Password rules: 8+ characters, uppercase, digit, symbol.

## Gaps (Figma vs code)
- No Figma frames for login, register or welcome; Figma uses `/auth/login` and `/auth/register`, code uses `/auth/signin` and `/auth/signup`.
- Input and error states are not drawn.
