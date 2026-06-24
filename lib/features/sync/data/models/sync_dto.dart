import 'package:json_annotation/json_annotation.dart';
import '../../../../features/reading/data/models/reading_progress_dto.dart';

part 'sync_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class SyncCommentDto {
  final String chapterId;
  final String? parentId;
  final String content;
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
class SyncRequestDto {
  final String? lastSyncAt;
  final List<SaveProgressDto>? readingProgress;
  final List<Map<String, dynamic>>? savedPages; // Use Map since CreateSavedPageDto isn't defined yet
  final List<SyncCommentDto>? comments;

  SyncRequestDto({
    this.lastSyncAt,
    this.readingProgress,
    this.savedPages,
    this.comments,
  });

  factory SyncRequestDto.fromJson(Map<String, dynamic> json) =>
      _$SyncRequestDtoFromJson(json);
  Map<String, dynamic> toJson() => _$SyncRequestDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SyncReadingProgressResultDto {
  final List<RemoteReadingProgress> synced;
  final List<dynamic> conflicts;
  final String lastSyncAt;

  SyncReadingProgressResultDto({
    required this.synced,
    required this.conflicts,
    required this.lastSyncAt,
  });

  factory SyncReadingProgressResultDto.fromJson(Map<String, dynamic> json) =>
      _$SyncReadingProgressResultDtoFromJson(json);
  Map<String, dynamic> toJson() => _$SyncReadingProgressResultDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SyncResultDto {
  final SyncReadingProgressResultDto? readingProgress;
  final List<dynamic>? savedPages;
  final List<dynamic>? comments;
  final String syncedAt;

  SyncResultDto({
    this.readingProgress,
    this.savedPages,
    this.comments,
    required this.syncedAt,
  });

  factory SyncResultDto.fromJson(Map<String, dynamic> json) =>
      _$SyncResultDtoFromJson(json);
  Map<String, dynamic> toJson() => _$SyncResultDtoToJson(this);
}
