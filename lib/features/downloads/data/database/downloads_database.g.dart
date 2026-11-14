// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'downloads_database.dart';

// ignore_for_file: type=lint
class $DownloadBooksTable extends DownloadBooks
    with TableInfo<$DownloadBooksTable, DownloadBook> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadBooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookTypeMeta = const VerificationMeta(
    'bookType',
  );
  @override
  late final GeneratedColumn<String> bookType = GeneratedColumn<String>(
    'book_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enqueuedAtMeta = const VerificationMeta(
    'enqueuedAt',
  );
  @override
  late final GeneratedColumn<DateTime> enqueuedAt = GeneratedColumn<DateTime>(
    'enqueued_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [bookId, bookType, enqueuedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'download_books';
  @override
  VerificationContext validateIntegrity(
    Insertable<DownloadBook> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('book_type')) {
      context.handle(
        _bookTypeMeta,
        bookType.isAcceptableOrUnknown(data['book_type']!, _bookTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_bookTypeMeta);
    }
    if (data.containsKey('enqueued_at')) {
      context.handle(
        _enqueuedAtMeta,
        enqueuedAt.isAcceptableOrUnknown(data['enqueued_at']!, _enqueuedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_enqueuedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bookId};
  @override
  DownloadBook map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadBook(
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      bookType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_type'],
      )!,
      enqueuedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}enqueued_at'],
      )!,
    );
  }

  @override
  $DownloadBooksTable createAlias(String alias) {
    return $DownloadBooksTable(attachedDatabase, alias);
  }
}

class DownloadBook extends DataClass implements Insertable<DownloadBook> {
  final String bookId;

