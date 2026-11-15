# Surface: Book detail

Anchors a single app surface for `/impeccable critique` and related commands. Facts come from the Gatuno Figma file (page "04 · Telas Mobile (App)", file key `QlUrvomONqwfefHCwTg0Hh`) and the repo; nothing here is new design. Token keys refer to `.impeccable/design.json`.

## Route
- Figma: /books/:id — Capítulos (mobile), Mais opções, Capítulos agrupados
- Code: `/books/:bookId` (`lib/features/books`)

## Figma frames
- `903:637` /books/:id — Capítulos (mobile)
- `903:928` /books/:id — Mais opções aberto (mobile)
- `906:1075` /books/:id — Capítulos agrupados (mobile)
- `1011:4909` /books/:id — Downloads · confirmar exclusão (#165, sub-section `1011:4908` "Livro · Downloads (#165)"): `Diálogo/Confirmação` Destrutivo with the chapter count and the space freed

## Figma components used
- `Diálogo/Confirmação` (issue #165, `1010:1327`) → multi-chapter delete confirmation
- `Livro/Capa` → cover
- `Tag` → metadata tags
- `Livro/Aba` → tabs
- `Capítulo/Item`
- `Capítulo/Grupo` → grouped chapters (multi-language)
- `Botão`
- `Leitor/Botão ícone`
- `Menu de contexto/Livro · mais opções` → glass menu

## Code
`lib/features/books/presentation/views/book_details_screen.dart`.

## Tokens used
- `color/app-background`
- `color/text`
- `color/text-secondary`
- `color/primary`
- `color/context-menu-bg`
- `color/text-10`
- `color/overlay`
- `color/danger`
- `radius/xl`
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
- `Vidro/Dropdown`
- `Vidro/Painel`

## States in Figma
- Chapters tab, more-options menu open, chapters grouped by number.
- Web only: art, extra info, saved pages, related, ratings, skeleton loading, admin tools, batch selection (`859:25` section).

## Accessibility
- Not audited.

## Gaps (Figma vs code)
- Mobile frames cover only the chapters tab; other tabs (art, info, related, ratings) are web-only.
- Admin tools and batch selection are web-only in Figma.
