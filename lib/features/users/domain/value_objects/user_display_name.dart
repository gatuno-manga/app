import 'package:equatable/equatable.dart';

class UserDisplayName extends Equatable {
  final String? value;

  const UserDisplayName(this.value);

  static const guest = UserDisplayName(null);

  bool get isGuest => value == null;

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value ?? '';

  factory UserDisplayName.fromJson(String? json) => UserDisplayName(json);

  String? toJson() => value;
}
