### Purpose

Resolve one stable target, run a design review plus a code-evidence pass, synthesize a critique, and ask the user what to improve next. The chat response is the deliverable. Nothing is persisted.

### Hard Invariants

- Two assessments are required: A (design review) and B (code evidence). Do A first and record it before reading B's output, so deterministic findings do not anchor your judgment.
- If a sub-agent tool is exposed you may delegate A and B to two isolated agents; otherwise run them sequentially in this context. Either way, state the method on the report's first line: `Method: sequential (A then B)` or `Method: dual-agent`.
- For a headless or delegated run, print `Questions skipped: non-interactive run` instead.
- The question is the LAST thing in the response. Write the whole report first, then ask; nothing follows the question.
- A run that ends with neither targeted questions nor a literal `Questions skipped: <reason>` line is incomplete.

### Setup

1. **Resolve the target** to a concrete Dart file or feature folder. Prefer the screen file (`lib/features/<feature>/presentation/views/*_screen.dart`) and follow it into its components (`presentation/components/{atoms,molecules,organisms,templates}`), its ViewModel, and shared components under `lib/shared/components`.
   - "the settings screen" -> the `*_screen.dart` file and the widgets it composes
   - "the reader" -> the feature's screen plus its templates
2. **Read context if it exists**: `PRODUCT.md` and `DESIGN.md` at the repo root. They may not exist yet; never invent them. Also read `AppTheme` / `ThemeData` setup so you know the real tokens.
3. If the user marked areas as off-limits or already-decided, drop matching findings.

### Assessment A: Design Review

Read the relevant source and think like a design director. If a device or emulator run is available (`flutter run`), look at the real screen at least in light and dark; otherwise review from the widget tree.

