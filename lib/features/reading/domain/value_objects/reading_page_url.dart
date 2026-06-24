import 'package:equatable/equatable.dart';

class ReadingPageUrl extends Equatable {
  final String value;

  const ReadingPageUrl(this.value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value.toString();

  factory ReadingPageUrl.fromJson(String json) => ReadingPageUrl(json);
  String toJson() => value;
}
