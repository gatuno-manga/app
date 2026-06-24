import 'package:equatable/equatable.dart';

class CommentId extends Equatable {
  final String value;

  const CommentId(this.value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value.toString();

  factory CommentId.fromJson(String json) => CommentId(json);
  String toJson() => value;
}
