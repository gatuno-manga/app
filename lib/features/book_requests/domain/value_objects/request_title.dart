import 'package:equatable/equatable.dart';

class RequestTitle extends Equatable {
  final String value;
  const RequestTitle._(this.value);
  
  factory RequestTitle(String input) {
    if (input.trim().isEmpty) throw ArgumentError('Title cannot be empty');
    return RequestTitle._(input.trim());
  }
  
  @override
  List<Object?> get props => [value];
  
  factory RequestTitle.fromJson(String json) => RequestTitle(json);
  String toJson() => value;
  
  @override
  String toString() => value;
}
