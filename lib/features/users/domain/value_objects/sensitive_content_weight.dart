import 'package:equatable/equatable.dart';

class SensitiveContentWeight extends Equatable {
  final int value;

  const SensitiveContentWeight(this.value);

  static const guest = SensitiveContentWeight(0);

  bool get isGuest => value == 0;

  @override
  List<Object?> get props => [value];

  factory SensitiveContentWeight.fromJson(int? json) =>
      SensitiveContentWeight(json ?? 0);

  int toJson() => value;
}
