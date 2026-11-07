# Init flow

`init` captures durable product truth in PRODUCT.md. It does not invent a visual world and does not write DESIGN.md; [new-work.md](new-work.md) creates or expands one, and [document.md](document.md) records an incumbent one.

This project is a native Flutter app (Material 3, Dart). There is no context CLI: read PRODUCT.md and DESIGN.md directly from the repo root if they exist. They may not exist yet; never invent them from memory.

## Step 1: Load current state

Check for PRODUCT.md and DESIGN.md at the repo root. Update an existing PRODUCT.md instead of creating a competing authority.

- **No PRODUCT.md:** explore, interview, and write it.
- **PRODUCT.md exists:** ask what product knowledge is stale or missing; do not reopen confirmed fields without a reason.
- **Only DESIGN.md exists:** leave it untouched and create PRODUCT.md.
- **Redesign/rebrand request:** preserve confirmed product truth unless the user changes it. Visual replacement happens later in new-work, not here.

Never silently overwrite an existing file or offer DESIGN.md during init. If another request invoked init, finish PRODUCT.md and resume it.

## Step 2: Explore the project

Before asking, scan enough to avoid making the user repeat known facts: README and docs; `pubspec.yaml`; feature folders under `lib/features/`; screens under `presentation/views/`; the existing theme in `lib/core/theme`; l10n ARB strings in `lib/l10n` (they reveal product voice and terminology); logos and assets; and accessibility signals (Semantics usage, text scaling handling).

Treat repository evidence as a hypothesis, not user approval. Note visual maturity without documenting, extending, or replacing the world.

Platform is Android and iOS, with desktop optional. Confirm only if the repo contradicts that.

## Step 3: Interview for product truth

Ask the user directly about what you cannot infer, and only about material gaps. Use the structured question tool when available; otherwise ask and wait. Keep rounds to at most three focused questions and require one real answer before writing a new PRODUCT.md. Confirm inferences.

If no answer mechanism exists, probe once with the real first round before concluding nobody is there. Only after that may you infer from the explicit brief, and then label every inferred fact in PRODUCT.md and say so in your first reply.

Start with the unknowns that most change future decisions:

1. Who is the primary user, in what situation, and what job are they doing?
2. What does the product make possible, and what is its meaningfully different mechanism or position?
3. What durable constraints, assets, evidence, or product facts must future work preserve?

Add a round only for a material audience, brand, evidence, or accessibility gap. Record undecided facts instead of inventing them. Do not ask for an aesthetic direction, feel, references, colors, typography, or style during init. If the user volunteers a binding visual constraint, record it without expanding it.

### What belongs here

- users, jobs, workflows, purpose, success, positioning, operating context;
- capabilities, constraints, terminology, evidence, platform, accessibility;
- confirmed voice, assets, and brand commitments.

### What does not belong here

- visual worlds, palettes, typography, components, or screen concepts;
- invented testimonials, customers, benchmarks, pricing, licensing, or store claims;
- a requirement to decide every optional field.

## Step 4: Write PRODUCT.md

Write only confirmed facts and explicitly marked open decisions. Omit irrelevant sections rather than filling them with generic prose.

```markdown
# Product

## Platform
Flutter (Material 3, Dart): Android, iOS, desktop optional.

## Users
[Primary users, their situation, and job. Add other audiences only when confirmed.]

## Product Purpose
[What the product does, why it exists, and what success means.]

## Positioning
[The mechanism or claim a neighboring product could not truthfully copy.]

## Operating Context
[Workflows, environments, devices, connectivity, and rituals that are factual parts of using the product.]

## Capabilities and Constraints
[Confirmed functionality, technical constraints, terminology, and explicitly undecided facts.]

## Brand Commitments
[Existing name, voice, assets, personality, and references the user made binding. Omit when none.]

## Evidence on Hand
[Real content, data, and assets, with paths. State absences that future work must not fabricate.]

## Product Principles
[Three to five durable strategic principles from confirmed answers; no visual recipes.]

## Accessibility & Inclusion
[Known user needs or required standard. Omit when none was established.]
```

New files go at the repo root as `PRODUCT.md`. Write it before any visual-world or screen-concept work. Also load [android.md](android.md) and [ios.md](ios.md) before design work.

### Completion gate

Before loading new-work or resuming shape, verify PRODUCT.md exists and contains the confirmed record. If absent, init is incomplete. Do not substitute interview notes or later design prose for the file.

## Step 5: Wrap up or resume

Summarize captured and deliberately undecided facts. Do not offer DESIGN.md merely because it is missing. Recommend the next action from the real project state:

- Early project: ask for the screen to be built, or use `/impeccable shape <screen>` for a confirmed brief without implementation.
- Existing coherent UI without DESIGN.md: `/impeccable document` records the incumbent system.
- Existing screen needing work: name the most relevant scoped command (`audit`, `polish`, `critique`).

If init was invoked by another request, resume that request; new-work owns later visual decisions.
