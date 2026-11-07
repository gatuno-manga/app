> **Additional context needed**: performance constraints.

Use motion to explain state, relationship, and hierarchy, or to create one authored moment the surface has earned. Decoration without purpose is animation debt.

---

## Product mode

- **Persuade + Experience (onboarding, splash):** motion may carry the voice. Prefer one rehearsed focal sequence to repeated reveals.
- **Operate + Read (lists, reader, settings):** motion serves feedback, state, and continuity. Keep routine transitions fast and do not make users wait through entrance choreography.
- **Platform:** follow the Motion section of [ios.md](ios.md) or [android.md](android.md), including the platform's Reduce Motion behavior.

## Find the job

Inspect the existing motion language, interaction states, target devices, and performance budget. Find only the places where motion would:

- acknowledge an action;
- make a state change or spatial relationship legible;
- preserve continuity through navigation or layout change;
- direct attention at a meaningful moment;
- embody the selected visual world.

Ask only when a material constraint cannot be inferred. Do not animate a static area merely because it exists.

## Set the motion thesis

Write a short plan before implementation:

- **Focal moment:** the one sequence or interaction that deserves authorship, if any.
- **Continuity:** the state, layout, or navigation changes that need explanation.
- **Feedback:** the controls and outcomes that need acknowledgment.
- **Budget:** which effects may be expensive and how often they run.

The focal moment must come from this product and surface concept. A generic fade-and-slide, press scale, or list reveal is not a thesis.

## Choose material by meaning

Transform and opacity are reliable foundations, not the entire palette. Choose properties for what the transition communicates:

- **Continuity and relationship:** `Hero`, shared-axis or container-transform transitions, deliberate spatial movement.
- **Focus and depth:** bounded blur, elevation, or shadow changes.
- **Reveal and composition:** clips, masks, `AnimatedSize`, controlled occlusion.
- **Material and energy:** color, gradient position, or custom painters/shaders when the world and runtime support them.
- **State and feedback:** the smallest change that makes cause and result unmistakable.

Do not stack techniques for spectacle. One strong material idea, carried through the focal sequence and quiet supporting states, is usually enough.

Sibling stagger is appropriate when a list appears as a list. Cap the total delay, and never stagger every item in a long scroll.

## Timing and easing

Timing should express distance and consequence:

| Duration | Typical use |
|---|---|
| 100-150 ms | immediate feedback |
| 150-300 ms | routine state change |
| 300-500 ms | layout, overlay, or route transition |
| 500-800 ms | a deliberately authored focal entrance |

Exit faster than entrance. Use natural deceleration such as `Curves.easeOutCubic`, `Curves.easeOutQuart`, or `Curves.fastOutSlowIn` for confident arrivals; do not use bounce or elastic curves by reflex. Long feedback feels like latency.

## Implement to the runtime

- Use implicit animations (`AnimatedContainer`, `AnimatedOpacity`, `AnimatedSwitcher`, `TweenAnimationBuilder`) for declarative state changes.
- Use `AnimationController` with explicit transitions (`FadeTransition`, `SlideTransition`, `ScaleTransition`) for interruption, sequencing, and dynamic values. Dispose controllers; use `SingleTickerProviderStateMixin`.
- Use `Hero` or page transition builders when continuity across screens is the point.
- Drive scroll-linked motion only when the scroll relationship carries meaning.
- Do not add a package for an effect the framework can express cleanly.
- Define durations and curves once (theme extension or shared constants), not inline per widget.

Keep content visible in the default state. Avoid animating layout-driving properties (size, padding) on large subtrees every frame; prefer transforms and opacity, and animate isolated regions. Wrap expensive animated regions in `RepaintBoundary`, use `AnimatedBuilder`'s `child` parameter so static subtrees do not rebuild, and keep `const` widgets const. Measure in `--profile` mode on a real device (DevTools frame build and raster times) rather than assuming transform means fast.

## Accessibility and control

Any nonessential loop must stop when the screen is not visible or the app is backgrounded.

Every animation needs a reduced-motion path: when `MediaQuery.disableAnimationsOf(context)` is true, use `Duration.zero` or a gentle fade instead of spatial movement. Reduced motion means fewer and gentler animations, not disabling all motion; feedback that confirms an action should remain legible.

## Verify

- The focal motion is specific to the selected world and surface.
- Every supporting animation explains feedback, state, or relationship.
- Interruption and repeated use behave correctly (rapid taps, back during transition).
- Phone, tablet, and screen-reader paths remain usable.
- The reduced-motion path reduces movement without erasing meaningful feedback or state changes.
- Expensive effects stay smooth (no jank in `--profile` mode) on the target device.
- Removing an animation would lose meaning or authored character, not merely decoration.

When motion earns its place, hand off to `/impeccable polish` for the final pass.
