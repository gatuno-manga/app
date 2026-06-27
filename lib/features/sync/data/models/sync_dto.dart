import 'package:json_annotation/json_annotation.dart';
import '../../../../features/reading/data/models/reading_progress_dto.dart';
import '../../../../features/books/domain/value_objects/chapter_id.dart';
import '../../../../features/reading/domain/value_objects/comment_id.dart';
import '../../../../features/reading/domain/value_objects/comment_content.dart';
import '../../../../shared/domain/value_objects/timestamp.dart';

part 'sync_dto.g.dart';

class StringConverter implements JsonConverter<String, dynamic> {
  const StringConverter();
  @override
  String fromJson(dynamic json) => json?.toString() ?? '';
  @override
  dynamic toJson(String object) => object;
}

@JsonSerializable(explicitToJson: true, converters: [StringConverter()])
class SyncCommentDto {
  final ChapterId chapterId;
  final CommentId? parentId;
  final CommentContent content;
  final bool? isPublic;

  SyncCommentDto({
    required this.chapterId,
    this.parentId,
    required this.content,
    this.isPublic,
  });

  factory SyncCommentDto.fromJson(Map<String, dynamic> json) =>
      _$SyncCommentDtoFromJson(json);
  Map<String, dynamic> toJson() => _$SyncCommentDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PushSyncRequestDto {
  final List<SaveProgressDto>? readingProgress;
  final List<Map<String, dynamic>>? savedPages;
  final List<SyncCommentDto>? comments;

  PushSyncRequestDto({
    this.readingProgress,
    this.savedPages,
    this.comments,
  });

  factory PushSyncRequestDto.fromJson(Map<String, dynamic> json) =>
      _$PushSyncRequestDtoFromJson(json);
  Map<String, dynamic> toJson() => _$PushSyncRequestDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PullSyncResponseDto {
  final Timestamp syncedAt;
  final Map<String, dynamic> data;

  PullSyncResponseDto({
    required this.syncedAt,
    required this.data,
  });

  factory PullSyncResponseDto.fromJson(Map<String, dynamic> json) =>
      _$PullSyncResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$PullSyncResponseDtoToJson(this);
}
