import 'package:equatable/equatable.dart';

class AuthorName extends Equatable {
  final String value;

  const AuthorName(this.value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value;

  factory AuthorName.fromJson(String json) => AuthorName(json);
  String toJson() => value;
}
