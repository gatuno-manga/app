// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_database.dart';

// ignore_for_file: type=lint
class $ReadingProgressTable extends ReadingProgress
    with TableInfo<$ReadingProgressTable, ReadingProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterIdMeta = const VerificationMeta(
    'chapterId',
  );
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
    'chapter_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageIndexMeta = const VerificationMeta(
    'pageIndex',
  );
  @override
  late final GeneratedColumn<int> pageIndex = GeneratedColumn<int>(
    'page_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalPagesMeta = const VerificationMeta(
    'totalPages',
  );
  @override
  late final GeneratedColumn<int> totalPages = GeneratedColumn<int>(
    'total_pages',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    chapterId,
    bookId,
    pageIndex,
    timestamp,
    totalPages,
    completed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingProgressData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('page_index')) {
      context.handle(
        _pageIndexMeta,
        pageIndex.isAcceptableOrUnknown(data['page_index']!, _pageIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_pageIndexMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('total_pages')) {
      context.handle(
        _totalPagesMeta,
        totalPages.isAcceptableOrUnknown(data['total_pages']!, _totalPagesMeta),
      );
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, chapterId};
  @override
  ReadingProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingProgressData(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      pageIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_index'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      totalPages: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_pages'],
      ),
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
    );
  }

  @override
  $ReadingProgressTable createAlias(String alias) {
    return $ReadingProgressTable(attachedDatabase, alias);
  }
}

