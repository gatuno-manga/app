import 'package:json_annotation/json_annotation.dart';
import '../../../../shared/data/models/image_metadata_model.dart';
import '../../../../shared/domain/value_objects/positive_int.dart';
import '../../domain/entities/author.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/book_type.dart';
import '../../domain/entities/tag.dart';
import '../../domain/value_objects/book_cover.dart';
import '../../domain/value_objects/book_description.dart';
import '../../domain/value_objects/book_id.dart';
import '../../domain/value_objects/book_title.dart';
import 'author_model.dart';
import 'tag_model.dart';

part 'book_model.g.dart';

class AuthorListConverter
    implements JsonConverter<List<Author>, List<dynamic>?> {
  const AuthorListConverter();
  @override
  List<Author> fromJson(List<dynamic>? json) {
    return (json ?? [])
        .map((e) => AuthorModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  List<dynamic> toJson(List<Author> object) {
    return object.map((e) => (e as AuthorModel).toJson()).toList();
  }
}

class TagListConverter implements JsonConverter<List<Tag>, List<dynamic>?> {
  const TagListConverter();
  @override
  List<Tag> fromJson(List<dynamic>? json) {
    return (json ?? [])
        .map((e) => TagModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  List<dynamic> toJson(List<Tag> object) {
    return object.map((e) => (e as TagModel).toJson()).toList();
  }
}

class TypeBookConverter implements JsonConverter<TypeBook?, dynamic> {
  const TypeBookConverter();
  @override
  TypeBook? fromJson(dynamic json) {
    if (json == null) return null;
    final typeStr = json.toString();
    try {
      return TypeBook.values.firstWhere(
        (e) => e.name.toLowerCase() == typeStr.toLowerCase(),
      );
    } catch (_) {
      return TypeBook.other;
    }
  }

  @override
  dynamic toJson(TypeBook? object) => object?.name;
}

@JsonSerializable(
  explicitToJson: true,
  converters: [AuthorListConverter(), TagListConverter(), TypeBookConverter()],
)
class BookModel extends Book {
  @JsonKey(name: 'coverMetadata')
  final ImageMetadataModel? imageMetadata;

  const BookModel({
    required super.id,
    required super.title,
    super.authors = const [],
    super.tags = const [],
    super.description,
    super.cover,
    this.imageMetadata,
    super.type,
    super.publication,
    super.totalChapters,
    super.createdAt,
    super.updatedAt,
  }) : super(metadata: imageMetadata);

  factory BookModel.fromJson(Map<String, dynamic> json) =>
      _$BookModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookModelToJson(this);
}

class BookListConverter implements JsonConverter<List<Book>, List<dynamic>?> {
  const BookListConverter();
  @override
  List<Book> fromJson(List<dynamic>? json) {
    return (json ?? [])
        .map((e) => BookModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  List<dynamic> toJson(List<Book> object) {
    return object.map((e) => (e as BookModel).toJson()).toList();
  }
}

@JsonSerializable(explicitToJson: true, converters: [BookListConverter()])
class BookListModel extends BookList {
  const BookListModel({
    required super.data,
    @JsonKey(readValue: _readTotal) required super.total,
    @JsonKey(readValue: _readPage) required super.page,
    @JsonKey(readValue: _readLimit) required super.limit,
    @JsonKey(readValue: _readTotalPages) required super.totalPages,
  });

  factory BookListModel.fromJson(Map<String, dynamic> json) =>
      _$BookListModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookListModelToJson(this);

  static Object? _readTotal(Map<dynamic, dynamic> json, String key) =>
      json['metadata']?['total'] ?? 0;
  static Object? _readPage(Map<dynamic, dynamic> json, String key) =>
      json['metadata']?['page'] ?? 1;
  static Object? _readLimit(Map<dynamic, dynamic> json, String key) =>
      json['metadata']?['limit'] ?? 20;
  static Object? _readTotalPages(Map<dynamic, dynamic> json, String key) =>
      json['metadata']?['lastPage'] ?? 0;
}
