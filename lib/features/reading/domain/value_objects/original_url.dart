import 'package:equatable/equatable.dart';

class OriginalUrl extends Equatable {
  final String value;

  const OriginalUrl(this.value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value.toString();

  factory OriginalUrl.fromJson(String json) => OriginalUrl(json);
  String toJson() => value;
}
