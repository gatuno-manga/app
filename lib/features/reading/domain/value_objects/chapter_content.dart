import 'package:equatable/equatable.dart';

class ChapterContent extends Equatable {
  final String value;

  const ChapterContent(this.value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value.toString();

  factory ChapterContent.fromJson(String json) => ChapterContent(json);
  String toJson() => value;
}
