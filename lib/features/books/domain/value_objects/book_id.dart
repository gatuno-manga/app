import 'package:equatable/equatable.dart';

class BookId extends Equatable {
  final String value;

  const BookId(this.value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value;

  factory BookId.fromJson(String json) => BookId(json);
  String toJson() => value;
}
