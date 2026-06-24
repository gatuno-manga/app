import 'package:json_annotation/json_annotation.dart';
import '../../../../shared/domain/value_objects/positive_int.dart';
import '../../domain/entities/chapter.dart';
import '../../domain/value_objects/chapter_id.dart';
import '../../domain/value_objects/chapter_index.dart';
import '../../domain/value_objects/chapter_title.dart';

part 'chapter_model.g.dart';

class IndexConverter implements JsonConverter<ChapterIndex, dynamic> {
  const IndexConverter();
  @override
  ChapterIndex fromJson(dynamic json) {
    if (json == null) return const ChapterIndex(0.0);
    if (json is num) return ChapterIndex(json.toDouble());
    return ChapterIndex(double.tryParse(json.toString()) ?? 0.0);
  }

  @override
  dynamic toJson(ChapterIndex object) => object.value;
}

class ScrapingStatusConverter
    implements JsonConverter<ScrapingStatus?, dynamic> {
  const ScrapingStatusConverter();
  @override
  ScrapingStatus? fromJson(dynamic json) {
    if (json == null) return null;
    final statusStr = json.toString();
    try {
      return ScrapingStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == statusStr.toLowerCase(),
      );
    } catch (_) {
      return ScrapingStatus.process;
    }
  }

  @override
  dynamic toJson(ScrapingStatus? object) => object?.name;
}

class StringConverter implements JsonConverter<String, dynamic> {
  const StringConverter();
  @override
  String fromJson(dynamic json) => json?.toString() ?? '';
  @override
  dynamic toJson(String object) => object;
}

class StringNullableConverter implements JsonConverter<String?, dynamic> {
  const StringNullableConverter();
  @override
  String? fromJson(dynamic json) => json?.toString();
  @override
  dynamic toJson(String? object) => object;
}

@JsonSerializable(
  converters: [IndexConverter(), ScrapingStatusConverter(), StringConverter()],
)
class ChapterModel extends Chapter {
  const ChapterModel({
    required super.id,
    super.title,
    required super.index,
    super.scrapingStatus,
    super.read = false,
    super.completed = false,
    super.lastPage = const PositiveInt(0),
  });

  factory ChapterModel.fromJson(Map<String, dynamic> json) =>
      _$ChapterModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChapterModelToJson(this);
}

class ChapterListConverter
    implements JsonConverter<List<Chapter>, List<dynamic>?> {
  const ChapterListConverter();
  @override
  List<Chapter> fromJson(List<dynamic>? json) {
    return (json ?? [])
        .map((e) => ChapterModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  List<dynamic> toJson(List<Chapter> object) {
    return object.map((e) => (e as ChapterModel).toJson()).toList();
  }
}

@JsonSerializable(
  converters: [ChapterListConverter(), StringNullableConverter()],
)
class ChapterListModel extends ChapterList {
  const ChapterListModel({
    required super.data,
    super.nextCursor,
    required super.hasNextPage,
  });

  factory ChapterListModel.fromJson(Map<String, dynamic> json) =>
      _$ChapterListModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChapterListModelToJson(this);
}
