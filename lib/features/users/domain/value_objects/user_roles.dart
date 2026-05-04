import 'package:equatable/equatable.dart';

class UserRoles extends Equatable {
  final List<String> values;

  const UserRoles(this.values);

  static const guest = UserRoles([]);

  bool get isGuest => values.isEmpty;

  bool contains(String role) => values.contains(role);

  @override
  List<Object?> get props => [values];

  factory UserRoles.fromJson(List<dynamic>? json) =>
      UserRoles(json?.cast<String>() ?? []);

  List<String> toJson() => values;
}
