// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'crm_entities.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CrmKpiEntity {
  String get label => throw _privateConstructorUsedError;
  String get value => throw _privateConstructorUsedError;
  IconData get icon => throw _privateConstructorUsedError;
  Color get color => throw _privateConstructorUsedError;
  Color get bgColor => throw _privateConstructorUsedError;
  String get trend => throw _privateConstructorUsedError;
  bool get trendUp => throw _privateConstructorUsedError;

  /// Create a copy of CrmKpiEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CrmKpiEntityCopyWith<CrmKpiEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CrmKpiEntityCopyWith<$Res> {
  factory $CrmKpiEntityCopyWith(
    CrmKpiEntity value,
    $Res Function(CrmKpiEntity) then,
  ) = _$CrmKpiEntityCopyWithImpl<$Res, CrmKpiEntity>;
  @useResult
  $Res call({
    String label,
    String value,
    IconData icon,
    Color color,
    Color bgColor,
    String trend,
    bool trendUp,
  });
}

/// @nodoc
class _$CrmKpiEntityCopyWithImpl<$Res, $Val extends CrmKpiEntity>
    implements $CrmKpiEntityCopyWith<$Res> {
  _$CrmKpiEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CrmKpiEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? value = null,
    Object? icon = null,
    Object? color = null,
    Object? bgColor = null,
    Object? trend = null,
    Object? trendUp = null,
  }) {
    return _then(
      _value.copyWith(
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            value: null == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                      as String,
            icon: null == icon
                ? _value.icon
                : icon // ignore: cast_nullable_to_non_nullable
                      as IconData,
            color: null == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as Color,
            bgColor: null == bgColor
                ? _value.bgColor
                : bgColor // ignore: cast_nullable_to_non_nullable
                      as Color,
            trend: null == trend
                ? _value.trend
                : trend // ignore: cast_nullable_to_non_nullable
                      as String,
            trendUp: null == trendUp
                ? _value.trendUp
                : trendUp // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CrmKpiEntityImplCopyWith<$Res>
    implements $CrmKpiEntityCopyWith<$Res> {
  factory _$$CrmKpiEntityImplCopyWith(
    _$CrmKpiEntityImpl value,
    $Res Function(_$CrmKpiEntityImpl) then,
  ) = __$$CrmKpiEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String label,
    String value,
    IconData icon,
    Color color,
    Color bgColor,
    String trend,
    bool trendUp,
  });
}

/// @nodoc
class __$$CrmKpiEntityImplCopyWithImpl<$Res>
    extends _$CrmKpiEntityCopyWithImpl<$Res, _$CrmKpiEntityImpl>
    implements _$$CrmKpiEntityImplCopyWith<$Res> {
  __$$CrmKpiEntityImplCopyWithImpl(
    _$CrmKpiEntityImpl _value,
    $Res Function(_$CrmKpiEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CrmKpiEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? value = null,
    Object? icon = null,
    Object? color = null,
    Object? bgColor = null,
    Object? trend = null,
    Object? trendUp = null,
  }) {
    return _then(
      _$CrmKpiEntityImpl(
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        value: null == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                  as String,
        icon: null == icon
            ? _value.icon
            : icon // ignore: cast_nullable_to_non_nullable
                  as IconData,
        color: null == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as Color,
        bgColor: null == bgColor
            ? _value.bgColor
            : bgColor // ignore: cast_nullable_to_non_nullable
                  as Color,
        trend: null == trend
            ? _value.trend
            : trend // ignore: cast_nullable_to_non_nullable
                  as String,
        trendUp: null == trendUp
            ? _value.trendUp
            : trendUp // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$CrmKpiEntityImpl implements _CrmKpiEntity {
  const _$CrmKpiEntityImpl({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.trend,
    required this.trendUp,
  });

  @override
  final String label;
  @override
  final String value;
  @override
  final IconData icon;
  @override
  final Color color;
  @override
  final Color bgColor;
  @override
  final String trend;
  @override
  final bool trendUp;

  @override
  String toString() {
    return 'CrmKpiEntity(label: $label, value: $value, icon: $icon, color: $color, bgColor: $bgColor, trend: $trend, trendUp: $trendUp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CrmKpiEntityImpl &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.bgColor, bgColor) || other.bgColor == bgColor) &&
            (identical(other.trend, trend) || other.trend == trend) &&
            (identical(other.trendUp, trendUp) || other.trendUp == trendUp));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    label,
    value,
    icon,
    color,
    bgColor,
    trend,
    trendUp,
  );

  /// Create a copy of CrmKpiEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CrmKpiEntityImplCopyWith<_$CrmKpiEntityImpl> get copyWith =>
      __$$CrmKpiEntityImplCopyWithImpl<_$CrmKpiEntityImpl>(this, _$identity);
}

abstract class _CrmKpiEntity implements CrmKpiEntity {
  const factory _CrmKpiEntity({
    required final String label,
    required final String value,
    required final IconData icon,
    required final Color color,
    required final Color bgColor,
    required final String trend,
    required final bool trendUp,
  }) = _$CrmKpiEntityImpl;

  @override
  String get label;
  @override
  String get value;
  @override
  IconData get icon;
  @override
  Color get color;
  @override
  Color get bgColor;
  @override
  String get trend;
  @override
  bool get trendUp;

  /// Create a copy of CrmKpiEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CrmKpiEntityImplCopyWith<_$CrmKpiEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CrmChannelEntity {
  String get label => throw _privateConstructorUsedError;
  IconData get icon => throw _privateConstructorUsedError;
  Color get color => throw _privateConstructorUsedError;
  String get value => throw _privateConstructorUsedError;
  String get trend => throw _privateConstructorUsedError;
  bool get trendUp => throw _privateConstructorUsedError;

  /// Create a copy of CrmChannelEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CrmChannelEntityCopyWith<CrmChannelEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CrmChannelEntityCopyWith<$Res> {
  factory $CrmChannelEntityCopyWith(
    CrmChannelEntity value,
    $Res Function(CrmChannelEntity) then,
  ) = _$CrmChannelEntityCopyWithImpl<$Res, CrmChannelEntity>;
  @useResult
  $Res call({
    String label,
    IconData icon,
    Color color,
    String value,
    String trend,
    bool trendUp,
  });
}

/// @nodoc
class _$CrmChannelEntityCopyWithImpl<$Res, $Val extends CrmChannelEntity>
    implements $CrmChannelEntityCopyWith<$Res> {
  _$CrmChannelEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CrmChannelEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? icon = null,
    Object? color = null,
    Object? value = null,
    Object? trend = null,
    Object? trendUp = null,
  }) {
    return _then(
      _value.copyWith(
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            icon: null == icon
                ? _value.icon
                : icon // ignore: cast_nullable_to_non_nullable
                      as IconData,
            color: null == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as Color,
            value: null == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                      as String,
            trend: null == trend
                ? _value.trend
                : trend // ignore: cast_nullable_to_non_nullable
                      as String,
            trendUp: null == trendUp
                ? _value.trendUp
                : trendUp // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CrmChannelEntityImplCopyWith<$Res>
    implements $CrmChannelEntityCopyWith<$Res> {
  factory _$$CrmChannelEntityImplCopyWith(
    _$CrmChannelEntityImpl value,
    $Res Function(_$CrmChannelEntityImpl) then,
  ) = __$$CrmChannelEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String label,
    IconData icon,
    Color color,
    String value,
    String trend,
    bool trendUp,
  });
}

/// @nodoc
class __$$CrmChannelEntityImplCopyWithImpl<$Res>
    extends _$CrmChannelEntityCopyWithImpl<$Res, _$CrmChannelEntityImpl>
    implements _$$CrmChannelEntityImplCopyWith<$Res> {
  __$$CrmChannelEntityImplCopyWithImpl(
    _$CrmChannelEntityImpl _value,
    $Res Function(_$CrmChannelEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CrmChannelEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? icon = null,
    Object? color = null,
    Object? value = null,
    Object? trend = null,
    Object? trendUp = null,
  }) {
    return _then(
      _$CrmChannelEntityImpl(
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        icon: null == icon
            ? _value.icon
            : icon // ignore: cast_nullable_to_non_nullable
                  as IconData,
        color: null == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as Color,
        value: null == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                  as String,
        trend: null == trend
            ? _value.trend
            : trend // ignore: cast_nullable_to_non_nullable
                  as String,
        trendUp: null == trendUp
            ? _value.trendUp
            : trendUp // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$CrmChannelEntityImpl implements _CrmChannelEntity {
  const _$CrmChannelEntityImpl({
    required this.label,
    required this.icon,
    required this.color,
    required this.value,
    required this.trend,
    required this.trendUp,
  });

  @override
  final String label;
  @override
  final IconData icon;
  @override
  final Color color;
  @override
  final String value;
  @override
  final String trend;
  @override
  final bool trendUp;

  @override
  String toString() {
    return 'CrmChannelEntity(label: $label, icon: $icon, color: $color, value: $value, trend: $trend, trendUp: $trendUp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CrmChannelEntityImpl &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.trend, trend) || other.trend == trend) &&
            (identical(other.trendUp, trendUp) || other.trendUp == trendUp));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, label, icon, color, value, trend, trendUp);

  /// Create a copy of CrmChannelEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CrmChannelEntityImplCopyWith<_$CrmChannelEntityImpl> get copyWith =>
      __$$CrmChannelEntityImplCopyWithImpl<_$CrmChannelEntityImpl>(
        this,
        _$identity,
      );
}

abstract class _CrmChannelEntity implements CrmChannelEntity {
  const factory _CrmChannelEntity({
    required final String label,
    required final IconData icon,
    required final Color color,
    required final String value,
    required final String trend,
    required final bool trendUp,
  }) = _$CrmChannelEntityImpl;

  @override
  String get label;
  @override
  IconData get icon;
  @override
  Color get color;
  @override
  String get value;
  @override
  String get trend;
  @override
  bool get trendUp;

  /// Create a copy of CrmChannelEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CrmChannelEntityImplCopyWith<_$CrmChannelEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CrmLeadEntity {
  int get sno => throw _privateConstructorUsedError;
  String get leadNumber => throw _privateConstructorUsedError;
  String get customerName => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get source => throw _privateConstructorUsedError;
  Color get sourceColor => throw _privateConstructorUsedError;
  String get assignedTo => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  Color get statusColor => throw _privateConstructorUsedError;
  String get lastActivity => throw _privateConstructorUsedError;

  /// Create a copy of CrmLeadEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CrmLeadEntityCopyWith<CrmLeadEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CrmLeadEntityCopyWith<$Res> {
  factory $CrmLeadEntityCopyWith(
    CrmLeadEntity value,
    $Res Function(CrmLeadEntity) then,
  ) = _$CrmLeadEntityCopyWithImpl<$Res, CrmLeadEntity>;
  @useResult
  $Res call({
    int sno,
    String leadNumber,
    String customerName,
    String phone,
    String email,
    String source,
    Color sourceColor,
    String assignedTo,
    String status,
    Color statusColor,
    String lastActivity,
  });
}

/// @nodoc
class _$CrmLeadEntityCopyWithImpl<$Res, $Val extends CrmLeadEntity>
    implements $CrmLeadEntityCopyWith<$Res> {
  _$CrmLeadEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CrmLeadEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sno = null,
    Object? leadNumber = null,
    Object? customerName = null,
    Object? phone = null,
    Object? email = null,
    Object? source = null,
    Object? sourceColor = null,
    Object? assignedTo = null,
    Object? status = null,
    Object? statusColor = null,
    Object? lastActivity = null,
  }) {
    return _then(
      _value.copyWith(
            sno: null == sno
                ? _value.sno
                : sno // ignore: cast_nullable_to_non_nullable
                      as int,
            leadNumber: null == leadNumber
                ? _value.leadNumber
                : leadNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            customerName: null == customerName
                ? _value.customerName
                : customerName // ignore: cast_nullable_to_non_nullable
                      as String,
            phone: null == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            source: null == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as String,
            sourceColor: null == sourceColor
                ? _value.sourceColor
                : sourceColor // ignore: cast_nullable_to_non_nullable
                      as Color,
            assignedTo: null == assignedTo
                ? _value.assignedTo
                : assignedTo // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            statusColor: null == statusColor
                ? _value.statusColor
                : statusColor // ignore: cast_nullable_to_non_nullable
                      as Color,
            lastActivity: null == lastActivity
                ? _value.lastActivity
                : lastActivity // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CrmLeadEntityImplCopyWith<$Res>
    implements $CrmLeadEntityCopyWith<$Res> {
  factory _$$CrmLeadEntityImplCopyWith(
    _$CrmLeadEntityImpl value,
    $Res Function(_$CrmLeadEntityImpl) then,
  ) = __$$CrmLeadEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int sno,
    String leadNumber,
    String customerName,
    String phone,
    String email,
    String source,
    Color sourceColor,
    String assignedTo,
    String status,
    Color statusColor,
    String lastActivity,
  });
}

/// @nodoc
class __$$CrmLeadEntityImplCopyWithImpl<$Res>
    extends _$CrmLeadEntityCopyWithImpl<$Res, _$CrmLeadEntityImpl>
    implements _$$CrmLeadEntityImplCopyWith<$Res> {
  __$$CrmLeadEntityImplCopyWithImpl(
    _$CrmLeadEntityImpl _value,
    $Res Function(_$CrmLeadEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CrmLeadEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sno = null,
    Object? leadNumber = null,
    Object? customerName = null,
    Object? phone = null,
    Object? email = null,
    Object? source = null,
    Object? sourceColor = null,
    Object? assignedTo = null,
    Object? status = null,
    Object? statusColor = null,
    Object? lastActivity = null,
  }) {
    return _then(
      _$CrmLeadEntityImpl(
        sno: null == sno
            ? _value.sno
            : sno // ignore: cast_nullable_to_non_nullable
                  as int,
        leadNumber: null == leadNumber
            ? _value.leadNumber
            : leadNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        customerName: null == customerName
            ? _value.customerName
            : customerName // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: null == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        source: null == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as String,
        sourceColor: null == sourceColor
            ? _value.sourceColor
            : sourceColor // ignore: cast_nullable_to_non_nullable
                  as Color,
        assignedTo: null == assignedTo
            ? _value.assignedTo
            : assignedTo // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        statusColor: null == statusColor
            ? _value.statusColor
            : statusColor // ignore: cast_nullable_to_non_nullable
                  as Color,
        lastActivity: null == lastActivity
            ? _value.lastActivity
            : lastActivity // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$CrmLeadEntityImpl implements _CrmLeadEntity {
  const _$CrmLeadEntityImpl({
    required this.sno,
    required this.leadNumber,
    required this.customerName,
    required this.phone,
    required this.email,
    required this.source,
    required this.sourceColor,
    required this.assignedTo,
    required this.status,
    required this.statusColor,
    required this.lastActivity,
  });

  @override
  final int sno;
  @override
  final String leadNumber;
  @override
  final String customerName;
  @override
  final String phone;
  @override
  final String email;
  @override
  final String source;
  @override
  final Color sourceColor;
  @override
  final String assignedTo;
  @override
  final String status;
  @override
  final Color statusColor;
  @override
  final String lastActivity;

  @override
  String toString() {
    return 'CrmLeadEntity(sno: $sno, leadNumber: $leadNumber, customerName: $customerName, phone: $phone, email: $email, source: $source, sourceColor: $sourceColor, assignedTo: $assignedTo, status: $status, statusColor: $statusColor, lastActivity: $lastActivity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CrmLeadEntityImpl &&
            (identical(other.sno, sno) || other.sno == sno) &&
            (identical(other.leadNumber, leadNumber) ||
                other.leadNumber == leadNumber) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.sourceColor, sourceColor) ||
                other.sourceColor == sourceColor) &&
            (identical(other.assignedTo, assignedTo) ||
                other.assignedTo == assignedTo) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.statusColor, statusColor) ||
                other.statusColor == statusColor) &&
            (identical(other.lastActivity, lastActivity) ||
                other.lastActivity == lastActivity));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    sno,
    leadNumber,
    customerName,
    phone,
    email,
    source,
    sourceColor,
    assignedTo,
    status,
    statusColor,
    lastActivity,
  );

  /// Create a copy of CrmLeadEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CrmLeadEntityImplCopyWith<_$CrmLeadEntityImpl> get copyWith =>
      __$$CrmLeadEntityImplCopyWithImpl<_$CrmLeadEntityImpl>(this, _$identity);
}

abstract class _CrmLeadEntity implements CrmLeadEntity {
  const factory _CrmLeadEntity({
    required final int sno,
    required final String leadNumber,
    required final String customerName,
    required final String phone,
    required final String email,
    required final String source,
    required final Color sourceColor,
    required final String assignedTo,
    required final String status,
    required final Color statusColor,
    required final String lastActivity,
  }) = _$CrmLeadEntityImpl;

  @override
  int get sno;
  @override
  String get leadNumber;
  @override
  String get customerName;
  @override
  String get phone;
  @override
  String get email;
  @override
  String get source;
  @override
  Color get sourceColor;
  @override
  String get assignedTo;
  @override
  String get status;
  @override
  Color get statusColor;
  @override
  String get lastActivity;

  /// Create a copy of CrmLeadEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CrmLeadEntityImplCopyWith<_$CrmLeadEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CrmTaskEntity {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get assignedTo => throw _privateConstructorUsedError;
  String get dueDate => throw _privateConstructorUsedError;
  String get priority => throw _privateConstructorUsedError;
  Color get priorityColor => throw _privateConstructorUsedError;
  bool get isDone => throw _privateConstructorUsedError;

  /// Create a copy of CrmTaskEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CrmTaskEntityCopyWith<CrmTaskEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CrmTaskEntityCopyWith<$Res> {
  factory $CrmTaskEntityCopyWith(
    CrmTaskEntity value,
    $Res Function(CrmTaskEntity) then,
  ) = _$CrmTaskEntityCopyWithImpl<$Res, CrmTaskEntity>;
  @useResult
  $Res call({
    String id,
    String title,
    String assignedTo,
    String dueDate,
    String priority,
    Color priorityColor,
    bool isDone,
  });
}

/// @nodoc
class _$CrmTaskEntityCopyWithImpl<$Res, $Val extends CrmTaskEntity>
    implements $CrmTaskEntityCopyWith<$Res> {
  _$CrmTaskEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CrmTaskEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? assignedTo = null,
    Object? dueDate = null,
    Object? priority = null,
    Object? priorityColor = null,
    Object? isDone = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            assignedTo: null == assignedTo
                ? _value.assignedTo
                : assignedTo // ignore: cast_nullable_to_non_nullable
                      as String,
            dueDate: null == dueDate
                ? _value.dueDate
                : dueDate // ignore: cast_nullable_to_non_nullable
                      as String,
            priority: null == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                      as String,
            priorityColor: null == priorityColor
                ? _value.priorityColor
                : priorityColor // ignore: cast_nullable_to_non_nullable
                      as Color,
            isDone: null == isDone
                ? _value.isDone
                : isDone // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CrmTaskEntityImplCopyWith<$Res>
    implements $CrmTaskEntityCopyWith<$Res> {
  factory _$$CrmTaskEntityImplCopyWith(
    _$CrmTaskEntityImpl value,
    $Res Function(_$CrmTaskEntityImpl) then,
  ) = __$$CrmTaskEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String assignedTo,
    String dueDate,
    String priority,
    Color priorityColor,
    bool isDone,
  });
}

/// @nodoc
class __$$CrmTaskEntityImplCopyWithImpl<$Res>
    extends _$CrmTaskEntityCopyWithImpl<$Res, _$CrmTaskEntityImpl>
    implements _$$CrmTaskEntityImplCopyWith<$Res> {
  __$$CrmTaskEntityImplCopyWithImpl(
    _$CrmTaskEntityImpl _value,
    $Res Function(_$CrmTaskEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CrmTaskEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? assignedTo = null,
    Object? dueDate = null,
    Object? priority = null,
    Object? priorityColor = null,
    Object? isDone = null,
  }) {
    return _then(
      _$CrmTaskEntityImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        assignedTo: null == assignedTo
            ? _value.assignedTo
            : assignedTo // ignore: cast_nullable_to_non_nullable
                  as String,
        dueDate: null == dueDate
            ? _value.dueDate
            : dueDate // ignore: cast_nullable_to_non_nullable
                  as String,
        priority: null == priority
            ? _value.priority
            : priority // ignore: cast_nullable_to_non_nullable
                  as String,
        priorityColor: null == priorityColor
            ? _value.priorityColor
            : priorityColor // ignore: cast_nullable_to_non_nullable
                  as Color,
        isDone: null == isDone
            ? _value.isDone
            : isDone // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$CrmTaskEntityImpl implements _CrmTaskEntity {
  const _$CrmTaskEntityImpl({
    required this.id,
    required this.title,
    required this.assignedTo,
    required this.dueDate,
    required this.priority,
    required this.priorityColor,
    this.isDone = false,
  });

  @override
  final String id;
  @override
  final String title;
  @override
  final String assignedTo;
  @override
  final String dueDate;
  @override
  final String priority;
  @override
  final Color priorityColor;
  @override
  @JsonKey()
  final bool isDone;

  @override
  String toString() {
    return 'CrmTaskEntity(id: $id, title: $title, assignedTo: $assignedTo, dueDate: $dueDate, priority: $priority, priorityColor: $priorityColor, isDone: $isDone)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CrmTaskEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.assignedTo, assignedTo) ||
                other.assignedTo == assignedTo) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.priorityColor, priorityColor) ||
                other.priorityColor == priorityColor) &&
            (identical(other.isDone, isDone) || other.isDone == isDone));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    assignedTo,
    dueDate,
    priority,
    priorityColor,
    isDone,
  );

  /// Create a copy of CrmTaskEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CrmTaskEntityImplCopyWith<_$CrmTaskEntityImpl> get copyWith =>
      __$$CrmTaskEntityImplCopyWithImpl<_$CrmTaskEntityImpl>(this, _$identity);
}

