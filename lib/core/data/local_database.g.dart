// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_database.dart';

// ignore_for_file: type=lint
class $CachedProfilesTable extends CachedProfiles
    with TableInfo<$CachedProfilesTable, CachedProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<String?, String> email =
      GeneratedColumn<String>('email', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<String?>($CachedProfilesTable.$converteremail);
  @override
  late final GeneratedColumnWithTypeConverter<String, String> phone =
      GeneratedColumn<String>('phone', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<String>($CachedProfilesTable.$converterphone);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _profilePicMeta =
      const VerificationMeta('profilePic');
  @override
  late final GeneratedColumn<String> profilePic = GeneratedColumn<String>(
      'profile_pic', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _pointsMeta = const VerificationMeta('points');
  @override
  late final GeneratedColumn<int> points = GeneratedColumn<int>(
      'points', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, email, phone, role, profilePic, points];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_profiles';
  @override
  VerificationContext validateIntegrity(Insertable<CachedProfile> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('profile_pic')) {
      context.handle(
          _profilePicMeta,
          profilePic.isAcceptableOrUnknown(
              data['profile_pic']!, _profilePicMeta));
    }
    if (data.containsKey('points')) {
      context.handle(_pointsMeta,
          points.isAcceptableOrUnknown(data['points']!, _pointsMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedProfile(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      email: $CachedProfilesTable.$converteremail.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])),
      phone: $CachedProfilesTable.$converterphone.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone'])!),
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      profilePic: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}profile_pic']),
      points: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}points'])!,
    );
  }

  @override
  $CachedProfilesTable createAlias(String alias) {
    return $CachedProfilesTable(attachedDatabase, alias);
  }

  static TypeConverter<String?, String?> $converteremail =
      const NullAwareTypeConverter.wrap(EncryptedStringConverter());
  static JsonTypeConverter2<String, String, String> $converterphone =
      const EncryptedStringConverter();
}

class CachedProfile extends DataClass implements Insertable<CachedProfile> {
  final String id;
  final String name;
  final String? email;
  final String phone;
  final String role;
  final String? profilePic;
  final int points;
  const CachedProfile(
      {required this.id,
      required this.name,
      this.email,
      required this.phone,
      required this.role,
      this.profilePic,
      required this.points});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || email != null) {
      map['email'] =
          Variable<String>($CachedProfilesTable.$converteremail.toSql(email));
    }
    {
      map['phone'] =
          Variable<String>($CachedProfilesTable.$converterphone.toSql(phone));
    }
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || profilePic != null) {
      map['profile_pic'] = Variable<String>(profilePic);
    }
    map['points'] = Variable<int>(points);
    return map;
  }

  CachedProfilesCompanion toCompanion(bool nullToAbsent) {
    return CachedProfilesCompanion(
      id: Value(id),
      name: Value(name),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      phone: Value(phone),
      role: Value(role),
      profilePic: profilePic == null && nullToAbsent
          ? const Value.absent()
          : Value(profilePic),
      points: Value(points),
    );
  }

  factory CachedProfile.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedProfile(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String?>(json['email']),
      phone: $CachedProfilesTable.$converterphone
          .fromJson(serializer.fromJson<String>(json['phone'])),
      role: serializer.fromJson<String>(json['role']),
      profilePic: serializer.fromJson<String?>(json['profilePic']),
      points: serializer.fromJson<int>(json['points']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String?>(email),
      'phone': serializer
          .toJson<String>($CachedProfilesTable.$converterphone.toJson(phone)),
      'role': serializer.toJson<String>(role),
      'profilePic': serializer.toJson<String?>(profilePic),
      'points': serializer.toJson<int>(points),
    };
  }

  CachedProfile copyWith(
          {String? id,
          String? name,
          Value<String?> email = const Value.absent(),
          String? phone,
          String? role,
          Value<String?> profilePic = const Value.absent(),
          int? points}) =>
      CachedProfile(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email.present ? email.value : this.email,
        phone: phone ?? this.phone,
        role: role ?? this.role,
        profilePic: profilePic.present ? profilePic.value : this.profilePic,
        points: points ?? this.points,
      );
  CachedProfile copyWithCompanion(CachedProfilesCompanion data) {
    return CachedProfile(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      phone: data.phone.present ? data.phone.value : this.phone,
      role: data.role.present ? data.role.value : this.role,
      profilePic:
          data.profilePic.present ? data.profilePic.value : this.profilePic,
      points: data.points.present ? data.points.value : this.points,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedProfile(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('role: $role, ')
          ..write('profilePic: $profilePic, ')
          ..write('points: $points')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, email, phone, role, profilePic, points);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedProfile &&
          other.id == this.id &&
          other.name == this.name &&
          other.email == this.email &&
          other.phone == this.phone &&
          other.role == this.role &&
          other.profilePic == this.profilePic &&
          other.points == this.points);
}

class CachedProfilesCompanion extends UpdateCompanion<CachedProfile> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> email;
  final Value<String> phone;
  final Value<String> role;
  final Value<String?> profilePic;
  final Value<int> points;
  final Value<int> rowid;
  const CachedProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.role = const Value.absent(),
    this.profilePic = const Value.absent(),
    this.points = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedProfilesCompanion.insert({
    required String id,
    required String name,
    this.email = const Value.absent(),
    required String phone,
    required String role,
    this.profilePic = const Value.absent(),
    this.points = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        phone = Value(phone),
        role = Value(role);
  static Insertable<CachedProfile> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? email,
    Expression<String>? phone,
    Expression<String>? role,
    Expression<String>? profilePic,
    Expression<int>? points,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (role != null) 'role': role,
      if (profilePic != null) 'profile_pic': profilePic,
      if (points != null) 'points': points,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedProfilesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? email,
      Value<String>? phone,
      Value<String>? role,
      Value<String?>? profilePic,
      Value<int>? points,
      Value<int>? rowid}) {
    return CachedProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      profilePic: profilePic ?? this.profilePic,
      points: points ?? this.points,
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
    if (email.present) {
      map['email'] = Variable<String>(
          $CachedProfilesTable.$converteremail.toSql(email.value));
    }
    if (phone.present) {
      map['phone'] = Variable<String>(
          $CachedProfilesTable.$converterphone.toSql(phone.value));
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (profilePic.present) {
      map['profile_pic'] = Variable<String>(profilePic.value);
    }
    if (points.present) {
      map['points'] = Variable<int>(points.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('role: $role, ')
          ..write('profilePic: $profilePic, ')
          ..write('points: $points, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _idempotencyKeyMeta =
      const VerificationMeta('idempotencyKey');
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
      'idempotency_key', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
      'action', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _attemptsMeta =
      const VerificationMeta('attempts');
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
      'attempts', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _nextRetryAtMeta =
      const VerificationMeta('nextRetryAt');
  @override
  late final GeneratedColumn<DateTime> nextRetryAt = GeneratedColumn<DateTime>(
      'next_retry_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        idempotencyKey,
        entityType,
        action,
        payload,
        createdAt,
        attempts,
        nextRetryAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(Insertable<SyncQueueData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
          _idempotencyKeyMeta,
          idempotencyKey.isAcceptableOrUnknown(
              data['idempotency_key']!, _idempotencyKeyMeta));
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('action')) {
      context.handle(_actionMeta,
          action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('attempts')) {
      context.handle(_attemptsMeta,
          attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta));
    }
    if (data.containsKey('next_retry_at')) {
      context.handle(
          _nextRetryAtMeta,
          nextRetryAt.isAcceptableOrUnknown(
              data['next_retry_at']!, _nextRetryAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      idempotencyKey: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}idempotency_key'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      action: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      attempts: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempts'])!,
      nextRetryAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}next_retry_at']),
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  final int id;
  final String idempotencyKey;
  final String entityType;
  final String action;
  final String payload;
  final DateTime createdAt;
  final int attempts;
  final DateTime? nextRetryAt;
  const SyncQueueData(
      {required this.id,
      required this.idempotencyKey,
      required this.entityType,
      required this.action,
      required this.payload,
      required this.createdAt,
      required this.attempts,
      this.nextRetryAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['entity_type'] = Variable<String>(entityType);
    map['action'] = Variable<String>(action);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || nextRetryAt != null) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt);
    }
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      idempotencyKey: Value(idempotencyKey),
      entityType: Value(entityType),
      action: Value(action),
      payload: Value(payload),
      createdAt: Value(createdAt),
      attempts: Value(attempts),
      nextRetryAt: nextRetryAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextRetryAt),
    );
  }

  factory SyncQueueData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      id: serializer.fromJson<int>(json['id']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      entityType: serializer.fromJson<String>(json['entityType']),
      action: serializer.fromJson<String>(json['action']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      attempts: serializer.fromJson<int>(json['attempts']),
      nextRetryAt: serializer.fromJson<DateTime?>(json['nextRetryAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'entityType': serializer.toJson<String>(entityType),
      'action': serializer.toJson<String>(action),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'attempts': serializer.toJson<int>(attempts),
      'nextRetryAt': serializer.toJson<DateTime?>(nextRetryAt),
    };
  }

  SyncQueueData copyWith(
          {int? id,
          String? idempotencyKey,
          String? entityType,
          String? action,
          String? payload,
          DateTime? createdAt,
          int? attempts,
          Value<DateTime?> nextRetryAt = const Value.absent()}) =>
      SyncQueueData(
        id: id ?? this.id,
        idempotencyKey: idempotencyKey ?? this.idempotencyKey,
        entityType: entityType ?? this.entityType,
        action: action ?? this.action,
        payload: payload ?? this.payload,
        createdAt: createdAt ?? this.createdAt,
        attempts: attempts ?? this.attempts,
        nextRetryAt: nextRetryAt.present ? nextRetryAt.value : this.nextRetryAt,
      );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      action: data.action.present ? data.action.value : this.action,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      nextRetryAt:
          data.nextRetryAt.present ? data.nextRetryAt.value : this.nextRetryAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('id: $id, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('entityType: $entityType, ')
          ..write('action: $action, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('nextRetryAt: $nextRetryAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, idempotencyKey, entityType, action,
      payload, createdAt, attempts, nextRetryAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.id == this.id &&
          other.idempotencyKey == this.idempotencyKey &&
          other.entityType == this.entityType &&
          other.action == this.action &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.attempts == this.attempts &&
          other.nextRetryAt == this.nextRetryAt);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<int> id;
  final Value<String> idempotencyKey;
  final Value<String> entityType;
  final Value<String> action;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<int> attempts;
  final Value<DateTime?> nextRetryAt;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.entityType = const Value.absent(),
    this.action = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String idempotencyKey,
    required String entityType,
    required String action,
    required String payload,
    this.createdAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
  })  : idempotencyKey = Value(idempotencyKey),
        entityType = Value(entityType),
        action = Value(action),
        payload = Value(payload);
  static Insertable<SyncQueueData> custom({
    Expression<int>? id,
    Expression<String>? idempotencyKey,
    Expression<String>? entityType,
    Expression<String>? action,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<int>? attempts,
    Expression<DateTime>? nextRetryAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (entityType != null) 'entity_type': entityType,
      if (action != null) 'action': action,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (attempts != null) 'attempts': attempts,
      if (nextRetryAt != null) 'next_retry_at': nextRetryAt,
    });
  }

  SyncQueueCompanion copyWith(
      {Value<int>? id,
      Value<String>? idempotencyKey,
      Value<String>? entityType,
      Value<String>? action,
      Value<String>? payload,
      Value<DateTime>? createdAt,
      Value<int>? attempts,
      Value<DateTime?>? nextRetryAt}) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      entityType: entityType ?? this.entityType,
      action: action ?? this.action,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      attempts: attempts ?? this.attempts,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (nextRetryAt.present) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('entityType: $entityType, ')
          ..write('action: $action, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('nextRetryAt: $nextRetryAt')
          ..write(')'))
        .toString();
  }
}

