# Surface: Certificates

Anchors a single app surface for `/impeccable critique` and related commands. Facts come from the Gatuno Figma file (page "04 · Telas Mobile (App)", file key `QlUrvomONqwfefHCwTg0Hh`) and the repo; frames were drawn in issue #62 from the code as it is today, using the existing components, three components added for this screen, and tokens (Dark theme only). Token keys refer to `.impeccable/design.json`.

## Route
- Figma: none in the original file; the code-only route is drawn in section "Certificados — /settings/certificates" (`1060:8393`)
- Code: `/settings/certificates` (`lib/features/certificates`), a child route of `/settings`. The Settings frame `997:5052` already has the "Certificados" `Lista/Item` row that opens it.

## Figma frames
- `1060:8394` /settings/certificates — mobile (Confiáveis tab, three certificates: two with a fingerprint, one without)
- `1060:8453` /settings/certificates — mobile · ignorados vazio (Ignorados tab, `certEmptyIgnored`)
- `1060:8478` /settings/certificates — mobile · adicionar certificado (add dialog over a `color/overlay` scrim, name field empty so Selecionar Arquivo PEM is disabled)
- `1060:8553` /settings/certificates — mobile · remover certificado (`Diálogo/Confirmação` Destrutivo over the scrim)
- `1060:8623` /settings/certificates — mobile · erro ao adicionar (`Aviso/Snackbar` in `color/danger`, `certErrorInvalidFormat`; the FAB sits above it)

