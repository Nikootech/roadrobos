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
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
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
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    } else if (isInserting) {
      context.missing(_phoneMeta);
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
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone'])!,
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
      map['email'] = Variable<String>(email);
    }
    map['phone'] = Variable<String>(phone);
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
      phone: serializer.fromJson<String>(json['phone']),
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
      'phone': serializer.toJson<String>(phone),
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
      map['email'] = Variable<String>(email.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
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
  @override
  List<GeneratedColumn> get $columns =>
      [id, action, payload, createdAt, attempts];
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
      action: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      attempts: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempts'])!,
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  final int id;
  final String action;
  final String payload;
  final DateTime createdAt;
  final int attempts;
  const SyncQueueData(
      {required this.id,
      required this.action,
      required this.payload,
      required this.createdAt,
      required this.attempts});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['action'] = Variable<String>(action);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['attempts'] = Variable<int>(attempts);
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      action: Value(action),
      payload: Value(payload),
      createdAt: Value(createdAt),
      attempts: Value(attempts),
    );
  }

  factory SyncQueueData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      id: serializer.fromJson<int>(json['id']),
      action: serializer.fromJson<String>(json['action']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      attempts: serializer.fromJson<int>(json['attempts']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'action': serializer.toJson<String>(action),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'attempts': serializer.toJson<int>(attempts),
    };
  }

  SyncQueueData copyWith(
          {int? id,
          String? action,
          String? payload,
          DateTime? createdAt,
          int? attempts}) =>
      SyncQueueData(
        id: id ?? this.id,
        action: action ?? this.action,
        payload: payload ?? this.payload,
        createdAt: createdAt ?? this.createdAt,
        attempts: attempts ?? this.attempts,
      );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      action: data.action.present ? data.action.value : this.action,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('id: $id, ')
          ..write('action: $action, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, action, payload, createdAt, attempts);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.id == this.id &&
          other.action == this.action &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.attempts == this.attempts);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<int> id;
  final Value<String> action;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<int> attempts;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.action = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.attempts = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String action,
    required String payload,
    this.createdAt = const Value.absent(),
    this.attempts = const Value.absent(),
  })  : action = Value(action),
        payload = Value(payload);
  static Insertable<SyncQueueData> custom({
    Expression<int>? id,
    Expression<String>? action,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<int>? attempts,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (action != null) 'action': action,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (attempts != null) 'attempts': attempts,
    });
  }

  SyncQueueCompanion copyWith(
      {Value<int>? id,
      Value<String>? action,
      Value<String>? payload,
      Value<DateTime>? createdAt,
      Value<int>? attempts}) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      action: action ?? this.action,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      attempts: attempts ?? this.attempts,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('action: $action, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts')
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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CachedProfilesTable cachedProfiles = $CachedProfilesTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final $CachedRidesTable cachedRides = $CachedRidesTable(this);
  late final $CachedCategoriesTable cachedCategories =
      $CachedCategoriesTable(this);
  late final $CachedBannersTable cachedBanners = $CachedBannersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [cachedProfiles, syncQueue, cachedRides, cachedCategories, cachedBanners];
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

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

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

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phone =>
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
  required String action,
  required String payload,
  Value<DateTime> createdAt,
  Value<int> attempts,
});
typedef $$SyncQueueTableUpdateCompanionBuilder = SyncQueueCompanion Function({
  Value<int> id,
  Value<String> action,
  Value<String> payload,
  Value<DateTime> createdAt,
  Value<int> attempts,
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

  ColumnFilters<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnFilters(column));
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

  ColumnOrderings<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);
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
            Value<String> action = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> attempts = const Value.absent(),
          }) =>
              SyncQueueCompanion(
            id: id,
            action: action,
            payload: payload,
            createdAt: createdAt,
            attempts: attempts,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String action,
            required String payload,
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> attempts = const Value.absent(),
          }) =>
              SyncQueueCompanion.insert(
            id: id,
            action: action,
            payload: payload,
            createdAt: createdAt,
            attempts: attempts,
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CachedProfilesTableTableManager get cachedProfiles =>
      $$CachedProfilesTableTableManager(_db, _db.cachedProfiles);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
  $$CachedRidesTableTableManager get cachedRides =>
      $$CachedRidesTableTableManager(_db, _db.cachedRides);
  $$CachedCategoriesTableTableManager get cachedCategories =>
      $$CachedCategoriesTableTableManager(_db, _db.cachedCategories);
  $$CachedBannersTableTableManager get cachedBanners =>
      $$CachedBannersTableTableManager(_db, _db.cachedBanners);
}
