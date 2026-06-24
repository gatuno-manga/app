import 'package:equatable/equatable.dart';

class Password extends Equatable {
  final String value;

  Password(this.value) {
    if (value.isEmpty) throw ArgumentError('Password cannot be empty');
  }

  @override
  List<Object?> get props => [value];
}
