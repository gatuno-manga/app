---
name: Gatuno
description: Flutter client for the self-hosted Gatuno Manga reader; tokens sourced from the Gatuno Figma file.
theme:
  source: lib/core/theme/theme.dart
  figma: https://www.figma.com/design/QlUrvomONqwfefHCwTg0Hh/Gatuno
  tokens: .impeccable/design.json
  seed: "palette.primary of each theme"
  fontFamily: "Inknut Antiqua"
  extensions: [GatunoColors]
---

# Design System: Gatuno

**Source of truth: the Figma file, not the code.** Values below come from the Figma variable collections `Gatuno / Tokens (código)` and `Gatuno / Leitura (temas)` and the Figma text and effect styles. `AppTheme` (`lib/core/theme/theme.dart`, palettes in `app_palette.dart`, text styles in `app_typography.dart`) implements it; remaining drifts are collected in [Figma vs code gaps](#figma-vs-code-gaps). This intentionally overrides the `document` reference's "theme code is normative" rule for this repository (issue #40). Machine-readable tokens, with Figma names, live in `.impeccable/design.json`; the two files must agree (`python3 tool/check_design_tokens.py`).

## Overview

**Creative North Star:** not decided. The Figma file does not name one and none was confirmed; do not invent one.

The Figma system is dark-first: warm cream text (`#e9e1d1`) on near-black blue (`#000212`) with one orange accent (`#f18522`), serif titles (Inknut Antiqua), and glass (blurred translucent) surfaces for menus, sheets and overlays. Five themes share one set of semantic token names; only the values change.

**Key Characteristics:**
- Semantic tokens first: components reference `color/primary`, never a raw hex.
- Translucent tints (`-10`, `-15`, `-40` alpha ramps) instead of separate light/dark shades.
- Three type voices: Inknut Antiqua (titles), Manrope (body), Plus Jakarta Sans (interface labels); reader-only Literata and Lexend.
- Flat surfaces; depth comes from glass blur and one shadow style, not from layered elevation.

## Colors

Five themes (Figma modes of `Gatuno / Tokens (código)`, table at node `884:104`). All five are implemented as `AppTheme` builders (`lightTheme`, `darkTheme`, `trueDarkTheme`, `draculaTheme`, `slateTheme`); `main.dart` applies the choice persisted from the Settings swatch grid (System, Light, Dark, True-dark, Dracula, Slate; System follows the OS).

| Token (Figma) | CSS var | Dark | Light | True-dark | Dracula | Slate | Flutter target | Code vs Figma |
|---|---|---|---|---|---|---|---|---|
| `color/app-background` | `--app-background-color` | `#000212` | `#eeeeee` | `#000000` | `#282a36` | `#15161a` | `colorScheme.surface + scaffoldBackgroundColor` | match |
| `color/text` | `--app-text-color` | `#e9e1d1` | `#2b2d31` | `#e9e1d1` | `#f8f8f2` | `#f8fafc` | `colorScheme.onSurface` | match |
| `color/text-secondary` | `--app-text-color-secondary` | `#e9e1d18c` | `#2b2d31a6` | `#e9e1d173` | `#6272a4` | `#94a3b8` | `GatunoColors.palette.textSecondary` | match |
| `color/text-muted` | `--app-text-color-muted` | `#fdfdfd73` | `#2b2d3173` | `#fdfdfd59` | `#f8f8f273` | `#f8fafc73` | `GatunoColors.palette.textMuted` | match |
| `color/primary` | `--primary-color` | `#f18522` | `#cc5e00` | `#f18522` | `#bd93f9` | `#f18522` | `colorScheme.primary` | match |
| `color/secondary` | `--secondary-color` | `#181a1f` | `#e0e0e0` | `#181a1f` | `#44475a` | `#212329` | `colorScheme.surfaceContainerHighest` | match |
| `color/border` | `--border-color` | `#e9e1d126` | `#2b2d311f` | `#e9e1d11a` | `#f8f8f226` | `#f8fafc26` | `colorScheme.outline` | match |
| `color/hover` | `--hover-color` | `#e9e1d114` | `#2b2d310f` | `#e9e1d10f` | `#f8f8f214` | `#f8fafc14` | `GatunoColors.palette.hover` | match |
| `color/divider` | (none) | `#e9e1d11a` | `#2b2d311a` | `#e9e1d112` | `#f8f8f21a` | `#f8fafc1a` | `dividerTheme.color` | match |
| `color/context-menu-bg` | `--context-menu-bg` | `#000212cc` | `#ffffffe5` | `#000000e5` | `#282a36e5` | `#15161ae5` | `GatunoColors.contextMenuBackground` | match |
| `color/overlay` | `--overlay-bg` | `#000000b2` | `#0000004d` | `#000000d9` | `#000000bf` | `#000000b2` | `GatunoColors.overlayBackground` | match |
| `color/on-primary` | `--white` | `#fdfdfd` | `#fdfdfd` | `#fdfdfd` | `#fdfdfd` | `#fdfdfd` | `colorScheme.onPrimary` | match |
| `color/danger` | `--danger-color` | `#f12237` | `#ff0000` | `#f12237` | `#ff5555` | `#ef4444` | `colorScheme.error` | match |
| `color/warning` | `--warning-color` | `#ffc107` | `#ffc107` | `#ffc107` | `#ffb86c` | `#f59e0b` | `GatunoColors.palette.warning` | match |
| `color/success` | `--success-color` | `#157219` | `#28a745` | `#157219` | `#50fa7b` | `#10b981` | `GatunoColors.scrapingStatusReady` | match |
| `color/lilac` | `--lilac` | `#a972ff` | `#a972ff` | `#a972ff` | `#a972ff` | `#a972ff` | `GatunoColors.palette.lilac` | match |
| `color/cyan` | `--cyan` | `#17a2b8` | `#17a2b8` | `#17a2b8` | `#17a2b8` | `#17a2b8` | `GatunoColors.palette.cyan` | match |
| `color/on-lilac` | (none) | `#000212` | `#000212` | `#000212` | `#000212` | `#000212` | `AppPalette.onLilac` | match |

Alpha ramps (same hue as their base token, fixed opacity; values per theme in `design.json`): `color/primary-10`, `color/primary-15`, `color/primary-40`, `color/lilac-15`, `color/lilac-40`, `color/success-15`, `color/success-40`, `color/danger-10`, `color/danger-15`, `color/danger-40`, `color/warning-15`, `color/warning-40`, `color/cyan-15`, `color/cyan-40`, `color/secondary-45`, `color/secondary-60`, `color/text-10`, `color/text-40`, `color/app-background-2`, `color/app-background-3`, `color/app-background-40`, `color/app-background-75`.

### Reader themes
`Gatuno / Leitura (temas)` has four modes (Padrão, Sépia, Creme, Alto contraste) with `leitura/fundo`, `leitura/superficie`, `leitura/texto`, `leitura/texto-suave`, `leitura/acento`, `leitura/destaque`, `leitura/borda`. They apply only inside the reader (frame `882:910` uses Creme with the dyslexia preset). Code: `ReaderPalette` (`lib/core/theme/reader_palette.dart`, a `ThemeExtension`) holds Sépia, Creme and Alto contraste as constants; Padrão is built from the active `AppPalette` (`ReaderPalette.fromAppPalette`), so it follows the chosen app theme. The text reader applies the chosen palette to its own subtree through `ReaderThemeScope` (`features/reading/presentation/theme/`), which overrides `colorScheme.surface`, `onSurface`, `primary`, `outline` and the container roles; the image reader does not use it yet.

### Intentionally fixed colors
Raw (unbound) solid paints in the mobile frames of page "04 · Telas Mobile (App)" that stay fixed on purpose, so a later check for unbound paints does not flag them again. Machine-readable list: `fixedColors` in `.impeccable/design.json`. As of issue #144 no other unbound solid paint was found in these frames.

| Where | Colors | Why fixed |
| --- | --- | --- |
| `Marca/Logo` main component (`909:46`) | `#000212`, `#20142a` (30% opacity), `#f18522` | Brand art: the mark looks the same in every theme. |
| `Bandeira` instances (origin flags, `Idioma=pt-BR/en/es/ja`; found by component name) | flag colors (`#219e45`, `#ffd900`, `#002675`, `#00247d`, `#c70f2e`, `#ab141c`, `#fabf00`, and `#ffffff`, `#bd002e`) | Flags are fixed by nature. |
| `Livro/Capa` origin flag (JP; found by component name) | `#ffffff`, `#bd002e` | Same: a flag. |
| Sections of the Leitor board and the notes inside it (`983:3725`) | section fill `#444444`, section stroke `#ffffff` at 10%, note text `#ffffff` at 90% | Canvas annotation chrome, not app UI. |
| Drawer scrim in Home (`913:1538`, `sidebar-overlay`) | `#000212` at 50% | Pending removal: the drawer goes away with #169 (tracked in #168). |

### Named Rules
**The Semantic Token Rule.** Never hardcode a color in a screen; use the semantic token. Code today violates this with `AppColors.*` constants used directly (see gaps).
**The One Accent Rule.** `color/primary` is the only brand accent in a theme. `color/lilac` and `color/cyan` are fixed accents shared by all themes, not alternates for primary.

## Typography

**Figma families:** Inknut Antiqua (titles), Manrope (body), Plus Jakarta Sans (interface). Reader only: Literata (serif reading), Lexend (dyslexia preset); the reader font picker also offers Atkinson Hyperlegible and OpenDyslexic (see gap `reader-fonts-not-in-figma`). **Code:** all five families are bundled (`assets/fonts/`, declared in `pubspec.yaml`, OFL licences alongside; Manrope also at 500/600/700 and Literata/Lexend at 700 so Material bold does not synthesize). Inknut Antiqua stays the `ThemeData.fontFamily` fallback for roles Figma does not define; `AppTypography.textTheme` maps the Figma styles.

### Hierarchy
Styles without a Material role (target column below) are exposed as `AppTypography.overline`, `readingSerif` and `readingDyslexia`; `overline` also needs upper-casing by the caller.

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
| `Interface/Sobrelinha` | Plus Jakarta Sans Bold | 700 | 11 | 130% | 12% | `AppTypography.overline` |
| `Leitura/Serifa` | Literata Regular | 400 | 19 | 180% | 0% | `AppTypography.readingSerif` |
| `Leitura/Dislexia` | Lexend Regular | 400 | 20 | 180% | 5% | `AppTypography.readingDyslexia` |

The Figma styles prefixed `Legado/Gatuno/*` (Inknut Antiqua only) are superseded and excluded.

## Layout

Mobile frames are 390×844 with a bottom navigation bar and sheets instead of side menus (page "04 · Telas Mobile (App)", frame `859:30`). The desktop/web layout uses a fixed side menu at 1200px and above (frame `912:2803`), at 1440px width.

Spacing scale (same in every theme): `space/xs` 4, `space/sm` 8, `space/md` 12, `space/lg` 16, `space/xl` 20, `space/2xl` 24, `space/3xl` 40 dp. Mobile section content uses 16 dp horizontal padding (`space/lg`) in the Home frame `913:1380`. No spacing tokens exist in code.

## Elevation & Depth

Flat with glass. Figma effect styles: `Vidro/Leve` (blur 4), `Vidro/Médio` (blur 8), `Vidro/Overlay` (blur 12), `Vidro/Dropdown` (blur 8 + shadow 0/4/12 `#00001280`), `Vidro/Painel` (blur 24 + shadow 0/12/40 `#00000066`). Menus use `color/context-menu-bg`; scrims use `color/overlay`. Code has only `GatunoColors.shadowColor` and no blur tokens.

## Shapes

Radius scale: `radius/sm` 4, `radius/md` 8, `radius/lg` 12, `radius/xl` 16, `radius/pill` 999 dp. Code has no radius tokens; literals on this scale appear in `snackBarTheme` (8) and the icon segmented control (8 tile, 12 pill).

## Components

Figma component library (page "02 · Componentes", node `857:6123`), mapped to code. Mapping is by role; a component named here may not exist or may be built differently.

| Figma component | Role | Code (lib/) |
|---|---|---|
| `Botão` | Button | `shared/components/atoms/app_button.dart` |
| `Seletor segmentado` | Two-option single choice | `shared/components/molecules/app_labeled_segmented_button.dart` |
| `Aviso/Snackbar` | SnackBar | `snackBarTheme` in `core/theme/theme.dart` |
| `Livro/Resumo de downloads` | Book download summary | `features/books/presentation/components/` (planned in issue #93) |
| `Capítulos/Barra de seleção`, `Capítulos/Ações da seleção` | Chapter selection bars | `features/books/presentation/components/` (planned in issue #93) |
| `Diálogo/Confirmação` | Confirmation dialog | `shared/components/organisms/app_confirm_dialog.dart`, actions in `shared/components/atoms/app_text_button.dart` (both planned in issue #147) |
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
| `Leitor/Item de ajuste`, `Leitor/Tema de leitura` | Reader settings sheet rows (Seletor, Passos) and theme swatches | `features/reading/presentation/components/molecules/reader_setting_row.dart`, `atoms/reader_theme_swatch.dart`, `organisms/reader_settings_sheet.dart` |
| `Interruptor/Item` | Settings row with a switch (reader, book sheet, Settings, App lock) | `shared/components/molecules/app_switch_row.dart` (target; `atoms/app_switch.dart` and `reader_switch_row.dart` collapse into it, see gap `components-code-differences`) |
| `Esqueleto` | Loading placeholder, block or text line | `shared/components/atoms/app_skeleton.dart`, `atoms/app_text_skeleton.dart` |
| `Indicador de carregamento` | Circular spinner | `shared/components/atoms/app_loading_indicator.dart` |
| `Vista de erro` | Full-screen error with retry and back | `shared/components/molecules/app_error_view.dart` |
| `Cartão de chamada` | Call-to-action card | `shared/components/molecules/app_cta_card.dart` |
| `Diálogo/Confiar em certificado` | Trust an untrusted server certificate | `shared/components/organisms/certificate_trust_dialog.dart` |
| `Rádio/Item` | Single-choice row with a leading radio (app lock grace period) | Material `RadioListTile` in `features/app_lock/presentation/views/app_lock_settings_screen.dart` (no shared atom yet) |
| `Avaliação/*`, `Histórico/*` | Ratings, reading history | no code counterpart found |

Added in issue #52 (page "02 · Componentes", local, not yet published): `Campo/Texto` (`app_text_field`, Estado=Padrão/Foco/Erro), `Avatar/Perfil` (`app_avatar`, initials only) and `Lista/Item` (settings row). Switch rows used the reader's `Leitor/Item de ajuste` until issue #126 added `Interruptor/Item`.

Added in issue #162 (page "02 · Componentes", local, not yet published):
- `Seletor segmentado` (`996:5077`; Selecionado=1/2, Estado=Padrão/Desabilitado; text properties Opção 1/Opção 2): single choice between two always-visible options, drawn in the shape of Material's `SegmentedButton`. 48 dp container with a `color/border` outline, `radius/md`, joined full-height segments and a 1 dp `color/border` divider; the selected segment has a `color/primary-40` fill, an 18 dp check and a `color/text` label (`Interface/Botão`); unselected labels are `color/text`; disabled is drawn as 38% layer opacity (approximates Material's disabled colors: label and icon `onSurface` at 38%, outline at 12%). Code (issue #95): `AppLabeledSegmentedButton` (check shown, optional description line) styled by the global `segmentedButtonTheme` in `theme.dart` (48 dp `minimumSize`, `color/primary-40` selected fill, `color/text` labels, radius 8), which also styles `books_columns_picker`, `books_navigation_mode_picker` and the `SegmentedButton` in `books_option_filter`.
- `Aviso/Snackbar` (`997:1294`; text properties Mensagem/Ação, boolean Mostrar ação): floating SnackBar, `color/lilac` fill, `color/on-lilac` text and action, `radius/md`, `Corpo/Pequeno` message, optional `Interface/Botão` action with a 48 dp target. Code: `snackBarTheme` in `theme.dart`.
- Variable `color/on-lilac` (`#000212` in every mode) for text and icons on `color/lilac`, matching `AppPalette.onLilac`.

Added in issue #165 (page "02 · Componentes", local, not yet published):
- `Diálogo/Confirmação` (`1010:1327`; Variante=Padrão/Destrutivo; text properties Título and Corpo; exposed `Botão` Variante=Texto instances `cancelar` and `confirmar`): shared confirmation, used by the multi-chapter delete of #93/#165 and the server change of #147. 310 dp panel (the `AlertDialog` default inset of 40 on a 390 dp phone), `color/context-menu-bg` with a 1 dp `color/text-10` border and `Vidro/Painel`, `radius/xl`, padding `space/2xl` (bottom `space/lg`), gap `space/lg`, over a `color/overlay` scrim. Title `Título/3`, body `Corpo/Pequeno`, both `color/text`. Actions aligned right, `space/sm` apart: text buttons with `space/md` horizontal padding and a 48 dp target; Cancelar `color/text`, Confirmar `color/primary` (Padrão) or `color/danger` (Destrutivo). Tapping outside or back cancels. Numbers and units are joined by a no-break space. Code target (issue #147): `AppConfirmDialog` as an `AlertDialog` (`backgroundColor` context-menu background, `surfaceTintColor` transparent, `RoundedRectangleBorder` radius 16 with the `text-10` side, shadow approximated with `elevation` and `shadowColor`; `titleTextStyle` titleLarge and `contentTextStyle` bodySmall set explicitly; paddings title 24,24,24,0, content 24,16,24,0, actions 24,16,24,16; the glass blur is optional in code), and `AppTextButton` with neutral, primary and danger tones (`minimumSize` 0x48). The tones are instance overrides in Figma, since `Botão` Variante=Texto has no tone property and is 44 dp high.
- `Capítulo/Download` (`895:304`, extended in place): the chapter tile's trailing download indicator. Variants Baixar (`color/text-secondary`), Pendente (clock, `color/warning`), Baixando (24 dp ring: `color/text-10` track, `color/primary` arc for filesDone/filesTotal, pause glyph), Aguardando rede (wifi, `color/warning`), Aguardando conexão (cloud-off, `color/warning`; wins over waiting for Wi-Fi when the server is unreachable), Pausado (`color/text-secondary` ring with a play glyph), Falhou (alert-circle, `color/danger`) and Baixado (check, `color/success`). 40x24 visual inside a 48x48 touch area. Code target (issue #93): the trailing widget of `chapter_tile.dart`; #93 colours every indicator icon and status text with `theme.legible()`, including the text-secondary states (`theme.legible(theme.mutedColor)`), unlike the tile's current unread icon, which uses raw `mutedColor`.
- `Livro/Resumo de downloads` (`1023:1377`; Estado=Ativo/Aguardando conexão/Pausado/Falhou/Concluído): the book's download summary between the description and the chapter list, shown only when the book has downloads. Same card as the chapter tiles (`color/secondary-60`, `color/border`, `radius/lg`); "X de Y capítulos baixados · size" in `Interface/Botão` (Y is the book's `totalChapters`; when it is null, "X capítulos baixados · size"), a status line in `Interface/Legenda` ("Aguardando Wi-Fi" when every active chapter waits for Wi-Fi), one contextual text action in `color/primary` (Pausar tudo, Retomar, Tentar de novo (N)), and a 4 dp linear bar (`color/text-10` track, `radius/pill`) measuring the summed files of the active chapters.
- `Capítulos/Barra de seleção` (`1023:1378`): selection-mode top bar that replaces the back button: close, the count in `Título/3`, select loaded; 48 dp buttons on `color/app-background` with a `color/divider` bottom edge.
- `Capítulos/Ações da seleção` (`1023:1388`; booleans Mostrar Pausar/Retomar/Tentar de novo): selection-mode bottom bar with labelled actions (icon over `Interface/Legenda`), Excluir in `color/danger`; `color/context-menu-bg` with `Vidro/Overlay` and a `color/border` top edge.
- Icons `Ícone/wifi`, `wifi-off`, `cloud-off`, `pause`, `play`, `check-check` and `square` (Lucide, 2 dp stroke, `color/text`), in frame `1019:460` beside the icon library on page "01 · Padronizações".

Added in issue #126 (page "02 · Componentes", local, not yet published; x=8500 column, y from 2600). All fills, strokes, radii and paddings are bound to `Gatuno / Tokens (código)` variables; text uses the Figma text styles; drawn in Dark and checked in the other four modes by computing the pairs (contrast notes in `figma-contrast`):
- `Interruptor/Item` (`1047:1388`; Ícone=Sim/Não, Estado=Ligado/Desligado; boolean Mostrar descrição): settings row with a trailing switch. Built from the former `Leitor/Item de ajuste` Controle=Switch frames, so the 22 instances on the reader, book sheet, Settings and web frames were swapped to it with their text kept; the two old variants are deleted and `Leitor/Item de ajuste` keeps Seletor and Passos. 64 dp row with a 40 dp `color/hover` icon tile (`radius/md`), `Interface/Botão` title in `color/text`, `Interface/Legenda` description in `color/text-secondary`, 40x22 track (`color/primary` on, `color/border` off, `radius/pill`) and an 18 dp knob (`color/on-primary` on, `color/text-secondary` off). Ícone=Não drops the tile (60 dp). The whole row toggles. Replaces `AppSwitch` (plain `SwitchListTile`) and `AppSwitchRow`/`ReaderSwitchRow`.
- `Esqueleto` (`1048:1822`; Forma=Bloco/Linha de texto): placeholder in `color/text-10`, `radius/sm`; Bloco is 160x96, Linha de texto is 160 dp wide with a 16 dp bar and 4 dp vertical margin; size is set on the instance. Merges `AppSkeleton` and `AppTextSkeleton`.
- `Indicador de carregamento` (`1048:1829`; Tamanho=Pequeno 20/Padrão 24/Grande 40): open 270° arc, 2 dp stroke, `color/primary`, no track, with the sizes callers pass to `AppLoadingIndicator` (20 inside buttons, 24 in the load-more footer, 40 for a page).
- `Vista de erro` (`1048:7787`; text property Mensagem): 390 dp wide, content centered with `space/lg` padding and gaps, message in `Corpo/Padrão` `color/text`, `Botão` Primário "Tentar novamente" and `Botão` Texto "Voltar" (instances of the `Botão` set).
- `Cartão de chamada` (`1048:7849`; Nota=Sim/Não, Estado=Padrão/Desabilitado): 358 dp card in the style of `Livro/Resumo de downloads` (`color/secondary-60`, 1 dp `color/border`, `radius/lg`, padding `space/xl`, gap `space/sm`): `Título/3` title, `Corpo/Pequeno` description, optional `Interface/Legenda` note in `color/text-secondary`, and a right-aligned `Botão` Primário with an icon. Desabilitado is drawn as 38% opacity on the button (the same approximation as `Seletor segmentado`), and the note says why.
- `Diálogo/Confiar em certificado` (`1048:7850`): `Diálogo/Confirmação` Padrão with the name field between message and actions: `Título/3` "Certificado não confiável", `Corpo/Pequeno` message naming the host, `Campo/Texto` Nome filled with the host, and the text buttons Ignorar and Confiar (`color/primary`). It does not close on a tap outside (code `barrierDismissible: false`).

Added in issue #127 (page "02 · Componentes", local, not yet published): `Rádio/Item` (`1052:37854`; Selecionado=Sim/Não; text property Rótulo): 342x56 row for a `RadioListTile`, 16 dp side padding, a 40 dp radio target with a 20 dp ring (2 dp stroke, `color/primary` with a 10 dp dot when selected, `color/text-secondary` otherwise), `space/lg` gap and a `Corpo/Grande` label in `color/text`. Icon `Ícone/lock` (`1052:39975`, Lucide style, next to `Ícone/clock`). App lock frames live in the section "Bloqueio do app (/settings/app-lock)" (`1052:38698`) of page "04 · Telas Mobile (App)"; see `.impeccable/surfaces/settings.md`.

Added in issue #128 (page "02 · Componentes", local, not yet published; x=8500 column, y=5400), bound to `Gatuno / Tokens (código)` variables and drawn in Dark:
- `Caixa de seleção` (`1052:37844`; Marcada=Sim/Não; boolean Mostrar rótulo, text Rótulo): Material `Checkbox` / `CheckboxListTile` (used for "Eu guardei estes códigos" on the MFA backup-codes screen). 18 dp box inside a 48 dp row, `radius/sm`; marked is a `color/primary` fill with a 2 dp `color/on-primary` check, unmarked is a 2 dp `color/text-secondary` outline; label in `Corpo/Padrão` `color/text`. Only the two states the code has; no disabled, hover or focus. The code has no atom for it yet.
- `Botão` Variante=Contorno (`895:194`, already in the set; 44 dp, `color/border` 1 dp outline, `radius/md`, `Interface/Botão` label, optional icon) is the Figma counterpart of the planned `AppOutlinedButton` (#101, still open) and of the raw `OutlinedButton` the MFA settings screen builds today. The danger flavour in code is `AppButtonVariant.outlinedDanger` (48 dp, `color/danger` label); the MFA frames use Contorno with a `color/danger` label for Desativar.

Book-details frames live in the section "Livro — ficha do livro (/books/:id)" (`1037:7224`) of page "04 · Telas Mobile (App)"; the page's sections are no longer numbered. The book sheet's switch row is `AppSwitchRow` (Figma `Interruptor/Item`; it was the reader's `Leitor/Item de ajuste` before #126), and "Excluir download" is `AppButton` with `AppButtonVariant.outlinedDanger` (48 dp; Figma `Botão` Contorno is 44 dp).

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

- **figma-contrast**: Figma tokens fail WCAG AA 4.5:1 in places and AppTheme follows them as the source of truth. color/on-primary (#fdfdfd) on color/primary: 2.5:1 in Dark, True-dark and Slate, 2.4:1 in Dracula, 4.0:1 in Light. On color/danger: 3.1:1 Dracula, 3.7:1 Slate, 3.9:1 Light, 4.1:1 Dark and True-dark. color/text-secondary on color/app-background: 4.3:1 Light, 3.6:1 True-dark, 3.0:1 Dracula (Dark and Slate pass). color/text-muted: 2.5:1 Light, 3.0:1 True-dark, 4.0:1 Dracula, 4.4:1 Dark and Slate. Needs a Figma decision; PRODUCT.md has no WCAG target yet. color/border as the only outline of a control (`Seletor segmentado` border and divider) is 1.2-1.6:1 against color/app-background, below the 3:1 non-text guideline; the labels and the check icon carry the state. color/primary and color/danger as text on color/context-menu-bg (Diálogo/Confirmação actions) in Light: 3.8:1 and 3.7:1; the other themes pass. Download states drawn with raw tokens on the chapter card (color/secondary-60 over color/app-background), below 4.5:1: color/warning 1.3:1 in Light; color/success 2.5:1 in Light and 3.1:1 in Dark and True-dark; color/danger 3.2:1 in Light, 3.5:1 in Dracula and 4.4:1 in Slate; color/text-secondary 2.3:1 in Dracula, 3.8:1 in True-dark and 4.1:1 in Light. Issue #93 colours these icons and status texts with theme.legible(), which reaches at least 5.4:1 on the card in every theme. color/primary as the download summary's action text on the card: 3.2:1 in Light. color/danger as delete-action labels on color/context-menu-bg in Light: 3.9:1 for the selection bar and as drawn over the page, about 3.5:1 for sheets over the modal barrier in code, 3.7:1 for the dialog over the scrim. In Dark, True-dark and Slate the dialog panel is nearly the colour of the scrimmed background, so only the color/text-10 border (1.2-1.4:1) outlines it. Lilac pairings (snackbar, tertiary) use color/on-lilac (#000212, AppPalette.onLilac in code), 6.4:1 on color/lilac. Components from issue #126 (all measured by computing the pairs from the variable values): the Interruptor/Item knob in color/on-primary on the color/primary track is 2.5:1 in Dark, True-dark and Slate, 2.4:1 in Dracula and 4.0:1 in Light (non-text guideline is 3:1); the off track color/border against color/app-background is 1.2-1.6:1 and the off knob color/text-secondary on that track is 1.9:1 in Dracula (3.7-4.6:1 elsewhere); Esqueleto color/text-10 against the background is 1.2-1.35:1 (decorative placeholder, no text); the Cartão de chamada note in color/text-secondary on the card is 2.3:1 in Dracula, 3.8:1 in True-dark and 4.1:1 in Light (Dark and Slate pass), and the card title and description in color/text pass in every theme (10.3:1 or more); the Cartão de chamada and Vista de erro primary buttons repeat the color/on-primary on color/primary pairs above; the Diálogo/Confiar em certificado action color/primary on the color/context-menu-bg panel over color/app-background is 4.0:1 in Light (the 3.8:1 above for Diálogo/Confirmação is measured over the scrim, where the panel is darker). Logo from issue #144 (measured from the variable values; the logo is fixed brand art, so its colors do not change with the theme): the `#000212` body of `Marca/Logo` is 1.0-1.4:1 against color/app-background in Dark, True-dark, Dracula and Slate, so the dark shapes disappear into the page there and only the orange parts read (17.8:1 in Light, where the shapes show); `#f18522` is 2.2:1 on color/app-background in Light (5.5-8.1:1 in the other themes). Both are brand decisions for Figma, not fixed here. App lock frames (issue #127, computed from the variable values against color/app-background): color/primary as the grace-period section header and as the selected `Rádio/Item` ring and dot is 8.0:1 in Dark, 8.1:1 in True-dark, 7.0:1 in Slate, 5.9:1 in Dracula and 3.5:1 in Light (the text is below 4.5:1 in Light; the 3:1 non-text guideline holds); color/danger as the lock cover error text is 4.9:1 in Dark, 5.0:1 in True-dark, 4.8:1 in Slate, 4.5:1 in Dracula and 3.4:1 in Light; color/text-secondary as the cancelled message and as the unselected `Rádio/Item` ring is 7.1:1 in Slate, 5.0:1 in Dark, 4.3:1 in Light, 3.6:1 in True-dark and 3.0:1 in Dracula (the ring just meets 3:1 in Dracula); the `Interruptor/Item` rows repeat the knob and track pairs above; the authenticating button repeats color/on-primary on color/primary at 60% opacity. MFA frames (issue #128, computed from the variable values): color/danger as the error message and the Desativar label on color/app-background is 4.9:1 Dark, 5.0:1 True-dark, 4.8:1 Slate, 4.5:1 Dracula and 3.5:1 Light; the Caixa de seleção unmarked outline (color/text-secondary, non-text guideline 3:1) is 5.0:1 Dark, 7.1:1 Slate, 4.2:1 Light, 3.6:1 True-dark and 3.0:1 Dracula; the marked box repeats the color/on-primary on color/primary pairs above and color/primary against the background is 3.5:1 in Light and 5.9-8.1:1 elsewhere.
- **components-code-differences**: The #126 components are drawn in the intended Figma look, so code differs and each item is a code follow-up. Interruptor/Item: one row with an optional icon replaces AppSwitch (plain SwitchListTile, used in Settings and App lock), AppSwitchRow and ReaderSwitchRow. Esqueleto: code fills with onSurfaceVariant at 30% alpha (AppSkeleton, AppTextSkeleton), Figma uses color/text-10; the two skeleton widgets merge. Indicador de carregamento: code defaults to the Material indeterminate indicator with strokeWidth 2 and takes the size from the caller (20 in AppButton, 24 in the load-more footer, 40 in the profile page, none elsewhere); Figma names the 20/24/40 dp sizes as variants. Vista de erro: code builds a raw ElevatedButton and TextButton with a message in the default text style; Figma uses the Botão Primário and Texto and Corpo/Padrão text (AppButton and AppTextButton in code). Cartão de chamada: code is a Material Card with elevation 2, a bold titleLarge title, a bodySmall note in onSurface instead of color/text-secondary, a 20 dp gap before the button instead of space/sm, and a FilledButton.icon; Figma is a flat card with a color/border outline, Título/3 and the Botão Primário. Diálogo/Confiar em certificado: code uses an AlertDialog with a raw TextField and an ElevatedButton for Confiar; Figma uses the Diálogo/Confirmação shape, Campo/Texto and text buttons. The disabled card button has no Figma treatment beyond 38% opacity. MFA screens (issue #128): mfa_settings_screen.dart builds raw OutlinedButton (with icons), TextButton, CheckboxListTile and AlertDialog; Figma uses Botão Contorno and Texto (AppOutlinedButton of #101, AppTextButton), Caixa de seleção (new AppCheckbox atom) and Diálogo/Confirmação, with the disable dialog's code field between message and actions (a detached copy; Diálogo/Confirmação has no field slot). The MFA code field has a leading shield icon that Campo/Texto lacks (an icon slot on AppTextField/Campo/Texto), the secret and backup codes use a monospace titleMedium with no Figma text style, the settings loading phase builds a raw CircularProgressIndicator where Figma uses Indicador de carregamento (AppLoadingIndicator), and both screens build a Material AppBar (until #169). Outlined-button icons (copy, open_in_new, share) cannot be swapped on the Figma instances.
- **fallback-text-roles**: Material text roles Figma does not define (displayMedium, displaySmall, headlineLarge, titleMedium, titleSmall) keep Material default sizes but render in Inknut Antiqua through ThemeData.fontFamily; bodySmall and other roles use onSurface, not color/text-secondary or color/text-muted. The mapped roles also change Material default sizes globally (bodyLarge 16->18, bodyMedium 14->16, bodySmall 12->14, labelMedium 12->13, labelSmall 11->12) with 150-160% line heights, so ListTile, TextField, dialog and chip text grow; check fixed-height rows at large text scales.
- **tokens-without-code**: radius/*, space/* and Vidro effects have no ThemeData/ThemeExtension counterpart.
- **reader-fonts-not-in-figma**: the reader font picker offers Atkinson Hyperlegible and OpenDyslexic (bundled under `assets/fonts/`, OFL) because the Figma `Fonte` dropdown lists them, but Figma has no text style for either; only `Leitura/Serifa` (Literata) and `Leitura/Dislexia` (Lexend) are styled.
- **badge-colors-not-in-figma**: GatunoColors badge colors (badgeDefault, badgeSearch, badgeType, badgeExcluded, badgeSensitive, badgePublication, badgeAuthor) and the AppColors.badge*Light constants have no Figma variable; the Figma Tag/Filtro components should be inspected before mapping.
- **degrader-not-in-figma**: GatunoColors.degrader gradient has no Figma style.
- **figma-surfaces-empty**: Figma mobile sections 3 (Library/Profile), 4 (Auth) and 5 (Settings) have frames since issue #52 (Dark theme only, key states). Still without frames: web sections 3 (Auth) and 4 (Settings), web /library and /users/:userId, and the code-only welcome and certificates screens. The MFA screens (`/auth/mfa`, `/settings/mfa`) have frames since issue #128, in their own sections on the same page (`1052:38039`, `1052:39164`); see `.impeccable/surfaces/mfa.md`.
- **routes-differ**: Figma routes /library, /users/:userId and /latest-reads have no matching code routes; Figma /auth/login, /auth/register, /user and /users/:userId map to code /auth/signin, /auth/signup, /settings and /settings/profile under different names. Code-only routes without Figma frames: /settings/certificates, /chapters/:id, /chapters/:id/page/:index, /requests, /requests/create and /welcome.
- **app-lock-code-differences**: The app lock frames (issue #127, section `1052:38698` of page 04) draw what the code does, so these are the differences and each is a code follow-up. The switch rows are `AppSwitch` (plain `SwitchListTile`), drawn as `Interruptor/Item` Ícone=Não. The grace-period choices are Material `RadioListTile`s in the theme's default colours, drawn as `Rádio/Item` (`color/primary` selected, `color/text-secondary` otherwise); code has no shared radio atom. `SettingsSectionHeader` is `titleMedium` bold in `color/primary` (16 dp); no text style matches, so the frames use `Interface/Botão` (14 dp SemiBold) in `color/primary`. The lock cover builds its title, description and error as inline `Text` (`headlineSmall`, `bodyMedium`, error in `color/danger`, or `color/text-secondary` after a cancel) and an `AppButton`; the authenticating frame shows `Botão` Primário at 60% opacity with `Ícone/loader` and no label, where code shows `AppLoadingIndicator` (20 dp, `color/on-primary`) in a disabled button. The cover uses the logo at 96 dp. The entry row in `/settings` uses `Lista/Item` with `Ícone/lock` (added in #127, Lucide style) where code uses `Icons.lock_outline`, and its description is cut to one line in Figma while the `ListTile` subtitle wraps. The Figma frames omit the SnackBar's behaviour (hidden before the next one) and the `Semantics` live regions on the cover and the unsupported text.
- **cheap-weekly-exploration**: Collection 'Gatuno / The Cheap Weekly' (press-black palette) is a redesign exploration and is excluded from tokens.
