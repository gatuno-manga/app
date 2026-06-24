import 'package:equatable/equatable.dart';

class ReadingPageId extends Equatable {
  final String value;

  const ReadingPageId(this.value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value.toString();

  factory ReadingPageId.fromJson(String json) => ReadingPageId(json);
  String toJson() => value;
}