abstract class _CrmTaskEntity implements CrmTaskEntity {
  const factory _CrmTaskEntity({
    required final String id,
    required final String title,
    required final String assignedTo,
    required final String dueDate,
    required final String priority,
    required final Color priorityColor,
    final bool isDone,
  }) = _$CrmTaskEntityImpl;

  @override
  String get id;
  @override
  String get title;
  @override
  String get assignedTo;
  @override
  String get dueDate;
  @override
  String get priority;
  @override
  Color get priorityColor;
  @override
  bool get isDone;

  /// Create a copy of CrmTaskEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CrmTaskEntityImplCopyWith<_$CrmTaskEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CrmTrendPoint {
  String get month => throw _privateConstructorUsedError;
  double get won => throw _privateConstructorUsedError;
  double get lost => throw _privateConstructorUsedError;
  double get active => throw _privateConstructorUsedError;

  /// Create a copy of CrmTrendPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CrmTrendPointCopyWith<CrmTrendPoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CrmTrendPointCopyWith<$Res> {
  factory $CrmTrendPointCopyWith(
    CrmTrendPoint value,
    $Res Function(CrmTrendPoint) then,
  ) = _$CrmTrendPointCopyWithImpl<$Res, CrmTrendPoint>;
  @useResult
  $Res call({String month, double won, double lost, double active});
}

