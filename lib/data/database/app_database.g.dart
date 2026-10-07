// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UserProfileRowsTable extends UserProfileRows
    with TableInfo<$UserProfileRowsTable, UserProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfileRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
    'locale',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timezoneMeta = const VerificationMeta(
    'timezone',
  );
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
    'timezone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('ml'),
  );
  static const VerificationMeta _dailyTargetMlMeta = const VerificationMeta(
    'dailyTargetMl',
  );
  @override
  late final GeneratedColumn<int> dailyTargetMl = GeneratedColumn<int>(
    'daily_target_ml',
    aliasedName,
    false,
    check: () => ComparableExpr(dailyTargetMl).isBetweenValues(500, 8000),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetIsUserChosenMeta =
      const VerificationMeta('targetIsUserChosen');
  @override
  late final GeneratedColumn<bool> targetIsUserChosen = GeneratedColumn<bool>(
    'target_is_user_chosen',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("target_is_user_chosen" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _wakeMinuteMeta = const VerificationMeta(
    'wakeMinute',
  );
  @override
  late final GeneratedColumn<int> wakeMinute = GeneratedColumn<int>(
    'wake_minute',
    aliasedName,
    false,
    check: () => ComparableExpr(wakeMinute).isBetweenValues(0, 1439),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sleepMinuteMeta = const VerificationMeta(
    'sleepMinute',
  );
  @override
  late final GeneratedColumn<int> sleepMinute = GeneratedColumn<int>(
    'sleep_minute',
    aliasedName,
    false,
    check: () => ComparableExpr(sleepMinute).isBetweenValues(0, 1439),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('balanced'),
  );
  static const VerificationMeta _toneMeta = const VerificationMeta('tone');
  @override
  late final GeneratedColumn<String> tone = GeneratedColumn<String>(
    'tone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('auto'),
  );
  static const VerificationMeta _weekendDifferentMeta = const VerificationMeta(
    'weekendDifferent',
  );
  @override
  late final GeneratedColumn<bool> weekendDifferent = GeneratedColumn<bool>(
    'weekend_different',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("weekend_different" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _weekendWakeMinuteMeta = const VerificationMeta(
    'weekendWakeMinute',
  );
  @override
  late final GeneratedColumn<int> weekendWakeMinute = GeneratedColumn<int>(
    'weekend_wake_minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(480),
  );
  static const VerificationMeta _weekendSleepMinuteMeta =
      const VerificationMeta('weekendSleepMinute');
  @override
  late final GeneratedColumn<int> weekendSleepMinute = GeneratedColumn<int>(
    'weekend_sleep_minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1410),
  );
  static const VerificationMeta _quickAddsJsonMeta = const VerificationMeta(
    'quickAddsJson',
  );
  @override
  late final GeneratedColumn<String> quickAddsJson = GeneratedColumn<String>(
    'quick_adds_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[250,350,500]'),
  );
  static const VerificationMeta _onboardingCompleteMeta =
      const VerificationMeta('onboardingComplete');
  @override
  late final GeneratedColumn<bool> onboardingComplete = GeneratedColumn<bool>(
    'onboarding_complete',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("onboarding_complete" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _remindersEnabledMeta = const VerificationMeta(
    'remindersEnabled',
  );
  @override
  late final GeneratedColumn<bool> remindersEnabled = GeneratedColumn<bool>(
    'reminders_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reminders_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _themeMeta = const VerificationMeta('theme');
  @override
  late final GeneratedColumn<String> theme = GeneratedColumn<String>(
    'theme',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  );
  static const VerificationMeta _activeRoutineIdMeta = const VerificationMeta(
    'activeRoutineId',
  );
  @override
  late final GeneratedColumn<String> activeRoutineId = GeneratedColumn<String>(
    'active_routine_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _environmentHotMeta = const VerificationMeta(
    'environmentHot',
  );
  @override
  late final GeneratedColumn<bool> environmentHot = GeneratedColumn<bool>(
    'environment_hot',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("environment_hot" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    locale,
    timezone,
    unit,
    dailyTargetMl,
    targetIsUserChosen,
    wakeMinute,
    sleepMinute,
    mode,
    tone,
    weekendDifferent,
    weekendWakeMinute,
    weekendSleepMinute,
    quickAddsJson,
    onboardingComplete,
    remindersEnabled,
    theme,
    activeRoutineId,
    environmentHot,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profile_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('locale')) {
      context.handle(
        _localeMeta,
        locale.isAcceptableOrUnknown(data['locale']!, _localeMeta),
      );
    }
    if (data.containsKey('timezone')) {
      context.handle(
        _timezoneMeta,
        timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta),
      );
    } else if (isInserting) {
      context.missing(_timezoneMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('daily_target_ml')) {
      context.handle(
        _dailyTargetMlMeta,
        dailyTargetMl.isAcceptableOrUnknown(
          data['daily_target_ml']!,
          _dailyTargetMlMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dailyTargetMlMeta);
    }
    if (data.containsKey('target_is_user_chosen')) {
      context.handle(
        _targetIsUserChosenMeta,
        targetIsUserChosen.isAcceptableOrUnknown(
          data['target_is_user_chosen']!,
          _targetIsUserChosenMeta,
        ),
      );
    }
    if (data.containsKey('wake_minute')) {
      context.handle(
        _wakeMinuteMeta,
        wakeMinute.isAcceptableOrUnknown(data['wake_minute']!, _wakeMinuteMeta),
      );
    } else if (isInserting) {
      context.missing(_wakeMinuteMeta);
    }
    if (data.containsKey('sleep_minute')) {
      context.handle(
        _sleepMinuteMeta,
        sleepMinute.isAcceptableOrUnknown(
          data['sleep_minute']!,
          _sleepMinuteMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sleepMinuteMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    }
    if (data.containsKey('tone')) {
      context.handle(
        _toneMeta,
        tone.isAcceptableOrUnknown(data['tone']!, _toneMeta),
      );
    }
    if (data.containsKey('weekend_different')) {
      context.handle(
        _weekendDifferentMeta,
        weekendDifferent.isAcceptableOrUnknown(
          data['weekend_different']!,
          _weekendDifferentMeta,
        ),
      );
    }
    if (data.containsKey('weekend_wake_minute')) {
      context.handle(
        _weekendWakeMinuteMeta,
        weekendWakeMinute.isAcceptableOrUnknown(
          data['weekend_wake_minute']!,
          _weekendWakeMinuteMeta,
        ),
      );
    }
    if (data.containsKey('weekend_sleep_minute')) {
      context.handle(
        _weekendSleepMinuteMeta,
        weekendSleepMinute.isAcceptableOrUnknown(
          data['weekend_sleep_minute']!,
          _weekendSleepMinuteMeta,
        ),
      );
    }
    if (data.containsKey('quick_adds_json')) {
      context.handle(
        _quickAddsJsonMeta,
        quickAddsJson.isAcceptableOrUnknown(
          data['quick_adds_json']!,
          _quickAddsJsonMeta,
        ),
      );
    }
    if (data.containsKey('onboarding_complete')) {
      context.handle(
        _onboardingCompleteMeta,
        onboardingComplete.isAcceptableOrUnknown(
          data['onboarding_complete']!,
          _onboardingCompleteMeta,
        ),
      );
    }
    if (data.containsKey('reminders_enabled')) {
      context.handle(
        _remindersEnabledMeta,
        remindersEnabled.isAcceptableOrUnknown(
          data['reminders_enabled']!,
          _remindersEnabledMeta,
        ),
      );
    }
    if (data.containsKey('theme')) {
      context.handle(
        _themeMeta,
        theme.isAcceptableOrUnknown(data['theme']!, _themeMeta),
      );
    }
    if (data.containsKey('active_routine_id')) {
      context.handle(
        _activeRoutineIdMeta,
        activeRoutineId.isAcceptableOrUnknown(
          data['active_routine_id']!,
          _activeRoutineIdMeta,
        ),
      );
    }
    if (data.containsKey('environment_hot')) {
      context.handle(
        _environmentHotMeta,
        environmentHot.isAcceptableOrUnknown(
          data['environment_hot']!,
          _environmentHotMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfileRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      locale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale'],
      ),
      timezone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timezone'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      dailyTargetMl: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_target_ml'],
      )!,
      targetIsUserChosen: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}target_is_user_chosen'],
      )!,
      wakeMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wake_minute'],
      )!,
      sleepMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sleep_minute'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      tone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tone'],
      )!,
      weekendDifferent: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}weekend_different'],
      )!,
      weekendWakeMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekend_wake_minute'],
      )!,
      weekendSleepMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekend_sleep_minute'],
      )!,
      quickAddsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quick_adds_json'],
      )!,
      onboardingComplete: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}onboarding_complete'],
      )!,
      remindersEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reminders_enabled'],
      )!,
      theme: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme'],
      )!,
      activeRoutineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}active_routine_id'],
      ),
      environmentHot: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}environment_hot'],
      )!,
    );
  }

  @override
  $UserProfileRowsTable createAlias(String alias) {
    return $UserProfileRowsTable(attachedDatabase, alias);
  }
}

class UserProfileRow extends DataClass implements Insertable<UserProfileRow> {
  final int id;
  final int createdAt;
  final String? locale;
  final String timezone;
  final String unit;
  final int dailyTargetMl;
  final bool targetIsUserChosen;
  final int wakeMinute;
  final int sleepMinute;
  final String mode;
  final String tone;
  final bool weekendDifferent;
  final int weekendWakeMinute;
  final int weekendSleepMinute;
  final String quickAddsJson;
  final bool onboardingComplete;
  final bool remindersEnabled;
  final String theme;
  final String? activeRoutineId;
  final bool environmentHot;
  const UserProfileRow({
    required this.id,
    required this.createdAt,
    this.locale,
    required this.timezone,
    required this.unit,
    required this.dailyTargetMl,
    required this.targetIsUserChosen,
    required this.wakeMinute,
    required this.sleepMinute,
    required this.mode,
    required this.tone,
    required this.weekendDifferent,
    required this.weekendWakeMinute,
    required this.weekendSleepMinute,
    required this.quickAddsJson,
    required this.onboardingComplete,
    required this.remindersEnabled,
    required this.theme,
    this.activeRoutineId,
    required this.environmentHot,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || locale != null) {
      map['locale'] = Variable<String>(locale);
    }
    map['timezone'] = Variable<String>(timezone);
    map['unit'] = Variable<String>(unit);
    map['daily_target_ml'] = Variable<int>(dailyTargetMl);
    map['target_is_user_chosen'] = Variable<bool>(targetIsUserChosen);
    map['wake_minute'] = Variable<int>(wakeMinute);
    map['sleep_minute'] = Variable<int>(sleepMinute);
    map['mode'] = Variable<String>(mode);
    map['tone'] = Variable<String>(tone);
    map['weekend_different'] = Variable<bool>(weekendDifferent);
    map['weekend_wake_minute'] = Variable<int>(weekendWakeMinute);
    map['weekend_sleep_minute'] = Variable<int>(weekendSleepMinute);
    map['quick_adds_json'] = Variable<String>(quickAddsJson);
    map['onboarding_complete'] = Variable<bool>(onboardingComplete);
    map['reminders_enabled'] = Variable<bool>(remindersEnabled);
    map['theme'] = Variable<String>(theme);
    if (!nullToAbsent || activeRoutineId != null) {
      map['active_routine_id'] = Variable<String>(activeRoutineId);
    }
    map['environment_hot'] = Variable<bool>(environmentHot);
    return map;
  }

