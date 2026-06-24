import 'package:equatable/equatable.dart';
import '../../../../shared/validators/email.dart';

class EmailAddress extends Equatable {
  final String value;

  EmailAddress(this.value) {
    if (value.isEmpty) throw ArgumentError('Email cannot be empty');
    if (!EmailValidatorWrapper.validate(value)) {
      throw ArgumentError('Invalid email format');
    }
  }

  @override
  List<Object?> get props => [value];
}
