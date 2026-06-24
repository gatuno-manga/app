import 'package:equatable/equatable.dart';

class CommentContent extends Equatable {
  final String value;

  const CommentContent(this.value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value.toString();

  factory CommentContent.fromJson(String json) => CommentContent(json);
  String toJson() => value;
}
