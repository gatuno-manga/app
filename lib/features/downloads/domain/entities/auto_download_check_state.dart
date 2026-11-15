import 'package:equatable/equatable.dart';

import '../../../books/domain/value_objects/book_id.dart';

/// A book with automatic download on, with what the new-chapter check knows
/// about it.
class AutoDownloadCheckState extends Equatable {
  final BookId bookId;

  /// When automatic download was last turned on.
  final DateTime since;

  /// Whether the chapters that existed when it was turned on are recorded.
  /// Until they are, the next check records them instead of queueing.
  final bool hasBaseline;

  /// When the check last read the book; `null` if never.
  final DateTime? checkedAt;

  const AutoDownloadCheckState({
    required this.bookId,
    required this.since,
    required this.hasBaseline,
    this.checkedAt,
  });

  @override
  List<Object?> get props => [bookId, since, hasBaseline, checkedAt];
}
