# Surface: MFA (two-factor authentication)

Anchors a single app surface for `/impeccable critique` and related commands. Facts come from the Gatuno Figma file (page "04 · Telas Mobile (App)", file key `QlUrvomONqwfefHCwTg0Hh`) and the repo; frames were drawn in issue #128 from existing components and tokens (Dark theme only). Token keys refer to `.impeccable/design.json`.

## Route
- Figma: `/auth/mfa` (section `1052:38039`, "Autenticação — MFA") and `/settings/mfa` (section `1052:39164`, "Configurações — MFA"); both sections sit next to their parents since #266 (`/auth/mfa` after Autenticação, `/settings/mfa` after Configurações).
- Code: `/auth/mfa` (`lib/features/authentication/presentation/views/mfa_challenge_screen.dart`, reached after sign-in when the account has two-factor on) and `/settings/mfa` (`lib/features/settings/presentation/views/mfa_settings_screen.dart`).

## Figma frames
- Layout (#266): on `/auth/mfa` and on the first three `/settings/mfa` states (carregando, erro ao carregar, desativada) the top bar stays and the content block is vertically centered in the remaining area, 24 dp side padding, 342 dp wide.
- `1052:38040` /auth/mfa — mobile (description, code field, Verificar)
- `1052:38063` /auth/mfa — mobile · erro (invalid code message under the field)
- `1052:38085` /auth/mfa — mobile · carregando (button with loader)
- `1052:39165` /settings/mfa — mobile · carregando (`MfaPhase.loading`)
- `1052:39176` /settings/mfa — mobile · erro ao carregar (`MfaPhase.loadFailed`, retry)
- `1052:39191` /settings/mfa — mobile · desativada (`MfaPhase.status`, off)
- `1052:39206` /settings/mfa — mobile · ativada (`MfaPhase.status`, on: backup codes left, Reconfigurar, Desativar)
- `1052:39231` /settings/mfa — mobile · configuração (`MfaPhase.setup`: secret, copy/open buttons, code field)
- `1052:39273` /settings/mfa — mobile · códigos de backup (`MfaPhase.backupCodes`, box unchecked, Concluir dimmed)
- `1052:39313` /settings/mfa — mobile · códigos de backup · confirmado (box checked, Concluir enabled)
- `1052:39354` /settings/mfa — mobile · confirmar desativação (code dialog over the "ativada" frame)
- `1052:39411` /settings/mfa — mobile · confirmar reconfiguração (warning dialog over the "ativada" frame)

## Figma components used
- `App/Atom/Campo/Texto` (`951:869`) → `lib/shared/components/atoms/app_text_field.dart`
- `Core/Atom/Botão` Primary, Outline, Text (set `895:204`, Outline `895:194`) → `app_button.dart`; Outline stands for the raw `OutlinedButton` the screen uses today and the planned `AppOutlinedButton` (#101)
- `App/Atom/Caixa de seleção` (new in #128, `1052:37844`) → Material `CheckboxListTile` (backup-codes confirmation)
- `App/Atom/Indicador de carregamento` (`1048:1829`, Size=Default) → `app_loading_indicator.dart`; the settings loading phase builds a raw `CircularProgressIndicator` today (see Gaps)
- `App/Organism/Diálogo/Confirmação` (`1010:1327`, Variant=Default for reconfigure, Destructive for disable) → the two `AlertDialog`s of the settings screen
- Every `/settings/mfa` frame draws `App/Organism/Shell/Barra superior` Type=Stacked (left-aligned "Autenticação em dois fatores", no actions) and `App/Organism/Shell/Barra inferior` Items=3 with Início selected, redrawn in #260 (code in #251 and #172; the frames carried a copy of the `/settings/download` inline `app-bar` before). The content area is 700 dp. The two backup-codes frames (`1052:39273`, `1052:39313`) have no back button, as `automaticallyImplyLeading: false` does: their bar is `App/Organism/Shell/Barra superior` Type=Stacked with Show back = No (#265; the earlier detached copy is gone). The dialog frames (`1052:39354`, `1052:39411`) keep their scrim over both bars.

## Code
`lib/features/authentication/presentation/{views/mfa_challenge_screen.dart,view_models/mfa_challenge_view_model.dart,view_models/mfa_error.dart}` and `lib/features/settings/presentation/{views/mfa_settings_screen.dart,view_models/mfa_settings_view_model.dart}`; strings are the `mfa*` keys in `lib/l10n/app_pt.arb`.

## Tokens used
- `color/app-background`
- `color/text`
- `color/text-secondary`
- `color/primary`
- `color/on-primary`
- `color/border`
- `color/danger`
- `color/overlay`
- `color/context-menu-bg`
- `Título/2`
- `Título/3`
- `Corpo/Grande`
- `Corpo/Padrão`
- `Interface/Botão`
- `radius/sm`
- `radius/md`

## States in Figma
- Challenge: default, invalid code, loading. The other errors (`tooManyAttempts`, `network`, `unknown`) use the same message slot with their `mfaError*` text; `challengeExpired` is a snackbar plus a redirect to `/auth/signin` and has no frame. The empty-field validation message (`mfaCodeRequired`) is not drawn either.
- Settings: every `MfaPhase` (loading, load failed, status off/on, setup, backup codes) plus the disable and reconfigure dialogs. The status and setup phases with an error (a failed enable, reconfigure or disable shows the message under the status; a failed confirmation shows it under the code field) and the busy button states are not drawn.
- Copy follows `lib/l10n/app_pt.arb`. The secret, backup codes and the "7 códigos de backup restantes" count are sample data.
- The disabled "Concluir" is drawn at 40% opacity, the same approximation as other disabled buttons; Figma has no disabled button treatment.
- The Desativar dialog is `App/Organism/Diálogo/Confirmação` Variant=Destructive with Show field = Yes (#265), an `App/Atom/Campo/Texto` between message and actions (the earlier detached copy is gone).

## Accessibility
- The error text is `color/danger` on `color/app-background`: 4.9:1 Dark, 5.0:1 True-dark, 4.8:1 Slate, 4.5:1 Dracula, 3.5:1 Light. In code it is a live region (`Semantics(liveRegion: true)`), so screen readers announce it; the message wording also carries the cue, not only the color.
- Disable action label (`color/danger`, outlined button and dialog action): same pairs as above.
- Unchecked checkbox outline (`color/text-secondary`, 2 dp) against the background: 5.0:1 Dark, 7.1:1 Slate, 4.2:1 Light, 3.6:1 True-dark, 3.0:1 Dracula; all meet the 3:1 non-text guideline, Dracula barely. The checked box is `color/primary` with a `color/on-primary` mark (2.5:1, see `figma-contrast`).
- The code field has `AutofillHints.oneTimeCode` and autofocus on the challenge and on the disable dialog; the setup field accepts digits only. Back is blocked while backup codes are shown (`PopScope`), with a snackbar telling the person to save them first.
- Secret and backup codes are `SelectableText`, so they can be copied by long press; two outlined buttons copy or share them.

## Tablet frames (issue #171)

Page "05 · Telas Tablet (App)" (`1100:8297`), window size classes in DESIGN.md (Layout).

- Not drawn. On expanded, `/settings/mfa` opens in the settings detail pane (see surface `settings`, 720 dp content at most); on medium it is pushed. `/auth/mfa` follows the 480 dp form rule of the auth surface.

## Gaps (Figma vs code)
- The challenge and setup code fields have a leading shield icon (`prefixIcon`); `App/Atom/Campo/Texto` has no icon slot, so the frames omit it (the disable dialog field has no icon in code either).
- Outlined buttons in code carry icons (`copy`, `open_in_new`, `share`); the `Core/Atom/Botão` Outline instances here show the component's default icon because Figma has no icon swap on it.
- The secret and the backup codes are `titleMedium` in a monospace family; Figma has no monospace text style, so the frames use `Título/3`. The status heading is also `titleMedium`, a role Figma does not define (`fallback-text-roles`), drawn as `Título/3`.
- The settings loading phase is a raw `CircularProgressIndicator` (Material default stroke, no size); the frame uses `App/Atom/Indicador de carregamento` Default (24 dp, 2 dp stroke), so code should use `AppLoadingIndicator`.
- The screen builds raw `OutlinedButton`, `TextButton`, `CheckboxListTile` and `AlertDialog` (`raw_widget_outside_atoms`); the frames use `Core/Atom/Botão`, `App/Atom/Caixa de seleção` and `App/Organism/Diálogo/Confirmação`.
- Flutter's `AppBar` shows the title on one line and ellipsizes it, so "Autenticação em dois fatores" may be cut on narrow phones or large text scales; the frames draw it one line with an ellipsis, and the overflow treatment (wrap or shorter title) is left to #251, which builds the shared top bar.
- No web (1440 dp) frames, and no Light, True-dark, Dracula or Slate frames: those themes are a mode switch of the same frames.