class $DeadLetterQueueTable extends DeadLetterQueue
    with TableInfo<$DeadLetterQueueTable, DeadLetterQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeadLetterQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _idempotencyKeyMeta =
      const VerificationMeta('idempotencyKey');
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
      'idempotency_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
      'action', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _attemptsMeta =
      const VerificationMeta('attempts');
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
      'attempts', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
      'error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _failedAtMeta =
      const VerificationMeta('failedAt');
  @override
  late final GeneratedColumn<DateTime> failedAt = GeneratedColumn<DateTime>(
      'failed_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        idempotencyKey,
        entityType,
        action,
        payload,
        createdAt,
        attempts,
        error,
        failedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dead_letter_queue';
  @override
  VerificationContext validateIntegrity(
      Insertable<DeadLetterQueueData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
          _idempotencyKeyMeta,
          idempotencyKey.isAcceptableOrUnknown(
              data['idempotency_key']!, _idempotencyKeyMeta));
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('action')) {
      context.handle(_actionMeta,
          action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(_attemptsMeta,
          attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta));
    } else if (isInserting) {
      context.missing(_attemptsMeta);
    }
    if (data.containsKey('error')) {
      context.handle(
          _errorMeta, error.isAcceptableOrUnknown(data['error']!, _errorMeta));
    }
    if (data.containsKey('failed_at')) {
      context.handle(_failedAtMeta,
          failedAt.isAcceptableOrUnknown(data['failed_at']!, _failedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeadLetterQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeadLetterQueueData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      idempotencyKey: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}idempotency_key'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      action: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      attempts: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempts'])!,
      error: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error']),
      failedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}failed_at'])!,
    );
  }

  @override
  $DeadLetterQueueTable createAlias(String alias) {
    return $DeadLetterQueueTable(attachedDatabase, alias);
  }
}

