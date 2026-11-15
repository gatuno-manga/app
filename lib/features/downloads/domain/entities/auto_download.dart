import 'package:equatable/equatable.dart';

import '../../../books/domain/value_objects/book_id.dart';

/// Automatic download of new chapters, turned on for one book.
class AutoDownload extends Equatable {
  final BookId bookId;

  /// When it was last turned on. Chapters that are new after it are the
  /// ones to download.
  final DateTime since;

  const AutoDownload({required this.bookId, required this.since});

  @override
  List<Object?> get props => [bookId, since];
}
