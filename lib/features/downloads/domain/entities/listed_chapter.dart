import 'package:equatable/equatable.dart';

import '../../../books/domain/value_objects/chapter_id.dart';

/// A chapter as the new-chapter check sees it on the server.
class ListedChapter extends Equatable {
  final ChapterId id;

  /// The server has its content, so it can be downloaded. Chapters still
  /// being scraped, or whose scraping failed, cannot yet.
  final bool ready;

  const ListedChapter({required this.id, required this.ready});

  @override
  List<Object?> get props => [id, ready];
}
