# Product

## Platform
Flutter (Material 3, Dart): Android and iOS. Mobile is one of two first-class clients; the other is the Gatuno web app (same backend, same design tokens, see `DESIGN.md`).

## Users
A small trusted group sharing one self-hosted Gatuno server: self-hosters and a private circle. Today two people use the same server, one preferring the web client and one the mobile client. Confirmed with the maintainer; there is no public sign-up audience assumed.

## Product Purpose
Gatuno Manga is a reader for manga and books hosted on the user's own server. The mobile app browses the library, tracks reading progress, and reads chapters, with progress synced across devices.

## Positioning
Self-hosted: the user supplies their own server URL on first launch (`/welcome`), validated against `/health/liveness`. Nothing is tied to a public hosted service.

## Operating Context
- First launch asks for the API URL; the app is then usable as a guest on `/home` without signing in.
- Signing in adds profile and synced reading progress (real-time sync over MQTT).
- Long reading sessions on a phone, including late at night.
- Self-signed certificates are possible on private servers (the app has a certificate trust flow).

## Capabilities and Constraints
- Content types in the product: image chapters, markdown text, and documents (PDF and EPUB are marked as proposals in Figma).
- Sensitive content: books can be flagged sensitive; a Settings toggle controls whether it is shown. Default behaviour is not recorded here (undecided in this file; check code before relying on it).
- Languages: English and Portuguese (ARB keys, feature-prefixed). Portuguese strings run longer.
- Book requests exist as a feature (`/requests`).
- Design source of truth: the Gatuno Figma file (see `DESIGN.md`). Some surfaces (library, profile, auth, settings) have no Figma frames yet.

## Brand Commitments
- Name: Gatuno. Brand orange `#F18522`.
- Title typeface: Inknut Antiqua.

## Evidence on Hand
- Figma file `QlUrvomONqwfefHCwTg0Hh` (tokens in `.impeccable/design.json`).
- App icons and fonts under `assets/`.
- No usage analytics, user research or store listing are in the repo; do not fabricate them.

## Product Principles
Only what is confirmed: the app works without an account; the user owns their server; reading comfort comes first (themes, accessibility presets in the reader).

## Accessibility & Inclusion
The Figma reader includes an accessibility settings sheet with a dyslexia-friendly preset (Lexend, Creme theme) and a reading ruler (frames `882:910`, `882:959`). No formal standard (such as WCAG level) has been stated; record one here when decided.
