Designs that only work with perfect data aren't production-ready. Harden the interface against the inputs, errors, languages, and network conditions that real users will throw at it.

## Assess Hardening Needs

1. **Test with extreme inputs**:
   - Very long text (names, titles, descriptions); very short (empty, single character)
   - Special characters (emoji, RTL text, accents)
   - Large numbers (millions, billions)
   - Many items (1000+ list items, 50+ options)
   - No data (empty states)

2. **Test error scenarios**:
   - Network failures (offline, slow, timeout)
   - API errors (400, 401, 403, 404, 500)
   - Validation, permission, and rate-limit errors
   - Concurrent operations

3. **Test internationalization** (the app ships EN + PT; test beyond them):
   - Long translations (German is often 30% longer than English; PT is longer than EN)
   - RTL languages (Arabic, Hebrew)
   - Character sets (CJK, emoji)
   - Date, time, and number formats (1,000 vs 1.000), currency

## Hardening Dimensions

### Text Overflow and Wrapping

**Long text handling**:
- Single line: `Text(..., maxLines: 1, overflow: TextOverflow.ellipsis)`
- Multi-line clamp: `maxLines: 3, overflow: TextOverflow.ellipsis`, and keep the full text reachable (tap to expand, detail screen, `Tooltip`)
- Never clip essential text silently

**Flex overflow** (the yellow-black stripes):
- Wrap text in `Expanded`/`Flexible` inside `Row`; use `Wrap` when items should flow to the next line
- Scrollable screens wrap content in `SingleChildScrollView`/`CustomScrollView`; keep keyboards from covering inputs
- `ConstrainedBox`/`IntrinsicWidth` for min/max widths; avoid fixed widths and heights on text containers

```dart
// Bad: assumes short English text
SizedBox(width: 96, child: ElevatedButton(onPressed: onTap, child: Text(label)))

// Good: adapts to content, constrained
ConstrainedBox(
  constraints: const BoxConstraints(minWidth: 96),
  child: AppButton(onPressed: onTap, label: label),
)
```

**Text scaling**:
- Read sizes from `Theme.of(context).textTheme`; never hardcode font sizes
- Test `MediaQuery.textScaler` at 1.5 and 2.0; containers expand with text (no fixed heights), and layouts reflow instead of clipping
- Honor the system font-size setting; do not clamp it away without a strong reason

### Internationalization (i18n)

**Strings**: every user-facing string goes through the ARB files in `lib/l10n` (EN + PT, feature-prefixed keys) and `AppLocalizations`; no literals in widgets.

**Text expansion**:
- Budget 30-40% extra space for translations; use flexible layouts, avoid fixed widths on text containers
- Test with the longest language

**RTL (right-to-left) support**:
- Use directional-agnostic APIs: `EdgeInsetsDirectional`, `AlignmentDirectional`, `BorderRadiusDirectional`, `PositionedDirectional`, `TextAlign.start`/`end` instead of left/right
- Mirror directional icons (back arrow, chevrons) via `matchTextDirection` or `Directionality`; do not mirror logos or media controls where convention says otherwise
- Test with `Directionality(textDirection: TextDirection.rtl, ...)` in a widget test or a forced RTL locale

**Arabic-script specifics** (Arabic, Persian, Urdu, Pashto, Kurdish):
- Preserve Zero-Width Non-Joiner (U+200C). Persian and Kurdish use it between compound-word parts; a sanitizer that strips it changes meaning. Never normalize it away.
- Handle Yeh and Kaf variants. Persian uses U+06CC and U+06A9, Arabic uses U+064A and U+0643. Preserve the original form in storage; for search and validation treat the corresponding letters as equivalent so input from either keyboard matches.
- Locale-aware digits: Persian and Arabic locales use Eastern Arabic-Indic numerals. Format with `NumberFormat` from the `intl` package using the active locale rather than hardcoding Western digits.
- Respect calendar systems: Solar Hijri (Jalali) for many Persian users, Hijri for many Arabic-speaking users. Use locale-appropriate calendar libraries, not hand-rolled math.

**Character sets**: UTF-8 everywhere; test CJK and emoji (emoji can be multiple code units; use `characters` for grapheme-safe truncation and counting, not `String.length`/`substring`).

**Date, number, currency formatting**:

```dart
// Use intl with the active locale, never manual string building
DateFormat.yMd(locale).format(date);
NumberFormat.currency(locale: locale, symbol: r'$').format(1234.56);
```

**Pluralization**: use ICU plural messages in the ARB files (`{count, plural, =0{...} =1{...} other{...}}`); never `'$count item${count != 1 ? 's' : ''}'`.

### Error Handling

**Network errors**: clear message, retry action, explain what happened, offline mode where applicable, handle timeouts. Use the shared `AppErrorView` rather than ad hoc error widgets.

```dart
// Error state with recovery
if (state.hasError) {
  return AppErrorView(
    message: l10n.libraryLoadError,
    onRetry: viewModel.reload,
  );
}
```

**Form validation errors**: inline errors near fields (`AppTextField` error text), clear and specific, suggest corrections, do not block submission unnecessarily, preserve user input on error.

**API errors** (handle each status deliberately):
- 400: show validation errors
- 401: re-authenticate (refresh token, then sign-in flow)
- 403: permission error
- 404: not-found state
- 429: rate-limit message with backoff
- 500: generic error and a retry; offer support

