# Extract Flow

Identify reusable patterns, widgets, and theme values, then extract and consolidate them into the shared component library for systematic reuse.

## Step 1: Discover the Design System

Read the existing structure before adding anything:

- shared components: `lib/shared/components/{atoms,molecules,organisms}` (`AppButton`, `AppTextField`, `AppSkeleton`, `AppErrorView`, ...);
- feature-specific components: `lib/features/<feature>/presentation/components/{atoms,molecules,organisms,templates}`;
- theme: `AppTheme`, `ThemeData`, `ColorScheme`, `TextTheme`, `ThemeExtension`s;
- naming and export conventions.

Read PRODUCT.md and DESIGN.md directly if they exist (never invent them). If the target location or structure is unclear, do not guess. Ask the user directly to clarify what you cannot infer.

## Step 2: Identify Patterns

Look for extraction opportunities in the target area:

- **Repeated widgets**: Similar UI patterns used 3+ times (buttons, cards, inputs, list tiles)
- **Hard-coded values**: `Color(0x...)`, spacing, `TextStyle(fontSize: ...)`, radii, elevations that should live in the theme
- **Inconsistent variations**: Multiple implementations of the same concept
- **Composition patterns**: Layout or interaction patterns that repeat (form rows, toolbar groups, empty states)
- **Type styles**: Repeated size + weight + height combinations that should be a `TextTheme` role
- **Animation patterns**: Repeated curve, duration, or transition combinations

Assess value: only extract things used 3+ times with the same intent. Premature abstraction is worse than duplication.

## Step 3: Plan Extraction

Create a systematic plan:

- **Widgets to extract**: Which UI elements become reusable components, and at which atomic level (atom, molecule, organism, template)?
- **Where each lives**: reusable across features goes to `lib/shared/components/...`; feature-specific goes to that feature's `presentation/components/...`; pages stay in `presentation/views/*_screen.dart`.
- **Theme values to create**: Which hard-coded values become `ThemeData` entries or `ThemeExtension` fields?
- **Variants to support**: What variations does each component need?
- **Naming conventions**: Widget names, theme field names, and constructor parameters that match existing patterns
- **Migration path**: How to refactor existing uses to consume the new shared versions

Design systems grow incrementally. Extract what is clearly reusable now, not everything that might someday be reusable. Reuse an existing shared component before creating a new one.

## Step 4: Extract & Enrich

Build improved, reusable versions:

- **Widgets**: Clear constructor API with sensible defaults and `const` constructors, proper variants for different use cases, accessibility built in (`Semantics`, tap targets of at least 48dp, focus and pressed states, text-scale safety), no business logic (state belongs in ViewModels), strings passed in or read from l10n
- **Theme values**: Clear naming (primitive vs semantic), proper organization, documentation of when to use each; widgets read `Theme.of(context)`
- **Patterns**: When to use this pattern, code examples, variations and combinations

## Step 5: Migrate

Replace existing uses with the new shared versions:

- **Find all instances**: Search for the patterns you extracted
- **Replace systematically**: Update each use to consume the shared version
- **Test thoroughly**: Ensure visual and functional parity (widget tests, golden tests, `flutter run`)
- **Delete dead code**: Remove the old implementations

## Step 6: Document

- Add doc comments (`///`) on new shared components with a usage example
- Document theme value usage where the theme is defined
- Update any component catalog or design documentation that already exists
- Run `flutter analyze` and check against `flutter-checklist.md`

**Avoid**:
- Extracting one-off, context-specific implementations without generalization
- Creating components so generic they are useless
- Extracting without considering existing conventions
- Skipping constructor documentation or typed parameters
- Creating theme values for every single value (they should have semantic meaning)
- Extracting things that differ in intent (two buttons that look similar but serve different purposes should stay separate)
