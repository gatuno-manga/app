import 'package:equatable/equatable.dart';

class UserDateTime extends Equatable {
  final DateTime value;

  const UserDateTime(this.value);

  static final guest = UserDateTime(DateTime.fromMillisecondsSinceEpoch(0));

  bool get isGuest => this == guest;

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value.toIso8601String();

  factory UserDateTime.fromJson(String? json) => UserDateTime(
    json != null
        ? DateTime.parse(json)
        : DateTime.fromMillisecondsSinceEpoch(0),
  );

  String toJson() => value.toIso8601String();
}
