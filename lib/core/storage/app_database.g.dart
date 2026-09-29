// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $HistoryBlocksTable extends HistoryBlocks
    with TableInfo<$HistoryBlocksTable, HistoryBlock> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HistoryBlocksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _queryMeta = const VerificationMeta('query');
  @override
  late final GeneratedColumn<String> query = GeneratedColumn<String>(
    'query',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _inputPriceMeta = const VerificationMeta(
    'inputPrice',
  );
  @override
  late final GeneratedColumn<int> inputPrice = GeneratedColumn<int>(
    'input_price',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<double> score = GeneratedColumn<double>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verdictMeta = const VerificationMeta(
    'verdict',
  );
  @override
  late final GeneratedColumn<String> verdict = GeneratedColumn<String>(
    'verdict',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _dataJsonMeta = const VerificationMeta(
    'dataJson',
  );
  @override
  late final GeneratedColumn<String> dataJson = GeneratedColumn<String>(
    'data_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _prevHashMeta = const VerificationMeta(
    'prevHash',
  );
  @override
  late final GeneratedColumn<String> prevHash = GeneratedColumn<String>(
    'prev_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _hashMeta = const VerificationMeta('hash');
  @override
  late final GeneratedColumn<String> hash = GeneratedColumn<String>(
    'hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mode,
    query,
    inputPrice,
    score,
    verdict,
    createdAt,
    dataJson,
    prevHash,
    hash,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'history_blocks';
  @override
  VerificationContext validateIntegrity(
    Insertable<HistoryBlock> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('query')) {
      context.handle(
        _queryMeta,
        query.isAcceptableOrUnknown(data['query']!, _queryMeta),
      );
    } else if (isInserting) {
      context.missing(_queryMeta);
    }
    if (data.containsKey('input_price')) {
      context.handle(
        _inputPriceMeta,
        inputPrice.isAcceptableOrUnknown(data['input_price']!, _inputPriceMeta),
      );
    } else if (isInserting) {
      context.missing(_inputPriceMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('verdict')) {
      context.handle(
        _verdictMeta,
        verdict.isAcceptableOrUnknown(data['verdict']!, _verdictMeta),
      );
    } else if (isInserting) {
      context.missing(_verdictMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('data_json')) {
      context.handle(
        _dataJsonMeta,
        dataJson.isAcceptableOrUnknown(data['data_json']!, _dataJsonMeta),
      );
    }
    if (data.containsKey('prev_hash')) {
      context.handle(
        _prevHashMeta,
        prevHash.isAcceptableOrUnknown(data['prev_hash']!, _prevHashMeta),
      );
    }
    if (data.containsKey('hash')) {
      context.handle(
        _hashMeta,
        hash.isAcceptableOrUnknown(data['hash']!, _hashMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HistoryBlock map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HistoryBlock(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      query: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}query'],
      )!,
      inputPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}input_price'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}score'],
      )!,
      verdict: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}verdict'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      dataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data_json'],
      )!,
      prevHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prev_hash'],
      )!,
      hash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hash'],
      )!,
    );
  }

  @override
  $HistoryBlocksTable createAlias(String alias) {
    return $HistoryBlocksTable(attachedDatabase, alias);
  }
}