**Graceful degradation**: images have placeholders and error builders (`errorBuilder`) and `semanticLabel`s; missing optional data hides its section instead of crashing; null-safety and `try`/`catch` at data boundaries; errors reported through `AppLogger`, never `print`.

### Edge Cases and Boundary Conditions

**Empty states**: no items, no search results, no notifications, no data. Always give a clear next action.

**Loading states**: initial load, pagination, refresh. Use `AppSkeleton` (not a bare spinner where a skeleton fits), say what is loading, and estimate time for long operations.

**Large datasets**: pagination or lazy lists (`ListView.builder`), search and filter, never load 10,000 items at once.

**Concurrent operations**:
- Prevent double-submission (disable the button, show progress, guard in the ViewModel)
- Handle race conditions (cancel or ignore stale responses)
- Optimistic updates with rollback; conflict resolution

**Interrupted gestures** (custom sliders, drag surfaces, scrollable control strips):
- A second pointer lands mid-drag: the first drag keeps its pointer or ends cleanly, never jumps
- The gesture is cancelled (parent scrollable wins the arena, `onPanCancel`/`onHorizontalDragCancel`), the pointer is released outside the control, or the app loses focus or is backgrounded mid-drag: clear the dragging state
- After each of these, the next tap or drag works without a rebuild of the screen

**Lifecycle**: app backgrounded and resumed mid-flow, rotation mid-flow, process death and restore; state survives or degrades gracefully (`AppLifecycleListener`, restoration where it matters).

**Permission states**: no permission to view or edit, read-only mode, OS-level permission denied (camera, notifications, storage) with a clear explanation and a path to settings.

**Platform differences**: guard platform-specific APIs (`defaultTargetPlatform`, `Platform.isIOS`) and degrade gracefully where a plugin is unavailable.

### Input Validation and Sanitization

**Client-side validation**: required fields, formats (email, phone, link), length limits (`maxLength`, `inputFormatters`), correct `keyboardType` and `textInputAction`, `autofillHints`, custom rules.

**Server-side validation** (always): never trust the client alone; the backend validates and sanitizes everything; rate limiting.

**Constraint handling**:

```dart
AppTextField(
  label: l10n.profileUsernameLabel,
  maxLength: 100,
  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]'))],
  helperText: l10n.profileUsernameHint,
)
```

### Accessibility Resilience

**Focus and keyboard** (desktop and switch access):
- All functionality reachable via focus traversal; logical order (`FocusTraversalGroup`, `FocusTraversalOrder`)
- Focus management in dialogs and sheets; visible focus states

**Screen reader support**:
- `Semantics` labels, roles, and values; `MergeSemantics` for compound controls, `ExcludeSemantics` for decoration
- Announce dynamic changes (`SemanticsService.announce`, `Semantics(liveRegion: true)`)
- `semanticLabel` and `Tooltip` on icon-only controls

**High contrast and bold text**: honor `MediaQuery.highContrast` and `boldText`; do not rely on color alone; provide alternative cues (icons, text).

### Performance Resilience

**Slow connections**: progressive image loading, skeletons, optimistic updates, offline cache.

**Memory leaks**: dispose controllers and focus nodes, cancel subscriptions and timers, cancel pending requests on dispose, check `mounted` after awaits.

**Throttling and debouncing**: debounce search input (about 300 ms), throttle scroll-driven work.

## Testing Strategies

**Manual testing**: extreme data (very long, very short, empty), different languages and RTL, airplane mode, slow connection, TalkBack and VoiceOver, text scale 2.0, rotation, backgrounding, low-end device.

**Automated testing**:
- Unit tests for edge cases in ViewModels and parsers
- Widget tests for error, empty, and loading states
- Goldens at compact and expanded widths, light and dark, and at large text scale
- Integration tests (`integration_test`) for critical paths
- A behavioral regression for each confirmed gesture fix (`tester.drag`, `tester.startGesture` with cancel)
- Accessibility guideline checks: `meetsGuideline(androidTapTargetGuideline)`, `iOSTapTargetGuideline`, `labeledTapTargetGuideline`, `textContrastGuideline`
- `flutter analyze` clean

**Avoid**:
- Assume perfect input (validate everything)
- Ignore internationalization (design for global)
- Generic error messages ("Error occurred")
- Forget offline scenarios
- Trust client-side validation alone
- Fixed widths and heights on text
- Assume English-length text
- Block the entire screen when one component errors

## Verify Hardening

- **Long text**: names with 100+ characters
- **Emoji**: in all text fields
- **RTL**: Arabic or Hebrew locale
- **CJK**: Chinese, Japanese, Korean input
- **Network issues**: airplane mode, throttled connection
- **Large datasets**: 1000+ items
- **Concurrent actions**: tap submit 10 times rapidly
- **Interrupted gestures**: second finger mid-drag, scroll across the control, release outside it, background the app mid-drag; then drag again
- **Errors**: force API errors and test every error state
- **Empty**: remove all data and test empty states

For gestures, say what produced the evidence (widget test, emulator, physical device) and name what stayed untested.

When edge cases are covered, hand off to `/impeccable polish` for the final pass.