Evaluate:
- **Design specificity**: is the composition, interaction, and visual language grounded in this product, or could an unrelated app use it unchanged? Judge this before seeing any analyzer output.
- **Holistic design**: hierarchy, information architecture, emotional fit, discoverability, composition, typography, color, accessibility, states (loading, empty, error), copy, and edge cases.
- **Cognitive load**: use the [Cognitive Load Assessment](#cognitive-load-assessment) below; report checklist failures and decision points with more than 4 visible options.
- **Emotional journey**: peak-end rule, valleys, reassurance at high-stakes moments.
- **Nielsen heuristics**: score all 10 per the [Heuristics Scoring Guide](#heuristics-scoring-guide), using `n/a` only where a heuristic genuinely cannot apply.

Return: design-specificity verdict, heuristic scores, cognitive load, emotional journey, 2-3 strengths, 3-5 priority issues, persona red flags, minor observations, provocative questions.

### Assessment B: Code Evidence

This replaces upstream's detector and visual overlay. Gather deterministic evidence from the code:

1. **Read the Dart code** of the target and grep `lib/` for the patterns in [flutter-checklist.md](flutter-checklist.md) (hardcoded `Color(0x...)`, inline `TextStyle`, tap targets, missing `Semantics`, non-`const` widgets, string literals instead of l10n keys, duplicated components).
2. **Run `flutter analyze`** (scoped to the target path when possible). Report counts and file:line locations. A clean analyzer is not a clean design; say so.
3. **Optional visual evidence**: a `flutter test` golden at compact and expanded widths, or an emulator/device screenshot (light, dark, text scale 1.5). Say which one produced the evidence; goldens and screenshots prove layout, not gestures or performance.

Return: analyzer output summary, checklist findings with `file:line`, false positives you ruled out, and any step you could not run with the concrete reason.

### Generate Combined Critique Report

Synthesize A and B; do not concatenate. Note where the review and the code evidence agree, where the code caught what the review missed, and which findings are false positives. Present the full report in chat, structured as a design director would.

#### Design Health Score

Present the 10 heuristics as a table:

| # | Heuristic | Score | Key Issue |
|---|-----------|-------|-----------|
| 1 | Visibility of System Status | ? | [specific finding or "n/a" if solid] |
| 2 | Match System / Real World | ? | |
| 3 | User Control and Freedom | ? | |
| 4 | Consistency and Standards | ? | |
| 5 | Error Prevention | ? | |
| 6 | Recognition Rather Than Recall | ? | |
| 7 | Flexibility and Efficiency | ? | |
| 8 | Aesthetic and Minimalist Design | ? | |
| 9 | Error Recovery | ? | |
| 10 | Help and Documentation | ? | |
| **Total** | | **??/[applicable max]** | **[Rating band]** |

The applicable maximum is 4 times the number of heuristics scored: **/40** when all ten apply, **/32** when two are `n/a`. Never print `/40` over a partial set. Be honest: a 4 means genuinely excellent; most real apps score 20-32 out of 40.

**Applicability**: heuristics 7 and 10 may be `n/a` on narrow surfaces (a splash, a single-purpose confirmation sheet), as may any heuristic that genuinely cannot apply. Write `n/a` with a one-line reason and renormalize the total.

#### Design Specificity Verdict

**Start here.** Does the result feel authored for this product, or category-interchangeable?
- **Review assessment**: your unanchored evaluation: coherence, structural sameness (identical card grids, default Material look with no point of view), category-interchangeable choices, missed opportunities for product character.
- **Code evidence**: analyzer counts, checklist hits with `file:line`, false positives.

#### Overall Impression
A brief gut reaction: what works, what doesn't, and the single biggest opportunity.

#### What's Working
2-3 things done well, with why they work.

#### Priority Issues
The 3-5 most impactful problems, ordered by importance. For each, tag **P0-P3** (see [Issue Severity](#issue-severity-p0p3)):
- **[P?] What**: name the problem clearly
- **Why it matters**: how it hurts users or goals
- **Fix**: concrete, naming the widget, theme role, or shared component to use
- **Suggested command**: from /impeccable adapt, animate, audit, bolder, clarify, colorize, critique, delight, distill, document, harden, layout, onboard, optimize, overdrive, polish, quieter, shape, typeset

#### Persona Red Flags
Pick 2-3 personas from [Persona-Based Design Testing](#persona-based-design-testing) using its selection table. If `PRODUCT.md` exists, add 1-2 project-specific personas from its audience info. Walk the primary user action as each persona and list the exact elements that fail them, for example: "Alex (Power User): reading list needs 3 taps to reach the primary action; no bulk select." Never write generic persona descriptions.

#### Minor Observations
Quick notes on smaller issues.

#### Questions to Consider
Provocative questions: "What if the primary action were more prominent?", "Does this need to feel this complex?", "What would a confident version look like?"

**Remember**: be direct and specific ("the submit AppButton", not "some elements"); say what is wrong AND why it matters; give concrete suggestions; prioritize ruthlessly; do not soften criticism.

### Ask the User

Ask in the same message as the report, report first, questions last. Use targeted questions based on what was found:

1. **Priority direction**: which category matters most (for example hierarchy, theming, information overload)? Offer the top 2-3 categories.
2. **Design intent**: if tone mismatched, was it intentional? Offer 2-3 tonal directions.
3. **Scope**: "I found N issues. Top 3 only, all issues, or critical only?"
4. **Constraints** (only if findings span many areas): anything off-limits?

Rules: every question references specific findings; 2-4 questions max; give 2-3 concrete options each; skipping is allowed only when the report listed **fewer than 3 Priority Issues**, in which case print `Questions skipped: <N> priority issues`. At 3 or more, questions are required.

### Recommended Actions

After the user answers, present a prioritized action summary:

1. **`/command-name`**: what to fix, with specific context from the findings
2. ...

Rules: only recommend commands from the list above; order by the user's stated priorities, then impact; skip commands that address zero issues; respect scope and off-limits; end with `/impeccable polish` if any fix was recommended. Then tell the user:

> You can ask me to run these one at a time, all at once, or in any order you prefer.
>
> Re-run `/impeccable critique` after fixes to see your score improve.

---

## Reference Material

### Cognitive Load Assessment

Cognitive load is the total mental effort an interface demands.

**Three types**:
- **Intrinsic**: the task's inherent complexity. Structure it: break into steps, provide defaults and examples, disclose progressively, group related decisions.
- **Extraneous**: bad design (confusing navigation, unclear labels, clutter, inconsistent patterns, needless steps). Eliminate ruthlessly.
- **Germane**: effort spent building understanding. Support it with consistent patterns, confirming feedback, and onboarding that teaches through action.

**Checklist** (8 items; count failures):
- [ ] **Single focus**: can the user complete the primary task without competing elements?
- [ ] **Chunking**: information in groups of 4 or fewer?
- [ ] **Grouping**: related items visually grouped (proximity, containers, shared surface)?
- [ ] **Visual hierarchy**: immediately clear what matters most?
- [ ] **One thing at a time**: a single decision before the next?
- [ ] **Minimal choices**: 4 or fewer visible options per decision point?
- [ ] **Working memory**: no need to remember a previous screen to act on this one?
- [ ] **Progressive disclosure**: complexity revealed only when needed?

**Scoring**: 0-1 failures = low load (good); 2-3 = moderate (address soon); 4+ = high (critical).

**Working memory rule**: humans hold about 4 items at once. Count the distinct options at any decision point: 4 or fewer is fine, 5-7 pushes it (group or disclose), 8+ overloads (users skip, mis-tap, or leave). In practice: one primary action, 1-2 secondary, the rest in an overflow menu; 5 or fewer top-level navigation destinations; one reading path per screen; one decision per screen on browse and detail views.

**Common violations**:
1. **Wall of options**: 10+ choices with no hierarchy. Group, highlight the recommended one, disclose progressively.
2. **Memory bridge**: step 3 needs info from step 1. Keep context visible or repeat it.
3. **Hidden navigation**: user must build a mental map. Show current location (active destination, progress indicator).
4. **Jargon barrier**: plain language; define unavoidable terms inline.
5. **Visual noise floor**: everything has equal weight. One primary element, 2-3 secondary, the rest muted.
6. **Inconsistent pattern**: similar actions behave differently. Same action, same UI.
7. **Multi-task demand**: reading, deciding, and navigating at once. Sequence the steps.
8. **Context switch**: jumping between screens or sheets to make one decision. Co-locate the information.

### Heuristics Scoring Guide

Score each of Nielsen's 10 heuristics 0-4. Anchors: 0 = absent or actively harmful, 1 = major gaps, 2 = partial (main flows ok, edges fail), 3 = good with minor gaps, 4 = genuinely excellent.

| # | Heuristic | Check for | 0 / 4 anchors |
|---|-----------|-----------|---------------|
| 1 | **Visibility of System Status** | Loading states (skeletons or progress, not frozen UI), confirmation of save/submit/delete, multi-step progress, current location in navigation, inline validation feedback | 0: user is guessing what happened. 4: every action confirms, progress always visible |
| 2 | **Match System / Real World** | Familiar terminology, logical order, recognizable icons and metaphors, language fit for the audience | 0: pure jargon. 4: speaks the user's language throughout |
| 3 | **User Control and Freedom** | Undo (for example a snackbar Undo action), cancel on sheets and dialogs, working system Back, easy way to clear filters and search, exits from multi-step flows | 0: user is trapped. 4: undo, cancel, back, and escape everywhere |
| 4 | **Consistency and Standards** | Same terms and actions everywhere, Material 3 conventions, consistent tokens and shared `App*` components, same gesture same result | 0: feels like different apps stitched together. 4: cohesive, predictable system |
| 5 | **Error Prevention** | Confirmation before destructive actions, input constraints (pickers, keyboard types), smart defaults, clear labels, draft recovery | 0: no guardrails. 4: errors nearly impossible |
| 6 | **Recognition Rather Than Recall** | Visible options, tooltips and hints, recent items, suggestions, text labels on icons (not icon-only navigation) | 0: users must memorize paths. 4: everything discoverable |
| 7 | **Flexibility and Efficiency** | Shortcuts and gestures (swipe actions, long-press), bulk actions, favorites, hardware keyboard support on desktop, power paths that do not complicate basics | 0: one rigid path. 4: multiple paths, customizable |
| 8 | **Aesthetic and Minimalist Design** | Only necessary information per step, clear hierarchy, purposeful color and emphasis, no decorative clutter | 0: everything competes equally. 4: every element earns its place |
| 9 | **Error Recovery** | Plain-language messages, specific problem ("Email is missing @", not "Invalid input"), actionable next step (retry via `AppErrorView`), errors near the source, user input preserved | 0: cryptic or silent. 1: "Something went wrong". 3: problem plus next step. 4: pinpoints, suggests fix, preserves work |
| 10 | **Help and Documentation** | Contextual help (tooltips, inline hints, tours), task-focused, concise, reachable without leaving context | 0: none. 4: right info at the right moment |

**Rating bands** (total out of 40): 36-40 Excellent (polish only), 28-35 Good (address weak areas), 20-27 Acceptable (significant improvement needed), 12-19 Poor (major UX overhaul), 0-11 Critical (redesign). When some heuristics are `n/a`, read the band off the percentage: 90%+ Excellent, 70%+ Good, 50%+ Acceptable, 30%+ Poor, else Critical. 24/32 is 75%, so Good.

#### Issue Severity (P0-P3)

| Priority | Name | Description | Action |
|----------|------|-------------|--------|
| **P0** | Blocking | Prevents task completion | Fix immediately |
| **P1** | Major | Significant difficulty or confusion | Fix before release |
| **P2** | Minor | Annoyance, workaround exists | Fix in next pass |
| **P3** | Polish | No real user impact | Fix if time permits |

Unsure between two levels? Ask: "Would a user contact support about this?" If yes, it is at least P1.

### Persona-Based Design Testing

Each persona exposes failure modes a single design-director view misses. Select 2-3, walk the primary action as each, report specific red flags.

**Alex, impatient power user.** Expert, hates hand-holding, skips onboarding, wants bulk actions and shortcuts, abandons when slow or patronizing. Test: can Alex finish the core task in under 60 seconds? Can onboarding be skipped? Are there swipe actions, bulk actions, desktop keyboard shortcuts? Red flags: unskippable tutorials, no shortcut for primary actions, animations that cannot be skipped, one-at-a-time flows where batch fits, redundant confirmations for low-risk actions.

**Jordan, confused first-timer.** Never used this kind of app, reads everything, hesitates, takes labels literally, abandons rather than figures it out. Test: is the first action clear within 5 seconds? Are icons labeled? Is there help at decision points? Does terminology assume knowledge? Red flags: icon-only navigation, unexplained jargon, no visible help, ambiguous next step after an action, no confirmation that an action succeeded.

**Sam, accessibility-dependent user.** Uses TalkBack or VoiceOver, switch access, or hardware keyboard; may have low vision or motor impairment; scales text up to 200%. Test: can the primary flow be completed with a screen reader and with keyboard focus traversal? Are controls focusable with visible focus? Do images have `semanticLabel`? Does contrast meet WCAG AA (4.5:1)? Are state changes announced? Does layout survive `textScaler` 2.0? Red flags: gesture-only interactions, missing or invisible focus, meaning by color alone, unlabeled icon buttons, time-limited actions, custom widgets without `Semantics`.

**Riley, deliberate stress tester.** Pushes past the happy path: empty states, very long strings, emoji, RTL, rotating mid-flow, backgrounding mid-flow. Test: behavior at 0, 1, and 1000 items and with very long text? Do error states recover? Is state preserved across rotation and app resume? Red flags: features that silently fail, technical details in errors, "No results" with no guidance, data lost on navigation or rotation, inconsistent behavior between similar interactions.

**Casey, distracted mobile user.** One-handed, thumb only, interrupted often, on a slow connection, types as little as possible. Test: are primary actions in the thumb zone? Is state preserved on leaving and returning? Does it work on a slow network? Smart defaults and autofill? Tap targets at least 48dp? Red flags: key actions at the top edge, progress lost on interruption, large text input where selection works, heavy images with no placeholder or caching, tiny or crowded tap targets.

**Selecting personas**:

| Interface type | Primary personas |
|----------------|------------------|
| Onboarding / first run | Jordan, Casey |
| Dashboard / library / admin | Alex, Sam |
| Checkout / purchase | Casey, Riley, Jordan |
| Data-heavy / analytics | Alex, Sam |
| Form-heavy / wizard | Jordan, Sam, Casey |
| Reader / media playback | Casey, Sam, Riley |

**Project-specific personas**: only when `PRODUCT.md` exists with real audience data, derive 1-2 extra personas (role, 2-3 profile traits, 3-4 behaviors, 3-4 red flags). Never invent audience details; use the predefined five otherwise.
