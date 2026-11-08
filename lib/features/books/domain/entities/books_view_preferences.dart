import 'package:equatable/equatable.dart';

enum BooksLayoutMode { grid, list, cover }

enum BooksNavigationMode { pages, infinite }

/// How the book list is displayed; persisted per device.
class BooksViewPreferences extends Equatable {
  static const int minColumns = 1;
  static const int maxColumns = 4;

  final BooksLayoutMode layout;
  final int columns;
  final BooksNavigationMode navigation;

  const BooksViewPreferences({
    this.layout = BooksLayoutMode.grid,
    this.columns = 2,
    this.navigation = BooksNavigationMode.infinite,
  });

  BooksViewPreferences copyWith({
    BooksLayoutMode? layout,
    int? columns,
    BooksNavigationMode? navigation,
  }) {
    return BooksViewPreferences(
      layout: layout ?? this.layout,
      columns: columns ?? this.columns,
      navigation: navigation ?? this.navigation,
    );
  }

  @override
  List<Object?> get props => [layout, columns, navigation];
}
