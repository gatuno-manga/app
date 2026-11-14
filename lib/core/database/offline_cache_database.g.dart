// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_cache_database.dart';

// ignore_for_file: type=lint
class $CachedBooksTable extends CachedBooks
    with TableInfo<$CachedBooksTable, CachedBook> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedBooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverMeta = const VerificationMeta('cover');
  @override
  late final GeneratedColumn<String> cover = GeneratedColumn<String>(
    'cover',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _publicationMeta = const VerificationMeta(
    'publication',
  );
  @override
  late final GeneratedColumn<int> publication = GeneratedColumn<int>(
    'publication',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalChaptersMeta = const VerificationMeta(
    'totalChapters',
  );
  @override
  late final GeneratedColumn<int> totalChapters = GeneratedColumn<int>(
    'total_chapters',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverWidthMeta = const VerificationMeta(
    'coverWidth',
  );
  @override
  late final GeneratedColumn<double> coverWidth = GeneratedColumn<double>(
    'cover_width',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverHeightMeta = const VerificationMeta(
    'coverHeight',
  );
  @override
  late final GeneratedColumn<double> coverHeight = GeneratedColumn<double>(
    'cover_height',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverSizeBytesMeta = const VerificationMeta(
    'coverSizeBytes',
  );
  @override
  late final GeneratedColumn<int> coverSizeBytes = GeneratedColumn<int>(
    'cover_size_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverMimeTypeMeta = const VerificationMeta(
    'coverMimeType',
  );
  @override
  late final GeneratedColumn<String> coverMimeType = GeneratedColumn<String>(
    'cover_mime_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverBlurHashMeta = const VerificationMeta(
    'coverBlurHash',
  );
  @override
  late final GeneratedColumn<String> coverBlurHash = GeneratedColumn<String>(
    'cover_blur_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverDominantColorMeta =
      const VerificationMeta('coverDominantColor');
  @override
  late final GeneratedColumn<String> coverDominantColor =
      GeneratedColumn<String>(
        'cover_dominant_color',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _coverPHashMeta = const VerificationMeta(
    'coverPHash',
  );
  @override
  late final GeneratedColumn<String> coverPHash = GeneratedColumn<String>(
    'cover_p_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverEntropyMeta = const VerificationMeta(
    'coverEntropy',
  );
  @override
  late final GeneratedColumn<double> coverEntropy = GeneratedColumn<double>(
    'cover_entropy',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverFormatOriginMeta = const VerificationMeta(
    'coverFormatOrigin',
  );
  @override
  late final GeneratedColumn<String> coverFormatOrigin =
      GeneratedColumn<String>(
        'cover_format_origin',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _relationsKnownMeta = const VerificationMeta(
    'relationsKnown',
  );
  @override
  late final GeneratedColumn<bool> relationsKnown = GeneratedColumn<bool>(
    'relations_known',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("relations_known" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _seenAsSafeMeta = const VerificationMeta(
    'seenAsSafe',
  );
  @override
  late final GeneratedColumn<bool> seenAsSafe = GeneratedColumn<bool>(
    'seen_as_safe',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("seen_as_safe" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastAccessedAtMeta = const VerificationMeta(
    'lastAccessedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAccessedAt =
      GeneratedColumn<DateTime>(
        'last_accessed_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    cover,
    type,
    publication,
    totalChapters,
    createdAt,
    updatedAt,
    coverWidth,
    coverHeight,
    coverSizeBytes,
    coverMimeType,
    coverBlurHash,
    coverDominantColor,
    coverPHash,
    coverEntropy,
    coverFormatOrigin,
    relationsKnown,
    seenAsSafe,
    cachedAt,
    lastAccessedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_books';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedBook> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('cover')) {
      context.handle(
        _coverMeta,
        cover.isAcceptableOrUnknown(data['cover']!, _coverMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('publication')) {
      context.handle(
        _publicationMeta,
        publication.isAcceptableOrUnknown(
          data['publication']!,
          _publicationMeta,
        ),
      );
    }
    if (data.containsKey('total_chapters')) {
      context.handle(
        _totalChaptersMeta,
        totalChapters.isAcceptableOrUnknown(
          data['total_chapters']!,
          _totalChaptersMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('cover_width')) {
      context.handle(
        _coverWidthMeta,
        coverWidth.isAcceptableOrUnknown(data['cover_width']!, _coverWidthMeta),
      );
    }
    if (data.containsKey('cover_height')) {
      context.handle(
        _coverHeightMeta,
        coverHeight.isAcceptableOrUnknown(
          data['cover_height']!,
          _coverHeightMeta,
        ),
      );
    }
    if (data.containsKey('cover_size_bytes')) {
      context.handle(
        _coverSizeBytesMeta,
        coverSizeBytes.isAcceptableOrUnknown(
          data['cover_size_bytes']!,
          _coverSizeBytesMeta,
        ),
      );
    }
    if (data.containsKey('cover_mime_type')) {
      context.handle(
        _coverMimeTypeMeta,
        coverMimeType.isAcceptableOrUnknown(
          data['cover_mime_type']!,
          _coverMimeTypeMeta,
        ),
      );
    }
    if (data.containsKey('cover_blur_hash')) {
      context.handle(
        _coverBlurHashMeta,
        coverBlurHash.isAcceptableOrUnknown(
          data['cover_blur_hash']!,
          _coverBlurHashMeta,
        ),
      );
    }
    if (data.containsKey('cover_dominant_color')) {
      context.handle(
        _coverDominantColorMeta,
        coverDominantColor.isAcceptableOrUnknown(
          data['cover_dominant_color']!,
          _coverDominantColorMeta,
        ),
      );
    }
    if (data.containsKey('cover_p_hash')) {
      context.handle(
        _coverPHashMeta,
        coverPHash.isAcceptableOrUnknown(
          data['cover_p_hash']!,
          _coverPHashMeta,
        ),
      );
    }
    if (data.containsKey('cover_entropy')) {
      context.handle(
        _coverEntropyMeta,
        coverEntropy.isAcceptableOrUnknown(
          data['cover_entropy']!,
          _coverEntropyMeta,
        ),
      );
    }
    if (data.containsKey('cover_format_origin')) {
      context.handle(
        _coverFormatOriginMeta,
        coverFormatOrigin.isAcceptableOrUnknown(
          data['cover_format_origin']!,
          _coverFormatOriginMeta,
        ),
      );
    }
    if (data.containsKey('relations_known')) {
      context.handle(
        _relationsKnownMeta,
        relationsKnown.isAcceptableOrUnknown(
          data['relations_known']!,
          _relationsKnownMeta,
        ),
      );
    }
    if (data.containsKey('seen_as_safe')) {
      context.handle(
        _seenAsSafeMeta,
        seenAsSafe.isAcceptableOrUnknown(
          data['seen_as_safe']!,
          _seenAsSafeMeta,
        ),
      );
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    if (data.containsKey('last_accessed_at')) {
      context.handle(
        _lastAccessedAtMeta,
        lastAccessedAt.isAcceptableOrUnknown(
          data['last_accessed_at']!,
          _lastAccessedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastAccessedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedBook map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedBook(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      cover: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      ),
      publication: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}publication'],
      ),
      totalChapters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_chapters'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      coverWidth: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cover_width'],
      ),
      coverHeight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cover_height'],
      ),
      coverSizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cover_size_bytes'],
      ),
      coverMimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_mime_type'],
      ),
      coverBlurHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_blur_hash'],
      ),
      coverDominantColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_dominant_color'],
      ),
      coverPHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_p_hash'],
      ),
      coverEntropy: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cover_entropy'],
      ),
      coverFormatOrigin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_format_origin'],
      ),
      relationsKnown: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}relations_known'],
      )!,
      seenAsSafe: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}seen_as_safe'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
      lastAccessedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_accessed_at'],
      )!,
    );
  }

  @override
  $CachedBooksTable createAlias(String alias) {
    return $CachedBooksTable(attachedDatabase, alias);
  }
}

class CachedBook extends DataClass implements Insertable<CachedBook> {
  final String id;
  final String title;
  final String? description;
  final String? cover;
  final String? type;
  final int? publication;
  final int? totalChapters;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double? coverWidth;
  final double? coverHeight;
  final int? coverSizeBytes;
  final String? coverMimeType;
  final String? coverBlurHash;
  final String? coverDominantColor;
  final String? coverPHash;
  final double? coverEntropy;
  final String? coverFormatOrigin;

  /// Tags, authors and sensitive content come from a detail response.
  final bool relationsKnown;

  /// Returned by a list request that asked for safe books only. List items
  /// carry no sensitive content, so this is how a book never opened in
  /// detail can still pass the offline "safe" filter.
  final bool seenAsSafe;
  final DateTime cachedAt;

  /// Last read or write; drives the 90-day eviction.
  final DateTime lastAccessedAt;
  const CachedBook({
    required this.id,
    required this.title,
    this.description,
    this.cover,
    this.type,
    this.publication,
    this.totalChapters,
    this.createdAt,
    this.updatedAt,
    this.coverWidth,
    this.coverHeight,
    this.coverSizeBytes,
    this.coverMimeType,
    this.coverBlurHash,
    this.coverDominantColor,
    this.coverPHash,
    this.coverEntropy,
    this.coverFormatOrigin,
    required this.relationsKnown,
    required this.seenAsSafe,
    required this.cachedAt,
    required this.lastAccessedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || cover != null) {
      map['cover'] = Variable<String>(cover);
    }
    if (!nullToAbsent || type != null) {
      map['type'] = Variable<String>(type);
    }
    if (!nullToAbsent || publication != null) {
      map['publication'] = Variable<int>(publication);
    }
    if (!nullToAbsent || totalChapters != null) {
      map['total_chapters'] = Variable<int>(totalChapters);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || coverWidth != null) {
      map['cover_width'] = Variable<double>(coverWidth);
    }
    if (!nullToAbsent || coverHeight != null) {
      map['cover_height'] = Variable<double>(coverHeight);
    }
    if (!nullToAbsent || coverSizeBytes != null) {
      map['cover_size_bytes'] = Variable<int>(coverSizeBytes);
    }
    if (!nullToAbsent || coverMimeType != null) {
      map['cover_mime_type'] = Variable<String>(coverMimeType);
    }
    if (!nullToAbsent || coverBlurHash != null) {
      map['cover_blur_hash'] = Variable<String>(coverBlurHash);
    }
    if (!nullToAbsent || coverDominantColor != null) {
      map['cover_dominant_color'] = Variable<String>(coverDominantColor);
    }
    if (!nullToAbsent || coverPHash != null) {
      map['cover_p_hash'] = Variable<String>(coverPHash);
    }
    if (!nullToAbsent || coverEntropy != null) {
      map['cover_entropy'] = Variable<double>(coverEntropy);
    }
    if (!nullToAbsent || coverFormatOrigin != null) {
      map['cover_format_origin'] = Variable<String>(coverFormatOrigin);
    }
    map['relations_known'] = Variable<bool>(relationsKnown);
    map['seen_as_safe'] = Variable<bool>(seenAsSafe);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    map['last_accessed_at'] = Variable<DateTime>(lastAccessedAt);
    return map;
  }

  CachedBooksCompanion toCompanion(bool nullToAbsent) {
    return CachedBooksCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      cover: cover == null && nullToAbsent
          ? const Value.absent()
          : Value(cover),
      type: type == null && nullToAbsent ? const Value.absent() : Value(type),
      publication: publication == null && nullToAbsent
          ? const Value.absent()
          : Value(publication),
      totalChapters: totalChapters == null && nullToAbsent
          ? const Value.absent()
          : Value(totalChapters),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      coverWidth: coverWidth == null && nullToAbsent
          ? const Value.absent()
          : Value(coverWidth),
      coverHeight: coverHeight == null && nullToAbsent
          ? const Value.absent()
          : Value(coverHeight),
      coverSizeBytes: coverSizeBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(coverSizeBytes),
      coverMimeType: coverMimeType == null && nullToAbsent
          ? const Value.absent()
          : Value(coverMimeType),
      coverBlurHash: coverBlurHash == null && nullToAbsent
          ? const Value.absent()
          : Value(coverBlurHash),
      coverDominantColor: coverDominantColor == null && nullToAbsent
          ? const Value.absent()
          : Value(coverDominantColor),
      coverPHash: coverPHash == null && nullToAbsent
          ? const Value.absent()
          : Value(coverPHash),
      coverEntropy: coverEntropy == null && nullToAbsent
          ? const Value.absent()
          : Value(coverEntropy),
      coverFormatOrigin: coverFormatOrigin == null && nullToAbsent
          ? const Value.absent()
          : Value(coverFormatOrigin),
      relationsKnown: Value(relationsKnown),
      seenAsSafe: Value(seenAsSafe),
      cachedAt: Value(cachedAt),
      lastAccessedAt: Value(lastAccessedAt),
    );
  }

  factory CachedBook.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedBook(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      cover: serializer.fromJson<String?>(json['cover']),
      type: serializer.fromJson<String?>(json['type']),
      publication: serializer.fromJson<int?>(json['publication']),
      totalChapters: serializer.fromJson<int?>(json['totalChapters']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      coverWidth: serializer.fromJson<double?>(json['coverWidth']),
      coverHeight: serializer.fromJson<double?>(json['coverHeight']),
      coverSizeBytes: serializer.fromJson<int?>(json['coverSizeBytes']),
      coverMimeType: serializer.fromJson<String?>(json['coverMimeType']),
      coverBlurHash: serializer.fromJson<String?>(json['coverBlurHash']),
      coverDominantColor: serializer.fromJson<String?>(
        json['coverDominantColor'],
      ),
      coverPHash: serializer.fromJson<String?>(json['coverPHash']),
      coverEntropy: serializer.fromJson<double?>(json['coverEntropy']),
      coverFormatOrigin: serializer.fromJson<String?>(
        json['coverFormatOrigin'],
      ),
      relationsKnown: serializer.fromJson<bool>(json['relationsKnown']),
      seenAsSafe: serializer.fromJson<bool>(json['seenAsSafe']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
      lastAccessedAt: serializer.fromJson<DateTime>(json['lastAccessedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'cover': serializer.toJson<String?>(cover),
      'type': serializer.toJson<String?>(type),
      'publication': serializer.toJson<int?>(publication),
      'totalChapters': serializer.toJson<int?>(totalChapters),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'coverWidth': serializer.toJson<double?>(coverWidth),
      'coverHeight': serializer.toJson<double?>(coverHeight),
      'coverSizeBytes': serializer.toJson<int?>(coverSizeBytes),
      'coverMimeType': serializer.toJson<String?>(coverMimeType),
      'coverBlurHash': serializer.toJson<String?>(coverBlurHash),
      'coverDominantColor': serializer.toJson<String?>(coverDominantColor),
      'coverPHash': serializer.toJson<String?>(coverPHash),
      'coverEntropy': serializer.toJson<double?>(coverEntropy),
      'coverFormatOrigin': serializer.toJson<String?>(coverFormatOrigin),
      'relationsKnown': serializer.toJson<bool>(relationsKnown),
      'seenAsSafe': serializer.toJson<bool>(seenAsSafe),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
      'lastAccessedAt': serializer.toJson<DateTime>(lastAccessedAt),
    };
  }

  CachedBook copyWith({
    String? id,
    String? title,
    Value<String?> description = const Value.absent(),
    Value<String?> cover = const Value.absent(),
    Value<String?> type = const Value.absent(),
    Value<int?> publication = const Value.absent(),
    Value<int?> totalChapters = const Value.absent(),
    Value<DateTime?> createdAt = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<double?> coverWidth = const Value.absent(),
    Value<double?> coverHeight = const Value.absent(),
    Value<int?> coverSizeBytes = const Value.absent(),
    Value<String?> coverMimeType = const Value.absent(),
    Value<String?> coverBlurHash = const Value.absent(),
    Value<String?> coverDominantColor = const Value.absent(),
    Value<String?> coverPHash = const Value.absent(),
    Value<double?> coverEntropy = const Value.absent(),
    Value<String?> coverFormatOrigin = const Value.absent(),
    bool? relationsKnown,
    bool? seenAsSafe,
    DateTime? cachedAt,
    DateTime? lastAccessedAt,
  }) => CachedBook(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    cover: cover.present ? cover.value : this.cover,
    type: type.present ? type.value : this.type,
    publication: publication.present ? publication.value : this.publication,
    totalChapters: totalChapters.present
        ? totalChapters.value
        : this.totalChapters,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    coverWidth: coverWidth.present ? coverWidth.value : this.coverWidth,
    coverHeight: coverHeight.present ? coverHeight.value : this.coverHeight,
    coverSizeBytes: coverSizeBytes.present
        ? coverSizeBytes.value
        : this.coverSizeBytes,
    coverMimeType: coverMimeType.present
        ? coverMimeType.value
        : this.coverMimeType,
    coverBlurHash: coverBlurHash.present
        ? coverBlurHash.value
        : this.coverBlurHash,
    coverDominantColor: coverDominantColor.present
        ? coverDominantColor.value
        : this.coverDominantColor,
    coverPHash: coverPHash.present ? coverPHash.value : this.coverPHash,
    coverEntropy: coverEntropy.present ? coverEntropy.value : this.coverEntropy,
    coverFormatOrigin: coverFormatOrigin.present
        ? coverFormatOrigin.value
        : this.coverFormatOrigin,
    relationsKnown: relationsKnown ?? this.relationsKnown,
    seenAsSafe: seenAsSafe ?? this.seenAsSafe,
    cachedAt: cachedAt ?? this.cachedAt,
    lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
  );
  CachedBook copyWithCompanion(CachedBooksCompanion data) {
    return CachedBook(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      cover: data.cover.present ? data.cover.value : this.cover,
      type: data.type.present ? data.type.value : this.type,
      publication: data.publication.present
          ? data.publication.value
          : this.publication,
      totalChapters: data.totalChapters.present
          ? data.totalChapters.value
          : this.totalChapters,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      coverWidth: data.coverWidth.present
          ? data.coverWidth.value
          : this.coverWidth,
      coverHeight: data.coverHeight.present
          ? data.coverHeight.value
          : this.coverHeight,
      coverSizeBytes: data.coverSizeBytes.present
          ? data.coverSizeBytes.value
          : this.coverSizeBytes,
      coverMimeType: data.coverMimeType.present
          ? data.coverMimeType.value
          : this.coverMimeType,
      coverBlurHash: data.coverBlurHash.present
          ? data.coverBlurHash.value
          : this.coverBlurHash,
      coverDominantColor: data.coverDominantColor.present
          ? data.coverDominantColor.value
          : this.coverDominantColor,
      coverPHash: data.coverPHash.present
          ? data.coverPHash.value
          : this.coverPHash,
      coverEntropy: data.coverEntropy.present
          ? data.coverEntropy.value
          : this.coverEntropy,
      coverFormatOrigin: data.coverFormatOrigin.present
          ? data.coverFormatOrigin.value
          : this.coverFormatOrigin,
      relationsKnown: data.relationsKnown.present
          ? data.relationsKnown.value
          : this.relationsKnown,
      seenAsSafe: data.seenAsSafe.present
          ? data.seenAsSafe.value
          : this.seenAsSafe,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
      lastAccessedAt: data.lastAccessedAt.present
          ? data.lastAccessedAt.value
          : this.lastAccessedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedBook(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('cover: $cover, ')
          ..write('type: $type, ')
          ..write('publication: $publication, ')
          ..write('totalChapters: $totalChapters, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('coverWidth: $coverWidth, ')
          ..write('coverHeight: $coverHeight, ')
          ..write('coverSizeBytes: $coverSizeBytes, ')
          ..write('coverMimeType: $coverMimeType, ')
          ..write('coverBlurHash: $coverBlurHash, ')
          ..write('coverDominantColor: $coverDominantColor, ')
          ..write('coverPHash: $coverPHash, ')
          ..write('coverEntropy: $coverEntropy, ')
          ..write('coverFormatOrigin: $coverFormatOrigin, ')
          ..write('relationsKnown: $relationsKnown, ')
          ..write('seenAsSafe: $seenAsSafe, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('lastAccessedAt: $lastAccessedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    title,
    description,
    cover,
    type,
    publication,
    totalChapters,
    createdAt,
    updatedAt,
    coverWidth,
    coverHeight,
    coverSizeBytes,
    coverMimeType,
    coverBlurHash,
    coverDominantColor,
    coverPHash,
    coverEntropy,
    coverFormatOrigin,
    relationsKnown,
    seenAsSafe,
    cachedAt,
    lastAccessedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedBook &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.cover == this.cover &&
          other.type == this.type &&
          other.publication == this.publication &&
          other.totalChapters == this.totalChapters &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.coverWidth == this.coverWidth &&
          other.coverHeight == this.coverHeight &&
          other.coverSizeBytes == this.coverSizeBytes &&
          other.coverMimeType == this.coverMimeType &&
          other.coverBlurHash == this.coverBlurHash &&
          other.coverDominantColor == this.coverDominantColor &&
          other.coverPHash == this.coverPHash &&
          other.coverEntropy == this.coverEntropy &&
          other.coverFormatOrigin == this.coverFormatOrigin &&
          other.relationsKnown == this.relationsKnown &&
          other.seenAsSafe == this.seenAsSafe &&
          other.cachedAt == this.cachedAt &&
          other.lastAccessedAt == this.lastAccessedAt);
}

class CachedBooksCompanion extends UpdateCompanion<CachedBook> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<String?> cover;
  final Value<String?> type;
  final Value<int?> publication;
  final Value<int?> totalChapters;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<double?> coverWidth;
  final Value<double?> coverHeight;
  final Value<int?> coverSizeBytes;
  final Value<String?> coverMimeType;
  final Value<String?> coverBlurHash;
  final Value<String?> coverDominantColor;
  final Value<String?> coverPHash;
  final Value<double?> coverEntropy;
  final Value<String?> coverFormatOrigin;
  final Value<bool> relationsKnown;
  final Value<bool> seenAsSafe;
  final Value<DateTime> cachedAt;
  final Value<DateTime> lastAccessedAt;
  final Value<int> rowid;
  const CachedBooksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.cover = const Value.absent(),
    this.type = const Value.absent(),
    this.publication = const Value.absent(),
    this.totalChapters = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.coverWidth = const Value.absent(),
    this.coverHeight = const Value.absent(),
    this.coverSizeBytes = const Value.absent(),
    this.coverMimeType = const Value.absent(),
    this.coverBlurHash = const Value.absent(),
    this.coverDominantColor = const Value.absent(),
    this.coverPHash = const Value.absent(),
    this.coverEntropy = const Value.absent(),
    this.coverFormatOrigin = const Value.absent(),
    this.relationsKnown = const Value.absent(),
    this.seenAsSafe = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.lastAccessedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedBooksCompanion.insert({
    required String id,
    required String title,
    this.description = const Value.absent(),
    this.cover = const Value.absent(),
    this.type = const Value.absent(),
    this.publication = const Value.absent(),
    this.totalChapters = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.coverWidth = const Value.absent(),
    this.coverHeight = const Value.absent(),
    this.coverSizeBytes = const Value.absent(),
    this.coverMimeType = const Value.absent(),
    this.coverBlurHash = const Value.absent(),
    this.coverDominantColor = const Value.absent(),
    this.coverPHash = const Value.absent(),
    this.coverEntropy = const Value.absent(),
    this.coverFormatOrigin = const Value.absent(),
    this.relationsKnown = const Value.absent(),
    this.seenAsSafe = const Value.absent(),
    required DateTime cachedAt,
    required DateTime lastAccessedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       cachedAt = Value(cachedAt),
       lastAccessedAt = Value(lastAccessedAt);
  static Insertable<CachedBook> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? cover,
    Expression<String>? type,
    Expression<int>? publication,
    Expression<int>? totalChapters,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<double>? coverWidth,
    Expression<double>? coverHeight,
    Expression<int>? coverSizeBytes,
    Expression<String>? coverMimeType,
    Expression<String>? coverBlurHash,
    Expression<String>? coverDominantColor,
    Expression<String>? coverPHash,
    Expression<double>? coverEntropy,
    Expression<String>? coverFormatOrigin,
    Expression<bool>? relationsKnown,
    Expression<bool>? seenAsSafe,
    Expression<DateTime>? cachedAt,
    Expression<DateTime>? lastAccessedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (cover != null) 'cover': cover,
      if (type != null) 'type': type,
      if (publication != null) 'publication': publication,
      if (totalChapters != null) 'total_chapters': totalChapters,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (coverWidth != null) 'cover_width': coverWidth,
      if (coverHeight != null) 'cover_height': coverHeight,
      if (coverSizeBytes != null) 'cover_size_bytes': coverSizeBytes,
      if (coverMimeType != null) 'cover_mime_type': coverMimeType,
      if (coverBlurHash != null) 'cover_blur_hash': coverBlurHash,
      if (coverDominantColor != null)
        'cover_dominant_color': coverDominantColor,
      if (coverPHash != null) 'cover_p_hash': coverPHash,
      if (coverEntropy != null) 'cover_entropy': coverEntropy,
      if (coverFormatOrigin != null) 'cover_format_origin': coverFormatOrigin,
      if (relationsKnown != null) 'relations_known': relationsKnown,
      if (seenAsSafe != null) 'seen_as_safe': seenAsSafe,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (lastAccessedAt != null) 'last_accessed_at': lastAccessedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedBooksCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? description,
    Value<String?>? cover,
    Value<String?>? type,
    Value<int?>? publication,
    Value<int?>? totalChapters,
    Value<DateTime?>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<double?>? coverWidth,
    Value<double?>? coverHeight,
    Value<int?>? coverSizeBytes,
    Value<String?>? coverMimeType,
    Value<String?>? coverBlurHash,
    Value<String?>? coverDominantColor,
    Value<String?>? coverPHash,
    Value<double?>? coverEntropy,
    Value<String?>? coverFormatOrigin,
    Value<bool>? relationsKnown,
    Value<bool>? seenAsSafe,
    Value<DateTime>? cachedAt,
    Value<DateTime>? lastAccessedAt,
    Value<int>? rowid,
  }) {
    return CachedBooksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      cover: cover ?? this.cover,
      type: type ?? this.type,
      publication: publication ?? this.publication,
      totalChapters: totalChapters ?? this.totalChapters,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      coverWidth: coverWidth ?? this.coverWidth,
      coverHeight: coverHeight ?? this.coverHeight,
      coverSizeBytes: coverSizeBytes ?? this.coverSizeBytes,
      coverMimeType: coverMimeType ?? this.coverMimeType,
      coverBlurHash: coverBlurHash ?? this.coverBlurHash,
      coverDominantColor: coverDominantColor ?? this.coverDominantColor,
      coverPHash: coverPHash ?? this.coverPHash,
      coverEntropy: coverEntropy ?? this.coverEntropy,
      coverFormatOrigin: coverFormatOrigin ?? this.coverFormatOrigin,
      relationsKnown: relationsKnown ?? this.relationsKnown,
      seenAsSafe: seenAsSafe ?? this.seenAsSafe,
      cachedAt: cachedAt ?? this.cachedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (cover.present) {
      map['cover'] = Variable<String>(cover.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (publication.present) {
      map['publication'] = Variable<int>(publication.value);
    }
    if (totalChapters.present) {
      map['total_chapters'] = Variable<int>(totalChapters.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (coverWidth.present) {
      map['cover_width'] = Variable<double>(coverWidth.value);
    }
    if (coverHeight.present) {
      map['cover_height'] = Variable<double>(coverHeight.value);
    }
    if (coverSizeBytes.present) {
      map['cover_size_bytes'] = Variable<int>(coverSizeBytes.value);
    }
    if (coverMimeType.present) {
      map['cover_mime_type'] = Variable<String>(coverMimeType.value);
    }
    if (coverBlurHash.present) {
      map['cover_blur_hash'] = Variable<String>(coverBlurHash.value);
    }
    if (coverDominantColor.present) {
      map['cover_dominant_color'] = Variable<String>(coverDominantColor.value);
    }
    if (coverPHash.present) {
      map['cover_p_hash'] = Variable<String>(coverPHash.value);
    }
    if (coverEntropy.present) {
      map['cover_entropy'] = Variable<double>(coverEntropy.value);
    }
    if (coverFormatOrigin.present) {
      map['cover_format_origin'] = Variable<String>(coverFormatOrigin.value);
    }
    if (relationsKnown.present) {
      map['relations_known'] = Variable<bool>(relationsKnown.value);
    }
    if (seenAsSafe.present) {
      map['seen_as_safe'] = Variable<bool>(seenAsSafe.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (lastAccessedAt.present) {
      map['last_accessed_at'] = Variable<DateTime>(lastAccessedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedBooksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('cover: $cover, ')
          ..write('type: $type, ')
          ..write('publication: $publication, ')
          ..write('totalChapters: $totalChapters, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('coverWidth: $coverWidth, ')
          ..write('coverHeight: $coverHeight, ')
          ..write('coverSizeBytes: $coverSizeBytes, ')
          ..write('coverMimeType: $coverMimeType, ')
          ..write('coverBlurHash: $coverBlurHash, ')
          ..write('coverDominantColor: $coverDominantColor, ')
          ..write('coverPHash: $coverPHash, ')
          ..write('coverEntropy: $coverEntropy, ')
          ..write('coverFormatOrigin: $coverFormatOrigin, ')
          ..write('relationsKnown: $relationsKnown, ')
          ..write('seenAsSafe: $seenAsSafe, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('lastAccessedAt: $lastAccessedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedAuthorsTable extends CachedAuthors
    with TableInfo<$CachedAuthorsTable, CachedAuthor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedAuthorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_authors';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedAuthor> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedAuthor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedAuthor(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $CachedAuthorsTable createAlias(String alias) {
    return $CachedAuthorsTable(attachedDatabase, alias);
  }
}

class CachedAuthor extends DataClass implements Insertable<CachedAuthor> {
  final String id;
  final String name;
  const CachedAuthor({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  CachedAuthorsCompanion toCompanion(bool nullToAbsent) {
    return CachedAuthorsCompanion(id: Value(id), name: Value(name));
  }

  factory CachedAuthor.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedAuthor(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  CachedAuthor copyWith({String? id, String? name}) =>
      CachedAuthor(id: id ?? this.id, name: name ?? this.name);
  CachedAuthor copyWithCompanion(CachedAuthorsCompanion data) {
    return CachedAuthor(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedAuthor(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedAuthor && other.id == this.id && other.name == this.name);
}

class CachedAuthorsCompanion extends UpdateCompanion<CachedAuthor> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> rowid;
  const CachedAuthorsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedAuthorsCompanion.insert({
    required String id,
    required String name,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<CachedAuthor> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedAuthorsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return CachedAuthorsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedAuthorsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedTagsTable extends CachedTags
    with TableInfo<$CachedTagsTable, CachedTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedTag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $CachedTagsTable createAlias(String alias) {
    return $CachedTagsTable(attachedDatabase, alias);
  }
}

class CachedTag extends DataClass implements Insertable<CachedTag> {
  final String id;
  final String name;
  const CachedTag({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  CachedTagsCompanion toCompanion(bool nullToAbsent) {
    return CachedTagsCompanion(id: Value(id), name: Value(name));
  }

  factory CachedTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedTag(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  CachedTag copyWith({String? id, String? name}) =>
      CachedTag(id: id ?? this.id, name: name ?? this.name);
  CachedTag copyWithCompanion(CachedTagsCompanion data) {
    return CachedTag(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedTag(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedTag && other.id == this.id && other.name == this.name);
}

class CachedTagsCompanion extends UpdateCompanion<CachedTag> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> rowid;
  const CachedTagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedTagsCompanion.insert({
    required String id,
    required String name,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<CachedTag> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedTagsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return CachedTagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedTagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedBookAuthorsTable extends CachedBookAuthors
    with TableInfo<$CachedBookAuthorsTable, CachedBookAuthor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedBookAuthorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorIdMeta = const VerificationMeta(
    'authorId',
  );
  @override
  late final GeneratedColumn<String> authorId = GeneratedColumn<String>(
    'author_id',
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
  @override
  List<GeneratedColumn> get $columns => [bookId, authorId, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_book_authors';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedBookAuthor> instance, {
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
    if (data.containsKey('author_id')) {
      context.handle(
        _authorIdMeta,
        authorId.isAcceptableOrUnknown(data['author_id']!, _authorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_authorIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bookId, authorId};
  @override
  CachedBookAuthor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedBookAuthor(
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      authorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $CachedBookAuthorsTable createAlias(String alias) {
    return $CachedBookAuthorsTable(attachedDatabase, alias);
  }
}

class CachedBookAuthor extends DataClass
    implements Insertable<CachedBookAuthor> {
  final String bookId;
  final String authorId;
  final int position;
  const CachedBookAuthor({
    required this.bookId,
    required this.authorId,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['book_id'] = Variable<String>(bookId);
    map['author_id'] = Variable<String>(authorId);
    map['position'] = Variable<int>(position);
    return map;
  }

  CachedBookAuthorsCompanion toCompanion(bool nullToAbsent) {
    return CachedBookAuthorsCompanion(
      bookId: Value(bookId),
      authorId: Value(authorId),
      position: Value(position),
    );
  }

  factory CachedBookAuthor.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedBookAuthor(
      bookId: serializer.fromJson<String>(json['bookId']),
      authorId: serializer.fromJson<String>(json['authorId']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bookId': serializer.toJson<String>(bookId),
      'authorId': serializer.toJson<String>(authorId),
      'position': serializer.toJson<int>(position),
    };
  }

  CachedBookAuthor copyWith({
    String? bookId,
    String? authorId,
    int? position,
  }) => CachedBookAuthor(
    bookId: bookId ?? this.bookId,
    authorId: authorId ?? this.authorId,
    position: position ?? this.position,
  );
  CachedBookAuthor copyWithCompanion(CachedBookAuthorsCompanion data) {
    return CachedBookAuthor(
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      authorId: data.authorId.present ? data.authorId.value : this.authorId,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedBookAuthor(')
          ..write('bookId: $bookId, ')
          ..write('authorId: $authorId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(bookId, authorId, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedBookAuthor &&
          other.bookId == this.bookId &&
          other.authorId == this.authorId &&
          other.position == this.position);
}

class CachedBookAuthorsCompanion extends UpdateCompanion<CachedBookAuthor> {
  final Value<String> bookId;
  final Value<String> authorId;
  final Value<int> position;
  final Value<int> rowid;
  const CachedBookAuthorsCompanion({
    this.bookId = const Value.absent(),
    this.authorId = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedBookAuthorsCompanion.insert({
    required String bookId,
    required String authorId,
    required int position,
    this.rowid = const Value.absent(),
  }) : bookId = Value(bookId),
       authorId = Value(authorId),
       position = Value(position);
  static Insertable<CachedBookAuthor> custom({
    Expression<String>? bookId,
    Expression<String>? authorId,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bookId != null) 'book_id': bookId,
      if (authorId != null) 'author_id': authorId,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedBookAuthorsCompanion copyWith({
    Value<String>? bookId,
    Value<String>? authorId,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return CachedBookAuthorsCompanion(
      bookId: bookId ?? this.bookId,
      authorId: authorId ?? this.authorId,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (authorId.present) {
      map['author_id'] = Variable<String>(authorId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedBookAuthorsCompanion(')
          ..write('bookId: $bookId, ')
          ..write('authorId: $authorId, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedBookTagsTable extends CachedBookTags
    with TableInfo<$CachedBookTagsTable, CachedBookTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedBookTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
    'tag_id',
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
  @override
  List<GeneratedColumn> get $columns => [bookId, tagId, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_book_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedBookTag> instance, {
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
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bookId, tagId};
  @override
  CachedBookTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedBookTag(
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $CachedBookTagsTable createAlias(String alias) {
    return $CachedBookTagsTable(attachedDatabase, alias);
  }
}

class CachedBookTag extends DataClass implements Insertable<CachedBookTag> {
  final String bookId;
  final String tagId;
  final int position;
  const CachedBookTag({
    required this.bookId,
    required this.tagId,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['book_id'] = Variable<String>(bookId);
    map['tag_id'] = Variable<String>(tagId);
    map['position'] = Variable<int>(position);
    return map;
  }

  CachedBookTagsCompanion toCompanion(bool nullToAbsent) {
    return CachedBookTagsCompanion(
      bookId: Value(bookId),
      tagId: Value(tagId),
      position: Value(position),
    );
  }

  factory CachedBookTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedBookTag(
      bookId: serializer.fromJson<String>(json['bookId']),
      tagId: serializer.fromJson<String>(json['tagId']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bookId': serializer.toJson<String>(bookId),
      'tagId': serializer.toJson<String>(tagId),
      'position': serializer.toJson<int>(position),
    };
  }

  CachedBookTag copyWith({String? bookId, String? tagId, int? position}) =>
      CachedBookTag(
        bookId: bookId ?? this.bookId,
        tagId: tagId ?? this.tagId,
        position: position ?? this.position,
      );
  CachedBookTag copyWithCompanion(CachedBookTagsCompanion data) {
    return CachedBookTag(
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedBookTag(')
          ..write('bookId: $bookId, ')
          ..write('tagId: $tagId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(bookId, tagId, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedBookTag &&
          other.bookId == this.bookId &&
          other.tagId == this.tagId &&
          other.position == this.position);
}

class CachedBookTagsCompanion extends UpdateCompanion<CachedBookTag> {
  final Value<String> bookId;
  final Value<String> tagId;
  final Value<int> position;
  final Value<int> rowid;
  const CachedBookTagsCompanion({
    this.bookId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedBookTagsCompanion.insert({
    required String bookId,
    required String tagId,
    required int position,
    this.rowid = const Value.absent(),
  }) : bookId = Value(bookId),
       tagId = Value(tagId),
       position = Value(position);
  static Insertable<CachedBookTag> custom({
    Expression<String>? bookId,
    Expression<String>? tagId,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bookId != null) 'book_id': bookId,
      if (tagId != null) 'tag_id': tagId,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedBookTagsCompanion copyWith({
    Value<String>? bookId,
    Value<String>? tagId,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return CachedBookTagsCompanion(
      bookId: bookId ?? this.bookId,
      tagId: tagId ?? this.tagId,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedBookTagsCompanion(')
          ..write('bookId: $bookId, ')
          ..write('tagId: $tagId, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedBookSensitiveContentsTable extends CachedBookSensitiveContents
    with
        TableInfo<
          $CachedBookSensitiveContentsTable,
          CachedBookSensitiveContent
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedBookSensitiveContentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [bookId, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_book_sensitive_contents';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedBookSensitiveContent> instance, {
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
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bookId, name};
  @override
  CachedBookSensitiveContent map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedBookSensitiveContent(
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $CachedBookSensitiveContentsTable createAlias(String alias) {
    return $CachedBookSensitiveContentsTable(attachedDatabase, alias);
  }
}

class CachedBookSensitiveContent extends DataClass
    implements Insertable<CachedBookSensitiveContent> {
  final String bookId;
  final String name;
  const CachedBookSensitiveContent({required this.bookId, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['book_id'] = Variable<String>(bookId);
    map['name'] = Variable<String>(name);
    return map;
  }

  CachedBookSensitiveContentsCompanion toCompanion(bool nullToAbsent) {
    return CachedBookSensitiveContentsCompanion(
      bookId: Value(bookId),
      name: Value(name),
    );
  }

  factory CachedBookSensitiveContent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedBookSensitiveContent(
      bookId: serializer.fromJson<String>(json['bookId']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bookId': serializer.toJson<String>(bookId),
      'name': serializer.toJson<String>(name),
    };
  }

  CachedBookSensitiveContent copyWith({String? bookId, String? name}) =>
      CachedBookSensitiveContent(
        bookId: bookId ?? this.bookId,
        name: name ?? this.name,
      );
  CachedBookSensitiveContent copyWithCompanion(
    CachedBookSensitiveContentsCompanion data,
  ) {
    return CachedBookSensitiveContent(
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedBookSensitiveContent(')
          ..write('bookId: $bookId, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(bookId, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedBookSensitiveContent &&
          other.bookId == this.bookId &&
          other.name == this.name);
}

class CachedBookSensitiveContentsCompanion
    extends UpdateCompanion<CachedBookSensitiveContent> {
  final Value<String> bookId;
  final Value<String> name;
  final Value<int> rowid;
  const CachedBookSensitiveContentsCompanion({
    this.bookId = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedBookSensitiveContentsCompanion.insert({
    required String bookId,
    required String name,
    this.rowid = const Value.absent(),
  }) : bookId = Value(bookId),
       name = Value(name);
  static Insertable<CachedBookSensitiveContent> custom({
    Expression<String>? bookId,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bookId != null) 'book_id': bookId,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedBookSensitiveContentsCompanion copyWith({
    Value<String>? bookId,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return CachedBookSensitiveContentsCompanion(
      bookId: bookId ?? this.bookId,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedBookSensitiveContentsCompanion(')
          ..write('bookId: $bookId, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedBookSensitiveProvenanceTable extends CachedBookSensitiveProvenance
    with
        TableInfo<
          $CachedBookSensitiveProvenanceTable,
          CachedBookSensitiveProvenanceData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedBookSensitiveProvenanceTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [bookId, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_book_sensitive_provenance';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedBookSensitiveProvenanceData> instance, {
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
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bookId, name};
  @override
  CachedBookSensitiveProvenanceData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedBookSensitiveProvenanceData(
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $CachedBookSensitiveProvenanceTable createAlias(String alias) {
    return $CachedBookSensitiveProvenanceTable(attachedDatabase, alias);
  }
}

class CachedBookSensitiveProvenanceData extends DataClass
    implements Insertable<CachedBookSensitiveProvenanceData> {
  final String bookId;
  final String name;
  const CachedBookSensitiveProvenanceData({
    required this.bookId,
    required this.name,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['book_id'] = Variable<String>(bookId);
    map['name'] = Variable<String>(name);
    return map;
  }

  CachedBookSensitiveProvenanceCompanion toCompanion(bool nullToAbsent) {
    return CachedBookSensitiveProvenanceCompanion(
      bookId: Value(bookId),
      name: Value(name),
    );
  }

  factory CachedBookSensitiveProvenanceData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedBookSensitiveProvenanceData(
      bookId: serializer.fromJson<String>(json['bookId']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bookId': serializer.toJson<String>(bookId),
      'name': serializer.toJson<String>(name),
    };
  }

  CachedBookSensitiveProvenanceData copyWith({String? bookId, String? name}) =>
      CachedBookSensitiveProvenanceData(
        bookId: bookId ?? this.bookId,
        name: name ?? this.name,
      );
  CachedBookSensitiveProvenanceData copyWithCompanion(
    CachedBookSensitiveProvenanceCompanion data,
  ) {
    return CachedBookSensitiveProvenanceData(
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedBookSensitiveProvenanceData(')
          ..write('bookId: $bookId, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(bookId, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedBookSensitiveProvenanceData &&
          other.bookId == this.bookId &&
          other.name == this.name);
}

class CachedBookSensitiveProvenanceCompanion
    extends UpdateCompanion<CachedBookSensitiveProvenanceData> {
  final Value<String> bookId;
  final Value<String> name;
  final Value<int> rowid;
  const CachedBookSensitiveProvenanceCompanion({
    this.bookId = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedBookSensitiveProvenanceCompanion.insert({
    required String bookId,
    required String name,
    this.rowid = const Value.absent(),
  }) : bookId = Value(bookId),
       name = Value(name);
  static Insertable<CachedBookSensitiveProvenanceData> custom({
    Expression<String>? bookId,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bookId != null) 'book_id': bookId,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedBookSensitiveProvenanceCompanion copyWith({
    Value<String>? bookId,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return CachedBookSensitiveProvenanceCompanion(
      bookId: bookId ?? this.bookId,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedBookSensitiveProvenanceCompanion(')
          ..write('bookId: $bookId, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedChaptersTable extends CachedChapters
    with TableInfo<$CachedChaptersTable, CachedChapter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedChaptersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chapterIndexMeta = const VerificationMeta(
    'chapterIndex',
  );
  @override
  late final GeneratedColumn<double> chapterIndex = GeneratedColumn<double>(
    'chapter_index',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scrapingStatusMeta = const VerificationMeta(
    'scrapingStatus',
  );
  @override
  late final GeneratedColumn<String> scrapingStatus = GeneratedColumn<String>(
    'scraping_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _readMeta = const VerificationMeta('read');
  @override
  late final GeneratedColumn<bool> read = GeneratedColumn<bool>(
    'read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  static const VerificationMeta _lastPageMeta = const VerificationMeta(
    'lastPage',
  );
  @override
  late final GeneratedColumn<int> lastPage = GeneratedColumn<int>(
    'last_page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    title,
    chapterIndex,
    scrapingStatus,
    read,
    completed,
    lastPage,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_chapters';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedChapter> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('chapter_index')) {
      context.handle(
        _chapterIndexMeta,
        chapterIndex.isAcceptableOrUnknown(
          data['chapter_index']!,
          _chapterIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chapterIndexMeta);
    }
    if (data.containsKey('scraping_status')) {
      context.handle(
        _scrapingStatusMeta,
        scrapingStatus.isAcceptableOrUnknown(
          data['scraping_status']!,
          _scrapingStatusMeta,
        ),
      );
    }
    if (data.containsKey('read')) {
      context.handle(
        _readMeta,
        read.isAcceptableOrUnknown(data['read']!, _readMeta),
      );
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    if (data.containsKey('last_page')) {
      context.handle(
        _lastPageMeta,
        lastPage.isAcceptableOrUnknown(data['last_page']!, _lastPageMeta),
      );
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedChapter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedChapter(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      chapterIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}chapter_index'],
      )!,
      scrapingStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scraping_status'],
      ),
      read: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}read'],
      )!,
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
      lastPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_page'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $CachedChaptersTable createAlias(String alias) {
    return $CachedChaptersTable(attachedDatabase, alias);
  }
}

class CachedChapter extends DataClass implements Insertable<CachedChapter> {
  final String id;
  final String bookId;
  final String? title;
  final double chapterIndex;
  final String? scrapingStatus;
  final bool read;
  final bool completed;
  final int lastPage;
  final DateTime cachedAt;
  const CachedChapter({
    required this.id,
    required this.bookId,
    this.title,
    required this.chapterIndex,
    this.scrapingStatus,
    required this.read,
    required this.completed,
    required this.lastPage,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['book_id'] = Variable<String>(bookId);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    map['chapter_index'] = Variable<double>(chapterIndex);
    if (!nullToAbsent || scrapingStatus != null) {
      map['scraping_status'] = Variable<String>(scrapingStatus);
    }
    map['read'] = Variable<bool>(read);
    map['completed'] = Variable<bool>(completed);
    map['last_page'] = Variable<int>(lastPage);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CachedChaptersCompanion toCompanion(bool nullToAbsent) {
    return CachedChaptersCompanion(
      id: Value(id),
      bookId: Value(bookId),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      chapterIndex: Value(chapterIndex),
      scrapingStatus: scrapingStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(scrapingStatus),
      read: Value(read),
      completed: Value(completed),
      lastPage: Value(lastPage),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedChapter.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedChapter(
      id: serializer.fromJson<String>(json['id']),
      bookId: serializer.fromJson<String>(json['bookId']),
      title: serializer.fromJson<String?>(json['title']),
      chapterIndex: serializer.fromJson<double>(json['chapterIndex']),
      scrapingStatus: serializer.fromJson<String?>(json['scrapingStatus']),
      read: serializer.fromJson<bool>(json['read']),
      completed: serializer.fromJson<bool>(json['completed']),
      lastPage: serializer.fromJson<int>(json['lastPage']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bookId': serializer.toJson<String>(bookId),
      'title': serializer.toJson<String?>(title),
      'chapterIndex': serializer.toJson<double>(chapterIndex),
      'scrapingStatus': serializer.toJson<String?>(scrapingStatus),
      'read': serializer.toJson<bool>(read),
      'completed': serializer.toJson<bool>(completed),
      'lastPage': serializer.toJson<int>(lastPage),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CachedChapter copyWith({
    String? id,
    String? bookId,
    Value<String?> title = const Value.absent(),
    double? chapterIndex,
    Value<String?> scrapingStatus = const Value.absent(),
    bool? read,
    bool? completed,
    int? lastPage,
    DateTime? cachedAt,
  }) => CachedChapter(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    title: title.present ? title.value : this.title,
    chapterIndex: chapterIndex ?? this.chapterIndex,
    scrapingStatus: scrapingStatus.present
        ? scrapingStatus.value
        : this.scrapingStatus,
    read: read ?? this.read,
    completed: completed ?? this.completed,
    lastPage: lastPage ?? this.lastPage,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  CachedChapter copyWithCompanion(CachedChaptersCompanion data) {
    return CachedChapter(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      title: data.title.present ? data.title.value : this.title,
      chapterIndex: data.chapterIndex.present
          ? data.chapterIndex.value
          : this.chapterIndex,
      scrapingStatus: data.scrapingStatus.present
          ? data.scrapingStatus.value
          : this.scrapingStatus,
      read: data.read.present ? data.read.value : this.read,
      completed: data.completed.present ? data.completed.value : this.completed,
      lastPage: data.lastPage.present ? data.lastPage.value : this.lastPage,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedChapter(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('title: $title, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('scrapingStatus: $scrapingStatus, ')
          ..write('read: $read, ')
          ..write('completed: $completed, ')
          ..write('lastPage: $lastPage, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bookId,
    title,
    chapterIndex,
    scrapingStatus,
    read,
    completed,
    lastPage,
    cachedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedChapter &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.title == this.title &&
          other.chapterIndex == this.chapterIndex &&
          other.scrapingStatus == this.scrapingStatus &&
          other.read == this.read &&
          other.completed == this.completed &&
          other.lastPage == this.lastPage &&
          other.cachedAt == this.cachedAt);
}

class CachedChaptersCompanion extends UpdateCompanion<CachedChapter> {
  final Value<String> id;
  final Value<String> bookId;
  final Value<String?> title;
  final Value<double> chapterIndex;
  final Value<String?> scrapingStatus;
  final Value<bool> read;
  final Value<bool> completed;
  final Value<int> lastPage;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const CachedChaptersCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.title = const Value.absent(),
    this.chapterIndex = const Value.absent(),
    this.scrapingStatus = const Value.absent(),
    this.read = const Value.absent(),
    this.completed = const Value.absent(),
    this.lastPage = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedChaptersCompanion.insert({
    required String id,
    required String bookId,
    this.title = const Value.absent(),
    required double chapterIndex,
    this.scrapingStatus = const Value.absent(),
    this.read = const Value.absent(),
    this.completed = const Value.absent(),
    this.lastPage = const Value.absent(),
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       bookId = Value(bookId),
       chapterIndex = Value(chapterIndex),
       cachedAt = Value(cachedAt);
  static Insertable<CachedChapter> custom({
    Expression<String>? id,
    Expression<String>? bookId,
    Expression<String>? title,
    Expression<double>? chapterIndex,
    Expression<String>? scrapingStatus,
    Expression<bool>? read,
    Expression<bool>? completed,
    Expression<int>? lastPage,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (title != null) 'title': title,
      if (chapterIndex != null) 'chapter_index': chapterIndex,
      if (scrapingStatus != null) 'scraping_status': scrapingStatus,
      if (read != null) 'read': read,
      if (completed != null) 'completed': completed,
      if (lastPage != null) 'last_page': lastPage,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedChaptersCompanion copyWith({
    Value<String>? id,
    Value<String>? bookId,
    Value<String?>? title,
    Value<double>? chapterIndex,
    Value<String?>? scrapingStatus,
    Value<bool>? read,
    Value<bool>? completed,
    Value<int>? lastPage,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return CachedChaptersCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      title: title ?? this.title,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      scrapingStatus: scrapingStatus ?? this.scrapingStatus,
      read: read ?? this.read,
      completed: completed ?? this.completed,
      lastPage: lastPage ?? this.lastPage,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (chapterIndex.present) {
      map['chapter_index'] = Variable<double>(chapterIndex.value);
    }
    if (scrapingStatus.present) {
      map['scraping_status'] = Variable<String>(scrapingStatus.value);
    }
    if (read.present) {
      map['read'] = Variable<bool>(read.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (lastPage.present) {
      map['last_page'] = Variable<int>(lastPage.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedChaptersCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('title: $title, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('scrapingStatus: $scrapingStatus, ')
          ..write('read: $read, ')
          ..write('completed: $completed, ')
          ..write('lastPage: $lastPage, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedCoversTable extends CachedCovers
    with TableInfo<$CachedCoversTable, CachedCover> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedCoversTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceUrlMeta = const VerificationMeta(
    'sourceUrl',
  );
  @override
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
    'source_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bytesMeta = const VerificationMeta('bytes');
  @override
  late final GeneratedColumn<int> bytes = GeneratedColumn<int>(
    'bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastUsedAtMeta = const VerificationMeta(
    'lastUsedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastUsedAt = GeneratedColumn<DateTime>(
    'last_used_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    bookId,
    sourceUrl,
    filePath,
    bytes,
    fetchedAt,
    lastUsedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_covers';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedCover> instance, {
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
    if (data.containsKey('source_url')) {
      context.handle(
        _sourceUrlMeta,
        sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceUrlMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('bytes')) {
      context.handle(
        _bytesMeta,
        bytes.isAcceptableOrUnknown(data['bytes']!, _bytesMeta),
      );
    } else if (isInserting) {
      context.missing(_bytesMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    if (data.containsKey('last_used_at')) {
      context.handle(
        _lastUsedAtMeta,
        lastUsedAt.isAcceptableOrUnknown(
          data['last_used_at']!,
          _lastUsedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastUsedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bookId};
  @override
  CachedCover map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedCover(
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      sourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_url'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      bytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bytes'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
      lastUsedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_used_at'],
      )!,
    );
  }

  @override
  $CachedCoversTable createAlias(String alias) {
    return $CachedCoversTable(attachedDatabase, alias);
  }
}

class CachedCover extends DataClass implements Insertable<CachedCover> {
  final String bookId;
  final String sourceUrl;
  final String filePath;
  final int bytes;
  final DateTime fetchedAt;
  final DateTime lastUsedAt;
  const CachedCover({
    required this.bookId,
    required this.sourceUrl,
    required this.filePath,
    required this.bytes,
    required this.fetchedAt,
    required this.lastUsedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['book_id'] = Variable<String>(bookId);
    map['source_url'] = Variable<String>(sourceUrl);
    map['file_path'] = Variable<String>(filePath);
    map['bytes'] = Variable<int>(bytes);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    map['last_used_at'] = Variable<DateTime>(lastUsedAt);
    return map;
  }

  CachedCoversCompanion toCompanion(bool nullToAbsent) {
    return CachedCoversCompanion(
      bookId: Value(bookId),
      sourceUrl: Value(sourceUrl),
      filePath: Value(filePath),
      bytes: Value(bytes),
      fetchedAt: Value(fetchedAt),
      lastUsedAt: Value(lastUsedAt),
    );
  }

  factory CachedCover.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedCover(
      bookId: serializer.fromJson<String>(json['bookId']),
      sourceUrl: serializer.fromJson<String>(json['sourceUrl']),
      filePath: serializer.fromJson<String>(json['filePath']),
      bytes: serializer.fromJson<int>(json['bytes']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
      lastUsedAt: serializer.fromJson<DateTime>(json['lastUsedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bookId': serializer.toJson<String>(bookId),
      'sourceUrl': serializer.toJson<String>(sourceUrl),
      'filePath': serializer.toJson<String>(filePath),
      'bytes': serializer.toJson<int>(bytes),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
      'lastUsedAt': serializer.toJson<DateTime>(lastUsedAt),
    };
  }

  CachedCover copyWith({
    String? bookId,
    String? sourceUrl,
    String? filePath,
    int? bytes,
    DateTime? fetchedAt,
    DateTime? lastUsedAt,
  }) => CachedCover(
    bookId: bookId ?? this.bookId,
    sourceUrl: sourceUrl ?? this.sourceUrl,
    filePath: filePath ?? this.filePath,
    bytes: bytes ?? this.bytes,
    fetchedAt: fetchedAt ?? this.fetchedAt,
    lastUsedAt: lastUsedAt ?? this.lastUsedAt,
  );
  CachedCover copyWithCompanion(CachedCoversCompanion data) {
    return CachedCover(
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      bytes: data.bytes.present ? data.bytes.value : this.bytes,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
      lastUsedAt: data.lastUsedAt.present
          ? data.lastUsedAt.value
          : this.lastUsedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedCover(')
          ..write('bookId: $bookId, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('filePath: $filePath, ')
          ..write('bytes: $bytes, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('lastUsedAt: $lastUsedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(bookId, sourceUrl, filePath, bytes, fetchedAt, lastUsedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedCover &&
          other.bookId == this.bookId &&
          other.sourceUrl == this.sourceUrl &&
          other.filePath == this.filePath &&
          other.bytes == this.bytes &&
          other.fetchedAt == this.fetchedAt &&
          other.lastUsedAt == this.lastUsedAt);
}

class CachedCoversCompanion extends UpdateCompanion<CachedCover> {
  final Value<String> bookId;
  final Value<String> sourceUrl;
  final Value<String> filePath;
  final Value<int> bytes;
  final Value<DateTime> fetchedAt;
  final Value<DateTime> lastUsedAt;
  final Value<int> rowid;
  const CachedCoversCompanion({
    this.bookId = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.filePath = const Value.absent(),
    this.bytes = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedCoversCompanion.insert({
    required String bookId,
    required String sourceUrl,
    required String filePath,
    required int bytes,
    required DateTime fetchedAt,
    required DateTime lastUsedAt,
    this.rowid = const Value.absent(),
  }) : bookId = Value(bookId),
       sourceUrl = Value(sourceUrl),
       filePath = Value(filePath),
       bytes = Value(bytes),
       fetchedAt = Value(fetchedAt),
       lastUsedAt = Value(lastUsedAt);
  static Insertable<CachedCover> custom({
    Expression<String>? bookId,
    Expression<String>? sourceUrl,
    Expression<String>? filePath,
    Expression<int>? bytes,
    Expression<DateTime>? fetchedAt,
    Expression<DateTime>? lastUsedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bookId != null) 'book_id': bookId,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (filePath != null) 'file_path': filePath,
      if (bytes != null) 'bytes': bytes,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (lastUsedAt != null) 'last_used_at': lastUsedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedCoversCompanion copyWith({
    Value<String>? bookId,
    Value<String>? sourceUrl,
    Value<String>? filePath,
    Value<int>? bytes,
    Value<DateTime>? fetchedAt,
    Value<DateTime>? lastUsedAt,
    Value<int>? rowid,
  }) {
    return CachedCoversCompanion(
      bookId: bookId ?? this.bookId,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      filePath: filePath ?? this.filePath,
      bytes: bytes ?? this.bytes,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (bytes.present) {
      map['bytes'] = Variable<int>(bytes.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (lastUsedAt.present) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedCoversCompanion(')
          ..write('bookId: $bookId, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('filePath: $filePath, ')
          ..write('bytes: $bytes, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CoverPinsTable extends CoverPins
    with TableInfo<$CoverPinsTable, CoverPin> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CoverPinsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerMeta = const VerificationMeta('owner');
  @override
  late final GeneratedColumn<String> owner = GeneratedColumn<String>(
    'owner',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [bookId, owner];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cover_pins';
  @override
  VerificationContext validateIntegrity(
    Insertable<CoverPin> instance, {
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
    if (data.containsKey('owner')) {
      context.handle(
        _ownerMeta,
        owner.isAcceptableOrUnknown(data['owner']!, _ownerMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bookId, owner};
  @override
  CoverPin map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CoverPin(
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      owner: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner'],
      )!,
    );
  }

  @override
  $CoverPinsTable createAlias(String alias) {
    return $CoverPinsTable(attachedDatabase, alias);
  }
}

class CoverPin extends DataClass implements Insertable<CoverPin> {
  final String bookId;
  final String owner;
  const CoverPin({required this.bookId, required this.owner});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['book_id'] = Variable<String>(bookId);
    map['owner'] = Variable<String>(owner);
    return map;
  }

  CoverPinsCompanion toCompanion(bool nullToAbsent) {
    return CoverPinsCompanion(bookId: Value(bookId), owner: Value(owner));
  }

  factory CoverPin.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CoverPin(
      bookId: serializer.fromJson<String>(json['bookId']),
      owner: serializer.fromJson<String>(json['owner']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bookId': serializer.toJson<String>(bookId),
      'owner': serializer.toJson<String>(owner),
    };
  }

  CoverPin copyWith({String? bookId, String? owner}) =>
      CoverPin(bookId: bookId ?? this.bookId, owner: owner ?? this.owner);
  CoverPin copyWithCompanion(CoverPinsCompanion data) {
    return CoverPin(
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      owner: data.owner.present ? data.owner.value : this.owner,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CoverPin(')
          ..write('bookId: $bookId, ')
          ..write('owner: $owner')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(bookId, owner);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CoverPin &&
          other.bookId == this.bookId &&
          other.owner == this.owner);
}

class CoverPinsCompanion extends UpdateCompanion<CoverPin> {
  final Value<String> bookId;
  final Value<String> owner;
  final Value<int> rowid;
  const CoverPinsCompanion({
    this.bookId = const Value.absent(),
    this.owner = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CoverPinsCompanion.insert({
    required String bookId,
    required String owner,
    this.rowid = const Value.absent(),
  }) : bookId = Value(bookId),
       owner = Value(owner);
  static Insertable<CoverPin> custom({
    Expression<String>? bookId,
    Expression<String>? owner,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bookId != null) 'book_id': bookId,
      if (owner != null) 'owner': owner,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CoverPinsCompanion copyWith({
    Value<String>? bookId,
    Value<String>? owner,
    Value<int>? rowid,
  }) {
    return CoverPinsCompanion(
      bookId: bookId ?? this.bookId,
      owner: owner ?? this.owner,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (owner.present) {
      map['owner'] = Variable<String>(owner.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CoverPinsCompanion(')
          ..write('bookId: $bookId, ')
          ..write('owner: $owner, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$OfflineCacheDatabase extends GeneratedDatabase {
  _$OfflineCacheDatabase(QueryExecutor e) : super(e);
  $OfflineCacheDatabaseManager get managers =>
      $OfflineCacheDatabaseManager(this);
  late final $CachedBooksTable cachedBooks = $CachedBooksTable(this);
  late final $CachedAuthorsTable cachedAuthors = $CachedAuthorsTable(this);
  late final $CachedTagsTable cachedTags = $CachedTagsTable(this);
  late final $CachedBookAuthorsTable cachedBookAuthors =
      $CachedBookAuthorsTable(this);
  late final $CachedBookTagsTable cachedBookTags = $CachedBookTagsTable(this);
  late final $CachedBookSensitiveContentsTable cachedBookSensitiveContents =
      $CachedBookSensitiveContentsTable(this);
  late final $CachedBookSensitiveProvenanceTable cachedBookSensitiveProvenance =
      $CachedBookSensitiveProvenanceTable(this);
  late final $CachedChaptersTable cachedChapters = $CachedChaptersTable(this);
  late final $CachedCoversTable cachedCovers = $CachedCoversTable(this);
  late final $CoverPinsTable coverPins = $CoverPinsTable(this);
  late final Index idxCachedBooksCover = Index(
    'idx_cached_books_cover',
    'CREATE INDEX idx_cached_books_cover ON cached_books (cover)',
  );
  late final Index idxCachedBooksAccessed = Index(
    'idx_cached_books_accessed',
    'CREATE INDEX idx_cached_books_accessed ON cached_books (last_accessed_at)',
  );
  late final Index idxCachedBookAuthorsAuthor = Index(
    'idx_cached_book_authors_author',
    'CREATE INDEX idx_cached_book_authors_author ON cached_book_authors (author_id)',
  );
  late final Index idxCachedBookTagsTag = Index(
    'idx_cached_book_tags_tag',
    'CREATE INDEX idx_cached_book_tags_tag ON cached_book_tags (tag_id)',
  );
  late final Index idxCachedChaptersBook = Index(
    'idx_cached_chapters_book',
    'CREATE INDEX idx_cached_chapters_book ON cached_chapters (book_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cachedBooks,
    cachedAuthors,
    cachedTags,
    cachedBookAuthors,
    cachedBookTags,
    cachedBookSensitiveContents,
    cachedBookSensitiveProvenance,
    cachedChapters,
    cachedCovers,
    coverPins,
    idxCachedBooksCover,
    idxCachedBooksAccessed,
    idxCachedBookAuthorsAuthor,
    idxCachedBookTagsTag,
    idxCachedChaptersBook,
  ];
}

typedef $$CachedBooksTableCreateCompanionBuilder =
    CachedBooksCompanion Function({
      required String id,
      required String title,
      Value<String?> description,
      Value<String?> cover,
      Value<String?> type,
      Value<int?> publication,
      Value<int?> totalChapters,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<double?> coverWidth,
      Value<double?> coverHeight,
      Value<int?> coverSizeBytes,
      Value<String?> coverMimeType,
      Value<String?> coverBlurHash,
      Value<String?> coverDominantColor,
      Value<String?> coverPHash,
      Value<double?> coverEntropy,
      Value<String?> coverFormatOrigin,
      Value<bool> relationsKnown,
      Value<bool> seenAsSafe,
      required DateTime cachedAt,
      required DateTime lastAccessedAt,
      Value<int> rowid,
    });
typedef $$CachedBooksTableUpdateCompanionBuilder =
    CachedBooksCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> description,
      Value<String?> cover,
      Value<String?> type,
      Value<int?> publication,
      Value<int?> totalChapters,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<double?> coverWidth,
      Value<double?> coverHeight,
      Value<int?> coverSizeBytes,
      Value<String?> coverMimeType,
      Value<String?> coverBlurHash,
      Value<String?> coverDominantColor,
      Value<String?> coverPHash,
      Value<double?> coverEntropy,
      Value<String?> coverFormatOrigin,
      Value<bool> relationsKnown,
      Value<bool> seenAsSafe,
      Value<DateTime> cachedAt,
      Value<DateTime> lastAccessedAt,
      Value<int> rowid,
    });

class $$CachedBooksTableFilterComposer
    extends Composer<_$OfflineCacheDatabase, $CachedBooksTable> {
  $$CachedBooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cover => $composableBuilder(
    column: $table.cover,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get publication => $composableBuilder(
    column: $table.publication,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalChapters => $composableBuilder(
    column: $table.totalChapters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get coverWidth => $composableBuilder(
    column: $table.coverWidth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get coverHeight => $composableBuilder(
    column: $table.coverHeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get coverSizeBytes => $composableBuilder(
    column: $table.coverSizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverMimeType => $composableBuilder(
    column: $table.coverMimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverBlurHash => $composableBuilder(
    column: $table.coverBlurHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverDominantColor => $composableBuilder(
    column: $table.coverDominantColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverPHash => $composableBuilder(
    column: $table.coverPHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get coverEntropy => $composableBuilder(
    column: $table.coverEntropy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverFormatOrigin => $composableBuilder(
    column: $table.coverFormatOrigin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get relationsKnown => $composableBuilder(
    column: $table.relationsKnown,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get seenAsSafe => $composableBuilder(
    column: $table.seenAsSafe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedBooksTableOrderingComposer
    extends Composer<_$OfflineCacheDatabase, $CachedBooksTable> {
  $$CachedBooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cover => $composableBuilder(
    column: $table.cover,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get publication => $composableBuilder(
    column: $table.publication,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalChapters => $composableBuilder(
    column: $table.totalChapters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get coverWidth => $composableBuilder(
    column: $table.coverWidth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get coverHeight => $composableBuilder(
    column: $table.coverHeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get coverSizeBytes => $composableBuilder(
    column: $table.coverSizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverMimeType => $composableBuilder(
    column: $table.coverMimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverBlurHash => $composableBuilder(
    column: $table.coverBlurHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverDominantColor => $composableBuilder(
    column: $table.coverDominantColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverPHash => $composableBuilder(
    column: $table.coverPHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get coverEntropy => $composableBuilder(
    column: $table.coverEntropy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverFormatOrigin => $composableBuilder(
    column: $table.coverFormatOrigin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get relationsKnown => $composableBuilder(
    column: $table.relationsKnown,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get seenAsSafe => $composableBuilder(
    column: $table.seenAsSafe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedBooksTableAnnotationComposer
    extends Composer<_$OfflineCacheDatabase, $CachedBooksTable> {
  $$CachedBooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cover =>
      $composableBuilder(column: $table.cover, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get publication => $composableBuilder(
    column: $table.publication,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalChapters => $composableBuilder(
    column: $table.totalChapters,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<double> get coverWidth => $composableBuilder(
    column: $table.coverWidth,
    builder: (column) => column,
  );

  GeneratedColumn<double> get coverHeight => $composableBuilder(
    column: $table.coverHeight,
    builder: (column) => column,
  );

  GeneratedColumn<int> get coverSizeBytes => $composableBuilder(
    column: $table.coverSizeBytes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverMimeType => $composableBuilder(
    column: $table.coverMimeType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverBlurHash => $composableBuilder(
    column: $table.coverBlurHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverDominantColor => $composableBuilder(
    column: $table.coverDominantColor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverPHash => $composableBuilder(
    column: $table.coverPHash,
    builder: (column) => column,
  );

  GeneratedColumn<double> get coverEntropy => $composableBuilder(
    column: $table.coverEntropy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverFormatOrigin => $composableBuilder(
    column: $table.coverFormatOrigin,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get relationsKnown => $composableBuilder(
    column: $table.relationsKnown,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get seenAsSafe => $composableBuilder(
    column: $table.seenAsSafe,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => column,
  );
}

class $$CachedBooksTableTableManager
    extends
        RootTableManager<
          _$OfflineCacheDatabase,
          $CachedBooksTable,
          CachedBook,
          $$CachedBooksTableFilterComposer,
          $$CachedBooksTableOrderingComposer,
          $$CachedBooksTableAnnotationComposer,
          $$CachedBooksTableCreateCompanionBuilder,
          $$CachedBooksTableUpdateCompanionBuilder,
          (
            CachedBook,
            BaseReferences<
              _$OfflineCacheDatabase,
              $CachedBooksTable,
              CachedBook
            >,
          ),
          CachedBook,
          PrefetchHooks Function()
        > {
  $$CachedBooksTableTableManager(
    _$OfflineCacheDatabase db,
    $CachedBooksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedBooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedBooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedBooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> cover = const Value.absent(),
                Value<String?> type = const Value.absent(),
                Value<int?> publication = const Value.absent(),
                Value<int?> totalChapters = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<double?> coverWidth = const Value.absent(),
                Value<double?> coverHeight = const Value.absent(),
                Value<int?> coverSizeBytes = const Value.absent(),
                Value<String?> coverMimeType = const Value.absent(),
                Value<String?> coverBlurHash = const Value.absent(),
                Value<String?> coverDominantColor = const Value.absent(),
                Value<String?> coverPHash = const Value.absent(),
                Value<double?> coverEntropy = const Value.absent(),
                Value<String?> coverFormatOrigin = const Value.absent(),
                Value<bool> relationsKnown = const Value.absent(),
                Value<bool> seenAsSafe = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<DateTime> lastAccessedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedBooksCompanion(
                id: id,
                title: title,
                description: description,
                cover: cover,
                type: type,
                publication: publication,
                totalChapters: totalChapters,
                createdAt: createdAt,
                updatedAt: updatedAt,
                coverWidth: coverWidth,
                coverHeight: coverHeight,
                coverSizeBytes: coverSizeBytes,
                coverMimeType: coverMimeType,
                coverBlurHash: coverBlurHash,
                coverDominantColor: coverDominantColor,
                coverPHash: coverPHash,
                coverEntropy: coverEntropy,
                coverFormatOrigin: coverFormatOrigin,
                relationsKnown: relationsKnown,
                seenAsSafe: seenAsSafe,
                cachedAt: cachedAt,
                lastAccessedAt: lastAccessedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> description = const Value.absent(),
                Value<String?> cover = const Value.absent(),
                Value<String?> type = const Value.absent(),
                Value<int?> publication = const Value.absent(),
                Value<int?> totalChapters = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<double?> coverWidth = const Value.absent(),
                Value<double?> coverHeight = const Value.absent(),
                Value<int?> coverSizeBytes = const Value.absent(),
                Value<String?> coverMimeType = const Value.absent(),
                Value<String?> coverBlurHash = const Value.absent(),
                Value<String?> coverDominantColor = const Value.absent(),
                Value<String?> coverPHash = const Value.absent(),
                Value<double?> coverEntropy = const Value.absent(),
                Value<String?> coverFormatOrigin = const Value.absent(),
                Value<bool> relationsKnown = const Value.absent(),
                Value<bool> seenAsSafe = const Value.absent(),
                required DateTime cachedAt,
                required DateTime lastAccessedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedBooksCompanion.insert(
                id: id,
                title: title,
                description: description,
                cover: cover,
                type: type,
                publication: publication,
                totalChapters: totalChapters,
                createdAt: createdAt,
                updatedAt: updatedAt,
                coverWidth: coverWidth,
                coverHeight: coverHeight,
                coverSizeBytes: coverSizeBytes,
                coverMimeType: coverMimeType,
                coverBlurHash: coverBlurHash,
                coverDominantColor: coverDominantColor,
                coverPHash: coverPHash,
                coverEntropy: coverEntropy,
                coverFormatOrigin: coverFormatOrigin,
                relationsKnown: relationsKnown,
                seenAsSafe: seenAsSafe,
                cachedAt: cachedAt,
                lastAccessedAt: lastAccessedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedBooksTableProcessedTableManager =
    ProcessedTableManager<
      _$OfflineCacheDatabase,
      $CachedBooksTable,
      CachedBook,
      $$CachedBooksTableFilterComposer,
      $$CachedBooksTableOrderingComposer,
      $$CachedBooksTableAnnotationComposer,
      $$CachedBooksTableCreateCompanionBuilder,
      $$CachedBooksTableUpdateCompanionBuilder,
      (
        CachedBook,
        BaseReferences<_$OfflineCacheDatabase, $CachedBooksTable, CachedBook>,
      ),
      CachedBook,
      PrefetchHooks Function()
    >;
typedef $$CachedAuthorsTableCreateCompanionBuilder =
    CachedAuthorsCompanion Function({
      required String id,
      required String name,
      Value<int> rowid,
    });
typedef $$CachedAuthorsTableUpdateCompanionBuilder =
    CachedAuthorsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> rowid,
    });

class $$CachedAuthorsTableFilterComposer
    extends Composer<_$OfflineCacheDatabase, $CachedAuthorsTable> {
  $$CachedAuthorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedAuthorsTableOrderingComposer
    extends Composer<_$OfflineCacheDatabase, $CachedAuthorsTable> {
  $$CachedAuthorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedAuthorsTableAnnotationComposer
    extends Composer<_$OfflineCacheDatabase, $CachedAuthorsTable> {
  $$CachedAuthorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$CachedAuthorsTableTableManager
    extends
        RootTableManager<
          _$OfflineCacheDatabase,
          $CachedAuthorsTable,
          CachedAuthor,
          $$CachedAuthorsTableFilterComposer,
          $$CachedAuthorsTableOrderingComposer,
          $$CachedAuthorsTableAnnotationComposer,
          $$CachedAuthorsTableCreateCompanionBuilder,
          $$CachedAuthorsTableUpdateCompanionBuilder,
          (
            CachedAuthor,
            BaseReferences<
              _$OfflineCacheDatabase,
              $CachedAuthorsTable,
              CachedAuthor
            >,
          ),
          CachedAuthor,
          PrefetchHooks Function()
        > {
  $$CachedAuthorsTableTableManager(
    _$OfflineCacheDatabase db,
    $CachedAuthorsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedAuthorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedAuthorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedAuthorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedAuthorsCompanion(id: id, name: name, rowid: rowid),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => CachedAuthorsCompanion.insert(
                id: id,
                name: name,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedAuthorsTableProcessedTableManager =
    ProcessedTableManager<
      _$OfflineCacheDatabase,
      $CachedAuthorsTable,
      CachedAuthor,
      $$CachedAuthorsTableFilterComposer,
      $$CachedAuthorsTableOrderingComposer,
      $$CachedAuthorsTableAnnotationComposer,
      $$CachedAuthorsTableCreateCompanionBuilder,
      $$CachedAuthorsTableUpdateCompanionBuilder,
      (
        CachedAuthor,
        BaseReferences<
          _$OfflineCacheDatabase,
          $CachedAuthorsTable,
          CachedAuthor
        >,
      ),
      CachedAuthor,
      PrefetchHooks Function()
    >;
typedef $$CachedTagsTableCreateCompanionBuilder =
    CachedTagsCompanion Function({
      required String id,
      required String name,
      Value<int> rowid,
    });
typedef $$CachedTagsTableUpdateCompanionBuilder =
    CachedTagsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> rowid,
    });

class $$CachedTagsTableFilterComposer
    extends Composer<_$OfflineCacheDatabase, $CachedTagsTable> {
  $$CachedTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedTagsTableOrderingComposer
    extends Composer<_$OfflineCacheDatabase, $CachedTagsTable> {
  $$CachedTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedTagsTableAnnotationComposer
    extends Composer<_$OfflineCacheDatabase, $CachedTagsTable> {
  $$CachedTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$CachedTagsTableTableManager
    extends
        RootTableManager<
          _$OfflineCacheDatabase,
          $CachedTagsTable,
          CachedTag,
          $$CachedTagsTableFilterComposer,
          $$CachedTagsTableOrderingComposer,
          $$CachedTagsTableAnnotationComposer,
          $$CachedTagsTableCreateCompanionBuilder,
          $$CachedTagsTableUpdateCompanionBuilder,
          (
            CachedTag,
            BaseReferences<_$OfflineCacheDatabase, $CachedTagsTable, CachedTag>,
          ),
          CachedTag,
          PrefetchHooks Function()
        > {
  $$CachedTagsTableTableManager(
    _$OfflineCacheDatabase db,
    $CachedTagsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedTagsCompanion(id: id, name: name, rowid: rowid),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<int> rowid = const Value.absent(),
              }) =>
                  CachedTagsCompanion.insert(id: id, name: name, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$OfflineCacheDatabase,
      $CachedTagsTable,
      CachedTag,
      $$CachedTagsTableFilterComposer,
      $$CachedTagsTableOrderingComposer,
      $$CachedTagsTableAnnotationComposer,
      $$CachedTagsTableCreateCompanionBuilder,
      $$CachedTagsTableUpdateCompanionBuilder,
      (
        CachedTag,
        BaseReferences<_$OfflineCacheDatabase, $CachedTagsTable, CachedTag>,
      ),
      CachedTag,
      PrefetchHooks Function()
    >;
typedef $$CachedBookAuthorsTableCreateCompanionBuilder =
    CachedBookAuthorsCompanion Function({
      required String bookId,
      required String authorId,
      required int position,
      Value<int> rowid,
    });
typedef $$CachedBookAuthorsTableUpdateCompanionBuilder =
    CachedBookAuthorsCompanion Function({
      Value<String> bookId,
      Value<String> authorId,
      Value<int> position,
      Value<int> rowid,
    });

class $$CachedBookAuthorsTableFilterComposer
    extends Composer<_$OfflineCacheDatabase, $CachedBookAuthorsTable> {
  $$CachedBookAuthorsTableFilterComposer({
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

  ColumnFilters<String> get authorId => $composableBuilder(
    column: $table.authorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedBookAuthorsTableOrderingComposer
    extends Composer<_$OfflineCacheDatabase, $CachedBookAuthorsTable> {
  $$CachedBookAuthorsTableOrderingComposer({
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

  ColumnOrderings<String> get authorId => $composableBuilder(
    column: $table.authorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedBookAuthorsTableAnnotationComposer
    extends Composer<_$OfflineCacheDatabase, $CachedBookAuthorsTable> {
  $$CachedBookAuthorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<String> get authorId =>
      $composableBuilder(column: $table.authorId, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$CachedBookAuthorsTableTableManager
    extends
        RootTableManager<
          _$OfflineCacheDatabase,
          $CachedBookAuthorsTable,
          CachedBookAuthor,
          $$CachedBookAuthorsTableFilterComposer,
          $$CachedBookAuthorsTableOrderingComposer,
          $$CachedBookAuthorsTableAnnotationComposer,
          $$CachedBookAuthorsTableCreateCompanionBuilder,
          $$CachedBookAuthorsTableUpdateCompanionBuilder,
          (
            CachedBookAuthor,
            BaseReferences<
              _$OfflineCacheDatabase,
              $CachedBookAuthorsTable,
              CachedBookAuthor
            >,
          ),
          CachedBookAuthor,
          PrefetchHooks Function()
        > {
  $$CachedBookAuthorsTableTableManager(
    _$OfflineCacheDatabase db,
    $CachedBookAuthorsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedBookAuthorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedBookAuthorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedBookAuthorsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> bookId = const Value.absent(),
                Value<String> authorId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedBookAuthorsCompanion(
                bookId: bookId,
                authorId: authorId,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String bookId,
                required String authorId,
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => CachedBookAuthorsCompanion.insert(
                bookId: bookId,
                authorId: authorId,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedBookAuthorsTableProcessedTableManager =
    ProcessedTableManager<
      _$OfflineCacheDatabase,
      $CachedBookAuthorsTable,
      CachedBookAuthor,
      $$CachedBookAuthorsTableFilterComposer,
      $$CachedBookAuthorsTableOrderingComposer,
      $$CachedBookAuthorsTableAnnotationComposer,
      $$CachedBookAuthorsTableCreateCompanionBuilder,
      $$CachedBookAuthorsTableUpdateCompanionBuilder,
      (
        CachedBookAuthor,
        BaseReferences<
          _$OfflineCacheDatabase,
          $CachedBookAuthorsTable,
          CachedBookAuthor
        >,
      ),
      CachedBookAuthor,
      PrefetchHooks Function()
    >;
typedef $$CachedBookTagsTableCreateCompanionBuilder =
    CachedBookTagsCompanion Function({
      required String bookId,
      required String tagId,
      required int position,
      Value<int> rowid,
    });
typedef $$CachedBookTagsTableUpdateCompanionBuilder =
    CachedBookTagsCompanion Function({
      Value<String> bookId,
      Value<String> tagId,
      Value<int> position,
      Value<int> rowid,
    });

class $$CachedBookTagsTableFilterComposer
    extends Composer<_$OfflineCacheDatabase, $CachedBookTagsTable> {
  $$CachedBookTagsTableFilterComposer({
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

  ColumnFilters<String> get tagId => $composableBuilder(
    column: $table.tagId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedBookTagsTableOrderingComposer
    extends Composer<_$OfflineCacheDatabase, $CachedBookTagsTable> {
  $$CachedBookTagsTableOrderingComposer({
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

  ColumnOrderings<String> get tagId => $composableBuilder(
    column: $table.tagId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedBookTagsTableAnnotationComposer
    extends Composer<_$OfflineCacheDatabase, $CachedBookTagsTable> {
  $$CachedBookTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<String> get tagId =>
      $composableBuilder(column: $table.tagId, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$CachedBookTagsTableTableManager
    extends
        RootTableManager<
          _$OfflineCacheDatabase,
          $CachedBookTagsTable,
          CachedBookTag,
          $$CachedBookTagsTableFilterComposer,
          $$CachedBookTagsTableOrderingComposer,
          $$CachedBookTagsTableAnnotationComposer,
          $$CachedBookTagsTableCreateCompanionBuilder,
          $$CachedBookTagsTableUpdateCompanionBuilder,
          (
            CachedBookTag,
            BaseReferences<
              _$OfflineCacheDatabase,
              $CachedBookTagsTable,
              CachedBookTag
            >,
          ),
          CachedBookTag,
          PrefetchHooks Function()
        > {
  $$CachedBookTagsTableTableManager(
    _$OfflineCacheDatabase db,
    $CachedBookTagsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedBookTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedBookTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedBookTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> bookId = const Value.absent(),
                Value<String> tagId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedBookTagsCompanion(
                bookId: bookId,
                tagId: tagId,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String bookId,
                required String tagId,
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => CachedBookTagsCompanion.insert(
                bookId: bookId,
                tagId: tagId,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedBookTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$OfflineCacheDatabase,
      $CachedBookTagsTable,
      CachedBookTag,
      $$CachedBookTagsTableFilterComposer,
      $$CachedBookTagsTableOrderingComposer,
      $$CachedBookTagsTableAnnotationComposer,
      $$CachedBookTagsTableCreateCompanionBuilder,
      $$CachedBookTagsTableUpdateCompanionBuilder,
      (
        CachedBookTag,
        BaseReferences<
          _$OfflineCacheDatabase,
          $CachedBookTagsTable,
          CachedBookTag
        >,
      ),
      CachedBookTag,
      PrefetchHooks Function()
    >;
typedef $$CachedBookSensitiveContentsTableCreateCompanionBuilder =
    CachedBookSensitiveContentsCompanion Function({
      required String bookId,
      required String name,
      Value<int> rowid,
    });
typedef $$CachedBookSensitiveContentsTableUpdateCompanionBuilder =
    CachedBookSensitiveContentsCompanion Function({
      Value<String> bookId,
      Value<String> name,
      Value<int> rowid,
    });

class $$CachedBookSensitiveContentsTableFilterComposer
    extends
        Composer<_$OfflineCacheDatabase, $CachedBookSensitiveContentsTable> {
  $$CachedBookSensitiveContentsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedBookSensitiveContentsTableOrderingComposer
    extends
        Composer<_$OfflineCacheDatabase, $CachedBookSensitiveContentsTable> {
  $$CachedBookSensitiveContentsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedBookSensitiveContentsTableAnnotationComposer
    extends
        Composer<_$OfflineCacheDatabase, $CachedBookSensitiveContentsTable> {
  $$CachedBookSensitiveContentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$CachedBookSensitiveContentsTableTableManager
    extends
        RootTableManager<
          _$OfflineCacheDatabase,
          $CachedBookSensitiveContentsTable,
          CachedBookSensitiveContent,
          $$CachedBookSensitiveContentsTableFilterComposer,
          $$CachedBookSensitiveContentsTableOrderingComposer,
          $$CachedBookSensitiveContentsTableAnnotationComposer,
          $$CachedBookSensitiveContentsTableCreateCompanionBuilder,
          $$CachedBookSensitiveContentsTableUpdateCompanionBuilder,
          (
            CachedBookSensitiveContent,
            BaseReferences<
              _$OfflineCacheDatabase,
              $CachedBookSensitiveContentsTable,
              CachedBookSensitiveContent
            >,
          ),
          CachedBookSensitiveContent,
          PrefetchHooks Function()
        > {
  $$CachedBookSensitiveContentsTableTableManager(
    _$OfflineCacheDatabase db,
    $CachedBookSensitiveContentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedBookSensitiveContentsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CachedBookSensitiveContentsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CachedBookSensitiveContentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> bookId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedBookSensitiveContentsCompanion(
                bookId: bookId,
                name: name,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String bookId,
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => CachedBookSensitiveContentsCompanion.insert(
                bookId: bookId,
                name: name,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedBookSensitiveContentsTableProcessedTableManager =
    ProcessedTableManager<
      _$OfflineCacheDatabase,
      $CachedBookSensitiveContentsTable,
      CachedBookSensitiveContent,
      $$CachedBookSensitiveContentsTableFilterComposer,
      $$CachedBookSensitiveContentsTableOrderingComposer,
      $$CachedBookSensitiveContentsTableAnnotationComposer,
      $$CachedBookSensitiveContentsTableCreateCompanionBuilder,
      $$CachedBookSensitiveContentsTableUpdateCompanionBuilder,
      (
        CachedBookSensitiveContent,
        BaseReferences<
          _$OfflineCacheDatabase,
          $CachedBookSensitiveContentsTable,
          CachedBookSensitiveContent
        >,
      ),
      CachedBookSensitiveContent,
      PrefetchHooks Function()
    >;
typedef $$CachedBookSensitiveProvenanceTableCreateCompanionBuilder =
    CachedBookSensitiveProvenanceCompanion Function({
      required String bookId,
      required String name,
      Value<int> rowid,
    });
typedef $$CachedBookSensitiveProvenanceTableUpdateCompanionBuilder =
    CachedBookSensitiveProvenanceCompanion Function({
      Value<String> bookId,
      Value<String> name,
      Value<int> rowid,
    });

class $$CachedBookSensitiveProvenanceTableFilterComposer
    extends
        Composer<_$OfflineCacheDatabase, $CachedBookSensitiveProvenanceTable> {
  $$CachedBookSensitiveProvenanceTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedBookSensitiveProvenanceTableOrderingComposer
    extends
        Composer<_$OfflineCacheDatabase, $CachedBookSensitiveProvenanceTable> {
  $$CachedBookSensitiveProvenanceTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedBookSensitiveProvenanceTableAnnotationComposer
    extends
        Composer<_$OfflineCacheDatabase, $CachedBookSensitiveProvenanceTable> {
  $$CachedBookSensitiveProvenanceTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$CachedBookSensitiveProvenanceTableTableManager
    extends
        RootTableManager<
          _$OfflineCacheDatabase,
          $CachedBookSensitiveProvenanceTable,
          CachedBookSensitiveProvenanceData,
          $$CachedBookSensitiveProvenanceTableFilterComposer,
          $$CachedBookSensitiveProvenanceTableOrderingComposer,
          $$CachedBookSensitiveProvenanceTableAnnotationComposer,
          $$CachedBookSensitiveProvenanceTableCreateCompanionBuilder,
          $$CachedBookSensitiveProvenanceTableUpdateCompanionBuilder,
          (
            CachedBookSensitiveProvenanceData,
            BaseReferences<
              _$OfflineCacheDatabase,
              $CachedBookSensitiveProvenanceTable,
              CachedBookSensitiveProvenanceData
            >,
          ),
          CachedBookSensitiveProvenanceData,
          PrefetchHooks Function()
        > {
  $$CachedBookSensitiveProvenanceTableTableManager(
    _$OfflineCacheDatabase db,
    $CachedBookSensitiveProvenanceTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedBookSensitiveProvenanceTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CachedBookSensitiveProvenanceTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CachedBookSensitiveProvenanceTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> bookId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedBookSensitiveProvenanceCompanion(
                bookId: bookId,
                name: name,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String bookId,
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => CachedBookSensitiveProvenanceCompanion.insert(
                bookId: bookId,
                name: name,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedBookSensitiveProvenanceTableProcessedTableManager =
    ProcessedTableManager<
      _$OfflineCacheDatabase,
      $CachedBookSensitiveProvenanceTable,
      CachedBookSensitiveProvenanceData,
      $$CachedBookSensitiveProvenanceTableFilterComposer,
      $$CachedBookSensitiveProvenanceTableOrderingComposer,
      $$CachedBookSensitiveProvenanceTableAnnotationComposer,
      $$CachedBookSensitiveProvenanceTableCreateCompanionBuilder,
      $$CachedBookSensitiveProvenanceTableUpdateCompanionBuilder,
      (
        CachedBookSensitiveProvenanceData,
        BaseReferences<
          _$OfflineCacheDatabase,
          $CachedBookSensitiveProvenanceTable,
          CachedBookSensitiveProvenanceData
        >,
      ),
      CachedBookSensitiveProvenanceData,
      PrefetchHooks Function()
    >;
typedef $$CachedChaptersTableCreateCompanionBuilder =
    CachedChaptersCompanion Function({
      required String id,
      required String bookId,
      Value<String?> title,
      required double chapterIndex,
      Value<String?> scrapingStatus,
      Value<bool> read,
      Value<bool> completed,
      Value<int> lastPage,
      required DateTime cachedAt,
      Value<int> rowid,
    });
typedef $$CachedChaptersTableUpdateCompanionBuilder =
    CachedChaptersCompanion Function({
      Value<String> id,
      Value<String> bookId,
      Value<String?> title,
      Value<double> chapterIndex,
      Value<String?> scrapingStatus,
      Value<bool> read,
      Value<bool> completed,
      Value<int> lastPage,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$CachedChaptersTableFilterComposer
    extends Composer<_$OfflineCacheDatabase, $CachedChaptersTable> {
  $$CachedChaptersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scrapingStatus => $composableBuilder(
    column: $table.scrapingStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get read => $composableBuilder(
    column: $table.read,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastPage => $composableBuilder(
    column: $table.lastPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedChaptersTableOrderingComposer
    extends Composer<_$OfflineCacheDatabase, $CachedChaptersTable> {
  $$CachedChaptersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scrapingStatus => $composableBuilder(
    column: $table.scrapingStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get read => $composableBuilder(
    column: $table.read,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastPage => $composableBuilder(
    column: $table.lastPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedChaptersTableAnnotationComposer
    extends Composer<_$OfflineCacheDatabase, $CachedChaptersTable> {
  $$CachedChaptersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<double> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scrapingStatus => $composableBuilder(
    column: $table.scrapingStatus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get read =>
      $composableBuilder(column: $table.read, builder: (column) => column);

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<int> get lastPage =>
      $composableBuilder(column: $table.lastPage, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CachedChaptersTableTableManager
    extends
        RootTableManager<
          _$OfflineCacheDatabase,
          $CachedChaptersTable,
          CachedChapter,
          $$CachedChaptersTableFilterComposer,
          $$CachedChaptersTableOrderingComposer,
          $$CachedChaptersTableAnnotationComposer,
          $$CachedChaptersTableCreateCompanionBuilder,
          $$CachedChaptersTableUpdateCompanionBuilder,
          (
            CachedChapter,
            BaseReferences<
              _$OfflineCacheDatabase,
              $CachedChaptersTable,
              CachedChapter
            >,
          ),
          CachedChapter,
          PrefetchHooks Function()
        > {
  $$CachedChaptersTableTableManager(
    _$OfflineCacheDatabase db,
    $CachedChaptersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedChaptersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedChaptersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedChaptersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> bookId = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<double> chapterIndex = const Value.absent(),
                Value<String?> scrapingStatus = const Value.absent(),
                Value<bool> read = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<int> lastPage = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedChaptersCompanion(
                id: id,
                bookId: bookId,
                title: title,
                chapterIndex: chapterIndex,
                scrapingStatus: scrapingStatus,
                read: read,
                completed: completed,
                lastPage: lastPage,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String bookId,
                Value<String?> title = const Value.absent(),
                required double chapterIndex,
                Value<String?> scrapingStatus = const Value.absent(),
                Value<bool> read = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<int> lastPage = const Value.absent(),
                required DateTime cachedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedChaptersCompanion.insert(
                id: id,
                bookId: bookId,
                title: title,
                chapterIndex: chapterIndex,
                scrapingStatus: scrapingStatus,
                read: read,
                completed: completed,
                lastPage: lastPage,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedChaptersTableProcessedTableManager =
    ProcessedTableManager<
      _$OfflineCacheDatabase,
      $CachedChaptersTable,
      CachedChapter,
      $$CachedChaptersTableFilterComposer,
      $$CachedChaptersTableOrderingComposer,
      $$CachedChaptersTableAnnotationComposer,
      $$CachedChaptersTableCreateCompanionBuilder,
      $$CachedChaptersTableUpdateCompanionBuilder,
      (
        CachedChapter,
        BaseReferences<
          _$OfflineCacheDatabase,
          $CachedChaptersTable,
          CachedChapter
        >,
      ),
      CachedChapter,
      PrefetchHooks Function()
    >;
typedef $$CachedCoversTableCreateCompanionBuilder =
    CachedCoversCompanion Function({
      required String bookId,
      required String sourceUrl,
      required String filePath,
      required int bytes,
      required DateTime fetchedAt,
      required DateTime lastUsedAt,
      Value<int> rowid,
    });
typedef $$CachedCoversTableUpdateCompanionBuilder =
    CachedCoversCompanion Function({
      Value<String> bookId,
      Value<String> sourceUrl,
      Value<String> filePath,
      Value<int> bytes,
      Value<DateTime> fetchedAt,
      Value<DateTime> lastUsedAt,
      Value<int> rowid,
    });

class $$CachedCoversTableFilterComposer
    extends Composer<_$OfflineCacheDatabase, $CachedCoversTable> {
  $$CachedCoversTableFilterComposer({
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

  ColumnFilters<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedCoversTableOrderingComposer
    extends Composer<_$OfflineCacheDatabase, $CachedCoversTable> {
  $$CachedCoversTableOrderingComposer({
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

  ColumnOrderings<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedCoversTableAnnotationComposer
    extends Composer<_$OfflineCacheDatabase, $CachedCoversTable> {
  $$CachedCoversTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<int> get bytes =>
      $composableBuilder(column: $table.bytes, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => column,
  );
}

class $$CachedCoversTableTableManager
    extends
        RootTableManager<
          _$OfflineCacheDatabase,
          $CachedCoversTable,
          CachedCover,
          $$CachedCoversTableFilterComposer,
          $$CachedCoversTableOrderingComposer,
          $$CachedCoversTableAnnotationComposer,
          $$CachedCoversTableCreateCompanionBuilder,
          $$CachedCoversTableUpdateCompanionBuilder,
          (
            CachedCover,
            BaseReferences<
              _$OfflineCacheDatabase,
              $CachedCoversTable,
              CachedCover
            >,
          ),
          CachedCover,
          PrefetchHooks Function()
        > {
  $$CachedCoversTableTableManager(
    _$OfflineCacheDatabase db,
    $CachedCoversTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedCoversTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedCoversTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedCoversTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> bookId = const Value.absent(),
                Value<String> sourceUrl = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<int> bytes = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<DateTime> lastUsedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedCoversCompanion(
                bookId: bookId,
                sourceUrl: sourceUrl,
                filePath: filePath,
                bytes: bytes,
                fetchedAt: fetchedAt,
                lastUsedAt: lastUsedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String bookId,
                required String sourceUrl,
                required String filePath,
                required int bytes,
                required DateTime fetchedAt,
                required DateTime lastUsedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedCoversCompanion.insert(
                bookId: bookId,
                sourceUrl: sourceUrl,
                filePath: filePath,
                bytes: bytes,
                fetchedAt: fetchedAt,
                lastUsedAt: lastUsedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedCoversTableProcessedTableManager =
    ProcessedTableManager<
      _$OfflineCacheDatabase,
      $CachedCoversTable,
      CachedCover,
      $$CachedCoversTableFilterComposer,
      $$CachedCoversTableOrderingComposer,
      $$CachedCoversTableAnnotationComposer,
      $$CachedCoversTableCreateCompanionBuilder,
      $$CachedCoversTableUpdateCompanionBuilder,
      (
        CachedCover,
        BaseReferences<_$OfflineCacheDatabase, $CachedCoversTable, CachedCover>,
      ),
      CachedCover,
      PrefetchHooks Function()
    >;
typedef $$CoverPinsTableCreateCompanionBuilder =
    CoverPinsCompanion Function({
      required String bookId,
      required String owner,
      Value<int> rowid,
    });
typedef $$CoverPinsTableUpdateCompanionBuilder =
    CoverPinsCompanion Function({
      Value<String> bookId,
      Value<String> owner,
      Value<int> rowid,
    });

class $$CoverPinsTableFilterComposer
    extends Composer<_$OfflineCacheDatabase, $CoverPinsTable> {
  $$CoverPinsTableFilterComposer({
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

  ColumnFilters<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CoverPinsTableOrderingComposer
    extends Composer<_$OfflineCacheDatabase, $CoverPinsTable> {
  $$CoverPinsTableOrderingComposer({
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

  ColumnOrderings<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CoverPinsTableAnnotationComposer
    extends Composer<_$OfflineCacheDatabase, $CoverPinsTable> {
  $$CoverPinsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<String> get owner =>
      $composableBuilder(column: $table.owner, builder: (column) => column);
}

class $$CoverPinsTableTableManager
    extends
        RootTableManager<
          _$OfflineCacheDatabase,
          $CoverPinsTable,
          CoverPin,
          $$CoverPinsTableFilterComposer,
          $$CoverPinsTableOrderingComposer,
          $$CoverPinsTableAnnotationComposer,
          $$CoverPinsTableCreateCompanionBuilder,
          $$CoverPinsTableUpdateCompanionBuilder,
          (
            CoverPin,
            BaseReferences<_$OfflineCacheDatabase, $CoverPinsTable, CoverPin>,
          ),
          CoverPin,
          PrefetchHooks Function()
        > {
  $$CoverPinsTableTableManager(_$OfflineCacheDatabase db, $CoverPinsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CoverPinsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CoverPinsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CoverPinsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> bookId = const Value.absent(),
                Value<String> owner = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CoverPinsCompanion(
                bookId: bookId,
                owner: owner,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String bookId,
                required String owner,
                Value<int> rowid = const Value.absent(),
              }) => CoverPinsCompanion.insert(
                bookId: bookId,
                owner: owner,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CoverPinsTableProcessedTableManager =
    ProcessedTableManager<
      _$OfflineCacheDatabase,
      $CoverPinsTable,
      CoverPin,
      $$CoverPinsTableFilterComposer,
      $$CoverPinsTableOrderingComposer,
      $$CoverPinsTableAnnotationComposer,
      $$CoverPinsTableCreateCompanionBuilder,
      $$CoverPinsTableUpdateCompanionBuilder,
      (
        CoverPin,
        BaseReferences<_$OfflineCacheDatabase, $CoverPinsTable, CoverPin>,
      ),
      CoverPin,
      PrefetchHooks Function()
    >;

class $OfflineCacheDatabaseManager {
  final _$OfflineCacheDatabase _db;
  $OfflineCacheDatabaseManager(this._db);
  $$CachedBooksTableTableManager get cachedBooks =>
      $$CachedBooksTableTableManager(_db, _db.cachedBooks);
  $$CachedAuthorsTableTableManager get cachedAuthors =>
      $$CachedAuthorsTableTableManager(_db, _db.cachedAuthors);
  $$CachedTagsTableTableManager get cachedTags =>
      $$CachedTagsTableTableManager(_db, _db.cachedTags);
  $$CachedBookAuthorsTableTableManager get cachedBookAuthors =>
      $$CachedBookAuthorsTableTableManager(_db, _db.cachedBookAuthors);
  $$CachedBookTagsTableTableManager get cachedBookTags =>
      $$CachedBookTagsTableTableManager(_db, _db.cachedBookTags);
  $$CachedBookSensitiveContentsTableTableManager
  get cachedBookSensitiveContents =>
      $$CachedBookSensitiveContentsTableTableManager(
        _db,
        _db.cachedBookSensitiveContents,
      );
  $$CachedBookSensitiveProvenanceTableTableManager
  get cachedBookSensitiveProvenance =>
      $$CachedBookSensitiveProvenanceTableTableManager(
        _db,
        _db.cachedBookSensitiveProvenance,
      );
  $$CachedChaptersTableTableManager get cachedChapters =>
      $$CachedChaptersTableTableManager(_db, _db.cachedChapters);
  $$CachedCoversTableTableManager get cachedCovers =>
      $$CachedCoversTableTableManager(_db, _db.cachedCovers);
  $$CoverPinsTableTableManager get coverPins =>
      $$CoverPinsTableTableManager(_db, _db.coverPins);
}
