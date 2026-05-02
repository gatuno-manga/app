import 'package:equatable/equatable.dart';

class UserId extends Equatable {
  final String value;

  const UserId(this.value);

  static const guest = UserId('guest');

  bool get isGuest => this == guest;

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value;

  factory UserId.fromJson(String json) => UserId(json);

  String toJson() => value;
}
