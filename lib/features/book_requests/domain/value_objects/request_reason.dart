import 'package:equatable/equatable.dart';

class RequestReason extends Equatable {
  final String? value;
  const RequestReason(this.value);
  
  @override
  List<Object?> get props => [value];
  
  factory RequestReason.fromJson(String? json) => RequestReason(json);
  String? toJson() => value;
  
  @override
  String toString() => value ?? '';
}
