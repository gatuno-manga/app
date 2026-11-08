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
- `Seletor cíclico/Visualização` → `features/books/presentation/components/molecules/books_view_mode_selector.dart` (grid / list / covers, in the body above the list via `organisms/books_view_toolbar.dart`; built on `shared/components/molecules/app_icon_segmented_control.dart`)
- `Livros/Filtros avançados` → `features/books/presentation/components/`
- `Filtro/Ativo` → active filter chip
- `Livro/Card` → `molecules/book_card.dart` (grid, title below the cover), `molecules/book_cover_card.dart` (cover mode, title over the art), `molecules/book_list_item.dart` (list)
- `Paginação/Página` → `shared/components/molecules/pagination.dart`

## Code
`lib/features/books/presentation/views/books_screen.dart`.

## Tokens used
- `color/app-background`
- `color/text`
- `color/primary`
- `color/primary-15`
- `color/border`
- `Título/3`
- `Interface/Botão`
- `Interface/Legenda`
- `radius/md`

## States in Figma
- Grid, list and advanced-filters-open variants; paginated (6 page controls).
- Web only: no results, filter combinations (`919:3451` section). Cover mode is drawn on web only (`920:5249`) but the mobile selector carries the segment, so code implements it on mobile too.

## Accessibility
- Not audited.

## Gaps (Figma vs code)
- Mobile has no empty/no-results or loading frame (web has `920:5605`).
- Cover view mode is drawn on web only; the mobile implementation (issue #6) reuses the web card.
- Code-only, no Figma frame (issue #6): the view-options bottom sheet (`organisms/books_view_options_sheet.dart`: columns 1–4, navigation Pages/Infinite), the `Icons.tune` button that opens it, infinite scroll with its load-more footer, and the stored view preferences.
- Figma places sort, random-book actions and the source selector in the body and pagination above the grid; code keeps sort/filter/search in the app bar and pagination below the list.
