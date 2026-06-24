import 'package:equatable/equatable.dart';

class AuthorId extends Equatable {
  final String value;

  const AuthorId(this.value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value;

  factory AuthorId.fromJson(String json) => AuthorId(json);
  String toJson() => value;
}
