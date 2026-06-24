import 'package:equatable/equatable.dart';

class PositiveInt extends Equatable {
  final int value;

  const PositiveInt(this.value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value.toString();

  factory PositiveInt.fromJson(int json) => PositiveInt(json);
  int toJson() => value;
}
