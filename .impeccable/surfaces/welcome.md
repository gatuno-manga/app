# Surface: Welcome

Anchors a single app surface for `/impeccable critique` and related commands. Facts come from the Gatuno Figma file (page "04 · Telas Mobile (App)", file key `QlUrvomONqwfefHCwTg0Hh`) and the repo; frames were drawn in issue #62 from the code as it is today, using the existing components and tokens (Dark theme only). Token keys refer to `.impeccable/design.json`.

## Route
- Figma: none in the original file; the code-only route is drawn in section "Boas-vindas — /welcome" (`1059:7742`)
- Code: `/welcome` (`lib/features/welcome`); the first screen of a fresh install, where the person types the server API URL. `main.dart` opens it as the initial location while no API URL is saved.

## Figma frames
- `1059:7743` /welcome — mobile (logo, title, instructions, URL field with the code's default `http://localhost:3000/api`, Conectar)
- `1059:7772` /welcome — mobile · erro (`Campo/Texto` Estado=Erro with the connection message under the field)
- `1059:7801` /welcome — mobile · carregando (`Botão` in the disabled look with `Indicador de carregamento`)

## Figma components used
- `Marca/Logo` (80 dp instance; code draws `Icons.pets`, see gaps)
- `Campo/Texto` (`951:869`; Estado=Padrão / Erro, help line hidden in the default state) → `lib/shared/components/atoms/app_text_field.dart` (target; code uses a raw `TextField`)
- `Botão` (Primário) → `lib/shared/components/atoms/app_button.dart` (target; code uses a raw `ElevatedButton`)
- `Indicador de carregamento` (Tamanho=Padrão, `1048:1829`) → `lib/shared/components/atoms/app_loading_indicator.dart`

## Code
`lib/features/welcome/presentation/views/welcome_screen.dart` (`WelcomePage`), `view_models/welcome_view_model.dart`, `welcome_router.dart`. The model validates the URL through `SettingsService.validateApiUrl`, strips a trailing slash, saves it and the page then goes to `/home`.

## Tokens used
- `color/app-background`
- `color/text`
- `color/text-muted`
- `color/primary`
- `color/on-primary`
- `color/danger`
- `color/text-10`
- `color/app-background-3`
- `Título/1`
- `Corpo/Padrão`
- `Interface/Rótulo`
- `Interface/Legenda`
- `Interface/Botão`
- `radius/md`

## States in Figma
- Default, erro (message under the field, red outline from `Campo/Texto` Erro) and carregando (field kept in the Padrão look, button without label and with the spinner). There is no empty state: the field is prefilled.
- Copy follows `lib/l10n/app_pt.arb` (`welcomeTitle`, `welcomeInstructions`, `settingsApiUrlLabel`, `welcomeConnect`). The error text is the Portuguese rendering of the English string hard-coded in `WelcomeViewModel` (see gaps).
- The content is centred vertically as code does (`Center` plus `SingleChildScrollView`, 32 dp padding), so the error frame moves up by the height of the message.

## Accessibility
- Measured by computing the pairs from the variable values (Dark): `color/text` on `color/app-background` passes; the field value is `color/text` (the component's `color/text-muted` is for placeholders only); the error line in `color/danger` is 4.9:1 on `color/app-background` in Dark, 5.0:1 in True-dark, 4.8:1 in Slate, 4.5:1 in Dracula and 3.5:1 in Light.
- `Conectar` repeats the `color/on-primary` on `color/primary` gap (2.4-4.0:1, see `figma-contrast`). The Material button is 48 dp or more; the Figma `Botão` is 44 dp.
- The spinner in `color/primary` on the disabled button fill (`color/text-10` over `color/app-background`) is 6.8:1 in Dark, 4.4:1 in Dracula and 2.9:1 in Light; it carries no text, so the 3:1 non-text guideline applies.

## Gaps (Figma vs code)
- Code draws `Icons.pets` at 80 dp in `color/primary`, not `Marca/Logo`; Figma uses `Marca/Logo`. Code follow-up: use the brand logo.
- The screen builds a raw `TextField` (outlined border, floating label), `ElevatedButton` and `CircularProgressIndicator` (default 36 dp, no size). Figma uses `Campo/Texto` (label above a filled field), `Botão` and the 24 dp `Indicador de carregamento`. Code follow-up: `AppTextField`, `AppButton` with its loading state.
- The disabled field and the disabled button have no Figma state: while loading, code disables both (Material disabled colors, button grows to fit the 36 dp spinner). Figma keeps the field in Padrão and fills the button with `color/text-10`, close to Material's 12% disabled fill.
- `WelcomeViewModel` hard-codes English messages ("Please enter a URL", "Could not connect to the server. Please check the URL and certificate.", "An unexpected error occurred while saving the URL.") instead of ARB keys. Figma shows the Portuguese text of the connection message; code follow-up: move all three to `app_en.arb` and `app_pt.arb`.
- Code bolds the title (`headlineMedium` is `Título/1` at w600, with `fontWeight: FontWeight.bold` it renders w700); Figma uses `Título/1` as is.
- The empty-URL message appears in the same slot as the connection message; only the connection one is drawn.
- No web frame exists.
