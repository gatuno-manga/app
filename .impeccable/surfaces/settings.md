# Surface: Settings

Anchors a single app surface for `/impeccable critique` and related commands. Facts come from the Gatuno Figma file (page "04 · Telas Mobile (App)", file key `QlUrvomONqwfefHCwTg0Hh`) and the repo; frames were drawn in issue #52 from the existing mobile frames, using only existing components and tokens (Dark theme only); issue #127 added the `App/Molecule/Rádio/Item` component and the `Core/Atom/Ícone/lock` icon for the app lock frames. Token keys refer to `.impeccable/design.json`.

## Route
- Figma: /user (mobile section `859:38`, "Configurações — /user"); app lock frames in the section "Bloqueio do app (/settings/app-lock)" (`1052:38698`)
- Code: `/settings` (`lib/features/settings`), certificates under `/settings/certificates`, download network rules under `/settings/download` (issue #95, `download_settings_screen.dart`), app lock under `/settings/app-lock` plus the lock cover (issue #127, `lib/features/app_lock`)

## Figma frames
- `997:5052` /settings — mobile: the merged profile and settings screen, "Perfil e configurações", pushed from the avatar action of any tab root (profile card, general, downloads, API, a "Solicitações de livros" row for `/requests`, certificates, diagnostics; replaced `954:2732` in issue #162 and grows to show every tile; redrawn in #170 with `App/Organism/Shell/Barra superior` Type=Stacked and `App/Organism/Shell/Barra inferior` with Início selected)
- `1112:8331` /settings — mobile · visitante: sign-in card instead of the profile card, no requests row
- `997:5174` /settings/download — mobile (five book types, each a `App/Molecule/Seletor segmentado`, plus a permanent caption)
- `997:5230` /settings/download — mobile · erro ao salvar (reverted choice and `App/Molecule/Aviso/Snackbar`)
- `1010:5184` /settings — mobile · confirmar troca de servidor (#147): `App/Organism/Diálogo/Confirmação` Destructive with chapter count and size
- `1010:5288` /settings — mobile · confirmar troca de servidor · sem contagem (#147): fallback body when the download totals cannot be read
- `997:5052` also gained the app lock entry row `1052:39980` (`App/Molecule/Lista/Item`, `Core/Atom/Ícone/lock`, issue #127) after the sensitive-content switch, so the frame is now 974 dp tall
- `1052:38699` /settings/app-lock — mobile (lock on: both switches on, grace radios with "Após 1 minuto" selected)
- `1052:38771` /settings/app-lock — mobile · bloqueio desligado (grace radios hidden, as in code)
- `1052:38818` /settings/app-lock — mobile · aparelho sem bloqueio de tela (only the unsupported-device text)
- `1052:38854` /settings/app-lock — mobile · erro ao salvar (`App/Molecule/Aviso/Snackbar` "Não foi possível salvar a configuração. Tente novamente.")
- `1052:38905` lock cover — mobile (logo, title, description, "DESBLOQUEAR")
- `1052:38960` lock cover — mobile · erro (danger message, "TENTAR NOVAMENTE")
- `1052:39017` lock cover — mobile · desbloqueio cancelado (muted message, "TENTAR NOVAMENTE")
- `1052:39074` lock cover — mobile · autenticando (`Core/Atom/Botão` with loader, no label)

## Figma components used
- `App/Organism/Shell/Barra superior` Type=Stacked (back, left-aligned title, actions hidden) and `App/Organism/Shell/Barra inferior` (#169, #170; code in #251 and #172). Settings is no longer a tab: the screen opens from the avatar action in each tab root's top bar. The `/settings/download` (`997:5174`, `997:5230`) and `/settings/app-lock` (`1052:38699`, `1052:38771`, `1052:38818`) frames draw both bars too since #260 (titles "Downloads" and "Bloqueio do app", no actions, Início selected); the content area is 700 dp and the snackbar of `997:5230` sits above the bottom bar.
- `App/Molecule/Perfil/Cartão` (#265, `1124:9549`): the profile entry at the top of `/settings`; `App/Molecule/Configurações/Linha de tipo` (#265, `1124:9624`): the five type rows of `/settings/download`
- `App/Atom/Avatar/Perfil` (new local component, `951:870`) → profile card
- `Core/Molecule/Interruptor/Item` → sensitive-content switch (`app_switch`; Figma component added in #126, replacing the reuse of the reader's `Core/Molecule/Leitor/Item de ajuste`)
- `App/Atom/Campo/Texto` (new local component, `951:869`) → API base URL
- `App/Molecule/Lista/Item` (new local component, `951:872`) → downloads, certificates, export logs, open logs
- `App/Molecule/Seletor segmentado` (issue #162, `996:5077`) → per-type download network (`AppLabeledSegmentedButton`)
- `App/Molecule/Aviso/Snackbar` (issue #162, `997:1294`) → failed save on /settings/download
- `App/Organism/Diálogo/Confirmação` (issue #165, `1010:1327`) → server-change confirmation (#147)
- `App/Molecule/Rádio/Item` (issue #127, `1052:37854`) → grace-period choices (`RadioListTile`)
- `Core/Molecule/Interruptor/Item` (Icon=No) → the two app lock switches (`AppSwitch`)
- `Core/Atom/Botão` Primary and `Core/Atom/Marca/Logo` (96 dp) → lock cover; `App/Molecule/Aviso/Snackbar` → refused prompt or failed save

## Code
`lib/features/settings/presentation/views/settings_screen.dart`, settings components under `presentation/components/{molecules,organisms,templates}`; certificates in `lib/features/certificates`; app lock in `lib/features/app_lock/presentation/{views/app_lock_settings_screen.dart,views/app_lock_screen.dart,components/molecules/app_lock_settings_tile.dart}`.

Shell (#172): Settings is no longer a tab. The screen is pushed from a tab root and mounted under each (`/home/settings`, `/library/settings`, `/books/settings`, with `download`, `app-lock`, `mfa`, `certificates` and `profile` below it); `/settings` redirects to the Home copy. It still renders `SettingsPage` until the merged content lands (#251).

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
- `Corpo/Grande`
- `Interface/Botão`
- `Interface/Rótulo`
- `Interface/Legenda`

## States in Figma
- /settings: default only. /settings/download: default, the other choice (Livro on "Wi-Fi e dados") and a failed save; the disabled control (initial load) exists only as a component variant. Copy follows `lib/l10n/app_pt.arb` (`settingsTitle`, `settingsGeneralSection`, `settingsApiSection`, `settingsDiagnosticsSection`), plus the `settingsDownload*` keys for the download screen.
- No frames for API-URL saved/error feedback (`settingsApiUrlSuccess`, `settingsApiUrlError`).
- /settings/app-lock: lock on, lock off, unsupported device and failed save. The enabled-but-unsupported text (`appLockUnsupportedEnabledDesc`), the biometric-only descriptions and the other refusal messages of `appLockOutcomeText` are not drawn. The lock cover: default, error (`appLockErrorFailed`), cancelled (`appLockErrorCancelled`) and authenticating; the biometric-only description (`appLockLockedDescBiometricOnly`) is not drawn. Copy follows `lib/l10n/app_pt.arb` (`appLock*`), with the button labels in capitals as the other `Core/Atom/Botão` frames.

## Accessibility
- Measured in Figma against `color/app-background` (Dark): secondary text about 5.0:1 (AA, little headroom). `App/Molecule/Lista/Item` rows are about 69 dp high and `Core/Molecule/Interruptor/Item` is 64 dp, both above the 44 dp minimum tap target.
- `Core/Molecule/Interruptor/Item` and `App/Molecule/Lista/Item` use no primary-colored control besides the switch track; the `color/on-primary` contrast gap (see `on-primary-dark` in DESIGN.md) does not apply to this frame.
- /settings/download: `App/Molecule/Seletor segmentado` segments are 48 dp high (meets the target); color/text on the selected `color/primary-40` fill is 6.3-8.2:1 across the five themes; the `color/border` outline and divider are 1.2-1.6:1 (see `figma-contrast`).
- App lock: `Core/Molecule/Interruptor/Item` is 64 dp (the longer fallback description wraps to a taller row) and `App/Molecule/Rádio/Item` is 56 dp with a 40 dp radio target, both above the 44 dp tap target. The grace header in `color/primary` is 3.5:1 in Light, the cover error in `color/danger` is 3.4:1 in Light, and the cancelled message and unselected radio ring in `color/text-secondary` are 3.0:1 in Dracula, 3.6:1 in True-dark and 4.3:1 in Light (see `figma-contrast`). The code marks the cover title and error as live regions and the unsupported text as a live region; Figma cannot show it.

## Tablet frames (issue #171)

Page "05 · Telas Tablet (App)" (`1100:8297`), window size classes in DESIGN.md (Layout).

- Medium: `1105:9225` /settings (the merged profile and settings screen, pushed, one column) and `1105:9370` /settings/download (pushed). Expanded list-detail: `1105:9489` (profile preselected) and `1105:9653` (downloads selected).
- Components: `App/Organism/Shell/Trilho de navegação` (`1112:9248`, 80 dp, three destinations, replaces the bottom bar from 600 dp up) with Início selected (the tab the screen was opened from; there is no Settings tab); `App/Organism/Shell/Barra superior` Stacked with the title "Perfil e configurações", since profile and settings are one pushed screen opened from the avatar action of the tab-root top bars; `App/Atom/Avatar/Perfil`, `Core/Molecule/Interruptor/Item`, `App/Molecule/Lista/Item` (including the new "Solicitar livro" row for `/requests`), `App/Atom/Campo/Texto`, `App/Molecule/Seletor segmentado`, `Core/Atom/Botão`. The selected list row has a `color/primary-15` fill.
- Layout rules: list pane 400 dp, detail pane fills the rest with content 720 dp at most; the first entry is selected on open (profile for signed-in users, Downloads for guests).
- Code: #254.
- Not drawn: the API URL field and the diagnostics rows beyond "Exportar Logs", the server-change dialogs, and the app lock, MFA and certificates sub-pages in the detail pane (they follow the same pane rules).

## Gaps (Figma vs code)
- Figma `997:5052` has no Leitura section; code orders Geral, Leitura, Downloads, API, Certificados, Diagnósticos.
- The API field shows only a placeholder (`http://sua-api.com/api`) and no save action, although the server URL is always set at first launch; the stored-value and save states are not drawn.
- The guest frame `1112:8331` shows a sign-in card in place of the profile card; code shows the profile card as `commonGuest` ("Visitante") with no email, and tapping it opens `/auth/signin` (`settings_screen.dart`).
- The page header has no subtitle, unlike library and profile; code does not show one either.
- Section label "Configuração da API" and field label "URL Base da API" both come from l10n keys and overlap in meaning.
- Figma route /user differs from code `/settings`.
- `/settings/certificates` is drawn in issue #62; see `certificates.md`.
- `/settings/app-lock` and the lock cover are drawn (issue #127); the code differences are listed in `app-lock-code-differences` in DESIGN.md. The entry row is drawn on `997:5052` with a description cut to one line.
- No web frame exists (web section `859:28` is empty).
- Allowed-URLs list from `settingsAllowedUrlsSection` is not drawn on this screen.
- Book requests: the decision (#169, changed in #170) is a row on this screen as well as the card on Home; it is drawn on `997:5052` and the two #147 dialog frames. Code has no such row and still has Settings as the third tab (#172, #251). The profile edit screen (`/settings/profile`) is pushed above this one and keeps whichever tab was selected.
