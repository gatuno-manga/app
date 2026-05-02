import 'package:equatable/equatable.dart';

class UserName extends Equatable {
  final String value;

  const UserName(this.value);

  static const guest = UserName('guest');

  bool get isGuest => this == guest;

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value;

  factory UserName.fromJson(String? json) => UserName(json ?? 'guest');

  String toJson() => value;
}
