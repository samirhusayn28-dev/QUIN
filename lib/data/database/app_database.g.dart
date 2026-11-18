// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CountersTable extends Counters with TableInfo<$CountersTable, Counter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CountersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 120),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _startValueMeta =
      const VerificationMeta('startValue');
  @override
  late final GeneratedColumn<int> startValue = GeneratedColumn<int>(
      'start_value', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _targetValueMeta =
      const VerificationMeta('targetValue');
  @override
  late final GeneratedColumn<int> targetValue = GeneratedColumn<int>(
      'target_value', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _directionMeta =
      const VerificationMeta('direction');
  @override
  late final GeneratedColumn<int> direction = GeneratedColumn<int>(
      'direction', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _stepSizeMeta =
      const VerificationMeta('stepSize');
  @override
  late final GeneratedColumn<int> stepSize = GeneratedColumn<int>(
      'step_size', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _currentValueMeta =
      const VerificationMeta('currentValue');
  @override
  late final GeneratedColumn<int> currentValue = GeneratedColumn<int>(
      'current_value', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _accentColorMeta =
      const VerificationMeta('accentColor');
  @override
  late final GeneratedColumn<int> accentColor = GeneratedColumn<int>(
      'accent_color', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0xFFFFD23F));
  static const VerificationMeta _lineStyleMeta =
      const VerificationMeta('lineStyle');
  @override
  late final GeneratedColumn<String> lineStyle = GeneratedColumn<String>(
      'line_style', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('ink'));
  static const VerificationMeta _numberPosXMeta =
      const VerificationMeta('numberPosX');
  @override
  late final GeneratedColumn<double> numberPosX = GeneratedColumn<double>(
      'number_pos_x', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.5));
  static const VerificationMeta _numberPosYMeta =
      const VerificationMeta('numberPosY');
  @override
  late final GeneratedColumn<double> numberPosY = GeneratedColumn<double>(
      'number_pos_y', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.13));
  static const VerificationMeta _numberScaleMeta =
      const VerificationMeta('numberScale');
  @override
  late final GeneratedColumn<double> numberScale = GeneratedColumn<double>(
      'number_scale', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.0));
  static const VerificationMeta _numberOpacityMeta =
      const VerificationMeta('numberOpacity');
  @override
  late final GeneratedColumn<double> numberOpacity = GeneratedColumn<double>(
      'number_opacity', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.0));
  static const VerificationMeta _numberColorMeta =
      const VerificationMeta('numberColor');
  @override
  late final GeneratedColumn<int> numberColor = GeneratedColumn<int>(
      'number_color', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _autoArchiveMeta =
      const VerificationMeta('autoArchive');
  @override
  late final GeneratedColumn<bool> autoArchive = GeneratedColumn<bool>(
      'auto_archive', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("auto_archive" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _celebrateOnTargetMeta =
      const VerificationMeta('celebrateOnTarget');
  @override
  late final GeneratedColumn<bool> celebrateOnTarget = GeneratedColumn<bool>(
      'celebrate_on_target', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("celebrate_on_target" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _showGroupBreakdownMeta =
      const VerificationMeta('showGroupBreakdown');
  @override
  late final GeneratedColumn<bool> showGroupBreakdown = GeneratedColumn<bool>(
      'show_group_breakdown', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("show_group_breakdown" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _autoCountMeta =
      const VerificationMeta('autoCount');
  @override
  late final GeneratedColumn<bool> autoCount = GeneratedColumn<bool>(
      'auto_count', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("auto_count" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _autoIntervalMsMeta =
      const VerificationMeta('autoIntervalMs');
  @override
  late final GeneratedColumn<int> autoIntervalMs = GeneratedColumn<int>(
      'auto_interval_ms', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1000));
  static const VerificationMeta _orderIndexMeta =
      const VerificationMeta('orderIndex');
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
      'order_index', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _pinnedMeta = const VerificationMeta('pinned');
  @override
  late final GeneratedColumn<bool> pinned = GeneratedColumn<bool>(
      'pinned', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("pinned" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _archivedMeta =
      const VerificationMeta('archived');
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
      'archived', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("archived" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        description,
        startValue,
        targetValue,
        direction,
        stepSize,
        currentValue,
        accentColor,
        lineStyle,
        numberPosX,
        numberPosY,
        numberScale,
        numberOpacity,
        numberColor,
        autoArchive,
        celebrateOnTarget,
        showGroupBreakdown,
        autoCount,
        autoIntervalMs,
        orderIndex,
        pinned,
        archived,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'counters';
  @override
  VerificationContext validateIntegrity(Insertable<Counter> instance,
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
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('start_value')) {
      context.handle(
          _startValueMeta,
          startValue.isAcceptableOrUnknown(
              data['start_value']!, _startValueMeta));
    }
    if (data.containsKey('target_value')) {
      context.handle(
          _targetValueMeta,
          targetValue.isAcceptableOrUnknown(
              data['target_value']!, _targetValueMeta));
    }
    if (data.containsKey('direction')) {
      context.handle(_directionMeta,
          direction.isAcceptableOrUnknown(data['direction']!, _directionMeta));
    }
    if (data.containsKey('step_size')) {
      context.handle(_stepSizeMeta,
          stepSize.isAcceptableOrUnknown(data['step_size']!, _stepSizeMeta));
    }
    if (data.containsKey('current_value')) {
      context.handle(
          _currentValueMeta,
          currentValue.isAcceptableOrUnknown(
              data['current_value']!, _currentValueMeta));
    }
    if (data.containsKey('accent_color')) {
      context.handle(
          _accentColorMeta,
          accentColor.isAcceptableOrUnknown(
              data['accent_color']!, _accentColorMeta));
    }
    if (data.containsKey('line_style')) {
      context.handle(_lineStyleMeta,
          lineStyle.isAcceptableOrUnknown(data['line_style']!, _lineStyleMeta));
    }
    if (data.containsKey('number_pos_x')) {
      context.handle(
          _numberPosXMeta,
          numberPosX.isAcceptableOrUnknown(
              data['number_pos_x']!, _numberPosXMeta));
    }
    if (data.containsKey('number_pos_y')) {
      context.handle(
          _numberPosYMeta,
          numberPosY.isAcceptableOrUnknown(
              data['number_pos_y']!, _numberPosYMeta));
    }
    if (data.containsKey('number_scale')) {
      context.handle(
          _numberScaleMeta,
          numberScale.isAcceptableOrUnknown(
              data['number_scale']!, _numberScaleMeta));
    }
    if (data.containsKey('number_opacity')) {
      context.handle(
          _numberOpacityMeta,
          numberOpacity.isAcceptableOrUnknown(
              data['number_opacity']!, _numberOpacityMeta));
    }
    if (data.containsKey('number_color')) {
      context.handle(
          _numberColorMeta,
          numberColor.isAcceptableOrUnknown(
              data['number_color']!, _numberColorMeta));
    }
    if (data.containsKey('auto_archive')) {
      context.handle(
          _autoArchiveMeta,
          autoArchive.isAcceptableOrUnknown(
              data['auto_archive']!, _autoArchiveMeta));
    }
    if (data.containsKey('celebrate_on_target')) {
      context.handle(
          _celebrateOnTargetMeta,
          celebrateOnTarget.isAcceptableOrUnknown(
              data['celebrate_on_target']!, _celebrateOnTargetMeta));
    }
    if (data.containsKey('show_group_breakdown')) {
      context.handle(
          _showGroupBreakdownMeta,
          showGroupBreakdown.isAcceptableOrUnknown(
              data['show_group_breakdown']!, _showGroupBreakdownMeta));
    }
    if (data.containsKey('auto_count')) {
      context.handle(_autoCountMeta,
          autoCount.isAcceptableOrUnknown(data['auto_count']!, _autoCountMeta));
    }
    if (data.containsKey('auto_interval_ms')) {
      context.handle(
          _autoIntervalMsMeta,
          autoIntervalMs.isAcceptableOrUnknown(
              data['auto_interval_ms']!, _autoIntervalMsMeta));
    }
    if (data.containsKey('order_index')) {
      context.handle(
          _orderIndexMeta,
          orderIndex.isAcceptableOrUnknown(
              data['order_index']!, _orderIndexMeta));
    }
    if (data.containsKey('pinned')) {
      context.handle(_pinnedMeta,
          pinned.isAcceptableOrUnknown(data['pinned']!, _pinnedMeta));
    }
    if (data.containsKey('archived')) {
      context.handle(_archivedMeta,
          archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Counter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Counter(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      startValue: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}start_value'])!,
      targetValue: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}target_value']),
      direction: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}direction'])!,
      stepSize: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}step_size'])!,
      currentValue: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}current_value'])!,
      accentColor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}accent_color'])!,
      lineStyle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}line_style'])!,
      numberPosX: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}number_pos_x'])!,
      numberPosY: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}number_pos_y'])!,
      numberScale: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}number_scale'])!,
      numberOpacity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}number_opacity'])!,
      numberColor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}number_color']),
      autoArchive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}auto_archive'])!,
      celebrateOnTarget: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}celebrate_on_target'])!,
      showGroupBreakdown: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}show_group_breakdown'])!,
      autoCount: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}auto_count'])!,
      autoIntervalMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}auto_interval_ms'])!,
      orderIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_index'])!,
      pinned: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}pinned'])!,
      archived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}archived'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CountersTable createAlias(String alias) {
    return $CountersTable(attachedDatabase, alias);
  }
}

