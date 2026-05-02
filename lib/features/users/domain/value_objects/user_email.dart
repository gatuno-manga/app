import 'package:equatable/equatable.dart';

class UserEmail extends Equatable {
  final String value;

  const UserEmail(this.value);

  static const guest = UserEmail('');

  bool get isGuest => value.isEmpty;

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value;

  factory UserEmail.fromJson(String? json) => UserEmail(json ?? '');

  String toJson() => value;
}
