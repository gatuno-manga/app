// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncCommentDto _$SyncCommentDtoFromJson(Map<String, dynamic> json) =>
    SyncCommentDto(
      chapterId: json['chapterId'] as String,
      parentId: json['parentId'] as String?,
      content: json['content'] as String,
      isPublic: json['isPublic'] as bool?,
    );

Map<String, dynamic> _$SyncCommentDtoToJson(SyncCommentDto instance) =>
    <String, dynamic>{
      'chapterId': instance.chapterId,
      'parentId': instance.parentId,
      'content': instance.content,
      'isPublic': instance.isPublic,
    };

SyncRequestDto _$SyncRequestDtoFromJson(Map<String, dynamic> json) =>
    SyncRequestDto(
      lastSyncAt: json['lastSyncAt'] as String?,
      readingProgress: (json['readingProgress'] as List<dynamic>?)
          ?.map((e) => SaveProgressDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      savedPages: (json['savedPages'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      comments: (json['comments'] as List<dynamic>?)
          ?.map((e) => SyncCommentDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SyncRequestDtoToJson(
  SyncRequestDto instance,
) => <String, dynamic>{
  'lastSyncAt': instance.lastSyncAt,
  'readingProgress': instance.readingProgress?.map((e) => e.toJson()).toList(),
  'savedPages': instance.savedPages,
  'comments': instance.comments?.map((e) => e.toJson()).toList(),
};

SyncReadingProgressResultDto _$SyncReadingProgressResultDtoFromJson(
  Map<String, dynamic> json,
) => SyncReadingProgressResultDto(
  synced: (json['synced'] as List<dynamic>)
      .map((e) => RemoteReadingProgress.fromJson(e as Map<String, dynamic>))
      .toList(),
  conflicts: json['conflicts'] as List<dynamic>,
  lastSyncAt: json['lastSyncAt'] as String,
);

Map<String, dynamic> _$SyncReadingProgressResultDtoToJson(
  SyncReadingProgressResultDto instance,
) => <String, dynamic>{
  'synced': instance.synced.map((e) => e.toJson()).toList(),
  'conflicts': instance.conflicts,
  'lastSyncAt': instance.lastSyncAt,
};

SyncResultDto _$SyncResultDtoFromJson(Map<String, dynamic> json) =>
    SyncResultDto(
      readingProgress: json['readingProgress'] == null
          ? null
          : SyncReadingProgressResultDto.fromJson(
              json['readingProgress'] as Map<String, dynamic>,
            ),
      savedPages: json['savedPages'] as List<dynamic>?,
      comments: json['comments'] as List<dynamic>?,
      syncedAt: json['syncedAt'] as String,
    );

Map<String, dynamic> _$SyncResultDtoToJson(SyncResultDto instance) =>
    <String, dynamic>{
      'readingProgress': instance.readingProgress?.toJson(),
      'savedPages': instance.savedPages,
      'comments': instance.comments,
      'syncedAt': instance.syncedAt,
    };
