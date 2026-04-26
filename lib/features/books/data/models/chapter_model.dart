import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/chapter.dart';

part 'chapter_model.g.dart';

@JsonSerializable()
class ChapterModel extends Chapter {
  @override
  @JsonKey(fromJson: _parseString)
  final String id;

  @override
  @JsonKey(fromJson: _parseIndex)
  final double index;

  @override
  @JsonKey(fromJson: _parseScrapingStatus)
  final ScrapingStatus? scrapingStatus;

  const ChapterModel({
    required this.id,
    super.title,
    required this.index,
    this.scrapingStatus,
    super.read = false,
  }) : super(
          id: id,
          index: index,
          scrapingStatus: scrapingStatus,
        );

  factory ChapterModel.fromJson(Map<String, dynamic> json) =>
      _$ChapterModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChapterModelToJson(this);

  static String _parseString(dynamic value) => value?.toString() ?? '';

  static double _parseIndex(dynamic index) {
    if (index == null) return 0.0;
    if (index is num) return index.toDouble();
    return double.tryParse(index.toString()) ?? 0.0;
  }

  static ScrapingStatus? _parseScrapingStatus(dynamic status) {
    if (status == null) return null;
    final statusStr = status.toString();
    try {
      return ScrapingStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == statusStr.toLowerCase(),
      );
    } catch (_) {
      return ScrapingStatus.process;
    }
  }
}

@JsonSerializable()
class ChapterListModel extends ChapterList {
  @override
  final List<ChapterModel> data;

  @override
  @JsonKey(fromJson: _parseStringNullable)
  final String? nextCursor;

  const ChapterListModel({
    required this.data,
    this.nextCursor,
    required super.hasNextPage,
  }) : super(
          data: data,
          nextCursor: nextCursor,
        );

  factory ChapterListModel.fromJson(Map<String, dynamic> json) =>
      _$ChapterListModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChapterListModelToJson(this);

  static String? _parseStringNullable(dynamic value) => value?.toString();
  static String _parseString(dynamic value) => value?.toString() ?? '';
}
