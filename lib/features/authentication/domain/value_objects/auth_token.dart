import 'package:equatable/equatable.dart';

class AuthToken extends Equatable {
  final String value;

  AuthToken(this.value) {
    if (value.isEmpty) throw ArgumentError('AuthToken cannot be empty');
  }

  @override
  List<Object?> get props => [value];
}
