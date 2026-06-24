import '../value_objects/author_id.dart';
import '../value_objects/author_name.dart';

class Author {
  final AuthorId id;
  final AuthorName name;

  const Author({required this.id, required this.name});
}
