import 'package:equatable/equatable.dart';

/// Font family offered by the reader settings sheet (Figma `Fonte`).
enum ReaderFontFamily {
  serif,
  sans,
  lexend,
  atkinson,
  openDyslexic;

  /// Parses a persisted [name]; null or unknown values fall back to [serif].
  static ReaderFontFamily fromName(String? name) =>
      values.firstWhere((v) => v.name == name, orElse: () => serif);
}

/// Paragraph alignment (Figma `Alinhamento`: esquerda, centro ou justificado).
enum ReaderTextAlignment {
  left,
  center,
  justify;

  /// Parses a persisted [name]; null or unknown values fall back to [left].
  static ReaderTextAlignment fromName(String? name) =>
      values.firstWhere((v) => v.name == name, orElse: () => left);
}

/// Reader theme (Figma `Gatuno / Leitura (temas)` modes). [standard] follows
/// the active app theme; the other three are fixed palettes.
enum ReaderTheme {
  standard,
  sepia,
  cream,
  highContrast;

  /// Parses a persisted [name]; null or unknown values fall back to
  /// [standard].
  static ReaderTheme fromName(String? name) =>
      values.firstWhere((v) => v.name == name, orElse: () => standard);
}

/// Applies a change to the current [TextReaderPreferences].
typedef TextReaderPreferencesChange =
    TextReaderPreferences Function(TextReaderPreferences current);

/// Typography preferences of the text reader. [copyWith] and the `step*`
/// methods clamp their results; the constructor asserts the same ranges.
class TextReaderPreferences extends Equatable {
  static const double minFontSize = 14;
  static const double maxFontSize = 28;
  static const double fontSizeStep = 1;
  static const double minLineHeight = 1.2;
  static const double maxLineHeight = 2.2;
  static const double lineHeightStep = 0.1;

  /// Letter and word spacing are fractions of the font size (em).
  static const double maxLetterSpacing = 0.10;
  static const double letterSpacingStep = 0.01;
  static const double maxWordSpacing = 0.32;
  static const double wordSpacingStep = 0.02;

  /// Line width is in `ch`: the width of the glyph `0` in the reader font.
  /// Below [minLineWidth] the limit is off (null).
  static const double minLineWidth = 40;
  static const double maxLineWidth = 100;
  static const double lineWidthStep = 5;

  /// Figma `Leitura/Serifa`: Literata 19 dp at 180% line height.
  static const TextReaderPreferences defaults = TextReaderPreferences(
    fontFamily: ReaderFontFamily.serif,
    fontSize: 19,
    lineHeight: 1.8,
    alignment: ReaderTextAlignment.left,
  );

  /// Figma `Leitor/Predefinição · Modo dislexia`: Lexend, left, letters +5%,
  /// words +16%, line 1.8, 60ch, no italics and the reading ruler. The font
  /// size is the user's own and is kept.
  TextReaderPreferences get withDyslexiaPreset => copyWith(
    fontFamily: ReaderFontFamily.lexend,
    alignment: ReaderTextAlignment.left,
    lineHeight: 1.8,
    letterSpacing: 0.05,
    wordSpacing: 0.16,
    lineWidth: 60,
    suppressItalics: true,
    readingRuler: true,
  );

  final ReaderFontFamily fontFamily;

  /// Font size in dp.
  final double fontSize;

  /// Line height as a multiple of the font size.
  final double lineHeight;
  final ReaderTextAlignment alignment;

  /// Extra space between letters, in em; 0 is the font's own.
  final double letterSpacing;

  /// Extra space between words, in em; 0 is the font's own.
  final double wordSpacing;

  /// Maximum line width in `ch`; null means no limit.
  final double? lineWidth;

  /// Shows emphasised text as regular.
  final bool suppressItalics;

  /// Highlights one line with the rest of the page dimmed.
  final bool readingRuler;

  const TextReaderPreferences({
    required this.fontFamily,
    required this.fontSize,
    required this.lineHeight,
    required this.alignment,
    this.letterSpacing = 0,
    this.wordSpacing = 0,
    this.lineWidth,
    this.suppressItalics = false,
    this.readingRuler = false,
  }) : assert(fontSize >= minFontSize && fontSize <= maxFontSize),
       assert(lineHeight >= minLineHeight && lineHeight <= maxLineHeight),
       assert(letterSpacing >= 0 && letterSpacing <= maxLetterSpacing),
       assert(wordSpacing >= 0 && wordSpacing <= maxWordSpacing),
       assert(
         lineWidth == null ||
             (lineWidth >= minLineWidth && lineWidth <= maxLineWidth),
       );

  bool get canIncreaseFontSize => fontSize < maxFontSize;
  bool get canDecreaseFontSize => fontSize > minFontSize;
  bool get canIncreaseLineHeight => lineHeight < maxLineHeight;
  bool get canDecreaseLineHeight => lineHeight > minLineHeight;
  bool get canIncreaseLetterSpacing => letterSpacing < maxLetterSpacing;
  bool get canDecreaseLetterSpacing => letterSpacing > 0;
  bool get canIncreaseWordSpacing => wordSpacing < maxWordSpacing;
  bool get canDecreaseWordSpacing => wordSpacing > 0;
  bool get canIncreaseLineWidth => (lineWidth ?? 0) < maxLineWidth;
  bool get canDecreaseLineWidth => lineWidth != null;

  /// Moves the font size by [steps] of [fontSizeStep], clamped.
  TextReaderPreferences stepFontSize(int steps) =>
      copyWith(fontSize: _stepped(fontSize, fontSizeStep, steps));

