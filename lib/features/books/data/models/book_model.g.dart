// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookModel _$BookModelFromJson(Map<String, dynamic> json) => BookModel(
  id: json['id'] as String,
  title: json['title'] as String,
  authors:
      (json['authors'] as List<dynamic>?)
          ?.map((e) => AuthorModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  tags:
      (json['tags'] as List<dynamic>?)
          ?.map((e) => TagModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  description: json['description'] as String?,
  cover: json['cover'] as String?,
  type: BookModel._parseType(json['type']),
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
  'description': instance.description,
  'cover': instance.cover,
  'publication': instance.publication,
  'totalChapters': instance.totalChapters,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'authors': instance.authors.map((e) => e.toJson()).toList(),
  'tags': instance.tags.map((e) => e.toJson()).toList(),
  'type': _$TypeBookEnumMap[instance.type],
};

const _$TypeBookEnumMap = {
  TypeBook.manga: 'manga',
  TypeBook.manhwa: 'manhwa',
  TypeBook.manhua: 'manhua',
  TypeBook.book: 'book',
  TypeBook.other: 'other',
};

BookListModel _$BookListModelFromJson(Map<String, dynamic> json) =>
    BookListModel(
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => BookModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: (BookListModel._readTotal(json, 'total') as num).toInt(),
      page: (BookListModel._readPage(json, 'page') as num).toInt(),
      limit: (BookListModel._readLimit(json, 'limit') as num).toInt(),
      totalPages: (BookListModel._readTotalPages(json, 'totalPages') as num)
          .toInt(),
    );

Map<String, dynamic> _$BookListModelToJson(BookListModel instance) =>
    <String, dynamic>{
      'total': instance.total,
      'page': instance.page,
      'limit': instance.limit,
      'totalPages': instance.totalPages,
      'data': instance.data,
    };
