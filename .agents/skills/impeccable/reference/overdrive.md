Start your response with:

```
──────────── ⚡ OVERDRIVE ─────────────
》》》 Entering overdrive mode...
```

Push an interface past conventional limits. This isn't just about visual effects. It's about using the full power of Flutter's rendering pipeline to make any part of an app feel extraordinary: a list that handles a million rows at 60fps, a dialog that morphs from its trigger, a form that validates in real time with streaming feedback, a screen transition that feels cinematic.

Context decides what "extraordinary" means. A particle system on a creative showcase is impressive. The same particle system on a settings screen is embarrassing. But a settings screen with instant optimistic saves and animated state transitions? That's extraordinary too. Understand the project's personality and goals before deciding what's appropriate.

### Propose Before Building

This command has the highest potential to misfire. Do NOT jump straight into implementation. You MUST:

1. **Think through 2-3 different directions**: consider different techniques, levels of ambition, and aesthetic approaches. For each direction, briefly describe what the result would look and feel like.
2. **Get the user's pick before writing any code.** Ask the user directly to clarify what you cannot infer. Carry each direction's description and its trade-offs (platform support, performance cost, complexity) inside the option itself, so the user is choosing between things they can read. A structured question blocks the message it rides in until the user answers, so directions written alongside the question stay invisible while the user is being asked to choose between them.
3. Only proceed with the direction the user confirms.

Skipping this step risks building something embarrassing that needs to be thrown away.

### Verify on a Device

Ambitious effects rarely work on the first try, so verify them with `flutter run --profile` on a real mid-range device (and hot reload while tuning), not from code alone: an effect that technically runs can still stutter, ease wrong, or land on the wrong frame. Aim the checks at timing, easing, and smoothness using DevTools frame build and raster times, batch the fixes between looks, and keep refining until the effect is extraordinary.

---

## Assess What "Extraordinary" Means Here

The right kind of technical ambition depends entirely on what you're working with. Before choosing a technique, ask: **what would make a user of THIS specific interface say "wow, that's nice"?**

### For expressive surfaces
Onboarding, splash, hero screens, showcases: the "wow" is often sensory: a scroll-driven reveal, a fragment-shader background, a cinematic route transition, generative art that responds to touch or device motion.

### For functional UI
Lists, forms, dialogs, navigation: the "wow" is in how it FEELS: a dialog that morphs from the button that triggered it (container transform, `Hero`), a list of 100k rows scrolling at 60fps via lazy `ListView.builder`, a form with streaming validation that feels instant, drag-and-drop with spring physics.

### For performance-critical UI
The "wow" is invisible but felt: a search that filters 50k items without a flicker, a complex form that never blocks the UI thread, an image editor that processes in near-real-time. The interface just never hesitates.

### For data-heavy interfaces
Charts and dashboards: the "wow" is in fluidity: `CustomPainter` rendering for massive datasets, animated transitions between data states, force-directed layouts that settle naturally.

**The common thread**: something about the implementation goes beyond what users expect from an app of this kind. The technique serves the experience, not the other way around.

## The Toolkit

Organized by what you're trying to achieve, not by technology name.

### Make transitions feel cinematic
- **Shared-element and container transforms**: `Hero`, `OpenContainer`-style transitions, custom `PageRouteBuilder`/`PageTransitionsTheme`. A list item expanding into a detail screen. A button morphing into a dialog.
- **Spring physics**: natural motion with mass, stiffness, and damping via `SpringSimulation`, `AnimationController.animateWith`, or physics-based `Draggable` behavior instead of fixed curves.
- **Choreographed sequences**: `Interval` curves on a single `AnimationController` for staggered, coordinated motion.

### Tie animation to scroll position
- **Scroll-driven motion**: `ScrollController`/`NotificationListener` or sliver delegates (`SliverPersistentHeader`, collapsing app bars) for parallax, progress, and reveal sequences. Always provide a static fallback for reduced motion.

