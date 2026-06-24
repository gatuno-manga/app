import 'package:equatable/equatable.dart';

class RequestUrl extends Equatable {
  final String value;
  const RequestUrl._(this.value);
  
  factory RequestUrl(String input) {
    if (input.trim().isEmpty) throw ArgumentError('URL cannot be empty');
    return RequestUrl._(input.trim());
  }
  
  @override
  List<Object?> get props => [value];
  
  factory RequestUrl.fromJson(String json) => RequestUrl(json);
  String toJson() => value;
  
  @override
  String toString() => value;
}
