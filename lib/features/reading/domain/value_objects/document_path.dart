import 'package:equatable/equatable.dart';

class DocumentPath extends Equatable {
  final String value;

  const DocumentPath(this.value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value.toString();

  factory DocumentPath.fromJson(String json) => DocumentPath(json);
  String toJson() => value;
}
