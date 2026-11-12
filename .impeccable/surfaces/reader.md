# Surface: Reader

Anchors a single app surface for `/impeccable critique` and related commands. Facts come from the Gatuno Figma file (page "04 · Telas Mobile (App)", file key `QlUrvomONqwfefHCwTg0Hh`) and the repo; nothing here is new design. Token keys refer to `.impeccable/design.json`.

## Route
- Figma: Leitor · Imagem, Texto, PDF, EPUB, Ajustes, Acessibilidade, menu de contexto
- Code: `/chapters/:id` and `/chapters/:id/page/:index` (`lib/features/reading`)

## Figma frames
- `874:2` Leitor · Imagem (scroll contínuo)
- `874:69` Leitor · Texto (markdown)
- `874:585` Leitor · Documento PDF (proposta)
- `874:643` Leitor · Documento EPUB (proposta)
- `874:694` Leitor · Ajustes (folha inferior)
- `882:910` Leitor · Texto · Modo dislexia (Creme)
- `882:959` Leitor · Ajustes · Acessibilidade (folha)
- `894:1837` Leitor · Imagem · menu de contexto (toque longo)

## Figma components used
- `Leitor/Barra superior` → `.../molecules/reading_top_bar.dart`
- `Leitor/Barra inferior` → `.../molecules/reading_bottom_bar.dart`
- `Leitor/Progresso por página`
- `Leitor/Indicador de página`
- `Leitor/Item de ajuste` → `.../molecules/reader_setting_row.dart` (settings sheet row)
- `Leitor/Tema de leitura` → `.../atoms/reader_theme_swatch.dart` (reader theme swatch, 4)
- `Leitor/Predefinição · Modo dislexia`
- `Leitor/Régua de leitura` → reading ruler
- `Menu de contexto/Leitor · página de imagem` → long-press menu

## Code
`lib/features/reading/presentation/views/reading_screen.dart`; organisms `image_reader.dart`, `text_reader.dart`, `document_reader.dart`, `reader_settings_sheet.dart`, `text_reader_settings_section.dart`; templates `reading_template.dart`. Reader themes: `lib/core/theme/reader_palette.dart`; preferences: `features/reading/domain/entities/reader_preferences.dart`.

## Tokens used
- `leitura/fundo`
- `leitura/superficie`
- `leitura/texto`
- `leitura/texto-suave`
- `leitura/acento`
- `leitura/destaque`
- `leitura/borda`
- `color/overlay`
- `color/context-menu-bg`
- `Leitura/Serifa`
- `Leitura/Dislexia`
- `Interface/Rótulo`
- `Vidro/Overlay`

## States in Figma
- Image continuous scroll; text (markdown); PDF and EPUB (both proposals).
- Settings sheet and accessibility sheet; dyslexia preset on Creme theme; context menu on long press.
- Reader themes: Padrão, Sépia, Creme, Alto contraste.

## Accessibility
- Dyslexia preset (Lexend, spacing 5%) and reading ruler are specified; see Figma frame `882:523` (web) for the accessibility spec.
- Reader theme contrast should be checked per mode, especially `Sépia` accent `#9a4a00` and `Creme` accent `#1b5fad`.

## Gaps (Figma vs code)
- Reader themes and the text settings sheet (font, size, line spacing, alignment) are implemented for the text reader only; the accessibility sheet (dyslexia preset, word spacing, reading ruler), the `Geral`/`Aparência`/`Privacidade` tabs and `Modo noturno` are not.
- PDF and EPUB are proposals in Figma; code has `document_reader.dart` and its scope is not audited.

## Image reader settings (issue #70)

Frames live in the Figma section `Leitor · Imagem · Ajustes (#70)` (id `979:3184`, inside "2 · Livro e Leitor"), built from the same sheet pattern as `874:694` / `882:959`. Light token mode, like the accessibility sheet.
- `979:3185` Leitor · Imagem · Ajustes (padrão): theme Padrão, gap 0 dp (minus disabled), indicator on, keep screen on off
- `979:3326` Leitor · Imagem · Ajustes (extremos: espaço máximo): theme Sépia, gap 16 dp (plus disabled), indicator off, keep screen on on
- `979:3467` Leitor · Imagem · Ajustes (Creme, espaço 8): theme Creme, gap 8 dp (both steppers enabled)
- `979:3602` Leitor · Imagem · Espaço entre páginas 8 dp (Sépia): the reader without the sheet, showing the gap on the `leitura/fundo` of Sépia
- `979:3612` Leitor · Imagem · Ajustes (Alto contraste): theme Alto contraste, gap 4 dp

Decisions: the background is the shared theme picker (`Leitor/Tema de leitura`, no new control or token). Rows below it: page gap stepper (`Leitor/Item de ajuste` Controle=Passos; default 0, range 0-16 dp, step 4), "Mostrar indicador de página" (Switch, default on) and "Manter a tela ligada" (Switch, default off). Components reused: `Leitor/Item de ajuste`, `Leitor/Tema de leitura`, `Leitor/Botão ícone`.

Gaps:
- A disabled stepper button is drawn with 38% opacity on the `Leitor/Botão ícone` instance; the component has no disabled variant.
- Paged mode, reading direction (LTR/RTL) and fit width/height (fit height needs paged mode) are not designed; a follow-up issue is pending.
- "Manter a tela ligada" needs a wakelock dependency in code; the image reader does not apply the reader theme yet (`ReaderThemeScope`).

Accessibility for the implementation: the stepper buttons (32 dp) and switches in the Figma components are below 48 dp, so code must pad the hit area to at least 48 dp (`gatuno_lints` small tap target rule). Give the two stepper buttons separate labels (decrease and increase page gap; the current value is in the row title) and expose each switch with its row title as the label. The rows reuse the code molecules `reader_stepper_row.dart` and `reader_setting_row.dart`.
