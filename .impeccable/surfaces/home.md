# Surface: Home

Anchors a single app surface for `/impeccable critique` and related commands. Facts come from the Gatuno Figma file (page "04 · Telas Mobile (App)", file key `QlUrvomONqwfefHCwTg0Hh`) and the repo; nothing here is new design. Token keys refer to `.impeccable/design.json`.

## Route
- Figma: /home — mobile
- Code: `/home` (`lib/features/home`)

## Figma frames
- `913:1380` /home — mobile
- The drawer variant `913:1538` was removed in #169; frames still carry the old web header until #170 redraws them.

## Figma components used
- `Shell/Barra superior` (Tipo=Raiz com logo: logo, search and avatar or sign-in) → target of `features/home/presentation/components/organisms/home_app_bar.dart` (shared top bar from #251). Frames still use the web `Shell web/Header` until #170.
- `Shell/Barra inferior` → `shared/components/molecules/app_bottom_nav_bar.dart`
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
- No drawer variant (removed in #169). Book detail opened from here keeps the Início tab selected.
- No loading, empty or error frame.

## Accessibility
- Figma has no annotations; check tap target size of header icons and carousel contrast over cover art manually.

## Gaps (Figma vs code)
- Frame `913:1380` still draws the web header; the target is `Shell/Barra superior` with the logo and a 64 dp bar that hides on scroll, plus `Shell/Barra inferior` (80 dp, labels). Code has a 48 dp icons-only bar with Home, Books and Settings and builds its own `AppBar` (gap `navigation-shell-code-differences`).
- Book requests: the call-to-action card stays on Home and Settings gets a row for `/requests`; code has only the card.
- Header shows login/profile icon in code (guest vs authenticated); Figma header content not audited.
