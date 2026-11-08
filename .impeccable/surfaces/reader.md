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