  UserProfileRowsCompanion toCompanion(bool nullToAbsent) {
    return UserProfileRowsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      locale: locale == null && nullToAbsent
          ? const Value.absent()
          : Value(locale),
      timezone: Value(timezone),
      unit: Value(unit),
      dailyTargetMl: Value(dailyTargetMl),
      targetIsUserChosen: Value(targetIsUserChosen),
      wakeMinute: Value(wakeMinute),
      sleepMinute: Value(sleepMinute),
      mode: Value(mode),
      tone: Value(tone),
      weekendDifferent: Value(weekendDifferent),
      weekendWakeMinute: Value(weekendWakeMinute),
      weekendSleepMinute: Value(weekendSleepMinute),
      quickAddsJson: Value(quickAddsJson),
      onboardingComplete: Value(onboardingComplete),
      remindersEnabled: Value(remindersEnabled),
      theme: Value(theme),
      activeRoutineId: activeRoutineId == null && nullToAbsent
          ? const Value.absent()
          : Value(activeRoutineId),
      environmentHot: Value(environmentHot),
    );
  }

  factory UserProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfileRow(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      locale: serializer.fromJson<String?>(json['locale']),
      timezone: serializer.fromJson<String>(json['timezone']),
      unit: serializer.fromJson<String>(json['unit']),
      dailyTargetMl: serializer.fromJson<int>(json['dailyTargetMl']),
      targetIsUserChosen: serializer.fromJson<bool>(json['targetIsUserChosen']),
      wakeMinute: serializer.fromJson<int>(json['wakeMinute']),
      sleepMinute: serializer.fromJson<int>(json['sleepMinute']),
      mode: serializer.fromJson<String>(json['mode']),
      tone: serializer.fromJson<String>(json['tone']),
      weekendDifferent: serializer.fromJson<bool>(json['weekendDifferent']),
      weekendWakeMinute: serializer.fromJson<int>(json['weekendWakeMinute']),
      weekendSleepMinute: serializer.fromJson<int>(json['weekendSleepMinute']),
      quickAddsJson: serializer.fromJson<String>(json['quickAddsJson']),
      onboardingComplete: serializer.fromJson<bool>(json['onboardingComplete']),
      remindersEnabled: serializer.fromJson<bool>(json['remindersEnabled']),
      theme: serializer.fromJson<String>(json['theme']),
      activeRoutineId: serializer.fromJson<String?>(json['activeRoutineId']),
      environmentHot: serializer.fromJson<bool>(json['environmentHot']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'locale': serializer.toJson<String?>(locale),
      'timezone': serializer.toJson<String>(timezone),
      'unit': serializer.toJson<String>(unit),
      'dailyTargetMl': serializer.toJson<int>(dailyTargetMl),
      'targetIsUserChosen': serializer.toJson<bool>(targetIsUserChosen),
      'wakeMinute': serializer.toJson<int>(wakeMinute),
      'sleepMinute': serializer.toJson<int>(sleepMinute),
      'mode': serializer.toJson<String>(mode),
      'tone': serializer.toJson<String>(tone),
      'weekendDifferent': serializer.toJson<bool>(weekendDifferent),
      'weekendWakeMinute': serializer.toJson<int>(weekendWakeMinute),
      'weekendSleepMinute': serializer.toJson<int>(weekendSleepMinute),
      'quickAddsJson': serializer.toJson<String>(quickAddsJson),
      'onboardingComplete': serializer.toJson<bool>(onboardingComplete),
      'remindersEnabled': serializer.toJson<bool>(remindersEnabled),
      'theme': serializer.toJson<String>(theme),
      'activeRoutineId': serializer.toJson<String?>(activeRoutineId),
      'environmentHot': serializer.toJson<bool>(environmentHot),
    };
  }

  UserProfileRow copyWith({
    int? id,
    int? createdAt,
    Value<String?> locale = const Value.absent(),
    String? timezone,
    String? unit,
    int? dailyTargetMl,
    bool? targetIsUserChosen,
    int? wakeMinute,
    int? sleepMinute,
    String? mode,
    String? tone,
    bool? weekendDifferent,
    int? weekendWakeMinute,
    int? weekendSleepMinute,
    String? quickAddsJson,
    bool? onboardingComplete,
    bool? remindersEnabled,
    String? theme,
    Value<String?> activeRoutineId = const Value.absent(),
    bool? environmentHot,
  }) => UserProfileRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    locale: locale.present ? locale.value : this.locale,
    timezone: timezone ?? this.timezone,
    unit: unit ?? this.unit,
    dailyTargetMl: dailyTargetMl ?? this.dailyTargetMl,
    targetIsUserChosen: targetIsUserChosen ?? this.targetIsUserChosen,
    wakeMinute: wakeMinute ?? this.wakeMinute,
    sleepMinute: sleepMinute ?? this.sleepMinute,
    mode: mode ?? this.mode,
    tone: tone ?? this.tone,
    weekendDifferent: weekendDifferent ?? this.weekendDifferent,
    weekendWakeMinute: weekendWakeMinute ?? this.weekendWakeMinute,
    weekendSleepMinute: weekendSleepMinute ?? this.weekendSleepMinute,
    quickAddsJson: quickAddsJson ?? this.quickAddsJson,
    onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    remindersEnabled: remindersEnabled ?? this.remindersEnabled,
    theme: theme ?? this.theme,
    activeRoutineId: activeRoutineId.present
        ? activeRoutineId.value
        : this.activeRoutineId,
    environmentHot: environmentHot ?? this.environmentHot,
  );
  UserProfileRow copyWithCompanion(UserProfileRowsCompanion data) {
    return UserProfileRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      locale: data.locale.present ? data.locale.value : this.locale,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      unit: data.unit.present ? data.unit.value : this.unit,
      dailyTargetMl: data.dailyTargetMl.present
          ? data.dailyTargetMl.value
          : this.dailyTargetMl,
      targetIsUserChosen: data.targetIsUserChosen.present
          ? data.targetIsUserChosen.value
          : this.targetIsUserChosen,
      wakeMinute: data.wakeMinute.present
          ? data.wakeMinute.value
          : this.wakeMinute,
      sleepMinute: data.sleepMinute.present
          ? data.sleepMinute.value
          : this.sleepMinute,
      mode: data.mode.present ? data.mode.value : this.mode,
      tone: data.tone.present ? data.tone.value : this.tone,
      weekendDifferent: data.weekendDifferent.present
          ? data.weekendDifferent.value
          : this.weekendDifferent,
      weekendWakeMinute: data.weekendWakeMinute.present
          ? data.weekendWakeMinute.value
          : this.weekendWakeMinute,
      weekendSleepMinute: data.weekendSleepMinute.present
          ? data.weekendSleepMinute.value
          : this.weekendSleepMinute,
      quickAddsJson: data.quickAddsJson.present
          ? data.quickAddsJson.value
          : this.quickAddsJson,
      onboardingComplete: data.onboardingComplete.present
          ? data.onboardingComplete.value
          : this.onboardingComplete,
      remindersEnabled: data.remindersEnabled.present
          ? data.remindersEnabled.value
          : this.remindersEnabled,
      theme: data.theme.present ? data.theme.value : this.theme,
      activeRoutineId: data.activeRoutineId.present
          ? data.activeRoutineId.value
          : this.activeRoutineId,
      environmentHot: data.environmentHot.present
          ? data.environmentHot.value
          : this.environmentHot,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfileRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('locale: $locale, ')
          ..write('timezone: $timezone, ')
          ..write('unit: $unit, ')
          ..write('dailyTargetMl: $dailyTargetMl, ')
          ..write('targetIsUserChosen: $targetIsUserChosen, ')
          ..write('wakeMinute: $wakeMinute, ')
          ..write('sleepMinute: $sleepMinute, ')
          ..write('mode: $mode, ')
          ..write('tone: $tone, ')
          ..write('weekendDifferent: $weekendDifferent, ')
          ..write('weekendWakeMinute: $weekendWakeMinute, ')
          ..write('weekendSleepMinute: $weekendSleepMinute, ')
          ..write('quickAddsJson: $quickAddsJson, ')
          ..write('onboardingComplete: $onboardingComplete, ')
          ..write('remindersEnabled: $remindersEnabled, ')
          ..write('theme: $theme, ')
          ..write('activeRoutineId: $activeRoutineId, ')
          ..write('environmentHot: $environmentHot')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    locale,
    timezone,
    unit,
    dailyTargetMl,
    targetIsUserChosen,
    wakeMinute,
    sleepMinute,
    mode,
    tone,
    weekendDifferent,
    weekendWakeMinute,
    weekendSleepMinute,
    quickAddsJson,
    onboardingComplete,
    remindersEnabled,
    theme,
    activeRoutineId,
    environmentHot,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfileRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.locale == this.locale &&
          other.timezone == this.timezone &&
          other.unit == this.unit &&
          other.dailyTargetMl == this.dailyTargetMl &&
          other.targetIsUserChosen == this.targetIsUserChosen &&
          other.wakeMinute == this.wakeMinute &&
          other.sleepMinute == this.sleepMinute &&
          other.mode == this.mode &&
          other.tone == this.tone &&
          other.weekendDifferent == this.weekendDifferent &&
          other.weekendWakeMinute == this.weekendWakeMinute &&
          other.weekendSleepMinute == this.weekendSleepMinute &&
          other.quickAddsJson == this.quickAddsJson &&
          other.onboardingComplete == this.onboardingComplete &&
          other.remindersEnabled == this.remindersEnabled &&
          other.theme == this.theme &&
          other.activeRoutineId == this.activeRoutineId &&
          other.environmentHot == this.environmentHot);
}