class DeadLetterQueueData extends DataClass
    implements Insertable<DeadLetterQueueData> {
  final int id;
  final String idempotencyKey;
  final String entityType;
  final String action;
  final String payload;
  final DateTime createdAt;
  final int attempts;
  final String? error;
  final DateTime failedAt;
  const DeadLetterQueueData(
      {required this.id,
      required this.idempotencyKey,
      required this.entityType,
      required this.action,
      required this.payload,
      required this.createdAt,
      required this.attempts,
      this.error,
      required this.failedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['entity_type'] = Variable<String>(entityType);
    map['action'] = Variable<String>(action);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    map['failed_at'] = Variable<DateTime>(failedAt);
    return map;
  }

  DeadLetterQueueCompanion toCompanion(bool nullToAbsent) {
    return DeadLetterQueueCompanion(
      id: Value(id),
      idempotencyKey: Value(idempotencyKey),
      entityType: Value(entityType),
      action: Value(action),
      payload: Value(payload),
      createdAt: Value(createdAt),
      attempts: Value(attempts),
      error:
          error == null && nullToAbsent ? const Value.absent() : Value(error),
      failedAt: Value(failedAt),
    );
  }

  factory DeadLetterQueueData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeadLetterQueueData(
      id: serializer.fromJson<int>(json['id']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      entityType: serializer.fromJson<String>(json['entityType']),
      action: serializer.fromJson<String>(json['action']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      attempts: serializer.fromJson<int>(json['attempts']),
      error: serializer.fromJson<String?>(json['error']),
      failedAt: serializer.fromJson<DateTime>(json['failedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'entityType': serializer.toJson<String>(entityType),
      'action': serializer.toJson<String>(action),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'attempts': serializer.toJson<int>(attempts),
      'error': serializer.toJson<String?>(error),
      'failedAt': serializer.toJson<DateTime>(failedAt),
    };
  }

  DeadLetterQueueData copyWith(
          {int? id,
          String? idempotencyKey,
          String? entityType,
          String? action,
          String? payload,
          DateTime? createdAt,
          int? attempts,
          Value<String?> error = const Value.absent(),
          DateTime? failedAt}) =>
      DeadLetterQueueData(
        id: id ?? this.id,
        idempotencyKey: idempotencyKey ?? this.idempotencyKey,
        entityType: entityType ?? this.entityType,
        action: action ?? this.action,
        payload: payload ?? this.payload,
        createdAt: createdAt ?? this.createdAt,
        attempts: attempts ?? this.attempts,
        error: error.present ? error.value : this.error,
        failedAt: failedAt ?? this.failedAt,
      );
  DeadLetterQueueData copyWithCompanion(DeadLetterQueueCompanion data) {
    return DeadLetterQueueData(
      id: data.id.present ? data.id.value : this.id,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      action: data.action.present ? data.action.value : this.action,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      error: data.error.present ? data.error.value : this.error,
      failedAt: data.failedAt.present ? data.failedAt.value : this.failedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeadLetterQueueData(')
          ..write('id: $id, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('entityType: $entityType, ')
          ..write('action: $action, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('error: $error, ')
          ..write('failedAt: $failedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, idempotencyKey, entityType, action,
      payload, createdAt, attempts, error, failedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeadLetterQueueData &&
          other.id == this.id &&
          other.idempotencyKey == this.idempotencyKey &&
          other.entityType == this.entityType &&
          other.action == this.action &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.attempts == this.attempts &&
          other.error == this.error &&
          other.failedAt == this.failedAt);
}

class DeadLetterQueueCompanion extends UpdateCompanion<DeadLetterQueueData> {
  final Value<int> id;
  final Value<String> idempotencyKey;
  final Value<String> entityType;
  final Value<String> action;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<int> attempts;
  final Value<String?> error;
  final Value<DateTime> failedAt;
  const DeadLetterQueueCompanion({
    this.id = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.entityType = const Value.absent(),
    this.action = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.error = const Value.absent(),
    this.failedAt = const Value.absent(),
  });
  DeadLetterQueueCompanion.insert({
    this.id = const Value.absent(),
    required String idempotencyKey,
    required String entityType,
    required String action,
    required String payload,
    required DateTime createdAt,
    required int attempts,
    this.error = const Value.absent(),
    this.failedAt = const Value.absent(),
  })  : idempotencyKey = Value(idempotencyKey),
        entityType = Value(entityType),
        action = Value(action),
        payload = Value(payload),
        createdAt = Value(createdAt),
        attempts = Value(attempts);
  static Insertable<DeadLetterQueueData> custom({
    Expression<int>? id,
    Expression<String>? idempotencyKey,
    Expression<String>? entityType,
    Expression<String>? action,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<int>? attempts,
    Expression<String>? error,
    Expression<DateTime>? failedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (entityType != null) 'entity_type': entityType,
      if (action != null) 'action': action,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (attempts != null) 'attempts': attempts,
      if (error != null) 'error': error,
      if (failedAt != null) 'failed_at': failedAt,
    });
  }

  DeadLetterQueueCompanion copyWith(
      {Value<int>? id,
      Value<String>? idempotencyKey,
      Value<String>? entityType,
      Value<String>? action,
      Value<String>? payload,
      Value<DateTime>? createdAt,
      Value<int>? attempts,
      Value<String?>? error,
      Value<DateTime>? failedAt}) {
    return DeadLetterQueueCompanion(
      id: id ?? this.id,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      entityType: entityType ?? this.entityType,
      action: action ?? this.action,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      attempts: attempts ?? this.attempts,
      error: error ?? this.error,
      failedAt: failedAt ?? this.failedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (failedAt.present) {
      map['failed_at'] = Variable<DateTime>(failedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeadLetterQueueCompanion(')
          ..write('id: $id, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('entityType: $entityType, ')
          ..write('action: $action, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('error: $error, ')
          ..write('failedAt: $failedAt')
          ..write(')'))
        .toString();
  }
}

class $CachedRidesTable extends CachedRides
    with TableInfo<$CachedRidesTable, CachedRide> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedRidesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pickupAddressMeta =
      const VerificationMeta('pickupAddress');
  @override
  late final GeneratedColumn<String> pickupAddress = GeneratedColumn<String>(
      'pickup_address', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _destinationAddressMeta =
      const VerificationMeta('destinationAddress');
  @override
  late final GeneratedColumn<String> destinationAddress =
      GeneratedColumn<String>('destination_address', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fareMeta = const VerificationMeta('fare');
  @override
  late final GeneratedColumn<double> fare = GeneratedColumn<double>(
      'fare', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, pickupAddress, destinationAddress, fare, status, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_rides';
  @override
  VerificationContext validateIntegrity(Insertable<CachedRide> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('pickup_address')) {
      context.handle(
          _pickupAddressMeta,
          pickupAddress.isAcceptableOrUnknown(
              data['pickup_address']!, _pickupAddressMeta));
    } else if (isInserting) {
      context.missing(_pickupAddressMeta);
    }
    if (data.containsKey('destination_address')) {
      context.handle(
          _destinationAddressMeta,
          destinationAddress.isAcceptableOrUnknown(
              data['destination_address']!, _destinationAddressMeta));
    } else if (isInserting) {
      context.missing(_destinationAddressMeta);
    }
    if (data.containsKey('fare')) {
      context.handle(
          _fareMeta, fare.isAcceptableOrUnknown(data['fare']!, _fareMeta));
    } else if (isInserting) {
      context.missing(_fareMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedRide map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedRide(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      pickupAddress: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pickup_address'])!,
      destinationAddress: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}destination_address'])!,
      fare: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}fare'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $CachedRidesTable createAlias(String alias) {
    return $CachedRidesTable(attachedDatabase, alias);
  }
}

class CachedRide extends DataClass implements Insertable<CachedRide> {
  final String id;
  final String pickupAddress;
  final String destinationAddress;
  final double fare;
  final String status;
  final DateTime createdAt;
  const CachedRide(
      {required this.id,
      required this.pickupAddress,
      required this.destinationAddress,
      required this.fare,
      required this.status,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['pickup_address'] = Variable<String>(pickupAddress);
    map['destination_address'] = Variable<String>(destinationAddress);
    map['fare'] = Variable<double>(fare);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CachedRidesCompanion toCompanion(bool nullToAbsent) {
    return CachedRidesCompanion(
      id: Value(id),
      pickupAddress: Value(pickupAddress),
      destinationAddress: Value(destinationAddress),
      fare: Value(fare),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory CachedRide.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedRide(
      id: serializer.fromJson<String>(json['id']),
      pickupAddress: serializer.fromJson<String>(json['pickupAddress']),
      destinationAddress:
          serializer.fromJson<String>(json['destinationAddress']),
      fare: serializer.fromJson<double>(json['fare']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'pickupAddress': serializer.toJson<String>(pickupAddress),
      'destinationAddress': serializer.toJson<String>(destinationAddress),
      'fare': serializer.toJson<double>(fare),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CachedRide copyWith(
          {String? id,
          String? pickupAddress,
          String? destinationAddress,
          double? fare,
          String? status,
          DateTime? createdAt}) =>
      CachedRide(
        id: id ?? this.id,
        pickupAddress: pickupAddress ?? this.pickupAddress,
        destinationAddress: destinationAddress ?? this.destinationAddress,
        fare: fare ?? this.fare,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
      );
  CachedRide copyWithCompanion(CachedRidesCompanion data) {
    return CachedRide(
      id: data.id.present ? data.id.value : this.id,
      pickupAddress: data.pickupAddress.present
          ? data.pickupAddress.value
          : this.pickupAddress,
      destinationAddress: data.destinationAddress.present
          ? data.destinationAddress.value
          : this.destinationAddress,
      fare: data.fare.present ? data.fare.value : this.fare,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedRide(')
          ..write('id: $id, ')
          ..write('pickupAddress: $pickupAddress, ')
          ..write('destinationAddress: $destinationAddress, ')
          ..write('fare: $fare, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, pickupAddress, destinationAddress, fare, status, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedRide &&
          other.id == this.id &&
          other.pickupAddress == this.pickupAddress &&
          other.destinationAddress == this.destinationAddress &&
          other.fare == this.fare &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class CachedRidesCompanion extends UpdateCompanion<CachedRide> {
  final Value<String> id;
  final Value<String> pickupAddress;
  final Value<String> destinationAddress;
  final Value<double> fare;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CachedRidesCompanion({
    this.id = const Value.absent(),
    this.pickupAddress = const Value.absent(),
    this.destinationAddress = const Value.absent(),
    this.fare = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedRidesCompanion.insert({
    required String id,
    required String pickupAddress,
    required String destinationAddress,
    required double fare,
    required String status,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        pickupAddress = Value(pickupAddress),
        destinationAddress = Value(destinationAddress),
        fare = Value(fare),
        status = Value(status),
        createdAt = Value(createdAt);
  static Insertable<CachedRide> custom({
    Expression<String>? id,
    Expression<String>? pickupAddress,
    Expression<String>? destinationAddress,
    Expression<double>? fare,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pickupAddress != null) 'pickup_address': pickupAddress,
      if (destinationAddress != null) 'destination_address': destinationAddress,
      if (fare != null) 'fare': fare,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedRidesCompanion copyWith(
      {Value<String>? id,
      Value<String>? pickupAddress,
      Value<String>? destinationAddress,
      Value<double>? fare,
      Value<String>? status,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return CachedRidesCompanion(
      id: id ?? this.id,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      fare: fare ?? this.fare,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (pickupAddress.present) {
      map['pickup_address'] = Variable<String>(pickupAddress.value);
    }
    if (destinationAddress.present) {
      map['destination_address'] = Variable<String>(destinationAddress.value);
    }
    if (fare.present) {
      map['fare'] = Variable<double>(fare.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
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
    return (StringBuffer('CachedRidesCompanion(')
          ..write('id: $id, ')
          ..write('pickupAddress: $pickupAddress, ')
          ..write('destinationAddress: $destinationAddress, ')
          ..write('fare: $fare, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedCategoriesTable extends CachedCategories
    with TableInfo<$CachedCategoriesTable, CachedCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
      'icon', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<String> count = GeneratedColumn<String>(
      'count', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, icon, label, count];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_categories';
  @override
  VerificationContext validateIntegrity(Insertable<CachedCategory> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
          _iconMeta, icon.isAcceptableOrUnknown(data['icon']!, _iconMeta));
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('count')) {
      context.handle(
          _countMeta, count.isAcceptableOrUnknown(data['count']!, _countMeta));
    } else if (isInserting) {
      context.missing(_countMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedCategory(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      icon: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label'])!,
      count: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}count'])!,
    );
  }

  @override
  $CachedCategoriesTable createAlias(String alias) {
    return $CachedCategoriesTable(attachedDatabase, alias);
  }
}

class CachedCategory extends DataClass implements Insertable<CachedCategory> {
  final String id;
  final String icon;
  final String label;
  final String count;
  const CachedCategory(
      {required this.id,
      required this.icon,
      required this.label,
      required this.count});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['icon'] = Variable<String>(icon);
    map['label'] = Variable<String>(label);
    map['count'] = Variable<String>(count);
    return map;
  }

  CachedCategoriesCompanion toCompanion(bool nullToAbsent) {
    return CachedCategoriesCompanion(
      id: Value(id),
      icon: Value(icon),
      label: Value(label),
      count: Value(count),
    );
  }

  factory CachedCategory.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedCategory(
      id: serializer.fromJson<String>(json['id']),
      icon: serializer.fromJson<String>(json['icon']),
      label: serializer.fromJson<String>(json['label']),
      count: serializer.fromJson<String>(json['count']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'icon': serializer.toJson<String>(icon),
      'label': serializer.toJson<String>(label),
      'count': serializer.toJson<String>(count),
    };
  }

  CachedCategory copyWith(
          {String? id, String? icon, String? label, String? count}) =>
      CachedCategory(
        id: id ?? this.id,
        icon: icon ?? this.icon,
        label: label ?? this.label,
        count: count ?? this.count,
      );
  CachedCategory copyWithCompanion(CachedCategoriesCompanion data) {
    return CachedCategory(
      id: data.id.present ? data.id.value : this.id,
      icon: data.icon.present ? data.icon.value : this.icon,
      label: data.label.present ? data.label.value : this.label,
      count: data.count.present ? data.count.value : this.count,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedCategory(')
          ..write('id: $id, ')
          ..write('icon: $icon, ')
          ..write('label: $label, ')
          ..write('count: $count')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, icon, label, count);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedCategory &&
          other.id == this.id &&
          other.icon == this.icon &&
          other.label == this.label &&
          other.count == this.count);
}

class CachedCategoriesCompanion extends UpdateCompanion<CachedCategory> {
  final Value<String> id;
  final Value<String> icon;
  final Value<String> label;
  final Value<String> count;
  final Value<int> rowid;
  const CachedCategoriesCompanion({
    this.id = const Value.absent(),
    this.icon = const Value.absent(),
    this.label = const Value.absent(),
    this.count = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedCategoriesCompanion.insert({
    required String id,
    required String icon,
    required String label,
    required String count,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        icon = Value(icon),
        label = Value(label),
        count = Value(count);
  static Insertable<CachedCategory> custom({
    Expression<String>? id,
    Expression<String>? icon,
    Expression<String>? label,
    Expression<String>? count,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (icon != null) 'icon': icon,
      if (label != null) 'label': label,
      if (count != null) 'count': count,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedCategoriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? icon,
      Value<String>? label,
      Value<String>? count,
      Value<int>? rowid}) {
    return CachedCategoriesCompanion(
      id: id ?? this.id,
      icon: icon ?? this.icon,
      label: label ?? this.label,
      count: count ?? this.count,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (count.present) {
      map['count'] = Variable<String>(count.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('icon: $icon, ')
          ..write('label: $label, ')
          ..write('count: $count, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedBannersTable extends CachedBanners
    with TableInfo<$CachedBannersTable, CachedBanner> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedBannersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subtitleMeta =
      const VerificationMeta('subtitle');
  @override
  late final GeneratedColumn<String> subtitle = GeneratedColumn<String>(
      'subtitle', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _imageMeta = const VerificationMeta('image');
  @override
  late final GeneratedColumn<String> image = GeneratedColumn<String>(
      'image', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ctaMeta = const VerificationMeta('cta');
  @override
  late final GeneratedColumn<String> cta = GeneratedColumn<String>(
      'cta', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, title, subtitle, image, cta];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_banners';
  @override
  VerificationContext validateIntegrity(Insertable<CachedBanner> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('subtitle')) {
      context.handle(_subtitleMeta,
          subtitle.isAcceptableOrUnknown(data['subtitle']!, _subtitleMeta));
    } else if (isInserting) {
      context.missing(_subtitleMeta);
    }
    if (data.containsKey('image')) {
      context.handle(
          _imageMeta, image.isAcceptableOrUnknown(data['image']!, _imageMeta));
    } else if (isInserting) {
      context.missing(_imageMeta);
    }
    if (data.containsKey('cta')) {
      context.handle(
          _ctaMeta, cta.isAcceptableOrUnknown(data['cta']!, _ctaMeta));
    } else if (isInserting) {
      context.missing(_ctaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedBanner map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedBanner(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      subtitle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subtitle'])!,
      image: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image'])!,
      cta: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cta'])!,
    );
  }

  @override
  $CachedBannersTable createAlias(String alias) {
    return $CachedBannersTable(attachedDatabase, alias);
  }
}

class CachedBanner extends DataClass implements Insertable<CachedBanner> {
  final String id;
  final String title;
  final String subtitle;
  final String image;
  final String cta;
  const CachedBanner(
      {required this.id,
      required this.title,
      required this.subtitle,
      required this.image,
      required this.cta});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['subtitle'] = Variable<String>(subtitle);
    map['image'] = Variable<String>(image);
    map['cta'] = Variable<String>(cta);
    return map;
  }

  CachedBannersCompanion toCompanion(bool nullToAbsent) {
    return CachedBannersCompanion(
      id: Value(id),
      title: Value(title),
      subtitle: Value(subtitle),
      image: Value(image),
      cta: Value(cta),
    );
  }

  factory CachedBanner.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedBanner(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      subtitle: serializer.fromJson<String>(json['subtitle']),
      image: serializer.fromJson<String>(json['image']),
      cta: serializer.fromJson<String>(json['cta']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'subtitle': serializer.toJson<String>(subtitle),
      'image': serializer.toJson<String>(image),
      'cta': serializer.toJson<String>(cta),
    };
  }

  CachedBanner copyWith(
          {String? id,
          String? title,
          String? subtitle,
          String? image,
          String? cta}) =>
      CachedBanner(
        id: id ?? this.id,
        title: title ?? this.title,
        subtitle: subtitle ?? this.subtitle,
        image: image ?? this.image,
        cta: cta ?? this.cta,
      );
  CachedBanner copyWithCompanion(CachedBannersCompanion data) {
    return CachedBanner(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      subtitle: data.subtitle.present ? data.subtitle.value : this.subtitle,
      image: data.image.present ? data.image.value : this.image,
      cta: data.cta.present ? data.cta.value : this.cta,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedBanner(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('image: $image, ')
          ..write('cta: $cta')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, subtitle, image, cta);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedBanner &&
          other.id == this.id &&
          other.title == this.title &&
          other.subtitle == this.subtitle &&
          other.image == this.image &&
          other.cta == this.cta);
}

class CachedBannersCompanion extends UpdateCompanion<CachedBanner> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> subtitle;
  final Value<String> image;
  final Value<String> cta;
  final Value<int> rowid;
  const CachedBannersCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.subtitle = const Value.absent(),
    this.image = const Value.absent(),
    this.cta = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedBannersCompanion.insert({
    required String id,
    required String title,
    required String subtitle,
    required String image,
    required String cta,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        subtitle = Value(subtitle),
        image = Value(image),
        cta = Value(cta);
  static Insertable<CachedBanner> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? subtitle,
    Expression<String>? image,
    Expression<String>? cta,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (subtitle != null) 'subtitle': subtitle,
      if (image != null) 'image': image,
      if (cta != null) 'cta': cta,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedBannersCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? subtitle,
      Value<String>? image,
      Value<String>? cta,
      Value<int>? rowid}) {
    return CachedBannersCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      image: image ?? this.image,
      cta: cta ?? this.cta,
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
    if (subtitle.present) {
      map['subtitle'] = Variable<String>(subtitle.value);
    }
    if (image.present) {
      map['image'] = Variable<String>(image.value);
    }
    if (cta.present) {
      map['cta'] = Variable<String>(cta.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedBannersCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('image: $image, ')
          ..write('cta: $cta, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedTechnicianJobsTable extends CachedTechnicianJobs
    with TableInfo<$CachedTechnicianJobsTable, CachedTechnicianJob> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedTechnicianJobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _vehicleModelMeta =
      const VerificationMeta('vehicleModel');
  @override
  late final GeneratedColumn<String> vehicleModel = GeneratedColumn<String>(
      'vehicle_model', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _vehiclePlateMeta =
      const VerificationMeta('vehiclePlate');
  @override
  late final GeneratedColumn<String> vehiclePlate = GeneratedColumn<String>(
      'vehicle_plate', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serviceTypeMeta =
      const VerificationMeta('serviceType');
  @override
  late final GeneratedColumn<String> serviceType = GeneratedColumn<String>(
      'service_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _packageNameMeta =
      const VerificationMeta('packageName');
  @override
  late final GeneratedColumn<String> packageName = GeneratedColumn<String>(
      'package_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<String> time = GeneratedColumn<String>(
      'time', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _progressMeta =
      const VerificationMeta('progress');
  @override
  late final GeneratedColumn<double> progress = GeneratedColumn<double>(
      'progress', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _checklistMeta =
      const VerificationMeta('checklist');
  @override
  late final GeneratedColumn<String> checklist = GeneratedColumn<String>(
      'checklist', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _partsMeta = const VerificationMeta('parts');
  @override
  late final GeneratedColumn<String> parts = GeneratedColumn<String>(
      'parts', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<String> price = GeneratedColumn<String>(
      'price', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _assignedTechIdMeta =
      const VerificationMeta('assignedTechId');
  @override
  late final GeneratedColumn<String> assignedTechId = GeneratedColumn<String>(
      'assigned_tech_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _customerIdMeta =
      const VerificationMeta('customerId');
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
      'customer_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _serviceBookingIdMeta =
      const VerificationMeta('serviceBookingId');
  @override
  late final GeneratedColumn<String> serviceBookingId = GeneratedColumn<String>(
      'service_booking_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _estimatedCompletionMeta =
      const VerificationMeta('estimatedCompletion');
  @override
  late final GeneratedColumn<String> estimatedCompletion =
      GeneratedColumn<String>('estimated_completion', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        vehicleModel,
        vehiclePlate,
        serviceType,
        packageName,
        date,
        time,
        progress,
        checklist,
        parts,
        status,
        price,
        assignedTechId,
        customerId,
        serviceBookingId,
        estimatedCompletion,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_technician_jobs';
  @override
  VerificationContext validateIntegrity(
      Insertable<CachedTechnicianJob> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('vehicle_model')) {
      context.handle(
          _vehicleModelMeta,
          vehicleModel.isAcceptableOrUnknown(
              data['vehicle_model']!, _vehicleModelMeta));
    } else if (isInserting) {
      context.missing(_vehicleModelMeta);
    }
    if (data.containsKey('vehicle_plate')) {
      context.handle(
          _vehiclePlateMeta,
          vehiclePlate.isAcceptableOrUnknown(
              data['vehicle_plate']!, _vehiclePlateMeta));
    } else if (isInserting) {
      context.missing(_vehiclePlateMeta);
    }
    if (data.containsKey('service_type')) {
      context.handle(
          _serviceTypeMeta,
          serviceType.isAcceptableOrUnknown(
              data['service_type']!, _serviceTypeMeta));
    } else if (isInserting) {
      context.missing(_serviceTypeMeta);
    }
    if (data.containsKey('package_name')) {
      context.handle(
          _packageNameMeta,
          packageName.isAcceptableOrUnknown(
              data['package_name']!, _packageNameMeta));
    } else if (isInserting) {
      context.missing(_packageNameMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('time')) {
      context.handle(
          _timeMeta, time.isAcceptableOrUnknown(data['time']!, _timeMeta));
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    if (data.containsKey('progress')) {
      context.handle(_progressMeta,
          progress.isAcceptableOrUnknown(data['progress']!, _progressMeta));
    } else if (isInserting) {
      context.missing(_progressMeta);
    }
    if (data.containsKey('checklist')) {
      context.handle(_checklistMeta,
          checklist.isAcceptableOrUnknown(data['checklist']!, _checklistMeta));
    } else if (isInserting) {
      context.missing(_checklistMeta);
    }
    if (data.containsKey('parts')) {
      context.handle(
          _partsMeta, parts.isAcceptableOrUnknown(data['parts']!, _partsMeta));
    } else if (isInserting) {
      context.missing(_partsMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
          _priceMeta, price.isAcceptableOrUnknown(data['price']!, _priceMeta));
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('assigned_tech_id')) {
      context.handle(
          _assignedTechIdMeta,
          assignedTechId.isAcceptableOrUnknown(
              data['assigned_tech_id']!, _assignedTechIdMeta));
    }
    if (data.containsKey('customer_id')) {
      context.handle(
          _customerIdMeta,
          customerId.isAcceptableOrUnknown(
              data['customer_id']!, _customerIdMeta));
    }
    if (data.containsKey('service_booking_id')) {
      context.handle(
          _serviceBookingIdMeta,
          serviceBookingId.isAcceptableOrUnknown(
              data['service_booking_id']!, _serviceBookingIdMeta));
    }
    if (data.containsKey('estimated_completion')) {
      context.handle(
          _estimatedCompletionMeta,
          estimatedCompletion.isAcceptableOrUnknown(
              data['estimated_completion']!, _estimatedCompletionMeta));
    } else if (isInserting) {
      context.missing(_estimatedCompletionMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedTechnicianJob map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedTechnicianJob(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      vehicleModel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vehicle_model'])!,
      vehiclePlate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vehicle_plate'])!,
      serviceType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}service_type'])!,
      packageName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}package_name'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      time: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}time'])!,
      progress: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}progress'])!,
      checklist: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}checklist'])!,
      parts: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parts'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      price: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}price'])!,
      assignedTechId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}assigned_tech_id']),
      customerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_id']),
      serviceBookingId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}service_booking_id']),
      estimatedCompletion: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}estimated_completion'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $CachedTechnicianJobsTable createAlias(String alias) {
    return $CachedTechnicianJobsTable(attachedDatabase, alias);
  }
}

class CachedTechnicianJob extends DataClass
    implements Insertable<CachedTechnicianJob> {
  final String id;
  final String vehicleModel;
  final String vehiclePlate;
  final String serviceType;
  final String packageName;
  final String date;
  final String time;
  final double progress;
  final String checklist;
  final String parts;
  final String status;
  final String price;
  final String? assignedTechId;
  final String? customerId;
  final String? serviceBookingId;
  final String estimatedCompletion;
  final DateTime createdAt;
  const CachedTechnicianJob(
      {required this.id,
      required this.vehicleModel,
      required this.vehiclePlate,
      required this.serviceType,
      required this.packageName,
      required this.date,
      required this.time,
      required this.progress,
      required this.checklist,
      required this.parts,
      required this.status,
      required this.price,
      this.assignedTechId,
      this.customerId,
      this.serviceBookingId,
      required this.estimatedCompletion,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['vehicle_model'] = Variable<String>(vehicleModel);
    map['vehicle_plate'] = Variable<String>(vehiclePlate);
    map['service_type'] = Variable<String>(serviceType);
    map['package_name'] = Variable<String>(packageName);
    map['date'] = Variable<String>(date);
    map['time'] = Variable<String>(time);
    map['progress'] = Variable<double>(progress);
    map['checklist'] = Variable<String>(checklist);
    map['parts'] = Variable<String>(parts);
    map['status'] = Variable<String>(status);
    map['price'] = Variable<String>(price);
    if (!nullToAbsent || assignedTechId != null) {
      map['assigned_tech_id'] = Variable<String>(assignedTechId);
    }
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<String>(customerId);
    }
    if (!nullToAbsent || serviceBookingId != null) {
      map['service_booking_id'] = Variable<String>(serviceBookingId);
    }
    map['estimated_completion'] = Variable<String>(estimatedCompletion);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CachedTechnicianJobsCompanion toCompanion(bool nullToAbsent) {
    return CachedTechnicianJobsCompanion(
      id: Value(id),
      vehicleModel: Value(vehicleModel),
      vehiclePlate: Value(vehiclePlate),
      serviceType: Value(serviceType),
      packageName: Value(packageName),
      date: Value(date),
      time: Value(time),
      progress: Value(progress),
      checklist: Value(checklist),
      parts: Value(parts),
      status: Value(status),
      price: Value(price),
      assignedTechId: assignedTechId == null && nullToAbsent
          ? const Value.absent()
          : Value(assignedTechId),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      serviceBookingId: serviceBookingId == null && nullToAbsent
          ? const Value.absent()
          : Value(serviceBookingId),
      estimatedCompletion: Value(estimatedCompletion),
      createdAt: Value(createdAt),
    );
  }

  factory CachedTechnicianJob.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedTechnicianJob(
      id: serializer.fromJson<String>(json['id']),
      vehicleModel: serializer.fromJson<String>(json['vehicleModel']),
      vehiclePlate: serializer.fromJson<String>(json['vehiclePlate']),
      serviceType: serializer.fromJson<String>(json['serviceType']),
      packageName: serializer.fromJson<String>(json['packageName']),
      date: serializer.fromJson<String>(json['date']),
      time: serializer.fromJson<String>(json['time']),
      progress: serializer.fromJson<double>(json['progress']),
      checklist: serializer.fromJson<String>(json['checklist']),
      parts: serializer.fromJson<String>(json['parts']),
      status: serializer.fromJson<String>(json['status']),
      price: serializer.fromJson<String>(json['price']),
      assignedTechId: serializer.fromJson<String?>(json['assignedTechId']),
      customerId: serializer.fromJson<String?>(json['customerId']),
      serviceBookingId: serializer.fromJson<String?>(json['serviceBookingId']),
      estimatedCompletion:
          serializer.fromJson<String>(json['estimatedCompletion']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'vehicleModel': serializer.toJson<String>(vehicleModel),
      'vehiclePlate': serializer.toJson<String>(vehiclePlate),
      'serviceType': serializer.toJson<String>(serviceType),
      'packageName': serializer.toJson<String>(packageName),
      'date': serializer.toJson<String>(date),
      'time': serializer.toJson<String>(time),
      'progress': serializer.toJson<double>(progress),
      'checklist': serializer.toJson<String>(checklist),
      'parts': serializer.toJson<String>(parts),
      'status': serializer.toJson<String>(status),
      'price': serializer.toJson<String>(price),
      'assignedTechId': serializer.toJson<String?>(assignedTechId),
      'customerId': serializer.toJson<String?>(customerId),
      'serviceBookingId': serializer.toJson<String?>(serviceBookingId),
      'estimatedCompletion': serializer.toJson<String>(estimatedCompletion),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CachedTechnicianJob copyWith(
          {String? id,
          String? vehicleModel,
          String? vehiclePlate,
          String? serviceType,
          String? packageName,
          String? date,
          String? time,
          double? progress,
          String? checklist,
          String? parts,
          String? status,
          String? price,
          Value<String?> assignedTechId = const Value.absent(),
          Value<String?> customerId = const Value.absent(),
          Value<String?> serviceBookingId = const Value.absent(),
          String? estimatedCompletion,
          DateTime? createdAt}) =>
      CachedTechnicianJob(
        id: id ?? this.id,
        vehicleModel: vehicleModel ?? this.vehicleModel,
        vehiclePlate: vehiclePlate ?? this.vehiclePlate,
        serviceType: serviceType ?? this.serviceType,
        packageName: packageName ?? this.packageName,
        date: date ?? this.date,
        time: time ?? this.time,
        progress: progress ?? this.progress,
        checklist: checklist ?? this.checklist,
        parts: parts ?? this.parts,
        status: status ?? this.status,
        price: price ?? this.price,
        assignedTechId:
            assignedTechId.present ? assignedTechId.value : this.assignedTechId,
        customerId: customerId.present ? customerId.value : this.customerId,
        serviceBookingId: serviceBookingId.present
            ? serviceBookingId.value
            : this.serviceBookingId,
        estimatedCompletion: estimatedCompletion ?? this.estimatedCompletion,
        createdAt: createdAt ?? this.createdAt,
      );
  CachedTechnicianJob copyWithCompanion(CachedTechnicianJobsCompanion data) {
    return CachedTechnicianJob(
      id: data.id.present ? data.id.value : this.id,
      vehicleModel: data.vehicleModel.present
          ? data.vehicleModel.value
          : this.vehicleModel,
      vehiclePlate: data.vehiclePlate.present
          ? data.vehiclePlate.value
          : this.vehiclePlate,
      serviceType:
          data.serviceType.present ? data.serviceType.value : this.serviceType,
      packageName:
          data.packageName.present ? data.packageName.value : this.packageName,
      date: data.date.present ? data.date.value : this.date,
      time: data.time.present ? data.time.value : this.time,
      progress: data.progress.present ? data.progress.value : this.progress,
      checklist: data.checklist.present ? data.checklist.value : this.checklist,
      parts: data.parts.present ? data.parts.value : this.parts,
      status: data.status.present ? data.status.value : this.status,
      price: data.price.present ? data.price.value : this.price,
      assignedTechId: data.assignedTechId.present
          ? data.assignedTechId.value
          : this.assignedTechId,
      customerId:
          data.customerId.present ? data.customerId.value : this.customerId,
      serviceBookingId: data.serviceBookingId.present
          ? data.serviceBookingId.value
          : this.serviceBookingId,
      estimatedCompletion: data.estimatedCompletion.present
          ? data.estimatedCompletion.value
          : this.estimatedCompletion,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedTechnicianJob(')
          ..write('id: $id, ')
          ..write('vehicleModel: $vehicleModel, ')
          ..write('vehiclePlate: $vehiclePlate, ')
          ..write('serviceType: $serviceType, ')
          ..write('packageName: $packageName, ')
          ..write('date: $date, ')
          ..write('time: $time, ')
          ..write('progress: $progress, ')
          ..write('checklist: $checklist, ')
          ..write('parts: $parts, ')
          ..write('status: $status, ')
          ..write('price: $price, ')
          ..write('assignedTechId: $assignedTechId, ')
          ..write('customerId: $customerId, ')
          ..write('serviceBookingId: $serviceBookingId, ')
          ..write('estimatedCompletion: $estimatedCompletion, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      vehicleModel,
      vehiclePlate,
      serviceType,
      packageName,
      date,
      time,
      progress,
      checklist,
      parts,
      status,
      price,
      assignedTechId,
      customerId,
      serviceBookingId,
      estimatedCompletion,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedTechnicianJob &&
          other.id == this.id &&
          other.vehicleModel == this.vehicleModel &&
          other.vehiclePlate == this.vehiclePlate &&
          other.serviceType == this.serviceType &&
          other.packageName == this.packageName &&
          other.date == this.date &&
          other.time == this.time &&
          other.progress == this.progress &&
          other.checklist == this.checklist &&
          other.parts == this.parts &&
          other.status == this.status &&
          other.price == this.price &&
          other.assignedTechId == this.assignedTechId &&
          other.customerId == this.customerId &&
          other.serviceBookingId == this.serviceBookingId &&
          other.estimatedCompletion == this.estimatedCompletion &&
          other.createdAt == this.createdAt);
}

class CachedTechnicianJobsCompanion
    extends UpdateCompanion<CachedTechnicianJob> {
  final Value<String> id;
  final Value<String> vehicleModel;
  final Value<String> vehiclePlate;
  final Value<String> serviceType;
  final Value<String> packageName;
  final Value<String> date;
  final Value<String> time;
  final Value<double> progress;
  final Value<String> checklist;
  final Value<String> parts;
  final Value<String> status;
  final Value<String> price;
  final Value<String?> assignedTechId;
  final Value<String?> customerId;
  final Value<String?> serviceBookingId;
  final Value<String> estimatedCompletion;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CachedTechnicianJobsCompanion({
    this.id = const Value.absent(),
    this.vehicleModel = const Value.absent(),
    this.vehiclePlate = const Value.absent(),
    this.serviceType = const Value.absent(),
    this.packageName = const Value.absent(),
    this.date = const Value.absent(),
    this.time = const Value.absent(),
    this.progress = const Value.absent(),
    this.checklist = const Value.absent(),
    this.parts = const Value.absent(),
    this.status = const Value.absent(),
    this.price = const Value.absent(),
    this.assignedTechId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.serviceBookingId = const Value.absent(),
    this.estimatedCompletion = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedTechnicianJobsCompanion.insert({
    required String id,
    required String vehicleModel,
    required String vehiclePlate,
    required String serviceType,
    required String packageName,
    required String date,
    required String time,
    required double progress,
    required String checklist,
    required String parts,
    required String status,
    required String price,
    this.assignedTechId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.serviceBookingId = const Value.absent(),
    required String estimatedCompletion,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        vehicleModel = Value(vehicleModel),
        vehiclePlate = Value(vehiclePlate),
        serviceType = Value(serviceType),
        packageName = Value(packageName),
        date = Value(date),
        time = Value(time),
        progress = Value(progress),
        checklist = Value(checklist),
        parts = Value(parts),
        status = Value(status),
        price = Value(price),
        estimatedCompletion = Value(estimatedCompletion),
        createdAt = Value(createdAt);
  static Insertable<CachedTechnicianJob> custom({
    Expression<String>? id,
    Expression<String>? vehicleModel,
    Expression<String>? vehiclePlate,
    Expression<String>? serviceType,
    Expression<String>? packageName,
    Expression<String>? date,
    Expression<String>? time,
    Expression<double>? progress,
    Expression<String>? checklist,
    Expression<String>? parts,
    Expression<String>? status,
    Expression<String>? price,
    Expression<String>? assignedTechId,
    Expression<String>? customerId,
    Expression<String>? serviceBookingId,
    Expression<String>? estimatedCompletion,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vehicleModel != null) 'vehicle_model': vehicleModel,
      if (vehiclePlate != null) 'vehicle_plate': vehiclePlate,
      if (serviceType != null) 'service_type': serviceType,
      if (packageName != null) 'package_name': packageName,
      if (date != null) 'date': date,
      if (time != null) 'time': time,
      if (progress != null) 'progress': progress,
      if (checklist != null) 'checklist': checklist,
      if (parts != null) 'parts': parts,
      if (status != null) 'status': status,
      if (price != null) 'price': price,
      if (assignedTechId != null) 'assigned_tech_id': assignedTechId,
      if (customerId != null) 'customer_id': customerId,
      if (serviceBookingId != null) 'service_booking_id': serviceBookingId,
      if (estimatedCompletion != null)
        'estimated_completion': estimatedCompletion,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedTechnicianJobsCompanion copyWith(
      {Value<String>? id,
      Value<String>? vehicleModel,
      Value<String>? vehiclePlate,
      Value<String>? serviceType,
      Value<String>? packageName,
      Value<String>? date,
      Value<String>? time,
      Value<double>? progress,
      Value<String>? checklist,
      Value<String>? parts,
      Value<String>? status,
      Value<String>? price,
      Value<String?>? assignedTechId,
      Value<String?>? customerId,
      Value<String?>? serviceBookingId,
      Value<String>? estimatedCompletion,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return CachedTechnicianJobsCompanion(
      id: id ?? this.id,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      serviceType: serviceType ?? this.serviceType,
      packageName: packageName ?? this.packageName,
      date: date ?? this.date,
      time: time ?? this.time,
      progress: progress ?? this.progress,
      checklist: checklist ?? this.checklist,
      parts: parts ?? this.parts,
      status: status ?? this.status,
      price: price ?? this.price,
      assignedTechId: assignedTechId ?? this.assignedTechId,
      customerId: customerId ?? this.customerId,
      serviceBookingId: serviceBookingId ?? this.serviceBookingId,
      estimatedCompletion: estimatedCompletion ?? this.estimatedCompletion,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (vehicleModel.present) {
      map['vehicle_model'] = Variable<String>(vehicleModel.value);
    }
    if (vehiclePlate.present) {
      map['vehicle_plate'] = Variable<String>(vehiclePlate.value);
    }
    if (serviceType.present) {
      map['service_type'] = Variable<String>(serviceType.value);
    }
    if (packageName.present) {
      map['package_name'] = Variable<String>(packageName.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (time.present) {
      map['time'] = Variable<String>(time.value);
    }
    if (progress.present) {
      map['progress'] = Variable<double>(progress.value);
    }
    if (checklist.present) {
      map['checklist'] = Variable<String>(checklist.value);
    }
    if (parts.present) {
      map['parts'] = Variable<String>(parts.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (price.present) {
      map['price'] = Variable<String>(price.value);
    }
    if (assignedTechId.present) {
      map['assigned_tech_id'] = Variable<String>(assignedTechId.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (serviceBookingId.present) {
      map['service_booking_id'] = Variable<String>(serviceBookingId.value);
    }
    if (estimatedCompletion.present) {
      map['estimated_completion'] = Variable<String>(estimatedCompletion.value);
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
    return (StringBuffer('CachedTechnicianJobsCompanion(')
          ..write('id: $id, ')
          ..write('vehicleModel: $vehicleModel, ')
          ..write('vehiclePlate: $vehiclePlate, ')
          ..write('serviceType: $serviceType, ')
          ..write('packageName: $packageName, ')
          ..write('date: $date, ')
          ..write('time: $time, ')
          ..write('progress: $progress, ')
          ..write('checklist: $checklist, ')
          ..write('parts: $parts, ')
          ..write('status: $status, ')
          ..write('price: $price, ')
          ..write('assignedTechId: $assignedTechId, ')
          ..write('customerId: $customerId, ')
          ..write('serviceBookingId: $serviceBookingId, ')
          ..write('estimatedCompletion: $estimatedCompletion, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HttpResponseCacheTable extends HttpResponseCache
    with TableInfo<$HttpResponseCacheTable, HttpResponseCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HttpResponseCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cacheKeyMeta =
      const VerificationMeta('cacheKey');
  @override
  late final GeneratedColumn<String> cacheKey = GeneratedColumn<String>(
      'cache_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _responseBodyMeta =
      const VerificationMeta('responseBody');
  @override
  late final GeneratedColumn<String> responseBody = GeneratedColumn<String>(
      'response_body', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _ttlSecondsMeta =
      const VerificationMeta('ttlSeconds');
  @override
  late final GeneratedColumn<int> ttlSeconds = GeneratedColumn<int>(
      'ttl_seconds', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(300));
  @override
  List<GeneratedColumn> get $columns =>
      [cacheKey, responseBody, cachedAt, ttlSeconds];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'http_response_cache';
  @override
  VerificationContext validateIntegrity(
      Insertable<HttpResponseCacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cache_key')) {
      context.handle(_cacheKeyMeta,
          cacheKey.isAcceptableOrUnknown(data['cache_key']!, _cacheKeyMeta));
    } else if (isInserting) {
      context.missing(_cacheKeyMeta);
    }
    if (data.containsKey('response_body')) {
      context.handle(
          _responseBodyMeta,
          responseBody.isAcceptableOrUnknown(
              data['response_body']!, _responseBodyMeta));
    } else if (isInserting) {
      context.missing(_responseBodyMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta,
          cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    if (data.containsKey('ttl_seconds')) {
      context.handle(
          _ttlSecondsMeta,
          ttlSeconds.isAcceptableOrUnknown(
              data['ttl_seconds']!, _ttlSecondsMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cacheKey};
  @override
  HttpResponseCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HttpResponseCacheData(
      cacheKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cache_key'])!,
      responseBody: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}response_body'])!,
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cached_at'])!,
      ttlSeconds: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ttl_seconds'])!,
    );
  }

  @override
  $HttpResponseCacheTable createAlias(String alias) {
    return $HttpResponseCacheTable(attachedDatabase, alias);
  }
}

class HttpResponseCacheData extends DataClass
    implements Insertable<HttpResponseCacheData> {
  final String cacheKey;
  final String responseBody;
  final DateTime cachedAt;
  final int ttlSeconds;
  const HttpResponseCacheData(
      {required this.cacheKey,
      required this.responseBody,
      required this.cachedAt,
      required this.ttlSeconds});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cache_key'] = Variable<String>(cacheKey);
    map['response_body'] = Variable<String>(responseBody);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    map['ttl_seconds'] = Variable<int>(ttlSeconds);
    return map;
  }

  HttpResponseCacheCompanion toCompanion(bool nullToAbsent) {
    return HttpResponseCacheCompanion(
      cacheKey: Value(cacheKey),
      responseBody: Value(responseBody),
      cachedAt: Value(cachedAt),
      ttlSeconds: Value(ttlSeconds),
    );
  }

  factory HttpResponseCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HttpResponseCacheData(
      cacheKey: serializer.fromJson<String>(json['cacheKey']),
      responseBody: serializer.fromJson<String>(json['responseBody']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
      ttlSeconds: serializer.fromJson<int>(json['ttlSeconds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cacheKey': serializer.toJson<String>(cacheKey),
      'responseBody': serializer.toJson<String>(responseBody),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
      'ttlSeconds': serializer.toJson<int>(ttlSeconds),
    };
  }

  HttpResponseCacheData copyWith(
          {String? cacheKey,
          String? responseBody,
          DateTime? cachedAt,
          int? ttlSeconds}) =>
      HttpResponseCacheData(
        cacheKey: cacheKey ?? this.cacheKey,
        responseBody: responseBody ?? this.responseBody,
        cachedAt: cachedAt ?? this.cachedAt,
        ttlSeconds: ttlSeconds ?? this.ttlSeconds,
      );
  HttpResponseCacheData copyWithCompanion(HttpResponseCacheCompanion data) {
    return HttpResponseCacheData(
      cacheKey: data.cacheKey.present ? data.cacheKey.value : this.cacheKey,
      responseBody: data.responseBody.present
          ? data.responseBody.value
          : this.responseBody,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
      ttlSeconds:
          data.ttlSeconds.present ? data.ttlSeconds.value : this.ttlSeconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HttpResponseCacheData(')
          ..write('cacheKey: $cacheKey, ')
          ..write('responseBody: $responseBody, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('ttlSeconds: $ttlSeconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(cacheKey, responseBody, cachedAt, ttlSeconds);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HttpResponseCacheData &&
          other.cacheKey == this.cacheKey &&
          other.responseBody == this.responseBody &&
          other.cachedAt == this.cachedAt &&
          other.ttlSeconds == this.ttlSeconds);
}

class HttpResponseCacheCompanion
    extends UpdateCompanion<HttpResponseCacheData> {
  final Value<String> cacheKey;
  final Value<String> responseBody;
  final Value<DateTime> cachedAt;
  final Value<int> ttlSeconds;
  final Value<int> rowid;
  const HttpResponseCacheCompanion({
    this.cacheKey = const Value.absent(),
    this.responseBody = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.ttlSeconds = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HttpResponseCacheCompanion.insert({
    required String cacheKey,
    required String responseBody,
    required DateTime cachedAt,
    this.ttlSeconds = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : cacheKey = Value(cacheKey),
        responseBody = Value(responseBody),
        cachedAt = Value(cachedAt);
  static Insertable<HttpResponseCacheData> custom({
    Expression<String>? cacheKey,
    Expression<String>? responseBody,
    Expression<DateTime>? cachedAt,
    Expression<int>? ttlSeconds,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cacheKey != null) 'cache_key': cacheKey,
      if (responseBody != null) 'response_body': responseBody,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (ttlSeconds != null) 'ttl_seconds': ttlSeconds,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HttpResponseCacheCompanion copyWith(
      {Value<String>? cacheKey,
      Value<String>? responseBody,
      Value<DateTime>? cachedAt,
      Value<int>? ttlSeconds,
      Value<int>? rowid}) {
    return HttpResponseCacheCompanion(
      cacheKey: cacheKey ?? this.cacheKey,
      responseBody: responseBody ?? this.responseBody,
      cachedAt: cachedAt ?? this.cachedAt,
      ttlSeconds: ttlSeconds ?? this.ttlSeconds,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cacheKey.present) {
      map['cache_key'] = Variable<String>(cacheKey.value);
    }
    if (responseBody.present) {
      map['response_body'] = Variable<String>(responseBody.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (ttlSeconds.present) {
      map['ttl_seconds'] = Variable<int>(ttlSeconds.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HttpResponseCacheCompanion(')
          ..write('cacheKey: $cacheKey, ')
          ..write('responseBody: $responseBody, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('ttlSeconds: $ttlSeconds, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CachedProfilesTable cachedProfiles = $CachedProfilesTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final $DeadLetterQueueTable deadLetterQueue =
      $DeadLetterQueueTable(this);
  late final $CachedRidesTable cachedRides = $CachedRidesTable(this);
  late final $CachedCategoriesTable cachedCategories =
      $CachedCategoriesTable(this);
  late final $CachedBannersTable cachedBanners = $CachedBannersTable(this);
  late final $CachedTechnicianJobsTable cachedTechnicianJobs =
      $CachedTechnicianJobsTable(this);
  late final $HttpResponseCacheTable httpResponseCache =
      $HttpResponseCacheTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        cachedProfiles,
        syncQueue,
        deadLetterQueue,
        cachedRides,
        cachedCategories,
        cachedBanners,
        cachedTechnicianJobs,
        httpResponseCache
      ];
}

typedef $$CachedProfilesTableCreateCompanionBuilder = CachedProfilesCompanion
    Function({
  required String id,
  required String name,
  Value<String?> email,
  required String phone,
  required String role,
  Value<String?> profilePic,
  Value<int> points,
  Value<int> rowid,
});
typedef $$CachedProfilesTableUpdateCompanionBuilder = CachedProfilesCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String?> email,
  Value<String> phone,
  Value<String> role,
  Value<String?> profilePic,
  Value<int> points,
  Value<int> rowid,
});

class $$CachedProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedProfilesTable> {
  $$CachedProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<String?, String, String> get email =>
      $composableBuilder(
          column: $table.email,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<String, String, String> get phone =>
      $composableBuilder(
          column: $table.phone,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get profilePic => $composableBuilder(
      column: $table.profilePic, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get points => $composableBuilder(
      column: $table.points, builder: (column) => ColumnFilters(column));
}

class $$CachedProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedProfilesTable> {
  $$CachedProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get profilePic => $composableBuilder(
      column: $table.profilePic, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get points => $composableBuilder(
      column: $table.points, builder: (column) => ColumnOrderings(column));
}

class $$CachedProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedProfilesTable> {
  $$CachedProfilesTableAnnotationComposer({
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

  GeneratedColumnWithTypeConverter<String?, String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumnWithTypeConverter<String, String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get profilePic => $composableBuilder(
      column: $table.profilePic, builder: (column) => column);

  GeneratedColumn<int> get points =>
      $composableBuilder(column: $table.points, builder: (column) => column);
}

class $$CachedProfilesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CachedProfilesTable,
    CachedProfile,
    $$CachedProfilesTableFilterComposer,
    $$CachedProfilesTableOrderingComposer,
    $$CachedProfilesTableAnnotationComposer,
    $$CachedProfilesTableCreateCompanionBuilder,
    $$CachedProfilesTableUpdateCompanionBuilder,
    (
      CachedProfile,
      BaseReferences<_$AppDatabase, $CachedProfilesTable, CachedProfile>
    ),
    CachedProfile,
    PrefetchHooks Function()> {
  $$CachedProfilesTableTableManager(
      _$AppDatabase db, $CachedProfilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String> phone = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<String?> profilePic = const Value.absent(),
            Value<int> points = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedProfilesCompanion(
            id: id,
            name: name,
            email: email,
            phone: phone,
            role: role,
            profilePic: profilePic,
            points: points,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> email = const Value.absent(),
            required String phone,
            required String role,
            Value<String?> profilePic = const Value.absent(),
            Value<int> points = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedProfilesCompanion.insert(
            id: id,
            name: name,
            email: email,
            phone: phone,
            role: role,
            profilePic: profilePic,
            points: points,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedProfilesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CachedProfilesTable,
    CachedProfile,
    $$CachedProfilesTableFilterComposer,
    $$CachedProfilesTableOrderingComposer,
    $$CachedProfilesTableAnnotationComposer,
    $$CachedProfilesTableCreateCompanionBuilder,
    $$CachedProfilesTableUpdateCompanionBuilder,
    (
      CachedProfile,
      BaseReferences<_$AppDatabase, $CachedProfilesTable, CachedProfile>
    ),
    CachedProfile,
    PrefetchHooks Function()>;
typedef $$SyncQueueTableCreateCompanionBuilder = SyncQueueCompanion Function({
  Value<int> id,
  required String idempotencyKey,
  required String entityType,
  required String action,
  required String payload,
  Value<DateTime> createdAt,
  Value<int> attempts,
  Value<DateTime?> nextRetryAt,
});
typedef $$SyncQueueTableUpdateCompanionBuilder = SyncQueueCompanion Function({
  Value<int> id,
  Value<String> idempotencyKey,
  Value<String> entityType,
  Value<String> action,
  Value<String> payload,
  Value<DateTime> createdAt,
  Value<int> attempts,
  Value<DateTime?> nextRetryAt,
});

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextRetryAt => $composableBuilder(
      column: $table.nextRetryAt, builder: (column) => ColumnFilters(column));
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextRetryAt => $composableBuilder(
      column: $table.nextRetryAt, builder: (column) => ColumnOrderings(column));
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<DateTime> get nextRetryAt => $composableBuilder(
      column: $table.nextRetryAt, builder: (column) => column);
}

class $$SyncQueueTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncQueueTable,
    SyncQueueData,
    $$SyncQueueTableFilterComposer,
    $$SyncQueueTableOrderingComposer,
    $$SyncQueueTableAnnotationComposer,
    $$SyncQueueTableCreateCompanionBuilder,
    $$SyncQueueTableUpdateCompanionBuilder,
    (
      SyncQueueData,
      BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>
    ),
    SyncQueueData,
    PrefetchHooks Function()> {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> idempotencyKey = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> action = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> attempts = const Value.absent(),
            Value<DateTime?> nextRetryAt = const Value.absent(),
          }) =>
              SyncQueueCompanion(
            id: id,
            idempotencyKey: idempotencyKey,
            entityType: entityType,
            action: action,
            payload: payload,
            createdAt: createdAt,
            attempts: attempts,
            nextRetryAt: nextRetryAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String idempotencyKey,
            required String entityType,
            required String action,
            required String payload,
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> attempts = const Value.absent(),
            Value<DateTime?> nextRetryAt = const Value.absent(),
          }) =>
              SyncQueueCompanion.insert(
            id: id,
            idempotencyKey: idempotencyKey,
            entityType: entityType,
            action: action,
            payload: payload,
            createdAt: createdAt,
            attempts: attempts,
            nextRetryAt: nextRetryAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncQueueTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncQueueTable,
    SyncQueueData,
    $$SyncQueueTableFilterComposer,
    $$SyncQueueTableOrderingComposer,
    $$SyncQueueTableAnnotationComposer,
    $$SyncQueueTableCreateCompanionBuilder,
    $$SyncQueueTableUpdateCompanionBuilder,
    (
      SyncQueueData,
      BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>
    ),
    SyncQueueData,
    PrefetchHooks Function()>;
typedef $$DeadLetterQueueTableCreateCompanionBuilder = DeadLetterQueueCompanion
    Function({
  Value<int> id,
  required String idempotencyKey,
  required String entityType,
  required String action,
  required String payload,
  required DateTime createdAt,
  required int attempts,
  Value<String?> error,
  Value<DateTime> failedAt,
});
typedef $$DeadLetterQueueTableUpdateCompanionBuilder = DeadLetterQueueCompanion
    Function({
  Value<int> id,
  Value<String> idempotencyKey,
  Value<String> entityType,
  Value<String> action,
  Value<String> payload,
  Value<DateTime> createdAt,
  Value<int> attempts,
  Value<String?> error,
  Value<DateTime> failedAt,
});

class $$DeadLetterQueueTableFilterComposer
    extends Composer<_$AppDatabase, $DeadLetterQueueTable> {
  $$DeadLetterQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get error => $composableBuilder(
      column: $table.error, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get failedAt => $composableBuilder(
      column: $table.failedAt, builder: (column) => ColumnFilters(column));
}

class $$DeadLetterQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $DeadLetterQueueTable> {
  $$DeadLetterQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get error => $composableBuilder(
      column: $table.error, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get failedAt => $composableBuilder(
      column: $table.failedAt, builder: (column) => ColumnOrderings(column));
}

class $$DeadLetterQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeadLetterQueueTable> {
  $$DeadLetterQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);

  GeneratedColumn<DateTime> get failedAt =>
      $composableBuilder(column: $table.failedAt, builder: (column) => column);
}

class $$DeadLetterQueueTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DeadLetterQueueTable,
    DeadLetterQueueData,
    $$DeadLetterQueueTableFilterComposer,
    $$DeadLetterQueueTableOrderingComposer,
    $$DeadLetterQueueTableAnnotationComposer,
    $$DeadLetterQueueTableCreateCompanionBuilder,
    $$DeadLetterQueueTableUpdateCompanionBuilder,
    (
      DeadLetterQueueData,
      BaseReferences<_$AppDatabase, $DeadLetterQueueTable, DeadLetterQueueData>
    ),
    DeadLetterQueueData,
    PrefetchHooks Function()> {
  $$DeadLetterQueueTableTableManager(
      _$AppDatabase db, $DeadLetterQueueTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeadLetterQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeadLetterQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeadLetterQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> idempotencyKey = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> action = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> attempts = const Value.absent(),
            Value<String?> error = const Value.absent(),
            Value<DateTime> failedAt = const Value.absent(),
          }) =>
              DeadLetterQueueCompanion(
            id: id,
            idempotencyKey: idempotencyKey,
            entityType: entityType,
            action: action,
            payload: payload,
            createdAt: createdAt,
            attempts: attempts,
            error: error,
            failedAt: failedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String idempotencyKey,
            required String entityType,
            required String action,
            required String payload,
            required DateTime createdAt,
            required int attempts,
            Value<String?> error = const Value.absent(),
            Value<DateTime> failedAt = const Value.absent(),
          }) =>
              DeadLetterQueueCompanion.insert(
            id: id,
            idempotencyKey: idempotencyKey,
            entityType: entityType,
            action: action,
            payload: payload,
            createdAt: createdAt,
            attempts: attempts,
            error: error,
            failedAt: failedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DeadLetterQueueTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DeadLetterQueueTable,
    DeadLetterQueueData,
    $$DeadLetterQueueTableFilterComposer,
    $$DeadLetterQueueTableOrderingComposer,
    $$DeadLetterQueueTableAnnotationComposer,
    $$DeadLetterQueueTableCreateCompanionBuilder,
    $$DeadLetterQueueTableUpdateCompanionBuilder,
    (
      DeadLetterQueueData,
      BaseReferences<_$AppDatabase, $DeadLetterQueueTable, DeadLetterQueueData>
    ),
    DeadLetterQueueData,
    PrefetchHooks Function()>;
typedef $$CachedRidesTableCreateCompanionBuilder = CachedRidesCompanion
    Function({
  required String id,
  required String pickupAddress,
  required String destinationAddress,
  required double fare,
  required String status,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$CachedRidesTableUpdateCompanionBuilder = CachedRidesCompanion
    Function({
  Value<String> id,
  Value<String> pickupAddress,
  Value<String> destinationAddress,
  Value<double> fare,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$CachedRidesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedRidesTable> {
  $$CachedRidesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pickupAddress => $composableBuilder(
      column: $table.pickupAddress, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get destinationAddress => $composableBuilder(
      column: $table.destinationAddress,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fare => $composableBuilder(
      column: $table.fare, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$CachedRidesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedRidesTable> {
  $$CachedRidesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pickupAddress => $composableBuilder(
      column: $table.pickupAddress,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get destinationAddress => $composableBuilder(
      column: $table.destinationAddress,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fare => $composableBuilder(
      column: $table.fare, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$CachedRidesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedRidesTable> {
  $$CachedRidesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get pickupAddress => $composableBuilder(
      column: $table.pickupAddress, builder: (column) => column);

  GeneratedColumn<String> get destinationAddress => $composableBuilder(
      column: $table.destinationAddress, builder: (column) => column);

  GeneratedColumn<double> get fare =>
      $composableBuilder(column: $table.fare, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CachedRidesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CachedRidesTable,
    CachedRide,
    $$CachedRidesTableFilterComposer,
    $$CachedRidesTableOrderingComposer,
    $$CachedRidesTableAnnotationComposer,
    $$CachedRidesTableCreateCompanionBuilder,
    $$CachedRidesTableUpdateCompanionBuilder,
    (CachedRide, BaseReferences<_$AppDatabase, $CachedRidesTable, CachedRide>),
    CachedRide,
    PrefetchHooks Function()> {
  $$CachedRidesTableTableManager(_$AppDatabase db, $CachedRidesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedRidesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedRidesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedRidesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> pickupAddress = const Value.absent(),
            Value<String> destinationAddress = const Value.absent(),
            Value<double> fare = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedRidesCompanion(
            id: id,
            pickupAddress: pickupAddress,
            destinationAddress: destinationAddress,
            fare: fare,
            status: status,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String pickupAddress,
            required String destinationAddress,
            required double fare,
            required String status,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedRidesCompanion.insert(
            id: id,
            pickupAddress: pickupAddress,
            destinationAddress: destinationAddress,
            fare: fare,
            status: status,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedRidesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CachedRidesTable,
    CachedRide,
    $$CachedRidesTableFilterComposer,
    $$CachedRidesTableOrderingComposer,
    $$CachedRidesTableAnnotationComposer,
    $$CachedRidesTableCreateCompanionBuilder,
    $$CachedRidesTableUpdateCompanionBuilder,
    (CachedRide, BaseReferences<_$AppDatabase, $CachedRidesTable, CachedRide>),
    CachedRide,
    PrefetchHooks Function()>;
typedef $$CachedCategoriesTableCreateCompanionBuilder
    = CachedCategoriesCompanion Function({
  required String id,
  required String icon,
  required String label,
  required String count,
  Value<int> rowid,
});
typedef $$CachedCategoriesTableUpdateCompanionBuilder
    = CachedCategoriesCompanion Function({
  Value<String> id,
  Value<String> icon,
  Value<String> label,
  Value<String> count,
  Value<int> rowid,
});

class $$CachedCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedCategoriesTable> {
  $$CachedCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get count => $composableBuilder(
      column: $table.count, builder: (column) => ColumnFilters(column));
}

class $$CachedCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedCategoriesTable> {
  $$CachedCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get count => $composableBuilder(
      column: $table.count, builder: (column) => ColumnOrderings(column));
}

class $$CachedCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedCategoriesTable> {
  $$CachedCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);
}

class $$CachedCategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CachedCategoriesTable,
    CachedCategory,
    $$CachedCategoriesTableFilterComposer,
    $$CachedCategoriesTableOrderingComposer,
    $$CachedCategoriesTableAnnotationComposer,
    $$CachedCategoriesTableCreateCompanionBuilder,
    $$CachedCategoriesTableUpdateCompanionBuilder,
    (
      CachedCategory,
      BaseReferences<_$AppDatabase, $CachedCategoriesTable, CachedCategory>
    ),
    CachedCategory,
    PrefetchHooks Function()> {
  $$CachedCategoriesTableTableManager(
      _$AppDatabase db, $CachedCategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> icon = const Value.absent(),
            Value<String> label = const Value.absent(),
            Value<String> count = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedCategoriesCompanion(
            id: id,
            icon: icon,
            label: label,
            count: count,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String icon,
            required String label,
            required String count,
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedCategoriesCompanion.insert(
            id: id,
            icon: icon,
            label: label,
            count: count,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedCategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CachedCategoriesTable,
    CachedCategory,
    $$CachedCategoriesTableFilterComposer,
    $$CachedCategoriesTableOrderingComposer,
    $$CachedCategoriesTableAnnotationComposer,
    $$CachedCategoriesTableCreateCompanionBuilder,
    $$CachedCategoriesTableUpdateCompanionBuilder,
    (
      CachedCategory,
      BaseReferences<_$AppDatabase, $CachedCategoriesTable, CachedCategory>
    ),
    CachedCategory,
    PrefetchHooks Function()>;
typedef $$CachedBannersTableCreateCompanionBuilder = CachedBannersCompanion
    Function({
  required String id,
  required String title,
  required String subtitle,
  required String image,
  required String cta,
  Value<int> rowid,
});
typedef $$CachedBannersTableUpdateCompanionBuilder = CachedBannersCompanion
    Function({
  Value<String> id,
  Value<String> title,
  Value<String> subtitle,
  Value<String> image,
  Value<String> cta,
  Value<int> rowid,
});

class $$CachedBannersTableFilterComposer
    extends Composer<_$AppDatabase, $CachedBannersTable> {
  $$CachedBannersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subtitle => $composableBuilder(
      column: $table.subtitle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get image => $composableBuilder(
      column: $table.image, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cta => $composableBuilder(
      column: $table.cta, builder: (column) => ColumnFilters(column));
}

class $$CachedBannersTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedBannersTable> {
  $$CachedBannersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subtitle => $composableBuilder(
      column: $table.subtitle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get image => $composableBuilder(
      column: $table.image, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cta => $composableBuilder(
      column: $table.cta, builder: (column) => ColumnOrderings(column));
}

class $$CachedBannersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedBannersTable> {
  $$CachedBannersTableAnnotationComposer({
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

  GeneratedColumn<String> get subtitle =>
      $composableBuilder(column: $table.subtitle, builder: (column) => column);

  GeneratedColumn<String> get image =>
      $composableBuilder(column: $table.image, builder: (column) => column);

  GeneratedColumn<String> get cta =>
      $composableBuilder(column: $table.cta, builder: (column) => column);
}

class $$CachedBannersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CachedBannersTable,
    CachedBanner,
    $$CachedBannersTableFilterComposer,
    $$CachedBannersTableOrderingComposer,
    $$CachedBannersTableAnnotationComposer,
    $$CachedBannersTableCreateCompanionBuilder,
    $$CachedBannersTableUpdateCompanionBuilder,
    (
      CachedBanner,
      BaseReferences<_$AppDatabase, $CachedBannersTable, CachedBanner>
    ),
    CachedBanner,
    PrefetchHooks Function()> {
  $$CachedBannersTableTableManager(_$AppDatabase db, $CachedBannersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedBannersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedBannersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedBannersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> subtitle = const Value.absent(),
            Value<String> image = const Value.absent(),
            Value<String> cta = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedBannersCompanion(
            id: id,
            title: title,
            subtitle: subtitle,
            image: image,
            cta: cta,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required String subtitle,
            required String image,
            required String cta,
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedBannersCompanion.insert(
            id: id,
            title: title,
            subtitle: subtitle,
            image: image,
            cta: cta,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedBannersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CachedBannersTable,
    CachedBanner,
    $$CachedBannersTableFilterComposer,
    $$CachedBannersTableOrderingComposer,
    $$CachedBannersTableAnnotationComposer,
    $$CachedBannersTableCreateCompanionBuilder,
    $$CachedBannersTableUpdateCompanionBuilder,
    (
      CachedBanner,
      BaseReferences<_$AppDatabase, $CachedBannersTable, CachedBanner>
    ),
    CachedBanner,
    PrefetchHooks Function()>;
typedef $$CachedTechnicianJobsTableCreateCompanionBuilder
    = CachedTechnicianJobsCompanion Function({
  required String id,
  required String vehicleModel,
  required String vehiclePlate,
  required String serviceType,
  required String packageName,
  required String date,
  required String time,
  required double progress,
  required String checklist,
  required String parts,
  required String status,
  required String price,
  Value<String?> assignedTechId,
  Value<String?> customerId,
  Value<String?> serviceBookingId,
  required String estimatedCompletion,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$CachedTechnicianJobsTableUpdateCompanionBuilder
    = CachedTechnicianJobsCompanion Function({
  Value<String> id,
  Value<String> vehicleModel,
  Value<String> vehiclePlate,
  Value<String> serviceType,
  Value<String> packageName,
  Value<String> date,
  Value<String> time,
  Value<double> progress,
  Value<String> checklist,
  Value<String> parts,
  Value<String> status,
  Value<String> price,
  Value<String?> assignedTechId,
  Value<String?> customerId,
  Value<String?> serviceBookingId,
  Value<String> estimatedCompletion,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$CachedTechnicianJobsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedTechnicianJobsTable> {
  $$CachedTechnicianJobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vehicleModel => $composableBuilder(
      column: $table.vehicleModel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vehiclePlate => $composableBuilder(
      column: $table.vehiclePlate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serviceType => $composableBuilder(
      column: $table.serviceType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get packageName => $composableBuilder(
      column: $table.packageName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get time => $composableBuilder(
      column: $table.time, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get progress => $composableBuilder(
      column: $table.progress, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get checklist => $composableBuilder(
      column: $table.checklist, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parts => $composableBuilder(
      column: $table.parts, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get assignedTechId => $composableBuilder(
      column: $table.assignedTechId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serviceBookingId => $composableBuilder(
      column: $table.serviceBookingId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get estimatedCompletion => $composableBuilder(
      column: $table.estimatedCompletion,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$CachedTechnicianJobsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedTechnicianJobsTable> {
  $$CachedTechnicianJobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vehicleModel => $composableBuilder(
      column: $table.vehicleModel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vehiclePlate => $composableBuilder(
      column: $table.vehiclePlate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serviceType => $composableBuilder(
      column: $table.serviceType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get packageName => $composableBuilder(
      column: $table.packageName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get time => $composableBuilder(
      column: $table.time, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get progress => $composableBuilder(
      column: $table.progress, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get checklist => $composableBuilder(
      column: $table.checklist, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parts => $composableBuilder(
      column: $table.parts, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get assignedTechId => $composableBuilder(
      column: $table.assignedTechId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serviceBookingId => $composableBuilder(
      column: $table.serviceBookingId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get estimatedCompletion => $composableBuilder(
      column: $table.estimatedCompletion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$CachedTechnicianJobsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedTechnicianJobsTable> {
  $$CachedTechnicianJobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get vehicleModel => $composableBuilder(
      column: $table.vehicleModel, builder: (column) => column);

  GeneratedColumn<String> get vehiclePlate => $composableBuilder(
      column: $table.vehiclePlate, builder: (column) => column);

  GeneratedColumn<String> get serviceType => $composableBuilder(
      column: $table.serviceType, builder: (column) => column);

  GeneratedColumn<String> get packageName => $composableBuilder(
      column: $table.packageName, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);

  GeneratedColumn<double> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);

  GeneratedColumn<String> get checklist =>
      $composableBuilder(column: $table.checklist, builder: (column) => column);

  GeneratedColumn<String> get parts =>
      $composableBuilder(column: $table.parts, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<String> get assignedTechId => $composableBuilder(
      column: $table.assignedTechId, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => column);

  GeneratedColumn<String> get serviceBookingId => $composableBuilder(
      column: $table.serviceBookingId, builder: (column) => column);

  GeneratedColumn<String> get estimatedCompletion => $composableBuilder(
      column: $table.estimatedCompletion, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CachedTechnicianJobsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CachedTechnicianJobsTable,
    CachedTechnicianJob,
    $$CachedTechnicianJobsTableFilterComposer,
    $$CachedTechnicianJobsTableOrderingComposer,
    $$CachedTechnicianJobsTableAnnotationComposer,
    $$CachedTechnicianJobsTableCreateCompanionBuilder,
    $$CachedTechnicianJobsTableUpdateCompanionBuilder,
    (
      CachedTechnicianJob,
      BaseReferences<_$AppDatabase, $CachedTechnicianJobsTable,
          CachedTechnicianJob>
    ),
    CachedTechnicianJob,
    PrefetchHooks Function()> {
  $$CachedTechnicianJobsTableTableManager(
      _$AppDatabase db, $CachedTechnicianJobsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedTechnicianJobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedTechnicianJobsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedTechnicianJobsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> vehicleModel = const Value.absent(),
            Value<String> vehiclePlate = const Value.absent(),
            Value<String> serviceType = const Value.absent(),
            Value<String> packageName = const Value.absent(),
            Value<String> date = const Value.absent(),
            Value<String> time = const Value.absent(),
            Value<double> progress = const Value.absent(),
            Value<String> checklist = const Value.absent(),
            Value<String> parts = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> price = const Value.absent(),
            Value<String?> assignedTechId = const Value.absent(),
            Value<String?> customerId = const Value.absent(),
            Value<String?> serviceBookingId = const Value.absent(),
            Value<String> estimatedCompletion = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedTechnicianJobsCompanion(
            id: id,
            vehicleModel: vehicleModel,
            vehiclePlate: vehiclePlate,
            serviceType: serviceType,
            packageName: packageName,
            date: date,
            time: time,
            progress: progress,
            checklist: checklist,
            parts: parts,
            status: status,
            price: price,
            assignedTechId: assignedTechId,
            customerId: customerId,
            serviceBookingId: serviceBookingId,
            estimatedCompletion: estimatedCompletion,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String vehicleModel,
            required String vehiclePlate,
            required String serviceType,
            required String packageName,
            required String date,
            required String time,
            required double progress,
            required String checklist,
            required String parts,
            required String status,
            required String price,
            Value<String?> assignedTechId = const Value.absent(),
            Value<String?> customerId = const Value.absent(),
            Value<String?> serviceBookingId = const Value.absent(),
            required String estimatedCompletion,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedTechnicianJobsCompanion.insert(
            id: id,
            vehicleModel: vehicleModel,
            vehiclePlate: vehiclePlate,
            serviceType: serviceType,
            packageName: packageName,
            date: date,
            time: time,
            progress: progress,
            checklist: checklist,
            parts: parts,
            status: status,
            price: price,
            assignedTechId: assignedTechId,
            customerId: customerId,
            serviceBookingId: serviceBookingId,
            estimatedCompletion: estimatedCompletion,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedTechnicianJobsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $CachedTechnicianJobsTable,
        CachedTechnicianJob,
        $$CachedTechnicianJobsTableFilterComposer,
        $$CachedTechnicianJobsTableOrderingComposer,
        $$CachedTechnicianJobsTableAnnotationComposer,
        $$CachedTechnicianJobsTableCreateCompanionBuilder,
        $$CachedTechnicianJobsTableUpdateCompanionBuilder,
        (
          CachedTechnicianJob,
          BaseReferences<_$AppDatabase, $CachedTechnicianJobsTable,
              CachedTechnicianJob>
        ),
        CachedTechnicianJob,
        PrefetchHooks Function()>;
typedef $$HttpResponseCacheTableCreateCompanionBuilder
    = HttpResponseCacheCompanion Function({
  required String cacheKey,
  required String responseBody,
  required DateTime cachedAt,
  Value<int> ttlSeconds,
  Value<int> rowid,
});
typedef $$HttpResponseCacheTableUpdateCompanionBuilder
    = HttpResponseCacheCompanion Function({
  Value<String> cacheKey,
  Value<String> responseBody,
  Value<DateTime> cachedAt,
  Value<int> ttlSeconds,
  Value<int> rowid,
});

class $$HttpResponseCacheTableFilterComposer
    extends Composer<_$AppDatabase, $HttpResponseCacheTable> {
  $$HttpResponseCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cacheKey => $composableBuilder(
      column: $table.cacheKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get responseBody => $composableBuilder(
      column: $table.responseBody, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ttlSeconds => $composableBuilder(
      column: $table.ttlSeconds, builder: (column) => ColumnFilters(column));
}

class $$HttpResponseCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $HttpResponseCacheTable> {
  $$HttpResponseCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cacheKey => $composableBuilder(
      column: $table.cacheKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get responseBody => $composableBuilder(
      column: $table.responseBody,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ttlSeconds => $composableBuilder(
      column: $table.ttlSeconds, builder: (column) => ColumnOrderings(column));
}

class $$HttpResponseCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $HttpResponseCacheTable> {
  $$HttpResponseCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cacheKey =>
      $composableBuilder(column: $table.cacheKey, builder: (column) => column);

  GeneratedColumn<String> get responseBody => $composableBuilder(
      column: $table.responseBody, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);

  GeneratedColumn<int> get ttlSeconds => $composableBuilder(
      column: $table.ttlSeconds, builder: (column) => column);
}

class $$HttpResponseCacheTableTableManager extends RootTableManager<
    _$AppDatabase,
    $HttpResponseCacheTable,
    HttpResponseCacheData,
    $$HttpResponseCacheTableFilterComposer,
    $$HttpResponseCacheTableOrderingComposer,
    $$HttpResponseCacheTableAnnotationComposer,
    $$HttpResponseCacheTableCreateCompanionBuilder,
    $$HttpResponseCacheTableUpdateCompanionBuilder,
    (
      HttpResponseCacheData,
      BaseReferences<_$AppDatabase, $HttpResponseCacheTable,
          HttpResponseCacheData>
    ),
    HttpResponseCacheData,
    PrefetchHooks Function()> {
  $$HttpResponseCacheTableTableManager(
      _$AppDatabase db, $HttpResponseCacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HttpResponseCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HttpResponseCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HttpResponseCacheTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> cacheKey = const Value.absent(),
            Value<String> responseBody = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
            Value<int> ttlSeconds = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HttpResponseCacheCompanion(
            cacheKey: cacheKey,
            responseBody: responseBody,
            cachedAt: cachedAt,
            ttlSeconds: ttlSeconds,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String cacheKey,
            required String responseBody,
            required DateTime cachedAt,
            Value<int> ttlSeconds = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HttpResponseCacheCompanion.insert(
            cacheKey: cacheKey,
            responseBody: responseBody,
            cachedAt: cachedAt,
            ttlSeconds: ttlSeconds,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$HttpResponseCacheTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $HttpResponseCacheTable,
    HttpResponseCacheData,
    $$HttpResponseCacheTableFilterComposer,
    $$HttpResponseCacheTableOrderingComposer,
    $$HttpResponseCacheTableAnnotationComposer,
    $$HttpResponseCacheTableCreateCompanionBuilder,
    $$HttpResponseCacheTableUpdateCompanionBuilder,
    (
      HttpResponseCacheData,
      BaseReferences<_$AppDatabase, $HttpResponseCacheTable,
          HttpResponseCacheData>
    ),
    HttpResponseCacheData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CachedProfilesTableTableManager get cachedProfiles =>
      $$CachedProfilesTableTableManager(_db, _db.cachedProfiles);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
  $$DeadLetterQueueTableTableManager get deadLetterQueue =>
      $$DeadLetterQueueTableTableManager(_db, _db.deadLetterQueue);
  $$CachedRidesTableTableManager get cachedRides =>
      $$CachedRidesTableTableManager(_db, _db.cachedRides);
  $$CachedCategoriesTableTableManager get cachedCategories =>
      $$CachedCategoriesTableTableManager(_db, _db.cachedCategories);
  $$CachedBannersTableTableManager get cachedBanners =>
      $$CachedBannersTableTableManager(_db, _db.cachedBanners);
  $$CachedTechnicianJobsTableTableManager get cachedTechnicianJobs =>
      $$CachedTechnicianJobsTableTableManager(_db, _db.cachedTechnicianJobs);
  $$HttpResponseCacheTableTableManager get httpResponseCache =>
      $$HttpResponseCacheTableTableManager(_db, _db.httpResponseCache);
}