class Counter extends DataClass implements Insertable<Counter> {
  final String id;
  final String name;
  final String? description;
  final int startValue;
  final int? targetValue;
  final int direction;
  final int stepSize;
  final int currentValue;
  final int accentColor;
  final String lineStyle;
  final double numberPosX;
  final double numberPosY;
  final double numberScale;
  final double numberOpacity;
  final int? numberColor;
  final bool autoArchive;
  final bool celebrateOnTarget;
  final bool showGroupBreakdown;
  final bool autoCount;
  final int autoIntervalMs;
  final int orderIndex;
  final bool pinned;
  final bool archived;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Counter(
      {required this.id,
      required this.name,
      this.description,
      required this.startValue,
      this.targetValue,
      required this.direction,
      required this.stepSize,
      required this.currentValue,
      required this.accentColor,
      required this.lineStyle,
      required this.numberPosX,
      required this.numberPosY,
      required this.numberScale,
      required this.numberOpacity,
      this.numberColor,
      required this.autoArchive,
      required this.celebrateOnTarget,
      required this.showGroupBreakdown,
      required this.autoCount,
      required this.autoIntervalMs,
      required this.orderIndex,
      required this.pinned,
      required this.archived,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['start_value'] = Variable<int>(startValue);
    if (!nullToAbsent || targetValue != null) {
      map['target_value'] = Variable<int>(targetValue);
    }
    map['direction'] = Variable<int>(direction);
    map['step_size'] = Variable<int>(stepSize);
    map['current_value'] = Variable<int>(currentValue);
    map['accent_color'] = Variable<int>(accentColor);
    map['line_style'] = Variable<String>(lineStyle);
    map['number_pos_x'] = Variable<double>(numberPosX);
    map['number_pos_y'] = Variable<double>(numberPosY);
    map['number_scale'] = Variable<double>(numberScale);
    map['number_opacity'] = Variable<double>(numberOpacity);
    if (!nullToAbsent || numberColor != null) {
      map['number_color'] = Variable<int>(numberColor);
    }
    map['auto_archive'] = Variable<bool>(autoArchive);
    map['celebrate_on_target'] = Variable<bool>(celebrateOnTarget);
    map['show_group_breakdown'] = Variable<bool>(showGroupBreakdown);
    map['auto_count'] = Variable<bool>(autoCount);
    map['auto_interval_ms'] = Variable<int>(autoIntervalMs);
    map['order_index'] = Variable<int>(orderIndex);
    map['pinned'] = Variable<bool>(pinned);
    map['archived'] = Variable<bool>(archived);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CountersCompanion toCompanion(bool nullToAbsent) {
    return CountersCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      startValue: Value(startValue),
      targetValue: targetValue == null && nullToAbsent
          ? const Value.absent()
          : Value(targetValue),
      direction: Value(direction),
      stepSize: Value(stepSize),
      currentValue: Value(currentValue),
      accentColor: Value(accentColor),
      lineStyle: Value(lineStyle),
      numberPosX: Value(numberPosX),
      numberPosY: Value(numberPosY),
      numberScale: Value(numberScale),
      numberOpacity: Value(numberOpacity),
      numberColor: numberColor == null && nullToAbsent
          ? const Value.absent()
          : Value(numberColor),
      autoArchive: Value(autoArchive),
      celebrateOnTarget: Value(celebrateOnTarget),
      showGroupBreakdown: Value(showGroupBreakdown),
      autoCount: Value(autoCount),
      autoIntervalMs: Value(autoIntervalMs),
      orderIndex: Value(orderIndex),
      pinned: Value(pinned),
      archived: Value(archived),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Counter.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Counter(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      startValue: serializer.fromJson<int>(json['startValue']),
      targetValue: serializer.fromJson<int?>(json['targetValue']),
      direction: serializer.fromJson<int>(json['direction']),
      stepSize: serializer.fromJson<int>(json['stepSize']),
      currentValue: serializer.fromJson<int>(json['currentValue']),
      accentColor: serializer.fromJson<int>(json['accentColor']),
      lineStyle: serializer.fromJson<String>(json['lineStyle']),
      numberPosX: serializer.fromJson<double>(json['numberPosX']),
      numberPosY: serializer.fromJson<double>(json['numberPosY']),
      numberScale: serializer.fromJson<double>(json['numberScale']),
      numberOpacity: serializer.fromJson<double>(json['numberOpacity']),
      numberColor: serializer.fromJson<int?>(json['numberColor']),
      autoArchive: serializer.fromJson<bool>(json['autoArchive']),
      celebrateOnTarget: serializer.fromJson<bool>(json['celebrateOnTarget']),
      showGroupBreakdown: serializer.fromJson<bool>(json['showGroupBreakdown']),
      autoCount: serializer.fromJson<bool>(json['autoCount']),
      autoIntervalMs: serializer.fromJson<int>(json['autoIntervalMs']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      pinned: serializer.fromJson<bool>(json['pinned']),
      archived: serializer.fromJson<bool>(json['archived']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'startValue': serializer.toJson<int>(startValue),
      'targetValue': serializer.toJson<int?>(targetValue),
      'direction': serializer.toJson<int>(direction),
      'stepSize': serializer.toJson<int>(stepSize),
      'currentValue': serializer.toJson<int>(currentValue),
      'accentColor': serializer.toJson<int>(accentColor),
      'lineStyle': serializer.toJson<String>(lineStyle),
      'numberPosX': serializer.toJson<double>(numberPosX),
      'numberPosY': serializer.toJson<double>(numberPosY),
      'numberScale': serializer.toJson<double>(numberScale),
      'numberOpacity': serializer.toJson<double>(numberOpacity),
      'numberColor': serializer.toJson<int?>(numberColor),
      'autoArchive': serializer.toJson<bool>(autoArchive),
      'celebrateOnTarget': serializer.toJson<bool>(celebrateOnTarget),
      'showGroupBreakdown': serializer.toJson<bool>(showGroupBreakdown),
      'autoCount': serializer.toJson<bool>(autoCount),
      'autoIntervalMs': serializer.toJson<int>(autoIntervalMs),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'pinned': serializer.toJson<bool>(pinned),
      'archived': serializer.toJson<bool>(archived),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Counter copyWith(
          {String? id,
          String? name,
          Value<String?> description = const Value.absent(),
          int? startValue,
          Value<int?> targetValue = const Value.absent(),
          int? direction,
          int? stepSize,
          int? currentValue,
          int? accentColor,
          String? lineStyle,
          double? numberPosX,
          double? numberPosY,
          double? numberScale,
          double? numberOpacity,
          Value<int?> numberColor = const Value.absent(),
          bool? autoArchive,
          bool? celebrateOnTarget,
          bool? showGroupBreakdown,
          bool? autoCount,
          int? autoIntervalMs,
          int? orderIndex,
          bool? pinned,
          bool? archived,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Counter(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        startValue: startValue ?? this.startValue,
        targetValue: targetValue.present ? targetValue.value : this.targetValue,
        direction: direction ?? this.direction,
        stepSize: stepSize ?? this.stepSize,
        currentValue: currentValue ?? this.currentValue,
        accentColor: accentColor ?? this.accentColor,
        lineStyle: lineStyle ?? this.lineStyle,
        numberPosX: numberPosX ?? this.numberPosX,
        numberPosY: numberPosY ?? this.numberPosY,
        numberScale: numberScale ?? this.numberScale,
        numberOpacity: numberOpacity ?? this.numberOpacity,
        numberColor: numberColor.present ? numberColor.value : this.numberColor,
        autoArchive: autoArchive ?? this.autoArchive,
        celebrateOnTarget: celebrateOnTarget ?? this.celebrateOnTarget,
        showGroupBreakdown: showGroupBreakdown ?? this.showGroupBreakdown,
        autoCount: autoCount ?? this.autoCount,
        autoIntervalMs: autoIntervalMs ?? this.autoIntervalMs,
        orderIndex: orderIndex ?? this.orderIndex,
        pinned: pinned ?? this.pinned,
        archived: archived ?? this.archived,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Counter copyWithCompanion(CountersCompanion data) {
    return Counter(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      startValue:
          data.startValue.present ? data.startValue.value : this.startValue,
      targetValue:
          data.targetValue.present ? data.targetValue.value : this.targetValue,
      direction: data.direction.present ? data.direction.value : this.direction,
      stepSize: data.stepSize.present ? data.stepSize.value : this.stepSize,
      currentValue: data.currentValue.present
          ? data.currentValue.value
          : this.currentValue,
      accentColor:
          data.accentColor.present ? data.accentColor.value : this.accentColor,
      lineStyle: data.lineStyle.present ? data.lineStyle.value : this.lineStyle,
      numberPosX:
          data.numberPosX.present ? data.numberPosX.value : this.numberPosX,
      numberPosY:
          data.numberPosY.present ? data.numberPosY.value : this.numberPosY,
      numberScale:
          data.numberScale.present ? data.numberScale.value : this.numberScale,
      numberOpacity: data.numberOpacity.present
          ? data.numberOpacity.value
          : this.numberOpacity,
      numberColor:
          data.numberColor.present ? data.numberColor.value : this.numberColor,
      autoArchive:
          data.autoArchive.present ? data.autoArchive.value : this.autoArchive,
      celebrateOnTarget: data.celebrateOnTarget.present
          ? data.celebrateOnTarget.value
          : this.celebrateOnTarget,
      showGroupBreakdown: data.showGroupBreakdown.present
          ? data.showGroupBreakdown.value
          : this.showGroupBreakdown,
      autoCount: data.autoCount.present ? data.autoCount.value : this.autoCount,
      autoIntervalMs: data.autoIntervalMs.present
          ? data.autoIntervalMs.value
          : this.autoIntervalMs,
      orderIndex:
          data.orderIndex.present ? data.orderIndex.value : this.orderIndex,
      pinned: data.pinned.present ? data.pinned.value : this.pinned,
      archived: data.archived.present ? data.archived.value : this.archived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Counter(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('startValue: $startValue, ')
          ..write('targetValue: $targetValue, ')
          ..write('direction: $direction, ')
          ..write('stepSize: $stepSize, ')
          ..write('currentValue: $currentValue, ')
          ..write('accentColor: $accentColor, ')
          ..write('lineStyle: $lineStyle, ')
          ..write('numberPosX: $numberPosX, ')
          ..write('numberPosY: $numberPosY, ')
          ..write('numberScale: $numberScale, ')
          ..write('numberOpacity: $numberOpacity, ')
          ..write('numberColor: $numberColor, ')
          ..write('autoArchive: $autoArchive, ')
          ..write('celebrateOnTarget: $celebrateOnTarget, ')
          ..write('showGroupBreakdown: $showGroupBreakdown, ')
          ..write('autoCount: $autoCount, ')
          ..write('autoIntervalMs: $autoIntervalMs, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('pinned: $pinned, ')
          ..write('archived: $archived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        name,
        description,
        startValue,
        targetValue,
        direction,
        stepSize,
        currentValue,
        accentColor,
        lineStyle,
        numberPosX,
        numberPosY,
        numberScale,
        numberOpacity,
        numberColor,
        autoArchive,
        celebrateOnTarget,
        showGroupBreakdown,
        autoCount,
        autoIntervalMs,
        orderIndex,
        pinned,
        archived,
        createdAt,
        updatedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Counter &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.startValue == this.startValue &&
          other.targetValue == this.targetValue &&
          other.direction == this.direction &&
          other.stepSize == this.stepSize &&
          other.currentValue == this.currentValue &&
          other.accentColor == this.accentColor &&
          other.lineStyle == this.lineStyle &&
          other.numberPosX == this.numberPosX &&
          other.numberPosY == this.numberPosY &&
          other.numberScale == this.numberScale &&
          other.numberOpacity == this.numberOpacity &&
          other.numberColor == this.numberColor &&
          other.autoArchive == this.autoArchive &&
          other.celebrateOnTarget == this.celebrateOnTarget &&
          other.showGroupBreakdown == this.showGroupBreakdown &&
          other.autoCount == this.autoCount &&
          other.autoIntervalMs == this.autoIntervalMs &&
          other.orderIndex == this.orderIndex &&
          other.pinned == this.pinned &&
          other.archived == this.archived &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CountersCompanion extends UpdateCompanion<Counter> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<int> startValue;
  final Value<int?> targetValue;
  final Value<int> direction;
  final Value<int> stepSize;
  final Value<int> currentValue;
  final Value<int> accentColor;
  final Value<String> lineStyle;
  final Value<double> numberPosX;
  final Value<double> numberPosY;
  final Value<double> numberScale;
  final Value<double> numberOpacity;
  final Value<int?> numberColor;
  final Value<bool> autoArchive;
  final Value<bool> celebrateOnTarget;
  final Value<bool> showGroupBreakdown;
  final Value<bool> autoCount;
  final Value<int> autoIntervalMs;
  final Value<int> orderIndex;
  final Value<bool> pinned;
  final Value<bool> archived;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CountersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.startValue = const Value.absent(),
    this.targetValue = const Value.absent(),
    this.direction = const Value.absent(),
    this.stepSize = const Value.absent(),
    this.currentValue = const Value.absent(),
    this.accentColor = const Value.absent(),
    this.lineStyle = const Value.absent(),
    this.numberPosX = const Value.absent(),
    this.numberPosY = const Value.absent(),
    this.numberScale = const Value.absent(),
    this.numberOpacity = const Value.absent(),
    this.numberColor = const Value.absent(),
    this.autoArchive = const Value.absent(),
    this.celebrateOnTarget = const Value.absent(),
    this.showGroupBreakdown = const Value.absent(),
    this.autoCount = const Value.absent(),
    this.autoIntervalMs = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.pinned = const Value.absent(),
    this.archived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CountersCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.startValue = const Value.absent(),
    this.targetValue = const Value.absent(),
    this.direction = const Value.absent(),
    this.stepSize = const Value.absent(),
    this.currentValue = const Value.absent(),
    this.accentColor = const Value.absent(),
    this.lineStyle = const Value.absent(),
    this.numberPosX = const Value.absent(),
    this.numberPosY = const Value.absent(),
    this.numberScale = const Value.absent(),
    this.numberOpacity = const Value.absent(),
    this.numberColor = const Value.absent(),
    this.autoArchive = const Value.absent(),
    this.celebrateOnTarget = const Value.absent(),
    this.showGroupBreakdown = const Value.absent(),
    this.autoCount = const Value.absent(),
    this.autoIntervalMs = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.pinned = const Value.absent(),
    this.archived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<Counter> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? startValue,
    Expression<int>? targetValue,
    Expression<int>? direction,
    Expression<int>? stepSize,
    Expression<int>? currentValue,
    Expression<int>? accentColor,
    Expression<String>? lineStyle,
    Expression<double>? numberPosX,
    Expression<double>? numberPosY,
    Expression<double>? numberScale,
    Expression<double>? numberOpacity,
    Expression<int>? numberColor,
    Expression<bool>? autoArchive,
    Expression<bool>? celebrateOnTarget,
    Expression<bool>? showGroupBreakdown,
    Expression<bool>? autoCount,
    Expression<int>? autoIntervalMs,
    Expression<int>? orderIndex,
    Expression<bool>? pinned,
    Expression<bool>? archived,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (startValue != null) 'start_value': startValue,
      if (targetValue != null) 'target_value': targetValue,
      if (direction != null) 'direction': direction,
      if (stepSize != null) 'step_size': stepSize,
      if (currentValue != null) 'current_value': currentValue,
      if (accentColor != null) 'accent_color': accentColor,
      if (lineStyle != null) 'line_style': lineStyle,
      if (numberPosX != null) 'number_pos_x': numberPosX,
      if (numberPosY != null) 'number_pos_y': numberPosY,
      if (numberScale != null) 'number_scale': numberScale,
      if (numberOpacity != null) 'number_opacity': numberOpacity,
      if (numberColor != null) 'number_color': numberColor,
      if (autoArchive != null) 'auto_archive': autoArchive,
      if (celebrateOnTarget != null) 'celebrate_on_target': celebrateOnTarget,
      if (showGroupBreakdown != null)
        'show_group_breakdown': showGroupBreakdown,
      if (autoCount != null) 'auto_count': autoCount,
      if (autoIntervalMs != null) 'auto_interval_ms': autoIntervalMs,
      if (orderIndex != null) 'order_index': orderIndex,
      if (pinned != null) 'pinned': pinned,
      if (archived != null) 'archived': archived,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CountersCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<int>? startValue,
      Value<int?>? targetValue,
      Value<int>? direction,
      Value<int>? stepSize,
      Value<int>? currentValue,
      Value<int>? accentColor,
      Value<String>? lineStyle,
      Value<double>? numberPosX,
      Value<double>? numberPosY,
      Value<double>? numberScale,
      Value<double>? numberOpacity,
      Value<int?>? numberColor,
      Value<bool>? autoArchive,
      Value<bool>? celebrateOnTarget,
      Value<bool>? showGroupBreakdown,
      Value<bool>? autoCount,
      Value<int>? autoIntervalMs,
      Value<int>? orderIndex,
      Value<bool>? pinned,
      Value<bool>? archived,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return CountersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      startValue: startValue ?? this.startValue,
      targetValue: targetValue ?? this.targetValue,
      direction: direction ?? this.direction,
      stepSize: stepSize ?? this.stepSize,
      currentValue: currentValue ?? this.currentValue,
      accentColor: accentColor ?? this.accentColor,
      lineStyle: lineStyle ?? this.lineStyle,
      numberPosX: numberPosX ?? this.numberPosX,
      numberPosY: numberPosY ?? this.numberPosY,
      numberScale: numberScale ?? this.numberScale,
      numberOpacity: numberOpacity ?? this.numberOpacity,
      numberColor: numberColor ?? this.numberColor,
      autoArchive: autoArchive ?? this.autoArchive,
      celebrateOnTarget: celebrateOnTarget ?? this.celebrateOnTarget,
      showGroupBreakdown: showGroupBreakdown ?? this.showGroupBreakdown,
      autoCount: autoCount ?? this.autoCount,
      autoIntervalMs: autoIntervalMs ?? this.autoIntervalMs,
      orderIndex: orderIndex ?? this.orderIndex,
      pinned: pinned ?? this.pinned,
      archived: archived ?? this.archived,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (startValue.present) {
      map['start_value'] = Variable<int>(startValue.value);
    }
    if (targetValue.present) {
      map['target_value'] = Variable<int>(targetValue.value);
    }
    if (direction.present) {
      map['direction'] = Variable<int>(direction.value);
    }
    if (stepSize.present) {
      map['step_size'] = Variable<int>(stepSize.value);
    }
    if (currentValue.present) {
      map['current_value'] = Variable<int>(currentValue.value);
    }
    if (accentColor.present) {
      map['accent_color'] = Variable<int>(accentColor.value);
    }
    if (lineStyle.present) {
      map['line_style'] = Variable<String>(lineStyle.value);
    }
    if (numberPosX.present) {
      map['number_pos_x'] = Variable<double>(numberPosX.value);
    }
    if (numberPosY.present) {
      map['number_pos_y'] = Variable<double>(numberPosY.value);
    }
    if (numberScale.present) {
      map['number_scale'] = Variable<double>(numberScale.value);
    }
    if (numberOpacity.present) {
      map['number_opacity'] = Variable<double>(numberOpacity.value);
    }
    if (numberColor.present) {
      map['number_color'] = Variable<int>(numberColor.value);
    }
    if (autoArchive.present) {
      map['auto_archive'] = Variable<bool>(autoArchive.value);
    }
    if (celebrateOnTarget.present) {
      map['celebrate_on_target'] = Variable<bool>(celebrateOnTarget.value);
    }
    if (showGroupBreakdown.present) {
      map['show_group_breakdown'] = Variable<bool>(showGroupBreakdown.value);
    }
    if (autoCount.present) {
      map['auto_count'] = Variable<bool>(autoCount.value);
    }
    if (autoIntervalMs.present) {
      map['auto_interval_ms'] = Variable<int>(autoIntervalMs.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (pinned.present) {
      map['pinned'] = Variable<bool>(pinned.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CountersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('startValue: $startValue, ')
          ..write('targetValue: $targetValue, ')
          ..write('direction: $direction, ')
          ..write('stepSize: $stepSize, ')
          ..write('currentValue: $currentValue, ')
          ..write('accentColor: $accentColor, ')
          ..write('lineStyle: $lineStyle, ')
          ..write('numberPosX: $numberPosX, ')
          ..write('numberPosY: $numberPosY, ')
          ..write('numberScale: $numberScale, ')
          ..write('numberOpacity: $numberOpacity, ')
          ..write('numberColor: $numberColor, ')
          ..write('autoArchive: $autoArchive, ')
          ..write('celebrateOnTarget: $celebrateOnTarget, ')
          ..write('showGroupBreakdown: $showGroupBreakdown, ')
          ..write('autoCount: $autoCount, ')
          ..write('autoIntervalMs: $autoIntervalMs, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('pinned: $pinned, ')
          ..write('archived: $archived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TapsTable extends Taps with TableInfo<$TapsTable, Tap> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TapsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _counterIdMeta =
      const VerificationMeta('counterId');
  @override
  late final GeneratedColumn<String> counterId = GeneratedColumn<String>(
      'counter_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES counters (id) ON DELETE CASCADE'));
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
      'session_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deltaMeta = const VerificationMeta('delta');
  @override
  late final GeneratedColumn<int> delta = GeneratedColumn<int>(
      'delta', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _valueAfterMeta =
      const VerificationMeta('valueAfter');
  @override
  late final GeneratedColumn<int> valueAfter = GeneratedColumn<int>(
      'value_after', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
      'at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, counterId, sessionId, delta, valueAfter, at, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'taps';
  @override
  VerificationContext validateIntegrity(Insertable<Tap> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('counter_id')) {
      context.handle(_counterIdMeta,
          counterId.isAcceptableOrUnknown(data['counter_id']!, _counterIdMeta));
    } else if (isInserting) {
      context.missing(_counterIdMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    }
    if (data.containsKey('delta')) {
      context.handle(
          _deltaMeta, delta.isAcceptableOrUnknown(data['delta']!, _deltaMeta));
    } else if (isInserting) {
      context.missing(_deltaMeta);
    }
    if (data.containsKey('value_after')) {
      context.handle(
          _valueAfterMeta,
          valueAfter.isAcceptableOrUnknown(
              data['value_after']!, _valueAfterMeta));
    } else if (isInserting) {
      context.missing(_valueAfterMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tap map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tap(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      counterId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}counter_id'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}session_id']),
      delta: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}delta'])!,
      valueAfter: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}value_after'])!,
      at: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}at'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
    );
  }

  @override
  $TapsTable createAlias(String alias) {
    return $TapsTable(attachedDatabase, alias);
  }
}

class Tap extends DataClass implements Insertable<Tap> {
  final String id;
  final String counterId;
  final String? sessionId;
  final int delta;
  final int valueAfter;
  final DateTime at;
  final String? note;
  const Tap(
      {required this.id,
      required this.counterId,
      this.sessionId,
      required this.delta,
      required this.valueAfter,
      required this.at,
      this.note});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['counter_id'] = Variable<String>(counterId);
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<String>(sessionId);
    }
    map['delta'] = Variable<int>(delta);
    map['value_after'] = Variable<int>(valueAfter);
    map['at'] = Variable<DateTime>(at);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  TapsCompanion toCompanion(bool nullToAbsent) {
    return TapsCompanion(
      id: Value(id),
      counterId: Value(counterId),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
      delta: Value(delta),
      valueAfter: Value(valueAfter),
      at: Value(at),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory Tap.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tap(
      id: serializer.fromJson<String>(json['id']),
      counterId: serializer.fromJson<String>(json['counterId']),
      sessionId: serializer.fromJson<String?>(json['sessionId']),
      delta: serializer.fromJson<int>(json['delta']),
      valueAfter: serializer.fromJson<int>(json['valueAfter']),
      at: serializer.fromJson<DateTime>(json['at']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'counterId': serializer.toJson<String>(counterId),
      'sessionId': serializer.toJson<String?>(sessionId),
      'delta': serializer.toJson<int>(delta),
      'valueAfter': serializer.toJson<int>(valueAfter),
      'at': serializer.toJson<DateTime>(at),
      'note': serializer.toJson<String?>(note),
    };
  }

  Tap copyWith(
          {String? id,
          String? counterId,
          Value<String?> sessionId = const Value.absent(),
          int? delta,
          int? valueAfter,
          DateTime? at,
          Value<String?> note = const Value.absent()}) =>
      Tap(
        id: id ?? this.id,
        counterId: counterId ?? this.counterId,
        sessionId: sessionId.present ? sessionId.value : this.sessionId,
        delta: delta ?? this.delta,
        valueAfter: valueAfter ?? this.valueAfter,
        at: at ?? this.at,
        note: note.present ? note.value : this.note,
      );
  Tap copyWithCompanion(TapsCompanion data) {
    return Tap(
      id: data.id.present ? data.id.value : this.id,
      counterId: data.counterId.present ? data.counterId.value : this.counterId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      delta: data.delta.present ? data.delta.value : this.delta,
      valueAfter:
          data.valueAfter.present ? data.valueAfter.value : this.valueAfter,
      at: data.at.present ? data.at.value : this.at,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tap(')
          ..write('id: $id, ')
          ..write('counterId: $counterId, ')
          ..write('sessionId: $sessionId, ')
          ..write('delta: $delta, ')
          ..write('valueAfter: $valueAfter, ')
          ..write('at: $at, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, counterId, sessionId, delta, valueAfter, at, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tap &&
          other.id == this.id &&
          other.counterId == this.counterId &&
          other.sessionId == this.sessionId &&
          other.delta == this.delta &&
          other.valueAfter == this.valueAfter &&
          other.at == this.at &&
          other.note == this.note);
}

class TapsCompanion extends UpdateCompanion<Tap> {
  final Value<String> id;
  final Value<String> counterId;
  final Value<String?> sessionId;
  final Value<int> delta;
  final Value<int> valueAfter;
  final Value<DateTime> at;
  final Value<String?> note;
  final Value<int> rowid;
  const TapsCompanion({
    this.id = const Value.absent(),
    this.counterId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.delta = const Value.absent(),
    this.valueAfter = const Value.absent(),
    this.at = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TapsCompanion.insert({
    required String id,
    required String counterId,
    this.sessionId = const Value.absent(),
    required int delta,
    required int valueAfter,
    this.at = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        counterId = Value(counterId),
        delta = Value(delta),
        valueAfter = Value(valueAfter);
  static Insertable<Tap> custom({
    Expression<String>? id,
    Expression<String>? counterId,
    Expression<String>? sessionId,
    Expression<int>? delta,
    Expression<int>? valueAfter,
    Expression<DateTime>? at,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (counterId != null) 'counter_id': counterId,
      if (sessionId != null) 'session_id': sessionId,
      if (delta != null) 'delta': delta,
      if (valueAfter != null) 'value_after': valueAfter,
      if (at != null) 'at': at,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TapsCompanion copyWith(
      {Value<String>? id,
      Value<String>? counterId,
      Value<String?>? sessionId,
      Value<int>? delta,
      Value<int>? valueAfter,
      Value<DateTime>? at,
      Value<String?>? note,
      Value<int>? rowid}) {
    return TapsCompanion(
      id: id ?? this.id,
      counterId: counterId ?? this.counterId,
      sessionId: sessionId ?? this.sessionId,
      delta: delta ?? this.delta,
      valueAfter: valueAfter ?? this.valueAfter,
      at: at ?? this.at,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (counterId.present) {
      map['counter_id'] = Variable<String>(counterId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (delta.present) {
      map['delta'] = Variable<int>(delta.value);
    }
    if (valueAfter.present) {
      map['value_after'] = Variable<int>(valueAfter.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TapsCompanion(')
          ..write('id: $id, ')
          ..write('counterId: $counterId, ')
          ..write('sessionId: $sessionId, ')
          ..write('delta: $delta, ')
          ..write('valueAfter: $valueAfter, ')
          ..write('at: $at, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _counterIdMeta =
      const VerificationMeta('counterId');
  @override
  late final GeneratedColumn<String> counterId = GeneratedColumn<String>(
      'counter_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES counters (id) ON DELETE CASCADE'));
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
      'tags', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _endedAtMeta =
      const VerificationMeta('endedAt');
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
      'ended_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _startValueMeta =
      const VerificationMeta('startValue');
  @override
  late final GeneratedColumn<int> startValue = GeneratedColumn<int>(
      'start_value', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _endValueMeta =
      const VerificationMeta('endValue');
  @override
  late final GeneratedColumn<int> endValue = GeneratedColumn<int>(
      'end_value', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, counterId, label, tags, startedAt, endedAt, startValue, endValue];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(Insertable<Session> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('counter_id')) {
      context.handle(_counterIdMeta,
          counterId.isAcceptableOrUnknown(data['counter_id']!, _counterIdMeta));
    } else if (isInserting) {
      context.missing(_counterIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    }
    if (data.containsKey('tags')) {
      context.handle(
          _tagsMeta, tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    }
    if (data.containsKey('ended_at')) {
      context.handle(_endedAtMeta,
          endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta));
    }
    if (data.containsKey('start_value')) {
      context.handle(
          _startValueMeta,
          startValue.isAcceptableOrUnknown(
              data['start_value']!, _startValueMeta));
    }
    if (data.containsKey('end_value')) {
      context.handle(_endValueMeta,
          endValue.isAcceptableOrUnknown(data['end_value']!, _endValueMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      counterId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}counter_id'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label']),
      tags: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags']),
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at'])!,
      endedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}ended_at']),
      startValue: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}start_value'])!,
      endValue: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}end_value']),
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final String id;
  final String counterId;
  final String? label;
  final String? tags;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int startValue;
  final int? endValue;
  const Session(
      {required this.id,
      required this.counterId,
      this.label,
      this.tags,
      required this.startedAt,
      this.endedAt,
      required this.startValue,
      this.endValue});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['counter_id'] = Variable<String>(counterId);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    if (!nullToAbsent || tags != null) {
      map['tags'] = Variable<String>(tags);
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['start_value'] = Variable<int>(startValue);
    if (!nullToAbsent || endValue != null) {
      map['end_value'] = Variable<int>(endValue);
    }
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      counterId: Value(counterId),
      label:
          label == null && nullToAbsent ? const Value.absent() : Value(label),
      tags: tags == null && nullToAbsent ? const Value.absent() : Value(tags),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      startValue: Value(startValue),
      endValue: endValue == null && nullToAbsent
          ? const Value.absent()
          : Value(endValue),
    );
  }

  factory Session.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<String>(json['id']),
      counterId: serializer.fromJson<String>(json['counterId']),
      label: serializer.fromJson<String?>(json['label']),
      tags: serializer.fromJson<String?>(json['tags']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      startValue: serializer.fromJson<int>(json['startValue']),
      endValue: serializer.fromJson<int?>(json['endValue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'counterId': serializer.toJson<String>(counterId),
      'label': serializer.toJson<String?>(label),
      'tags': serializer.toJson<String?>(tags),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'startValue': serializer.toJson<int>(startValue),
      'endValue': serializer.toJson<int?>(endValue),
    };
  }

  Session copyWith(
          {String? id,
          String? counterId,
          Value<String?> label = const Value.absent(),
          Value<String?> tags = const Value.absent(),
          DateTime? startedAt,
          Value<DateTime?> endedAt = const Value.absent(),
          int? startValue,
          Value<int?> endValue = const Value.absent()}) =>
      Session(
        id: id ?? this.id,
        counterId: counterId ?? this.counterId,
        label: label.present ? label.value : this.label,
        tags: tags.present ? tags.value : this.tags,
        startedAt: startedAt ?? this.startedAt,
        endedAt: endedAt.present ? endedAt.value : this.endedAt,
        startValue: startValue ?? this.startValue,
        endValue: endValue.present ? endValue.value : this.endValue,
      );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      counterId: data.counterId.present ? data.counterId.value : this.counterId,
      label: data.label.present ? data.label.value : this.label,
      tags: data.tags.present ? data.tags.value : this.tags,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      startValue:
          data.startValue.present ? data.startValue.value : this.startValue,
      endValue: data.endValue.present ? data.endValue.value : this.endValue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('counterId: $counterId, ')
          ..write('label: $label, ')
          ..write('tags: $tags, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('startValue: $startValue, ')
          ..write('endValue: $endValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, counterId, label, tags, startedAt, endedAt, startValue, endValue);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.counterId == this.counterId &&
          other.label == this.label &&
          other.tags == this.tags &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.startValue == this.startValue &&
          other.endValue == this.endValue);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<String> id;
  final Value<String> counterId;
  final Value<String?> label;
  final Value<String?> tags;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<int> startValue;
  final Value<int?> endValue;
  final Value<int> rowid;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.counterId = const Value.absent(),
    this.label = const Value.absent(),
    this.tags = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.startValue = const Value.absent(),
    this.endValue = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionsCompanion.insert({
    required String id,
    required String counterId,
    this.label = const Value.absent(),
    this.tags = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.startValue = const Value.absent(),
    this.endValue = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        counterId = Value(counterId);
  static Insertable<Session> custom({
    Expression<String>? id,
    Expression<String>? counterId,
    Expression<String>? label,
    Expression<String>? tags,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<int>? startValue,
    Expression<int>? endValue,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (counterId != null) 'counter_id': counterId,
      if (label != null) 'label': label,
      if (tags != null) 'tags': tags,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (startValue != null) 'start_value': startValue,
      if (endValue != null) 'end_value': endValue,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? counterId,
      Value<String?>? label,
      Value<String?>? tags,
      Value<DateTime>? startedAt,
      Value<DateTime?>? endedAt,
      Value<int>? startValue,
      Value<int?>? endValue,
      Value<int>? rowid}) {
    return SessionsCompanion(
      id: id ?? this.id,
      counterId: counterId ?? this.counterId,
      label: label ?? this.label,
      tags: tags ?? this.tags,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      startValue: startValue ?? this.startValue,
      endValue: endValue ?? this.endValue,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (counterId.present) {
      map['counter_id'] = Variable<String>(counterId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (startValue.present) {
      map['start_value'] = Variable<int>(startValue.value);
    }
    if (endValue.present) {
      map['end_value'] = Variable<int>(endValue.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('counterId: $counterId, ')
          ..write('label: $label, ')
          ..write('tags: $tags, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('startValue: $startValue, ')
          ..write('endValue: $endValue, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTableTable extends SettingsTable
    with TableInfo<$SettingsTableTable, SettingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings_table';
  @override
  VerificationContext validateIntegrity(Insertable<SettingsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingsTableData(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SettingsTableTable createAlias(String alias) {
    return $SettingsTableTable(attachedDatabase, alias);
  }
}

class SettingsTableData extends DataClass
    implements Insertable<SettingsTableData> {
  final String key;
  final String? value;
  final DateTime updatedAt;
  const SettingsTableData(
      {required this.key, this.value, required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SettingsTableCompanion toCompanion(bool nullToAbsent) {
    return SettingsTableCompanion(
      key: Value(key),
      value:
          value == null && nullToAbsent ? const Value.absent() : Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory SettingsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingsTableData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String?>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String?>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SettingsTableData copyWith(
          {String? key,
          Value<String?> value = const Value.absent(),
          DateTime? updatedAt}) =>
      SettingsTableData(
        key: key ?? this.key,
        value: value.present ? value.value : this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  SettingsTableData copyWithCompanion(SettingsTableCompanion data) {
    return SettingsTableData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingsTableData(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingsTableData &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class SettingsTableCompanion extends UpdateCompanion<SettingsTableData> {
  final Value<String> key;
  final Value<String?> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SettingsTableCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsTableCompanion.insert({
    required String key,
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<SettingsTableData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsTableCompanion copyWith(
      {Value<String>? key,
      Value<String?>? value,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return SettingsTableCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsTableCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CountersTable counters = $CountersTable(this);
  late final $TapsTable taps = $TapsTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $SettingsTableTable settingsTable = $SettingsTableTable(this);
  late final Index countersNameIdx = Index(
      'counters_name_idx', 'CREATE INDEX counters_name_idx ON counters (name)');
  late final Index tapsCounterAtIdx = Index('taps_counter_at_idx',
      'CREATE INDEX taps_counter_at_idx ON taps (counter_id, at)');
  late final Index tapsSessionIdx = Index(
      'taps_session_idx', 'CREATE INDEX taps_session_idx ON taps (session_id)');
  late final Index sessionsCounterIdx = Index('sessions_counter_idx',
      'CREATE INDEX sessions_counter_idx ON sessions (counter_id, started_at)');
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        counters,
        taps,
        sessions,
        settingsTable,
        countersNameIdx,
        tapsCounterAtIdx,
        tapsSessionIdx,
        sessionsCounterIdx
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('counters',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('taps', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('counters',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('sessions', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$CountersTableCreateCompanionBuilder = CountersCompanion Function({
  required String id,
  required String name,
  Value<String?> description,
  Value<int> startValue,
  Value<int?> targetValue,
  Value<int> direction,
  Value<int> stepSize,
  Value<int> currentValue,
  Value<int> accentColor,
  Value<String> lineStyle,
  Value<double> numberPosX,
  Value<double> numberPosY,
  Value<double> numberScale,
  Value<double> numberOpacity,
  Value<int?> numberColor,
  Value<bool> autoArchive,
  Value<bool> celebrateOnTarget,
  Value<bool> showGroupBreakdown,
  Value<bool> autoCount,
  Value<int> autoIntervalMs,
  Value<int> orderIndex,
  Value<bool> pinned,
  Value<bool> archived,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$CountersTableUpdateCompanionBuilder = CountersCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> description,
  Value<int> startValue,
  Value<int?> targetValue,
  Value<int> direction,
  Value<int> stepSize,
  Value<int> currentValue,
  Value<int> accentColor,
  Value<String> lineStyle,
  Value<double> numberPosX,
  Value<double> numberPosY,
  Value<double> numberScale,
  Value<double> numberOpacity,
  Value<int?> numberColor,
  Value<bool> autoArchive,
  Value<bool> celebrateOnTarget,
  Value<bool> showGroupBreakdown,
  Value<bool> autoCount,
  Value<int> autoIntervalMs,
  Value<int> orderIndex,
  Value<bool> pinned,
  Value<bool> archived,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$CountersTableReferences
    extends BaseReferences<_$AppDatabase, $CountersTable, Counter> {
  $$CountersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TapsTable, List<Tap>> _tapsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.taps,
          aliasName: 'counters__id__taps__counter_id');

  $$TapsTableProcessedTableManager get tapsRefs {
    final manager = $$TapsTableTableManager($_db, $_db.taps)
        .filter((f) => f.counterId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tapsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SessionsTable, List<Session>> _sessionsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.sessions,
          aliasName: 'counters__id__sessions__counter_id');

  $$SessionsTableProcessedTableManager get sessionsRefs {
    final manager = $$SessionsTableTableManager($_db, $_db.sessions)
        .filter((f) => f.counterId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CountersTableFilterComposer
    extends Composer<_$AppDatabase, $CountersTable> {
  $$CountersTableFilterComposer({
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

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get startValue => $composableBuilder(
      column: $table.startValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get targetValue => $composableBuilder(
      column: $table.targetValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get direction => $composableBuilder(
      column: $table.direction, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get stepSize => $composableBuilder(
      column: $table.stepSize, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get currentValue => $composableBuilder(
      column: $table.currentValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get accentColor => $composableBuilder(
      column: $table.accentColor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lineStyle => $composableBuilder(
      column: $table.lineStyle, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get numberPosX => $composableBuilder(
      column: $table.numberPosX, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get numberPosY => $composableBuilder(
      column: $table.numberPosY, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get numberScale => $composableBuilder(
      column: $table.numberScale, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get numberOpacity => $composableBuilder(
      column: $table.numberOpacity, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get numberColor => $composableBuilder(
      column: $table.numberColor, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get autoArchive => $composableBuilder(
      column: $table.autoArchive, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get celebrateOnTarget => $composableBuilder(
      column: $table.celebrateOnTarget,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get showGroupBreakdown => $composableBuilder(
      column: $table.showGroupBreakdown,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get autoCount => $composableBuilder(
      column: $table.autoCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get autoIntervalMs => $composableBuilder(
      column: $table.autoIntervalMs,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get pinned => $composableBuilder(
      column: $table.pinned, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get archived => $composableBuilder(
      column: $table.archived, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> tapsRefs(
      Expression<bool> Function($$TapsTableFilterComposer f) f) {
    final $$TapsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.taps,
        getReferencedColumn: (t) => t.counterId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TapsTableFilterComposer(
              $db: $db,
              $table: $db.taps,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> sessionsRefs(
      Expression<bool> Function($$SessionsTableFilterComposer f) f) {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sessions,
        getReferencedColumn: (t) => t.counterId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionsTableFilterComposer(
              $db: $db,
              $table: $db.sessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CountersTableOrderingComposer
    extends Composer<_$AppDatabase, $CountersTable> {
  $$CountersTableOrderingComposer({
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

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get startValue => $composableBuilder(
      column: $table.startValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get targetValue => $composableBuilder(
      column: $table.targetValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get direction => $composableBuilder(
      column: $table.direction, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get stepSize => $composableBuilder(
      column: $table.stepSize, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get currentValue => $composableBuilder(
      column: $table.currentValue,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get accentColor => $composableBuilder(
      column: $table.accentColor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lineStyle => $composableBuilder(
      column: $table.lineStyle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get numberPosX => $composableBuilder(
      column: $table.numberPosX, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get numberPosY => $composableBuilder(
      column: $table.numberPosY, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get numberScale => $composableBuilder(
      column: $table.numberScale, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get numberOpacity => $composableBuilder(
      column: $table.numberOpacity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get numberColor => $composableBuilder(
      column: $table.numberColor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get autoArchive => $composableBuilder(
      column: $table.autoArchive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get celebrateOnTarget => $composableBuilder(
      column: $table.celebrateOnTarget,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get showGroupBreakdown => $composableBuilder(
      column: $table.showGroupBreakdown,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get autoCount => $composableBuilder(
      column: $table.autoCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get autoIntervalMs => $composableBuilder(
      column: $table.autoIntervalMs,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get pinned => $composableBuilder(
      column: $table.pinned, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get archived => $composableBuilder(
      column: $table.archived, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$CountersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CountersTable> {
  $$CountersTableAnnotationComposer({
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

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get startValue => $composableBuilder(
      column: $table.startValue, builder: (column) => column);

  GeneratedColumn<int> get targetValue => $composableBuilder(
      column: $table.targetValue, builder: (column) => column);

  GeneratedColumn<int> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<int> get stepSize =>
      $composableBuilder(column: $table.stepSize, builder: (column) => column);

  GeneratedColumn<int> get currentValue => $composableBuilder(
      column: $table.currentValue, builder: (column) => column);

  GeneratedColumn<int> get accentColor => $composableBuilder(
      column: $table.accentColor, builder: (column) => column);

  GeneratedColumn<String> get lineStyle =>
      $composableBuilder(column: $table.lineStyle, builder: (column) => column);

  GeneratedColumn<double> get numberPosX => $composableBuilder(
      column: $table.numberPosX, builder: (column) => column);

  GeneratedColumn<double> get numberPosY => $composableBuilder(
      column: $table.numberPosY, builder: (column) => column);

  GeneratedColumn<double> get numberScale => $composableBuilder(
      column: $table.numberScale, builder: (column) => column);

  GeneratedColumn<double> get numberOpacity => $composableBuilder(
      column: $table.numberOpacity, builder: (column) => column);

  GeneratedColumn<int> get numberColor => $composableBuilder(
      column: $table.numberColor, builder: (column) => column);

  GeneratedColumn<bool> get autoArchive => $composableBuilder(
      column: $table.autoArchive, builder: (column) => column);

  GeneratedColumn<bool> get celebrateOnTarget => $composableBuilder(
      column: $table.celebrateOnTarget, builder: (column) => column);

  GeneratedColumn<bool> get showGroupBreakdown => $composableBuilder(
      column: $table.showGroupBreakdown, builder: (column) => column);

  GeneratedColumn<bool> get autoCount =>
      $composableBuilder(column: $table.autoCount, builder: (column) => column);

  GeneratedColumn<int> get autoIntervalMs => $composableBuilder(
      column: $table.autoIntervalMs, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => column);

  GeneratedColumn<bool> get pinned =>
      $composableBuilder(column: $table.pinned, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> tapsRefs<T extends Object>(
      Expression<T> Function($$TapsTableAnnotationComposer a) f) {
    final $$TapsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.taps,
        getReferencedColumn: (t) => t.counterId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TapsTableAnnotationComposer(
              $db: $db,
              $table: $db.taps,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> sessionsRefs<T extends Object>(
      Expression<T> Function($$SessionsTableAnnotationComposer a) f) {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sessions,
        getReferencedColumn: (t) => t.counterId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionsTableAnnotationComposer(
              $db: $db,
              $table: $db.sessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CountersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CountersTable,
    Counter,
    $$CountersTableFilterComposer,
    $$CountersTableOrderingComposer,
    $$CountersTableAnnotationComposer,
    $$CountersTableCreateCompanionBuilder,
    $$CountersTableUpdateCompanionBuilder,
    (Counter, $$CountersTableReferences),
    Counter,
    PrefetchHooks Function({bool tapsRefs, bool sessionsRefs})> {
  $$CountersTableTableManager(_$AppDatabase db, $CountersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CountersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CountersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CountersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<int> startValue = const Value.absent(),
            Value<int?> targetValue = const Value.absent(),
            Value<int> direction = const Value.absent(),
            Value<int> stepSize = const Value.absent(),
            Value<int> currentValue = const Value.absent(),
            Value<int> accentColor = const Value.absent(),
            Value<String> lineStyle = const Value.absent(),
            Value<double> numberPosX = const Value.absent(),
            Value<double> numberPosY = const Value.absent(),
            Value<double> numberScale = const Value.absent(),
            Value<double> numberOpacity = const Value.absent(),
            Value<int?> numberColor = const Value.absent(),
            Value<bool> autoArchive = const Value.absent(),
            Value<bool> celebrateOnTarget = const Value.absent(),
            Value<bool> showGroupBreakdown = const Value.absent(),
            Value<bool> autoCount = const Value.absent(),
            Value<int> autoIntervalMs = const Value.absent(),
            Value<int> orderIndex = const Value.absent(),
            Value<bool> pinned = const Value.absent(),
            Value<bool> archived = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CountersCompanion(
            id: id,
            name: name,
            description: description,
            startValue: startValue,
            targetValue: targetValue,
            direction: direction,
            stepSize: stepSize,
            currentValue: currentValue,
            accentColor: accentColor,
            lineStyle: lineStyle,
            numberPosX: numberPosX,
            numberPosY: numberPosY,
            numberScale: numberScale,
            numberOpacity: numberOpacity,
            numberColor: numberColor,
            autoArchive: autoArchive,
            celebrateOnTarget: celebrateOnTarget,
            showGroupBreakdown: showGroupBreakdown,
            autoCount: autoCount,
            autoIntervalMs: autoIntervalMs,
            orderIndex: orderIndex,
            pinned: pinned,
            archived: archived,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> description = const Value.absent(),
            Value<int> startValue = const Value.absent(),
            Value<int?> targetValue = const Value.absent(),
            Value<int> direction = const Value.absent(),
            Value<int> stepSize = const Value.absent(),
            Value<int> currentValue = const Value.absent(),
            Value<int> accentColor = const Value.absent(),
            Value<String> lineStyle = const Value.absent(),
            Value<double> numberPosX = const Value.absent(),
            Value<double> numberPosY = const Value.absent(),
            Value<double> numberScale = const Value.absent(),
            Value<double> numberOpacity = const Value.absent(),
            Value<int?> numberColor = const Value.absent(),
            Value<bool> autoArchive = const Value.absent(),
            Value<bool> celebrateOnTarget = const Value.absent(),
            Value<bool> showGroupBreakdown = const Value.absent(),
            Value<bool> autoCount = const Value.absent(),
            Value<int> autoIntervalMs = const Value.absent(),
            Value<int> orderIndex = const Value.absent(),
            Value<bool> pinned = const Value.absent(),
            Value<bool> archived = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CountersCompanion.insert(
            id: id,
            name: name,
            description: description,
            startValue: startValue,
            targetValue: targetValue,
            direction: direction,
            stepSize: stepSize,
            currentValue: currentValue,
            accentColor: accentColor,
            lineStyle: lineStyle,
            numberPosX: numberPosX,
            numberPosY: numberPosY,
            numberScale: numberScale,
            numberOpacity: numberOpacity,
            numberColor: numberColor,
            autoArchive: autoArchive,
            celebrateOnTarget: celebrateOnTarget,
            showGroupBreakdown: showGroupBreakdown,
            autoCount: autoCount,
            autoIntervalMs: autoIntervalMs,
            orderIndex: orderIndex,
            pinned: pinned,
            archived: archived,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$CountersTable, Counter>(table),
                    $$CountersTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({tapsRefs = false, sessionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (tapsRefs) db.taps,
                if (sessionsRefs) db.sessions
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tapsRefs)
                    await $_getPrefetchedData<Counter, $CountersTable, Tap>(
                        currentTable: table,
                        referencedTable:
                            $$CountersTableReferences._tapsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CountersTableReferences(db, table, p0).tapsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.counterId == item.id),
                        typedResults: items),
                  if (sessionsRefs)
                    await $_getPrefetchedData<Counter, $CountersTable, Session>(
                        currentTable: table,
                        referencedTable:
                            $$CountersTableReferences._sessionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CountersTableReferences(db, table, p0)
                                .sessionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.counterId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CountersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CountersTable,
    Counter,
    $$CountersTableFilterComposer,
    $$CountersTableOrderingComposer,
    $$CountersTableAnnotationComposer,
    $$CountersTableCreateCompanionBuilder,
    $$CountersTableUpdateCompanionBuilder,
    (Counter, $$CountersTableReferences),
    Counter,
    PrefetchHooks Function({bool tapsRefs, bool sessionsRefs})>;
typedef $$TapsTableCreateCompanionBuilder = TapsCompanion Function({
  required String id,
  required String counterId,
  Value<String?> sessionId,
  required int delta,
  required int valueAfter,
  Value<DateTime> at,
  Value<String?> note,
  Value<int> rowid,
});
typedef $$TapsTableUpdateCompanionBuilder = TapsCompanion Function({
  Value<String> id,
  Value<String> counterId,
  Value<String?> sessionId,
  Value<int> delta,
  Value<int> valueAfter,
  Value<DateTime> at,
  Value<String?> note,
  Value<int> rowid,
});

final class $$TapsTableReferences
    extends BaseReferences<_$AppDatabase, $TapsTable, Tap> {
  $$TapsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CountersTable _counterIdTable(_$AppDatabase db) =>
      db.counters.createAlias('taps__counter_id__counters__id');

  $$CountersTableProcessedTableManager get counterId {
    final $_column = $_itemColumn<String>('counter_id')!;

    final manager = $$CountersTableTableManager($_db, $_db.counters)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_counterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TapsTableFilterComposer extends Composer<_$AppDatabase, $TapsTable> {
  $$TapsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get delta => $composableBuilder(
      column: $table.delta, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get valueAfter => $composableBuilder(
      column: $table.valueAfter, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get at => $composableBuilder(
      column: $table.at, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  $$CountersTableFilterComposer get counterId {
    final $$CountersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.counterId,
        referencedTable: $db.counters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CountersTableFilterComposer(
              $db: $db,
              $table: $db.counters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TapsTableOrderingComposer extends Composer<_$AppDatabase, $TapsTable> {
  $$TapsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get delta => $composableBuilder(
      column: $table.delta, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get valueAfter => $composableBuilder(
      column: $table.valueAfter, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get at => $composableBuilder(
      column: $table.at, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  $$CountersTableOrderingComposer get counterId {
    final $$CountersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.counterId,
        referencedTable: $db.counters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CountersTableOrderingComposer(
              $db: $db,
              $table: $db.counters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TapsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TapsTable> {
  $$TapsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<int> get delta =>
      $composableBuilder(column: $table.delta, builder: (column) => column);

  GeneratedColumn<int> get valueAfter => $composableBuilder(
      column: $table.valueAfter, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$CountersTableAnnotationComposer get counterId {
    final $$CountersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.counterId,
        referencedTable: $db.counters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CountersTableAnnotationComposer(
              $db: $db,
              $table: $db.counters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TapsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TapsTable,
    Tap,
    $$TapsTableFilterComposer,
    $$TapsTableOrderingComposer,
    $$TapsTableAnnotationComposer,
    $$TapsTableCreateCompanionBuilder,
    $$TapsTableUpdateCompanionBuilder,
    (Tap, $$TapsTableReferences),
    Tap,
    PrefetchHooks Function({bool counterId})> {
  $$TapsTableTableManager(_$AppDatabase db, $TapsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TapsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TapsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TapsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> counterId = const Value.absent(),
            Value<String?> sessionId = const Value.absent(),
            Value<int> delta = const Value.absent(),
            Value<int> valueAfter = const Value.absent(),
            Value<DateTime> at = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TapsCompanion(
            id: id,
            counterId: counterId,
            sessionId: sessionId,
            delta: delta,
            valueAfter: valueAfter,
            at: at,
            note: note,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String counterId,
            Value<String?> sessionId = const Value.absent(),
            required int delta,
            required int valueAfter,
            Value<DateTime> at = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TapsCompanion.insert(
            id: id,
            counterId: counterId,
            sessionId: sessionId,
            delta: delta,
            valueAfter: valueAfter,
            at: at,
            note: note,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$TapsTable, Tap>(table),
                    $$TapsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({counterId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (counterId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.counterId,
                    referencedTable: $$TapsTableReferences._counterIdTable(db),
                    referencedColumn:
                        $$TapsTableReferences._counterIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$TapsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TapsTable,
    Tap,
    $$TapsTableFilterComposer,
    $$TapsTableOrderingComposer,
    $$TapsTableAnnotationComposer,
    $$TapsTableCreateCompanionBuilder,
    $$TapsTableUpdateCompanionBuilder,
    (Tap, $$TapsTableReferences),
    Tap,
    PrefetchHooks Function({bool counterId})>;
typedef $$SessionsTableCreateCompanionBuilder = SessionsCompanion Function({
  required String id,
  required String counterId,
  Value<String?> label,
  Value<String?> tags,
  Value<DateTime> startedAt,
  Value<DateTime?> endedAt,
  Value<int> startValue,
  Value<int?> endValue,
  Value<int> rowid,
});
typedef $$SessionsTableUpdateCompanionBuilder = SessionsCompanion Function({
  Value<String> id,
  Value<String> counterId,
  Value<String?> label,
  Value<String?> tags,
  Value<DateTime> startedAt,
  Value<DateTime?> endedAt,
  Value<int> startValue,
  Value<int?> endValue,
  Value<int> rowid,
});

final class $$SessionsTableReferences
    extends BaseReferences<_$AppDatabase, $SessionsTable, Session> {
  $$SessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CountersTable _counterIdTable(_$AppDatabase db) =>
      db.counters.createAlias('sessions__counter_id__counters__id');

  $$CountersTableProcessedTableManager get counterId {
    final $_column = $_itemColumn<String>('counter_id')!;

    final manager = $$CountersTableTableManager($_db, $_db.counters)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_counterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
      column: $table.endedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get startValue => $composableBuilder(
      column: $table.startValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get endValue => $composableBuilder(
      column: $table.endValue, builder: (column) => ColumnFilters(column));

  $$CountersTableFilterComposer get counterId {
    final $$CountersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.counterId,
        referencedTable: $db.counters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CountersTableFilterComposer(
              $db: $db,
              $table: $db.counters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
      column: $table.endedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get startValue => $composableBuilder(
      column: $table.startValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get endValue => $composableBuilder(
      column: $table.endValue, builder: (column) => ColumnOrderings(column));

  $$CountersTableOrderingComposer get counterId {
    final $$CountersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.counterId,
        referencedTable: $db.counters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CountersTableOrderingComposer(
              $db: $db,
              $table: $db.counters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get startValue => $composableBuilder(
      column: $table.startValue, builder: (column) => column);

  GeneratedColumn<int> get endValue =>
      $composableBuilder(column: $table.endValue, builder: (column) => column);

  $$CountersTableAnnotationComposer get counterId {
    final $$CountersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.counterId,
        referencedTable: $db.counters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CountersTableAnnotationComposer(
              $db: $db,
              $table: $db.counters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SessionsTable,
    Session,
    $$SessionsTableFilterComposer,
    $$SessionsTableOrderingComposer,
    $$SessionsTableAnnotationComposer,
    $$SessionsTableCreateCompanionBuilder,
    $$SessionsTableUpdateCompanionBuilder,
    (Session, $$SessionsTableReferences),
    Session,
    PrefetchHooks Function({bool counterId})> {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> counterId = const Value.absent(),
            Value<String?> label = const Value.absent(),
            Value<String?> tags = const Value.absent(),
            Value<DateTime> startedAt = const Value.absent(),
            Value<DateTime?> endedAt = const Value.absent(),
            Value<int> startValue = const Value.absent(),
            Value<int?> endValue = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SessionsCompanion(
            id: id,
            counterId: counterId,
            label: label,
            tags: tags,
            startedAt: startedAt,
            endedAt: endedAt,
            startValue: startValue,
            endValue: endValue,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String counterId,
            Value<String?> label = const Value.absent(),
            Value<String?> tags = const Value.absent(),
            Value<DateTime> startedAt = const Value.absent(),
            Value<DateTime?> endedAt = const Value.absent(),
            Value<int> startValue = const Value.absent(),
            Value<int?> endValue = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SessionsCompanion.insert(
            id: id,
            counterId: counterId,
            label: label,
            tags: tags,
            startedAt: startedAt,
            endedAt: endedAt,
            startValue: startValue,
            endValue: endValue,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$SessionsTable, Session>(table),
                    $$SessionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({counterId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (counterId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.counterId,
                    referencedTable:
                        $$SessionsTableReferences._counterIdTable(db),
                    referencedColumn:
                        $$SessionsTableReferences._counterIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$SessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SessionsTable,
    Session,
    $$SessionsTableFilterComposer,
    $$SessionsTableOrderingComposer,
    $$SessionsTableAnnotationComposer,
    $$SessionsTableCreateCompanionBuilder,
    $$SessionsTableUpdateCompanionBuilder,
    (Session, $$SessionsTableReferences),
    Session,
    PrefetchHooks Function({bool counterId})>;
typedef $$SettingsTableTableCreateCompanionBuilder = SettingsTableCompanion
    Function({
  required String key,
  Value<String?> value,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$SettingsTableTableUpdateCompanionBuilder = SettingsTableCompanion
    Function({
  Value<String> key,
  Value<String?> value,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$SettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$SettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SettingsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SettingsTableTable,
    SettingsTableData,
    $$SettingsTableTableFilterComposer,
    $$SettingsTableTableOrderingComposer,
    $$SettingsTableTableAnnotationComposer,
    $$SettingsTableTableCreateCompanionBuilder,
    $$SettingsTableTableUpdateCompanionBuilder,
    (
      SettingsTableData,
      BaseReferences<_$AppDatabase, $SettingsTableTable, SettingsTableData>
    ),
    SettingsTableData,
    PrefetchHooks Function()> {
  $$SettingsTableTableTableManager(_$AppDatabase db, $SettingsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String?> value = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsTableCompanion(
            key: key,
            value: value,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            Value<String?> value = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsTableCompanion.insert(
            key: key,
            value: value,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$SettingsTableTable, SettingsTableData>(table),
                    BaseReferences<_$AppDatabase, $SettingsTableTable,
                        SettingsTableData>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SettingsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SettingsTableTable,
    SettingsTableData,
    $$SettingsTableTableFilterComposer,
    $$SettingsTableTableOrderingComposer,
    $$SettingsTableTableAnnotationComposer,
    $$SettingsTableTableCreateCompanionBuilder,
    $$SettingsTableTableUpdateCompanionBuilder,
    (
      SettingsTableData,
      BaseReferences<_$AppDatabase, $SettingsTableTable, SettingsTableData>
    ),
    SettingsTableData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CountersTableTableManager get counters =>
      $$CountersTableTableManager(_db, _db.counters);
  $$TapsTableTableManager get taps => $$TapsTableTableManager(_db, _db.taps);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$SettingsTableTableTableManager get settingsTable =>
      $$SettingsTableTableTableManager(_db, _db.settingsTable);
}
