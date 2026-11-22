# Surface: Book detail

Anchors a single app surface for `/impeccable critique` and related commands. Facts come from the Gatuno Figma file (page "04 · Telas Mobile (App)", file key `QlUrvomONqwfefHCwTg0Hh`) and the repo; the download controls of issue #165 are new design in the section "Livro — ficha do livro (/books/:id)" (`1037:7224`). Token keys refer to `.impeccable/design.json`.

## Route
- Figma: /books/:id — Capítulos (mobile), Mais opções, Capítulos agrupados, Downloads (#165)
- Code: `/books/:bookId` (`lib/features/books`)

## Figma frames
- `903:637` /books/:id — Capítulos (mobile)
- `903:928` /books/:id — Mais opções aberto (mobile)
- `906:1075` /books/:id — Capítulos agrupados (mobile)
- `1023:5698` /books/:id — Downloads · estados dos capítulos (#165): download summary and one tile per indicator state
- `1023:6647` /books/:id — Downloads · resumo (#165): the five summary states
- `1023:6696` /books/:id — Downloads · seleção (#165): selection top and bottom bars
- `1025:5929` /books/:id — Opções do livro (⋮) (#165): book sheet with the Downloads group
- `1025:6019` /books/:id — Opções do livro (⋮) · offline (#165): Baixar todos disabled
- `1025:6109` /books/:id — Downloads · capítulo com erro (folha) (#165)
- `1025:6181` /books/:id — Downloads · capítulo baixado (folha) (#165)
- `1025:6243` /books/:id — Downloads · offline (#165): tiles waiting for connection
- `1025:6544` /books/:id — Downloads · visitante (#165): sign-in SnackBar
- `1011:4909` /books/:id — Downloads · confirmar exclusão (#165): `Diálogo/Confirmação` Destrutivo with the chapter count and the space freed

## Figma components used
- `Diálogo/Confirmação` (issue #165, `1010:1327`) → multi-chapter delete confirmation
- `Capítulo/Download` (extended in issue #165, `895:304`) → tile download indicator
- `Livro/Resumo de downloads` (issue #165, `1023:1377`) → download summary
- `Capítulos/Barra de seleção` (`1023:1378`) and `Capítulos/Ações da seleção` (`1023:1388`) (issue #165) → selection mode
- `Lista/Item`, `Interruptor/Item` → book sheet rows
- `Aviso/Snackbar` → guest sign-in prompt
- `Livro/Capa` → cover
- `Tag` → metadata tags
- `Livro/Aba` → tabs
- `Capítulo/Item` (Estado=Selecionado for selected tiles in selection mode)
- `Ícone/square`, `wifi`, `cloud-off`, `pause`, `play`, `check-check` (issue #165, frame `1019:460`) → indicator and selection glyphs
- `Capítulo/Grupo` → grouped chapters (multi-language)
- `Botão`
- `Leitor/Botão ícone`
- `Menu de contexto/Livro · mais opções` → glass menu in `903:928` (superseded by the Opções do livro sheet)

## Code
`lib/features/books/presentation/views/book_details_screen.dart`.

## Tokens used
- `color/app-background`
- `color/text`
- `color/text-secondary`
- `color/text-muted`
- `color/primary`
- `color/context-menu-bg`
- `color/secondary-60`
- `color/border`
- `color/divider`
- `color/warning`
- `color/success`
- `color/lilac`
- `color/on-lilac`
- `color/text-10`
- `color/overlay`
- `color/danger`
- `radius/xl`
- `radius/lg`
- `radius/pill`
- `space/xs`
- `space/sm`
- `space/md`
- `space/lg`
- `space/2xl`
- `Título/2`
- `Título/3`
- `Corpo/Pequeno`
- `Interface/Botão`
- `Corpo/Padrão`
- `Interface/Rótulo`
- `Interface/Legenda`
- `Vidro/Dropdown`
- `Vidro/Painel`
- `Vidro/Overlay`

## States in Figma
- Chapters tab, more-options menu open, chapters grouped by number.
- Downloads (#165): every indicator state, the five summary states, selection mode, the book sheet online and offline, failed and done chapter sheets, offline tiles, guest SnackBar and the multi-delete confirmation. Behaviour details not drawn (empty selection, bar metric, colours via `theme.legible()`) are in issue #165's implementation notes and the component descriptions.
- Web only: art, extra info, saved pages, related, ratings, skeleton loading, admin tools, batch selection (`859:25` section).

## Accessibility
- Not audited.

## Gaps (Figma vs code)
- `903:928` still shows the earlier floating ⋮ menu proposal; the app's ⋮ opens the "Opções do livro" sheet (`1025:5929`).
- The download controls (#165) have no code yet (issue #93). The book sheet's switch row is `Interruptor/Item` (it was the reader's `Leitor/Item de ajuste` before #126): #93 promotes a switch row to `shared/components/molecules/` instead of importing `reader_switch_row.dart`; "Excluir download" needs a new outlined danger `AppButton` variant or `app_outlined_button` atom at 48 dp; the shell's `AppOfflineBanner` is not drawn in the offline frame.
- Mobile frames cover only the chapters tab; other tabs (art, info, related, ratings) are web-only.
- Admin tools and batch selection are web-only in Figma.
