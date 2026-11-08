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

  /// Figma `Leitura/Serifa`: Literata 19 dp at 180% line height.
  static const TextReaderPreferences defaults = TextReaderPreferences(
    fontFamily: ReaderFontFamily.serif,
    fontSize: 19,
    lineHeight: 1.8,
    alignment: ReaderTextAlignment.left,
  );

  final ReaderFontFamily fontFamily;

  /// Font size in dp.
  final double fontSize;

  /// Line height as a multiple of the font size.
  final double lineHeight;
  final ReaderTextAlignment alignment;

  const TextReaderPreferences({
    required this.fontFamily,
    required this.fontSize,
    required this.lineHeight,
    required this.alignment,
  }) : assert(fontSize >= minFontSize && fontSize <= maxFontSize),
       assert(lineHeight >= minLineHeight && lineHeight <= maxLineHeight);

  bool get canIncreaseFontSize => fontSize < maxFontSize;
  bool get canDecreaseFontSize => fontSize > minFontSize;
  bool get canIncreaseLineHeight => lineHeight < maxLineHeight;
  bool get canDecreaseLineHeight => lineHeight > minLineHeight;

  /// Moves the font size by [steps] of [fontSizeStep], clamped.
  TextReaderPreferences stepFontSize(int steps) =>
      copyWith(fontSize: _stepped(fontSize, fontSizeStep, steps));

  /// Moves the line height by [steps] of [lineHeightStep], clamped.
  TextReaderPreferences stepLineHeight(int steps) =>
      copyWith(lineHeight: _stepped(lineHeight, lineHeightStep, steps));

  /// `value + steps * step` quantised to tenths, so `1.8 + 0.1` is `1.9`,
  /// not `1.9000000000000001`. Both steps are multiples of 0.1; clamping
  /// happens in [copyWith].
  static double _stepped(double value, double step, int steps) =>
      ((value + steps * step) * _quantum).roundToDouble() / _quantum;

  static const double _quantum = 10;

  TextReaderPreferences copyWith({
    ReaderFontFamily? fontFamily,
    double? fontSize,
    double? lineHeight,
    ReaderTextAlignment? alignment,
  }) {
    return TextReaderPreferences(
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: (fontSize ?? this.fontSize).clamp(minFontSize, maxFontSize),
      lineHeight: (lineHeight ?? this.lineHeight).clamp(
        minLineHeight,
        maxLineHeight,
      ),
      alignment: alignment ?? this.alignment,
    );
  }

  @override
  List<Object?> get props => [fontFamily, fontSize, lineHeight, alignment];
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

  const ReaderPreferences({required this.theme, required this.text});

  ReaderPreferences copyWith({
    ReaderTheme? theme,
    TextReaderPreferences? text,
  }) {
    return ReaderPreferences(
      theme: theme ?? this.theme,
      text: text ?? this.text,
    );
  }

  @override
  List<Object?> get props => [theme, text];
}
