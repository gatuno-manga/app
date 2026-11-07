# Surface: Books list

Anchors a single app surface for `/impeccable critique` and related commands. Facts come from the Gatuno Figma file (page "04 · Telas Mobile (App)", file key `QlUrvomONqwfefHCwTg0Hh`) and the repo; nothing here is new design. Token keys refer to `.impeccable/design.json`.

## Route
- Figma: /books — mobile (grade, filtros avançados, lista)
- Code: `/books` (`lib/features/books`)

## Figma frames
- `922:1714` /books — mobile · grade
- `922:1888` /books — mobile · filtros avançados
- `922:2215` /books — mobile · lista

## Figma components used
- `Shell/Header`
- `Botão` → search/filter actions
- `Seletor cíclico/Fonte` → source selector
- `Seletor cíclico/Visualização` → view mode selector
- `Livros/Filtros avançados` → `features/books/presentation/components/`
- `Filtro/Ativo` → active filter chip
- `Livro/Card` → grid/list card
- `Paginação/Página` → `shared/components/molecules/pagination.dart`

## Code
`lib/features/books/presentation/views/books_screen.dart`.

## Tokens used
- ``color/app-background``
- ``color/text``
- ``color/primary``
- ``color/primary-15``
- ``color/border``
- ``Título/3``
- ``Interface/Botão``
- ``Interface/Legenda``
- ``radius/md``

## States in Figma
- Grid, list and advanced-filters-open variants; paginated (6 page controls).
- Web only: cover mode, no results, filter combinations (`919:3451` section).

## Accessibility
- Not audited.

## Gaps (Figma vs code)
- Mobile has no empty/no-results or loading frame (web has `920:5605`).
- Cover view mode exists on web only.
