enum ScrapingStatus { process, ready, error }

class Chapter {
  final String id;
  final String? title;
  final double index;
  final ScrapingStatus? scrapingStatus;
  final bool read;
  final bool completed;
  final int lastPage;

  const Chapter({
    required this.id,
    this.title,
    required this.index,
    this.scrapingStatus,
    this.read = false,
    this.completed = false,
    this.lastPage = 0,
  });

  Chapter copyWith({
    String? id,
    String? title,
    double? index,
    ScrapingStatus? scrapingStatus,
    bool? read,
    bool? completed,
    int? lastPage,
  }) {
    return Chapter(
      id: id ?? this.id,
      title: title ?? this.title,
      index: index ?? this.index,
      scrapingStatus: scrapingStatus ?? this.scrapingStatus,
      read: read ?? this.read,
      completed: completed ?? this.completed,
      lastPage: lastPage ?? this.lastPage,
    );
  }
}

class ChapterList {
  final List<Chapter> data;
  final String? nextCursor;
  final bool hasNextPage;

  const ChapterList({
    required this.data,
    this.nextCursor,
    required this.hasNextPage,
  });

  ChapterList copyWith({
    List<Chapter>? data,
    String? nextCursor,
    bool? hasNextPage,
  }) {
    return ChapterList(
      data: data ?? this.data,
      nextCursor: nextCursor ?? this.nextCursor,
      hasNextPage: hasNextPage ?? this.hasNextPage,
    );
  }
}
