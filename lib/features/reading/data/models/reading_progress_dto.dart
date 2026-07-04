import 'package:json_annotation/json_annotation.dart';
import '../../../../features/books/domain/value_objects/book_id.dart';
import '../../../../features/books/domain/value_objects/chapter_id.dart';
import '../../../../features/users/domain/value_objects/user_id.dart';
import '../../../../shared/domain/value_objects/positive_int.dart';
import '../../../../shared/domain/value_objects/timestamp.dart';
import '../../domain/value_objects/progress_id.dart';

part 'reading_progress_dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class RemoteReadingProgress {
  final ProgressId id;
  final UserId? userId;
  final ChapterId chapterId;
  final BookId bookId;
  final PositiveInt pageIndex;
  final Timestamp? timestamp;
  final PositiveInt? totalPages;
  final bool? completed;
  final Timestamp? updatedAt;

  RemoteReadingProgress({
    required this.id,
    this.userId,
    required this.chapterId,
    required this.bookId,
    required this.pageIndex,
    this.timestamp,
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
  final ChapterId chapterId;
  final BookId bookId;
  final PositiveInt pageIndex;
  @TimestampAsIntConverter()
  final Timestamp timestamp;
  final PositiveInt? totalPages;
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
