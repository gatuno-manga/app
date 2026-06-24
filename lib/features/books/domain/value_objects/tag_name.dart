import 'package:equatable/equatable.dart';

class TagName extends Equatable {
  final String value;

  const TagName(this.value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value;

  factory TagName.fromJson(String json) => TagName(json);
  String toJson() => value;
}
