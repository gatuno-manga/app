import 'package:json_annotation/json_annotation.dart';
import 'package:optional/optional.dart';
import 'book_type.dart';

part 'book_page_options.g.dart';

enum SortOrder { asc, desc }

class SortOption {
  final String orderBy;
  final SortOrder order;
  const SortOption(this.orderBy, this.order);
}

@JsonSerializable(includeIfNull: false)
class BookPageOptions {
  final int page;
  final int limit;
  final String orderBy;
  @JsonKey(toJson: _orderToJson)
  final SortOrder order;
  final String? search;
  final int? publication;
  final String? publicationOperator; // 'eq', 'gt', 'lt', 'gte', 'lte'
  @JsonKey(toJson: _typeToJson)
  final List<TypeBook>? type;
  final List<String>? sensitiveContent;
  final List<String>? tags;
  final String? tagsLogic; // 'and', 'or'
  final List<String>? excludeTags;
  final String? excludeTagsLogic; // 'and', 'or'
  final List<String>? authors;
  final String? authorsLogic; // 'and', 'or'

  const BookPageOptions({
    this.page = 1,
    this.limit = 20,
    this.orderBy = 'createdAt',
    this.order = SortOrder.desc,
    this.search,
    this.publication,
    this.publicationOperator,
    this.type,
    this.sensitiveContent,
    this.tags,
    this.tagsLogic,
    this.excludeTags,
    this.excludeTagsLogic,
    this.authors,
    this.authorsLogic,
  });

  Map<String, dynamic> toJson() => _$BookPageOptionsToJson(this);

  static String _orderToJson(SortOrder order) => order.name.toUpperCase();
  static List<String>? _typeToJson(List<TypeBook>? type) =>
      type?.map((e) => e.name.toLowerCase()).toList();

  BookPageOptions copyWith({
    int? page,
    int? limit,
    String? orderBy,
    SortOrder? order,
    Optional<String?>? search,
    Optional<int?>? publication,
    Optional<String?>? publicationOperator,
    Optional<List<TypeBook>?>? type,
    Optional<List<String>?>? sensitiveContent,
    Optional<List<String>?>? tags,
    Optional<String?>? tagsLogic,
    Optional<List<String>?>? excludeTags,
    Optional<String?>? excludeTagsLogic,
    Optional<List<String>?>? authors,
    Optional<String?>? authorsLogic,
  }) {
    return BookPageOptions(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      orderBy: orderBy ?? this.orderBy,
      order: order ?? this.order,
      search: search != null ? search.orElse(null) : this.search,
      publication: publication != null
          ? publication.orElse(null)
          : this.publication,
      publicationOperator: publicationOperator != null
          ? publicationOperator.orElse(null)
          : this.publicationOperator,
      type: type != null ? type.orElse(null) : this.type,
      sensitiveContent: sensitiveContent != null
          ? sensitiveContent.orElse(null)
          : this.sensitiveContent,
      tags: tags != null ? tags.orElse(null) : this.tags,
      tagsLogic: tagsLogic != null ? tagsLogic.orElse(null) : this.tagsLogic,
      excludeTags: excludeTags != null
          ? excludeTags.orElse(null)
          : this.excludeTags,
      excludeTagsLogic: excludeTagsLogic != null
          ? excludeTagsLogic.orElse(null)
          : this.excludeTagsLogic,
      authors: authors != null ? authors.orElse(null) : this.authors,
      authorsLogic: authorsLogic != null
          ? authorsLogic.orElse(null)
          : this.authorsLogic,
    );
  }
}
