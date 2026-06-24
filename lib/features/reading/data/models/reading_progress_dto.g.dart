// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_progress_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RemoteReadingProgress _$RemoteReadingProgressFromJson(
  Map<String, dynamic> json,
) => RemoteReadingProgress(
  id: ProgressId.fromJson(json['id'] as String),
  userId: UserId.fromJson(json['user_id'] as String),
  chapterId: ChapterId.fromJson(json['chapter_id'] as String),
  bookId: BookId.fromJson(json['book_id'] as String),
  pageIndex: PositiveInt.fromJson((json['page_index'] as num).toInt()),
  timestamp: Timestamp.fromJson(json['timestamp']),
  version: PositiveInt.fromJson((json['version'] as num).toInt()),
  totalPages: json['total_pages'] == null
      ? null
      : PositiveInt.fromJson((json['total_pages'] as num).toInt()),
  completed: json['completed'] as bool?,
  updatedAt: json['updated_at'] == null
      ? null
      : Timestamp.fromJson(json['updated_at']),
);

Map<String, dynamic> _$RemoteReadingProgressToJson(
  RemoteReadingProgress instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'chapter_id': instance.chapterId,
  'book_id': instance.bookId,
  'page_index': instance.pageIndex,
  'timestamp': instance.timestamp,
  'version': instance.version,
  'total_pages': instance.totalPages,
  'completed': instance.completed,
  'updated_at': instance.updatedAt,
};

SaveProgressDto _$SaveProgressDtoFromJson(Map<String, dynamic> json) =>
    SaveProgressDto(
      chapterId: ChapterId.fromJson(json['chapter_id'] as String),
      bookId: BookId.fromJson(json['book_id'] as String),
      pageIndex: PositiveInt.fromJson((json['page_index'] as num).toInt()),
      timestamp: const TimestampAsIntConverter().fromJson(
        (json['timestamp'] as num).toInt(),
      ),
      totalPages: json['total_pages'] == null
          ? null
          : PositiveInt.fromJson((json['total_pages'] as num).toInt()),
      completed: json['completed'] as bool?,
    );

Map<String, dynamic> _$SaveProgressDtoToJson(SaveProgressDto instance) =>
    <String, dynamic>{
      'chapter_id': instance.chapterId,
      'book_id': instance.bookId,
      'page_index': instance.pageIndex,
      'timestamp': const TimestampAsIntConverter().toJson(instance.timestamp),
      'total_pages': instance.totalPages,
      'completed': instance.completed,
    };

SyncReadingProgressDto _$SyncReadingProgressDtoFromJson(
  Map<String, dynamic> json,
) => SyncReadingProgressDto(
  progress: (json['progress'] as List<dynamic>)
      .map((e) => SaveProgressDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  lastSyncAt: json['last_sync_at'] == null
      ? null
      : DateTime.parse(json['last_sync_at'] as String),
);

Map<String, dynamic> _$SyncReadingProgressDtoToJson(
  SyncReadingProgressDto instance,
) => <String, dynamic>{
  'progress': instance.progress,
  'last_sync_at': instance.lastSyncAt?.toIso8601String(),
};
