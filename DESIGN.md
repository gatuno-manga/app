---
name: Gatuno
description: Flutter client for the self-hosted Gatuno Manga reader; tokens sourced from the Gatuno Figma file.
theme:
  source: lib/core/theme/theme.dart
  figma: https://www.figma.com/design/QlUrvomONqwfefHCwTg0Hh/Gatuno
  tokens: .impeccable/design.json
  seed: "AppColors.lilac (Light), AppColors.orange (Dark)"
  fontFamily: "Inknut Antiqua"
  extensions: [GatunoColors]
---

# Design System: Gatuno

**Source of truth: the Figma file, not the code.** Values below come from the Figma variable collections `Gatuno / Tokens (código)` and `Gatuno / Leitura (temas)` and the Figma text and effect styles. `AppTheme` (`lib/core/theme/theme.dart`) is the implementation and currently drifts from Figma; each drift is marked `(Figma; code differs: <value>)` and collected in [Figma vs code gaps](#figma-vs-code-gaps). This intentionally overrides the `document` reference's "theme code is normative" rule for this repository (issue #40). Machine-readable tokens, with Figma names, live in `.impeccable/design.json`; the two files must agree (`python3 tool/check_design_tokens.py`).

## Overview

**Creative North Star:** not decided. The Figma file does not name one and none was confirmed; do not invent one.

The Figma system is dark-first: warm cream text (`#e9e1d1`) on near-black blue (`#000212`) with one orange accent (`#f18522`), serif titles (Inknut Antiqua), and glass (blurred translucent) surfaces for menus, sheets and overlays. Five themes share one set of semantic token names; only the values change.

**Key Characteristics:**
- Semantic tokens first: components reference `color/primary`, never a raw hex.
- Translucent tints (`-10`, `-15`, `-40` alpha ramps) instead of separate light/dark shades.
- Three type voices: Inknut Antiqua (titles), Manrope (body), Plus Jakarta Sans (interface labels); reader-only Literata and Lexend.
- Flat surfaces; depth comes from glass blur and one shadow style, not from layered elevation.

## Colors

Five themes (Figma modes of `Gatuno / Tokens (código)`, table at node `884:104`). Implemented in code today: Dark (partly matches), Light (diverges). True-dark, Dracula and Slate: not implemented, and no theme-selection mechanism exists in code.

| Token (Figma) | CSS var | Dark | Light | True-dark | Dracula | Slate | Flutter target | Code vs Figma |
|---|---|---|---|---|---|---|---|---|
| `color/app-background` | `--app-background-color` | `#000212` | `#eeeeee` | `#000000` | `#282a36` | `#15161a` | `colorScheme.surface + scaffoldBackgroundColor` | differs: code Light `#fdfdfd` |
| `color/text` | `--app-text-color` | `#e9e1d1` | `#2b2d31` | `#e9e1d1` | `#f8f8f2` | `#f8fafc` | `colorScheme.onSurface` | differs: code Light `#20142a` |
| `color/text-secondary` | `--app-text-color-secondary` | `#e9e1d18c` | `#2b2d31a6` | `#e9e1d173` | `#6272a4` | `#94a3b8` | none | no code token |
| `color/text-muted` | `--app-text-color-muted` | `#fdfdfd73` | `#2b2d3173` | `#fdfdfd59` | `#f8f8f273` | `#f8fafc73` | none | no code token |
| `color/primary` | `--primary-color` | `#f18522` | `#cc5e00` | `#f18522` | `#bd93f9` | `#f18522` | `colorScheme.primary` | differs: code Light `#a972ff` |
| `color/secondary` | `--secondary-color` | `#181a1f` | `#e0e0e0` | `#181a1f` | `#44475a` | `#212329` | `colorScheme.surfaceContainerHighest (proposed)` | differs: code Dark `#20142a`, Light `#f8f9fa` |
| `color/border` | `--border-color` | `#e9e1d126` | `#2b2d311f` | `#e9e1d11a` | `#f8f8f226` | `#f8fafc26` | `colorScheme.outline` | differs: code Dark `#666666`, Light `#cccccc` |
| `color/hover` | `--hover-color` | `#e9e1d114` | `#2b2d310f` | `#e9e1d10f` | `#f8f8f214` | `#f8fafc14` | none | no code token |
| `color/divider` | (none) | `#e9e1d11a` | `#2b2d311a` | `#e9e1d112` | `#f8f8f21a` | `#f8fafc1a` | `dividerTheme.color` | differs: code Dark `#555555`, Light `#e0e0e0` |
| `color/context-menu-bg` | `--context-menu-bg` | `#000212cc` | `#ffffffe5` | `#000000e5` | `#282a36e5` | `#15161ae5` | `GatunoColors.contextMenuBackground` | differs: code Light `#fdfdfde6` |
| `color/overlay` | `--overlay-bg` | `#000000b2` | `#0000004d` | `#000000d9` | `#000000bf` | `#000000b2` | `GatunoColors.overlayBackground` | differs: code Dark `#000000b3` |
| `color/on-primary` | `--white` | `#fdfdfd` | `#fdfdfd` | `#fdfdfd` | `#fdfdfd` | `#fdfdfd` | `colorScheme.onPrimary` | differs: code Dark `#000212` |
| `color/danger` | `--danger-color` | `#f12237` | `#ff0000` | `#f12237` | `#ff5555` | `#ef4444` | `colorScheme.error` | differs: code Dark `#f18522`, Light `#f18522` |
| `color/warning` | `--warning-color` | `#ffc107` | `#ffc107` | `#ffc107` | `#ffb86c` | `#f59e0b` | none | no code token |
| `color/success` | `--success-color` | `#157219` | `#28a745` | `#157219` | `#50fa7b` | `#10b981` | `GatunoColors.scrapingStatusReady` | differs: code Light `#00ff00` |
| `color/lilac` | `--lilac` | `#a972ff` | `#a972ff` | `#a972ff` | `#a972ff` | `#a972ff` | none | no code token |
| `color/cyan` | `--cyan` | `#17a2b8` | `#17a2b8` | `#17a2b8` | `#17a2b8` | `#17a2b8` | none | no code token |

Alpha ramps (same hue as their base token, fixed opacity; values per theme in `design.json`): `color/primary-10`, `color/primary-15`, `color/primary-40`, `color/lilac-15`, `color/lilac-40`, `color/success-15`, `color/success-40`, `color/danger-10`, `color/danger-15`, `color/danger-40`, `color/warning-15`, `color/warning-40`, `color/cyan-15`, `color/cyan-40`, `color/secondary-45`, `color/secondary-60`, `color/text-10`, `color/text-40`, `color/app-background-2`, `color/app-background-3`, `color/app-background-40`, `color/app-background-75`.

### Reader themes
`Gatuno / Leitura (temas)` has four modes (Padrão, Sépia, Creme, Alto contraste) with `leitura/fundo`, `leitura/superficie`, `leitura/texto`, `leitura/texto-suave`, `leitura/acento`, `leitura/destaque`, `leitura/borda`. They apply only inside the reader (frame `882:910` uses Creme with the dyslexia preset). Code has no reader themes.

### Named Rules
**The Semantic Token Rule.** Never hardcode a color in a screen; use the semantic token. Code today violates this with `AppColors.*` constants used directly (see gaps).
**The One Accent Rule.** `color/primary` is the only brand accent in a theme. `color/lilac` and `color/cyan` are fixed accents shared by all themes, not alternates for primary.

## Typography

**Figma families:** Inknut Antiqua (titles), Manrope (body), Plus Jakarta Sans (interface). Reader only: Literata (serif reading), Lexend (dyslexia preset). **Code today:** Inknut Antiqua is applied to everything through `ThemeData.fontFamily`; the other four families are not bundled in `pubspec.yaml`.

### Hierarchy
Flutter targets are proposed mappings; none exist in `AppTheme` yet.

| Style (Figma) | Family | Weight | Size dp | Line height | Letter spacing | Flutter target |
|---|---|---|---|---|---|---|
| `Display/Hero` | Inknut Antiqua Bold | 700 | 48 | 120% | 0% | `textTheme.displayLarge` |
| `Título/1` | Inknut Antiqua SemiBold | 600 | 32 | 130% | 0% | `textTheme.headlineMedium` |
| `Título/2` | Inknut Antiqua SemiBold | 600 | 24 | 135% | 0% | `textTheme.headlineSmall` |
| `Título/3` | Inknut Antiqua Medium | 500 | 20 | 140% | 0% | `textTheme.titleLarge` |
| `Corpo/Grande` | Manrope Regular | 400 | 18 | 160% | 0% | `textTheme.bodyLarge` |
| `Corpo/Padrão` | Manrope Regular | 400 | 16 | 160% | 0% | `textTheme.bodyMedium` |
| `Corpo/Pequeno` | Manrope Regular | 400 | 14 | 150% | 0% | `textTheme.bodySmall` |
| `Interface/Botão` | Plus Jakarta Sans SemiBold | 600 | 14 | 120% | 0% | `textTheme.labelLarge` |
| `Interface/Rótulo` | Plus Jakarta Sans Medium | 500 | 13 | 130% | 0% | `textTheme.labelMedium` |
| `Interface/Legenda` | Plus Jakarta Sans Medium | 500 | 12 | 130% | 0% | `textTheme.labelSmall` |
| `Interface/Sobrelinha` | Plus Jakarta Sans Bold | 700 | 11 | 130% | 12% | none |
| `Leitura/Serifa` | Literata Regular | 400 | 19 | 180% | 0% | none |
| `Leitura/Dislexia` | Lexend Regular | 400 | 20 | 180% | 5% | none |

The Figma styles prefixed `Legado/Gatuno/*` (Inknut Antiqua only) are superseded and excluded.

## Layout

Mobile frames are 390×844 with a bottom navigation bar and sheets instead of side menus (page "04 · Telas Mobile (App)", frame `859:30`). The desktop/web layout uses a fixed side menu at 1200px and above (frame `912:2803`), at 1440px width.

Spacing scale (same in every theme): `space/xs` 4, `space/sm` 8, `space/md` 12, `space/lg` 16, `space/xl` 20, `space/2xl` 24, `space/3xl` 40 dp. Mobile section content uses 16 dp horizontal padding (`space/lg`) in the Home frame `913:1380`. No spacing tokens exist in code.

## Elevation & Depth

Flat with glass. Figma effect styles: `Vidro/Leve` (blur 4), `Vidro/Médio` (blur 8), `Vidro/Overlay` (blur 12), `Vidro/Dropdown` (blur 8 + shadow 0/4/12 `#00001280`), `Vidro/Painel` (blur 24 + shadow 0/12/40 `#00000066`). Menus use `color/context-menu-bg`; scrims use `color/overlay`. Code has only `GatunoColors.shadowColor` and no blur tokens.

## Shapes

Radius scale: `radius/sm` 4, `radius/md` 8, `radius/lg` 12, `radius/xl` 16, `radius/pill` 999 dp. Code uses a literal 8 (md) only in `snackBarTheme`.

## Components

Figma component library (page "02 · Componentes", node `857:6123`), mapped to code. Mapping is by role; a component named here may not exist or may be built differently.

| Figma component | Role | Code (lib/) |
|---|---|---|
| `Botão` | Button | `shared/components/atoms/app_button.dart` |
| `Tag`, `Filtro/Tag`, `Filtro/Ativo` | Tags and filter chips | `shared/components/atoms/app_status_badge.dart` (nearest; no filter chip atom) |
| `Livro/Capa` | Cover image | `shared/components/atoms/app_image.dart`, `app_image_placeholder.dart` |
| `Livro/Card` | Book card | `features/books/presentation/components/molecules/` |
| `Paginação/Página` | Pagination | `shared/components/molecules/pagination.dart` |
| `Shell/Header` | App bar | `features/home/presentation/components/organisms/home_app_bar.dart` |
| `Shell/Item de navegação`, `Shell/Menu lateral` | Navigation | `shared/components/atoms/app_nav_bar_item.dart`, `molecules/app_bottom_nav_bar.dart`, `organisms/navigation_shell.dart` |
| `Home/Destaque` | Featured carousel | `features/home/presentation/components/organisms/featured_carousel.dart` |
| `Seção/Cabeçalho` | Section header | `features/home/presentation/components/molecules/home_section_header.dart` |
| `Capítulo/Item`, `Capítulo/Grupo`, `Capítulo/Status`, `Capítulo/Download` | Chapter list | `features/books/presentation/components/` |
| `Menu de contexto/*` | Context menus (glass) | no shared component |
| `Leitor/*` | Reader chrome | `features/reading/presentation/components/{molecules,organisms,templates}/` |
| `Avaliação/*`, `Histórico/*` | Ratings, reading history | no code counterpart found |

Added in issue #52 (page "02 · Componentes", local, not yet published): `Campo/Texto` (`app_text_field`, Estado=Padrão/Foco/Erro), `Avatar/Perfil` (`app_avatar`, initials only) and `Lista/Item` (settings row). Switch rows reuse the reader's `Leitor/Item de ajuste`.

Also in code but not in Figma: `app_switch`, `app_skeleton`, `app_loading_indicator`, `app_error_view`, `app_cta_card`, `certificate_trust_dialog`.

States: only states drawn in Figma are specified. Figma defines the tokens `color/hover` and the `-10`/`-15`/`-40` tints for interaction states, but per-component state mapping has not been audited here; do not invent pressed, disabled or focus treatments, flag them as missing instead.

## Do's and Don'ts

### Do
- **Do** reference semantic token names (`color/primary`, `radius/md`, `Título/2`) when describing or reviewing UI.
- **Do** keep text on `color/primary` in `color/on-primary`.
- **Do** respect the sensitive-content preference from Settings; Figma shows the visible-sensitive state in frame `925:4590` (uses the `Bandeira` component).
- **Do** support EN and PT strings through ARB keys, with room for longer Portuguese labels.

### Don't
- **Don't** introduce colors, radii, spacing or fonts that have no Figma variable or style; record a gap instead.
- **Don't** use the `Gatuno / The Cheap Weekly` collection (redesign exploration) as product tokens.
- **Don't** treat the current `AppTheme` values as the target where they differ from Figma.

## Figma vs code gaps

- **fonts-not-bundled**: Manrope, Plus Jakarta Sans, Literata and Lexend are used by Figma text styles but are not declared in pubspec.yaml; only Inknut Antiqua is bundled.
- **text-theme-uncustomized**: AppTheme sets fontFamily only; no TextTheme roles map to the Figma text styles.
- **light-theme-diverges**: AppTheme.lightTheme uses lilac primary, white surface and darkPurple onSurface; Figma Light uses #cc5e00 primary, #eeeeee background and #2b2d31 text.
- **themes-missing**: True-dark, Dracula and Slate exist in Figma but not in AppTheme; no theme-selection mechanism exists in code.
- **on-primary-dark**: Dark onPrimary is #000212 in code; Figma color/on-primary is #fdfdfd in every theme.
- **error-role**: colorScheme.error is orange (#f18522) in both code themes; Figma color/danger is #f12237 (Dark) / #ff0000 (Light). Code keeps danger only in GatunoColors.scrapingStatusError.
- **outline-divider-values**: outline and divider use opaque grays in code; Figma border/divider are translucent text-color tints.
- **secondary-role**: colorScheme.secondary is darkPurple (Dark) / beige (Light) in code; Figma color/secondary is #181a1f / #e0e0e0. Proposed mapping to surfaceContainerHighest is not implemented.
- **tokens-without-code**: text-secondary, text-muted, hover, warning, lilac, cyan, alpha ramps, radius/*, space/*, Vidro effects and reader themes have no ThemeData/ThemeExtension counterpart.
- **badge-colors-not-in-figma**: GatunoColors badge colors (badgeDefault, badgeSearch, badgeType, badgeExcluded, badgeSensitive, badgePublication, badgeAuthor) and AppColors.gray*/badge* constants have no Figma variable; the Figma Tag/Filtro components should be inspected before mapping.
- **degrader-not-in-figma**: GatunoColors.degrader gradient has no Figma style.
- **figma-surfaces-empty**: Figma mobile sections 3 (Library/Profile), 4 (Auth) and 5 (Settings) have frames since issue #52 (Dark theme only, key states). Still without frames: web sections 3 (Auth) and 4 (Settings), web /library and /users/:userId, and the code-only welcome and certificates screens.
- **routes-differ**: Figma routes /library, /users/:userId and /latest-reads have no matching code routes; Figma /auth/login, /auth/register, /user and /users/:userId map to code /auth/signin, /auth/signup, /settings and /settings/profile under different names. Code-only routes without Figma frames: /settings/certificates, /chapters/:id, /chapters/:id/page/:index, /requests, /requests/create and /welcome.
- **cheap-weekly-exploration**: Collection 'Gatuno / The Cheap Weekly' (press-black palette) is a redesign exploration and is excluded from tokens.
