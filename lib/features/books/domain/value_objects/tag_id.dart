import 'package:equatable/equatable.dart';

class TagId extends Equatable {
  final String value;

  const TagId(this.value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value;

  factory TagId.fromJson(String json) => TagId(json);
  String toJson() => value;
}
