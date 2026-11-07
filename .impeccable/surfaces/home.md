# Surface: Home

Anchors a single app surface for `/impeccable critique` and related commands. Facts come from the Gatuno Figma file (page "04 · Telas Mobile (App)", file key `QlUrvomONqwfefHCwTg0Hh`) and the repo; nothing here is new design. Token keys refer to `.impeccable/design.json`.

## Route
- Figma: /home — mobile
- Code: `/home` (`lib/features/home`)

## Figma frames
- `913:1380` /home — mobile
- `913:1538` /home — mobile · menu aberto (gaveta)

## Figma components used
- `Shell/Header` → `features/home/presentation/components/organisms/home_app_bar.dart`
- `Home/Destaque` → `.../organisms/featured_carousel.dart`
- `Seção/Cabeçalho` → `.../molecules/home_section_header.dart`
- `Livro/Card` → `features/books/presentation/components/molecules/`
- `Shell/Menu lateral` → drawer variant; code uses bottom nav (`shared/components/molecules/app_bottom_nav_bar.dart`)

## Code
`lib/features/home/presentation/views/home_screen.dart`, template `home_template.dart`.

## Tokens used
- `color/app-background`
- `color/text`
- `color/text-secondary`
- `color/primary`
- `color/border`
- `color/context-menu-bg`
- `Título/2`
- `Título/3`
- `Corpo/Padrão`
- `Interface/Rótulo`
- `Interface/Botão`
- `radius/md`
- `Vidro/Médio`
- `Vidro/Painel`

## States in Figma
- Default: featured carousel (`Home/Destaque`, 620 dp) then three sections, the first being continue-reading with a horizontal list of `Livro/Card` (140×295).
- Menu open (drawer) variant, frame `913:1538`.
- No loading, empty or error frame.

## Accessibility
- Figma has no annotations; check tap target size of header icons and carousel contrast over cover art manually.

## Gaps (Figma vs code)
- Figma shows a drawer menu; mobile code uses a bottom navigation bar with Home, Books and Settings.
- Header shows login/profile icon in code (guest vs authenticated); Figma header content not audited.