  /// Moves the line height by [steps] of [lineHeightStep], clamped.
  TextReaderPreferences stepLineHeight(int steps) =>
      copyWith(lineHeight: _stepped(lineHeight, lineHeightStep, steps));

  /// Moves the letter spacing by [steps] of [letterSpacingStep], clamped.
  TextReaderPreferences stepLetterSpacing(int steps) => copyWith(
    letterSpacing: _stepped(letterSpacing, letterSpacingStep, steps),
  );

  /// Moves the word spacing by [steps] of [wordSpacingStep], clamped.
  TextReaderPreferences stepWordSpacing(int steps) =>
      copyWith(wordSpacing: _stepped(wordSpacing, wordSpacingStep, steps));

  /// Moves the line width by [steps] of [lineWidthStep]. "No limit" sits one
  /// step below [minLineWidth], so stepping down from the minimum turns the
  /// limit off and stepping up from off sets the minimum.
  TextReaderPreferences stepLineWidth(int steps) {
    final next = _stepped(
      lineWidth ?? minLineWidth - lineWidthStep,
      lineWidthStep,
      steps,
    );
    return next < minLineWidth
        ? copyWith(clearLineWidth: true)
        : copyWith(lineWidth: next);
  }

  /// `value + steps * step` quantised to hundredths, so `1.8 + 0.1` is `1.9`,
  /// not `1.9000000000000001`. Every step is a multiple of 0.01; clamping
  /// happens in [copyWith].
  static double _stepped(double value, double step, int steps) =>
      ((value + steps * step) * _quantum).roundToDouble() / _quantum;

  static const double _quantum = 100;

  TextReaderPreferences copyWith({
    ReaderFontFamily? fontFamily,
    double? fontSize,
    double? lineHeight,
    ReaderTextAlignment? alignment,
    double? letterSpacing,
    double? wordSpacing,
    double? lineWidth,
    bool clearLineWidth = false,
    bool? suppressItalics,
    bool? readingRuler,
  }) {
    final width = clearLineWidth ? null : lineWidth ?? this.lineWidth;
    return TextReaderPreferences(
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: (fontSize ?? this.fontSize).clamp(minFontSize, maxFontSize),
      lineHeight: (lineHeight ?? this.lineHeight).clamp(
        minLineHeight,
        maxLineHeight,
      ),
      alignment: alignment ?? this.alignment,
      letterSpacing: (letterSpacing ?? this.letterSpacing).clamp(
        0.0,
        maxLetterSpacing,
      ),
      wordSpacing: (wordSpacing ?? this.wordSpacing).clamp(0.0, maxWordSpacing),
      lineWidth: width?.clamp(minLineWidth, maxLineWidth),
      suppressItalics: suppressItalics ?? this.suppressItalics,
      readingRuler: readingRuler ?? this.readingRuler,
    );
  }

  @override
  List<Object?> get props => [
    fontFamily,
    fontSize,
    lineHeight,
    alignment,
    letterSpacing,
    wordSpacing,
    lineWidth,
    suppressItalics,
    readingRuler,
  ];
}

/// What the dyslexia preset overwrote, kept while it is on so turning it off
/// restores the user's own values.
class DyslexiaSnapshot extends Equatable {
  final ReaderTheme theme;
  final TextReaderPreferences text;

  const DyslexiaSnapshot({required this.theme, required this.text});

  @override
  List<Object?> get props => [theme, text];
}

/// Everything the user can customize in the readers. Per-reader sections are
/// fields here ([text] today); the theme is shared by all readers.
class ReaderPreferences extends Equatable {
  static const ReaderPreferences defaults = ReaderPreferences(
    theme: ReaderTheme.standard,
    text: TextReaderPreferences.defaults,
  );

  final ReaderTheme theme;
  final TextReaderPreferences text;

  /// Non-null exactly while the dyslexia preset is on.
  final DyslexiaSnapshot? dyslexiaSnapshot;

  const ReaderPreferences({
    required this.theme,
    required this.text,
    this.dyslexiaSnapshot,
  });

  bool get dyslexiaMode => dyslexiaSnapshot != null;

  /// Turns the dyslexia preset on or off. On snapshots the current theme and
  /// text values, then writes the preset (cream theme and
  /// [TextReaderPreferences.withDyslexiaPreset]); edits made while it is on
  /// are plain changes. Off restores the snapshot, keeping the font size,
  /// which the preset does not touch. Either call is a no-op when the mode
  /// already has that value.
  ReaderPreferences withDyslexiaMode(bool enabled) {
    final snapshot = dyslexiaSnapshot;
    if (enabled == dyslexiaMode) return this;
    if (enabled) {
      return ReaderPreferences(
        theme: ReaderTheme.cream,
        text: text.withDyslexiaPreset,
        dyslexiaSnapshot: DyslexiaSnapshot(theme: theme, text: text),
      );
    }
    return ReaderPreferences(
      theme: snapshot!.theme,
      text: snapshot.text.copyWith(fontSize: text.fontSize),
    );
  }

  ReaderPreferences copyWith({
    ReaderTheme? theme,
    TextReaderPreferences? text,
  }) {
    return ReaderPreferences(
      theme: theme ?? this.theme,
      text: text ?? this.text,
      dyslexiaSnapshot: dyslexiaSnapshot,
    );
  }

  @override
  List<Object?> get props => [theme, text, dyslexiaSnapshot];
}
