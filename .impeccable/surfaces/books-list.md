# Surface: Books list

Anchors a single app surface for `/impeccable critique` and related commands. Facts come from the Gatuno Figma file (page "04 · Telas Mobile (App)", file key `QlUrvomONqwfefHCwTg0Hh`) and the repo; nothing here is new design. Token keys refer to `.impeccable/design.json`.

## Route
- Figma: /books — mobile (grade, filtros avançados, lista)
- Code: `/books` (`lib/features/books`)

## Figma frames
- `922:1714` /books — mobile · grade
- `922:1888` /books — mobile · filtros avançados
- `922:2215` /books — mobile · lista
- `1112:8121` /books — mobile · barra recolhida (the Root bar with the search row scrolled away; since #266 the bar is the same 64 dp row as every Root)

## Figma components used
- `App/Organism/Shell/Barra superior` Type=Root with search (one 64 dp row with the title, the shuffle and random-book actions and the avatar, then the search field on its own row; 120 dp) and `App/Organism/Shell/Barra inferior` with Livros selected (#169, #170; code in #251 and #172)
- `App/Molecule/Ordenação/Seletor` (#265, `1124:9594`): the "Ordenar por:" row on the grid, list and filter frames
- `Core/Atom/Botão` → search/filter actions
- `Core/Molecule/Seletor cíclico/Fonte` → source selector
- `Core/Molecule/Seletor cíclico/Visualização` → `features/books/presentation/components/molecules/books_view_mode_selector.dart` (grid / list / covers, in the body above the list via `organisms/books_view_toolbar.dart`; built on `shared/components/molecules/app_icon_segmented_control.dart`)
- `Core/Organism/Livros/Filtros avançados` → `features/books/presentation/components/`
- `Core/Atom/Filtro/Ativo` → active filter chip
- `Core/Molecule/Livro/Card` → `molecules/book_card.dart` (grid, title below the cover), `molecules/book_cover_card.dart` (cover mode, title over the art), `molecules/book_list_item.dart` (list)
- `Core/Atom/Paginação/Página` → `shared/components/molecules/pagination.dart`

## Code
`lib/features/books/presentation/views/books_screen.dart`.

Shell (#172): `/books` is the third branch (Livros); re-tapping the active tab pops to the root, then scrolls the list to the top (`TabRootScrollScope` in `books_router.dart`).

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
- Selected view-selector glyph is `color/on-primary` on `color/primary` (2.5:1 in Dark, True-dark, Slate; 2.4:1 Dracula; 4.0:1 Light), the documented `figma-contrast` gap; selection also reads from the tile fill. Needs a Figma decision.
- Selector tiles are 36 dp (Figma size), like the pagination buttons.

## Tablet frames (issue #171)

Page "05 · Telas Tablet (App)" (`1100:8297`), window size classes in DESIGN.md (Layout).

- Grid: `1103:680` medium, `1103:873` expanded. List: `1103:1035` medium, `1103:1210` expanded. Filters: `1103:1424` medium (bottom sheet, 640 dp at most, centered), `1103:1607` expanded (modal side sheet, 360 dp, from the right).
- Components: `App/Organism/Shell/Trilho de navegação` (`1112:9248`, 80 dp, three destinations, replaces the bottom bar from 600 dp up) with Livros selected; `App/Organism/Shell/Barra superior` Root with search with the profile avatar in the third action slot; `Core/Molecule/Seletor cíclico/Visualização`, `Core/Atom/Paginação/Página`, `Core/Atom/Botão` Outline "Filtros"; `Core/Molecule/Livro/Card` Grade (4 columns medium, 6 expanded, minimum 160 dp) or Lista (2 and 3 columns, minimum 320 dp); `Core/Organism/Livros/Filtros avançados` Platform=Mobile inside the sheets.
- Code: #252.
- Not drawn: the random-book actions row of the phone frame (the top bar keeps the two actions), loading and empty states.

## Gaps (Figma vs code)
- Mobile has no empty/no-results or loading frame (web has `920:5605`).
- Cover view mode is drawn on web only; the mobile implementation (issue #6) reuses the web card.
- Code-only, no Figma frame (issue #6): the view-options bottom sheet (`organisms/books_view_options_sheet.dart`: columns 1–4, navigation Pages/Infinite), the `Icons.tune` button that opens it, infinite scroll with its load-more footer, and the stored view preferences.
- Figma puts the search field and the random-book actions (shuffle, dice) in the top bar and keeps only the filter button, sort and the source selector in the body, with pagination above the grid; code keeps sort/filter/search in the app bar and pagination below the list.

## Implementation status (#251)
- #251: Livros uses `AppTopBar` with the search row (hides with the bar) and `TabRootProfileAction`; the list is a sliver. `BooksPage` applies a `BooksLaunchIntent` (`focus`, `orderBy`, `order`, `n`) on open and whenever the nonce changes.
- #251 device fixes: the search field follows the `campo de busca` frame (48 dp, `color/secondary-60` fill, 1 dp `color/border`, radius 12, a 20 dp search icon, Corpo/Pequeno), and `AppTopBarScaffold` keeps the scroll view below the status bar (`SafeArea`), so a focused field never scrolls under the system icons.