class ReadingProgressData extends DataClass
    implements Insertable<ReadingProgressData> {
  final String userId;
  final String chapterId;
  final String bookId;
  final int pageIndex;
  final DateTime timestamp;
  final int? totalPages;
  final bool completed;
  const ReadingProgressData({
    required this.userId,
    required this.chapterId,
    required this.bookId,
    required this.pageIndex,
    required this.timestamp,
    this.totalPages,
    required this.completed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['chapter_id'] = Variable<String>(chapterId);
    map['book_id'] = Variable<String>(bookId);
    map['page_index'] = Variable<int>(pageIndex);
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || totalPages != null) {
      map['total_pages'] = Variable<int>(totalPages);
    }
    map['completed'] = Variable<bool>(completed);
    return map;
  }

  ReadingProgressCompanion toCompanion(bool nullToAbsent) {
    return ReadingProgressCompanion(
      userId: Value(userId),
      chapterId: Value(chapterId),
      bookId: Value(bookId),
      pageIndex: Value(pageIndex),
      timestamp: Value(timestamp),
      totalPages: totalPages == null && nullToAbsent
          ? const Value.absent()
          : Value(totalPages),
      completed: Value(completed),
    );
  }

  factory ReadingProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingProgressData(
      userId: serializer.fromJson<String>(json['userId']),
      chapterId: serializer.fromJson<String>(json['chapterId']),
      bookId: serializer.fromJson<String>(json['bookId']),
      pageIndex: serializer.fromJson<int>(json['pageIndex']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      totalPages: serializer.fromJson<int?>(json['totalPages']),
      completed: serializer.fromJson<bool>(json['completed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'chapterId': serializer.toJson<String>(chapterId),
      'bookId': serializer.toJson<String>(bookId),
      'pageIndex': serializer.toJson<int>(pageIndex),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'totalPages': serializer.toJson<int?>(totalPages),
      'completed': serializer.toJson<bool>(completed),
    };
  }

  ReadingProgressData copyWith({
    String? userId,
    String? chapterId,
    String? bookId,
    int? pageIndex,
    DateTime? timestamp,
    Value<int?> totalPages = const Value.absent(),
    bool? completed,
  }) => ReadingProgressData(
    userId: userId ?? this.userId,
    chapterId: chapterId ?? this.chapterId,
    bookId: bookId ?? this.bookId,
    pageIndex: pageIndex ?? this.pageIndex,
    timestamp: timestamp ?? this.timestamp,
    totalPages: totalPages.present ? totalPages.value : this.totalPages,
    completed: completed ?? this.completed,
  );
  ReadingProgressData copyWithCompanion(ReadingProgressCompanion data) {
    return ReadingProgressData(
      userId: data.userId.present ? data.userId.value : this.userId,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      pageIndex: data.pageIndex.present ? data.pageIndex.value : this.pageIndex,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      totalPages: data.totalPages.present
          ? data.totalPages.value
          : this.totalPages,
      completed: data.completed.present ? data.completed.value : this.completed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingProgressData(')
          ..write('userId: $userId, ')
          ..write('chapterId: $chapterId, ')
          ..write('bookId: $bookId, ')
          ..write('pageIndex: $pageIndex, ')
          ..write('timestamp: $timestamp, ')
          ..write('totalPages: $totalPages, ')
          ..write('completed: $completed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    chapterId,
    bookId,
    pageIndex,
    timestamp,
    totalPages,
    completed,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingProgressData &&
          other.userId == this.userId &&
          other.chapterId == this.chapterId &&
          other.bookId == this.bookId &&
          other.pageIndex == this.pageIndex &&
          other.timestamp == this.timestamp &&
          other.totalPages == this.totalPages &&
          other.completed == this.completed);
}

class ReadingProgressCompanion extends UpdateCompanion<ReadingProgressData> {
  final Value<String> userId;
  final Value<String> chapterId;
  final Value<String> bookId;
  final Value<int> pageIndex;
  final Value<DateTime> timestamp;
  final Value<int?> totalPages;
  final Value<bool> completed;
  final Value<int> rowid;
  const ReadingProgressCompanion({
    this.userId = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.bookId = const Value.absent(),
    this.pageIndex = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.totalPages = const Value.absent(),
    this.completed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReadingProgressCompanion.insert({
    required String userId,
    required String chapterId,
    required String bookId,
    required int pageIndex,
    required DateTime timestamp,
    this.totalPages = const Value.absent(),
    this.completed = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       chapterId = Value(chapterId),
       bookId = Value(bookId),
       pageIndex = Value(pageIndex),
       timestamp = Value(timestamp);
  static Insertable<ReadingProgressData> custom({
    Expression<String>? userId,
    Expression<String>? chapterId,
    Expression<String>? bookId,
    Expression<int>? pageIndex,
    Expression<DateTime>? timestamp,
    Expression<int>? totalPages,
    Expression<bool>? completed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (chapterId != null) 'chapter_id': chapterId,
      if (bookId != null) 'book_id': bookId,
      if (pageIndex != null) 'page_index': pageIndex,
      if (timestamp != null) 'timestamp': timestamp,
      if (totalPages != null) 'total_pages': totalPages,
      if (completed != null) 'completed': completed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReadingProgressCompanion copyWith({
    Value<String>? userId,
    Value<String>? chapterId,
    Value<String>? bookId,
    Value<int>? pageIndex,
    Value<DateTime>? timestamp,
    Value<int?>? totalPages,
    Value<bool>? completed,
    Value<int>? rowid,
  }) {
    return ReadingProgressCompanion(
      userId: userId ?? this.userId,
      chapterId: chapterId ?? this.chapterId,
      bookId: bookId ?? this.bookId,
      pageIndex: pageIndex ?? this.pageIndex,
      timestamp: timestamp ?? this.timestamp,
      totalPages: totalPages ?? this.totalPages,
      completed: completed ?? this.completed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (pageIndex.present) {
      map['page_index'] = Variable<int>(pageIndex.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (totalPages.present) {
      map['total_pages'] = Variable<int>(totalPages.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingProgressCompanion(')
          ..write('userId: $userId, ')
          ..write('chapterId: $chapterId, ')
          ..write('bookId: $bookId, ')
          ..write('pageIndex: $pageIndex, ')
          ..write('timestamp: $timestamp, ')
          ..write('totalPages: $totalPages, ')
          ..write('completed: $completed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingReadMarksTable extends PendingReadMarks
    with TableInfo<$PendingReadMarksTable, PendingReadMark> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingReadMarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterIdMeta = const VerificationMeta(
    'chapterId',
  );
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
    'chapter_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [userId, chapterId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_read_marks';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingReadMark> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, chapterId};
  @override
  PendingReadMark map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingReadMark(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PendingReadMarksTable createAlias(String alias) {
    return $PendingReadMarksTable(attachedDatabase, alias);
  }
}

class PendingReadMark extends DataClass implements Insertable<PendingReadMark> {
  final String userId;
  final String chapterId;
  final DateTime createdAt;
  const PendingReadMark({
    required this.userId,
    required this.chapterId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['chapter_id'] = Variable<String>(chapterId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PendingReadMarksCompanion toCompanion(bool nullToAbsent) {
    return PendingReadMarksCompanion(
      userId: Value(userId),
      chapterId: Value(chapterId),
      createdAt: Value(createdAt),
    );
  }

  factory PendingReadMark.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingReadMark(
      userId: serializer.fromJson<String>(json['userId']),
      chapterId: serializer.fromJson<String>(json['chapterId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'chapterId': serializer.toJson<String>(chapterId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PendingReadMark copyWith({
    String? userId,
    String? chapterId,
    DateTime? createdAt,
  }) => PendingReadMark(
    userId: userId ?? this.userId,
    chapterId: chapterId ?? this.chapterId,
    createdAt: createdAt ?? this.createdAt,
  );
  PendingReadMark copyWithCompanion(PendingReadMarksCompanion data) {
    return PendingReadMark(
      userId: data.userId.present ? data.userId.value : this.userId,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingReadMark(')
          ..write('userId: $userId, ')
          ..write('chapterId: $chapterId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userId, chapterId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingReadMark &&
          other.userId == this.userId &&
          other.chapterId == this.chapterId &&
          other.createdAt == this.createdAt);
}

class PendingReadMarksCompanion extends UpdateCompanion<PendingReadMark> {
  final Value<String> userId;
  final Value<String> chapterId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PendingReadMarksCompanion({
    this.userId = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PendingReadMarksCompanion.insert({
    required String userId,
    required String chapterId,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       chapterId = Value(chapterId),
       createdAt = Value(createdAt);
  static Insertable<PendingReadMark> custom({
    Expression<String>? userId,
    Expression<String>? chapterId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (chapterId != null) 'chapter_id': chapterId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PendingReadMarksCompanion copyWith({
    Value<String>? userId,
    Value<String>? chapterId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PendingReadMarksCompanion(
      userId: userId ?? this.userId,
      chapterId: chapterId ?? this.chapterId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingReadMarksCompanion(')
          ..write('userId: $userId, ')
          ..write('chapterId: $chapterId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$ReadingDatabase extends GeneratedDatabase {
  _$ReadingDatabase(QueryExecutor e) : super(e);
  $ReadingDatabaseManager get managers => $ReadingDatabaseManager(this);
  late final $ReadingProgressTable readingProgress = $ReadingProgressTable(
    this,
  );
  late final $PendingReadMarksTable pendingReadMarks = $PendingReadMarksTable(
    this,
  );
  late final Index idxReadingProgressRecent = Index(
    'idx_reading_progress_recent',
    'CREATE INDEX idx_reading_progress_recent ON reading_progress (user_id, timestamp)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    readingProgress,
    pendingReadMarks,
    idxReadingProgressRecent,
  ];
}

typedef $$ReadingProgressTableCreateCompanionBuilder =
    ReadingProgressCompanion Function({
      required String userId,
      required String chapterId,
      required String bookId,
      required int pageIndex,
      required DateTime timestamp,
      Value<int?> totalPages,
      Value<bool> completed,
      Value<int> rowid,
    });
typedef $$ReadingProgressTableUpdateCompanionBuilder =
    ReadingProgressCompanion Function({
      Value<String> userId,
      Value<String> chapterId,
      Value<String> bookId,
      Value<int> pageIndex,
      Value<DateTime> timestamp,
      Value<int?> totalPages,
      Value<bool> completed,
      Value<int> rowid,
    });

class $$ReadingProgressTableFilterComposer
    extends Composer<_$ReadingDatabase, $ReadingProgressTable> {
  $$ReadingProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageIndex => $composableBuilder(
    column: $table.pageIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalPages => $composableBuilder(
    column: $table.totalPages,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReadingProgressTableOrderingComposer
    extends Composer<_$ReadingDatabase, $ReadingProgressTable> {
  $$ReadingProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageIndex => $composableBuilder(
    column: $table.pageIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalPages => $composableBuilder(
    column: $table.totalPages,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReadingProgressTableAnnotationComposer
    extends Composer<_$ReadingDatabase, $ReadingProgressTable> {
  $$ReadingProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get chapterId =>
      $composableBuilder(column: $table.chapterId, builder: (column) => column);

  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<int> get pageIndex =>
      $composableBuilder(column: $table.pageIndex, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<int> get totalPages => $composableBuilder(
    column: $table.totalPages,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);
}

class $$ReadingProgressTableTableManager
    extends
        RootTableManager<
          _$ReadingDatabase,
          $ReadingProgressTable,
          ReadingProgressData,
          $$ReadingProgressTableFilterComposer,
          $$ReadingProgressTableOrderingComposer,
          $$ReadingProgressTableAnnotationComposer,
          $$ReadingProgressTableCreateCompanionBuilder,
          $$ReadingProgressTableUpdateCompanionBuilder,
          (
            ReadingProgressData,
            BaseReferences<
              _$ReadingDatabase,
              $ReadingProgressTable,
              ReadingProgressData
            >,
          ),
          ReadingProgressData,
          PrefetchHooks Function()
        > {
  $$ReadingProgressTableTableManager(
    _$ReadingDatabase db,
    $ReadingProgressTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> chapterId = const Value.absent(),
                Value<String> bookId = const Value.absent(),
                Value<int> pageIndex = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<int?> totalPages = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReadingProgressCompanion(
                userId: userId,
                chapterId: chapterId,
                bookId: bookId,
                pageIndex: pageIndex,
                timestamp: timestamp,
                totalPages: totalPages,
                completed: completed,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String chapterId,
                required String bookId,
                required int pageIndex,
                required DateTime timestamp,
                Value<int?> totalPages = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReadingProgressCompanion.insert(
                userId: userId,
                chapterId: chapterId,
                bookId: bookId,
                pageIndex: pageIndex,
                timestamp: timestamp,
                totalPages: totalPages,
                completed: completed,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReadingProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$ReadingDatabase,
      $ReadingProgressTable,
      ReadingProgressData,
      $$ReadingProgressTableFilterComposer,
      $$ReadingProgressTableOrderingComposer,
      $$ReadingProgressTableAnnotationComposer,
      $$ReadingProgressTableCreateCompanionBuilder,
      $$ReadingProgressTableUpdateCompanionBuilder,
      (
        ReadingProgressData,
        BaseReferences<
          _$ReadingDatabase,
          $ReadingProgressTable,
          ReadingProgressData
        >,
      ),
      ReadingProgressData,
      PrefetchHooks Function()
    >;
typedef $$PendingReadMarksTableCreateCompanionBuilder =
    PendingReadMarksCompanion Function({
      required String userId,
      required String chapterId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$PendingReadMarksTableUpdateCompanionBuilder =
    PendingReadMarksCompanion Function({
      Value<String> userId,
      Value<String> chapterId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$PendingReadMarksTableFilterComposer
    extends Composer<_$ReadingDatabase, $PendingReadMarksTable> {
  $$PendingReadMarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingReadMarksTableOrderingComposer
    extends Composer<_$ReadingDatabase, $PendingReadMarksTable> {
  $$PendingReadMarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingReadMarksTableAnnotationComposer
    extends Composer<_$ReadingDatabase, $PendingReadMarksTable> {
  $$PendingReadMarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get chapterId =>
      $composableBuilder(column: $table.chapterId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PendingReadMarksTableTableManager
    extends
        RootTableManager<
          _$ReadingDatabase,
          $PendingReadMarksTable,
          PendingReadMark,
          $$PendingReadMarksTableFilterComposer,
          $$PendingReadMarksTableOrderingComposer,
          $$PendingReadMarksTableAnnotationComposer,
          $$PendingReadMarksTableCreateCompanionBuilder,
          $$PendingReadMarksTableUpdateCompanionBuilder,
          (
            PendingReadMark,
            BaseReferences<
              _$ReadingDatabase,
              $PendingReadMarksTable,
              PendingReadMark
            >,
          ),
          PendingReadMark,
          PrefetchHooks Function()
        > {
  $$PendingReadMarksTableTableManager(
    _$ReadingDatabase db,
    $PendingReadMarksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingReadMarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingReadMarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingReadMarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> chapterId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingReadMarksCompanion(
                userId: userId,
                chapterId: chapterId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String chapterId,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PendingReadMarksCompanion.insert(
                userId: userId,
                chapterId: chapterId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingReadMarksTableProcessedTableManager =
    ProcessedTableManager<
      _$ReadingDatabase,
      $PendingReadMarksTable,
      PendingReadMark,
      $$PendingReadMarksTableFilterComposer,
      $$PendingReadMarksTableOrderingComposer,
      $$PendingReadMarksTableAnnotationComposer,
      $$PendingReadMarksTableCreateCompanionBuilder,
      $$PendingReadMarksTableUpdateCompanionBuilder,
      (
        PendingReadMark,
        BaseReferences<
          _$ReadingDatabase,
          $PendingReadMarksTable,
          PendingReadMark
        >,
      ),
      PendingReadMark,
      PrefetchHooks Function()
    >;

class $ReadingDatabaseManager {
  final _$ReadingDatabase _db;
  $ReadingDatabaseManager(this._db);
  $$ReadingProgressTableTableManager get readingProgress =>
      $$ReadingProgressTableTableManager(_db, _db.readingProgress);
  $$PendingReadMarksTableTableManager get pendingReadMarks =>
      $$PendingReadMarksTableTableManager(_db, _db.pendingReadMarks);
}
