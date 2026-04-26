import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/book_type.dart';
import 'author_model.dart';
import 'tag_model.dart';

part 'book_model.g.dart';

@JsonSerializable(explicitToJson: true)
class BookModel extends Book {
  @override
  @JsonKey(defaultValue: [])
  final List<AuthorModel> authors;

  @override
  @JsonKey(defaultValue: [])
  final List<TagModel> tags;

  @override
  @JsonKey(name: 'type', fromJson: _parseType)
  final TypeBook? type;

  const BookModel({
    required super.id,
    required super.title,
    this.authors = const [],
    this.tags = const [],
    super.description,
    super.cover,
    this.type,
    super.publication,
    super.totalChapters,
    super.createdAt,
    super.updatedAt,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) =>
      _$BookModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookModelToJson(this);

  static TypeBook? _parseType(dynamic type) {
    if (type == null) return null;
    final typeStr = type.toString();
    try {
      return TypeBook.values.firstWhere(
        (e) => e.name.toLowerCase() == typeStr.toLowerCase(),
      );
    } catch (_) {
      return TypeBook.other;
    }
  }
}

@JsonSerializable()
class BookListModel extends BookList {
  @override
  @JsonKey(defaultValue: [])
  final List<BookModel> data;

  const BookListModel({
    required this.data,
    @JsonKey(readValue: _readTotal) required super.total,
    @JsonKey(readValue: _readPage) required super.page,
    @JsonKey(readValue: _readLimit) required super.limit,
    @JsonKey(readValue: _readTotalPages) required super.totalPages,
  }) : super(data: data);

  factory BookListModel.fromJson(Map<String, dynamic> json) =>
      _$BookListModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookListModelToJson(this);

  static Object? _readTotal(Map json, String key) =>
      json['metadata']?['total'] ?? 0;
  static Object? _readPage(Map json, String key) =>
      json['metadata']?['page'] ?? 1;
  static Object? _readLimit(Map json, String key) =>
      json['metadata']?['limit'] ?? 20;
  static Object? _readTotalPages(Map json, String key) =>
      json['metadata']?['lastPage'] ?? 0;
}
