Quiet design is harder than bold design. Subtlety needs precision. Reduce visual intensity in designs that are too loud, aggressive, or overstimulating without losing personality or making the result generic.

---

## Product mode

Persuade + Experience (onboarding, splash, marketing-style screens): "quieter" means a more restrained palette, more whitespace, more typographic air. Drama is reduced, not eliminated; the POV stays intact.

Operate + Read (lists, readers, settings, tools): "quieter" means reducing visual noise. Fewer background accents, flatter cards, less color, less motion. The app should disappear more completely into the task.

---

## Assess Current State

Analyze what makes the design feel too intense:

1. **Identify intensity sources**:
   - **Color saturation**: Overly bright or saturated colors
   - **Contrast extremes**: Too much high-contrast juxtaposition
   - **Visual weight**: Too many bold, heavy elements competing
   - **Animation excess**: Too much motion or overly dramatic effects
   - **Complexity**: Too many visual elements, patterns, or decorations
   - **Scale**: Everything is large and loud with no hierarchy

2. **Understand the context**:
   - What's the purpose? (Onboarding vs tool vs reading experience)
   - Who's the audience? (Some contexts need energy)
   - What's working? (Don't throw away good ideas)
   - What's the core message? (Preserve what matters)

If any of these are unclear from the codebase, do not guess. Ask the user directly to clarify what you cannot infer.

"Quieter" means refined and easier on the eyes, not generic. Generic quiet looks like gray text on white, one font at a uniform weight, and a list of identical cards; restraint still needs a point of view.

## Plan Refinement

Create a strategy to reduce intensity while maintaining impact:

- **Color approach**: Desaturate or shift to more restrained `ColorScheme` roles?
- **Hierarchy approach**: Which elements should stay bold (very few), which should recede?
- **Simplification approach**: What can be removed entirely?
- **Sophistication approach**: How can we signal quality through restraint?

Subtlety requires precision. Quiet without intent collapses to generic.

## Refine the Design

Systematically reduce intensity across these dimensions:

### Color Refinement
- **Reduce saturation**: Shift from fully saturated to roughly 70-85% saturation (adjust the seed or role in `ColorScheme`, not per widget)
- **Soften palette**: Replace bright colors with muted container roles (`primaryContainer`, `surfaceContainer*`)
- **Reduce color variety**: Use fewer colors more thoughtfully
- **Neutral dominance**: Let neutrals do more work, use color as accent (10% rule)
- **Gentler contrasts**: High contrast only where it matters most, while text still meets WCAG ratios
- **Tinted neutrals**: Use warm or cool tinted surfaces and `onSurfaceVariant` instead of pure gray. Adds depth without loudness
- **Never gray on color**: Gray text on a colored background reads muddy; use the matching `on*` role or a darker shade of that color

### Visual Weight Reduction
- **Typography**: Reduce font weights (w900 to w600, w700 to w500) and decrease sizes where appropriate, by choosing a lighter `TextTheme` role
- **Hierarchy through subtlety**: Use weight, size, and space instead of color and boldness
- **White space**: Increase breathing room, reduce density
- **Borders & lines**: Reduce thickness, lower opacity, or remove entirely (`Divider`, `BorderSide`)

### Simplification
- **Remove decorative elements**: Gradients, shadows, patterns, textures that don't serve purpose
- **Simplify shapes**: Reduce corner radius extremes, simplify custom shapes
- **Reduce layering**: Flatten visual hierarchy; lower `elevation` and surface tint where possible
- **Clean up effects**: Reduce or remove blur effects, glows, multiple shadows

### Motion Reduction
- **Reduce animation intensity**: Shorter distances (10-20dp instead of 40dp), gentler curves
- **Remove decorative animations**: Keep functional motion, remove flourishes
- **Subtle micro-interactions**: Replace dramatic effects with gentle feedback
- **Refined easing**: Use `Curves.easeOutCubic` or `Curves.easeOutQuart` for smooth, understated motion. Never bounce or elastic
- **Remove animations entirely** if they're not serving a clear purpose, and always honor `MediaQuery.disableAnimationsOf(context)`

### Composition Refinement
- **Reduce scale jumps**: Smaller contrast between sizes creates a calmer feeling
- **Align to the spacing scale**: Bring rogue elements back into systematic alignment
- **Even out spacing**: Replace extreme spacing variations with consistent rhythm

**Avoid**:
- Making everything the same size/weight (hierarchy still matters)
- Removing all color (quiet is not grayscale)
- Eliminating all personality (maintain character through refinement)
- Sacrificing usability for aesthetics (functional elements still need clear affordances and 48dp tap targets)
- Making everything small and light (some anchors needed)

## Verify Quality

Ensure refinement maintains quality:

- **Still functional**: Can users still accomplish tasks easily?
- **Still distinctive**: Does it have character, or is it generic now?
- **Better reading**: Is text easier to read for extended periods, in light and dark themes?
- **Restrained, not absent**: Does the POV survive the cuts?

When the result feels right, hand off to `/impeccable polish` for the final pass.
