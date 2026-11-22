import 'package:equatable/equatable.dart';

class RequestRejectionMessage extends Equatable {
  final String? value;
  const RequestRejectionMessage(this.value);
  
  @override
  List<Object?> get props => [value];
  
  factory RequestRejectionMessage.fromJson(String? json) => RequestRejectionMessage(json);
  String? toJson() => value;
  
  @override
  String toString() => value ?? '';
}
