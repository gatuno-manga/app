import 'package:equatable/equatable.dart';

class ProgressId extends Equatable {
  final String value;

  const ProgressId(this.value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value.toString();

  factory ProgressId.fromJson(String json) => ProgressId(json);
  String toJson() => value;
}
