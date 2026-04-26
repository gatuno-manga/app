import 'package:json_annotation/json_annotation.dart';

part 'chapter_page_options.g.dart';

enum ChapterSortOrder { asc, desc }

@JsonSerializable(includeIfNull: false)
class ChapterPageOptions {
  final String? cursor;
  final int limit;
  @JsonKey(toJson: _orderToJson)
  final ChapterSortOrder order;

  const ChapterPageOptions({
    this.cursor,
    this.limit = 200,
    this.order = ChapterSortOrder.asc,
  });

  Map<String, dynamic> toJson() => _$ChapterPageOptionsToJson(this);

  ChapterPageOptions copyWith({
    String? cursor,
    int? limit,
    ChapterSortOrder? order,
  }) {
    return ChapterPageOptions(
      cursor: cursor ?? this.cursor,
      limit: limit ?? this.limit,
      order: order ?? this.order,
    );
  }

  static String _orderToJson(ChapterSortOrder order) => order.name.toUpperCase();
}
