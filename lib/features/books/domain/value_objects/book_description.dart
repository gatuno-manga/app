import 'package:equatable/equatable.dart';

class BookDescription extends Equatable {
  final String value;

  const BookDescription(this.value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value;

  factory BookDescription.fromJson(String json) => BookDescription(json);
  String toJson() => value;
}
