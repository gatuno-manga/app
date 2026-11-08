# Surface: Profile

Anchors a single app surface for `/impeccable critique` and related commands. Facts come from the Gatuno Figma file (page "04 · Telas Mobile (App)", file key `QlUrvomONqwfefHCwTg0Hh`) and the repo; frames were drawn in issue #52 from the existing mobile frames, using only existing components and tokens (Dark theme only). Token keys refer to `.impeccable/design.json`.

## Route
- Figma: `/users/:userId` (mobile section `859:36`, "3 · Biblioteca e Perfil")
- Code: `/settings/profile` (`lib/features/users`, `me_screen.dart`)

## Figma frames
- `953:2544` /users/:userId — mobile · Meu Perfil (avatar, name, email, logout)

## Figma components used
- `Shell/Header` (Plataforma=Mobile)
- `Avatar/Perfil` (new local component, `951:870`) → `shared/components/atoms/app_avatar.dart`
- `Botão` (Contorno) → logout

## Code
`lib/features/users/presentation/views/me_screen.dart`, components under `lib/features/users/presentation/components/{molecules,templates}`. Redirects to `/auth/signin` when unauthenticated.

## Tokens used
- `color/app-background`
- `color/text`
- `color/text-secondary`
- `color/primary`
- `color/primary-15`
- `color/primary-40`
- `radius/pill`
- `Título/1`
- `Título/2`
- `Título/3`
- `Corpo/Padrão`
- `Interface/Botão`

## States in Figma
- Authenticated default only. The signed-out case is a redirect to `/auth/signin` in code and has no frame.

## Accessibility
- Not audited. Avatar shows initials only; no photo state is drawn.

## Gaps (Figma vs code)
- Figma route `/users/:userId` (any user) differs from code `/settings/profile` (current user only); the frame shows the current user.
- The sensitive-content switch is not on the profile screen: code puts it on settings (`settings_screen.dart`), so the profile frame omits it.
- Avatar has no image, loading or error state.
