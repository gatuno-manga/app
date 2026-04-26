// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookModel _$BookModelFromJson(Map<String, dynamic> json) => BookModel(
  id: json['id'] as String,
  title: json['title'] as String,
  authors: json['authors'] == null
      ? const []
      : const AuthorListConverter().fromJson(json['authors'] as List?),
  tags: json['tags'] == null
      ? const []
      : const TagListConverter().fromJson(json['tags'] as List?),
  description: json['description'] as String?,
  cover: json['cover'] as String?,
  type: const TypeBookConverter().fromJson(json['type']),
  publication: (json['publication'] as num?)?.toInt(),
  totalChapters: (json['totalChapters'] as num?)?.toInt(),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$BookModelToJson(BookModel instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'authors': const AuthorListConverter().toJson(instance.authors),
  'tags': const TagListConverter().toJson(instance.tags),
  'description': instance.description,
  'cover': instance.cover,
  'type': const TypeBookConverter().toJson(instance.type),
  'publication': instance.publication,
  'totalChapters': instance.totalChapters,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

BookListModel _$BookListModelFromJson(Map<String, dynamic> json) =>
    BookListModel(
      data: const BookListConverter().fromJson(json['data'] as List?),
      total: (BookListModel._readTotal(json, 'total') as num).toInt(),
      page: (BookListModel._readPage(json, 'page') as num).toInt(),
      limit: (BookListModel._readLimit(json, 'limit') as num).toInt(),
      totalPages: (BookListModel._readTotalPages(json, 'totalPages') as num)
          .toInt(),
    );

Map<String, dynamic> _$BookListModelToJson(BookListModel instance) =>
    <String, dynamic>{
      'data': const BookListConverter().toJson(instance.data),
      'total': instance.total,
      'page': instance.page,
      'limit': instance.limit,
      'totalPages': instance.totalPages,
    };
