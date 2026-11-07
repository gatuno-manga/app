Performance is a feature. Identify the actual bottleneck for THIS interface, fix it, then measure. Don't optimize what isn't slow.

## Assess Performance Issues

1. **Measure current state** (always in `--profile` mode on a real device; debug mode numbers are meaningless):
   - **Frame times**: build and raster time per frame in DevTools (Performance view); the budget is about 16 ms at 60 Hz, about 8 ms at 120 Hz
   - **Jank**: dropped frames during scroll, navigation transitions, and animations
   - **Startup**: time to first frame
   - **Memory**: DevTools Memory view; image cache size, leaked controllers or subscriptions
   - **Rebuilds**: which widgets rebuild and how often (DevTools rebuild counts, "Track widget rebuilds")
   - **Network**: request count, payload size, repeated fetches
   - **App size**: `flutter build apk --analyze-size` / `--analyze-size` for iOS builds

2. **Identify bottlenecks**:
   - What is slow? (Startup? Scroll? A specific interaction? An animation?)
   - Is it the UI thread (build) or the raster thread (paint, shaders, clips, blur)?
   - How bad is it, and who is affected (all devices, low-end Android only, slow networks)?

Measure before and after. Optimizing without measurement spends effort on things that do not matter.

## Optimization Strategy

### Build Performance (UI thread)

- **`const` everywhere possible**: `const` widgets are skipped on rebuild. Satisfy `prefer_const_constructors` and `prefer_const_literals_to_create_immutables`.
- **Narrow rebuild scope**: split large `build` methods into small widgets (classes, not helper methods) so a change rebuilds only its subtree. Scope `Consumer`/`Selector`/`ListenableBuilder` to the smallest subtree that depends on the state. Avoid `setState` or `notifyListeners` at screen level for small changes.
- **Keep `build` pure and cheap**: no sorting, filtering, parsing, or object construction on every build; precompute in the ViewModel or memoize.
- **Heavy work off the UI thread**: `compute`/`Isolate.run` for payload parsing of large payloads, image processing, or crypto.
- **Debounce** expensive reactions (search as you type, resize handlers).

### Lists and Scrolling

- Use `ListView.builder` / `SliverList.builder` / `GridView.builder` (or the shared scrollable list) for long or dynamic content; never `ListView(children: [...])` over many items.
- Avoid `shrinkWrap: true` and `NeverScrollableScrollPhysics` lists nested in scrollables; use slivers (`CustomScrollView`).
- Give items stable `Key`s when order changes; set `itemExtent` or `prototypeItem` for uniform rows.
- Paginate; do not load thousands of items at once.

### Raster Performance (GPU)

- **`RepaintBoundary`** around frequently animating or independently updating subtrees so they do not repaint the rest of the screen. Do not scatter it everywhere; each boundary costs memory.
- **Avoid saveLayer-triggering widgets over large areas** every frame: `Opacity` (prefer `FadeTransition`/`AnimatedOpacity`), `ClipRRect` with anti-aliasing on big subtrees, `BackdropFilter`, `ShaderMask`, large blurred shadows. Bound them to small regions or precompute.
- Prefer `ColoredBox`/`DecoratedBox` over `Container` stacks when you need one thing.
- Reduce overdraw: remove fully hidden backgrounds and redundant stacked fills.
- Shader jank: warm up or use Impeller (default on modern Flutter); verify first-run animations on real devices.

### Animation Performance

- Animate with `AnimatedBuilder`/`TweenAnimationBuilder`/transitions (`FadeTransition`, `SlideTransition`, `ScaleTransition`) that rebuild only the animated subtree, passing static content as `child`. Avoid animating a whole screen via `setState`.
- Prefer transform and opacity changes; avoid animating layout-driving properties (size, padding) across large trees every frame.
- Dispose every `AnimationController` (`SingleTickerProviderStateMixin`) and stop tickers for off-screen widgets.
- Respect `MediaQuery.disableAnimationsOf(context)`: shorten or replace with a crossfade, never leave motion that blocks the task.
- Keep animations within the frame budget; check the raster thread, not just the UI thread.

### Images and Assets

- Decode at display size: `cacheWidth`/`cacheHeight` (or `ResizeImage`) so thumbnails do not decode full-resolution bitmaps; use the shared `AppImage` for network images with caching and a placeholder.
- Reserve space (fixed sizes or `AspectRatio`) so layout does not jump when images arrive.
- Precache above-the-fold hero images with `precacheImage`; lazy-load the rest.
- Use appropriately compressed assets (WebP where supported; compress to the quality that is imperceptible), vector assets for icons.
- Fonts: bundle only the weights and subsets in use (Inknut Antiqua via `AppTheme`); each extra weight adds size.

### Startup

- Do the minimum before `runApp`; defer non-critical initialization (analytics, prefetching, large caches) until after the first frame (`WidgetsBinding.instance.addPostFrameCallback`).
- Avoid blocking splash work on the network; show a skeleton and fill in.
- Lazy-create ViewModels and heavy services; keep dependency injection registration cheap.

### Network and Data

- Paginate and request only needed fields; cache responses (response caching, local cache) and avoid duplicate in-flight requests.
- Compress payloads; cancel requests when the screen is disposed.
- Optimistic UI for fast-feeling writes, with rollback on failure.
- Adapt to slow connections: skeletons (`AppSkeleton`), progressive loading, offline support where it matters.

### Memory and Leaks

- Dispose `AnimationController`, `TextEditingController`, `ScrollController`, `FocusNode`; cancel `StreamSubscription`s and timers; close sinks (lints `cancel_subscriptions`, `close_sinks`).
- Do not hold `BuildContext` across async gaps; check `mounted`.
- Watch the image cache size on image-heavy screens.

### App Size

- `--analyze-size`, remove unused dependencies and assets, enable tree shaking of icon fonts (`--tree-shake-icons`), split per ABI on Android.

## Performance Monitoring

**Tools**:
- Flutter DevTools (Performance, CPU profiler, Memory, Widget inspector with rebuild tracking)
- `flutter run --profile` on a real device; the `PerformanceOverlay`
- `flutter analyze` for perf-related lints (const, dispose, subscriptions)
- Integration tests with `traceAction` / frame timing summaries for regression checks
- Crash and performance reporting already wired into the app, if any

**Key metrics**: build and raster time (average and worst frames), dropped-frame percentage, time to first frame, memory peak, app size, request count.

Measure on a real mid-range or low-end Android phone and an older iPhone, not just a flagship or an emulator.

**Avoid**:
- Optimize without measuring (premature optimization)
- Profile in debug mode
- Sacrifice accessibility for performance
- Break functionality while optimizing
- Wrap everything in `RepaintBoundary` (memory cost)
- Lazy-load above-the-fold content
- Chase micro-optimizations while ignoring the biggest bottleneck
- Forget low-end devices and slow connections

## Verify Improvements

- **Before/after metrics**: compare DevTools frame times, dropped frames, and startup in `--profile` on the same device
- **Different devices**: low-end Android, not just a flagship iPhone
- **Slow connections**: throttle the network and test the experience
- **No regressions**: widget tests and goldens still pass; `flutter analyze` clean
- **User perception**: does it feel faster?

When the user-facing numbers move, hand off to `/impeccable polish` for the final pass.
