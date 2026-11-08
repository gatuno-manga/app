import 'package:equatable/equatable.dart';

/// A selectable id/label pair for tag and author filters.
class FilterOption extends Equatable {
  final String id;
  final String label;

  const FilterOption({required this.id, required this.label});

  @override
  List<Object?> get props => [id, label];
}
