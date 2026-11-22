# Surface: Profile

Anchors a single app surface for `/impeccable critique` and related commands. Facts come from the Gatuno Figma file (page "04 · Telas Mobile (App)", file key `QlUrvomONqwfefHCwTg0Hh`) and the repo; frames were drawn in issue #52 from the existing mobile frames, using only existing components and tokens (Dark theme only). Token keys refer to `.impeccable/design.json`.

## Route
- Figma: `/users/:userId` (mobile section `859:36`, "Biblioteca e Perfil — /library, /users/:userId")
- Code: `/settings/profile` (`lib/features/users`, `me_screen.dart`)

## Figma frames
- `953:2544` /users/:userId — mobile · Meu Perfil (avatar, name, email, logout)

## Figma components used
- `Shell/Barra superior` Tipo=Empilhada (back, "Perfil", no actions) and `Shell/Barra inferior` with Início selected: the screen is pushed above the merged profile and settings screen, from whichever tab opened it (#169, #170; code in #251 and #172)
- `Avatar/Perfil` (new local component, `951:870`) → `lib/shared/components/atoms/app_avatar.dart`
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
- Secondary text about 5.0:1 (little headroom) on `color/app-background` (Dark). Avatar shows initials only; no photo state is drawn.

## Tablet frames (issue #171)

Page "05 · Telas Tablet (App)" (`1100:8297`), window size classes in DESIGN.md (Layout).

- Expanded list-detail with the profile in the detail pane: `1105:9489` (surface `settings`). Medium: the profile page is pushed as on the phone; no separate tablet frame.
- Components in the detail pane: `Avatar/Perfil`, `Campo/Texto`, `Botão`. The profile is part of the merged profile and settings screen; the avatar in the tab-root top bars opens it and the tab it was opened from stays selected. `/settings/profile` (edit) is a second pushed screen.
- Code: #254.

## Gaps (Figma vs code)
- Profile (`/settings/profile`) and settings (`/settings`) are separate screens in code; settings holds the profile card, sensitive-content switch and API, certificate and log entries.
- Figma route `/users/:userId` (any user) differs from code `/settings/profile` (current user only); the frame shows the current user.
- The sensitive-content switch is not on the profile screen: code puts it on settings (`settings_screen.dart`), so the profile frame omits it.
- Avatar has no image, loading or error state drawn (code has a grey placeholder circle when the name is null, and uses `colorScheme.onPrimary`, which differs from Figma `color/on-primary`, see `on-primary-dark`); there is no logout-confirmation frame.
