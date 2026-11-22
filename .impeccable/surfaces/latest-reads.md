# Surface: Latest reads

Anchors a single app surface for `/impeccable critique` and related commands. Facts come from the Gatuno Figma file (page "04 · Telas Mobile (App)", file key `QlUrvomONqwfefHCwTg0Hh`) and the repo; nothing here is new design. Token keys refer to `.impeccable/design.json`.

## Route
- Figma: /latest-reads — mobile
- Code: no code route (`/latest-reads` does not exist in `lib/`)

## Figma frames
- `926:7037` /latest-reads — mobile
- `926:7198` /latest-reads — mobile · vazio

## Figma components used
- `Shell/Barra superior` Tipo=Empilhada (back, "Últimas leituras", search, more) and `Shell/Barra inferior` with Início selected, since the screen is pushed from "Ver tudo" on Home (#169, #170; code in #251 and #172)
- `Histórico/Data` → date group header
- `Histórico/Item` → history entry
- `Histórico/Capítulo`
- `Leitor/Botão ícone`
- `Botão` → empty-state action
- `Ícone/clock` → empty-state icon

## Code
Not implemented in code. Web frames exist too (`925:4328` history, `925:4590` sensitive visible, `925:4849` empty, `925:4955` loading).

## Tokens used
- `color/app-background`
- `color/text`
- `color/text-secondary`
- `color/primary`
- `Título/2`
- `Corpo/Padrão`
- `Interface/Rótulo`
- `Interface/Legenda`

## States in Figma
- History list grouped by date (3 groups, 4 items).
- Empty state, frame `926:7198`.
- Web only: sensitive content visible, loading.

## Accessibility
- Not audited.

## Gaps (Figma vs code)
- Surface is designed in Figma but has no route or code.
- Mobile has no loading or sensitive-visible frame (web does).
