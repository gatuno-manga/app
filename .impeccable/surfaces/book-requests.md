# Surface: Book requests

Anchors a single app surface for `/impeccable critique` and related commands. Facts come from the Gatuno Figma file (page "04 · Telas Mobile (App)", file key `QlUrvomONqwfefHCwTg0Hh`) and the repo; frames were drawn in issue #129 (Dark theme only). Token keys refer to `.impeccable/design.json`.

## Route
- Figma: frames in the section "Solicitações — /requests e /requests/create (#129)" (`1052:38112`); the Figma route map has no entry for these routes
- Code: `/requests` (list) and `/requests/create` (form), `lib/features/book_requests`; home links to `/requests` for signed-in users and to `/auth/signin?redirect=/requests` for guests

## Figma frames
- `1052:38263` /requests — mobile (three cards, one per status)
- `1052:38389` /requests — mobile · carregando mais (cards plus the pagination `App/Atom/Indicador de carregamento`)
- `1052:38518` /requests — mobile · primeira carga (four skeleton cards from `App/Atom/Esqueleto`, intended look)
- `1052:38593` /requests — mobile · erro (`App/Molecule/Vista de erro`, intended look)
- `1052:38640` /requests — mobile · vazio (`App/Molecule/Cartão de chamada` look, intended)
- `1052:39703` /requests/create — mobile · vazio (submit disabled)
- `1052:39757` /requests/create — mobile · preenchido
- `1052:39811` /requests/create — mobile · erro de campo (invalid URL, submit disabled)
- `1052:39865` /requests/create — mobile · enviando (button shows the spinner)
- `1052:39920` /requests/create — mobile · erro do servidor (form-level message in `color/danger`)

## Figma components used
- `App/Molecule/Solicitação/Cartão` (new local component set, `1052:38038`; Status=Pending/Approved/Rejected, text properties Title/URL/Reason/Rejection/Date, booleans Show reason/Show rejection) → `BookRequestCard`
- `Core/Atom/Tag` (extended in #129 with Type=Pending/Approved/Rejected, `895:209`) → `AppStatusBadge`
- `App/Atom/Campo/Texto` (State=Default/Error) → `AppTextField`
- `Core/Atom/Botão` Primary → `AppButton`
- `App/Atom/Esqueleto`, `App/Atom/Indicador de carregamento`, `App/Molecule/Vista de erro`, `App/Molecule/Cartão de chamada` (components from #126)
- `App/Molecule/Solicitação/Cartão de esqueleto` (#265, `1124:9446`): the four loading cards of `/requests` · primeira carga and carregando mais
- `App/Organism/Shell/Barra superior` Type=Stacked (back, left-aligned "Solicitações", "+" action) and `App/Organism/Shell/Barra inferior` with Início selected on the five `/requests` frames, drawn in #170 (code in #251 and #172); the five `/requests/create` frames draw `App/Organism/Shell/Barra superior` Type=Stacked (back, left-aligned "Novo Pedido", no actions) and `App/Organism/Shell/Barra inferior` with Início selected, redrawn in #260 (code in #251 and #172)

## Code
`lib/features/book_requests/presentation/views/{book_requests_list_page,create_book_request_page}.dart`, `components/molecules/book_request_card.dart`, `components/organisms/create_book_request_form.dart`; `lib/shared/components/atoms/app_status_badge.dart`.

Shell (#172): `/requests` and `/requests/create` are mounted under every tab root (`/home/requests`, `/library/requests`, `/books/requests`), keep the bar and the opener's tab; the old top-level paths redirect to the Home copy.

## Tokens used
- `color/app-background`
- `color/text`
- `color/text-muted`
- `color/primary`
- `color/on-primary`
- `color/danger`
- `color/danger-15`
- `color/danger-40`
- `color/success`
- `color/success-15`
- `color/success-40`
- `color/warning`
- `color/warning-15`
- `color/warning-40`
- `color/secondary-60`
- `color/border`
- `color/text-10`
- `radius/lg`
- `space/sm`
- `space/lg`
- `space/xl`
- `Título/3`
- `Corpo/Pequeno`
- `Interface/Botão`
- `Interface/Rótulo`
- `Interface/Legenda`

## States in Figma
- /requests: default, loading more, first load (skeleton), error, empty. /requests/create: empty, filled, field error, submitting, server error.
- The disabled submit button is drawn as 38% opacity, the same approximation as `App/Molecule/Seletor segmentado`.
- Not drawn: pull-to-refresh, the success SnackBar after submitting (`bookRequestsSuccess`), the guest path through sign-in (only the home link redirects; the routes have none).

## Accessibility
- Measured by computing the pairs over the card (`color/secondary-60` over `color/app-background`): `color/text` is 10.3:1 or more in every theme. See `figma-contrast` in DESIGN.md for the status tags (1.2-8.7:1 on their tints; `color/warning` in Light is the worst at 1.2:1, `color/success` is 2.2-2.8:1 in Dark, True-dark and Light and `color/danger` 2.5-3.0:1 in Light and Dracula), the link in `color/primary` (3.2:1 in Light) and `color/text-muted` metadata (2.5-4.48:1).
- The "+" action and the back button are 48 dp targets; the code "+" is an `IconButton` without a tooltip or semantic label.

## Tablet frames (issue #171)

Page "05 · Telas Tablet (App)" (`1100:8297`), window size classes in DESIGN.md (Layout).

- Not drawn. `/requests` and `/requests/create` are reached from the Home card and from a Settings row; they are pushed screens, so on tablets they keep the rail and use `App/Organism/Shell/Barra superior` Stacked with text content 720 dp wide at most.

## Gaps (Figma vs code)
- First load, error and empty are drawn in the intended look; code uses a bare `CircularProgressIndicator`, an icon with red text and a raw `ElevatedButton.icon`, and a `Icons.inbox_outlined` empty state.
- `BookRequestCard` is a Material `Card` (elevation 2); Figma uses the flat `color/secondary-60` card with a `color/border` outline.
- Code status badge is `labelSmall` bold on a 20% tint with a 50% border; Figma `Core/Atom/Tag` uses `Interface/Rótulo` on 15% and 40% tint tokens.
- Figma has no info or calendar icon in the icon library: the reason row uses `Core/Atom/Ícone/file-text` and the date `Core/Atom/Ícone/clock` where code uses `Icons.info_outline` and `Icons.calendar_today`.
- Code `AppButton` is 48 dp high; Figma `Core/Atom/Botão` is 44 dp.
- The `/requests` frames draw the native `App/Organism/Shell/Barra superior` and `App/Organism/Shell/Barra inferior` of #169 (#170); the `/requests/create` frames draw them too since #260. Entry points are the Home card and a row in the merged profile and settings screen.

## Implementation status (#251)
- #251: the list and create screens use `AppTopBar` (Stacked); the entries are the Home card and the row on `/settings`.
