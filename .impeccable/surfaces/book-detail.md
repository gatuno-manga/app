# Surface: Book detail

Anchors a single app surface for `/impeccable critique` and related commands. Facts come from the Gatuno Figma file (page "04 · Telas Mobile (App)", file key `QlUrvomONqwfefHCwTg0Hh`) and the repo; nothing here is new design. Token keys refer to `.impeccable/design.json`.

## Route
- Figma: /books/:id — Capítulos (mobile), Mais opções, Capítulos agrupados
- Code: `/books/:bookId` (`lib/features/books`)

## Figma frames
- `903:637` /books/:id — Capítulos (mobile)
- `903:928` /books/:id — Mais opções aberto (mobile)
- `906:1075` /books/:id — Capítulos agrupados (mobile)

## Figma components used
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
- ``color/app-background``
- ``color/text``
- ``color/text-secondary``
- ``color/primary``
- ``color/context-menu-bg``
- ``Título/2``
- ``Corpo/Padrão``
- ``Interface/Rótulo``
- ``Vidro/Dropdown``

## States in Figma
- Chapters tab, more-options menu open, chapters grouped by number.
- Web only: art, extra info, saved pages, related, ratings, skeleton loading, admin tools, batch selection (`859:25` section).

## Accessibility
- Not audited.

## Gaps (Figma vs code)
- Mobile frames cover only the chapters tab; other tabs (art, info, related, ratings) are web-only.
- Admin tools and batch selection are web-only in Figma.
