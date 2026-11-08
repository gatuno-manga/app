# Surface: Library

Anchors a single app surface for `/impeccable critique` and related commands. Facts come from the Gatuno Figma file (page "04 · Telas Mobile (App)", file key `QlUrvomONqwfefHCwTg0Hh`) and the repo; frames were drawn in issue #52 from the existing mobile frames, using only existing components and tokens (Dark theme only). Token keys refer to `.impeccable/design.json`.

## Route
- Figma: `/library` (mobile section `859:36`, "3 · Biblioteca e Perfil")
- Code: no code route

## Figma frames
- `953:2419` /library — mobile (saved books, tabs Lendo / Salvos / Concluídos, three `Livro/Card` list items)
- `953:2492` /library — mobile · vazio

## Figma components used
- `Shell/Header` (Plataforma=Mobile)
- `Livro/Aba` → tabs (Ativa / Inativa)
- `Livro/Card` (Tipo=Lista) → `features/books/presentation/components/molecules/`
- `Botão` (Primário) → empty-state action
- `Ícone/bookmark` → empty-state icon

## Code
No code exists for `/library`.

## Tokens used
- `color/app-background`
- `color/text`
- `color/text-secondary`
- `color/text-muted`
- `color/primary`
- `Título/2`
- `Corpo/Padrão`
- `Interface/Botão`

## States in Figma
- Loaded: tabs plus list of saved books.
- Empty: icon, message and a primary action to explore books.
- No loading or error frame.

## Accessibility
- Not audited. Empty-state icon uses `color/text-muted`; check its contrast against `color/app-background` manually.

## Gaps (Figma vs code)
- No code route or screen for `/library`; the frames are a design proposal.
- Tab labels (Lendo, Salvos, Concluídos), titles, subtitle and empty message are placeholder copy; no l10n keys exist.
- No web frame exists for `/library` (web section 1 names the route only).
