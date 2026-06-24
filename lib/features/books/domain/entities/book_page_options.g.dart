// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_page_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookPageOptions _$BookPageOptionsFromJson(Map<String, dynamic> json) =>
    BookPageOptions(
      page: json['page'] == null
          ? const PositiveInt(1)
          : PositiveInt.fromJson((json['page'] as num).toInt()),
      limit: json['limit'] == null
          ? const PositiveInt(20)
          : PositiveInt.fromJson((json['limit'] as num).toInt()),
      orderBy: json['orderBy'] as String? ?? 'createdAt',
      order:
          $enumDecodeNullable(_$SortOrderEnumMap, json['order']) ??
          SortOrder.desc,
      search: json['search'] as String?,
      publication: json['publication'] == null
          ? null
          : PositiveInt.fromJson((json['publication'] as num).toInt()),
      publicationOperator: json['publicationOperator'] as String?,
      type: (json['type'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$TypeBookEnumMap, e))
          .toList(),
      sensitiveContent: (json['sensitiveContent'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      tagsLogic: json['tagsLogic'] as String?,
      excludeTags: (json['excludeTags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      excludeTagsLogic: json['excludeTagsLogic'] as String?,
      authors: (json['authors'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      authorsLogic: json['authorsLogic'] as String?,
    );

Map<String, dynamic> _$BookPageOptionsToJson(BookPageOptions instance) =>
    <String, dynamic>{
      'page': instance.page,
      'limit': instance.limit,
      'orderBy': instance.orderBy,
      'order': BookPageOptions._orderToJson(instance.order),
      'search': ?instance.search,
      'publication': ?instance.publication,
      'publicationOperator': ?instance.publicationOperator,
      'type': ?BookPageOptions._typeToJson(instance.type),
      'sensitiveContent': ?instance.sensitiveContent,
      'tags': ?instance.tags,
      'tagsLogic': ?instance.tagsLogic,
      'excludeTags': ?instance.excludeTags,
      'excludeTagsLogic': ?instance.excludeTagsLogic,
      'authors': ?instance.authors,
      'authorsLogic': ?instance.authorsLogic,
    };

const _$SortOrderEnumMap = {SortOrder.asc: 'asc', SortOrder.desc: 'desc'};

const _$TypeBookEnumMap = {
  TypeBook.manga: 'manga',
  TypeBook.manhwa: 'manhwa',
  TypeBook.manhua: 'manhua',
  TypeBook.book: 'book',
  TypeBook.other: 'other',
};
