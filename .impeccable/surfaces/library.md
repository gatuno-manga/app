# Surface: Library

Anchors a single app surface for `/impeccable critique` and related commands. Facts come from the Gatuno Figma file (page "04 · Telas Mobile (App)", file key `QlUrvomONqwfefHCwTg0Hh`) and the repo; frames were drawn in issue #52 from the existing mobile frames, using only existing components and tokens (Dark theme only). Token keys refer to `.impeccable/design.json`.

## Route
- Figma: `/library` (mobile section `859:36`, "Biblioteca e Perfil — /library, /users/:userId")
- Code: no code route

## Figma frames
- `953:2419` /library — mobile (saved books, tabs Lendo / Salvos / Concluídos, three `Core/Molecule/Livro/Card` list items)
- `953:2492` /library — mobile · vazio
- `1112:8220` /library — mobile · barra recolhida (`Collapsed root` state)
- `1112:8281` /library — mobile · em breve (antes do #130): the placeholder tab the app ships until #130 builds the screen
- `1112:8305` /library — mobile · visitante: sign-in prompt

## Figma components used
- `App/Organism/Shell/Barra superior` Type=Expanded root (search, avatar or user icon) and `App/Organism/Shell/Barra inferior` with Biblioteca selected (#169, #170; code in #251 and #172)
- `Core/Atom/Livro/Aba` → tabs (Ativa / Inativa)
- `Core/Molecule/Livro/Card` (Type=List) → `features/books/presentation/components/molecules/`
- `Core/Atom/Botão` (Primary) → empty-state action
- `Core/Atom/Ícone/bookmark` → empty-state icon

## Code
No code exists for `/library`. The closest code surface is `/books` (`lib/features/books/books_router.dart`), which lists all books, not the user's saved ones.

Shell (#172): the Biblioteca tab is the placeholder `LibraryPage` (`lib/features/library/`, route `/library`, empty state from frame `1112:8281`, same for guests and signed-in users) until #130 replaces the view.

## Tokens used
- `color/app-background`
- `color/text`
- `color/text-secondary`
- `color/text-muted`
- `color/primary`
- `Título/2`
- `Corpo/Padrão`
- `Corpo/Grande`
- `Corpo/Pequeno`
- `Interface/Botão`

## States in Figma
- Loaded: tabs plus list of saved books.
- Empty: icon, message and a primary action to explore books. The tabs are hidden in this state (a choice, not a code fact).
- Collapsed top bar (`1112:8220`), the placeholder shipped before #130 (`1112:8281`, "A sua biblioteca chega em breve.") and the guest sign-in prompt (`1112:8305`).
- No loading or error frame.

## Accessibility
- Secondary text about 5.0:1 (little headroom) on `color/app-background` (Dark). Empty-state icon uses `color/text-muted`; check its contrast manually.
- `Core/Atom/Livro/Aba` tabs are 40 dp high and 43-77 dp wide, below the 44 dp tap target; the component is shared with the book page, so it is recorded here, not changed.
- `color/on-primary` on `color/primary` is about 2.5:1 (see `on-primary-dark` in DESIGN.md); it affects the `Explorar livros` button and the chapter badges.

## Tablet frames (issue #171)

Page "05 · Telas Tablet (App)" (`1100:8297`), window size classes in DESIGN.md (Layout).

- Medium: `1107:9618` and `1107:9911` (vazio). Expanded: `1107:9781` and `1107:9976` (vazio).
- Components: `App/Organism/Shell/Trilho de navegação` (`1112:9248`, 80 dp, three destinations, replaces the bottom bar from 600 dp up) with Biblioteca selected (the second of three destinations; until #130 ships the tab is a placeholder); `App/Organism/Shell/Barra superior` Expanded root with the profile avatar in the last action slot; `Core/Atom/Livro/Aba` (Lendo, Salvos, Concluídos); `Core/Molecule/Livro/Card` List in 2 (medium) or 3 (expanded) columns; `Core/Atom/Botão` and `Core/Atom/Ícone/bookmark` in the empty state.
- Reference for #130; no code task in #168 builds it. Guests see the tab with a sign-in prompt (#169 decision); not drawn.

## Gaps (Figma vs code)
- The empty frame is tab-agnostic: it hides the tabs and says the whole library is empty, which would be wrong for a user with saved books under another tab. A per-tab empty state is not drawn.
- The `Cap. N` badge is ambiguous (user progress or latest chapter) and no progress indicator is drawn. The subtitle "Seus livros salvos" overlaps the "Salvos" tab. All three cards reuse the same cover as mock content.
- No code route or screen for `/library`; the frames are a design proposal, except the placeholder `1112:8281`, which is the screen planned to ship before #130. The placeholder and guest copy have no l10n keys yet.
- Tab labels (Lendo, Salvos, Concluídos), titles, subtitle and empty message are placeholder copy; no l10n keys exist.
- No web frame exists for `/library` (web section 1 names the route only).
