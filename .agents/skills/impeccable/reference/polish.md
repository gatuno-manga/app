> **Additional context needed**: quality bar and shipping constraints.

Polish is refinement, never concealed redesign. Preserve the incumbent visual world, content, behavior, and everything outside scope. If the concept itself is wrong, say so and recommend redesign or `bolder` instead of smuggling in a replacement.

`flutter analyze` and the checklist in `flutter-checklist.md` are defect evidence, not proof of quality. Run the app and walk the real interaction path.

## 1. Establish the system

Read PRODUCT.md and DESIGN.md directly if they exist (they may not; never invent them). Read `AppTheme`, `ThemeData`/`ColorScheme`/`TextTheme`/`ThemeExtension` definitions, shared components in `lib/shared/components/{atoms,molecules,organisms}`, and neighboring flows. If no formal system exists, use coherent project conventions.

Classify each drift before fixing it:

- **missing token:** the theme needs a reusable value (add it to `ThemeData` or a `ThemeExtension`);
- **one-off implementation:** an existing shared component (`AppButton`, `AppTextField`, `AppSkeleton`, `AppErrorView`, ...) should replace it;
- **conceptual mismatch:** the flow, information architecture, or hierarchy differs from comparable product areas;
- **local defect:** the implementation is simply incomplete or inconsistent.

Fix the cause at the narrowest correct level. Ask when a binding system principle cannot be inferred.

## 2. Gather the evidence

Use the feature yourself with `flutter run` (hot reload) on an emulator, simulator, or device, at the shipped size classes (phone, tablet, desktop if supported) and in both orientations. Determine:

- whether the path is functionally complete;
- the intended quality bar and time available;
- known constraints or deliberately unfinished work;
- the states, content lengths, locales, and input methods users will actually encounter.

If a prior critique exists in the conversation or repo, use it as one input, but perform an independent pass either way.

## 3. Triage

Separate functional defects from cosmetic ones and fix in this order:

1. broken or blocked tasks, data loss, misleading state, and inaccessible paths;
2. missing loading, empty, error, success, disabled, and permission states;
3. flow, hierarchy, adaptive-layout, and design-system drift;
4. visual and motion inconsistencies;
5. code and asset cleanup.

Do not perfect one corner while leaving the rest below the same quality bar.

## 4. Polish the whole path

### Flow and hierarchy

- Match neighboring mental models, terminology, disclosure, navigation, save behavior, and optimistic or pessimistic patterns.
- Make the primary task and current state obvious without flattening every element to equal weight.
- Ensure arrival, transition, empty, and recovery paths connect instead of behaving as isolated screens.

### Layout and type

- Align to the project's spacing scale; fix optical as well as mathematical alignment.
- Group related content tightly and separate distinct groups generously.
- Keep same-role typography consistent via `Theme.of(context).textTheme`; test line length, wrapping, localization expansion (EN and PT), and large text scale (`MediaQuery.textScaler`).
- Verify every supported size class with `LayoutBuilder`/`MediaQuery` and `SafeArea` rather than correcting only the current screen.

### Color, imagery, and icons

- Use `ColorScheme` roles and stable color meanings across light and dark themes; no hardcoded `Color(0x...)`.
- Verify text, control, and focus contrast in every state.
- Keep icon families, weight, sizing, and optical alignment coherent.
- Prevent layout jumps when images load: reserve aspect ratio, use `cacheWidth`/`cacheHeight`, and provide `semanticLabel` for meaningful images.

### Interaction and state

- Every control needs appropriate default, focused, pressed, disabled, loading, error, and success behavior (`InkWell`, `WidgetState`); pointer-hover feedback on desktop is a bonus, never the only affordance.
- Preserve visible focus, logical focus order, labels via `Semantics`, and tap targets of at least 48dp.
- Keep motion coherent, interruptible, and cheap. Do not add animation merely to make polish visible. Respect `MediaQuery.disableAnimationsOf(context)`.
- Validate long, missing, localized, offline, slow, and permission-limited content where the product can encounter it.

### Content and code

- Keep terminology, capitalization, punctuation, and factual copy consistent. Strings go through l10n ARB (`lib/l10n`, EN and PT, feature-prefixed keys). Ask before changing claims.
- Remove debug output (`print`), dead code, unused imports, and polish-created duplication.
- Replace custom implementations with shared components where the system owns the pattern.
- Promote genuinely reusable values to the theme; do not create an abstraction for one local exception.
- State lives in ViewModels (`presentation/view_models`), not in widgets.

## 5. Verify and finish

Walk the complete path again with touch, keyboard, and screen reader where applicable. Check:

- phone and tablet size classes in both orientations;
- loading, empty, error, success, disabled, long-content, and missing-content states;
- text scaling, contrast, focus order, and TalkBack/VoiceOver names;
- runtime warnings and overflow errors in the debug console, and dropped frames in `--profile` mode;
- agreement with DESIGN.md (if present), neighboring features, and the user's scope.

Run `flutter analyze` and any relevant tests (including golden tests), then check against `flutter-checklist.md`. Fix real defects and document only narrow intentional exceptions. A clean analyzer run does not replace visual judgment.

Finish with a source diff: remove accidental churn, orphaned code, redundant values, and temporary artifacts. Ship only when the feature is functionally complete and consistently finished across the path.
