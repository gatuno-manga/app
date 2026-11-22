import 'package:equatable/equatable.dart';

class RequestId extends Equatable {
  final String value;
  const RequestId._(this.value);
  
  factory RequestId(String input) {
    if (input.trim().isEmpty) throw ArgumentError('Request ID cannot be empty');
    return RequestId._(input.trim());
  }
  
  @override
  List<Object?> get props => [value];
  
  factory RequestId.fromJson(String json) => RequestId(json);
  String toJson() => value;
  
  @override
  String toString() => value;
}