## Figma components used
- App bar: drawn inline as in `/settings/download` (back arrow in a 48 dp tile, centered `Título/3`, symmetric spacer); issue #169 owns the future top app bar component.
- `Abas` (new in #62, `1052:39159`; Selecionada=Primeira/Segunda) → Material `TabBar` in `certificates_template.dart`
- `Certificado/Item` (new in #62, `1052:39702`; Impressão digital=Sim/Não) → `certificate_item_tile.dart`; its delete action is `Leitor/Botão ícone` Fantasma with `Ícone/trash` in `color/danger`
- `Botão de ação flutuante` (new in #62, `1052:39160`) → `FloatingActionButton` in `certificates_template.dart`
- `Diálogo/Confiar em certificado` (#126) → reused for the add dialog: message hidden, title "Adicionar Certificado", `Campo/Texto` Nome with the hint `api.exemplo.com`, actions Cancelar and Selecionar Arquivo PEM (disabled at 38%)
- `Diálogo/Confirmação` Destrutivo (#165) → delete confirmation
- `Aviso/Snackbar` (#165) with its fill overridden to `color/danger` → error feedback
- `Campo/Texto` → add dialog name field

## Code
`lib/features/certificates/presentation/views/certificates_screen.dart` (`CertificatesPage`), `components/templates/certificates_template.dart`, `components/organisms/certificate_list.dart`, `components/molecules/{certificate_item_tile,certificate_add_dialog}.dart`, `components/atoms/certificate_empty_state.dart`; domain in `domain/`. Untrusted-certificate prompts elsewhere use `shared/components/organisms/certificate_trust_dialog.dart` (Figma `Diálogo/Confiar em certificado`).

## Tokens used
- `color/app-background`
- `color/text`
- `color/text-secondary`
- `color/primary`
- `color/on-primary`
- `color/border`
- `color/divider`
- `color/danger`
- `color/on-lilac`
- `color/overlay`
- `color/context-menu-bg`
- `color/text-10`
- `color/app-background-3`
- `color/text-muted`
- `radius/sm`
- `radius/md`
- `radius/xl`
- `space/lg`
- `Título/3`
- `Corpo/Padrão`
- `Corpo/Pequeno`
- `Interface/Botão`
- `Interface/Rótulo`
- `Interface/Legenda`

## States in Figma
- Confiáveis with items; Ignorados empty; add dialog (empty name, so the file button is disabled); delete confirmation; error snackbar. The row has two variants because the fingerprint line only shows when the fingerprint is not empty.
- Not drawn: Ignorados with items (same rows as Confiáveis), the add dialog while it loads (code swaps the file button label for a skeleton and disables both actions), the add dialog with a valid name (button enabled), and the Confiáveis empty tab (same layout as `1060:8453` with `certEmptyTrusted`). `CertificatesState.isLoading` exists but the page shows no loading view.
- Other `certError*` messages use the same snackbar with different text (`certErrorFileMissing`, `certErrorDecoding`, `certErrorEmptyFingerprint`, `certErrorUnknown`).
- Copy follows `lib/l10n/app_pt.arb` (`settingsCertificatesSection`, `certTrustedTab`, `certIgnoredTab`, `certAdd*`, `certDeleteConfirm`, `commonDelete`, `commonCancel`, `certFingerprintLabel`).

## Accessibility
- Measured by computing the pairs from the variable values. Fingerprint line and empty message in `color/border` (code uses `colorScheme.outline`) on `color/app-background`: 1.2-1.6:1 (1.33:1 in Dark), far below AA; the name and subject pass (`color/text`, `color/text-secondary` at 5.0:1 in Dark).
- Snackbar text `color/on-lilac` on `color/danger`: 4.9:1 in Dark and True-dark, 5.2:1 in Light, 5.5:1 in Slate and 6.6:1 Dracula (the code keeps the theme's `onLilac` text style on the error fill).
- FAB glyph `color/on-primary` on `color/primary`: 2.5:1 in Dark, True-dark and Slate, 2.4:1 in Dracula, 4.0:1 in Light (non-text guideline 3:1). Tabs: the selected label in `color/primary` is 8.0:1 in Dark and 3.5:1 in Light; the unselected `color/text-secondary` label repeats the 3.0-4.3:1 cases in `figma-contrast`.
- Disabled Selecionar Arquivo PEM (`color/primary` at 38% on the dialog panel) is about 1.9:1 in Dark (1.7-2.1:1 across themes); that is the disabled treatment the other components use.
- Tap targets: tabs are 48 dp high, the FAB 56 dp, the dialog actions 48 dp; the row's delete button is 40 dp in Figma (Material's `IconButton` is 48 dp).

## Gaps (Figma vs code)
- The code builds the screen from raw Material parts: `AppBar` with a `TabBar`, `FloatingActionButton`, `ListTile` rows with `IconButton`, `AlertDialog` for the add dialog (raw `TextField` and `ElevatedButton`) and `AlertDialog` for the delete confirmation. Figma draws them through `Abas`, `Botão de ação flutuante`, `Certificado/Item`, `Diálogo/Confiar em certificado` and `Diálogo/Confirmação`. Code follow-ups: extract the tab bar, FAB and row into atoms and molecules, use `AppConfirmDialog` (#147) for the delete confirmation and `AppTextField`, `AppButton` and `AppTextButton` in the add dialog.
- Colors that code takes from Material defaults and Figma binds to tokens: unselected tab label (`onSurfaceVariant`, drawn `color/text-secondary`), tab indicator and divider (drawn `color/primary` and `color/divider`), FAB fill and glyph (`primaryContainer` and `onPrimaryContainer` from the seed, drawn `color/primary` and `color/on-primary`). The row subject is `bodySmall` in `onSurface` (`color/text`) in code and drawn `color/text-secondary`.
- The row title uses `titleMedium`, which `AppTypography.textTheme` does not define (`fallback-text-roles`); Figma uses `Corpo/Padrão`.
- The empty message is italic in code; Figma has no italic text style, so it is drawn upright in `color/border`.
- The error snackbar is `colorScheme.error` in code, unlike the lilac snackbar of the theme; the snackbar's action is hidden (code has none).
- The add dialog's actions are drawn in a row; with a long Selecionar Arquivo PEM label code stacks them (`AlertDialog` overflow). The `certAddPemLabel` string is not used by the dialog.
- The Figma app bar title is `Título/3` centered, as `AppBarTheme(centerTitle: true)` does; the app bar height is 60 here and 56 in Material.
- No web frame exists.
