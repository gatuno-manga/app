# Surface: Settings

Anchors a single app surface for `/impeccable critique` and related commands. Facts come from the Gatuno Figma file (page "04 · Telas Mobile (App)", file key `QlUrvomONqwfefHCwTg0Hh`) and the repo; frames were drawn in issue #52 from the existing mobile frames, using only existing components and tokens (Dark theme only). Token keys refer to `.impeccable/design.json`.

## Route
- Figma: /user (mobile section `859:38`, "Configurações — /user")
- Code: `/settings` (`lib/features/settings`), certificates under `/settings/certificates`, download network rules under `/settings/download` (issue #95, `download_settings_screen.dart`)

## Figma frames
- `997:5052` /settings — mobile (profile card, general, downloads, API, certificates, diagnostics; replaced `954:2732` in issue #162 and grows to show every tile)
- `997:5174` /settings/download — mobile (five book types, each a `Seletor segmentado`, plus a permanent caption)
- `997:5230` /settings/download — mobile · erro ao salvar (reverted choice and `Aviso/Snackbar`)
- `1010:5184` /settings — mobile · confirmar troca de servidor (#147): `Diálogo/Confirmação` Destrutivo with chapter count and size
- `1010:5288` /settings — mobile · confirmar troca de servidor · sem contagem (#147): fallback body when the download totals cannot be read

## Figma components used
- `Shell/Header` (Plataforma=Mobile)
- `Avatar/Perfil` (new local component, `951:870`) → profile card
- `Leitor/Item de ajuste` (Controle=Switch) → sensitive-content switch (`app_switch`; reuses the reader component because Figma has no settings switch)
- `Campo/Texto` (new local component, `951:869`) → API base URL
- `Lista/Item` (new local component, `951:872`) → downloads, certificates, export logs, open logs
- `Seletor segmentado` (issue #162, `996:5077`) → per-type download network (`AppLabeledSegmentedButton`)
- `Aviso/Snackbar` (issue #162, `997:1294`) → failed save on /settings/download
- `Diálogo/Confirmação` (issue #165, `1010:1327`) → server-change confirmation (#147)

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
- `color/border`
- `color/lilac`
- `color/on-lilac`
- `color/context-menu-bg`
- `color/text-10`
- `color/overlay`
- `color/danger`
- `color/divider`
- `color/app-background-3`
- `radius/md`
- `radius/pill`
- `radius/xl`
- `space/sm`
- `space/md`
- `space/lg`
- `space/2xl`
- `Título/2`
- `Título/3`
- `Corpo/Padrão`
- `Corpo/Pequeno`
- `Interface/Botão`
- `Interface/Rótulo`
- `Interface/Legenda`

## States in Figma
- /settings: default only. /settings/download: default, the other choice (Livro on "Wi-Fi e dados") and a failed save; the disabled control (initial load) exists only as a component variant. Copy follows `lib/l10n/app_pt.arb` (`settingsTitle`, `settingsGeneralSection`, `settingsApiSection`, `settingsDiagnosticsSection`), plus the `settingsDownload*` keys for the download screen.
- No frames for API-URL saved/error feedback (`settingsApiUrlSuccess`, `settingsApiUrlError`).

## Accessibility
- Measured in Figma against `color/app-background` (Dark): secondary text about 5.0:1 (AA, little headroom). `Lista/Item` rows are about 69 dp high and `Leitor/Item de ajuste` is 64 dp, both above the 44 dp minimum tap target.
- `Leitor/Item de ajuste` and `Lista/Item` use no primary-colored control besides the switch track; the `color/on-primary` contrast gap (see `on-primary-dark` in DESIGN.md) does not apply to this frame.
- /settings/download: `Seletor segmentado` segments are 48 dp high (meets the target); color/text on the selected `color/primary-40` fill is 6.3-8.2:1 across the five themes; the `color/border` outline and divider are 1.2-1.6:1 (see `figma-contrast`).

## Gaps (Figma vs code)
- Figma `997:5052` has no Leitura section; code orders Geral, Leitura, Downloads, API, Certificados, Diagnósticos.
- The API field shows only a placeholder (`http://sua-api.com/api`) and no save action, although the server URL is always set at first launch; the stored-value and save states are not drawn.
- Signed-out state is not drawn: code shows the profile card as `commonGuest` ("Visitante") with no email, and tapping it opens `/auth/signin` (`settings_screen.dart`).
- The page header has no subtitle, unlike library and profile; code does not show one either.
- Section label "Configuração da API" and field label "URL Base da API" both come from l10n keys and overlap in meaning.
- Figma route /user differs from code `/settings`.
- `/settings/certificates` (list, add and remove allowed URLs) has no frame; tracked in a follow-up issue.
- `/settings/app-lock` (issue #4) and its General-section entry (`app_lock_settings_tile.dart`, a `Lista/Item` row hidden on devices without a screen lock) have no frame; the lock cover screen has none either (see `app-lock-not-in-figma` in DESIGN.md).
- No web frame exists (web section `859:28` is empty).
- Allowed-URLs list from `settingsAllowedUrlsSection` is not drawn on this screen.
