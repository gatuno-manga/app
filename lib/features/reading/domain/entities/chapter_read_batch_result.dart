import 'package:equatable/equatable.dart';

import '../../../books/domain/value_objects/chapter_id.dart';

/// Result for one chapter from `POST /chapters/batch/read`.
class ChapterReadBatchResult extends Equatable {
  final ChapterId chapterId;
  final bool success;
  final String? error;

  const ChapterReadBatchResult({
    required this.chapterId,
    required this.success,
    this.error,
  });

  /// Whether this entry should be removed from the offline queue: either it
  /// succeeded or the server no longer has the chapter.
  bool get shouldClearFromQueue =>
      success || (error?.toLowerCase().contains('not found') ?? false);

  @override
  List<Object?> get props => [chapterId, success, error];
}
