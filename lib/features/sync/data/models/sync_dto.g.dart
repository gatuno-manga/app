// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncCommentDto _$SyncCommentDtoFromJson(Map<String, dynamic> json) =>
    SyncCommentDto(
      chapterId: ChapterId.fromJson(
        const StringConverter().fromJson(json['chapterId']),
      ),
      parentId: json['parentId'] == null
          ? null
          : CommentId.fromJson(
              const StringConverter().fromJson(json['parentId']),
            ),
      content: CommentContent.fromJson(
        const StringConverter().fromJson(json['content']),
      ),
      isPublic: json['isPublic'] as bool?,
    );

Map<String, dynamic> _$SyncCommentDtoToJson(SyncCommentDto instance) =>
    <String, dynamic>{
      'chapterId': instance.chapterId.toJson(),
      'parentId': instance.parentId?.toJson(),
      'content': instance.content.toJson(),
      'isPublic': instance.isPublic,
    };

PushSyncRequestDto _$PushSyncRequestDtoFromJson(Map<String, dynamic> json) =>
    PushSyncRequestDto(
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

Map<String, dynamic> _$PushSyncRequestDtoToJson(
  PushSyncRequestDto instance,
) => <String, dynamic>{
  'readingProgress': instance.readingProgress?.map((e) => e.toJson()).toList(),
  'savedPages': instance.savedPages,
  'comments': instance.comments?.map((e) => e.toJson()).toList(),
};

PullSyncResponseDto _$PullSyncResponseDtoFromJson(Map<String, dynamic> json) =>
    PullSyncResponseDto(
      syncedAt: Timestamp.fromJson(json['syncedAt']),
      data: json['data'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$PullSyncResponseDtoToJson(
  PullSyncResponseDto instance,
) => <String, dynamic>{
  'syncedAt': instance.syncedAt.toJson(),
  'data': instance.data,
};
