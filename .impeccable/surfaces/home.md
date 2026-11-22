# Surface: Home

Anchors a single app surface for `/impeccable critique` and related commands. Facts come from the Gatuno Figma file (page "04 · Telas Mobile (App)", file key `QlUrvomONqwfefHCwTg0Hh`) and the repo; nothing here is new design. Token keys refer to `.impeccable/design.json`.

## Route
- Figma: /home — mobile
- Code: `/home` (`lib/features/home`)

## Figma frames
- `913:1380` /home — mobile
- `1112:8067` /home — mobile · visitante (the second action is the user icon, not the avatar)
- The drawer variant `913:1538` was removed in #169. Frames carry `Shell/Barra superior` Tipo=Raiz com logo and `Shell/Barra inferior` since #170.

## Figma components used
- `Shell/Barra superior` (Tipo=Raiz com logo: logo, search and an avatar action, a user icon for guests) → target of `features/home/presentation/components/organisms/home_app_bar.dart` (shared top bar from #251). The avatar action opens the merged profile and settings screen (see `settings.md`).
- `Shell/Barra inferior` (Itens=3: Início selected, Biblioteca, Livros) → `shared/components/molecules/app_bottom_nav_bar.dart`
- `Home/Destaque` → `.../organisms/featured_carousel.dart`
- `Seção/Cabeçalho` → `.../molecules/home_section_header.dart`
- `Livro/Card` → `features/books/presentation/components/molecules/`
- `Shell web/Menu lateral` is web only; the app has no drawer.

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
- Signed-in and guest variants (`913:1380`, `1112:8067`); no drawer (removed in #169). Book detail opened from here keeps the Início tab selected.
- No loading, empty or error frame.

## Accessibility
- Figma has no annotations; check tap target size of header icons and carousel contrast over cover art manually.

## Gaps (Figma vs code)
- Frame `913:1380` draws `Shell/Barra superior` (logo, search, avatar; 64 dp, hides on scroll) and `Shell/Barra inferior` (80 dp, labels, three tabs); code has a 48 dp icons-only bar with Home, Books and Settings and builds its own `AppBar` (gap `navigation-shell-code-differences`). `Seção/Cabeçalho` shows "Ver tudo" on "Continue a sua leitura", opening `/latest-reads`.
- Book requests: the call-to-action card stays on Home and the merged profile and settings screen gets a row for `/requests`; the card is not drawn on Home yet, and code has only the card.
- Code shows a login or profile icon in the header (guest vs authenticated); Figma shows the avatar (signed in) or a user icon (guest) that opens the merged profile and settings screen.
