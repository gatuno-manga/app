# Surface: Home

Anchors a single app surface for `/impeccable critique` and related commands. Facts come from the Gatuno Figma file (page "04 · Telas Mobile (App)", file key `QlUrvomONqwfefHCwTg0Hh`) and the repo; nothing here is new design. Token keys refer to `.impeccable/design.json`.

## Route
- Figma: /home — mobile
- Code: `/home` (`lib/features/home`)

## Figma frames
- `913:1380` /home — mobile
- `1112:8067` /home — mobile · visitante (the second action is the user icon, not the avatar)
- `1114:9063` /home — mobile · offline (#260; the call-to-action card `1114:9166` disabled, with its offline note)
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

Shell (#172): `/home` is the first branch of the `StatefulShellRoute` (`home_router.dart`); the bottom bar is `AppBottomNavBar` (Início, Biblioteca, Livros, 80 dp with labels). The profile button pushes the merged profile and settings screen under the Home tab (`/home/settings`); the avatar action itself is #251.

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
- Default: featured carousel (`Home/Destaque`, 620 dp) then three sections, the first being continue-reading with a horizontal list of `Livro/Card` (140×295), then the requests `Cartão de chamada` (#260).
- Signed-in, guest and offline variants (`913:1380`, `1112:8067`, `1114:9063`), each ending in the requests card (#260); no drawer (removed in #169). Book detail opened from here keeps the Início tab selected.
- No loading, empty or error frame.

## Accessibility
- Figma has no annotations; check tap target size of header icons and carousel contrast over cover art manually.

## Tablet frames (issue #171)

Page "05 · Telas Tablet (App)" (`1100:8297`), window size classes in DESIGN.md (Layout).

- Medium 834×1194: `1101:469` /home — tablet médio. Expanded 1194×834: `1101:625` /home — tablet expandido.
- Components: `Shell/Trilho de navegação` (`1112:9248`, 80 dp, three destinations, replaces the bottom bar from 600 dp up) with Início selected; `Shell/Barra superior` Raiz com logo across the content width, with the profile avatar (`Avatar/Perfil`) in the last action slot (opens the merged profile and settings screen); `Home/Destaque` Plataforma=Tablet (`1100:8359`) capped at 360 dp; `Seção/Cabeçalho`; `Livro/Card` Grade in rows of 4 (medium) or 6 (expanded) cards.
- Layout rules: see DESIGN.md Layout, "Window size classes and tablets". Code: #255 (rail in #173).
- Not drawn: the requests call-to-action card and the loading, empty and error states (the phone frame has none either).

## Gaps (Figma vs code)
- Frame `913:1380` draws `Shell/Barra superior` (logo, search, avatar; 64 dp, hides on scroll) and `Shell/Barra inferior` (80 dp, labels, three tabs); code has a 48 dp icons-only bar with Home, Books and Settings and builds its own `AppBar` (gap `navigation-shell-code-differences`). `Seção/Cabeçalho` shows "Ver tudo" on "Continue a sua leitura", opening `/latest-reads`.
- Book requests: the call-to-action card stays on Home and the merged profile and settings screen gets a row for `/requests`. The phone frames draw the card (`Cartão de chamada`, wrapper `home-cta · pedidos de livros`, 16 dp inset, after the last book row) since #260: signed in with the button "Pedidos de Livros" (`1114:9091`), guest with "Faça Login para Solicitar" (`1114:9101`) and offline (`Estado=Desabilitado`, `Nota=Sim`; `1114:9166`). Copy follows `homeCta*` and `bookRequestsTitle` in `lib/l10n/app_pt.arb`. The icon library has no `library_add` or login icon, so both buttons show `Ícone/plus`.
- Code shows a login or profile icon in the header (guest vs authenticated); Figma shows the avatar (signed in) or a user icon (guest) that opens the merged profile and settings screen.