### Render beyond widgets
- **Fragment shaders** (`FragmentProgram`, GLSL via Impeller/Skia): shader effects, post-processing, particle-like looks that widgets can't express.
- **`CustomPainter` and `Canvas`**: custom rendering and pixel-level drawing; pair with `RepaintBoundary`.
- **`ImageFilter`, `BackdropFilter`, `ShaderMask`, `ColorFiltered`**: bounded blur, glow, and masking in isolated regions (these are expensive; use sparingly).

### Make data feel alive
- **Lazy lists and slivers**: `ListView.builder`, `SliverList`, `SliverGrid` render only visible rows; use `itemExtent` or `prototypeItem` when row height is fixed.
- **Painter-based charts**: `CustomPainter` rendering for datasets too large for widget trees.
- **Animated data transitions**: morph between chart states with `TweenAnimationBuilder` and lerped painter values rather than replacing.

### Animate complex properties
- **Custom `Tween`s and `Animatable`s**: interpolate gradients, shapes (`ShapeBorder.lerp`), paths, and complex values Flutter doesn't interpolate by default.
- **Explicit animation controllers**: composable, cancellable, reversible; the foundation for complex choreography.

### Push performance boundaries
- **Isolates** (`Isolate.run`, `compute`): move computation off the UI thread. Heavy data processing, image manipulation, search indexing: anything that would cause jank.
- **Image decoding discipline**: `cacheWidth`/`cacheHeight`, precaching, and image caches so large images never stall frames.
- **FFI/native code**: near-native performance for computation-heavy features. Image processing, physics simulations, codecs.

### Interact with the device
- **Haptics and audio**: `HapticFeedback`, sonic feedback, audio-reactive visuals. Sound requires explicit opt-in.
- **Sensors**: accelerometer, gyroscope, ambient light. Use sparingly and always with user permission.

**NOTE**: This command is about enhancing how an interface FEELS, not changing what a product DOES. Adding real-time collaboration, offline support, or new backend capabilities are product decisions, not UI enhancements. Focus on making existing features feel extraordinary.

## Implement with Discipline

### Graceful degradation is non-negotiable

Every technique must degrade gracefully. The experience without the enhancement must still be good.

- Check `MediaQuery.disableAnimationsOf(context)` and fall back to a static or gentle-fade version.
- Shaders and heavy effects can fail to load or perform poorly on low-end devices; keep a plain-widget fallback that still looks good.
- Platform-specific APIs (sensors, haptics) must be guarded and optional on Android, iOS, and desktop.

### Performance rules

- Target 60fps (or the device's refresh rate). If frame times regularly exceed budget in `--profile` mode, simplify.
- Lazy-initialize heavy resources (shaders, large images, controllers) only when the screen needs them; dispose them.
- Pause off-screen animation (`TickerMode`, stop controllers). Kill what you can't see.
- Use `RepaintBoundary` around expensive animated regions and keep static subtrees `const`.
- Test on real mid-range devices, not just a flagship or an emulator.

### Polish is the difference

The gap between "cool" and "extraordinary" is in the last 20% of refinement: the curve on a spring animation, the timing offset in a staggered reveal, the subtle secondary motion that makes a transition feel physical. Don't ship the first version that works; ship the version that feels inevitable.

**NEVER**:
- Ship effects that cause jank on mid-range devices
- Use experimental or unstable APIs without a functional fallback
- Add sound without explicit user opt-in
- Use technical ambition to mask weak design fundamentals; fix those first with other commands
- Layer multiple competing extraordinary moments. Focus creates impact, excess creates noise

## Verify the Result

- **The wow test**: Show it to someone who hasn't seen it. Do they react?
- **The removal test**: Take it away. Does the experience feel diminished, or does nobody notice?
- **The device test**: Run it on a phone, a tablet, a low-end Android device. Still smooth?
- **The context test**: Does this make sense for THIS brand and audience?

"Technically extraordinary" isn't about using the newest API. It's about making an interface do something users didn't think an app could do.