class HistoryBlock extends DataClass implements Insertable<HistoryBlock> {
  final int id;
  final String mode;
  final String query;
  final int inputPrice;
  final double score;
  final String verdict;
  final DateTime createdAt;
  final String dataJson;
  final String prevHash;
  final String hash;
  const HistoryBlock({
    required this.id,
    required this.mode,
    required this.query,
    required this.inputPrice,
    required this.score,
    required this.verdict,
    required this.createdAt,
    required this.dataJson,
    required this.prevHash,
    required this.hash,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['mode'] = Variable<String>(mode);
    map['query'] = Variable<String>(query);
    map['input_price'] = Variable<int>(inputPrice);
    map['score'] = Variable<double>(score);
    map['verdict'] = Variable<String>(verdict);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['data_json'] = Variable<String>(dataJson);
    map['prev_hash'] = Variable<String>(prevHash);
    map['hash'] = Variable<String>(hash);
    return map;
  }

  HistoryBlocksCompanion toCompanion(bool nullToAbsent) {
    return HistoryBlocksCompanion(
      id: Value(id),
      mode: Value(mode),
      query: Value(query),
      inputPrice: Value(inputPrice),
      score: Value(score),
      verdict: Value(verdict),
      createdAt: Value(createdAt),
      dataJson: Value(dataJson),
      prevHash: Value(prevHash),
      hash: Value(hash),
    );
  }

  factory HistoryBlock.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HistoryBlock(
      id: serializer.fromJson<int>(json['id']),
      mode: serializer.fromJson<String>(json['mode']),
      query: serializer.fromJson<String>(json['query']),
      inputPrice: serializer.fromJson<int>(json['inputPrice']),
      score: serializer.fromJson<double>(json['score']),
      verdict: serializer.fromJson<String>(json['verdict']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      dataJson: serializer.fromJson<String>(json['dataJson']),
      prevHash: serializer.fromJson<String>(json['prevHash']),
      hash: serializer.fromJson<String>(json['hash']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'mode': serializer.toJson<String>(mode),
      'query': serializer.toJson<String>(query),
      'inputPrice': serializer.toJson<int>(inputPrice),
      'score': serializer.toJson<double>(score),
      'verdict': serializer.toJson<String>(verdict),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'dataJson': serializer.toJson<String>(dataJson),
      'prevHash': serializer.toJson<String>(prevHash),
      'hash': serializer.toJson<String>(hash),
    };
  }

  HistoryBlock copyWith({
    int? id,
    String? mode,
    String? query,
    int? inputPrice,
    double? score,
    String? verdict,
    DateTime? createdAt,
    String? dataJson,
    String? prevHash,
    String? hash,
  }) => HistoryBlock(
    id: id ?? this.id,
    mode: mode ?? this.mode,
    query: query ?? this.query,
    inputPrice: inputPrice ?? this.inputPrice,
    score: score ?? this.score,
    verdict: verdict ?? this.verdict,
    createdAt: createdAt ?? this.createdAt,
    dataJson: dataJson ?? this.dataJson,
    prevHash: prevHash ?? this.prevHash,
    hash: hash ?? this.hash,
  );
  HistoryBlock copyWithCompanion(HistoryBlocksCompanion data) {
    return HistoryBlock(
      id: data.id.present ? data.id.value : this.id,
      mode: data.mode.present ? data.mode.value : this.mode,
      query: data.query.present ? data.query.value : this.query,
      inputPrice: data.inputPrice.present
          ? data.inputPrice.value
          : this.inputPrice,
      score: data.score.present ? data.score.value : this.score,
      verdict: data.verdict.present ? data.verdict.value : this.verdict,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      dataJson: data.dataJson.present ? data.dataJson.value : this.dataJson,
      prevHash: data.prevHash.present ? data.prevHash.value : this.prevHash,
      hash: data.hash.present ? data.hash.value : this.hash,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HistoryBlock(')
          ..write('id: $id, ')
          ..write('mode: $mode, ')
          ..write('query: $query, ')
          ..write('inputPrice: $inputPrice, ')
          ..write('score: $score, ')
          ..write('verdict: $verdict, ')
          ..write('createdAt: $createdAt, ')
          ..write('dataJson: $dataJson, ')
          ..write('prevHash: $prevHash, ')
          ..write('hash: $hash')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    mode,
    query,
    inputPrice,
    score,
    verdict,
    createdAt,
    dataJson,
    prevHash,
    hash,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HistoryBlock &&
          other.id == this.id &&
          other.mode == this.mode &&
          other.query == this.query &&
          other.inputPrice == this.inputPrice &&
          other.score == this.score &&
          other.verdict == this.verdict &&
          other.createdAt == this.createdAt &&
          other.dataJson == this.dataJson &&
          other.prevHash == this.prevHash &&
          other.hash == this.hash);
}

class HistoryBlocksCompanion extends UpdateCompanion<HistoryBlock> {
  final Value<int> id;
  final Value<String> mode;
  final Value<String> query;
  final Value<int> inputPrice;
  final Value<double> score;
  final Value<String> verdict;
  final Value<DateTime> createdAt;
  final Value<String> dataJson;
  final Value<String> prevHash;
  final Value<String> hash;
  const HistoryBlocksCompanion({
    this.id = const Value.absent(),
    this.mode = const Value.absent(),
    this.query = const Value.absent(),
    this.inputPrice = const Value.absent(),
    this.score = const Value.absent(),
    this.verdict = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.dataJson = const Value.absent(),
    this.prevHash = const Value.absent(),
    this.hash = const Value.absent(),
  });
  HistoryBlocksCompanion.insert({
    this.id = const Value.absent(),
    required String mode,
    required String query,
    required int inputPrice,
    required double score,
    required String verdict,
    this.createdAt = const Value.absent(),
    this.dataJson = const Value.absent(),
    this.prevHash = const Value.absent(),
    this.hash = const Value.absent(),
  }) : mode = Value(mode),
       query = Value(query),
       inputPrice = Value(inputPrice),
       score = Value(score),
       verdict = Value(verdict);
  static Insertable<HistoryBlock> custom({
    Expression<int>? id,
    Expression<String>? mode,
    Expression<String>? query,
    Expression<int>? inputPrice,
    Expression<double>? score,
    Expression<String>? verdict,
    Expression<DateTime>? createdAt,
    Expression<String>? dataJson,
    Expression<String>? prevHash,
    Expression<String>? hash,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mode != null) 'mode': mode,
      if (query != null) 'query': query,
      if (inputPrice != null) 'input_price': inputPrice,
      if (score != null) 'score': score,
      if (verdict != null) 'verdict': verdict,
      if (createdAt != null) 'created_at': createdAt,
      if (dataJson != null) 'data_json': dataJson,
      if (prevHash != null) 'prev_hash': prevHash,
      if (hash != null) 'hash': hash,
    });
  }

  HistoryBlocksCompanion copyWith({
    Value<int>? id,
    Value<String>? mode,
    Value<String>? query,
    Value<int>? inputPrice,
    Value<double>? score,
    Value<String>? verdict,
    Value<DateTime>? createdAt,
    Value<String>? dataJson,
    Value<String>? prevHash,
    Value<String>? hash,
  }) {
    return HistoryBlocksCompanion(
      id: id ?? this.id,
      mode: mode ?? this.mode,
      query: query ?? this.query,
      inputPrice: inputPrice ?? this.inputPrice,
      score: score ?? this.score,
      verdict: verdict ?? this.verdict,
      createdAt: createdAt ?? this.createdAt,
      dataJson: dataJson ?? this.dataJson,
      prevHash: prevHash ?? this.prevHash,
      hash: hash ?? this.hash,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (query.present) {
      map['query'] = Variable<String>(query.value);
    }
    if (inputPrice.present) {
      map['input_price'] = Variable<int>(inputPrice.value);
    }
    if (score.present) {
      map['score'] = Variable<double>(score.value);
    }
    if (verdict.present) {
      map['verdict'] = Variable<String>(verdict.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (dataJson.present) {
      map['data_json'] = Variable<String>(dataJson.value);
    }
    if (prevHash.present) {
      map['prev_hash'] = Variable<String>(prevHash.value);
    }
    if (hash.present) {
      map['hash'] = Variable<String>(hash.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HistoryBlocksCompanion(')
          ..write('id: $id, ')
          ..write('mode: $mode, ')
          ..write('query: $query, ')
          ..write('inputPrice: $inputPrice, ')
          ..write('score: $score, ')
          ..write('verdict: $verdict, ')
          ..write('createdAt: $createdAt, ')
          ..write('dataJson: $dataJson, ')
          ..write('prevHash: $prevHash, ')
          ..write('hash: $hash')
          ..write(')'))
        .toString();
  }
}

class $WishlistItemsTable extends WishlistItems
    with TableInfo<$WishlistItemsTable, WishlistItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WishlistItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _queryMeta = const VerificationMeta('query');
  @override
  late final GeneratedColumn<String> query = GeneratedColumn<String>(
    'query',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetPriceMeta = const VerificationMeta(
    'targetPrice',
  );
  @override
  late final GeneratedColumn<int> targetPrice = GeneratedColumn<int>(
    'target_price',
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
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    query,
    mode,
    targetPrice,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wishlist_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<WishlistItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('query')) {
      context.handle(
        _queryMeta,
        query.isAcceptableOrUnknown(data['query']!, _queryMeta),
      );
    } else if (isInserting) {
      context.missing(_queryMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('target_price')) {
      context.handle(
        _targetPriceMeta,
        targetPrice.isAcceptableOrUnknown(
          data['target_price']!,
          _targetPriceMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WishlistItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WishlistItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      query: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}query'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      targetPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_price'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $WishlistItemsTable createAlias(String alias) {
    return $WishlistItemsTable(attachedDatabase, alias);
  }
}

class WishlistItem extends DataClass implements Insertable<WishlistItem> {
  final int id;
  final String query;
  final String mode;
  final int? targetPrice;
  final DateTime createdAt;
  const WishlistItem({
    required this.id,
    required this.query,
    required this.mode,
    this.targetPrice,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['query'] = Variable<String>(query);
    map['mode'] = Variable<String>(mode);
    if (!nullToAbsent || targetPrice != null) {
      map['target_price'] = Variable<int>(targetPrice);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  WishlistItemsCompanion toCompanion(bool nullToAbsent) {
    return WishlistItemsCompanion(
      id: Value(id),
      query: Value(query),
      mode: Value(mode),
      targetPrice: targetPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(targetPrice),
      createdAt: Value(createdAt),
    );
  }

  factory WishlistItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WishlistItem(
      id: serializer.fromJson<int>(json['id']),
      query: serializer.fromJson<String>(json['query']),
      mode: serializer.fromJson<String>(json['mode']),
      targetPrice: serializer.fromJson<int?>(json['targetPrice']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'query': serializer.toJson<String>(query),
      'mode': serializer.toJson<String>(mode),
      'targetPrice': serializer.toJson<int?>(targetPrice),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  WishlistItem copyWith({
    int? id,
    String? query,
    String? mode,
    Value<int?> targetPrice = const Value.absent(),
    DateTime? createdAt,
  }) => WishlistItem(
    id: id ?? this.id,
    query: query ?? this.query,
    mode: mode ?? this.mode,
    targetPrice: targetPrice.present ? targetPrice.value : this.targetPrice,
    createdAt: createdAt ?? this.createdAt,
  );
  WishlistItem copyWithCompanion(WishlistItemsCompanion data) {
    return WishlistItem(
      id: data.id.present ? data.id.value : this.id,
      query: data.query.present ? data.query.value : this.query,
      mode: data.mode.present ? data.mode.value : this.mode,
      targetPrice: data.targetPrice.present
          ? data.targetPrice.value
          : this.targetPrice,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WishlistItem(')
          ..write('id: $id, ')
          ..write('query: $query, ')
          ..write('mode: $mode, ')
          ..write('targetPrice: $targetPrice, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, query, mode, targetPrice, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WishlistItem &&
          other.id == this.id &&
          other.query == this.query &&
          other.mode == this.mode &&
          other.targetPrice == this.targetPrice &&
          other.createdAt == this.createdAt);
}

class WishlistItemsCompanion extends UpdateCompanion<WishlistItem> {
  final Value<int> id;
  final Value<String> query;
  final Value<String> mode;
  final Value<int?> targetPrice;
  final Value<DateTime> createdAt;
  const WishlistItemsCompanion({
    this.id = const Value.absent(),
    this.query = const Value.absent(),
    this.mode = const Value.absent(),
    this.targetPrice = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  WishlistItemsCompanion.insert({
    this.id = const Value.absent(),
    required String query,
    required String mode,
    this.targetPrice = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : query = Value(query),
       mode = Value(mode);
  static Insertable<WishlistItem> custom({
    Expression<int>? id,
    Expression<String>? query,
    Expression<String>? mode,
    Expression<int>? targetPrice,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (query != null) 'query': query,
      if (mode != null) 'mode': mode,
      if (targetPrice != null) 'target_price': targetPrice,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  WishlistItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? query,
    Value<String>? mode,
    Value<int?>? targetPrice,
    Value<DateTime>? createdAt,
  }) {
    return WishlistItemsCompanion(
      id: id ?? this.id,
      query: query ?? this.query,
      mode: mode ?? this.mode,
      targetPrice: targetPrice ?? this.targetPrice,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (query.present) {
      map['query'] = Variable<String>(query.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (targetPrice.present) {
      map['target_price'] = Variable<int>(targetPrice.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WishlistItemsCompanion(')
          ..write('id: $id, ')
          ..write('query: $query, ')
          ..write('mode: $mode, ')
          ..write('targetPrice: $targetPrice, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PriceAlertsTable extends PriceAlerts
    with TableInfo<$PriceAlertsTable, PriceAlert> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PriceAlertsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _queryMeta = const VerificationMeta('query');
  @override
  late final GeneratedColumn<String> query = GeneratedColumn<String>(
    'query',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetPriceMeta = const VerificationMeta(
    'targetPrice',
  );
  @override
  late final GeneratedColumn<int> targetPrice = GeneratedColumn<int>(
    'target_price',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    query,
    mode,
    targetPrice,
    isActive,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'price_alerts';
  @override
  VerificationContext validateIntegrity(
    Insertable<PriceAlert> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('query')) {
      context.handle(
        _queryMeta,
        query.isAcceptableOrUnknown(data['query']!, _queryMeta),
      );
    } else if (isInserting) {
      context.missing(_queryMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('target_price')) {
      context.handle(
        _targetPriceMeta,
        targetPrice.isAcceptableOrUnknown(
          data['target_price']!,
          _targetPriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetPriceMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PriceAlert map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PriceAlert(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      query: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}query'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      targetPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_price'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PriceAlertsTable createAlias(String alias) {
    return $PriceAlertsTable(attachedDatabase, alias);
  }
}

class PriceAlert extends DataClass implements Insertable<PriceAlert> {
  final int id;
  final String query;
  final String mode;
  final int targetPrice;
  final bool isActive;
  final DateTime createdAt;
  const PriceAlert({
    required this.id,
    required this.query,
    required this.mode,
    required this.targetPrice,
    required this.isActive,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['query'] = Variable<String>(query);
    map['mode'] = Variable<String>(mode);
    map['target_price'] = Variable<int>(targetPrice);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PriceAlertsCompanion toCompanion(bool nullToAbsent) {
    return PriceAlertsCompanion(
      id: Value(id),
      query: Value(query),
      mode: Value(mode),
      targetPrice: Value(targetPrice),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory PriceAlert.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PriceAlert(
      id: serializer.fromJson<int>(json['id']),
      query: serializer.fromJson<String>(json['query']),
      mode: serializer.fromJson<String>(json['mode']),
      targetPrice: serializer.fromJson<int>(json['targetPrice']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'query': serializer.toJson<String>(query),
      'mode': serializer.toJson<String>(mode),
      'targetPrice': serializer.toJson<int>(targetPrice),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PriceAlert copyWith({
    int? id,
    String? query,
    String? mode,
    int? targetPrice,
    bool? isActive,
    DateTime? createdAt,
  }) => PriceAlert(
    id: id ?? this.id,
    query: query ?? this.query,
    mode: mode ?? this.mode,
    targetPrice: targetPrice ?? this.targetPrice,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
  PriceAlert copyWithCompanion(PriceAlertsCompanion data) {
    return PriceAlert(
      id: data.id.present ? data.id.value : this.id,
      query: data.query.present ? data.query.value : this.query,
      mode: data.mode.present ? data.mode.value : this.mode,
      targetPrice: data.targetPrice.present
          ? data.targetPrice.value
          : this.targetPrice,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PriceAlert(')
          ..write('id: $id, ')
          ..write('query: $query, ')
          ..write('mode: $mode, ')
          ..write('targetPrice: $targetPrice, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, query, mode, targetPrice, isActive, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PriceAlert &&
          other.id == this.id &&
          other.query == this.query &&
          other.mode == this.mode &&
          other.targetPrice == this.targetPrice &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class PriceAlertsCompanion extends UpdateCompanion<PriceAlert> {
  final Value<int> id;
  final Value<String> query;
  final Value<String> mode;
  final Value<int> targetPrice;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  const PriceAlertsCompanion({
    this.id = const Value.absent(),
    this.query = const Value.absent(),
    this.mode = const Value.absent(),
    this.targetPrice = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PriceAlertsCompanion.insert({
    this.id = const Value.absent(),
    required String query,
    required String mode,
    required int targetPrice,
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : query = Value(query),
       mode = Value(mode),
       targetPrice = Value(targetPrice);
  static Insertable<PriceAlert> custom({
    Expression<int>? id,
    Expression<String>? query,
    Expression<String>? mode,
    Expression<int>? targetPrice,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (query != null) 'query': query,
      if (mode != null) 'mode': mode,
      if (targetPrice != null) 'target_price': targetPrice,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PriceAlertsCompanion copyWith({
    Value<int>? id,
    Value<String>? query,
    Value<String>? mode,
    Value<int>? targetPrice,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
  }) {
    return PriceAlertsCompanion(
      id: id ?? this.id,
      query: query ?? this.query,
      mode: mode ?? this.mode,
      targetPrice: targetPrice ?? this.targetPrice,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (query.present) {
      map['query'] = Variable<String>(query.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (targetPrice.present) {
      map['target_price'] = Variable<int>(targetPrice.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PriceAlertsCompanion(')
          ..write('id: $id, ')
          ..write('query: $query, ')
          ..write('mode: $mode, ')
          ..write('targetPrice: $targetPrice, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $CachedResultsTable extends CachedResults
    with TableInfo<$CachedResultsTable, CachedResult> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedResultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [key, payload, cachedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_results';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedResult> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  CachedResult map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedResult(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $CachedResultsTable createAlias(String alias) {
    return $CachedResultsTable(attachedDatabase, alias);
  }
}

class CachedResult extends DataClass implements Insertable<CachedResult> {
  final String key;
  final String payload;
  final DateTime cachedAt;
  const CachedResult({
    required this.key,
    required this.payload,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['payload'] = Variable<String>(payload);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CachedResultsCompanion toCompanion(bool nullToAbsent) {
    return CachedResultsCompanion(
      key: Value(key),
      payload: Value(payload),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedResult.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedResult(
      key: serializer.fromJson<String>(json['key']),
      payload: serializer.fromJson<String>(json['payload']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'payload': serializer.toJson<String>(payload),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CachedResult copyWith({String? key, String? payload, DateTime? cachedAt}) =>
      CachedResult(
        key: key ?? this.key,
        payload: payload ?? this.payload,
        cachedAt: cachedAt ?? this.cachedAt,
      );
  CachedResult copyWithCompanion(CachedResultsCompanion data) {
    return CachedResult(
      key: data.key.present ? data.key.value : this.key,
      payload: data.payload.present ? data.payload.value : this.payload,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedResult(')
          ..write('key: $key, ')
          ..write('payload: $payload, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, payload, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedResult &&
          other.key == this.key &&
          other.payload == this.payload &&
          other.cachedAt == this.cachedAt);
}

class CachedResultsCompanion extends UpdateCompanion<CachedResult> {
  final Value<String> key;
  final Value<String> payload;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const CachedResultsCompanion({
    this.key = const Value.absent(),
    this.payload = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedResultsCompanion.insert({
    required String key,
    required String payload,
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       payload = Value(payload);
  static Insertable<CachedResult> custom({
    Expression<String>? key,
    Expression<String>? payload,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (payload != null) 'payload': payload,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedResultsCompanion copyWith({
    Value<String>? key,
    Value<String>? payload,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return CachedResultsCompanion(
      key: key ?? this.key,
      payload: payload ?? this.payload,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
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
    return (StringBuffer('CachedResultsCompanion(')
          ..write('key: $key, ')
          ..write('payload: $payload, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $HistoryBlocksTable historyBlocks = $HistoryBlocksTable(this);
  late final $WishlistItemsTable wishlistItems = $WishlistItemsTable(this);
  late final $PriceAlertsTable priceAlerts = $PriceAlertsTable(this);
  late final $CachedResultsTable cachedResults = $CachedResultsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    historyBlocks,
    wishlistItems,
    priceAlerts,
    cachedResults,
  ];
}

typedef $$HistoryBlocksTableCreateCompanionBuilder =
    HistoryBlocksCompanion Function({
      Value<int> id,
      required String mode,
      required String query,
      required int inputPrice,
      required double score,
      required String verdict,
      Value<DateTime> createdAt,
      Value<String> dataJson,
      Value<String> prevHash,
      Value<String> hash,
    });
typedef $$HistoryBlocksTableUpdateCompanionBuilder =
    HistoryBlocksCompanion Function({
      Value<int> id,
      Value<String> mode,
      Value<String> query,
      Value<int> inputPrice,
      Value<double> score,
      Value<String> verdict,
      Value<DateTime> createdAt,
      Value<String> dataJson,
      Value<String> prevHash,
      Value<String> hash,
    });

class $$HistoryBlocksTableFilterComposer
    extends Composer<_$AppDatabase, $HistoryBlocksTable> {
  $$HistoryBlocksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get inputPrice => $composableBuilder(
    column: $table.inputPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get verdict => $composableBuilder(
    column: $table.verdict,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dataJson => $composableBuilder(
    column: $table.dataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prevHash => $composableBuilder(
    column: $table.prevHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hash => $composableBuilder(
    column: $table.hash,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HistoryBlocksTableOrderingComposer
    extends Composer<_$AppDatabase, $HistoryBlocksTable> {
  $$HistoryBlocksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get inputPrice => $composableBuilder(
    column: $table.inputPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get verdict => $composableBuilder(
    column: $table.verdict,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dataJson => $composableBuilder(
    column: $table.dataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prevHash => $composableBuilder(
    column: $table.prevHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hash => $composableBuilder(
    column: $table.hash,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HistoryBlocksTableAnnotationComposer
    extends Composer<_$AppDatabase, $HistoryBlocksTable> {
  $$HistoryBlocksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get query =>
      $composableBuilder(column: $table.query, builder: (column) => column);

  GeneratedColumn<int> get inputPrice => $composableBuilder(
    column: $table.inputPrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<String> get verdict =>
      $composableBuilder(column: $table.verdict, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get dataJson =>
      $composableBuilder(column: $table.dataJson, builder: (column) => column);

  GeneratedColumn<String> get prevHash =>
      $composableBuilder(column: $table.prevHash, builder: (column) => column);

  GeneratedColumn<String> get hash =>
      $composableBuilder(column: $table.hash, builder: (column) => column);
}

class $$HistoryBlocksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HistoryBlocksTable,
          HistoryBlock,
          $$HistoryBlocksTableFilterComposer,
          $$HistoryBlocksTableOrderingComposer,
          $$HistoryBlocksTableAnnotationComposer,
          $$HistoryBlocksTableCreateCompanionBuilder,
          $$HistoryBlocksTableUpdateCompanionBuilder,
          (
            HistoryBlock,
            BaseReferences<_$AppDatabase, $HistoryBlocksTable, HistoryBlock>,
          ),
          HistoryBlock,
          PrefetchHooks Function()
        > {
  $$HistoryBlocksTableTableManager(_$AppDatabase db, $HistoryBlocksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HistoryBlocksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HistoryBlocksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HistoryBlocksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String> query = const Value.absent(),
                Value<int> inputPrice = const Value.absent(),
                Value<double> score = const Value.absent(),
                Value<String> verdict = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> dataJson = const Value.absent(),
                Value<String> prevHash = const Value.absent(),
                Value<String> hash = const Value.absent(),
              }) => HistoryBlocksCompanion(
                id: id,
                mode: mode,
                query: query,
                inputPrice: inputPrice,
                score: score,
                verdict: verdict,
                createdAt: createdAt,
                dataJson: dataJson,
                prevHash: prevHash,
                hash: hash,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String mode,
                required String query,
                required int inputPrice,
                required double score,
                required String verdict,
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> dataJson = const Value.absent(),
                Value<String> prevHash = const Value.absent(),
                Value<String> hash = const Value.absent(),
              }) => HistoryBlocksCompanion.insert(
                id: id,
                mode: mode,
                query: query,
                inputPrice: inputPrice,
                score: score,
                verdict: verdict,
                createdAt: createdAt,
                dataJson: dataJson,
                prevHash: prevHash,
                hash: hash,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HistoryBlocksTable, HistoryBlock>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $HistoryBlocksTable,
                    HistoryBlock
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HistoryBlocksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HistoryBlocksTable,
      HistoryBlock,
      $$HistoryBlocksTableFilterComposer,
      $$HistoryBlocksTableOrderingComposer,
      $$HistoryBlocksTableAnnotationComposer,
      $$HistoryBlocksTableCreateCompanionBuilder,
      $$HistoryBlocksTableUpdateCompanionBuilder,
      (
        HistoryBlock,
        BaseReferences<_$AppDatabase, $HistoryBlocksTable, HistoryBlock>,
      ),
      HistoryBlock,
      PrefetchHooks Function()
    >;
typedef $$WishlistItemsTableCreateCompanionBuilder =
    WishlistItemsCompanion Function({
      Value<int> id,
      required String query,
      required String mode,
      Value<int?> targetPrice,
      Value<DateTime> createdAt,
    });
typedef $$WishlistItemsTableUpdateCompanionBuilder =
    WishlistItemsCompanion Function({
      Value<int> id,
      Value<String> query,
      Value<String> mode,
      Value<int?> targetPrice,
      Value<DateTime> createdAt,
    });

class $$WishlistItemsTableFilterComposer
    extends Composer<_$AppDatabase, $WishlistItemsTable> {
  $$WishlistItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetPrice => $composableBuilder(
    column: $table.targetPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WishlistItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $WishlistItemsTable> {
  $$WishlistItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetPrice => $composableBuilder(
    column: $table.targetPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WishlistItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WishlistItemsTable> {
  $$WishlistItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get query =>
      $composableBuilder(column: $table.query, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<int> get targetPrice => $composableBuilder(
    column: $table.targetPrice,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$WishlistItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WishlistItemsTable,
          WishlistItem,
          $$WishlistItemsTableFilterComposer,
          $$WishlistItemsTableOrderingComposer,
          $$WishlistItemsTableAnnotationComposer,
          $$WishlistItemsTableCreateCompanionBuilder,
          $$WishlistItemsTableUpdateCompanionBuilder,
          (
            WishlistItem,
            BaseReferences<_$AppDatabase, $WishlistItemsTable, WishlistItem>,
          ),
          WishlistItem,
          PrefetchHooks Function()
        > {
  $$WishlistItemsTableTableManager(_$AppDatabase db, $WishlistItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WishlistItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WishlistItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WishlistItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> query = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<int?> targetPrice = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => WishlistItemsCompanion(
                id: id,
                query: query,
                mode: mode,
                targetPrice: targetPrice,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String query,
                required String mode,
                Value<int?> targetPrice = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => WishlistItemsCompanion.insert(
                id: id,
                query: query,
                mode: mode,
                targetPrice: targetPrice,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WishlistItemsTable, WishlistItem>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $WishlistItemsTable,
                    WishlistItem
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WishlistItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WishlistItemsTable,
      WishlistItem,
      $$WishlistItemsTableFilterComposer,
      $$WishlistItemsTableOrderingComposer,
      $$WishlistItemsTableAnnotationComposer,
      $$WishlistItemsTableCreateCompanionBuilder,
      $$WishlistItemsTableUpdateCompanionBuilder,
      (
        WishlistItem,
        BaseReferences<_$AppDatabase, $WishlistItemsTable, WishlistItem>,
      ),
      WishlistItem,
      PrefetchHooks Function()
    >;
typedef $$PriceAlertsTableCreateCompanionBuilder =
    PriceAlertsCompanion Function({
      Value<int> id,
      required String query,
      required String mode,
      required int targetPrice,
      Value<bool> isActive,
      Value<DateTime> createdAt,
    });
typedef $$PriceAlertsTableUpdateCompanionBuilder =
    PriceAlertsCompanion Function({
      Value<int> id,
      Value<String> query,
      Value<String> mode,
      Value<int> targetPrice,
      Value<bool> isActive,
      Value<DateTime> createdAt,
    });

class $$PriceAlertsTableFilterComposer
    extends Composer<_$AppDatabase, $PriceAlertsTable> {
  $$PriceAlertsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetPrice => $composableBuilder(
    column: $table.targetPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PriceAlertsTableOrderingComposer
    extends Composer<_$AppDatabase, $PriceAlertsTable> {
  $$PriceAlertsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get query => $composableBuilder(
    column: $table.query,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetPrice => $composableBuilder(
    column: $table.targetPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PriceAlertsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PriceAlertsTable> {
  $$PriceAlertsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get query =>
      $composableBuilder(column: $table.query, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<int> get targetPrice => $composableBuilder(
    column: $table.targetPrice,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PriceAlertsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PriceAlertsTable,
          PriceAlert,
          $$PriceAlertsTableFilterComposer,
          $$PriceAlertsTableOrderingComposer,
          $$PriceAlertsTableAnnotationComposer,
          $$PriceAlertsTableCreateCompanionBuilder,
          $$PriceAlertsTableUpdateCompanionBuilder,
          (
            PriceAlert,
            BaseReferences<_$AppDatabase, $PriceAlertsTable, PriceAlert>,
          ),
          PriceAlert,
          PrefetchHooks Function()
        > {
  $$PriceAlertsTableTableManager(_$AppDatabase db, $PriceAlertsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PriceAlertsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PriceAlertsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PriceAlertsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> query = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<int> targetPrice = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PriceAlertsCompanion(
                id: id,
                query: query,
                mode: mode,
                targetPrice: targetPrice,
                isActive: isActive,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String query,
                required String mode,
                required int targetPrice,
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PriceAlertsCompanion.insert(
                id: id,
                query: query,
                mode: mode,
                targetPrice: targetPrice,
                isActive: isActive,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PriceAlertsTable, PriceAlert>(table),
                  BaseReferences<_$AppDatabase, $PriceAlertsTable, PriceAlert>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PriceAlertsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PriceAlertsTable,
      PriceAlert,
      $$PriceAlertsTableFilterComposer,
      $$PriceAlertsTableOrderingComposer,
      $$PriceAlertsTableAnnotationComposer,
      $$PriceAlertsTableCreateCompanionBuilder,
      $$PriceAlertsTableUpdateCompanionBuilder,
      (
        PriceAlert,
        BaseReferences<_$AppDatabase, $PriceAlertsTable, PriceAlert>,
      ),
      PriceAlert,
      PrefetchHooks Function()
    >;
typedef $$CachedResultsTableCreateCompanionBuilder =
    CachedResultsCompanion Function({
      required String key,
      required String payload,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });
typedef $$CachedResultsTableUpdateCompanionBuilder =
    CachedResultsCompanion Function({
      Value<String> key,
      Value<String> payload,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$CachedResultsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedResultsTable> {
  $$CachedResultsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedResultsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedResultsTable> {
  $$CachedResultsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedResultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedResultsTable> {
  $$CachedResultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CachedResultsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedResultsTable,
          CachedResult,
          $$CachedResultsTableFilterComposer,
          $$CachedResultsTableOrderingComposer,
          $$CachedResultsTableAnnotationComposer,
          $$CachedResultsTableCreateCompanionBuilder,
          $$CachedResultsTableUpdateCompanionBuilder,
          (
            CachedResult,
            BaseReferences<_$AppDatabase, $CachedResultsTable, CachedResult>,
          ),
          CachedResult,
          PrefetchHooks Function()
        > {
  $$CachedResultsTableTableManager(_$AppDatabase db, $CachedResultsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedResultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedResultsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedResultsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedResultsCompanion(
                key: key,
                payload: payload,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String payload,
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedResultsCompanion.insert(
                key: key,
                payload: payload,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CachedResultsTable, CachedResult>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CachedResultsTable,
                    CachedResult
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedResultsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedResultsTable,
      CachedResult,
      $$CachedResultsTableFilterComposer,
      $$CachedResultsTableOrderingComposer,
      $$CachedResultsTableAnnotationComposer,
      $$CachedResultsTableCreateCompanionBuilder,
      $$CachedResultsTableUpdateCompanionBuilder,
      (
        CachedResult,
        BaseReferences<_$AppDatabase, $CachedResultsTable, CachedResult>,
      ),
      CachedResult,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$HistoryBlocksTableTableManager get historyBlocks =>
      $$HistoryBlocksTableTableManager(_db, _db.historyBlocks);
  $$WishlistItemsTableTableManager get wishlistItems =>
      $$WishlistItemsTableTableManager(_db, _db.wishlistItems);
  $$PriceAlertsTableTableManager get priceAlerts =>
      $$PriceAlertsTableTableManager(_db, _db.priceAlerts);
  $$CachedResultsTableTableManager get cachedResults =>
      $$CachedResultsTableTableManager(_db, _db.cachedResults);
}