  /// `BookType.value`, for the network rule; `other` when unknown.
  final String bookType;
  final DateTime enqueuedAt;
  const DownloadBook({
    required this.bookId,
    required this.bookType,
    required this.enqueuedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['book_id'] = Variable<String>(bookId);
    map['book_type'] = Variable<String>(bookType);
    map['enqueued_at'] = Variable<DateTime>(enqueuedAt);
    return map;
  }

  DownloadBooksCompanion toCompanion(bool nullToAbsent) {
    return DownloadBooksCompanion(
      bookId: Value(bookId),
      bookType: Value(bookType),
      enqueuedAt: Value(enqueuedAt),
    );
  }

  factory DownloadBook.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadBook(
      bookId: serializer.fromJson<String>(json['bookId']),
      bookType: serializer.fromJson<String>(json['bookType']),
      enqueuedAt: serializer.fromJson<DateTime>(json['enqueuedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bookId': serializer.toJson<String>(bookId),
      'bookType': serializer.toJson<String>(bookType),
      'enqueuedAt': serializer.toJson<DateTime>(enqueuedAt),
    };
  }

  DownloadBook copyWith({
    String? bookId,
    String? bookType,
    DateTime? enqueuedAt,
  }) => DownloadBook(
    bookId: bookId ?? this.bookId,
    bookType: bookType ?? this.bookType,
    enqueuedAt: enqueuedAt ?? this.enqueuedAt,
  );
  DownloadBook copyWithCompanion(DownloadBooksCompanion data) {
    return DownloadBook(
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      bookType: data.bookType.present ? data.bookType.value : this.bookType,
      enqueuedAt: data.enqueuedAt.present
          ? data.enqueuedAt.value
          : this.enqueuedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadBook(')
          ..write('bookId: $bookId, ')
          ..write('bookType: $bookType, ')
          ..write('enqueuedAt: $enqueuedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(bookId, bookType, enqueuedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadBook &&
          other.bookId == this.bookId &&
          other.bookType == this.bookType &&
          other.enqueuedAt == this.enqueuedAt);
}

class DownloadBooksCompanion extends UpdateCompanion<DownloadBook> {
  final Value<String> bookId;
  final Value<String> bookType;
  final Value<DateTime> enqueuedAt;
  final Value<int> rowid;
  const DownloadBooksCompanion({
    this.bookId = const Value.absent(),
    this.bookType = const Value.absent(),
    this.enqueuedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DownloadBooksCompanion.insert({
    required String bookId,
    required String bookType,
    required DateTime enqueuedAt,
    this.rowid = const Value.absent(),
  }) : bookId = Value(bookId),
       bookType = Value(bookType),
       enqueuedAt = Value(enqueuedAt);
  static Insertable<DownloadBook> custom({
    Expression<String>? bookId,
    Expression<String>? bookType,
    Expression<DateTime>? enqueuedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bookId != null) 'book_id': bookId,
      if (bookType != null) 'book_type': bookType,
      if (enqueuedAt != null) 'enqueued_at': enqueuedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DownloadBooksCompanion copyWith({
    Value<String>? bookId,
    Value<String>? bookType,
    Value<DateTime>? enqueuedAt,
    Value<int>? rowid,
  }) {
    return DownloadBooksCompanion(
      bookId: bookId ?? this.bookId,
      bookType: bookType ?? this.bookType,
      enqueuedAt: enqueuedAt ?? this.enqueuedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (bookType.present) {
      map['book_type'] = Variable<String>(bookType.value);
    }
    if (enqueuedAt.present) {
      map['enqueued_at'] = Variable<DateTime>(enqueuedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadBooksCompanion(')
          ..write('bookId: $bookId, ')
          ..write('bookType: $bookType, ')
          ..write('enqueuedAt: $enqueuedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DownloadChaptersTable extends DownloadChapters
    with TableInfo<$DownloadChaptersTable, DownloadChapter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadChaptersTable(this.attachedDatabase, [this._alias]);
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
  @override
  late final GeneratedColumnWithTypeConverter<DownloadState, String> state =
      GeneratedColumn<String>(
        'state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DownloadState>($DownloadChaptersTable.$converterstate);
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
    'error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plannedMeta = const VerificationMeta(
    'planned',
  );
  @override
  late final GeneratedColumn<bool> planned = GeneratedColumn<bool>(
    'planned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("planned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _manifestBytesMeta = const VerificationMeta(
    'manifestBytes',
  );
  @override
  late final GeneratedColumn<int> manifestBytes = GeneratedColumn<int>(
    'manifest_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _enqueuedAtMeta = const VerificationMeta(
    'enqueuedAt',
  );
  @override
  late final GeneratedColumn<DateTime> enqueuedAt = GeneratedColumn<DateTime>(
    'enqueued_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    chapterId,
    bookId,
    state,
    error,
    planned,
    manifestBytes,
    enqueuedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'download_chapters';
  @override
  VerificationContext validateIntegrity(
    Insertable<DownloadChapter> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
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
    if (data.containsKey('error')) {
      context.handle(
        _errorMeta,
        error.isAcceptableOrUnknown(data['error']!, _errorMeta),
      );
    }
    if (data.containsKey('planned')) {
      context.handle(
        _plannedMeta,
        planned.isAcceptableOrUnknown(data['planned']!, _plannedMeta),
      );
    }
    if (data.containsKey('manifest_bytes')) {
      context.handle(
        _manifestBytesMeta,
        manifestBytes.isAcceptableOrUnknown(
          data['manifest_bytes']!,
          _manifestBytesMeta,
        ),
      );
    }
    if (data.containsKey('enqueued_at')) {
      context.handle(
        _enqueuedAtMeta,
        enqueuedAt.isAcceptableOrUnknown(data['enqueued_at']!, _enqueuedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_enqueuedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {chapterId};
  @override
  DownloadChapter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadChapter(
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      state: $DownloadChaptersTable.$converterstate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}state'],
        )!,
      ),
      error: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error'],
      ),
      planned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}planned'],
      )!,
      manifestBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}manifest_bytes'],
      )!,
      enqueuedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}enqueued_at'],
      )!,
    );
  }

  @override
  $DownloadChaptersTable createAlias(String alias) {
    return $DownloadChaptersTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<DownloadState, String, String> $converterstate =
      const EnumNameConverter<DownloadState>(DownloadState.values);
}

class DownloadChapter extends DataClass implements Insertable<DownloadChapter> {
  final String chapterId;
  final String bookId;
  final DownloadState state;

  /// A `DownloadErrors` code while failed.
  final String? error;

  /// The manifest is stored and every file has a row in [DownloadFiles].
  final bool planned;

  /// Bytes of the stored manifest.
  final int manifestBytes;

  /// FIFO order of the queue.
  final DateTime enqueuedAt;
  const DownloadChapter({
    required this.chapterId,
    required this.bookId,
    required this.state,
    this.error,
    required this.planned,
    required this.manifestBytes,
    required this.enqueuedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['chapter_id'] = Variable<String>(chapterId);
    map['book_id'] = Variable<String>(bookId);
    {
      map['state'] = Variable<String>(
        $DownloadChaptersTable.$converterstate.toSql(state),
      );
    }
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    map['planned'] = Variable<bool>(planned);
    map['manifest_bytes'] = Variable<int>(manifestBytes);
    map['enqueued_at'] = Variable<DateTime>(enqueuedAt);
    return map;
  }

  DownloadChaptersCompanion toCompanion(bool nullToAbsent) {
    return DownloadChaptersCompanion(
      chapterId: Value(chapterId),
      bookId: Value(bookId),
      state: Value(state),
      error: error == null && nullToAbsent
          ? const Value.absent()
          : Value(error),
      planned: Value(planned),
      manifestBytes: Value(manifestBytes),
      enqueuedAt: Value(enqueuedAt),
    );
  }

  factory DownloadChapter.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadChapter(
      chapterId: serializer.fromJson<String>(json['chapterId']),
      bookId: serializer.fromJson<String>(json['bookId']),
      state: $DownloadChaptersTable.$converterstate.fromJson(
        serializer.fromJson<String>(json['state']),
      ),
      error: serializer.fromJson<String?>(json['error']),
      planned: serializer.fromJson<bool>(json['planned']),
      manifestBytes: serializer.fromJson<int>(json['manifestBytes']),
      enqueuedAt: serializer.fromJson<DateTime>(json['enqueuedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'chapterId': serializer.toJson<String>(chapterId),
      'bookId': serializer.toJson<String>(bookId),
      'state': serializer.toJson<String>(
        $DownloadChaptersTable.$converterstate.toJson(state),
      ),
      'error': serializer.toJson<String?>(error),
      'planned': serializer.toJson<bool>(planned),
      'manifestBytes': serializer.toJson<int>(manifestBytes),
      'enqueuedAt': serializer.toJson<DateTime>(enqueuedAt),
    };
  }

  DownloadChapter copyWith({
    String? chapterId,
    String? bookId,
    DownloadState? state,
    Value<String?> error = const Value.absent(),
    bool? planned,
    int? manifestBytes,
    DateTime? enqueuedAt,
  }) => DownloadChapter(
    chapterId: chapterId ?? this.chapterId,
    bookId: bookId ?? this.bookId,
    state: state ?? this.state,
    error: error.present ? error.value : this.error,
    planned: planned ?? this.planned,
    manifestBytes: manifestBytes ?? this.manifestBytes,
    enqueuedAt: enqueuedAt ?? this.enqueuedAt,
  );
  DownloadChapter copyWithCompanion(DownloadChaptersCompanion data) {
    return DownloadChapter(
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      state: data.state.present ? data.state.value : this.state,
      error: data.error.present ? data.error.value : this.error,
      planned: data.planned.present ? data.planned.value : this.planned,
      manifestBytes: data.manifestBytes.present
          ? data.manifestBytes.value
          : this.manifestBytes,
      enqueuedAt: data.enqueuedAt.present
          ? data.enqueuedAt.value
          : this.enqueuedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadChapter(')
          ..write('chapterId: $chapterId, ')
          ..write('bookId: $bookId, ')
          ..write('state: $state, ')
          ..write('error: $error, ')
          ..write('planned: $planned, ')
          ..write('manifestBytes: $manifestBytes, ')
          ..write('enqueuedAt: $enqueuedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    chapterId,
    bookId,
    state,
    error,
    planned,
    manifestBytes,
    enqueuedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadChapter &&
          other.chapterId == this.chapterId &&
          other.bookId == this.bookId &&
          other.state == this.state &&
          other.error == this.error &&
          other.planned == this.planned &&
          other.manifestBytes == this.manifestBytes &&
          other.enqueuedAt == this.enqueuedAt);
}

class DownloadChaptersCompanion extends UpdateCompanion<DownloadChapter> {
  final Value<String> chapterId;
  final Value<String> bookId;
  final Value<DownloadState> state;
  final Value<String?> error;
  final Value<bool> planned;
  final Value<int> manifestBytes;
  final Value<DateTime> enqueuedAt;
  final Value<int> rowid;
  const DownloadChaptersCompanion({
    this.chapterId = const Value.absent(),
    this.bookId = const Value.absent(),
    this.state = const Value.absent(),
    this.error = const Value.absent(),
    this.planned = const Value.absent(),
    this.manifestBytes = const Value.absent(),
    this.enqueuedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DownloadChaptersCompanion.insert({
    required String chapterId,
    required String bookId,
    required DownloadState state,
    this.error = const Value.absent(),
    this.planned = const Value.absent(),
    this.manifestBytes = const Value.absent(),
    required DateTime enqueuedAt,
    this.rowid = const Value.absent(),
  }) : chapterId = Value(chapterId),
       bookId = Value(bookId),
       state = Value(state),
       enqueuedAt = Value(enqueuedAt);
  static Insertable<DownloadChapter> custom({
    Expression<String>? chapterId,
    Expression<String>? bookId,
    Expression<String>? state,
    Expression<String>? error,
    Expression<bool>? planned,
    Expression<int>? manifestBytes,
    Expression<DateTime>? enqueuedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (chapterId != null) 'chapter_id': chapterId,
      if (bookId != null) 'book_id': bookId,
      if (state != null) 'state': state,
      if (error != null) 'error': error,
      if (planned != null) 'planned': planned,
      if (manifestBytes != null) 'manifest_bytes': manifestBytes,
      if (enqueuedAt != null) 'enqueued_at': enqueuedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DownloadChaptersCompanion copyWith({
    Value<String>? chapterId,
    Value<String>? bookId,
    Value<DownloadState>? state,
    Value<String?>? error,
    Value<bool>? planned,
    Value<int>? manifestBytes,
    Value<DateTime>? enqueuedAt,
    Value<int>? rowid,
  }) {
    return DownloadChaptersCompanion(
      chapterId: chapterId ?? this.chapterId,
      bookId: bookId ?? this.bookId,
      state: state ?? this.state,
      error: error ?? this.error,
      planned: planned ?? this.planned,
      manifestBytes: manifestBytes ?? this.manifestBytes,
      enqueuedAt: enqueuedAt ?? this.enqueuedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(
        $DownloadChaptersTable.$converterstate.toSql(state.value),
      );
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (planned.present) {
      map['planned'] = Variable<bool>(planned.value);
    }
    if (manifestBytes.present) {
      map['manifest_bytes'] = Variable<int>(manifestBytes.value);
    }
    if (enqueuedAt.present) {
      map['enqueued_at'] = Variable<DateTime>(enqueuedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadChaptersCompanion(')
          ..write('chapterId: $chapterId, ')
          ..write('bookId: $bookId, ')
          ..write('state: $state, ')
          ..write('error: $error, ')
          ..write('planned: $planned, ')
          ..write('manifestBytes: $manifestBytes, ')
          ..write('enqueuedAt: $enqueuedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DownloadFilesTable extends DownloadFiles
    with TableInfo<$DownloadFilesTable, DownloadFile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadFilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _fileIdMeta = const VerificationMeta('fileId');
  @override
  late final GeneratedColumn<String> fileId = GeneratedColumn<String>(
    'file_id',
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
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relativePathMeta = const VerificationMeta(
    'relativePath',
  );
  @override
  late final GeneratedColumn<String> relativePath = GeneratedColumn<String>(
    'relative_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nativeTaskIdMeta = const VerificationMeta(
    'nativeTaskId',
  );
  @override
  late final GeneratedColumn<String> nativeTaskId = GeneratedColumn<String>(
    'native_task_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _doneMeta = const VerificationMeta('done');
  @override
  late final GeneratedColumn<bool> done = GeneratedColumn<bool>(
    'done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _bytesMeta = const VerificationMeta('bytes');
  @override
  late final GeneratedColumn<int> bytes = GeneratedColumn<int>(
    'bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    fileId,
    chapterId,
    position,
    url,
    relativePath,
    nativeTaskId,
    done,
    bytes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'download_files';
  @override
  VerificationContext validateIntegrity(
    Insertable<DownloadFile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('file_id')) {
      context.handle(
        _fileIdMeta,
        fileId.isAcceptableOrUnknown(data['file_id']!, _fileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_fileIdMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('relative_path')) {
      context.handle(
        _relativePathMeta,
        relativePath.isAcceptableOrUnknown(
          data['relative_path']!,
          _relativePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relativePathMeta);
    }
    if (data.containsKey('native_task_id')) {
      context.handle(
        _nativeTaskIdMeta,
        nativeTaskId.isAcceptableOrUnknown(
          data['native_task_id']!,
          _nativeTaskIdMeta,
        ),
      );
    }
    if (data.containsKey('done')) {
      context.handle(
        _doneMeta,
        done.isAcceptableOrUnknown(data['done']!, _doneMeta),
      );
    }
    if (data.containsKey('bytes')) {
      context.handle(
        _bytesMeta,
        bytes.isAcceptableOrUnknown(data['bytes']!, _bytesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {fileId};
  @override
  DownloadFile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadFile(
      fileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_id'],
      )!,
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      relativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relative_path'],
      )!,
      nativeTaskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}native_task_id'],
      ),
      done: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}done'],
      )!,
      bytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bytes'],
      )!,
    );
  }

  @override
  $DownloadFilesTable createAlias(String alias) {
    return $DownloadFilesTable(attachedDatabase, alias);
  }
}

class DownloadFile extends DataClass implements Insertable<DownloadFile> {
  /// `<chapterId>/<position>`.
  final String fileId;
  final String chapterId;

  /// Page order; 0 for a document.
  final int position;

  /// Absolute URL on the server.
  final String url;

  /// Path relative to the chapter's directory.
  final String relativePath;

  /// The native task of the current attempt; `null` when none is queued.
  /// Events of any other task id are stale and ignored.
  final String? nativeTaskId;
  final bool done;
  final int bytes;
  const DownloadFile({
    required this.fileId,
    required this.chapterId,
    required this.position,
    required this.url,
    required this.relativePath,
    this.nativeTaskId,
    required this.done,
    required this.bytes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['file_id'] = Variable<String>(fileId);
    map['chapter_id'] = Variable<String>(chapterId);
    map['position'] = Variable<int>(position);
    map['url'] = Variable<String>(url);
    map['relative_path'] = Variable<String>(relativePath);
    if (!nullToAbsent || nativeTaskId != null) {
      map['native_task_id'] = Variable<String>(nativeTaskId);
    }
    map['done'] = Variable<bool>(done);
    map['bytes'] = Variable<int>(bytes);
    return map;
  }

  DownloadFilesCompanion toCompanion(bool nullToAbsent) {
    return DownloadFilesCompanion(
      fileId: Value(fileId),
      chapterId: Value(chapterId),
      position: Value(position),
      url: Value(url),
      relativePath: Value(relativePath),
      nativeTaskId: nativeTaskId == null && nullToAbsent
          ? const Value.absent()
          : Value(nativeTaskId),
      done: Value(done),
      bytes: Value(bytes),
    );
  }

  factory DownloadFile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadFile(
      fileId: serializer.fromJson<String>(json['fileId']),
      chapterId: serializer.fromJson<String>(json['chapterId']),
      position: serializer.fromJson<int>(json['position']),
      url: serializer.fromJson<String>(json['url']),
      relativePath: serializer.fromJson<String>(json['relativePath']),
      nativeTaskId: serializer.fromJson<String?>(json['nativeTaskId']),
      done: serializer.fromJson<bool>(json['done']),
      bytes: serializer.fromJson<int>(json['bytes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'fileId': serializer.toJson<String>(fileId),
      'chapterId': serializer.toJson<String>(chapterId),
      'position': serializer.toJson<int>(position),
      'url': serializer.toJson<String>(url),
      'relativePath': serializer.toJson<String>(relativePath),
      'nativeTaskId': serializer.toJson<String?>(nativeTaskId),
      'done': serializer.toJson<bool>(done),
      'bytes': serializer.toJson<int>(bytes),
    };
  }

  DownloadFile copyWith({
    String? fileId,
    String? chapterId,
    int? position,
    String? url,
    String? relativePath,
    Value<String?> nativeTaskId = const Value.absent(),
    bool? done,
    int? bytes,
  }) => DownloadFile(
    fileId: fileId ?? this.fileId,
    chapterId: chapterId ?? this.chapterId,
    position: position ?? this.position,
    url: url ?? this.url,
    relativePath: relativePath ?? this.relativePath,
    nativeTaskId: nativeTaskId.present ? nativeTaskId.value : this.nativeTaskId,
    done: done ?? this.done,
    bytes: bytes ?? this.bytes,
  );
  DownloadFile copyWithCompanion(DownloadFilesCompanion data) {
    return DownloadFile(
      fileId: data.fileId.present ? data.fileId.value : this.fileId,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      position: data.position.present ? data.position.value : this.position,
      url: data.url.present ? data.url.value : this.url,
      relativePath: data.relativePath.present
          ? data.relativePath.value
          : this.relativePath,
      nativeTaskId: data.nativeTaskId.present
          ? data.nativeTaskId.value
          : this.nativeTaskId,
      done: data.done.present ? data.done.value : this.done,
      bytes: data.bytes.present ? data.bytes.value : this.bytes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadFile(')
          ..write('fileId: $fileId, ')
          ..write('chapterId: $chapterId, ')
          ..write('position: $position, ')
          ..write('url: $url, ')
          ..write('relativePath: $relativePath, ')
          ..write('nativeTaskId: $nativeTaskId, ')
          ..write('done: $done, ')
          ..write('bytes: $bytes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    fileId,
    chapterId,
    position,
    url,
    relativePath,
    nativeTaskId,
    done,
    bytes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadFile &&
          other.fileId == this.fileId &&
          other.chapterId == this.chapterId &&
          other.position == this.position &&
          other.url == this.url &&
          other.relativePath == this.relativePath &&
          other.nativeTaskId == this.nativeTaskId &&
          other.done == this.done &&
          other.bytes == this.bytes);
}

class DownloadFilesCompanion extends UpdateCompanion<DownloadFile> {
  final Value<String> fileId;
  final Value<String> chapterId;
  final Value<int> position;
  final Value<String> url;
  final Value<String> relativePath;
  final Value<String?> nativeTaskId;
  final Value<bool> done;
  final Value<int> bytes;
  final Value<int> rowid;
  const DownloadFilesCompanion({
    this.fileId = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.position = const Value.absent(),
    this.url = const Value.absent(),
    this.relativePath = const Value.absent(),
    this.nativeTaskId = const Value.absent(),
    this.done = const Value.absent(),
    this.bytes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DownloadFilesCompanion.insert({
    required String fileId,
    required String chapterId,
    required int position,
    required String url,
    required String relativePath,
    this.nativeTaskId = const Value.absent(),
    this.done = const Value.absent(),
    this.bytes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : fileId = Value(fileId),
       chapterId = Value(chapterId),
       position = Value(position),
       url = Value(url),
       relativePath = Value(relativePath);
  static Insertable<DownloadFile> custom({
    Expression<String>? fileId,
    Expression<String>? chapterId,
    Expression<int>? position,
    Expression<String>? url,
    Expression<String>? relativePath,
    Expression<String>? nativeTaskId,
    Expression<bool>? done,
    Expression<int>? bytes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (fileId != null) 'file_id': fileId,
      if (chapterId != null) 'chapter_id': chapterId,
      if (position != null) 'position': position,
      if (url != null) 'url': url,
      if (relativePath != null) 'relative_path': relativePath,
      if (nativeTaskId != null) 'native_task_id': nativeTaskId,
      if (done != null) 'done': done,
      if (bytes != null) 'bytes': bytes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DownloadFilesCompanion copyWith({
    Value<String>? fileId,
    Value<String>? chapterId,
    Value<int>? position,
    Value<String>? url,
    Value<String>? relativePath,
    Value<String?>? nativeTaskId,
    Value<bool>? done,
    Value<int>? bytes,
    Value<int>? rowid,
  }) {
    return DownloadFilesCompanion(
      fileId: fileId ?? this.fileId,
      chapterId: chapterId ?? this.chapterId,
      position: position ?? this.position,
      url: url ?? this.url,
      relativePath: relativePath ?? this.relativePath,
      nativeTaskId: nativeTaskId ?? this.nativeTaskId,
      done: done ?? this.done,
      bytes: bytes ?? this.bytes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (fileId.present) {
      map['file_id'] = Variable<String>(fileId.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (relativePath.present) {
      map['relative_path'] = Variable<String>(relativePath.value);
    }
    if (nativeTaskId.present) {
      map['native_task_id'] = Variable<String>(nativeTaskId.value);
    }
    if (done.present) {
      map['done'] = Variable<bool>(done.value);
    }
    if (bytes.present) {
      map['bytes'] = Variable<int>(bytes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadFilesCompanion(')
          ..write('fileId: $fileId, ')
          ..write('chapterId: $chapterId, ')
          ..write('position: $position, ')
          ..write('url: $url, ')
          ..write('relativePath: $relativePath, ')
          ..write('nativeTaskId: $nativeTaskId, ')
          ..write('done: $done, ')
          ..write('bytes: $bytes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$DownloadsDatabase extends GeneratedDatabase {
  _$DownloadsDatabase(QueryExecutor e) : super(e);
  $DownloadsDatabaseManager get managers => $DownloadsDatabaseManager(this);
  late final $DownloadBooksTable downloadBooks = $DownloadBooksTable(this);
  late final $DownloadChaptersTable downloadChapters = $DownloadChaptersTable(
    this,
  );
  late final $DownloadFilesTable downloadFiles = $DownloadFilesTable(this);
  late final Index idxDownloadChaptersBook = Index(
    'idx_download_chapters_book',
    'CREATE INDEX idx_download_chapters_book ON download_chapters (book_id)',
  );
  late final Index idxDownloadChaptersState = Index(
    'idx_download_chapters_state',
    'CREATE INDEX idx_download_chapters_state ON download_chapters (state)',
  );
  late final Index idxDownloadFilesChapter = Index(
    'idx_download_files_chapter',
    'CREATE INDEX idx_download_files_chapter ON download_files (chapter_id)',
  );
  late final Index idxDownloadFilesTask = Index(
    'idx_download_files_task',
    'CREATE INDEX idx_download_files_task ON download_files (native_task_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    downloadBooks,
    downloadChapters,
    downloadFiles,
    idxDownloadChaptersBook,
    idxDownloadChaptersState,
    idxDownloadFilesChapter,
    idxDownloadFilesTask,
  ];
}

typedef $$DownloadBooksTableCreateCompanionBuilder =
    DownloadBooksCompanion Function({
      required String bookId,
      required String bookType,
      required DateTime enqueuedAt,
      Value<int> rowid,
    });
typedef $$DownloadBooksTableUpdateCompanionBuilder =
    DownloadBooksCompanion Function({
      Value<String> bookId,
      Value<String> bookType,
      Value<DateTime> enqueuedAt,
      Value<int> rowid,
    });

class $$DownloadBooksTableFilterComposer
    extends Composer<_$DownloadsDatabase, $DownloadBooksTable> {
  $$DownloadBooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookType => $composableBuilder(
    column: $table.bookType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get enqueuedAt => $composableBuilder(
    column: $table.enqueuedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DownloadBooksTableOrderingComposer
    extends Composer<_$DownloadsDatabase, $DownloadBooksTable> {
  $$DownloadBooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookType => $composableBuilder(
    column: $table.bookType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get enqueuedAt => $composableBuilder(
    column: $table.enqueuedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DownloadBooksTableAnnotationComposer
    extends Composer<_$DownloadsDatabase, $DownloadBooksTable> {
  $$DownloadBooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<String> get bookType =>
      $composableBuilder(column: $table.bookType, builder: (column) => column);

  GeneratedColumn<DateTime> get enqueuedAt => $composableBuilder(
    column: $table.enqueuedAt,
    builder: (column) => column,
  );
}

class $$DownloadBooksTableTableManager
    extends
        RootTableManager<
          _$DownloadsDatabase,
          $DownloadBooksTable,
          DownloadBook,
          $$DownloadBooksTableFilterComposer,
          $$DownloadBooksTableOrderingComposer,
          $$DownloadBooksTableAnnotationComposer,
          $$DownloadBooksTableCreateCompanionBuilder,
          $$DownloadBooksTableUpdateCompanionBuilder,
          (
            DownloadBook,
            BaseReferences<
              _$DownloadsDatabase,
              $DownloadBooksTable,
              DownloadBook
            >,
          ),
          DownloadBook,
          PrefetchHooks Function()
        > {
  $$DownloadBooksTableTableManager(
    _$DownloadsDatabase db,
    $DownloadBooksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadBooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadBooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadBooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> bookId = const Value.absent(),
                Value<String> bookType = const Value.absent(),
                Value<DateTime> enqueuedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DownloadBooksCompanion(
                bookId: bookId,
                bookType: bookType,
                enqueuedAt: enqueuedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String bookId,
                required String bookType,
                required DateTime enqueuedAt,
                Value<int> rowid = const Value.absent(),
              }) => DownloadBooksCompanion.insert(
                bookId: bookId,
                bookType: bookType,
                enqueuedAt: enqueuedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DownloadBooksTableProcessedTableManager =
    ProcessedTableManager<
      _$DownloadsDatabase,
      $DownloadBooksTable,
      DownloadBook,
      $$DownloadBooksTableFilterComposer,
      $$DownloadBooksTableOrderingComposer,
      $$DownloadBooksTableAnnotationComposer,
      $$DownloadBooksTableCreateCompanionBuilder,
      $$DownloadBooksTableUpdateCompanionBuilder,
      (
        DownloadBook,
        BaseReferences<_$DownloadsDatabase, $DownloadBooksTable, DownloadBook>,
      ),
      DownloadBook,
      PrefetchHooks Function()
    >;
typedef $$DownloadChaptersTableCreateCompanionBuilder =
    DownloadChaptersCompanion Function({
      required String chapterId,
      required String bookId,
      required DownloadState state,
      Value<String?> error,
      Value<bool> planned,
      Value<int> manifestBytes,
      required DateTime enqueuedAt,
      Value<int> rowid,
    });
typedef $$DownloadChaptersTableUpdateCompanionBuilder =
    DownloadChaptersCompanion Function({
      Value<String> chapterId,
      Value<String> bookId,
      Value<DownloadState> state,
      Value<String?> error,
      Value<bool> planned,
      Value<int> manifestBytes,
      Value<DateTime> enqueuedAt,
      Value<int> rowid,
    });

class $$DownloadChaptersTableFilterComposer
    extends Composer<_$DownloadsDatabase, $DownloadChaptersTable> {
  $$DownloadChaptersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DownloadState, DownloadState, String>
  get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get planned => $composableBuilder(
    column: $table.planned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get manifestBytes => $composableBuilder(
    column: $table.manifestBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get enqueuedAt => $composableBuilder(
    column: $table.enqueuedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DownloadChaptersTableOrderingComposer
    extends Composer<_$DownloadsDatabase, $DownloadChaptersTable> {
  $$DownloadChaptersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get planned => $composableBuilder(
    column: $table.planned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get manifestBytes => $composableBuilder(
    column: $table.manifestBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get enqueuedAt => $composableBuilder(
    column: $table.enqueuedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DownloadChaptersTableAnnotationComposer
    extends Composer<_$DownloadsDatabase, $DownloadChaptersTable> {
  $$DownloadChaptersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get chapterId =>
      $composableBuilder(column: $table.chapterId, builder: (column) => column);

  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DownloadState, String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);

  GeneratedColumn<bool> get planned =>
      $composableBuilder(column: $table.planned, builder: (column) => column);

  GeneratedColumn<int> get manifestBytes => $composableBuilder(
    column: $table.manifestBytes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get enqueuedAt => $composableBuilder(
    column: $table.enqueuedAt,
    builder: (column) => column,
  );
}

class $$DownloadChaptersTableTableManager
    extends
        RootTableManager<
          _$DownloadsDatabase,
          $DownloadChaptersTable,
          DownloadChapter,
          $$DownloadChaptersTableFilterComposer,
          $$DownloadChaptersTableOrderingComposer,
          $$DownloadChaptersTableAnnotationComposer,
          $$DownloadChaptersTableCreateCompanionBuilder,
          $$DownloadChaptersTableUpdateCompanionBuilder,
          (
            DownloadChapter,
            BaseReferences<
              _$DownloadsDatabase,
              $DownloadChaptersTable,
              DownloadChapter
            >,
          ),
          DownloadChapter,
          PrefetchHooks Function()
        > {
  $$DownloadChaptersTableTableManager(
    _$DownloadsDatabase db,
    $DownloadChaptersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadChaptersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadChaptersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadChaptersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> chapterId = const Value.absent(),
                Value<String> bookId = const Value.absent(),
                Value<DownloadState> state = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<bool> planned = const Value.absent(),
                Value<int> manifestBytes = const Value.absent(),
                Value<DateTime> enqueuedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DownloadChaptersCompanion(
                chapterId: chapterId,
                bookId: bookId,
                state: state,
                error: error,
                planned: planned,
                manifestBytes: manifestBytes,
                enqueuedAt: enqueuedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String chapterId,
                required String bookId,
                required DownloadState state,
                Value<String?> error = const Value.absent(),
                Value<bool> planned = const Value.absent(),
                Value<int> manifestBytes = const Value.absent(),
                required DateTime enqueuedAt,
                Value<int> rowid = const Value.absent(),
              }) => DownloadChaptersCompanion.insert(
                chapterId: chapterId,
                bookId: bookId,
                state: state,
                error: error,
                planned: planned,
                manifestBytes: manifestBytes,
                enqueuedAt: enqueuedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DownloadChaptersTableProcessedTableManager =
    ProcessedTableManager<
      _$DownloadsDatabase,
      $DownloadChaptersTable,
      DownloadChapter,
      $$DownloadChaptersTableFilterComposer,
      $$DownloadChaptersTableOrderingComposer,
      $$DownloadChaptersTableAnnotationComposer,
      $$DownloadChaptersTableCreateCompanionBuilder,
      $$DownloadChaptersTableUpdateCompanionBuilder,
      (
        DownloadChapter,
        BaseReferences<
          _$DownloadsDatabase,
          $DownloadChaptersTable,
          DownloadChapter
        >,
      ),
      DownloadChapter,
      PrefetchHooks Function()
    >;
typedef $$DownloadFilesTableCreateCompanionBuilder =
    DownloadFilesCompanion Function({
      required String fileId,
      required String chapterId,
      required int position,
      required String url,
      required String relativePath,
      Value<String?> nativeTaskId,
      Value<bool> done,
      Value<int> bytes,
      Value<int> rowid,
    });
typedef $$DownloadFilesTableUpdateCompanionBuilder =
    DownloadFilesCompanion Function({
      Value<String> fileId,
      Value<String> chapterId,
      Value<int> position,
      Value<String> url,
      Value<String> relativePath,
      Value<String?> nativeTaskId,
      Value<bool> done,
      Value<int> bytes,
      Value<int> rowid,
    });

class $$DownloadFilesTableFilterComposer
    extends Composer<_$DownloadsDatabase, $DownloadFilesTable> {
  $$DownloadFilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get fileId => $composableBuilder(
    column: $table.fileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nativeTaskId => $composableBuilder(
    column: $table.nativeTaskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DownloadFilesTableOrderingComposer
    extends Composer<_$DownloadsDatabase, $DownloadFilesTable> {
  $$DownloadFilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get fileId => $composableBuilder(
    column: $table.fileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nativeTaskId => $composableBuilder(
    column: $table.nativeTaskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DownloadFilesTableAnnotationComposer
    extends Composer<_$DownloadsDatabase, $DownloadFilesTable> {
  $$DownloadFilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get fileId =>
      $composableBuilder(column: $table.fileId, builder: (column) => column);

  GeneratedColumn<String> get chapterId =>
      $composableBuilder(column: $table.chapterId, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nativeTaskId => $composableBuilder(
    column: $table.nativeTaskId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get done =>
      $composableBuilder(column: $table.done, builder: (column) => column);

  GeneratedColumn<int> get bytes =>
      $composableBuilder(column: $table.bytes, builder: (column) => column);
}

class $$DownloadFilesTableTableManager
    extends
        RootTableManager<
          _$DownloadsDatabase,
          $DownloadFilesTable,
          DownloadFile,
          $$DownloadFilesTableFilterComposer,
          $$DownloadFilesTableOrderingComposer,
          $$DownloadFilesTableAnnotationComposer,
          $$DownloadFilesTableCreateCompanionBuilder,
          $$DownloadFilesTableUpdateCompanionBuilder,
          (
            DownloadFile,
            BaseReferences<
              _$DownloadsDatabase,
              $DownloadFilesTable,
              DownloadFile
            >,
          ),
          DownloadFile,
          PrefetchHooks Function()
        > {
  $$DownloadFilesTableTableManager(
    _$DownloadsDatabase db,
    $DownloadFilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadFilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadFilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadFilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> fileId = const Value.absent(),
                Value<String> chapterId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String> relativePath = const Value.absent(),
                Value<String?> nativeTaskId = const Value.absent(),
                Value<bool> done = const Value.absent(),
                Value<int> bytes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DownloadFilesCompanion(
                fileId: fileId,
                chapterId: chapterId,
                position: position,
                url: url,
                relativePath: relativePath,
                nativeTaskId: nativeTaskId,
                done: done,
                bytes: bytes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String fileId,
                required String chapterId,
                required int position,
                required String url,
                required String relativePath,
                Value<String?> nativeTaskId = const Value.absent(),
                Value<bool> done = const Value.absent(),
                Value<int> bytes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DownloadFilesCompanion.insert(
                fileId: fileId,
                chapterId: chapterId,
                position: position,
                url: url,
                relativePath: relativePath,
                nativeTaskId: nativeTaskId,
                done: done,
                bytes: bytes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DownloadFilesTableProcessedTableManager =
    ProcessedTableManager<
      _$DownloadsDatabase,
      $DownloadFilesTable,
      DownloadFile,
      $$DownloadFilesTableFilterComposer,
      $$DownloadFilesTableOrderingComposer,
      $$DownloadFilesTableAnnotationComposer,
      $$DownloadFilesTableCreateCompanionBuilder,
      $$DownloadFilesTableUpdateCompanionBuilder,
      (
        DownloadFile,
        BaseReferences<_$DownloadsDatabase, $DownloadFilesTable, DownloadFile>,
      ),
      DownloadFile,
      PrefetchHooks Function()
    >;

class $DownloadsDatabaseManager {
  final _$DownloadsDatabase _db;
  $DownloadsDatabaseManager(this._db);
  $$DownloadBooksTableTableManager get downloadBooks =>
      $$DownloadBooksTableTableManager(_db, _db.downloadBooks);
  $$DownloadChaptersTableTableManager get downloadChapters =>
      $$DownloadChaptersTableTableManager(_db, _db.downloadChapters);
  $$DownloadFilesTableTableManager get downloadFiles =>
      $$DownloadFilesTableTableManager(_db, _db.downloadFiles);
}
