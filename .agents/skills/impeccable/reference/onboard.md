> **Additional context needed**: the "aha moment" you want users to reach, and users' experience level.

Get users to first value as fast as possible. Onboarding's job is not to teach the product. Its job is to get people to the moment that proves the product is worth their time.

## Assess Onboarding Needs

Understand what users need to learn and why:

1. **Identify the challenge**:
   - What are users trying to accomplish?
   - What's confusing or unclear about current experience?
   - Where do users get stuck or drop off?
   - What's the "aha moment" we want users to reach?

2. **Understand the users**:
   - What's their experience level? (Beginners, power users, mixed?)
   - What's their motivation? (Excited and exploring? Required by work?)
   - What's their time commitment? (5 minutes? 30 minutes?)
   - What alternatives do they know? (Coming from competitor? New to category?)

3. **Define success**:
   - What's the minimum users need to learn to be successful?
   - What's the key action we want them to take? (First project? First invite?)
   - How do we know onboarding worked? (Completion rate? Time to value?)

Onboarding should get users to value as quickly as possible, not teach everything possible.

## Onboarding Principles

Follow these core principles:

### Show, Don't Tell
- Demonstrate with working examples, not just descriptions
- Provide real functionality in onboarding, not separate tutorial mode
- Use progressive disclosure, teach one thing at a time

### Make It Optional (When Possible)
- Let experienced users skip onboarding
- Don't block access to product
- Provide "Skip" or "I'll explore on my own" options

### Time to Value
- Get users to their "aha moment" ASAP
- Front-load most important concepts
- Teach 20% that delivers 80% of value
- Save advanced features for contextual discovery

### Context Over Ceremony
- Teach features when users need them, not upfront
- Empty states are onboarding opportunities
- Tooltips and hints at point of use

### Respect User Intelligence
- Don't patronize or over-explain
- Be concise and clear
- Assume users can figure out standard patterns

## Design Onboarding Experiences

Create appropriate onboarding for the context:

### Initial Product Onboarding

**Welcome Screen**:
- Clear value proposition (what is this product?)
- What users will learn/accomplish
- Time estimate (honest about commitment)
- Option to skip (for experienced users)

**Account Setup**:
- Minimal required information (collect more later)
- Explain why you're asking for each piece of information
- Smart defaults where possible
- Platform sign-in options when appropriate

**Core Concept Introduction**:
- Introduce 1-3 core concepts (not everything)
- Use simple language and examples
- Interactive when possible (do, don't just read)
- Progress indication (step 1 of 3)

**First Success**:
- Guide users to accomplish something real
- Pre-populated examples or templates
- Celebrate completion (but don't overdo it)
- Clear next steps

### Feature Discovery & Adoption

**Empty States**:
Instead of blank space, show:
- What will appear here (description + screenshot/illustration)
- Why it's valuable
- Clear CTA to create first item
- Example or template option

Example:
```
No projects yet
Projects help you organize your work and collaborate with your team.
[Create your first project] or [Start from template]
```

**Contextual Tooltips**:
- Appear at relevant moment (first time user sees feature)
- Point directly at relevant UI element (`Tooltip`, anchored overlay, or coach mark)
- Brief explanation + benefit
- Dismissable (with "Don't show again" option)
- Optional "Learn more" action

**Feature Announcements**:
- Highlight new features when they're released
- Show what's new and why it matters
- Let users try immediately
- Dismissable

**Progressive Onboarding**:
- Teach features when users encounter them
- Badges or indicators on new/unused features
- Unlock complexity gradually (don't show all options immediately)

### Guided Tours & Walkthroughs

**When to use**:
- Complex interfaces with many features
- Significant changes to existing product
- Industry-specific tools needing domain knowledge

**How to design**:
- Spotlight specific UI elements (dim the rest of the screen with an overlay)
- Keep steps short (3-7 steps max per tour)
- Allow users to click through tour freely
- Include "Skip tour" option
- Make replayable (help menu)

**Best practices**:
- Interactive over passive (let users tap real buttons)
- Focus on workflow, not features ("Create a project" not "This is the project button")
- Provide sample data so actions work

### Interactive Tutorials

**When to use**:
- Users need hands-on practice
- Concepts are complex or unfamiliar
- High stakes (better to practice in safe environment)

**How to design**:
- Sandbox environment with sample data
- Clear objectives ("Create a chart showing sales by region")
- Step-by-step guidance
- Validation (confirm they did it right)
- Graduation moment (you're ready!)

### Documentation & Help

**In-product help**:
- Contextual help links throughout interface
- Searchable help section
- Video tutorials for complex workflows

**Help patterns**:
- Help icon (with `tooltip`) near complex features
- "Learn more" links in tooltips

## Empty State Design

Every empty state needs:

### What Will Be Here
"Your recent projects will appear here"

### Why It Matters
"Projects help you organize your work and collaborate with your team"

### How to Get Started
[Create project] or [Import from template]

### Visual Interest
Illustration or icon (not just text on a blank screen)

### Contextual Help
"Need help getting started? [Watch 2-min tutorial]"

**Empty state types**:
- **First use**: Never used this feature (emphasize value, provide template)
- **User cleared**: Intentionally deleted everything (light touch, easy to recreate)
- **No results**: Search or filter returned nothing (suggest different query, clear filters)
- **No permissions**: Can't access (explain why, how to get access or open system settings)
- **Error state**: Failed to load (explain what happened, retry option)

## Implementation Patterns

### Technical approaches:

**Tooltips and hints**: `Tooltip`, `OverlayEntry`/`CompositedTransformFollower` for anchored coach marks
**Tours**: a lightweight overlay driven by a ViewModel; avoid adding a package for a few steps
**Sheets and dialogs**: `showModalBottomSheet`, `showDialog`; support back/dismiss and TalkBack/VoiceOver focus
**Progress tracking**: persist "seen" flags through the app's existing local storage layer, exposed via a ViewModel
**Analytics**: Track completion and drop-off points if the app already has analytics

Show onboarding once: track completion and respect dismissals. All copy goes through l10n ARB (`lib/l10n`, EN and PT, feature-prefixed keys). Reuse shared components (`AppButton`, ...) and respect `MediaQuery.disableAnimationsOf(context)` for any animated steps.

**Avoid**:
- Force users through long onboarding before they can use product
- Patronize users with obvious explanations
- Show same tooltip repeatedly (respect dismissals)
- Block all UI during tour (let users explore)
- Create separate tutorial mode disconnected from real product
- Overwhelm with information upfront (progressive disclosure!)
- Hide "Skip" or make it hard to find
- Forget about returning users (don't show initial onboarding again)

## Verify Onboarding Quality

Test with real users:

- **Time to completion**: Can users complete onboarding quickly?
- **Comprehension**: Do users understand after completing?
- **Action**: Do users take desired next step?
- **Skip rate**: Are too many users skipping? (Maybe it's too long or not valuable)
- **Completion rate**: Are users completing? (If low, simplify)
- **Time to value**: How long until users get first value?

When users hit the aha moment fast and don't drop off, hand off to `/impeccable polish` for the final pass.
