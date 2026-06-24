import 'package:equatable/equatable.dart';

class BookTitle extends Equatable {
  final String value;

  const BookTitle(this.value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value;

  factory BookTitle.fromJson(String json) => BookTitle(json);
  String toJson() => value;
}
