# Shape

Discover what should be made and how it should work, then return a confirmed design brief without code.

## Phase 1: Discovery interview

Do not write code or choose visual direction yet.

### Cadence

- Use the structured question tool when available; otherwise ask and stop.
- Ask two or three related questions per round, then wait. One round is the default; add a second only when the answers expose a material gap.
- Do not dump a questionnaire, repeat settled facts, or turn obvious facts into menus. Assert the likely reading and invite correction.
- A sparse prompt requires at least one answer round. A precise prompt may need only a compact confirmation.
- Read PRODUCT.md and DESIGN.md first if they exist; they settle product and visual truth, not this screen's purpose.

### Round 1: purpose, people, and outcome

Choose the two or three questions that most change the result:

- What is this screen or feature for, and what problem must it solve?
- Who reaches it, in what situation (one hand, walking, offline, low light) and state of mind?
- What is the primary thing they must understand or do? What would success look like?
- What is uniquely true here that a neighboring app or generic template could not claim?

### Round 2: material, behavior, and boundaries

Run only for material unresolved decisions:

- What real content, data, and assets must it carry? Realistic minimum, typical, and maximum ranges (empty list, 3 items, 3,000 items, very long titles)?
- Which states and transitions matter: first-run, empty, loading, error, success, permissions, offline, overflow?
- What fidelity and breadth: exploration, production-ready screen, full flow?
- What must remain untouched? What would make the result feel wrong even if it looked polished?
- Which constraints are binding: platform behavior, accessibility, localization (EN and PT), or an existing ViewModel/API?

Never ask for raw color or size values or canned aesthetic lanes. New-work owns visual and structural direction.

## Phase 2: Resolve the design direction

For new screens or a changed visual identity, follow [new-work.md](new-work.md) through visual authority and structure choice. Reuse discovery, then return before implementation. Inside an established world, use its structure process only when composition or interaction is still materially open.

## Phase 3: Write the brief

Write the smallest useful brief:

1. **Job and audience:** who arrives, their context and need.
2. **Outcome and proof:** primary task, success, real content, product-specific truth.
3. **Selected direction:** visual authority, structural thesis, focal moment, implementation consequence.
4. **Scope and boundaries:** fidelity, breadth, interactivity, named target, what stays untouched, anti-goals.
5. **States and ranges:** realistic content ranges and material states.
6. **Interaction and layout:** hierarchy, structure across phone/tablet/desktop size classes, affordances, feedback, transitions; intent, not widget code.
7. **Placement and constraints:** which shared components to reuse (AppButton, AppTextField, AppSkeleton, AppErrorView, ...), which new atoms/molecules/organisms are needed and where they sit, the ViewModel involved, l10n keys, accessibility needs, and choices a builder must not invent.

Use three to five bullets when the task is settled; use the full structure only for ambiguous, multi-screen, or standalone planning. Do not restate the conversation.

## Confirm and stop

Present the brief for explicit confirmation or one correction round, then stop: shape never writes code.

When no human or structured answer mechanism exists, mark assumptions plainly, return the brief, and stop.
