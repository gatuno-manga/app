# Surface: Settings

Anchors a single app surface for `/impeccable critique` and related commands. Facts come from the Gatuno Figma file (page "04 · Telas Mobile (App)", file key `QlUrvomONqwfefHCwTg0Hh`) and the repo; frames were drawn in issue #52 from the existing mobile frames, using only existing components and tokens (Dark theme only). Token keys refer to `.impeccable/design.json`.

## Route
- Figma: /user (mobile section `859:38`, "5 · Configurações")
- Code: `/settings` (`lib/features/settings`), certificates under `/settings/certificates`

## Figma frames
- `954:2732` /settings — mobile (profile card, general, API, certificates, diagnostics)

## Figma components used
- `Shell/Header` (Plataforma=Mobile)
- `Avatar/Perfil` (new local component, `951:870`) → profile card
- `Leitor/Item de ajuste` (Controle=Switch) → sensitive-content switch (`app_switch`; reuses the reader component because Figma has no settings switch)
- `Campo/Texto` (new local component, `951:869`) → API base URL
- `Lista/Item` (new local component, `951:872`) → certificates, export logs, open logs

## Code
`lib/features/settings/presentation/views/settings_screen.dart`, components under `presentation/components/{molecules,organisms,templates}`; certificates in `lib/features/certificates`.

## Tokens used
- `color/app-background`
- `color/text`
- `color/text-secondary`
- `color/text-muted`
- `color/primary`
- `color/primary-15`
- `color/primary-40`
- `color/divider`
- `color/app-background-3`
- `radius/md`
- `radius/pill`
- `Título/2`
- `Título/3`
- `Corpo/Padrão`
- `Corpo/Pequeno`
- `Interface/Botão`
- `Interface/Rótulo`
- `Interface/Legenda`

## States in Figma
- Default only. Copy follows `lib/l10n/app_pt.arb` (`settingsTitle`, `settingsGeneralSection`, `settingsApiSection`, `settingsDiagnosticsSection`).
- No frames for API-URL saved/error feedback (`settingsApiUrlSuccess`, `settingsApiUrlError`).

## Accessibility
- Measured in Figma against `color/app-background` (Dark): secondary text about 5.0:1 (AA, little headroom). `Lista/Item` rows are about 69 dp high and `Leitor/Item de ajuste` is 64 dp, both above the 44 dp minimum tap target.
- `Leitor/Item de ajuste` and `Lista/Item` use no primary-colored control besides the switch track; the `color/on-primary` contrast gap (see `on-primary-dark` in DESIGN.md) does not apply to this frame.

## Gaps (Figma vs code)
- The API field shows only a placeholder (`http://sua-api.com/api`) and no save action, although the server URL is always set at first launch; the stored-value and save states are not drawn.
- Signed-out state is not drawn: code shows the profile card as `commonGuest` ("Visitante") with no email, and tapping it opens `/auth/signin` (`settings_screen.dart`).
- The page header has no subtitle, unlike library and profile; code does not show one either.
- Section label "Configuração da API" and field label "URL Base da API" both come from l10n keys and overlap in meaning.
- Figma route /user differs from code `/settings`.
- `/settings/certificates` (list, add and remove allowed URLs) has no frame; tracked in a follow-up issue.
- No web frame exists (web section `859:28` is empty).
- Allowed-URLs list from `settingsAllowedUrlsSection` is not drawn on this screen.
