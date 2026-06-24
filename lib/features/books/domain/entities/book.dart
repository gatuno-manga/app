import '../../../../shared/domain/entities/image_metadata.dart';
import '../../../../shared/domain/value_objects/positive_int.dart';
import '../value_objects/book_cover.dart';
import '../value_objects/book_description.dart';
import '../value_objects/book_id.dart';
import '../value_objects/book_title.dart';
import 'author.dart';
import 'book_type.dart';
import 'tag.dart';

class Book {
  final BookId id;
  final BookTitle title;
  final List<Author> authors;
  final List<Tag> tags;
  final BookDescription? description;
  final BookCover? cover;
  final ImageMetadata? metadata;
  final TypeBook? type;
  final PositiveInt? publication;
  final PositiveInt? totalChapters;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Book({
    required this.id,
    required this.title,
    this.authors = const [],
    this.tags = const [],
    this.description,
    this.cover,
    this.metadata,
    this.type,
    this.publication,
    this.totalChapters,
    this.createdAt,
    this.updatedAt,
  });
}

class BookList {
  final List<Book> data;
  final PositiveInt total;
  final PositiveInt page;
  final PositiveInt limit;
  final PositiveInt totalPages;

  const BookList({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });
}
