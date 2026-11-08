# Surface: Auth

Anchors a single app surface for `/impeccable critique` and related commands. Facts come from the Gatuno Figma file (page "04 · Telas Mobile (App)", file key `QlUrvomONqwfefHCwTg0Hh`) and the repo; frames were drawn in issue #52 from the existing mobile frames, using only existing components and tokens (Dark theme only). Token keys refer to `.impeccable/design.json`.

## Route
- Figma: /auth/login, /auth/register (mobile section `859:37`, "4 · Autenticação")
- Code: `/auth/signin`, `/auth/signup` (`lib/features/authentication`); also `/welcome` (API URL setup, no frame)

## Figma frames
- `954:2559` /auth/signin — mobile
- `954:2602` /auth/signin — mobile · erro (validation messages)
- `954:2641` /auth/signin — mobile · carregando (disabled action with loader)
- `954:2688` /auth/signup — mobile

## Figma components used
- `Marca/Logo`
- `Campo/Texto` (new local component, `951:869`; Estado=Padrão / Foco / Erro) → `lib/shared/components/atoms/app_text_field.dart`
- `Botão` (Primário, Texto) → `lib/shared/components/atoms/app_button.dart`
- `Ícone/loader` → loading action

## Code
`lib/features/authentication/presentation/views/{signin_screen,signup_screen}.dart`, templates and organisms under `presentation/components`; shared `app_text_field.dart`, `app_button.dart`. Welcome: `lib/features/welcome/presentation/views/welcome_screen.dart`.

## Tokens used
- `color/app-background`
- `color/text`
- `color/text-secondary`
- `color/text-muted`
- `color/primary`
- `color/on-primary`
- `color/border`
- `color/danger`
- `color/app-background-3`
- `Título/1`
- `Corpo/Pequeno`
- `Corpo/Padrão`
- `Interface/Rótulo`
- `Interface/Legenda`
- `Interface/Botão`
- `radius/md`

## States in Figma
- Hints: sign-in password shows "Informe a senha da sua conta."; sign-up shows the full rule. The loading frame dims the action but leaves fields looking active.
- Default, error and loading for sign-in; default for sign-up. The `Foco` field state exists in the component but no frame shows it.
- Titles, labels, button text and error messages follow `lib/l10n/app_pt.arb` (`authSignInTitle`, `authEmailLabel`, `authPasswordError`, and so on). Helper hints ("Use o email da sua conta.", "Informe a senha da sua conta.", the sign-up rule hint) and the subtitle are placeholder copy with no l10n key.

## Accessibility
- Code supports password-manager autofill (autofillHints) and a 'go back' action that pops the route, falling back to `/home`; preserve both when implementing. `/home` is also the post-login destination unless a redirect URL is set.
- Sign-up password rules: 8+ characters, uppercase, digit, symbol. Sign-in only checks that the password is not empty (`authPasswordError`).
- Error text uses `color/danger` (about 4.9:1 on `color/app-background`) and also a red field border and message copy, so color is not the only cue.
- `color/on-primary` on `color/primary` is about 2.5:1 (see `on-primary-dark` in DESIGN.md); it affects the ENTRAR and CRIAR CONTA buttons.
- Placeholder text (`color/text-muted`) is about 4.4:1, just below the AA 4.5:1 minimum for normal text.

## Gaps (Figma vs code)
- The Figma section title names the routes /auth/login and /auth/register; code uses `/auth/signin` and `/auth/signup`. The new frames are named after the code routes.
- `/welcome` (API URL setup) has no frame; tracked in a follow-up issue.
- Sign-up validation errors (the password rules above) and server errors are not drawn; no web frame exists (web section `859:27` is empty).
- Neither Figma nor code has a show/hide control on the password field (`obscureText: true`).
- Autofill hints and the go-back action (pop, falling back to `/home`, for guest use) are not visible in Figma; the frames have no guest back affordance.