class UserProfileRowsCompanion extends UpdateCompanion<UserProfileRow> {
  final Value<int> id;
  final Value<int> createdAt;
  final Value<String?> locale;
  final Value<String> timezone;
  final Value<String> unit;
  final Value<int> dailyTargetMl;
  final Value<bool> targetIsUserChosen;
  final Value<int> wakeMinute;
  final Value<int> sleepMinute;
  final Value<String> mode;
  final Value<String> tone;
  final Value<bool> weekendDifferent;
  final Value<int> weekendWakeMinute;
  final Value<int> weekendSleepMinute;
  final Value<String> quickAddsJson;
  final Value<bool> onboardingComplete;
  final Value<bool> remindersEnabled;
  final Value<String> theme;
  final Value<String?> activeRoutineId;
  final Value<bool> environmentHot;
  const UserProfileRowsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.locale = const Value.absent(),
    this.timezone = const Value.absent(),
    this.unit = const Value.absent(),
    this.dailyTargetMl = const Value.absent(),
    this.targetIsUserChosen = const Value.absent(),
    this.wakeMinute = const Value.absent(),
    this.sleepMinute = const Value.absent(),
    this.mode = const Value.absent(),
    this.tone = const Value.absent(),
    this.weekendDifferent = const Value.absent(),
    this.weekendWakeMinute = const Value.absent(),
    this.weekendSleepMinute = const Value.absent(),
    this.quickAddsJson = const Value.absent(),
    this.onboardingComplete = const Value.absent(),
    this.remindersEnabled = const Value.absent(),
    this.theme = const Value.absent(),
    this.activeRoutineId = const Value.absent(),
    this.environmentHot = const Value.absent(),
  });
  UserProfileRowsCompanion.insert({
    this.id = const Value.absent(),
    required int createdAt,
    this.locale = const Value.absent(),
    required String timezone,
    this.unit = const Value.absent(),
    required int dailyTargetMl,
    this.targetIsUserChosen = const Value.absent(),
    required int wakeMinute,
    required int sleepMinute,
    this.mode = const Value.absent(),
    this.tone = const Value.absent(),
    this.weekendDifferent = const Value.absent(),
    this.weekendWakeMinute = const Value.absent(),
    this.weekendSleepMinute = const Value.absent(),
    this.quickAddsJson = const Value.absent(),
    this.onboardingComplete = const Value.absent(),
    this.remindersEnabled = const Value.absent(),
    this.theme = const Value.absent(),
    this.activeRoutineId = const Value.absent(),
    this.environmentHot = const Value.absent(),
  }) : createdAt = Value(createdAt),
       timezone = Value(timezone),
       dailyTargetMl = Value(dailyTargetMl),
       wakeMinute = Value(wakeMinute),
       sleepMinute = Value(sleepMinute);
  static Insertable<UserProfileRow> custom({
    Expression<int>? id,
    Expression<int>? createdAt,
    Expression<String>? locale,
    Expression<String>? timezone,
    Expression<String>? unit,
    Expression<int>? dailyTargetMl,
    Expression<bool>? targetIsUserChosen,
    Expression<int>? wakeMinute,
    Expression<int>? sleepMinute,
    Expression<String>? mode,
    Expression<String>? tone,
    Expression<bool>? weekendDifferent,
    Expression<int>? weekendWakeMinute,
    Expression<int>? weekendSleepMinute,
    Expression<String>? quickAddsJson,
    Expression<bool>? onboardingComplete,
    Expression<bool>? remindersEnabled,
    Expression<String>? theme,
    Expression<String>? activeRoutineId,
    Expression<bool>? environmentHot,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (locale != null) 'locale': locale,
      if (timezone != null) 'timezone': timezone,
      if (unit != null) 'unit': unit,
      if (dailyTargetMl != null) 'daily_target_ml': dailyTargetMl,
      if (targetIsUserChosen != null)
        'target_is_user_chosen': targetIsUserChosen,
      if (wakeMinute != null) 'wake_minute': wakeMinute,
      if (sleepMinute != null) 'sleep_minute': sleepMinute,
      if (mode != null) 'mode': mode,
      if (tone != null) 'tone': tone,
      if (weekendDifferent != null) 'weekend_different': weekendDifferent,
      if (weekendWakeMinute != null) 'weekend_wake_minute': weekendWakeMinute,
      if (weekendSleepMinute != null)
        'weekend_sleep_minute': weekendSleepMinute,
      if (quickAddsJson != null) 'quick_adds_json': quickAddsJson,
      if (onboardingComplete != null) 'onboarding_complete': onboardingComplete,
      if (remindersEnabled != null) 'reminders_enabled': remindersEnabled,
      if (theme != null) 'theme': theme,
      if (activeRoutineId != null) 'active_routine_id': activeRoutineId,
      if (environmentHot != null) 'environment_hot': environmentHot,
    });
  }

  UserProfileRowsCompanion copyWith({
    Value<int>? id,
    Value<int>? createdAt,
    Value<String?>? locale,
    Value<String>? timezone,
    Value<String>? unit,
    Value<int>? dailyTargetMl,
    Value<bool>? targetIsUserChosen,
    Value<int>? wakeMinute,
    Value<int>? sleepMinute,
    Value<String>? mode,
    Value<String>? tone,
    Value<bool>? weekendDifferent,
    Value<int>? weekendWakeMinute,
    Value<int>? weekendSleepMinute,
    Value<String>? quickAddsJson,
    Value<bool>? onboardingComplete,
    Value<bool>? remindersEnabled,
    Value<String>? theme,
    Value<String?>? activeRoutineId,
    Value<bool>? environmentHot,
  }) {
    return UserProfileRowsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      locale: locale ?? this.locale,
      timezone: timezone ?? this.timezone,
      unit: unit ?? this.unit,
      dailyTargetMl: dailyTargetMl ?? this.dailyTargetMl,
      targetIsUserChosen: targetIsUserChosen ?? this.targetIsUserChosen,
      wakeMinute: wakeMinute ?? this.wakeMinute,
      sleepMinute: sleepMinute ?? this.sleepMinute,
      mode: mode ?? this.mode,
      tone: tone ?? this.tone,
      weekendDifferent: weekendDifferent ?? this.weekendDifferent,
      weekendWakeMinute: weekendWakeMinute ?? this.weekendWakeMinute,
      weekendSleepMinute: weekendSleepMinute ?? this.weekendSleepMinute,
      quickAddsJson: quickAddsJson ?? this.quickAddsJson,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      theme: theme ?? this.theme,
      activeRoutineId: activeRoutineId ?? this.activeRoutineId,
      environmentHot: environmentHot ?? this.environmentHot,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (locale.present) {
      map['locale'] = Variable<String>(locale.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (dailyTargetMl.present) {
      map['daily_target_ml'] = Variable<int>(dailyTargetMl.value);
    }
    if (targetIsUserChosen.present) {
      map['target_is_user_chosen'] = Variable<bool>(targetIsUserChosen.value);
    }
    if (wakeMinute.present) {
      map['wake_minute'] = Variable<int>(wakeMinute.value);
    }
    if (sleepMinute.present) {
      map['sleep_minute'] = Variable<int>(sleepMinute.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (tone.present) {
      map['tone'] = Variable<String>(tone.value);
    }
    if (weekendDifferent.present) {
      map['weekend_different'] = Variable<bool>(weekendDifferent.value);
    }
    if (weekendWakeMinute.present) {
      map['weekend_wake_minute'] = Variable<int>(weekendWakeMinute.value);
    }
    if (weekendSleepMinute.present) {
      map['weekend_sleep_minute'] = Variable<int>(weekendSleepMinute.value);
    }
    if (quickAddsJson.present) {
      map['quick_adds_json'] = Variable<String>(quickAddsJson.value);
    }
    if (onboardingComplete.present) {
      map['onboarding_complete'] = Variable<bool>(onboardingComplete.value);
    }
    if (remindersEnabled.present) {
      map['reminders_enabled'] = Variable<bool>(remindersEnabled.value);
    }
    if (theme.present) {
      map['theme'] = Variable<String>(theme.value);
    }
    if (activeRoutineId.present) {
      map['active_routine_id'] = Variable<String>(activeRoutineId.value);
    }
    if (environmentHot.present) {
      map['environment_hot'] = Variable<bool>(environmentHot.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfileRowsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('locale: $locale, ')
          ..write('timezone: $timezone, ')
          ..write('unit: $unit, ')
          ..write('dailyTargetMl: $dailyTargetMl, ')
          ..write('targetIsUserChosen: $targetIsUserChosen, ')
          ..write('wakeMinute: $wakeMinute, ')
          ..write('sleepMinute: $sleepMinute, ')
          ..write('mode: $mode, ')
          ..write('tone: $tone, ')
          ..write('weekendDifferent: $weekendDifferent, ')
          ..write('weekendWakeMinute: $weekendWakeMinute, ')
          ..write('weekendSleepMinute: $weekendSleepMinute, ')
          ..write('quickAddsJson: $quickAddsJson, ')
          ..write('onboardingComplete: $onboardingComplete, ')
          ..write('remindersEnabled: $remindersEnabled, ')
          ..write('theme: $theme, ')
          ..write('activeRoutineId: $activeRoutineId, ')
          ..write('environmentHot: $environmentHot')
          ..write(')'))
        .toString();
  }
}

class $HydrationEntriesTable extends HydrationEntries
    with TableInfo<$HydrationEntriesTable, HydrationEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HydrationEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampUtcMeta = const VerificationMeta(
    'timestampUtc',
  );
  @override
  late final GeneratedColumn<int> timestampUtc = GeneratedColumn<int>(
    'timestamp_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timezoneMeta = const VerificationMeta(
    'timezone',
  );
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
    'timezone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localDateMeta = const VerificationMeta(
    'localDate',
  );
  @override
  late final GeneratedColumn<String> localDate = GeneratedColumn<String>(
    'local_date',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 10,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _volumeMlMeta = const VerificationMeta(
    'volumeMl',
  );
  @override
  late final GeneratedColumn<int> volumeMl = GeneratedColumn<int>(
    'volume_ml',
    aliasedName,
    false,
    check: () => ComparableExpr(volumeMl).isBetweenValues(1, 5000),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _beverageMeta = const VerificationMeta(
    'beverage',
  );
  @override
  late final GeneratedColumn<String> beverage = GeneratedColumn<String>(
    'beverage',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('water'),
  );
  static const VerificationMeta _vesselIdMeta = const VerificationMeta(
    'vesselId',
  );
  @override
  late final GeneratedColumn<String> vesselId = GeneratedColumn<String>(
    'vessel_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _externalRecordIdMeta = const VerificationMeta(
    'externalRecordId',
  );
  @override
  late final GeneratedColumn<String> externalRecordId = GeneratedColumn<String>(
    'external_record_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    timestampUtc,
    timezone,
    localDate,
    volumeMl,
    beverage,
    vesselId,
    source,
    externalRecordId,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hydration_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<HydrationEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('timestamp_utc')) {
      context.handle(
        _timestampUtcMeta,
        timestampUtc.isAcceptableOrUnknown(
          data['timestamp_utc']!,
          _timestampUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timestampUtcMeta);
    }
    if (data.containsKey('timezone')) {
      context.handle(
        _timezoneMeta,
        timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta),
      );
    } else if (isInserting) {
      context.missing(_timezoneMeta);
    }
    if (data.containsKey('local_date')) {
      context.handle(
        _localDateMeta,
        localDate.isAcceptableOrUnknown(data['local_date']!, _localDateMeta),
      );
    } else if (isInserting) {
      context.missing(_localDateMeta);
    }
    if (data.containsKey('volume_ml')) {
      context.handle(
        _volumeMlMeta,
        volumeMl.isAcceptableOrUnknown(data['volume_ml']!, _volumeMlMeta),
      );
    } else if (isInserting) {
      context.missing(_volumeMlMeta);
    }
    if (data.containsKey('beverage')) {
      context.handle(
        _beverageMeta,
        beverage.isAcceptableOrUnknown(data['beverage']!, _beverageMeta),
      );
    }
    if (data.containsKey('vessel_id')) {
      context.handle(
        _vesselIdMeta,
        vesselId.isAcceptableOrUnknown(data['vessel_id']!, _vesselIdMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('external_record_id')) {
      context.handle(
        _externalRecordIdMeta,
        externalRecordId.isAcceptableOrUnknown(
          data['external_record_id']!,
          _externalRecordIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HydrationEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HydrationEntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      timestampUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timestamp_utc'],
      )!,
      timezone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timezone'],
      )!,
      localDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_date'],
      )!,
      volumeMl: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}volume_ml'],
      )!,
      beverage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}beverage'],
      )!,
      vesselId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vessel_id'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      externalRecordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_record_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $HydrationEntriesTable createAlias(String alias) {
    return $HydrationEntriesTable(attachedDatabase, alias);
  }
}

class HydrationEntryRow extends DataClass
    implements Insertable<HydrationEntryRow> {
  final String id;

  /// Absolute instant, milliseconds since epoch (UTC).
  final int timestampUtc;
  final String timezone;
  final String localDate;
  final int volumeMl;
  final String beverage;
  final String? vesselId;
  final String source;
  final String? externalRecordId;
  final int createdAt;
  final int updatedAt;
  const HydrationEntryRow({
    required this.id,
    required this.timestampUtc,
    required this.timezone,
    required this.localDate,
    required this.volumeMl,
    required this.beverage,
    this.vesselId,
    required this.source,
    this.externalRecordId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['timestamp_utc'] = Variable<int>(timestampUtc);
    map['timezone'] = Variable<String>(timezone);
    map['local_date'] = Variable<String>(localDate);
    map['volume_ml'] = Variable<int>(volumeMl);
    map['beverage'] = Variable<String>(beverage);
    if (!nullToAbsent || vesselId != null) {
      map['vessel_id'] = Variable<String>(vesselId);
    }
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || externalRecordId != null) {
      map['external_record_id'] = Variable<String>(externalRecordId);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  HydrationEntriesCompanion toCompanion(bool nullToAbsent) {
    return HydrationEntriesCompanion(
      id: Value(id),
      timestampUtc: Value(timestampUtc),
      timezone: Value(timezone),
      localDate: Value(localDate),
      volumeMl: Value(volumeMl),
      beverage: Value(beverage),
      vesselId: vesselId == null && nullToAbsent
          ? const Value.absent()
          : Value(vesselId),
      source: Value(source),
      externalRecordId: externalRecordId == null && nullToAbsent
          ? const Value.absent()
          : Value(externalRecordId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory HydrationEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HydrationEntryRow(
      id: serializer.fromJson<String>(json['id']),
      timestampUtc: serializer.fromJson<int>(json['timestampUtc']),
      timezone: serializer.fromJson<String>(json['timezone']),
      localDate: serializer.fromJson<String>(json['localDate']),
      volumeMl: serializer.fromJson<int>(json['volumeMl']),
      beverage: serializer.fromJson<String>(json['beverage']),
      vesselId: serializer.fromJson<String?>(json['vesselId']),
      source: serializer.fromJson<String>(json['source']),
      externalRecordId: serializer.fromJson<String?>(json['externalRecordId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'timestampUtc': serializer.toJson<int>(timestampUtc),
      'timezone': serializer.toJson<String>(timezone),
      'localDate': serializer.toJson<String>(localDate),
      'volumeMl': serializer.toJson<int>(volumeMl),
      'beverage': serializer.toJson<String>(beverage),
      'vesselId': serializer.toJson<String?>(vesselId),
      'source': serializer.toJson<String>(source),
      'externalRecordId': serializer.toJson<String?>(externalRecordId),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  HydrationEntryRow copyWith({
    String? id,
    int? timestampUtc,
    String? timezone,
    String? localDate,
    int? volumeMl,
    String? beverage,
    Value<String?> vesselId = const Value.absent(),
    String? source,
    Value<String?> externalRecordId = const Value.absent(),
    int? createdAt,
    int? updatedAt,
  }) => HydrationEntryRow(
    id: id ?? this.id,
    timestampUtc: timestampUtc ?? this.timestampUtc,
    timezone: timezone ?? this.timezone,
    localDate: localDate ?? this.localDate,
    volumeMl: volumeMl ?? this.volumeMl,
    beverage: beverage ?? this.beverage,
    vesselId: vesselId.present ? vesselId.value : this.vesselId,
    source: source ?? this.source,
    externalRecordId: externalRecordId.present
        ? externalRecordId.value
        : this.externalRecordId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  HydrationEntryRow copyWithCompanion(HydrationEntriesCompanion data) {
    return HydrationEntryRow(
      id: data.id.present ? data.id.value : this.id,
      timestampUtc: data.timestampUtc.present
          ? data.timestampUtc.value
          : this.timestampUtc,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
      volumeMl: data.volumeMl.present ? data.volumeMl.value : this.volumeMl,
      beverage: data.beverage.present ? data.beverage.value : this.beverage,
      vesselId: data.vesselId.present ? data.vesselId.value : this.vesselId,
      source: data.source.present ? data.source.value : this.source,
      externalRecordId: data.externalRecordId.present
          ? data.externalRecordId.value
          : this.externalRecordId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HydrationEntryRow(')
          ..write('id: $id, ')
          ..write('timestampUtc: $timestampUtc, ')
          ..write('timezone: $timezone, ')
          ..write('localDate: $localDate, ')
          ..write('volumeMl: $volumeMl, ')
          ..write('beverage: $beverage, ')
          ..write('vesselId: $vesselId, ')
          ..write('source: $source, ')
          ..write('externalRecordId: $externalRecordId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    timestampUtc,
    timezone,
    localDate,
    volumeMl,
    beverage,
    vesselId,
    source,
    externalRecordId,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HydrationEntryRow &&
          other.id == this.id &&
          other.timestampUtc == this.timestampUtc &&
          other.timezone == this.timezone &&
          other.localDate == this.localDate &&
          other.volumeMl == this.volumeMl &&
          other.beverage == this.beverage &&
          other.vesselId == this.vesselId &&
          other.source == this.source &&
          other.externalRecordId == this.externalRecordId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class HydrationEntriesCompanion extends UpdateCompanion<HydrationEntryRow> {
  final Value<String> id;
  final Value<int> timestampUtc;
  final Value<String> timezone;
  final Value<String> localDate;
  final Value<int> volumeMl;
  final Value<String> beverage;
  final Value<String?> vesselId;
  final Value<String> source;
  final Value<String?> externalRecordId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const HydrationEntriesCompanion({
    this.id = const Value.absent(),
    this.timestampUtc = const Value.absent(),
    this.timezone = const Value.absent(),
    this.localDate = const Value.absent(),
    this.volumeMl = const Value.absent(),
    this.beverage = const Value.absent(),
    this.vesselId = const Value.absent(),
    this.source = const Value.absent(),
    this.externalRecordId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HydrationEntriesCompanion.insert({
    required String id,
    required int timestampUtc,
    required String timezone,
    required String localDate,
    required int volumeMl,
    this.beverage = const Value.absent(),
    this.vesselId = const Value.absent(),
    required String source,
    this.externalRecordId = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       timestampUtc = Value(timestampUtc),
       timezone = Value(timezone),
       localDate = Value(localDate),
       volumeMl = Value(volumeMl),
       source = Value(source),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<HydrationEntryRow> custom({
    Expression<String>? id,
    Expression<int>? timestampUtc,
    Expression<String>? timezone,
    Expression<String>? localDate,
    Expression<int>? volumeMl,
    Expression<String>? beverage,
    Expression<String>? vesselId,
    Expression<String>? source,
    Expression<String>? externalRecordId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (timestampUtc != null) 'timestamp_utc': timestampUtc,
      if (timezone != null) 'timezone': timezone,
      if (localDate != null) 'local_date': localDate,
      if (volumeMl != null) 'volume_ml': volumeMl,
      if (beverage != null) 'beverage': beverage,
      if (vesselId != null) 'vessel_id': vesselId,
      if (source != null) 'source': source,
      if (externalRecordId != null) 'external_record_id': externalRecordId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HydrationEntriesCompanion copyWith({
    Value<String>? id,
    Value<int>? timestampUtc,
    Value<String>? timezone,
    Value<String>? localDate,
    Value<int>? volumeMl,
    Value<String>? beverage,
    Value<String?>? vesselId,
    Value<String>? source,
    Value<String?>? externalRecordId,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return HydrationEntriesCompanion(
      id: id ?? this.id,
      timestampUtc: timestampUtc ?? this.timestampUtc,
      timezone: timezone ?? this.timezone,
      localDate: localDate ?? this.localDate,
      volumeMl: volumeMl ?? this.volumeMl,
      beverage: beverage ?? this.beverage,
      vesselId: vesselId ?? this.vesselId,
      source: source ?? this.source,
      externalRecordId: externalRecordId ?? this.externalRecordId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (timestampUtc.present) {
      map['timestamp_utc'] = Variable<int>(timestampUtc.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (localDate.present) {
      map['local_date'] = Variable<String>(localDate.value);
    }
    if (volumeMl.present) {
      map['volume_ml'] = Variable<int>(volumeMl.value);
    }
    if (beverage.present) {
      map['beverage'] = Variable<String>(beverage.value);
    }
    if (vesselId.present) {
      map['vessel_id'] = Variable<String>(vesselId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (externalRecordId.present) {
      map['external_record_id'] = Variable<String>(externalRecordId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HydrationEntriesCompanion(')
          ..write('id: $id, ')
          ..write('timestampUtc: $timestampUtc, ')
          ..write('timezone: $timezone, ')
          ..write('localDate: $localDate, ')
          ..write('volumeMl: $volumeMl, ')
          ..write('beverage: $beverage, ')
          ..write('vesselId: $vesselId, ')
          ..write('source: $source, ')
          ..write('externalRecordId: $externalRecordId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VesselsTable extends Vessels with TableInfo<$VesselsTable, VesselRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VesselsTable(this.attachedDatabase, [this._alias]);
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
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _volumeMlMeta = const VerificationMeta(
    'volumeMl',
  );
  @override
  late final GeneratedColumn<int> volumeMl = GeneratedColumn<int>(
    'volume_ml',
    aliasedName,
    false,
    check: () => ComparableExpr(volumeMl).isBetweenValues(1, 5000),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('glass'),
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    volumeMl,
    icon,
    isFavorite,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vessels';
  @override
  VerificationContext validateIntegrity(
    Insertable<VesselRow> instance, {
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
    if (data.containsKey('volume_ml')) {
      context.handle(
        _volumeMlMeta,
        volumeMl.isAcceptableOrUnknown(data['volume_ml']!, _volumeMlMeta),
      );
    } else if (isInserting) {
      context.missing(_volumeMlMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VesselRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VesselRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      volumeMl: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}volume_ml'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $VesselsTable createAlias(String alias) {
    return $VesselsTable(attachedDatabase, alias);
  }
}

class VesselRow extends DataClass implements Insertable<VesselRow> {
  final String id;
  final String name;
  final int volumeMl;
  final String icon;
  final bool isFavorite;
  final int sortOrder;
  const VesselRow({
    required this.id,
    required this.name,
    required this.volumeMl,
    required this.icon,
    required this.isFavorite,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['volume_ml'] = Variable<int>(volumeMl);
    map['icon'] = Variable<String>(icon);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  VesselsCompanion toCompanion(bool nullToAbsent) {
    return VesselsCompanion(
      id: Value(id),
      name: Value(name),
      volumeMl: Value(volumeMl),
      icon: Value(icon),
      isFavorite: Value(isFavorite),
      sortOrder: Value(sortOrder),
    );
  }

  factory VesselRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VesselRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      volumeMl: serializer.fromJson<int>(json['volumeMl']),
      icon: serializer.fromJson<String>(json['icon']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'volumeMl': serializer.toJson<int>(volumeMl),
      'icon': serializer.toJson<String>(icon),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  VesselRow copyWith({
    String? id,
    String? name,
    int? volumeMl,
    String? icon,
    bool? isFavorite,
    int? sortOrder,
  }) => VesselRow(
    id: id ?? this.id,
    name: name ?? this.name,
    volumeMl: volumeMl ?? this.volumeMl,
    icon: icon ?? this.icon,
    isFavorite: isFavorite ?? this.isFavorite,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  VesselRow copyWithCompanion(VesselsCompanion data) {
    return VesselRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      volumeMl: data.volumeMl.present ? data.volumeMl.value : this.volumeMl,
      icon: data.icon.present ? data.icon.value : this.icon,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VesselRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('volumeMl: $volumeMl, ')
          ..write('icon: $icon, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, volumeMl, icon, isFavorite, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VesselRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.volumeMl == this.volumeMl &&
          other.icon == this.icon &&
          other.isFavorite == this.isFavorite &&
          other.sortOrder == this.sortOrder);
}

class VesselsCompanion extends UpdateCompanion<VesselRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> volumeMl;
  final Value<String> icon;
  final Value<bool> isFavorite;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const VesselsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.volumeMl = const Value.absent(),
    this.icon = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VesselsCompanion.insert({
    required String id,
    required String name,
    required int volumeMl,
    this.icon = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       volumeMl = Value(volumeMl);
  static Insertable<VesselRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? volumeMl,
    Expression<String>? icon,
    Expression<bool>? isFavorite,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (volumeMl != null) 'volume_ml': volumeMl,
      if (icon != null) 'icon': icon,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VesselsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? volumeMl,
    Value<String>? icon,
    Value<bool>? isFavorite,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return VesselsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      volumeMl: volumeMl ?? this.volumeMl,
      icon: icon ?? this.icon,
      isFavorite: isFavorite ?? this.isFavorite,
      sortOrder: sortOrder ?? this.sortOrder,
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
    if (volumeMl.present) {
      map['volume_ml'] = Variable<int>(volumeMl.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VesselsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('volumeMl: $volumeMl, ')
          ..write('icon: $icon, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoutinesTable extends Routines
    with TableInfo<$RoutinesTable, RoutineRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutinesTable(this.attachedDatabase, [this._alias]);
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
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weekdaysJsonMeta = const VerificationMeta(
    'weekdaysJson',
  );
  @override
  late final GeneratedColumn<String> weekdaysJson = GeneratedColumn<String>(
    'weekdays_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _wakeMinuteMeta = const VerificationMeta(
    'wakeMinute',
  );
  @override
  late final GeneratedColumn<int> wakeMinute = GeneratedColumn<int>(
    'wake_minute',
    aliasedName,
    false,
    check: () => ComparableExpr(wakeMinute).isBetweenValues(0, 1439),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sleepMinuteMeta = const VerificationMeta(
    'sleepMinute',
  );
  @override
  late final GeneratedColumn<int> sleepMinute = GeneratedColumn<int>(
    'sleep_minute',
    aliasedName,
    false,
    check: () => ComparableExpr(sleepMinute).isBetweenValues(0, 1439),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('balanced'),
  );
  static const VerificationMeta _quietJsonMeta = const VerificationMeta(
    'quietJson',
  );
  @override
  late final GeneratedColumn<String> quietJson = GeneratedColumn<String>(
    'quiet_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _workoutJsonMeta = const VerificationMeta(
    'workoutJson',
  );
  @override
  late final GeneratedColumn<String> workoutJson = GeneratedColumn<String>(
    'workout_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _quickAddsJsonMeta = const VerificationMeta(
    'quickAddsJson',
  );
  @override
  late final GeneratedColumn<String> quickAddsJson = GeneratedColumn<String>(
    'quick_adds_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    kind,
    weekdaysJson,
    wakeMinute,
    sleepMinute,
    mode,
    quietJson,
    workoutJson,
    quickAddsJson,
    enabled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routines';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutineRow> instance, {
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
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('weekdays_json')) {
      context.handle(
        _weekdaysJsonMeta,
        weekdaysJson.isAcceptableOrUnknown(
          data['weekdays_json']!,
          _weekdaysJsonMeta,
        ),
      );
    }
    if (data.containsKey('wake_minute')) {
      context.handle(
        _wakeMinuteMeta,
        wakeMinute.isAcceptableOrUnknown(data['wake_minute']!, _wakeMinuteMeta),
      );
    } else if (isInserting) {
      context.missing(_wakeMinuteMeta);
    }
    if (data.containsKey('sleep_minute')) {
      context.handle(
        _sleepMinuteMeta,
        sleepMinute.isAcceptableOrUnknown(
          data['sleep_minute']!,
          _sleepMinuteMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sleepMinuteMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    }
    if (data.containsKey('quiet_json')) {
      context.handle(
        _quietJsonMeta,
        quietJson.isAcceptableOrUnknown(data['quiet_json']!, _quietJsonMeta),
      );
    }
    if (data.containsKey('workout_json')) {
      context.handle(
        _workoutJsonMeta,
        workoutJson.isAcceptableOrUnknown(
          data['workout_json']!,
          _workoutJsonMeta,
        ),
      );
    }
    if (data.containsKey('quick_adds_json')) {
      context.handle(
        _quickAddsJsonMeta,
        quickAddsJson.isAcceptableOrUnknown(
          data['quick_adds_json']!,
          _quickAddsJsonMeta,
        ),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoutineRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      weekdaysJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weekdays_json'],
      )!,
      wakeMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wake_minute'],
      )!,
      sleepMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sleep_minute'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      quietJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quiet_json'],
      )!,
      workoutJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workout_json'],
      )!,
      quickAddsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quick_adds_json'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
    );
  }

  @override
  $RoutinesTable createAlias(String alias) {
    return $RoutinesTable(attachedDatabase, alias);
  }
}

class RoutineRow extends DataClass implements Insertable<RoutineRow> {
  final String id;
  final String name;
  final String kind;
  final String weekdaysJson;
  final int wakeMinute;
  final int sleepMinute;
  final String mode;
  final String quietJson;
  final String workoutJson;
  final String quickAddsJson;
  final bool enabled;
  const RoutineRow({
    required this.id,
    required this.name,
    required this.kind,
    required this.weekdaysJson,
    required this.wakeMinute,
    required this.sleepMinute,
    required this.mode,
    required this.quietJson,
    required this.workoutJson,
    required this.quickAddsJson,
    required this.enabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    map['weekdays_json'] = Variable<String>(weekdaysJson);
    map['wake_minute'] = Variable<int>(wakeMinute);
    map['sleep_minute'] = Variable<int>(sleepMinute);
    map['mode'] = Variable<String>(mode);
    map['quiet_json'] = Variable<String>(quietJson);
    map['workout_json'] = Variable<String>(workoutJson);
    map['quick_adds_json'] = Variable<String>(quickAddsJson);
    map['enabled'] = Variable<bool>(enabled);
    return map;
  }

  RoutinesCompanion toCompanion(bool nullToAbsent) {
    return RoutinesCompanion(
      id: Value(id),
      name: Value(name),
      kind: Value(kind),
      weekdaysJson: Value(weekdaysJson),
      wakeMinute: Value(wakeMinute),
      sleepMinute: Value(sleepMinute),
      mode: Value(mode),
      quietJson: Value(quietJson),
      workoutJson: Value(workoutJson),
      quickAddsJson: Value(quickAddsJson),
      enabled: Value(enabled),
    );
  }

  factory RoutineRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      weekdaysJson: serializer.fromJson<String>(json['weekdaysJson']),
      wakeMinute: serializer.fromJson<int>(json['wakeMinute']),
      sleepMinute: serializer.fromJson<int>(json['sleepMinute']),
      mode: serializer.fromJson<String>(json['mode']),
      quietJson: serializer.fromJson<String>(json['quietJson']),
      workoutJson: serializer.fromJson<String>(json['workoutJson']),
      quickAddsJson: serializer.fromJson<String>(json['quickAddsJson']),
      enabled: serializer.fromJson<bool>(json['enabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'weekdaysJson': serializer.toJson<String>(weekdaysJson),
      'wakeMinute': serializer.toJson<int>(wakeMinute),
      'sleepMinute': serializer.toJson<int>(sleepMinute),
      'mode': serializer.toJson<String>(mode),
      'quietJson': serializer.toJson<String>(quietJson),
      'workoutJson': serializer.toJson<String>(workoutJson),
      'quickAddsJson': serializer.toJson<String>(quickAddsJson),
      'enabled': serializer.toJson<bool>(enabled),
    };
  }

  RoutineRow copyWith({
    String? id,
    String? name,
    String? kind,
    String? weekdaysJson,
    int? wakeMinute,
    int? sleepMinute,
    String? mode,
    String? quietJson,
    String? workoutJson,
    String? quickAddsJson,
    bool? enabled,
  }) => RoutineRow(
    id: id ?? this.id,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    weekdaysJson: weekdaysJson ?? this.weekdaysJson,
    wakeMinute: wakeMinute ?? this.wakeMinute,
    sleepMinute: sleepMinute ?? this.sleepMinute,
    mode: mode ?? this.mode,
    quietJson: quietJson ?? this.quietJson,
    workoutJson: workoutJson ?? this.workoutJson,
    quickAddsJson: quickAddsJson ?? this.quickAddsJson,
    enabled: enabled ?? this.enabled,
  );
  RoutineRow copyWithCompanion(RoutinesCompanion data) {
    return RoutineRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      weekdaysJson: data.weekdaysJson.present
          ? data.weekdaysJson.value
          : this.weekdaysJson,
      wakeMinute: data.wakeMinute.present
          ? data.wakeMinute.value
          : this.wakeMinute,
      sleepMinute: data.sleepMinute.present
          ? data.sleepMinute.value
          : this.sleepMinute,
      mode: data.mode.present ? data.mode.value : this.mode,
      quietJson: data.quietJson.present ? data.quietJson.value : this.quietJson,
      workoutJson: data.workoutJson.present
          ? data.workoutJson.value
          : this.workoutJson,
      quickAddsJson: data.quickAddsJson.present
          ? data.quickAddsJson.value
          : this.quickAddsJson,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('weekdaysJson: $weekdaysJson, ')
          ..write('wakeMinute: $wakeMinute, ')
          ..write('sleepMinute: $sleepMinute, ')
          ..write('mode: $mode, ')
          ..write('quietJson: $quietJson, ')
          ..write('workoutJson: $workoutJson, ')
          ..write('quickAddsJson: $quickAddsJson, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    kind,
    weekdaysJson,
    wakeMinute,
    sleepMinute,
    mode,
    quietJson,
    workoutJson,
    quickAddsJson,
    enabled,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.weekdaysJson == this.weekdaysJson &&
          other.wakeMinute == this.wakeMinute &&
          other.sleepMinute == this.sleepMinute &&
          other.mode == this.mode &&
          other.quietJson == this.quietJson &&
          other.workoutJson == this.workoutJson &&
          other.quickAddsJson == this.quickAddsJson &&
          other.enabled == this.enabled);
}

class RoutinesCompanion extends UpdateCompanion<RoutineRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> kind;
  final Value<String> weekdaysJson;
  final Value<int> wakeMinute;
  final Value<int> sleepMinute;
  final Value<String> mode;
  final Value<String> quietJson;
  final Value<String> workoutJson;
  final Value<String> quickAddsJson;
  final Value<bool> enabled;
  final Value<int> rowid;
  const RoutinesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.weekdaysJson = const Value.absent(),
    this.wakeMinute = const Value.absent(),
    this.sleepMinute = const Value.absent(),
    this.mode = const Value.absent(),
    this.quietJson = const Value.absent(),
    this.workoutJson = const Value.absent(),
    this.quickAddsJson = const Value.absent(),
    this.enabled = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoutinesCompanion.insert({
    required String id,
    required String name,
    required String kind,
    this.weekdaysJson = const Value.absent(),
    required int wakeMinute,
    required int sleepMinute,
    this.mode = const Value.absent(),
    this.quietJson = const Value.absent(),
    this.workoutJson = const Value.absent(),
    this.quickAddsJson = const Value.absent(),
    this.enabled = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       kind = Value(kind),
       wakeMinute = Value(wakeMinute),
       sleepMinute = Value(sleepMinute);
  static Insertable<RoutineRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<String>? weekdaysJson,
    Expression<int>? wakeMinute,
    Expression<int>? sleepMinute,
    Expression<String>? mode,
    Expression<String>? quietJson,
    Expression<String>? workoutJson,
    Expression<String>? quickAddsJson,
    Expression<bool>? enabled,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (weekdaysJson != null) 'weekdays_json': weekdaysJson,
      if (wakeMinute != null) 'wake_minute': wakeMinute,
      if (sleepMinute != null) 'sleep_minute': sleepMinute,
      if (mode != null) 'mode': mode,
      if (quietJson != null) 'quiet_json': quietJson,
      if (workoutJson != null) 'workout_json': workoutJson,
      if (quickAddsJson != null) 'quick_adds_json': quickAddsJson,
      if (enabled != null) 'enabled': enabled,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoutinesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? kind,
    Value<String>? weekdaysJson,
    Value<int>? wakeMinute,
    Value<int>? sleepMinute,
    Value<String>? mode,
    Value<String>? quietJson,
    Value<String>? workoutJson,
    Value<String>? quickAddsJson,
    Value<bool>? enabled,
    Value<int>? rowid,
  }) {
    return RoutinesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      weekdaysJson: weekdaysJson ?? this.weekdaysJson,
      wakeMinute: wakeMinute ?? this.wakeMinute,
      sleepMinute: sleepMinute ?? this.sleepMinute,
      mode: mode ?? this.mode,
      quietJson: quietJson ?? this.quietJson,
      workoutJson: workoutJson ?? this.workoutJson,
      quickAddsJson: quickAddsJson ?? this.quickAddsJson,
      enabled: enabled ?? this.enabled,
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
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (weekdaysJson.present) {
      map['weekdays_json'] = Variable<String>(weekdaysJson.value);
    }
    if (wakeMinute.present) {
      map['wake_minute'] = Variable<int>(wakeMinute.value);
    }
    if (sleepMinute.present) {
      map['sleep_minute'] = Variable<int>(sleepMinute.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (quietJson.present) {
      map['quiet_json'] = Variable<String>(quietJson.value);
    }
    if (workoutJson.present) {
      map['workout_json'] = Variable<String>(workoutJson.value);
    }
    if (quickAddsJson.present) {
      map['quick_adds_json'] = Variable<String>(quickAddsJson.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutinesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('weekdaysJson: $weekdaysJson, ')
          ..write('wakeMinute: $wakeMinute, ')
          ..write('sleepMinute: $sleepMinute, ')
          ..write('mode: $mode, ')
          ..write('quietJson: $quietJson, ')
          ..write('workoutJson: $workoutJson, ')
          ..write('quickAddsJson: $quickAddsJson, ')
          ..write('enabled: $enabled, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReminderEventsTable extends ReminderEvents
    with TableInfo<$ReminderEventsTable, ReminderEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReminderEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledAtMeta = const VerificationMeta(
    'scheduledAt',
  );
  @override
  late final GeneratedColumn<int> scheduledAt = GeneratedColumn<int>(
    'scheduled_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localDateMeta = const VerificationMeta(
    'localDate',
  );
  @override
  late final GeneratedColumn<String> localDate = GeneratedColumn<String>(
    'local_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _outcomeMeta = const VerificationMeta(
    'outcome',
  );
  @override
  late final GeneratedColumn<String> outcome = GeneratedColumn<String>(
    'outcome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _algorithmVersionMeta = const VerificationMeta(
    'algorithmVersion',
  );
  @override
  late final GeneratedColumn<String> algorithmVersion = GeneratedColumn<String>(
    'algorithm_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resolvedAtMeta = const VerificationMeta(
    'resolvedAt',
  );
  @override
  late final GeneratedColumn<int> resolvedAt = GeneratedColumn<int>(
    'resolved_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    scheduledAt,
    localDate,
    type,
    outcome,
    reason,
    algorithmVersion,
    resolvedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminder_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReminderEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
        _scheduledAtMeta,
        scheduledAt.isAcceptableOrUnknown(
          data['scheduled_at']!,
          _scheduledAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledAtMeta);
    }
    if (data.containsKey('local_date')) {
      context.handle(
        _localDateMeta,
        localDate.isAcceptableOrUnknown(data['local_date']!, _localDateMeta),
      );
    } else if (isInserting) {
      context.missing(_localDateMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('outcome')) {
      context.handle(
        _outcomeMeta,
        outcome.isAcceptableOrUnknown(data['outcome']!, _outcomeMeta),
      );
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('algorithm_version')) {
      context.handle(
        _algorithmVersionMeta,
        algorithmVersion.isAcceptableOrUnknown(
          data['algorithm_version']!,
          _algorithmVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_algorithmVersionMeta);
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
        _resolvedAtMeta,
        resolvedAt.isAcceptableOrUnknown(data['resolved_at']!, _resolvedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReminderEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderEventRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      scheduledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scheduled_at'],
      )!,
      localDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_date'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      outcome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outcome'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      algorithmVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}algorithm_version'],
      )!,
      resolvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}resolved_at'],
      ),
    );
  }

  @override
  $ReminderEventsTable createAlias(String alias) {
    return $ReminderEventsTable(attachedDatabase, alias);
  }
}

class ReminderEventRow extends DataClass
    implements Insertable<ReminderEventRow> {
  final String id;
  final int scheduledAt;
  final String localDate;
  final String type;
  final String outcome;
  final String reason;
  final String algorithmVersion;
  final int? resolvedAt;
  const ReminderEventRow({
    required this.id,
    required this.scheduledAt,
    required this.localDate,
    required this.type,
    required this.outcome,
    required this.reason,
    required this.algorithmVersion,
    this.resolvedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['scheduled_at'] = Variable<int>(scheduledAt);
    map['local_date'] = Variable<String>(localDate);
    map['type'] = Variable<String>(type);
    map['outcome'] = Variable<String>(outcome);
    map['reason'] = Variable<String>(reason);
    map['algorithm_version'] = Variable<String>(algorithmVersion);
    if (!nullToAbsent || resolvedAt != null) {
      map['resolved_at'] = Variable<int>(resolvedAt);
    }
    return map;
  }

  ReminderEventsCompanion toCompanion(bool nullToAbsent) {
    return ReminderEventsCompanion(
      id: Value(id),
      scheduledAt: Value(scheduledAt),
      localDate: Value(localDate),
      type: Value(type),
      outcome: Value(outcome),
      reason: Value(reason),
      algorithmVersion: Value(algorithmVersion),
      resolvedAt: resolvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedAt),
    );
  }

  factory ReminderEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderEventRow(
      id: serializer.fromJson<String>(json['id']),
      scheduledAt: serializer.fromJson<int>(json['scheduledAt']),
      localDate: serializer.fromJson<String>(json['localDate']),
      type: serializer.fromJson<String>(json['type']),
      outcome: serializer.fromJson<String>(json['outcome']),
      reason: serializer.fromJson<String>(json['reason']),
      algorithmVersion: serializer.fromJson<String>(json['algorithmVersion']),
      resolvedAt: serializer.fromJson<int?>(json['resolvedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'scheduledAt': serializer.toJson<int>(scheduledAt),
      'localDate': serializer.toJson<String>(localDate),
      'type': serializer.toJson<String>(type),
      'outcome': serializer.toJson<String>(outcome),
      'reason': serializer.toJson<String>(reason),
      'algorithmVersion': serializer.toJson<String>(algorithmVersion),
      'resolvedAt': serializer.toJson<int?>(resolvedAt),
    };
  }

  ReminderEventRow copyWith({
    String? id,
    int? scheduledAt,
    String? localDate,
    String? type,
    String? outcome,
    String? reason,
    String? algorithmVersion,
    Value<int?> resolvedAt = const Value.absent(),
  }) => ReminderEventRow(
    id: id ?? this.id,
    scheduledAt: scheduledAt ?? this.scheduledAt,
    localDate: localDate ?? this.localDate,
    type: type ?? this.type,
    outcome: outcome ?? this.outcome,
    reason: reason ?? this.reason,
    algorithmVersion: algorithmVersion ?? this.algorithmVersion,
    resolvedAt: resolvedAt.present ? resolvedAt.value : this.resolvedAt,
  );
  ReminderEventRow copyWithCompanion(ReminderEventsCompanion data) {
    return ReminderEventRow(
      id: data.id.present ? data.id.value : this.id,
      scheduledAt: data.scheduledAt.present
          ? data.scheduledAt.value
          : this.scheduledAt,
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
      type: data.type.present ? data.type.value : this.type,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      reason: data.reason.present ? data.reason.value : this.reason,
      algorithmVersion: data.algorithmVersion.present
          ? data.algorithmVersion.value
          : this.algorithmVersion,
      resolvedAt: data.resolvedAt.present
          ? data.resolvedAt.value
          : this.resolvedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderEventRow(')
          ..write('id: $id, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('localDate: $localDate, ')
          ..write('type: $type, ')
          ..write('outcome: $outcome, ')
          ..write('reason: $reason, ')
          ..write('algorithmVersion: $algorithmVersion, ')
          ..write('resolvedAt: $resolvedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    scheduledAt,
    localDate,
    type,
    outcome,
    reason,
    algorithmVersion,
    resolvedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderEventRow &&
          other.id == this.id &&
          other.scheduledAt == this.scheduledAt &&
          other.localDate == this.localDate &&
          other.type == this.type &&
          other.outcome == this.outcome &&
          other.reason == this.reason &&
          other.algorithmVersion == this.algorithmVersion &&
          other.resolvedAt == this.resolvedAt);
}

class ReminderEventsCompanion extends UpdateCompanion<ReminderEventRow> {
  final Value<String> id;
  final Value<int> scheduledAt;
  final Value<String> localDate;
  final Value<String> type;
  final Value<String> outcome;
  final Value<String> reason;
  final Value<String> algorithmVersion;
  final Value<int?> resolvedAt;
  final Value<int> rowid;
  const ReminderEventsCompanion({
    this.id = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.localDate = const Value.absent(),
    this.type = const Value.absent(),
    this.outcome = const Value.absent(),
    this.reason = const Value.absent(),
    this.algorithmVersion = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReminderEventsCompanion.insert({
    required String id,
    required int scheduledAt,
    required String localDate,
    required String type,
    this.outcome = const Value.absent(),
    this.reason = const Value.absent(),
    required String algorithmVersion,
    this.resolvedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       scheduledAt = Value(scheduledAt),
       localDate = Value(localDate),
       type = Value(type),
       algorithmVersion = Value(algorithmVersion);
  static Insertable<ReminderEventRow> custom({
    Expression<String>? id,
    Expression<int>? scheduledAt,
    Expression<String>? localDate,
    Expression<String>? type,
    Expression<String>? outcome,
    Expression<String>? reason,
    Expression<String>? algorithmVersion,
    Expression<int>? resolvedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (localDate != null) 'local_date': localDate,
      if (type != null) 'type': type,
      if (outcome != null) 'outcome': outcome,
      if (reason != null) 'reason': reason,
      if (algorithmVersion != null) 'algorithm_version': algorithmVersion,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReminderEventsCompanion copyWith({
    Value<String>? id,
    Value<int>? scheduledAt,
    Value<String>? localDate,
    Value<String>? type,
    Value<String>? outcome,
    Value<String>? reason,
    Value<String>? algorithmVersion,
    Value<int?>? resolvedAt,
    Value<int>? rowid,
  }) {
    return ReminderEventsCompanion(
      id: id ?? this.id,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      localDate: localDate ?? this.localDate,
      type: type ?? this.type,
      outcome: outcome ?? this.outcome,
      reason: reason ?? this.reason,
      algorithmVersion: algorithmVersion ?? this.algorithmVersion,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<int>(scheduledAt.value);
    }
    if (localDate.present) {
      map['local_date'] = Variable<String>(localDate.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(outcome.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (algorithmVersion.present) {
      map['algorithm_version'] = Variable<String>(algorithmVersion.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<int>(resolvedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReminderEventsCompanion(')
          ..write('id: $id, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('localDate: $localDate, ')
          ..write('type: $type, ')
          ..write('outcome: $outcome, ')
          ..write('reason: $reason, ')
          ..write('algorithmVersion: $algorithmVersion, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailySummariesTable extends DailySummaries
    with TableInfo<$DailySummariesTable, DailySummaryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailySummariesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statsJsonMeta = const VerificationMeta(
    'statsJson',
  );
  @override
  late final GeneratedColumn<String> statsJson = GeneratedColumn<String>(
    'stats_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [date, statsJson, version, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_summaries';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailySummaryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('stats_json')) {
      context.handle(
        _statsJsonMeta,
        statsJson.isAcceptableOrUnknown(data['stats_json']!, _statsJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_statsJsonMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date};
  @override
  DailySummaryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailySummaryRow(
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      statsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stats_json'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DailySummariesTable createAlias(String alias) {
    return $DailySummariesTable(attachedDatabase, alias);
  }
}

class DailySummaryRow extends DataClass implements Insertable<DailySummaryRow> {
  final String date;
  final String statsJson;
  final int version;
  final int updatedAt;
  const DailySummaryRow({
    required this.date,
    required this.statsJson,
    required this.version,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<String>(date);
    map['stats_json'] = Variable<String>(statsJson);
    map['version'] = Variable<int>(version);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  DailySummariesCompanion toCompanion(bool nullToAbsent) {
    return DailySummariesCompanion(
      date: Value(date),
      statsJson: Value(statsJson),
      version: Value(version),
      updatedAt: Value(updatedAt),
    );
  }

  factory DailySummaryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailySummaryRow(
      date: serializer.fromJson<String>(json['date']),
      statsJson: serializer.fromJson<String>(json['statsJson']),
      version: serializer.fromJson<int>(json['version']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<String>(date),
      'statsJson': serializer.toJson<String>(statsJson),
      'version': serializer.toJson<int>(version),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  DailySummaryRow copyWith({
    String? date,
    String? statsJson,
    int? version,
    int? updatedAt,
  }) => DailySummaryRow(
    date: date ?? this.date,
    statsJson: statsJson ?? this.statsJson,
    version: version ?? this.version,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DailySummaryRow copyWithCompanion(DailySummariesCompanion data) {
    return DailySummaryRow(
      date: data.date.present ? data.date.value : this.date,
      statsJson: data.statsJson.present ? data.statsJson.value : this.statsJson,
      version: data.version.present ? data.version.value : this.version,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailySummaryRow(')
          ..write('date: $date, ')
          ..write('statsJson: $statsJson, ')
          ..write('version: $version, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(date, statsJson, version, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailySummaryRow &&
          other.date == this.date &&
          other.statsJson == this.statsJson &&
          other.version == this.version &&
          other.updatedAt == this.updatedAt);
}

class DailySummariesCompanion extends UpdateCompanion<DailySummaryRow> {
  final Value<String> date;
  final Value<String> statsJson;
  final Value<int> version;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const DailySummariesCompanion({
    this.date = const Value.absent(),
    this.statsJson = const Value.absent(),
    this.version = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailySummariesCompanion.insert({
    required String date,
    required String statsJson,
    required int version,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : date = Value(date),
       statsJson = Value(statsJson),
       version = Value(version),
       updatedAt = Value(updatedAt);
  static Insertable<DailySummaryRow> custom({
    Expression<String>? date,
    Expression<String>? statsJson,
    Expression<int>? version,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (statsJson != null) 'stats_json': statsJson,
      if (version != null) 'version': version,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailySummariesCompanion copyWith({
    Value<String>? date,
    Value<String>? statsJson,
    Value<int>? version,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return DailySummariesCompanion(
      date: date ?? this.date,
      statsJson: statsJson ?? this.statsJson,
      version: version ?? this.version,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (statsJson.present) {
      map['stats_json'] = Variable<String>(statsJson.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailySummariesCompanion(')
          ..write('date: $date, ')
          ..write('statsJson: $statsJson, ')
          ..write('version: $version, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AchievementsTable extends Achievements
    with TableInfo<$AchievementsTable, AchievementRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AchievementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unlockedAtMeta = const VerificationMeta(
    'unlockedAt',
  );
  @override
  late final GeneratedColumn<int> unlockedAt = GeneratedColumn<int>(
    'unlocked_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metadataJsonMeta = const VerificationMeta(
    'metadataJson',
  );
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
    'metadata_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, type, unlockedAt, metadataJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'achievements';
  @override
  VerificationContext validateIntegrity(
    Insertable<AchievementRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
        _unlockedAtMeta,
        unlockedAt.isAcceptableOrUnknown(data['unlocked_at']!, _unlockedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_unlockedAtMeta);
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
        _metadataJsonMeta,
        metadataJson.isAcceptableOrUnknown(
          data['metadata_json']!,
          _metadataJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AchievementRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AchievementRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      unlockedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unlocked_at'],
      )!,
      metadataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata_json'],
      )!,
    );
  }

  @override
  $AchievementsTable createAlias(String alias) {
    return $AchievementsTable(attachedDatabase, alias);
  }
}

class AchievementRow extends DataClass implements Insertable<AchievementRow> {
  final String id;
  final String type;
  final int unlockedAt;
  final String metadataJson;
  const AchievementRow({
    required this.id,
    required this.type,
    required this.unlockedAt,
    required this.metadataJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['unlocked_at'] = Variable<int>(unlockedAt);
    map['metadata_json'] = Variable<String>(metadataJson);
    return map;
  }

  AchievementsCompanion toCompanion(bool nullToAbsent) {
    return AchievementsCompanion(
      id: Value(id),
      type: Value(type),
      unlockedAt: Value(unlockedAt),
      metadataJson: Value(metadataJson),
    );
  }

  factory AchievementRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AchievementRow(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      unlockedAt: serializer.fromJson<int>(json['unlockedAt']),
      metadataJson: serializer.fromJson<String>(json['metadataJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'unlockedAt': serializer.toJson<int>(unlockedAt),
      'metadataJson': serializer.toJson<String>(metadataJson),
    };
  }

  AchievementRow copyWith({
    String? id,
    String? type,
    int? unlockedAt,
    String? metadataJson,
  }) => AchievementRow(
    id: id ?? this.id,
    type: type ?? this.type,
    unlockedAt: unlockedAt ?? this.unlockedAt,
    metadataJson: metadataJson ?? this.metadataJson,
  );
  AchievementRow copyWithCompanion(AchievementsCompanion data) {
    return AchievementRow(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      unlockedAt: data.unlockedAt.present
          ? data.unlockedAt.value
          : this.unlockedAt,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AchievementRow(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('metadataJson: $metadataJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, unlockedAt, metadataJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AchievementRow &&
          other.id == this.id &&
          other.type == this.type &&
          other.unlockedAt == this.unlockedAt &&
          other.metadataJson == this.metadataJson);
}

class AchievementsCompanion extends UpdateCompanion<AchievementRow> {
  final Value<String> id;
  final Value<String> type;
  final Value<int> unlockedAt;
  final Value<String> metadataJson;
  final Value<int> rowid;
  const AchievementsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AchievementsCompanion.insert({
    required String id,
    required String type,
    required int unlockedAt,
    this.metadataJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       unlockedAt = Value(unlockedAt);
  static Insertable<AchievementRow> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<int>? unlockedAt,
    Expression<String>? metadataJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AchievementsCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<int>? unlockedAt,
    Value<String>? metadataJson,
    Value<int>? rowid,
  }) {
    return AchievementsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      metadataJson: metadataJson ?? this.metadataJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<int>(unlockedAt.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AchievementsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KvSettingsTable extends KvSettings
    with TableInfo<$KvSettingsTable, KvSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KvSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'kv_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<KvSetting> instance, {
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
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  KvSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KvSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $KvSettingsTable createAlias(String alias) {
    return $KvSettingsTable(attachedDatabase, alias);
  }
}

class KvSetting extends DataClass implements Insertable<KvSetting> {
  final String key;
  final String value;
  const KvSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  KvSettingsCompanion toCompanion(bool nullToAbsent) {
    return KvSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory KvSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KvSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  KvSetting copyWith({String? key, String? value}) =>
      KvSetting(key: key ?? this.key, value: value ?? this.value);
  KvSetting copyWithCompanion(KvSettingsCompanion data) {
    return KvSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KvSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KvSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class KvSettingsCompanion extends UpdateCompanion<KvSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const KvSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KvSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<KvSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KvSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return KvSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KvSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ImportTombstonesTable extends ImportTombstones
    with TableInfo<$ImportTombstonesTable, ImportTombstone> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportTombstonesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _externalIdMeta = const VerificationMeta(
    'externalId',
  );
  @override
  late final GeneratedColumn<String> externalId = GeneratedColumn<String>(
    'external_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [source, externalId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'import_tombstones';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImportTombstone> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('external_id')) {
      context.handle(
        _externalIdMeta,
        externalId.isAcceptableOrUnknown(data['external_id']!, _externalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_externalIdMeta);
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
  Set<GeneratedColumn> get $primaryKey => {source, externalId};
  @override
  ImportTombstone map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportTombstone(
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      externalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ImportTombstonesTable createAlias(String alias) {
    return $ImportTombstonesTable(attachedDatabase, alias);
  }
}

class ImportTombstone extends DataClass implements Insertable<ImportTombstone> {
  final String source;
  final String externalId;
  final int createdAt;
  const ImportTombstone({
    required this.source,
    required this.externalId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source'] = Variable<String>(source);
    map['external_id'] = Variable<String>(externalId);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  ImportTombstonesCompanion toCompanion(bool nullToAbsent) {
    return ImportTombstonesCompanion(
      source: Value(source),
      externalId: Value(externalId),
      createdAt: Value(createdAt),
    );
  }

  factory ImportTombstone.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportTombstone(
      source: serializer.fromJson<String>(json['source']),
      externalId: serializer.fromJson<String>(json['externalId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'source': serializer.toJson<String>(source),
      'externalId': serializer.toJson<String>(externalId),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  ImportTombstone copyWith({
    String? source,
    String? externalId,
    int? createdAt,
  }) => ImportTombstone(
    source: source ?? this.source,
    externalId: externalId ?? this.externalId,
    createdAt: createdAt ?? this.createdAt,
  );
  ImportTombstone copyWithCompanion(ImportTombstonesCompanion data) {
    return ImportTombstone(
      source: data.source.present ? data.source.value : this.source,
      externalId: data.externalId.present
          ? data.externalId.value
          : this.externalId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportTombstone(')
          ..write('source: $source, ')
          ..write('externalId: $externalId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(source, externalId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportTombstone &&
          other.source == this.source &&
          other.externalId == this.externalId &&
          other.createdAt == this.createdAt);
}

class ImportTombstonesCompanion extends UpdateCompanion<ImportTombstone> {
  final Value<String> source;
  final Value<String> externalId;
  final Value<int> createdAt;
  final Value<int> rowid;
  const ImportTombstonesCompanion({
    this.source = const Value.absent(),
    this.externalId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImportTombstonesCompanion.insert({
    required String source,
    required String externalId,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : source = Value(source),
       externalId = Value(externalId),
       createdAt = Value(createdAt);
  static Insertable<ImportTombstone> custom({
    Expression<String>? source,
    Expression<String>? externalId,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (source != null) 'source': source,
      if (externalId != null) 'external_id': externalId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImportTombstonesCompanion copyWith({
    Value<String>? source,
    Value<String>? externalId,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return ImportTombstonesCompanion(
      source: source ?? this.source,
      externalId: externalId ?? this.externalId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (externalId.present) {
      map['external_id'] = Variable<String>(externalId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportTombstonesCompanion(')
          ..write('source: $source, ')
          ..write('externalId: $externalId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UserProfileRowsTable userProfileRows = $UserProfileRowsTable(
    this,
  );
  late final $HydrationEntriesTable hydrationEntries = $HydrationEntriesTable(
    this,
  );
  late final $VesselsTable vessels = $VesselsTable(this);
  late final $RoutinesTable routines = $RoutinesTable(this);
  late final $ReminderEventsTable reminderEvents = $ReminderEventsTable(this);
  late final $DailySummariesTable dailySummaries = $DailySummariesTable(this);
  late final $AchievementsTable achievements = $AchievementsTable(this);
  late final $KvSettingsTable kvSettings = $KvSettingsTable(this);
  late final $ImportTombstonesTable importTombstones = $ImportTombstonesTable(
    this,
  );
  late final Index idxEntriesLocalDate = Index(
    'idx_entries_local_date',
    'CREATE INDEX idx_entries_local_date ON hydration_entries (local_date)',
  );
  late final Index idxEntriesTimestamp = Index(
    'idx_entries_timestamp',
    'CREATE INDEX idx_entries_timestamp ON hydration_entries (timestamp_utc)',
  );
  late final Index idxRemindersScheduled = Index(
    'idx_reminders_scheduled',
    'CREATE INDEX idx_reminders_scheduled ON reminder_events (scheduled_at)',
  );
  late final Index idxRemindersLocalDate = Index(
    'idx_reminders_local_date',
    'CREATE INDEX idx_reminders_local_date ON reminder_events (local_date)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userProfileRows,
    hydrationEntries,
    vessels,
    routines,
    reminderEvents,
    dailySummaries,
    achievements,
    kvSettings,
    importTombstones,
    idxEntriesLocalDate,
    idxEntriesTimestamp,
    idxRemindersScheduled,
    idxRemindersLocalDate,
  ];
}

typedef $$UserProfileRowsTableCreateCompanionBuilder =
    UserProfileRowsCompanion Function({
      Value<int> id,
      required int createdAt,
      Value<String?> locale,
      required String timezone,
      Value<String> unit,
      required int dailyTargetMl,
      Value<bool> targetIsUserChosen,
      required int wakeMinute,
      required int sleepMinute,
      Value<String> mode,
      Value<String> tone,
      Value<bool> weekendDifferent,
      Value<int> weekendWakeMinute,
      Value<int> weekendSleepMinute,
      Value<String> quickAddsJson,
      Value<bool> onboardingComplete,
      Value<bool> remindersEnabled,
      Value<String> theme,
      Value<String?> activeRoutineId,
      Value<bool> environmentHot,
    });
typedef $$UserProfileRowsTableUpdateCompanionBuilder =
    UserProfileRowsCompanion Function({
      Value<int> id,
      Value<int> createdAt,
      Value<String?> locale,
      Value<String> timezone,
      Value<String> unit,
      Value<int> dailyTargetMl,
      Value<bool> targetIsUserChosen,
      Value<int> wakeMinute,
      Value<int> sleepMinute,
      Value<String> mode,
      Value<String> tone,
      Value<bool> weekendDifferent,
      Value<int> weekendWakeMinute,
      Value<int> weekendSleepMinute,
      Value<String> quickAddsJson,
      Value<bool> onboardingComplete,
      Value<bool> remindersEnabled,
      Value<String> theme,
      Value<String?> activeRoutineId,
      Value<bool> environmentHot,
    });

class $$UserProfileRowsTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfileRowsTable> {
  $$UserProfileRowsTableFilterComposer({
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

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailyTargetMl => $composableBuilder(
    column: $table.dailyTargetMl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get targetIsUserChosen => $composableBuilder(
    column: $table.targetIsUserChosen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wakeMinute => $composableBuilder(
    column: $table.wakeMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sleepMinute => $composableBuilder(
    column: $table.sleepMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tone => $composableBuilder(
    column: $table.tone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get weekendDifferent => $composableBuilder(
    column: $table.weekendDifferent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekendWakeMinute => $composableBuilder(
    column: $table.weekendWakeMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekendSleepMinute => $composableBuilder(
    column: $table.weekendSleepMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quickAddsJson => $composableBuilder(
    column: $table.quickAddsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get onboardingComplete => $composableBuilder(
    column: $table.onboardingComplete,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get remindersEnabled => $composableBuilder(
    column: $table.remindersEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get theme => $composableBuilder(
    column: $table.theme,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activeRoutineId => $composableBuilder(
    column: $table.activeRoutineId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get environmentHot => $composableBuilder(
    column: $table.environmentHot,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProfileRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfileRowsTable> {
  $$UserProfileRowsTableOrderingComposer({
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

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyTargetMl => $composableBuilder(
    column: $table.dailyTargetMl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get targetIsUserChosen => $composableBuilder(
    column: $table.targetIsUserChosen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wakeMinute => $composableBuilder(
    column: $table.wakeMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sleepMinute => $composableBuilder(
    column: $table.sleepMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tone => $composableBuilder(
    column: $table.tone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get weekendDifferent => $composableBuilder(
    column: $table.weekendDifferent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekendWakeMinute => $composableBuilder(
    column: $table.weekendWakeMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekendSleepMinute => $composableBuilder(
    column: $table.weekendSleepMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quickAddsJson => $composableBuilder(
    column: $table.quickAddsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get onboardingComplete => $composableBuilder(
    column: $table.onboardingComplete,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get remindersEnabled => $composableBuilder(
    column: $table.remindersEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get theme => $composableBuilder(
    column: $table.theme,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activeRoutineId => $composableBuilder(
    column: $table.activeRoutineId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get environmentHot => $composableBuilder(
    column: $table.environmentHot,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfileRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfileRowsTable> {
  $$UserProfileRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => column);

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<int> get dailyTargetMl => $composableBuilder(
    column: $table.dailyTargetMl,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get targetIsUserChosen => $composableBuilder(
    column: $table.targetIsUserChosen,
    builder: (column) => column,
  );

  GeneratedColumn<int> get wakeMinute => $composableBuilder(
    column: $table.wakeMinute,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sleepMinute => $composableBuilder(
    column: $table.sleepMinute,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get tone =>
      $composableBuilder(column: $table.tone, builder: (column) => column);

  GeneratedColumn<bool> get weekendDifferent => $composableBuilder(
    column: $table.weekendDifferent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get weekendWakeMinute => $composableBuilder(
    column: $table.weekendWakeMinute,
    builder: (column) => column,
  );

  GeneratedColumn<int> get weekendSleepMinute => $composableBuilder(
    column: $table.weekendSleepMinute,
    builder: (column) => column,
  );

  GeneratedColumn<String> get quickAddsJson => $composableBuilder(
    column: $table.quickAddsJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get onboardingComplete => $composableBuilder(
    column: $table.onboardingComplete,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get remindersEnabled => $composableBuilder(
    column: $table.remindersEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get theme =>
      $composableBuilder(column: $table.theme, builder: (column) => column);

  GeneratedColumn<String> get activeRoutineId => $composableBuilder(
    column: $table.activeRoutineId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get environmentHot => $composableBuilder(
    column: $table.environmentHot,
    builder: (column) => column,
  );
}

class $$UserProfileRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfileRowsTable,
          UserProfileRow,
          $$UserProfileRowsTableFilterComposer,
          $$UserProfileRowsTableOrderingComposer,
          $$UserProfileRowsTableAnnotationComposer,
          $$UserProfileRowsTableCreateCompanionBuilder,
          $$UserProfileRowsTableUpdateCompanionBuilder,
          (
            UserProfileRow,
            BaseReferences<
              _$AppDatabase,
              $UserProfileRowsTable,
              UserProfileRow
            >,
          ),
          UserProfileRow,
          PrefetchHooks Function()
        > {
  $$UserProfileRowsTableTableManager(
    _$AppDatabase db,
    $UserProfileRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfileRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfileRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfileRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String?> locale = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<int> dailyTargetMl = const Value.absent(),
                Value<bool> targetIsUserChosen = const Value.absent(),
                Value<int> wakeMinute = const Value.absent(),
                Value<int> sleepMinute = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String> tone = const Value.absent(),
                Value<bool> weekendDifferent = const Value.absent(),
                Value<int> weekendWakeMinute = const Value.absent(),
                Value<int> weekendSleepMinute = const Value.absent(),
                Value<String> quickAddsJson = const Value.absent(),
                Value<bool> onboardingComplete = const Value.absent(),
                Value<bool> remindersEnabled = const Value.absent(),
                Value<String> theme = const Value.absent(),
                Value<String?> activeRoutineId = const Value.absent(),
                Value<bool> environmentHot = const Value.absent(),
              }) => UserProfileRowsCompanion(
                id: id,
                createdAt: createdAt,
                locale: locale,
                timezone: timezone,
                unit: unit,
                dailyTargetMl: dailyTargetMl,
                targetIsUserChosen: targetIsUserChosen,
                wakeMinute: wakeMinute,
                sleepMinute: sleepMinute,
                mode: mode,
                tone: tone,
                weekendDifferent: weekendDifferent,
                weekendWakeMinute: weekendWakeMinute,
                weekendSleepMinute: weekendSleepMinute,
                quickAddsJson: quickAddsJson,
                onboardingComplete: onboardingComplete,
                remindersEnabled: remindersEnabled,
                theme: theme,
                activeRoutineId: activeRoutineId,
                environmentHot: environmentHot,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int createdAt,
                Value<String?> locale = const Value.absent(),
                required String timezone,
                Value<String> unit = const Value.absent(),
                required int dailyTargetMl,
                Value<bool> targetIsUserChosen = const Value.absent(),
                required int wakeMinute,
                required int sleepMinute,
                Value<String> mode = const Value.absent(),
                Value<String> tone = const Value.absent(),
                Value<bool> weekendDifferent = const Value.absent(),
                Value<int> weekendWakeMinute = const Value.absent(),
                Value<int> weekendSleepMinute = const Value.absent(),
                Value<String> quickAddsJson = const Value.absent(),
                Value<bool> onboardingComplete = const Value.absent(),
                Value<bool> remindersEnabled = const Value.absent(),
                Value<String> theme = const Value.absent(),
                Value<String?> activeRoutineId = const Value.absent(),
                Value<bool> environmentHot = const Value.absent(),
              }) => UserProfileRowsCompanion.insert(
                id: id,
                createdAt: createdAt,
                locale: locale,
                timezone: timezone,
                unit: unit,
                dailyTargetMl: dailyTargetMl,
                targetIsUserChosen: targetIsUserChosen,
                wakeMinute: wakeMinute,
                sleepMinute: sleepMinute,
                mode: mode,
                tone: tone,
                weekendDifferent: weekendDifferent,
                weekendWakeMinute: weekendWakeMinute,
                weekendSleepMinute: weekendSleepMinute,
                quickAddsJson: quickAddsJson,
                onboardingComplete: onboardingComplete,
                remindersEnabled: remindersEnabled,
                theme: theme,
                activeRoutineId: activeRoutineId,
                environmentHot: environmentHot,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UserProfileRowsTable, UserProfileRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $UserProfileRowsTable,
                    UserProfileRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProfileRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfileRowsTable,
      UserProfileRow,
      $$UserProfileRowsTableFilterComposer,
      $$UserProfileRowsTableOrderingComposer,
      $$UserProfileRowsTableAnnotationComposer,
      $$UserProfileRowsTableCreateCompanionBuilder,
      $$UserProfileRowsTableUpdateCompanionBuilder,
      (
        UserProfileRow,
        BaseReferences<_$AppDatabase, $UserProfileRowsTable, UserProfileRow>,
      ),
      UserProfileRow,
      PrefetchHooks Function()
    >;
typedef $$HydrationEntriesTableCreateCompanionBuilder =
    HydrationEntriesCompanion Function({
      required String id,
      required int timestampUtc,
      required String timezone,
      required String localDate,
      required int volumeMl,
      Value<String> beverage,
      Value<String?> vesselId,
      required String source,
      Value<String?> externalRecordId,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$HydrationEntriesTableUpdateCompanionBuilder =
    HydrationEntriesCompanion Function({
      Value<String> id,
      Value<int> timestampUtc,
      Value<String> timezone,
      Value<String> localDate,
      Value<int> volumeMl,
      Value<String> beverage,
      Value<String?> vesselId,
      Value<String> source,
      Value<String?> externalRecordId,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$HydrationEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $HydrationEntriesTable> {
  $$HydrationEntriesTableFilterComposer({
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

  ColumnFilters<int> get timestampUtc => $composableBuilder(
    column: $table.timestampUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get volumeMl => $composableBuilder(
    column: $table.volumeMl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get beverage => $composableBuilder(
    column: $table.beverage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vesselId => $composableBuilder(
    column: $table.vesselId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalRecordId => $composableBuilder(
    column: $table.externalRecordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HydrationEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $HydrationEntriesTable> {
  $$HydrationEntriesTableOrderingComposer({
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

  ColumnOrderings<int> get timestampUtc => $composableBuilder(
    column: $table.timestampUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get volumeMl => $composableBuilder(
    column: $table.volumeMl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get beverage => $composableBuilder(
    column: $table.beverage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vesselId => $composableBuilder(
    column: $table.vesselId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalRecordId => $composableBuilder(
    column: $table.externalRecordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HydrationEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HydrationEntriesTable> {
  $$HydrationEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get timestampUtc => $composableBuilder(
    column: $table.timestampUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);

  GeneratedColumn<int> get volumeMl =>
      $composableBuilder(column: $table.volumeMl, builder: (column) => column);

  GeneratedColumn<String> get beverage =>
      $composableBuilder(column: $table.beverage, builder: (column) => column);

  GeneratedColumn<String> get vesselId =>
      $composableBuilder(column: $table.vesselId, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get externalRecordId => $composableBuilder(
    column: $table.externalRecordId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$HydrationEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HydrationEntriesTable,
          HydrationEntryRow,
          $$HydrationEntriesTableFilterComposer,
          $$HydrationEntriesTableOrderingComposer,
          $$HydrationEntriesTableAnnotationComposer,
          $$HydrationEntriesTableCreateCompanionBuilder,
          $$HydrationEntriesTableUpdateCompanionBuilder,
          (
            HydrationEntryRow,
            BaseReferences<
              _$AppDatabase,
              $HydrationEntriesTable,
              HydrationEntryRow
            >,
          ),
          HydrationEntryRow,
          PrefetchHooks Function()
        > {
  $$HydrationEntriesTableTableManager(
    _$AppDatabase db,
    $HydrationEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HydrationEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HydrationEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HydrationEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> timestampUtc = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<String> localDate = const Value.absent(),
                Value<int> volumeMl = const Value.absent(),
                Value<String> beverage = const Value.absent(),
                Value<String?> vesselId = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> externalRecordId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HydrationEntriesCompanion(
                id: id,
                timestampUtc: timestampUtc,
                timezone: timezone,
                localDate: localDate,
                volumeMl: volumeMl,
                beverage: beverage,
                vesselId: vesselId,
                source: source,
                externalRecordId: externalRecordId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int timestampUtc,
                required String timezone,
                required String localDate,
                required int volumeMl,
                Value<String> beverage = const Value.absent(),
                Value<String?> vesselId = const Value.absent(),
                required String source,
                Value<String?> externalRecordId = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => HydrationEntriesCompanion.insert(
                id: id,
                timestampUtc: timestampUtc,
                timezone: timezone,
                localDate: localDate,
                volumeMl: volumeMl,
                beverage: beverage,
                vesselId: vesselId,
                source: source,
                externalRecordId: externalRecordId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HydrationEntriesTable, HydrationEntryRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $HydrationEntriesTable,
                    HydrationEntryRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HydrationEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HydrationEntriesTable,
      HydrationEntryRow,
      $$HydrationEntriesTableFilterComposer,
      $$HydrationEntriesTableOrderingComposer,
      $$HydrationEntriesTableAnnotationComposer,
      $$HydrationEntriesTableCreateCompanionBuilder,
      $$HydrationEntriesTableUpdateCompanionBuilder,
      (
        HydrationEntryRow,
        BaseReferences<
          _$AppDatabase,
          $HydrationEntriesTable,
          HydrationEntryRow
        >,
      ),
      HydrationEntryRow,
      PrefetchHooks Function()
    >;
typedef $$VesselsTableCreateCompanionBuilder = VesselsCompanion Function({
  required String id,
  required String name,
  required int volumeMl,
  Value<String> icon,
  Value<bool> isFavorite,
  Value<int> sortOrder,
  Value<int> rowid,
});
typedef $$VesselsTableUpdateCompanionBuilder = VesselsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> volumeMl,
  Value<String> icon,
  Value<bool> isFavorite,
  Value<int> sortOrder,
  Value<int> rowid,
});

class $$VesselsTableFilterComposer
    extends Composer<_$AppDatabase, $VesselsTable> {
  $$VesselsTableFilterComposer({
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

  ColumnFilters<int> get volumeMl => $composableBuilder(
    column: $table.volumeMl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VesselsTableOrderingComposer
    extends Composer<_$AppDatabase, $VesselsTable> {
  $$VesselsTableOrderingComposer({
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

  ColumnOrderings<int> get volumeMl => $composableBuilder(
    column: $table.volumeMl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VesselsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VesselsTable> {
  $$VesselsTableAnnotationComposer({
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

  GeneratedColumn<int> get volumeMl =>
      $composableBuilder(column: $table.volumeMl, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$VesselsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VesselsTable,
          VesselRow,
          $$VesselsTableFilterComposer,
          $$VesselsTableOrderingComposer,
          $$VesselsTableAnnotationComposer,
          $$VesselsTableCreateCompanionBuilder,
          $$VesselsTableUpdateCompanionBuilder,
          (VesselRow, BaseReferences<_$AppDatabase, $VesselsTable, VesselRow>),
          VesselRow,
          PrefetchHooks Function()
        > {
  $$VesselsTableTableManager(_$AppDatabase db, $VesselsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VesselsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VesselsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VesselsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> volumeMl = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VesselsCompanion(
                id: id,
                name: name,
                volumeMl: volumeMl,
                icon: icon,
                isFavorite: isFavorite,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int volumeMl,
                Value<String> icon = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VesselsCompanion.insert(
                id: id,
                name: name,
                volumeMl: volumeMl,
                icon: icon,
                isFavorite: isFavorite,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VesselsTable, VesselRow>(table),
                  BaseReferences<_$AppDatabase, $VesselsTable, VesselRow>(
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

typedef $$VesselsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VesselsTable,
      VesselRow,
      $$VesselsTableFilterComposer,
      $$VesselsTableOrderingComposer,
      $$VesselsTableAnnotationComposer,
      $$VesselsTableCreateCompanionBuilder,
      $$VesselsTableUpdateCompanionBuilder,
      (VesselRow, BaseReferences<_$AppDatabase, $VesselsTable, VesselRow>),
      VesselRow,
      PrefetchHooks Function()
    >;
typedef $$RoutinesTableCreateCompanionBuilder = RoutinesCompanion Function({
  required String id,
  required String name,
  required String kind,
  Value<String> weekdaysJson,
  required int wakeMinute,
  required int sleepMinute,
  Value<String> mode,
  Value<String> quietJson,
  Value<String> workoutJson,
  Value<String> quickAddsJson,
  Value<bool> enabled,
  Value<int> rowid,
});
typedef $$RoutinesTableUpdateCompanionBuilder = RoutinesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> kind,
  Value<String> weekdaysJson,
  Value<int> wakeMinute,
  Value<int> sleepMinute,
  Value<String> mode,
  Value<String> quietJson,
  Value<String> workoutJson,
  Value<String> quickAddsJson,
  Value<bool> enabled,
  Value<int> rowid,
});

class $$RoutinesTableFilterComposer
    extends Composer<_$AppDatabase, $RoutinesTable> {
  $$RoutinesTableFilterComposer({
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

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weekdaysJson => $composableBuilder(
    column: $table.weekdaysJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wakeMinute => $composableBuilder(
    column: $table.wakeMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sleepMinute => $composableBuilder(
    column: $table.sleepMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quietJson => $composableBuilder(
    column: $table.quietJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workoutJson => $composableBuilder(
    column: $table.workoutJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quickAddsJson => $composableBuilder(
    column: $table.quickAddsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RoutinesTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutinesTable> {
  $$RoutinesTableOrderingComposer({
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

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weekdaysJson => $composableBuilder(
    column: $table.weekdaysJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wakeMinute => $composableBuilder(
    column: $table.wakeMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sleepMinute => $composableBuilder(
    column: $table.sleepMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quietJson => $composableBuilder(
    column: $table.quietJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workoutJson => $composableBuilder(
    column: $table.workoutJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quickAddsJson => $composableBuilder(
    column: $table.quickAddsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RoutinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutinesTable> {
  $$RoutinesTableAnnotationComposer({
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

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get weekdaysJson => $composableBuilder(
    column: $table.weekdaysJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get wakeMinute => $composableBuilder(
    column: $table.wakeMinute,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sleepMinute => $composableBuilder(
    column: $table.sleepMinute,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get quietJson =>
      $composableBuilder(column: $table.quietJson, builder: (column) => column);

  GeneratedColumn<String> get workoutJson => $composableBuilder(
    column: $table.workoutJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get quickAddsJson => $composableBuilder(
    column: $table.quickAddsJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);
}

class $$RoutinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutinesTable,
          RoutineRow,
          $$RoutinesTableFilterComposer,
          $$RoutinesTableOrderingComposer,
          $$RoutinesTableAnnotationComposer,
          $$RoutinesTableCreateCompanionBuilder,
          $$RoutinesTableUpdateCompanionBuilder,
          (
            RoutineRow,
            BaseReferences<_$AppDatabase, $RoutinesTable, RoutineRow>,
          ),
          RoutineRow,
          PrefetchHooks Function()
        > {
  $$RoutinesTableTableManager(_$AppDatabase db, $RoutinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> weekdaysJson = const Value.absent(),
                Value<int> wakeMinute = const Value.absent(),
                Value<int> sleepMinute = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String> quietJson = const Value.absent(),
                Value<String> workoutJson = const Value.absent(),
                Value<String> quickAddsJson = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutinesCompanion(
                id: id,
                name: name,
                kind: kind,
                weekdaysJson: weekdaysJson,
                wakeMinute: wakeMinute,
                sleepMinute: sleepMinute,
                mode: mode,
                quietJson: quietJson,
                workoutJson: workoutJson,
                quickAddsJson: quickAddsJson,
                enabled: enabled,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String kind,
                Value<String> weekdaysJson = const Value.absent(),
                required int wakeMinute,
                required int sleepMinute,
                Value<String> mode = const Value.absent(),
                Value<String> quietJson = const Value.absent(),
                Value<String> workoutJson = const Value.absent(),
                Value<String> quickAddsJson = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutinesCompanion.insert(
                id: id,
                name: name,
                kind: kind,
                weekdaysJson: weekdaysJson,
                wakeMinute: wakeMinute,
                sleepMinute: sleepMinute,
                mode: mode,
                quietJson: quietJson,
                workoutJson: workoutJson,
                quickAddsJson: quickAddsJson,
                enabled: enabled,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RoutinesTable, RoutineRow>(table),
                  BaseReferences<_$AppDatabase, $RoutinesTable, RoutineRow>(
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

typedef $$RoutinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutinesTable,
      RoutineRow,
      $$RoutinesTableFilterComposer,
      $$RoutinesTableOrderingComposer,
      $$RoutinesTableAnnotationComposer,
      $$RoutinesTableCreateCompanionBuilder,
      $$RoutinesTableUpdateCompanionBuilder,
      (RoutineRow, BaseReferences<_$AppDatabase, $RoutinesTable, RoutineRow>),
      RoutineRow,
      PrefetchHooks Function()
    >;
typedef $$ReminderEventsTableCreateCompanionBuilder =
    ReminderEventsCompanion Function({
      required String id,
      required int scheduledAt,
      required String localDate,
      required String type,
      Value<String> outcome,
      Value<String> reason,
      required String algorithmVersion,
      Value<int?> resolvedAt,
      Value<int> rowid,
    });
typedef $$ReminderEventsTableUpdateCompanionBuilder =
    ReminderEventsCompanion Function({
      Value<String> id,
      Value<int> scheduledAt,
      Value<String> localDate,
      Value<String> type,
      Value<String> outcome,
      Value<String> reason,
      Value<String> algorithmVersion,
      Value<int?> resolvedAt,
      Value<int> rowid,
    });

class $$ReminderEventsTableFilterComposer
    extends Composer<_$AppDatabase, $ReminderEventsTable> {
  $$ReminderEventsTableFilterComposer({
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

  ColumnFilters<int> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get algorithmVersion => $composableBuilder(
    column: $table.algorithmVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReminderEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReminderEventsTable> {
  $$ReminderEventsTableOrderingComposer({
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

  ColumnOrderings<int> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get algorithmVersion => $composableBuilder(
    column: $table.algorithmVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReminderEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReminderEventsTable> {
  $$ReminderEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get algorithmVersion => $composableBuilder(
    column: $table.algorithmVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => column,
  );
}

class $$ReminderEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReminderEventsTable,
          ReminderEventRow,
          $$ReminderEventsTableFilterComposer,
          $$ReminderEventsTableOrderingComposer,
          $$ReminderEventsTableAnnotationComposer,
          $$ReminderEventsTableCreateCompanionBuilder,
          $$ReminderEventsTableUpdateCompanionBuilder,
          (
            ReminderEventRow,
            BaseReferences<
              _$AppDatabase,
              $ReminderEventsTable,
              ReminderEventRow
            >,
          ),
          ReminderEventRow,
          PrefetchHooks Function()
        > {
  $$ReminderEventsTableTableManager(
    _$AppDatabase db,
    $ReminderEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReminderEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReminderEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReminderEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> scheduledAt = const Value.absent(),
                Value<String> localDate = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> outcome = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<String> algorithmVersion = const Value.absent(),
                Value<int?> resolvedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReminderEventsCompanion(
                id: id,
                scheduledAt: scheduledAt,
                localDate: localDate,
                type: type,
                outcome: outcome,
                reason: reason,
                algorithmVersion: algorithmVersion,
                resolvedAt: resolvedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int scheduledAt,
                required String localDate,
                required String type,
                Value<String> outcome = const Value.absent(),
                Value<String> reason = const Value.absent(),
                required String algorithmVersion,
                Value<int?> resolvedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReminderEventsCompanion.insert(
                id: id,
                scheduledAt: scheduledAt,
                localDate: localDate,
                type: type,
                outcome: outcome,
                reason: reason,
                algorithmVersion: algorithmVersion,
                resolvedAt: resolvedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReminderEventsTable, ReminderEventRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ReminderEventsTable,
                    ReminderEventRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReminderEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReminderEventsTable,
      ReminderEventRow,
      $$ReminderEventsTableFilterComposer,
      $$ReminderEventsTableOrderingComposer,
      $$ReminderEventsTableAnnotationComposer,
      $$ReminderEventsTableCreateCompanionBuilder,
      $$ReminderEventsTableUpdateCompanionBuilder,
      (
        ReminderEventRow,
        BaseReferences<_$AppDatabase, $ReminderEventsTable, ReminderEventRow>,
      ),
      ReminderEventRow,
      PrefetchHooks Function()
    >;
typedef $$DailySummariesTableCreateCompanionBuilder =
    DailySummariesCompanion Function({
      required String date,
      required String statsJson,
      required int version,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$DailySummariesTableUpdateCompanionBuilder =
    DailySummariesCompanion Function({
      Value<String> date,
      Value<String> statsJson,
      Value<int> version,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$DailySummariesTableFilterComposer
    extends Composer<_$AppDatabase, $DailySummariesTable> {
  $$DailySummariesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get statsJson => $composableBuilder(
    column: $table.statsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailySummariesTableOrderingComposer
    extends Composer<_$AppDatabase, $DailySummariesTable> {
  $$DailySummariesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statsJson => $composableBuilder(
    column: $table.statsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailySummariesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailySummariesTable> {
  $$DailySummariesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get statsJson =>
      $composableBuilder(column: $table.statsJson, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DailySummariesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailySummariesTable,
          DailySummaryRow,
          $$DailySummariesTableFilterComposer,
          $$DailySummariesTableOrderingComposer,
          $$DailySummariesTableAnnotationComposer,
          $$DailySummariesTableCreateCompanionBuilder,
          $$DailySummariesTableUpdateCompanionBuilder,
          (
            DailySummaryRow,
            BaseReferences<
              _$AppDatabase,
              $DailySummariesTable,
              DailySummaryRow
            >,
          ),
          DailySummaryRow,
          PrefetchHooks Function()
        > {
  $$DailySummariesTableTableManager(
    _$AppDatabase db,
    $DailySummariesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailySummariesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailySummariesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailySummariesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> date = const Value.absent(),
                Value<String> statsJson = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailySummariesCompanion(
                date: date,
                statsJson: statsJson,
                version: version,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String date,
                required String statsJson,
                required int version,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => DailySummariesCompanion.insert(
                date: date,
                statsJson: statsJson,
                version: version,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DailySummariesTable, DailySummaryRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $DailySummariesTable,
                    DailySummaryRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailySummariesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailySummariesTable,
      DailySummaryRow,
      $$DailySummariesTableFilterComposer,
      $$DailySummariesTableOrderingComposer,
      $$DailySummariesTableAnnotationComposer,
      $$DailySummariesTableCreateCompanionBuilder,
      $$DailySummariesTableUpdateCompanionBuilder,
      (
        DailySummaryRow,
        BaseReferences<_$AppDatabase, $DailySummariesTable, DailySummaryRow>,
      ),
      DailySummaryRow,
      PrefetchHooks Function()
    >;
typedef $$AchievementsTableCreateCompanionBuilder =
    AchievementsCompanion Function({
      required String id,
      required String type,
      required int unlockedAt,
      Value<String> metadataJson,
      Value<int> rowid,
    });
typedef $$AchievementsTableUpdateCompanionBuilder =
    AchievementsCompanion Function({
      Value<String> id,
      Value<String> type,
      Value<int> unlockedAt,
      Value<String> metadataJson,
      Value<int> rowid,
    });

class $$AchievementsTableFilterComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableFilterComposer({
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

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AchievementsTableOrderingComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableOrderingComposer({
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AchievementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => column,
  );
}

class $$AchievementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AchievementsTable,
          AchievementRow,
          $$AchievementsTableFilterComposer,
          $$AchievementsTableOrderingComposer,
          $$AchievementsTableAnnotationComposer,
          $$AchievementsTableCreateCompanionBuilder,
          $$AchievementsTableUpdateCompanionBuilder,
          (
            AchievementRow,
            BaseReferences<_$AppDatabase, $AchievementsTable, AchievementRow>,
          ),
          AchievementRow,
          PrefetchHooks Function()
        > {
  $$AchievementsTableTableManager(_$AppDatabase db, $AchievementsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AchievementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AchievementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AchievementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> unlockedAt = const Value.absent(),
                Value<String> metadataJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AchievementsCompanion(
                id: id,
                type: type,
                unlockedAt: unlockedAt,
                metadataJson: metadataJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                required int unlockedAt,
                Value<String> metadataJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AchievementsCompanion.insert(
                id: id,
                type: type,
                unlockedAt: unlockedAt,
                metadataJson: metadataJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AchievementsTable, AchievementRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AchievementsTable,
                    AchievementRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AchievementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AchievementsTable,
      AchievementRow,
      $$AchievementsTableFilterComposer,
      $$AchievementsTableOrderingComposer,
      $$AchievementsTableAnnotationComposer,
      $$AchievementsTableCreateCompanionBuilder,
      $$AchievementsTableUpdateCompanionBuilder,
      (
        AchievementRow,
        BaseReferences<_$AppDatabase, $AchievementsTable, AchievementRow>,
      ),
      AchievementRow,
      PrefetchHooks Function()
    >;
typedef $$KvSettingsTableCreateCompanionBuilder = KvSettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$KvSettingsTableUpdateCompanionBuilder = KvSettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$KvSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $KvSettingsTable> {
  $$KvSettingsTableFilterComposer({
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

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KvSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $KvSettingsTable> {
  $$KvSettingsTableOrderingComposer({
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

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KvSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $KvSettingsTable> {
  $$KvSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$KvSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $KvSettingsTable,
          KvSetting,
          $$KvSettingsTableFilterComposer,
          $$KvSettingsTableOrderingComposer,
          $$KvSettingsTableAnnotationComposer,
          $$KvSettingsTableCreateCompanionBuilder,
          $$KvSettingsTableUpdateCompanionBuilder,
          (
            KvSetting,
            BaseReferences<_$AppDatabase, $KvSettingsTable, KvSetting>,
          ),
          KvSetting,
          PrefetchHooks Function()
        > {
  $$KvSettingsTableTableManager(_$AppDatabase db, $KvSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KvSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KvSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KvSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => KvSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => KvSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$KvSettingsTable, KvSetting>(table),
                  BaseReferences<_$AppDatabase, $KvSettingsTable, KvSetting>(
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

typedef $$KvSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $KvSettingsTable,
      KvSetting,
      $$KvSettingsTableFilterComposer,
      $$KvSettingsTableOrderingComposer,
      $$KvSettingsTableAnnotationComposer,
      $$KvSettingsTableCreateCompanionBuilder,
      $$KvSettingsTableUpdateCompanionBuilder,
      (KvSetting, BaseReferences<_$AppDatabase, $KvSettingsTable, KvSetting>),
      KvSetting,
      PrefetchHooks Function()
    >;
typedef $$ImportTombstonesTableCreateCompanionBuilder =
    ImportTombstonesCompanion Function({
      required String source,
      required String externalId,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$ImportTombstonesTableUpdateCompanionBuilder =
    ImportTombstonesCompanion Function({
      Value<String> source,
      Value<String> externalId,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$ImportTombstonesTableFilterComposer
    extends Composer<_$AppDatabase, $ImportTombstonesTable> {
  $$ImportTombstonesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ImportTombstonesTableOrderingComposer
    extends Composer<_$AppDatabase, $ImportTombstonesTable> {
  $$ImportTombstonesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ImportTombstonesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImportTombstonesTable> {
  $$ImportTombstonesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ImportTombstonesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ImportTombstonesTable,
          ImportTombstone,
          $$ImportTombstonesTableFilterComposer,
          $$ImportTombstonesTableOrderingComposer,
          $$ImportTombstonesTableAnnotationComposer,
          $$ImportTombstonesTableCreateCompanionBuilder,
          $$ImportTombstonesTableUpdateCompanionBuilder,
          (
            ImportTombstone,
            BaseReferences<
              _$AppDatabase,
              $ImportTombstonesTable,
              ImportTombstone
            >,
          ),
          ImportTombstone,
          PrefetchHooks Function()
        > {
  $$ImportTombstonesTableTableManager(
    _$AppDatabase db,
    $ImportTombstonesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportTombstonesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImportTombstonesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImportTombstonesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> source = const Value.absent(),
                Value<String> externalId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImportTombstonesCompanion(
                source: source,
                externalId: externalId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String source,
                required String externalId,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ImportTombstonesCompanion.insert(
                source: source,
                externalId: externalId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ImportTombstonesTable, ImportTombstone>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ImportTombstonesTable,
                    ImportTombstone
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ImportTombstonesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ImportTombstonesTable,
      ImportTombstone,
      $$ImportTombstonesTableFilterComposer,
      $$ImportTombstonesTableOrderingComposer,
      $$ImportTombstonesTableAnnotationComposer,
      $$ImportTombstonesTableCreateCompanionBuilder,
      $$ImportTombstonesTableUpdateCompanionBuilder,
      (
        ImportTombstone,
        BaseReferences<_$AppDatabase, $ImportTombstonesTable, ImportTombstone>,
      ),
      ImportTombstone,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserProfileRowsTableTableManager get userProfileRows =>
      $$UserProfileRowsTableTableManager(_db, _db.userProfileRows);
  $$HydrationEntriesTableTableManager get hydrationEntries =>
      $$HydrationEntriesTableTableManager(_db, _db.hydrationEntries);
  $$VesselsTableTableManager get vessels =>
      $$VesselsTableTableManager(_db, _db.vessels);
  $$RoutinesTableTableManager get routines =>
      $$RoutinesTableTableManager(_db, _db.routines);
  $$ReminderEventsTableTableManager get reminderEvents =>
      $$ReminderEventsTableTableManager(_db, _db.reminderEvents);
  $$DailySummariesTableTableManager get dailySummaries =>
      $$DailySummariesTableTableManager(_db, _db.dailySummaries);
  $$AchievementsTableTableManager get achievements =>
      $$AchievementsTableTableManager(_db, _db.achievements);
  $$KvSettingsTableTableManager get kvSettings =>
      $$KvSettingsTableTableManager(_db, _db.kvSettings);
  $$ImportTombstonesTableTableManager get importTombstones =>
      $$ImportTombstonesTableTableManager(_db, _db.importTombstones);
}
