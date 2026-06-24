// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookModel _$BookModelFromJson(Map<String, dynamic> json) => BookModel(
  id: BookId.fromJson(json['id'] as String),
  title: BookTitle.fromJson(json['title'] as String),
  authors: json['authors'] == null
      ? const []
      : const AuthorListConverter().fromJson(json['authors'] as List?),
  tags: json['tags'] == null
      ? const []
      : const TagListConverter().fromJson(json['tags'] as List?),
  description: json['description'] == null
      ? null
      : BookDescription.fromJson(json['description'] as String),
  cover: json['cover'] == null
      ? null
      : BookCover.fromJson(json['cover'] as String),
  imageMetadata: json['coverMetadata'] == null
      ? null
      : ImageMetadataModel.fromJson(
          json['coverMetadata'] as Map<String, dynamic>,
        ),
  type: const TypeBookConverter().fromJson(json['type']),
  publication: json['publication'] == null
      ? null
      : PositiveInt.fromJson((json['publication'] as num).toInt()),
  totalChapters: json['totalChapters'] == null
      ? null
      : PositiveInt.fromJson((json['totalChapters'] as num).toInt()),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$BookModelToJson(BookModel instance) => <String, dynamic>{
  'id': instance.id.toJson(),
  'title': instance.title.toJson(),
  'authors': const AuthorListConverter().toJson(instance.authors),
  'tags': const TagListConverter().toJson(instance.tags),
  'description': instance.description?.toJson(),
  'cover': instance.cover?.toJson(),
  'type': const TypeBookConverter().toJson(instance.type),
  'publication': instance.publication?.toJson(),
  'totalChapters': instance.totalChapters?.toJson(),
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'coverMetadata': instance.imageMetadata?.toJson(),
};

BookListModel _$BookListModelFromJson(Map<String, dynamic> json) =>
    BookListModel(
      data: const BookListConverter().fromJson(json['data'] as List?),
      total: PositiveInt.fromJson(
        (BookListModel._readTotal(json, 'total') as num).toInt(),
      ),
      page: PositiveInt.fromJson(
        (BookListModel._readPage(json, 'page') as num).toInt(),
      ),
      limit: PositiveInt.fromJson(
        (BookListModel._readLimit(json, 'limit') as num).toInt(),
      ),
      totalPages: PositiveInt.fromJson(
        (BookListModel._readTotalPages(json, 'totalPages') as num).toInt(),
      ),
    );

Map<String, dynamic> _$BookListModelToJson(BookListModel instance) =>
    <String, dynamic>{
      'data': const BookListConverter().toJson(instance.data),
      'total': instance.total.toJson(),
      'page': instance.page.toJson(),
      'limit': instance.limit.toJson(),
      'totalPages': instance.totalPages.toJson(),
    };
