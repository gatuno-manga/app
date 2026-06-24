import 'package:equatable/equatable.dart';

class BookCover extends Equatable {
  final String value;

  const BookCover(this.value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value;

  factory BookCover.fromJson(String json) => BookCover(json);
  String toJson() => value;
}