/// @nodoc
class _$CrmTrendPointCopyWithImpl<$Res, $Val extends CrmTrendPoint>
    implements $CrmTrendPointCopyWith<$Res> {
  _$CrmTrendPointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CrmTrendPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? month = null,
    Object? won = null,
    Object? lost = null,
    Object? active = null,
  }) {
    return _then(
      _value.copyWith(
            month: null == month
                ? _value.month
                : month // ignore: cast_nullable_to_non_nullable
                      as String,
            won: null == won
                ? _value.won
                : won // ignore: cast_nullable_to_non_nullable
                      as double,
            lost: null == lost
                ? _value.lost
                : lost // ignore: cast_nullable_to_non_nullable
                      as double,
            active: null == active
                ? _value.active
                : active // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CrmTrendPointImplCopyWith<$Res>
    implements $CrmTrendPointCopyWith<$Res> {
  factory _$$CrmTrendPointImplCopyWith(
    _$CrmTrendPointImpl value,
    $Res Function(_$CrmTrendPointImpl) then,
  ) = __$$CrmTrendPointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String month, double won, double lost, double active});
}

/// @nodoc
class __$$CrmTrendPointImplCopyWithImpl<$Res>
    extends _$CrmTrendPointCopyWithImpl<$Res, _$CrmTrendPointImpl>
    implements _$$CrmTrendPointImplCopyWith<$Res> {
  __$$CrmTrendPointImplCopyWithImpl(
    _$CrmTrendPointImpl _value,
    $Res Function(_$CrmTrendPointImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CrmTrendPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? month = null,
    Object? won = null,
    Object? lost = null,
    Object? active = null,
  }) {
    return _then(
      _$CrmTrendPointImpl(
        null == month
            ? _value.month
            : month // ignore: cast_nullable_to_non_nullable
                  as String,
        null == won
            ? _value.won
            : won // ignore: cast_nullable_to_non_nullable
                  as double,
        null == lost
            ? _value.lost
            : lost // ignore: cast_nullable_to_non_nullable
                  as double,
        null == active
            ? _value.active
            : active // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc

class _$CrmTrendPointImpl implements _CrmTrendPoint {
  const _$CrmTrendPointImpl(this.month, this.won, this.lost, this.active);

  @override
  final String month;
  @override
  final double won;
  @override
  final double lost;
  @override
  final double active;

  @override
  String toString() {
    return 'CrmTrendPoint(month: $month, won: $won, lost: $lost, active: $active)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CrmTrendPointImpl &&
            (identical(other.month, month) || other.month == month) &&
            (identical(other.won, won) || other.won == won) &&
            (identical(other.lost, lost) || other.lost == lost) &&
            (identical(other.active, active) || other.active == active));
  }

  @override
  int get hashCode => Object.hash(runtimeType, month, won, lost, active);

  /// Create a copy of CrmTrendPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CrmTrendPointImplCopyWith<_$CrmTrendPointImpl> get copyWith =>
      __$$CrmTrendPointImplCopyWithImpl<_$CrmTrendPointImpl>(this, _$identity);
}

abstract class _CrmTrendPoint implements CrmTrendPoint {
  const factory _CrmTrendPoint(
    final String month,
    final double won,
    final double lost,
    final double active,
  ) = _$CrmTrendPointImpl;

  @override
  String get month;
  @override
  double get won;
  @override
  double get lost;
  @override
  double get active;

  /// Create a copy of CrmTrendPoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CrmTrendPointImplCopyWith<_$CrmTrendPointImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SalespersonPerf {
  String get name => throw _privateConstructorUsedError;
  double get leads => throw _privateConstructorUsedError;
  double get won => throw _privateConstructorUsedError;

  /// Create a copy of SalespersonPerf
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SalespersonPerfCopyWith<SalespersonPerf> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SalespersonPerfCopyWith<$Res> {
  factory $SalespersonPerfCopyWith(
    SalespersonPerf value,
    $Res Function(SalespersonPerf) then,
  ) = _$SalespersonPerfCopyWithImpl<$Res, SalespersonPerf>;
  @useResult
  $Res call({String name, double leads, double won});
}

/// @nodoc
class _$SalespersonPerfCopyWithImpl<$Res, $Val extends SalespersonPerf>
    implements $SalespersonPerfCopyWith<$Res> {
  _$SalespersonPerfCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SalespersonPerf
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? leads = null, Object? won = null}) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            leads: null == leads
                ? _value.leads
                : leads // ignore: cast_nullable_to_non_nullable
                      as double,
            won: null == won
                ? _value.won
                : won // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SalespersonPerfImplCopyWith<$Res>
    implements $SalespersonPerfCopyWith<$Res> {
  factory _$$SalespersonPerfImplCopyWith(
    _$SalespersonPerfImpl value,
    $Res Function(_$SalespersonPerfImpl) then,
  ) = __$$SalespersonPerfImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, double leads, double won});
}

/// @nodoc
class __$$SalespersonPerfImplCopyWithImpl<$Res>
    extends _$SalespersonPerfCopyWithImpl<$Res, _$SalespersonPerfImpl>
    implements _$$SalespersonPerfImplCopyWith<$Res> {
  __$$SalespersonPerfImplCopyWithImpl(
    _$SalespersonPerfImpl _value,
    $Res Function(_$SalespersonPerfImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SalespersonPerf
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? leads = null, Object? won = null}) {
    return _then(
      _$SalespersonPerfImpl(
        null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        null == leads
            ? _value.leads
            : leads // ignore: cast_nullable_to_non_nullable
                  as double,
        null == won
            ? _value.won
            : won // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc

class _$SalespersonPerfImpl implements _SalespersonPerf {
  const _$SalespersonPerfImpl(this.name, this.leads, this.won);

  @override
  final String name;
  @override
  final double leads;
  @override
  final double won;

  @override
  String toString() {
    return 'SalespersonPerf(name: $name, leads: $leads, won: $won)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SalespersonPerfImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.leads, leads) || other.leads == leads) &&
            (identical(other.won, won) || other.won == won));
  }

  @override
  int get hashCode => Object.hash(runtimeType, name, leads, won);

  /// Create a copy of SalespersonPerf
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SalespersonPerfImplCopyWith<_$SalespersonPerfImpl> get copyWith =>
      __$$SalespersonPerfImplCopyWithImpl<_$SalespersonPerfImpl>(
        this,
        _$identity,
      );
}

abstract class _SalespersonPerf implements SalespersonPerf {
  const factory _SalespersonPerf(
    final String name,
    final double leads,
    final double won,
  ) = _$SalespersonPerfImpl;

  @override
  String get name;
  @override
  double get leads;
  @override
  double get won;

  /// Create a copy of SalespersonPerf
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SalespersonPerfImplCopyWith<_$SalespersonPerfImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ResponseTimeBucket {
  String get label => throw _privateConstructorUsedError;
  double get count => throw _privateConstructorUsedError;

  /// Create a copy of ResponseTimeBucket
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ResponseTimeBucketCopyWith<ResponseTimeBucket> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResponseTimeBucketCopyWith<$Res> {
  factory $ResponseTimeBucketCopyWith(
    ResponseTimeBucket value,
    $Res Function(ResponseTimeBucket) then,
  ) = _$ResponseTimeBucketCopyWithImpl<$Res, ResponseTimeBucket>;
  @useResult
  $Res call({String label, double count});
}

/// @nodoc
class _$ResponseTimeBucketCopyWithImpl<$Res, $Val extends ResponseTimeBucket>
    implements $ResponseTimeBucketCopyWith<$Res> {
  _$ResponseTimeBucketCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ResponseTimeBucket
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? label = null, Object? count = null}) {
    return _then(
      _value.copyWith(
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            count: null == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ResponseTimeBucketImplCopyWith<$Res>
    implements $ResponseTimeBucketCopyWith<$Res> {
  factory _$$ResponseTimeBucketImplCopyWith(
    _$ResponseTimeBucketImpl value,
    $Res Function(_$ResponseTimeBucketImpl) then,
  ) = __$$ResponseTimeBucketImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String label, double count});
}

/// @nodoc
class __$$ResponseTimeBucketImplCopyWithImpl<$Res>
    extends _$ResponseTimeBucketCopyWithImpl<$Res, _$ResponseTimeBucketImpl>
    implements _$$ResponseTimeBucketImplCopyWith<$Res> {
  __$$ResponseTimeBucketImplCopyWithImpl(
    _$ResponseTimeBucketImpl _value,
    $Res Function(_$ResponseTimeBucketImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ResponseTimeBucket
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? label = null, Object? count = null}) {
    return _then(
      _$ResponseTimeBucketImpl(
        null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        null == count
            ? _value.count
            : count // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc

class _$ResponseTimeBucketImpl implements _ResponseTimeBucket {
  const _$ResponseTimeBucketImpl(this.label, this.count);

  @override
  final String label;
  @override
  final double count;

  @override
  String toString() {
    return 'ResponseTimeBucket(label: $label, count: $count)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResponseTimeBucketImpl &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.count, count) || other.count == count));
  }

  @override
  int get hashCode => Object.hash(runtimeType, label, count);

  /// Create a copy of ResponseTimeBucket
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ResponseTimeBucketImplCopyWith<_$ResponseTimeBucketImpl> get copyWith =>
      __$$ResponseTimeBucketImplCopyWithImpl<_$ResponseTimeBucketImpl>(
        this,
        _$identity,
      );
}

abstract class _ResponseTimeBucket implements ResponseTimeBucket {
  const factory _ResponseTimeBucket(final String label, final double count) =
      _$ResponseTimeBucketImpl;

  @override
  String get label;
  @override
  double get count;

  /// Create a copy of ResponseTimeBucket
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ResponseTimeBucketImplCopyWith<_$ResponseTimeBucketImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$LeadSourceSlice {
  String get label => throw _privateConstructorUsedError;
  double get percent => throw _privateConstructorUsedError;
  Color get color => throw _privateConstructorUsedError;

  /// Create a copy of LeadSourceSlice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeadSourceSliceCopyWith<LeadSourceSlice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeadSourceSliceCopyWith<$Res> {
  factory $LeadSourceSliceCopyWith(
    LeadSourceSlice value,
    $Res Function(LeadSourceSlice) then,
  ) = _$LeadSourceSliceCopyWithImpl<$Res, LeadSourceSlice>;
  @useResult
  $Res call({String label, double percent, Color color});
}

/// @nodoc
class _$LeadSourceSliceCopyWithImpl<$Res, $Val extends LeadSourceSlice>
    implements $LeadSourceSliceCopyWith<$Res> {
  _$LeadSourceSliceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LeadSourceSlice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? percent = null,
    Object? color = null,
  }) {
    return _then(
      _value.copyWith(
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            percent: null == percent
                ? _value.percent
                : percent // ignore: cast_nullable_to_non_nullable
                      as double,
            color: null == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as Color,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LeadSourceSliceImplCopyWith<$Res>
    implements $LeadSourceSliceCopyWith<$Res> {
  factory _$$LeadSourceSliceImplCopyWith(
    _$LeadSourceSliceImpl value,
    $Res Function(_$LeadSourceSliceImpl) then,
  ) = __$$LeadSourceSliceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String label, double percent, Color color});
}

/// @nodoc
class __$$LeadSourceSliceImplCopyWithImpl<$Res>
    extends _$LeadSourceSliceCopyWithImpl<$Res, _$LeadSourceSliceImpl>
    implements _$$LeadSourceSliceImplCopyWith<$Res> {
  __$$LeadSourceSliceImplCopyWithImpl(
    _$LeadSourceSliceImpl _value,
    $Res Function(_$LeadSourceSliceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LeadSourceSlice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? percent = null,
    Object? color = null,
  }) {
    return _then(
      _$LeadSourceSliceImpl(
        null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        null == percent
            ? _value.percent
            : percent // ignore: cast_nullable_to_non_nullable
                  as double,
        null == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as Color,
      ),
    );
  }
}

/// @nodoc

class _$LeadSourceSliceImpl implements _LeadSourceSlice {
  const _$LeadSourceSliceImpl(this.label, this.percent, this.color);

  @override
  final String label;
  @override
  final double percent;
  @override
  final Color color;

  @override
  String toString() {
    return 'LeadSourceSlice(label: $label, percent: $percent, color: $color)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeadSourceSliceImpl &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.percent, percent) || other.percent == percent) &&
            (identical(other.color, color) || other.color == color));
  }

  @override
  int get hashCode => Object.hash(runtimeType, label, percent, color);

  /// Create a copy of LeadSourceSlice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeadSourceSliceImplCopyWith<_$LeadSourceSliceImpl> get copyWith =>
      __$$LeadSourceSliceImplCopyWithImpl<_$LeadSourceSliceImpl>(
        this,
        _$identity,
      );
}

abstract class _LeadSourceSlice implements LeadSourceSlice {
  const factory _LeadSourceSlice(
    final String label,
    final double percent,
    final Color color,
  ) = _$LeadSourceSliceImpl;

  @override
  String get label;
  @override
  double get percent;
  @override
  Color get color;

  /// Create a copy of LeadSourceSlice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeadSourceSliceImplCopyWith<_$LeadSourceSliceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CrmKeyMetric {
  String get label => throw _privateConstructorUsedError;
  String get value => throw _privateConstructorUsedError;
  String get sub => throw _privateConstructorUsedError;
  bool get up => throw _privateConstructorUsedError;
  Color get color => throw _privateConstructorUsedError;

  /// Create a copy of CrmKeyMetric
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CrmKeyMetricCopyWith<CrmKeyMetric> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CrmKeyMetricCopyWith<$Res> {
  factory $CrmKeyMetricCopyWith(
    CrmKeyMetric value,
    $Res Function(CrmKeyMetric) then,
  ) = _$CrmKeyMetricCopyWithImpl<$Res, CrmKeyMetric>;
  @useResult
  $Res call({String label, String value, String sub, bool up, Color color});
}

/// @nodoc
class _$CrmKeyMetricCopyWithImpl<$Res, $Val extends CrmKeyMetric>
    implements $CrmKeyMetricCopyWith<$Res> {
  _$CrmKeyMetricCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CrmKeyMetric
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? value = null,
    Object? sub = null,
    Object? up = null,
    Object? color = null,
  }) {
    return _then(
      _value.copyWith(
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            value: null == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                      as String,
            sub: null == sub
                ? _value.sub
                : sub // ignore: cast_nullable_to_non_nullable
                      as String,
            up: null == up
                ? _value.up
                : up // ignore: cast_nullable_to_non_nullable
                      as bool,
            color: null == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as Color,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CrmKeyMetricImplCopyWith<$Res>
    implements $CrmKeyMetricCopyWith<$Res> {
  factory _$$CrmKeyMetricImplCopyWith(
    _$CrmKeyMetricImpl value,
    $Res Function(_$CrmKeyMetricImpl) then,
  ) = __$$CrmKeyMetricImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String label, String value, String sub, bool up, Color color});
}

/// @nodoc
class __$$CrmKeyMetricImplCopyWithImpl<$Res>
    extends _$CrmKeyMetricCopyWithImpl<$Res, _$CrmKeyMetricImpl>
    implements _$$CrmKeyMetricImplCopyWith<$Res> {
  __$$CrmKeyMetricImplCopyWithImpl(
    _$CrmKeyMetricImpl _value,
    $Res Function(_$CrmKeyMetricImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CrmKeyMetric
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? value = null,
    Object? sub = null,
    Object? up = null,
    Object? color = null,
  }) {
    return _then(
      _$CrmKeyMetricImpl(
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        value: null == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                  as String,
        sub: null == sub
            ? _value.sub
            : sub // ignore: cast_nullable_to_non_nullable
                  as String,
        up: null == up
            ? _value.up
            : up // ignore: cast_nullable_to_non_nullable
                  as bool,
        color: null == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as Color,
      ),
    );
  }
}

/// @nodoc

class _$CrmKeyMetricImpl implements _CrmKeyMetric {
  const _$CrmKeyMetricImpl({
    required this.label,
    required this.value,
    required this.sub,
    required this.up,
    required this.color,
  });

  @override
  final String label;
  @override
  final String value;
  @override
  final String sub;
  @override
  final bool up;
  @override
  final Color color;

  @override
  String toString() {
    return 'CrmKeyMetric(label: $label, value: $value, sub: $sub, up: $up, color: $color)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CrmKeyMetricImpl &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.sub, sub) || other.sub == sub) &&
            (identical(other.up, up) || other.up == up) &&
            (identical(other.color, color) || other.color == color));
  }

  @override
  int get hashCode => Object.hash(runtimeType, label, value, sub, up, color);

  /// Create a copy of CrmKeyMetric
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CrmKeyMetricImplCopyWith<_$CrmKeyMetricImpl> get copyWith =>
      __$$CrmKeyMetricImplCopyWithImpl<_$CrmKeyMetricImpl>(this, _$identity);
}

abstract class _CrmKeyMetric implements CrmKeyMetric {
  const factory _CrmKeyMetric({
    required final String label,
    required final String value,
    required final String sub,
    required final bool up,
    required final Color color,
  }) = _$CrmKeyMetricImpl;

  @override
  String get label;
  @override
  String get value;
  @override
  String get sub;
  @override
  bool get up;
  @override
  Color get color;

  /// Create a copy of CrmKeyMetric
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CrmKeyMetricImplCopyWith<_$CrmKeyMetricImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$IntegrationEntity {
  String get name => throw _privateConstructorUsedError;
  IconData get icon => throw _privateConstructorUsedError;
  Color get color => throw _privateConstructorUsedError;
  bool get connected => throw _privateConstructorUsedError;

  /// Create a copy of IntegrationEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $IntegrationEntityCopyWith<IntegrationEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IntegrationEntityCopyWith<$Res> {
  factory $IntegrationEntityCopyWith(
    IntegrationEntity value,
    $Res Function(IntegrationEntity) then,
  ) = _$IntegrationEntityCopyWithImpl<$Res, IntegrationEntity>;
  @useResult
  $Res call({String name, IconData icon, Color color, bool connected});
}

/// @nodoc
class _$IntegrationEntityCopyWithImpl<$Res, $Val extends IntegrationEntity>
    implements $IntegrationEntityCopyWith<$Res> {
  _$IntegrationEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of IntegrationEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? icon = null,
    Object? color = null,
    Object? connected = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            icon: null == icon
                ? _value.icon
                : icon // ignore: cast_nullable_to_non_nullable
                      as IconData,
            color: null == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as Color,
            connected: null == connected
                ? _value.connected
                : connected // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$IntegrationEntityImplCopyWith<$Res>
    implements $IntegrationEntityCopyWith<$Res> {
  factory _$$IntegrationEntityImplCopyWith(
    _$IntegrationEntityImpl value,
    $Res Function(_$IntegrationEntityImpl) then,
  ) = __$$IntegrationEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, IconData icon, Color color, bool connected});
}

/// @nodoc
class __$$IntegrationEntityImplCopyWithImpl<$Res>
    extends _$IntegrationEntityCopyWithImpl<$Res, _$IntegrationEntityImpl>
    implements _$$IntegrationEntityImplCopyWith<$Res> {
  __$$IntegrationEntityImplCopyWithImpl(
    _$IntegrationEntityImpl _value,
    $Res Function(_$IntegrationEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of IntegrationEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? icon = null,
    Object? color = null,
    Object? connected = null,
  }) {
    return _then(
      _$IntegrationEntityImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        icon: null == icon
            ? _value.icon
            : icon // ignore: cast_nullable_to_non_nullable
                  as IconData,
        color: null == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as Color,
        connected: null == connected
            ? _value.connected
            : connected // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$IntegrationEntityImpl implements _IntegrationEntity {
  const _$IntegrationEntityImpl({
    required this.name,
    required this.icon,
    required this.color,
    required this.connected,
  });

  @override
  final String name;
  @override
  final IconData icon;
  @override
  final Color color;
  @override
  final bool connected;

  @override
  String toString() {
    return 'IntegrationEntity(name: $name, icon: $icon, color: $color, connected: $connected)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IntegrationEntityImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.connected, connected) ||
                other.connected == connected));
  }

  @override
  int get hashCode => Object.hash(runtimeType, name, icon, color, connected);

  /// Create a copy of IntegrationEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IntegrationEntityImplCopyWith<_$IntegrationEntityImpl> get copyWith =>
      __$$IntegrationEntityImplCopyWithImpl<_$IntegrationEntityImpl>(
        this,
        _$identity,
      );
}

abstract class _IntegrationEntity implements IntegrationEntity {
  const factory _IntegrationEntity({
    required final String name,
    required final IconData icon,
    required final Color color,
    required final bool connected,
  }) = _$IntegrationEntityImpl;

  @override
  String get name;
  @override
  IconData get icon;
  @override
  Color get color;
  @override
  bool get connected;

  /// Create a copy of IntegrationEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IntegrationEntityImplCopyWith<_$IntegrationEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SalesTeamMember {
  String get name => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;
  int get leadsHandled => throw _privateConstructorUsedError;
  int get wonDeals => throw _privateConstructorUsedError;
  String get revenue => throw _privateConstructorUsedError;
  double get winRate => throw _privateConstructorUsedError;

  /// Create a copy of SalesTeamMember
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SalesTeamMemberCopyWith<SalesTeamMember> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SalesTeamMemberCopyWith<$Res> {
  factory $SalesTeamMemberCopyWith(
    SalesTeamMember value,
    $Res Function(SalesTeamMember) then,
  ) = _$SalesTeamMemberCopyWithImpl<$Res, SalesTeamMember>;
  @useResult
  $Res call({
    String name,
    String role,
    int leadsHandled,
    int wonDeals,
    String revenue,
    double winRate,
  });
}

/// @nodoc
class _$SalesTeamMemberCopyWithImpl<$Res, $Val extends SalesTeamMember>
    implements $SalesTeamMemberCopyWith<$Res> {
  _$SalesTeamMemberCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SalesTeamMember
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? role = null,
    Object? leadsHandled = null,
    Object? wonDeals = null,
    Object? revenue = null,
    Object? winRate = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String,
            leadsHandled: null == leadsHandled
                ? _value.leadsHandled
                : leadsHandled // ignore: cast_nullable_to_non_nullable
                      as int,
            wonDeals: null == wonDeals
                ? _value.wonDeals
                : wonDeals // ignore: cast_nullable_to_non_nullable
                      as int,
            revenue: null == revenue
                ? _value.revenue
                : revenue // ignore: cast_nullable_to_non_nullable
                      as String,
            winRate: null == winRate
                ? _value.winRate
                : winRate // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SalesTeamMemberImplCopyWith<$Res>
    implements $SalesTeamMemberCopyWith<$Res> {
  factory _$$SalesTeamMemberImplCopyWith(
    _$SalesTeamMemberImpl value,
    $Res Function(_$SalesTeamMemberImpl) then,
  ) = __$$SalesTeamMemberImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    String role,
    int leadsHandled,
    int wonDeals,
    String revenue,
    double winRate,
  });
}

/// @nodoc
class __$$SalesTeamMemberImplCopyWithImpl<$Res>
    extends _$SalesTeamMemberCopyWithImpl<$Res, _$SalesTeamMemberImpl>
    implements _$$SalesTeamMemberImplCopyWith<$Res> {
  __$$SalesTeamMemberImplCopyWithImpl(
    _$SalesTeamMemberImpl _value,
    $Res Function(_$SalesTeamMemberImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SalesTeamMember
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? role = null,
    Object? leadsHandled = null,
    Object? wonDeals = null,
    Object? revenue = null,
    Object? winRate = null,
  }) {
    return _then(
      _$SalesTeamMemberImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String,
        leadsHandled: null == leadsHandled
            ? _value.leadsHandled
            : leadsHandled // ignore: cast_nullable_to_non_nullable
                  as int,
        wonDeals: null == wonDeals
            ? _value.wonDeals
            : wonDeals // ignore: cast_nullable_to_non_nullable
                  as int,
        revenue: null == revenue
            ? _value.revenue
            : revenue // ignore: cast_nullable_to_non_nullable
                  as String,
        winRate: null == winRate
            ? _value.winRate
            : winRate // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc

class _$SalesTeamMemberImpl implements _SalesTeamMember {
  const _$SalesTeamMemberImpl({
    required this.name,
    required this.role,
    required this.leadsHandled,
    required this.wonDeals,
    required this.revenue,
    required this.winRate,
  });

  @override
  final String name;
  @override
  final String role;
  @override
  final int leadsHandled;
  @override
  final int wonDeals;
  @override
  final String revenue;
  @override
  final double winRate;

  @override
  String toString() {
    return 'SalesTeamMember(name: $name, role: $role, leadsHandled: $leadsHandled, wonDeals: $wonDeals, revenue: $revenue, winRate: $winRate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SalesTeamMemberImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.leadsHandled, leadsHandled) ||
                other.leadsHandled == leadsHandled) &&
            (identical(other.wonDeals, wonDeals) ||
                other.wonDeals == wonDeals) &&
            (identical(other.revenue, revenue) || other.revenue == revenue) &&
            (identical(other.winRate, winRate) || other.winRate == winRate));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    role,
    leadsHandled,
    wonDeals,
    revenue,
    winRate,
  );

  /// Create a copy of SalesTeamMember
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SalesTeamMemberImplCopyWith<_$SalesTeamMemberImpl> get copyWith =>
      __$$SalesTeamMemberImplCopyWithImpl<_$SalesTeamMemberImpl>(
        this,
        _$identity,
      );
}

abstract class _SalesTeamMember implements SalesTeamMember {
  const factory _SalesTeamMember({
    required final String name,
    required final String role,
    required final int leadsHandled,
    required final int wonDeals,
    required final String revenue,
    required final double winRate,
  }) = _$SalesTeamMemberImpl;

  @override
  String get name;
  @override
  String get role;
  @override
  int get leadsHandled;
  @override
  int get wonDeals;
  @override
  String get revenue;
  @override
  double get winRate;

  /// Create a copy of SalesTeamMember
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SalesTeamMemberImplCopyWith<_$SalesTeamMemberImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ConversationEntity {
  String get id => throw _privateConstructorUsedError;
  String get customerName => throw _privateConstructorUsedError;
  String get lastMessage => throw _privateConstructorUsedError;
  String get time => throw _privateConstructorUsedError;
  String get channel => throw _privateConstructorUsedError;
  Color get channelColor => throw _privateConstructorUsedError;
  int get unread => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;

  /// Create a copy of ConversationEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConversationEntityCopyWith<ConversationEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConversationEntityCopyWith<$Res> {
  factory $ConversationEntityCopyWith(
    ConversationEntity value,
    $Res Function(ConversationEntity) then,
  ) = _$ConversationEntityCopyWithImpl<$Res, ConversationEntity>;
  @useResult
  $Res call({
    String id,
    String customerName,
    String lastMessage,
    String time,
    String channel,
    Color channelColor,
    int unread,
    String status,
  });
}

/// @nodoc
class _$ConversationEntityCopyWithImpl<$Res, $Val extends ConversationEntity>
    implements $ConversationEntityCopyWith<$Res> {
  _$ConversationEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConversationEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerName = null,
    Object? lastMessage = null,
    Object? time = null,
    Object? channel = null,
    Object? channelColor = null,
    Object? unread = null,
    Object? status = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            customerName: null == customerName
                ? _value.customerName
                : customerName // ignore: cast_nullable_to_non_nullable
                      as String,
            lastMessage: null == lastMessage
                ? _value.lastMessage
                : lastMessage // ignore: cast_nullable_to_non_nullable
                      as String,
            time: null == time
                ? _value.time
                : time // ignore: cast_nullable_to_non_nullable
                      as String,
            channel: null == channel
                ? _value.channel
                : channel // ignore: cast_nullable_to_non_nullable
                      as String,
            channelColor: null == channelColor
                ? _value.channelColor
                : channelColor // ignore: cast_nullable_to_non_nullable
                      as Color,
            unread: null == unread
                ? _value.unread
                : unread // ignore: cast_nullable_to_non_nullable
                      as int,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ConversationEntityImplCopyWith<$Res>
    implements $ConversationEntityCopyWith<$Res> {
  factory _$$ConversationEntityImplCopyWith(
    _$ConversationEntityImpl value,
    $Res Function(_$ConversationEntityImpl) then,
  ) = __$$ConversationEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String customerName,
    String lastMessage,
    String time,
    String channel,
    Color channelColor,
    int unread,
    String status,
  });
}

/// @nodoc
class __$$ConversationEntityImplCopyWithImpl<$Res>
    extends _$ConversationEntityCopyWithImpl<$Res, _$ConversationEntityImpl>
    implements _$$ConversationEntityImplCopyWith<$Res> {
  __$$ConversationEntityImplCopyWithImpl(
    _$ConversationEntityImpl _value,
    $Res Function(_$ConversationEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConversationEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerName = null,
    Object? lastMessage = null,
    Object? time = null,
    Object? channel = null,
    Object? channelColor = null,
    Object? unread = null,
    Object? status = null,
  }) {
    return _then(
      _$ConversationEntityImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        customerName: null == customerName
            ? _value.customerName
            : customerName // ignore: cast_nullable_to_non_nullable
                  as String,
        lastMessage: null == lastMessage
            ? _value.lastMessage
            : lastMessage // ignore: cast_nullable_to_non_nullable
                  as String,
        time: null == time
            ? _value.time
            : time // ignore: cast_nullable_to_non_nullable
                  as String,
        channel: null == channel
            ? _value.channel
            : channel // ignore: cast_nullable_to_non_nullable
                  as String,
        channelColor: null == channelColor
            ? _value.channelColor
            : channelColor // ignore: cast_nullable_to_non_nullable
                  as Color,
        unread: null == unread
            ? _value.unread
            : unread // ignore: cast_nullable_to_non_nullable
                  as int,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$ConversationEntityImpl implements _ConversationEntity {
  const _$ConversationEntityImpl({
    required this.id,
    required this.customerName,
    required this.lastMessage,
    required this.time,
    required this.channel,
    required this.channelColor,
    required this.unread,
    required this.status,
  });

  @override
  final String id;
  @override
  final String customerName;
  @override
  final String lastMessage;
  @override
  final String time;
  @override
  final String channel;
  @override
  final Color channelColor;
  @override
  final int unread;
  @override
  final String status;

  @override
  String toString() {
    return 'ConversationEntity(id: $id, customerName: $customerName, lastMessage: $lastMessage, time: $time, channel: $channel, channelColor: $channelColor, unread: $unread, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConversationEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.lastMessage, lastMessage) ||
                other.lastMessage == lastMessage) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.channel, channel) || other.channel == channel) &&
            (identical(other.channelColor, channelColor) ||
                other.channelColor == channelColor) &&
            (identical(other.unread, unread) || other.unread == unread) &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    customerName,
    lastMessage,
    time,
    channel,
    channelColor,
    unread,
    status,
  );

  /// Create a copy of ConversationEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConversationEntityImplCopyWith<_$ConversationEntityImpl> get copyWith =>
      __$$ConversationEntityImplCopyWithImpl<_$ConversationEntityImpl>(
        this,
        _$identity,
      );
}

abstract class _ConversationEntity implements ConversationEntity {
  const factory _ConversationEntity({
    required final String id,
    required final String customerName,
    required final String lastMessage,
    required final String time,
    required final String channel,
    required final Color channelColor,
    required final int unread,
    required final String status,
  }) = _$ConversationEntityImpl;

  @override
  String get id;
  @override
  String get customerName;
  @override
  String get lastMessage;
  @override
  String get time;
  @override
  String get channel;
  @override
  Color get channelColor;
  @override
  int get unread;
  @override
  String get status;

  /// Create a copy of ConversationEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConversationEntityImplCopyWith<_$ConversationEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CrmNotificationEntity {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  String get time => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  bool get isRead => throw _privateConstructorUsedError;

  /// Create a copy of CrmNotificationEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CrmNotificationEntityCopyWith<CrmNotificationEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CrmNotificationEntityCopyWith<$Res> {
  factory $CrmNotificationEntityCopyWith(
    CrmNotificationEntity value,
    $Res Function(CrmNotificationEntity) then,
  ) = _$CrmNotificationEntityCopyWithImpl<$Res, CrmNotificationEntity>;
  @useResult
  $Res call({
    String id,
    String title,
    String body,
    String time,
    String type,
    bool isRead,
  });
}

/// @nodoc
class _$CrmNotificationEntityCopyWithImpl<
  $Res,
  $Val extends CrmNotificationEntity
>
    implements $CrmNotificationEntityCopyWith<$Res> {
  _$CrmNotificationEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CrmNotificationEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? body = null,
    Object? time = null,
    Object? type = null,
    Object? isRead = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            body: null == body
                ? _value.body
                : body // ignore: cast_nullable_to_non_nullable
                      as String,
            time: null == time
                ? _value.time
                : time // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            isRead: null == isRead
                ? _value.isRead
                : isRead // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CrmNotificationEntityImplCopyWith<$Res>
    implements $CrmNotificationEntityCopyWith<$Res> {
  factory _$$CrmNotificationEntityImplCopyWith(
    _$CrmNotificationEntityImpl value,
    $Res Function(_$CrmNotificationEntityImpl) then,
  ) = __$$CrmNotificationEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String body,
    String time,
    String type,
    bool isRead,
  });
}

/// @nodoc
class __$$CrmNotificationEntityImplCopyWithImpl<$Res>
    extends
        _$CrmNotificationEntityCopyWithImpl<$Res, _$CrmNotificationEntityImpl>
    implements _$$CrmNotificationEntityImplCopyWith<$Res> {
  __$$CrmNotificationEntityImplCopyWithImpl(
    _$CrmNotificationEntityImpl _value,
    $Res Function(_$CrmNotificationEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CrmNotificationEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? body = null,
    Object? time = null,
    Object? type = null,
    Object? isRead = null,
  }) {
    return _then(
      _$CrmNotificationEntityImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        body: null == body
            ? _value.body
            : body // ignore: cast_nullable_to_non_nullable
                  as String,
        time: null == time
            ? _value.time
            : time // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        isRead: null == isRead
            ? _value.isRead
            : isRead // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$CrmNotificationEntityImpl implements _CrmNotificationEntity {
  const _$CrmNotificationEntityImpl({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    this.isRead = false,
  });

  @override
  final String id;
  @override
  final String title;
  @override
  final String body;
  @override
  final String time;
  @override
  final String type;
  @override
  @JsonKey()
  final bool isRead;

  @override
  String toString() {
    return 'CrmNotificationEntity(id: $id, title: $title, body: $body, time: $time, type: $type, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CrmNotificationEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.isRead, isRead) || other.isRead == isRead));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, title, body, time, type, isRead);

  /// Create a copy of CrmNotificationEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CrmNotificationEntityImplCopyWith<_$CrmNotificationEntityImpl>
  get copyWith =>
      __$$CrmNotificationEntityImplCopyWithImpl<_$CrmNotificationEntityImpl>(
        this,
        _$identity,
      );
}

abstract class _CrmNotificationEntity implements CrmNotificationEntity {
  const factory _CrmNotificationEntity({
    required final String id,
    required final String title,
    required final String body,
    required final String time,
    required final String type,
    final bool isRead,
  }) = _$CrmNotificationEntityImpl;

  @override
  String get id;
  @override
  String get title;
  @override
  String get body;
  @override
  String get time;
  @override
  String get type;
  @override
  bool get isRead;

  /// Create a copy of CrmNotificationEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CrmNotificationEntityImplCopyWith<_$CrmNotificationEntityImpl>
  get copyWith => throw _privateConstructorUsedError;
}
