import 'package:equatable/equatable.dart';

class ChapterId extends Equatable {
  final String value;

  const ChapterId(this.value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value;

  factory ChapterId.fromJson(String json) => ChapterId(json);
  String toJson() => value;
}
