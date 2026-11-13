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
- `983:3725` section Leitor · Documento (PDF e EPUB) · Ajustes (#72): six frames, see "Document reader settings (issue #72)"

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

## Document reader settings (issue #72)

Frames live in the Figma section `Leitor · Documento (PDF e EPUB) · Ajustes (#72)` (id `983:3725`, inside "2 · Livro e Leitor"), built from the same sheet pattern as `874:694` / `882:959` (as #70). The sheet is one pattern with sections per format; the reader theme is applied through the `Gatuno / Leitura (temas)` mode of each frame.
- `983:3726` Leitor · PDF · Ajustes (padrão): theme Padrão, layout Contínuo, direction Vertical, zoom fit Largura
- `983:3920` Leitor · PDF · Ajustes (Sépia, página única, zoom 125%): zoom row visible because fit is Personalizado
- `983:4138` Leitor · PDF · Ajustes (Alto contraste, zoom mínimo 50%): minus disabled
- `983:4356` Leitor · EPUB · Ajustes (padrão): Serifa 19 dp, 180%, Esquerda, margens Médias, Paginado
- `983:4598` Leitor · EPUB · Ajustes (extremos: Sépia, tamanho e linhas no máximo): Sem serifa, 28 dp and 220% (plus disabled), Justificado, margens Largas, Contínuo
- `983:4846` Leitor · EPUB · Ajustes (Alto contraste, tamanho e linhas no mínimo): Lexend, 14 dp and 120% (minus disabled), Centro, margens Estreitas, Paginado

Decisions:
- PDF options: page layout (Contínuo, Página única, Duas páginas; the last only at 600 dp or wider, hidden on phones), scroll direction (Vertical, Horizontal; in Contínuo it is the scroll axis, in Página única the page-turn axis; right-to-left is not designed), zoom fit (Largura, Página, Personalizado), and a zoom stepper (50% to 300%, step 25%) shown only for Personalizado, starting at the zoom the current fit produced (the stepper appears when the fit changes, growing the sheet from 423 to 513 dp; no frame shows that transition). The reader theme is a colour filter over the rendered page (Padrão = no filter, so the page stays white even though the Padrão swatch is dark navy, as on the EPUB).
- EPUB options: reader theme, typography (font from the text reader list: Serifa, Sem serifa, Lexend, Atkinson, OpenDyslexic; size 14-28 dp; line spacing 120-220%; alignment), margins (Estreitas, Médias, Largas) and pagination (Paginado, Contínuo).
- Document preferences are separate from the text reader preferences: PDF and EPUB share one document theme (the PDF applies it as a filter, the EPUB as a real theme), and the EPUB has its own typography values, so the implementation (#73) must not reuse `TextReaderPreferences` state as is.
- Components reused (the notes list above omits `Leitor/Botão ícone`, also used by #70): `Leitor/Item de ajuste` (Passos, Seletor), `Leitor/Tema de leitura`, `Leitor/Botão ícone`. No new tokens; the theme comes from the `leitura/*` tokens.
- Non-goals: PDF crop margins and an EPUB publisher-styles toggle.

Dependencies on #19 (the PDF and EPUB reader; `document_reader.dart` is still a placeholder): every option here acts on the reader, so none can be applied before #19 exists. The sheet, its preferences model and persistence can be built first.

Gaps:
- Selectors have no open (dropdown) state in Figma; the implementation can use a bottom sheet or menu, as for the other selector rows.
- A disabled stepper button is drawn with 38% opacity (same as #70); there is no disabled variant.
- The EPUB sheet is 657-669 dp tall (78-79% of an 844 dp screen) and hides most of the page while open; no peek or drag mode is designed. It should scroll once it exceeds 85% of the screen height (a proposed rule, not inherited from #70; small screens, large text scale); no frame shows that case.
- No frame for 600 dp or wider: the "Duas páginas" layout and the sheet on tablets are not designed. On phones the layout row subtitle lists only continuous and single page. Tablet breakpoints are not defined in the design system yet.
- Rows grow from 64 to 76 dp when a subtitle wraps and selector chips hug their content, so left edges are ragged. Implementation rule: keep the row at 64 dp minimum, wrap the subtitle, and ellipsize a long selector value at a maximum chip width, also at text scale 1.5 to 2.0.
- The EPUB body paragraphs sit behind the sheet in all three EPUB frames, so only the eyebrow and title show margins (symmetric: 28, 44 and 16 dp) and centre alignment; body size, line spacing and justification are described by the row values and the notes under each frame, not visible. Font family, layout and zoom changes are likewise described in the notes. The page indicator ghosts behind the sheet (inherited from #70), and whether the progress bar stays per page in Contínuo is a question for #19. The PDF page sample uses no tokens, and the "Padrão" swatch is the theme sample, not the page. Creme is not selected in any frame.
- The selected-theme label (`--primary-color` on the light sheet, about 3.7:1) is inherited from #70 and should be fixed at pattern level.
- Page theme as a colour filter is a proposal; the PDF renderer in #19 decides whether it is feasible.

Accessibility for the implementation: stepper buttons and selectors are below 48 dp in the Figma components, so code must pad the hit area to at least 48 dp. Give each stepper button a separate label (decrease and increase) with the current value in the row title, and expose each selector with its row title as the label.
