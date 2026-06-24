import 'package:equatable/equatable.dart';

class ChapterIndex extends Equatable {
  final double value;

  const ChapterIndex(this.value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value.toString();

  factory ChapterIndex.fromJson(double json) => ChapterIndex(json);
  double toJson() => value;
}
