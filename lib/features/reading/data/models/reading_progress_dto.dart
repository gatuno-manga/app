import 'package:json_annotation/json_annotation.dart';

part 'reading_progress_dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class RemoteReadingProgress {
  final String id;
  final String userId;
  final String chapterId;
  final String bookId;
  final int pageIndex;
  final DateTime timestamp;
  final int version;
  final int? totalPages;
  final bool? completed;
  final DateTime? updatedAt;

  RemoteReadingProgress({
    required this.id,
    required this.userId,
    required this.chapterId,
    required this.bookId,
    required this.pageIndex,
    required this.timestamp,
    required this.version,
    this.totalPages,
    this.completed,
    this.updatedAt,
  });

  factory RemoteReadingProgress.fromJson(Map<String, dynamic> json) =>
      _$RemoteReadingProgressFromJson(json);
  Map<String, dynamic> toJson() => _$RemoteReadingProgressToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SaveProgressDto {
  final String chapterId;
  final String bookId;
  final int pageIndex;
  final int timestamp; // Unix timestamp as used in the web app
  final int? totalPages;
  final bool? completed;

  SaveProgressDto({
    required this.chapterId,
    required this.bookId,
    required this.pageIndex,
    required this.timestamp,
    this.totalPages,
    this.completed,
  });

  factory SaveProgressDto.fromJson(Map<String, dynamic> json) =>
      _$SaveProgressDtoFromJson(json);
  Map<String, dynamic> toJson() => _$SaveProgressDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SyncReadingProgressDto {
  final List<SaveProgressDto> progress;
  final DateTime? lastSyncAt;

  SyncReadingProgressDto({required this.progress, this.lastSyncAt});

  factory SyncReadingProgressDto.fromJson(Map<String, dynamic> json) =>
      _$SyncReadingProgressDtoFromJson(json);
  Map<String, dynamic> toJson() => _$SyncReadingProgressDtoToJson(this);
}
