import 'package:equatable/equatable.dart';

class ChapterTitle extends Equatable {
  final String value;

  const ChapterTitle(this.value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value;

  factory ChapterTitle.fromJson(String json) => ChapterTitle(json);
  String toJson() => value;
}
