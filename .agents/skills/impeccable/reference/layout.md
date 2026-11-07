Layout turns product priority into reading order, grouping, rhythm, and usable space. Diagnose the structural problem before moving boxes.

---

## Product mode

- **Persuade + Experience:** composition may be asymmetric, fluid, or intentionally disruptive when the selected world earns it.
- **Operate + Read:** predictable structure, stable density, and navigable linearity are affordances.
- **Platform:** follow [ios.md](ios.md) or [android.md](android.md) for navigation, insets, adaptation, and touch targets.

Preserve the established visual world. A layout command changes structure inside it; identity replacement belongs to [new-work.md](new-work.md).

## Two isolated assessments

When a sub-agent tool is available and permitted, run these independently; otherwise run them yourself in this order.

1. **Layout assessment:** inspect representative states and window size classes. Answer every question below with rendered or source evidence:
   - **Reading order:** Apply the squint test. With detail blurred, can you still identify the primary element, the secondary element, and the major groups in order?
   - **Grouping:** Are related items close and distinct groups separated, or are containers (`Card`, `Container`) compensating for weak proximity?
   - **Rhythm:** Do tight and generous intervals create a deliberate cadence, or is one spacing value repeated until everything has equal weight?
   - **Structure:** Does the widget topology match the content and task? Are repeated cards, columns, or sections genuinely equivalent, or merely a default?
   - **Density:** Does the amount of information per region fit use frequency, decision complexity, and product mode?
   - **Adaptation:** On compact, medium, and expanded window sizes, in both orientations, at large text scale and in PT/EN, what reorders, collapses, wraps, scrolls, or remains fixed? Does focus and screen-reader order still agree with the visual order?
   - **Extremes:** Do long content, empty states, overlays, sticky elements, safe areas (notches, gesture bars, keyboard insets), and small tap targets expose structural failures? Any `RenderFlex overflowed` error is a structural failure.
2. **Mechanical scan:** run `flutter analyze` and check the code against `flutter-checklist.md`. Also inspect arbitrary spacing values, unbounded `Row`/`Column` children, nested scrollables, and constraint behavior the analyzer cannot resolve. Keep mechanical evidence out of the first assessment, then synthesize both passes before editing. A clean scan cannot prove hierarchy or rhythm.

## Set the spatial thesis

Before editing, name:

- the primary reading or task path;
- what belongs together and what must separate;
- which element leads and which supports;
- the intended density and spacing rhythm;
- how the structure changes across window size classes, input modes, and content extremes.

Choose the simplest structural model that expresses those relationships. Use layout primitives according to the relationships they control (`Column`, `Row`, `Wrap`, `Stack`, `Flex`/`Expanded`, `Slivers`, `GridView`), and name reusable spacing roles semantically in the theme or a spacing constants class.

## Apply

- Group by meaning. Use proximity before adding containers or decoration.
- Create rhythm through deliberate contrast between tight and generous intervals.
- Use a documented spacing scale rather than one-off values. A 4dp base usually provides the useful middle steps that an 8-only scale misses.
- Let hierarchy follow product priority, not widget defaults.
- Keep distinct content visually distinct without turning every group into an isolated card; never nest cards inside cards.
- Make adaptive behavior structural: reorder, collapse, reflow, or reveal based on what remains important. Use `LayoutBuilder` (local constraints) for component-level adaptation and `MediaQuery` for window-level decisions; consider a navigation rail or two-pane layout on wide windows.
- Wrap screens in `SafeArea` and respect `MediaQuery.viewInsets` for the keyboard.
- Use `Column(spacing: ...)`/`Row(spacing: ...)` or `SizedBox` gaps consistently for sibling rhythm; avoid ad-hoc padding on each child.
- Use `ListView.builder`/slivers for long or unbounded content, never a `Column` inside `SingleChildScrollView` for large lists.
- Keep tap targets at least 48dp even when their visible marks are small.
- Use depth (elevation, surface tint) only when it clarifies state or hierarchy.
- Make optical corrections only after inspecting the rendered result.
- Reuse shared components from `lib/shared/components` before composing new ones.

Variation is not a goal by itself. Repetition should support recognition; break it only when content or priority changes.

## Verify

- The squint test still reveals the primary, secondary, and major groups in order.
- The reading and task path remains clear at every supported size class.
- Related content groups naturally; unrelated content does not blur together.
- Tight and generous spacing create intentional rhythm instead of monotonous repetition.
- Density matches use frequency and content complexity.
- Long text, empty states, localization, large text scale, and dynamic content do not break the structure or overflow.
- Focus, touch, and screen-reader order agree with the visual order.
- `flutter analyze` is clean and no layout exceptions appear in the debug console.

Answer each item with rendered or source evidence, then rerun the checks. Do not substitute a bare "yes" for verification.

When the structure holds, hand off to `/impeccable polish`.
