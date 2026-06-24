import '../value_objects/tag_id.dart';
import '../value_objects/tag_name.dart';

class Tag {
  final TagId id;
  final TagName name;

  const Tag({required this.id, required this.name});
}
