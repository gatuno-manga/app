import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

class Timestamp extends Equatable {
  final DateTime value;

  const Timestamp(this.value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value.toIso8601String();

  factory Timestamp.fromMillisecondsSinceEpoch(int ms) {
    return Timestamp(DateTime.fromMillisecondsSinceEpoch(ms));
  }

  factory Timestamp.now() {
    return Timestamp(DateTime.now());
  }

  factory Timestamp.fromJson(dynamic json) {
    if (json is int) {
      return Timestamp.fromMillisecondsSinceEpoch(json);
    } else if (json is String) {
      return Timestamp(DateTime.parse(json));
    }
    throw ArgumentError('Invalid timestamp format: $json');
  }

  dynamic toJson() => value.toIso8601String();
}

class TimestampAsIntConverter implements JsonConverter<Timestamp, int> {
  const TimestampAsIntConverter();

  @override
  Timestamp fromJson(int json) => Timestamp.fromMillisecondsSinceEpoch(json);

  @override
  int toJson(Timestamp object) => object.value.millisecondsSinceEpoch;
}
