// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'supervisor_entities.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SupervisorKpiEntity {
  IconData get icon => throw _privateConstructorUsedError;
  Color get color => throw _privateConstructorUsedError;
  String get value => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  String get sub => throw _privateConstructorUsedError;

  /// Create a copy of SupervisorKpiEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SupervisorKpiEntityCopyWith<SupervisorKpiEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SupervisorKpiEntityCopyWith<$Res> {
  factory $SupervisorKpiEntityCopyWith(
    SupervisorKpiEntity value,
    $Res Function(SupervisorKpiEntity) then,
  ) = _$SupervisorKpiEntityCopyWithImpl<$Res, SupervisorKpiEntity>;
  @useResult
  $Res call({
    IconData icon,
    Color color,
    String value,
    String label,
    String sub,
  });
}

/// @nodoc
class _$SupervisorKpiEntityCopyWithImpl<$Res, $Val extends SupervisorKpiEntity>
    implements $SupervisorKpiEntityCopyWith<$Res> {
  _$SupervisorKpiEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SupervisorKpiEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? icon = null,
    Object? color = null,
    Object? value = null,
    Object? label = null,
    Object? sub = null,
  }) {
    return _then(
      _value.copyWith(
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
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            sub: null == sub
                ? _value.sub
                : sub // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SupervisorKpiEntityImplCopyWith<$Res>
    implements $SupervisorKpiEntityCopyWith<$Res> {
  factory _$$SupervisorKpiEntityImplCopyWith(
    _$SupervisorKpiEntityImpl value,
    $Res Function(_$SupervisorKpiEntityImpl) then,
  ) = __$$SupervisorKpiEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    IconData icon,
    Color color,
    String value,
    String label,
    String sub,
  });
}

/// @nodoc
class __$$SupervisorKpiEntityImplCopyWithImpl<$Res>
    extends _$SupervisorKpiEntityCopyWithImpl<$Res, _$SupervisorKpiEntityImpl>
    implements _$$SupervisorKpiEntityImplCopyWith<$Res> {
  __$$SupervisorKpiEntityImplCopyWithImpl(
    _$SupervisorKpiEntityImpl _value,
    $Res Function(_$SupervisorKpiEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SupervisorKpiEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? icon = null,
    Object? color = null,
    Object? value = null,
    Object? label = null,
    Object? sub = null,
  }) {
    return _then(
      _$SupervisorKpiEntityImpl(
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
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        sub: null == sub
            ? _value.sub
            : sub // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$SupervisorKpiEntityImpl implements _SupervisorKpiEntity {
  const _$SupervisorKpiEntityImpl({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    required this.sub,
  });

  @override
  final IconData icon;
  @override
  final Color color;
  @override
  final String value;
  @override
  final String label;
  @override
  final String sub;

  @override
  String toString() {
    return 'SupervisorKpiEntity(icon: $icon, color: $color, value: $value, label: $label, sub: $sub)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SupervisorKpiEntityImpl &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.sub, sub) || other.sub == sub));
  }

  @override
  int get hashCode => Object.hash(runtimeType, icon, color, value, label, sub);

  /// Create a copy of SupervisorKpiEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SupervisorKpiEntityImplCopyWith<_$SupervisorKpiEntityImpl> get copyWith =>
      __$$SupervisorKpiEntityImplCopyWithImpl<_$SupervisorKpiEntityImpl>(
        this,
        _$identity,
      );
}

abstract class _SupervisorKpiEntity implements SupervisorKpiEntity {
  const factory _SupervisorKpiEntity({
    required final IconData icon,
    required final Color color,
    required final String value,
    required final String label,
    required final String sub,
  }) = _$SupervisorKpiEntityImpl;

  @override
  IconData get icon;
  @override
  Color get color;
  @override
  String get value;
  @override
  String get label;
  @override
  String get sub;

  /// Create a copy of SupervisorKpiEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SupervisorKpiEntityImplCopyWith<_$SupervisorKpiEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AdvisorJobEntity {
  String get name => throw _privateConstructorUsedError;
  double get count => throw _privateConstructorUsedError;

  /// Create a copy of AdvisorJobEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdvisorJobEntityCopyWith<AdvisorJobEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdvisorJobEntityCopyWith<$Res> {
  factory $AdvisorJobEntityCopyWith(
    AdvisorJobEntity value,
    $Res Function(AdvisorJobEntity) then,
  ) = _$AdvisorJobEntityCopyWithImpl<$Res, AdvisorJobEntity>;
  @useResult
  $Res call({String name, double count});
}

/// @nodoc
class _$AdvisorJobEntityCopyWithImpl<$Res, $Val extends AdvisorJobEntity>
    implements $AdvisorJobEntityCopyWith<$Res> {
  _$AdvisorJobEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AdvisorJobEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? count = null}) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
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
abstract class _$$AdvisorJobEntityImplCopyWith<$Res>
    implements $AdvisorJobEntityCopyWith<$Res> {
  factory _$$AdvisorJobEntityImplCopyWith(
    _$AdvisorJobEntityImpl value,
    $Res Function(_$AdvisorJobEntityImpl) then,
  ) = __$$AdvisorJobEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, double count});
}

/// @nodoc
class __$$AdvisorJobEntityImplCopyWithImpl<$Res>
    extends _$AdvisorJobEntityCopyWithImpl<$Res, _$AdvisorJobEntityImpl>
    implements _$$AdvisorJobEntityImplCopyWith<$Res> {
  __$$AdvisorJobEntityImplCopyWithImpl(
    _$AdvisorJobEntityImpl _value,
    $Res Function(_$AdvisorJobEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AdvisorJobEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? count = null}) {
    return _then(
      _$AdvisorJobEntityImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        count: null == count
            ? _value.count
            : count // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc

class _$AdvisorJobEntityImpl implements _AdvisorJobEntity {
  const _$AdvisorJobEntityImpl({required this.name, required this.count});

  @override
  final String name;
  @override
  final double count;

  @override
  String toString() {
    return 'AdvisorJobEntity(name: $name, count: $count)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdvisorJobEntityImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.count, count) || other.count == count));
  }

  @override
  int get hashCode => Object.hash(runtimeType, name, count);

  /// Create a copy of AdvisorJobEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdvisorJobEntityImplCopyWith<_$AdvisorJobEntityImpl> get copyWith =>
      __$$AdvisorJobEntityImplCopyWithImpl<_$AdvisorJobEntityImpl>(
        this,
        _$identity,
      );
}

abstract class _AdvisorJobEntity implements AdvisorJobEntity {
  const factory _AdvisorJobEntity({
    required final String name,
    required final double count,
  }) = _$AdvisorJobEntityImpl;

  @override
  String get name;
  @override
  double get count;

  /// Create a copy of AdvisorJobEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdvisorJobEntityImplCopyWith<_$AdvisorJobEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$JobTypeEntity {
  String get label => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;
  Color get color => throw _privateConstructorUsedError;

  /// Create a copy of JobTypeEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JobTypeEntityCopyWith<JobTypeEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JobTypeEntityCopyWith<$Res> {
  factory $JobTypeEntityCopyWith(
    JobTypeEntity value,
    $Res Function(JobTypeEntity) then,
  ) = _$JobTypeEntityCopyWithImpl<$Res, JobTypeEntity>;
  @useResult
  $Res call({String label, int count, Color color});
}

/// @nodoc
class _$JobTypeEntityCopyWithImpl<$Res, $Val extends JobTypeEntity>
    implements $JobTypeEntityCopyWith<$Res> {
  _$JobTypeEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of JobTypeEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? count = null,
    Object? color = null,
  }) {
    return _then(
      _value.copyWith(
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            count: null == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                      as int,
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
abstract class _$$JobTypeEntityImplCopyWith<$Res>
    implements $JobTypeEntityCopyWith<$Res> {
  factory _$$JobTypeEntityImplCopyWith(
    _$JobTypeEntityImpl value,
    $Res Function(_$JobTypeEntityImpl) then,
  ) = __$$JobTypeEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String label, int count, Color color});
}

/// @nodoc
class __$$JobTypeEntityImplCopyWithImpl<$Res>
    extends _$JobTypeEntityCopyWithImpl<$Res, _$JobTypeEntityImpl>
    implements _$$JobTypeEntityImplCopyWith<$Res> {
  __$$JobTypeEntityImplCopyWithImpl(
    _$JobTypeEntityImpl _value,
    $Res Function(_$JobTypeEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of JobTypeEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? count = null,
    Object? color = null,
  }) {
    return _then(
      _$JobTypeEntityImpl(
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        count: null == count
            ? _value.count
            : count // ignore: cast_nullable_to_non_nullable
                  as int,
        color: null == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as Color,
      ),
    );
  }
}

/// @nodoc

class _$JobTypeEntityImpl implements _JobTypeEntity {
  const _$JobTypeEntityImpl({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  final String label;
  @override
  final int count;
  @override
  final Color color;

  @override
  String toString() {
    return 'JobTypeEntity(label: $label, count: $count, color: $color)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JobTypeEntityImpl &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.color, color) || other.color == color));
  }

  @override
  int get hashCode => Object.hash(runtimeType, label, count, color);

  /// Create a copy of JobTypeEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JobTypeEntityImplCopyWith<_$JobTypeEntityImpl> get copyWith =>
      __$$JobTypeEntityImplCopyWithImpl<_$JobTypeEntityImpl>(this, _$identity);
}

abstract class _JobTypeEntity implements JobTypeEntity {
  const factory _JobTypeEntity({
    required final String label,
    required final int count,
    required final Color color,
  }) = _$JobTypeEntityImpl;

  @override
  String get label;
  @override
  int get count;
  @override
  Color get color;

  /// Create a copy of JobTypeEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JobTypeEntityImplCopyWith<_$JobTypeEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$RevenueMetricEntity {
  IconData get icon => throw _privateConstructorUsedError;
  String get amount => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  String get change => throw _privateConstructorUsedError;

  /// Create a copy of RevenueMetricEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RevenueMetricEntityCopyWith<RevenueMetricEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RevenueMetricEntityCopyWith<$Res> {
  factory $RevenueMetricEntityCopyWith(
    RevenueMetricEntity value,
    $Res Function(RevenueMetricEntity) then,
  ) = _$RevenueMetricEntityCopyWithImpl<$Res, RevenueMetricEntity>;
  @useResult
  $Res call({IconData icon, String amount, String label, String change});
}

/// @nodoc
class _$RevenueMetricEntityCopyWithImpl<$Res, $Val extends RevenueMetricEntity>
    implements $RevenueMetricEntityCopyWith<$Res> {
  _$RevenueMetricEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RevenueMetricEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? icon = null,
    Object? amount = null,
    Object? label = null,
    Object? change = null,
  }) {
    return _then(
      _value.copyWith(
            icon: null == icon
                ? _value.icon
                : icon // ignore: cast_nullable_to_non_nullable
                      as IconData,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as String,
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            change: null == change
                ? _value.change
                : change // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RevenueMetricEntityImplCopyWith<$Res>
    implements $RevenueMetricEntityCopyWith<$Res> {
  factory _$$RevenueMetricEntityImplCopyWith(
    _$RevenueMetricEntityImpl value,
    $Res Function(_$RevenueMetricEntityImpl) then,
  ) = __$$RevenueMetricEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({IconData icon, String amount, String label, String change});
}

/// @nodoc
class __$$RevenueMetricEntityImplCopyWithImpl<$Res>
    extends _$RevenueMetricEntityCopyWithImpl<$Res, _$RevenueMetricEntityImpl>
    implements _$$RevenueMetricEntityImplCopyWith<$Res> {
  __$$RevenueMetricEntityImplCopyWithImpl(
    _$RevenueMetricEntityImpl _value,
    $Res Function(_$RevenueMetricEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RevenueMetricEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? icon = null,
    Object? amount = null,
    Object? label = null,
    Object? change = null,
  }) {
    return _then(
      _$RevenueMetricEntityImpl(
        icon: null == icon
            ? _value.icon
            : icon // ignore: cast_nullable_to_non_nullable
                  as IconData,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as String,
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        change: null == change
            ? _value.change
            : change // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$RevenueMetricEntityImpl implements _RevenueMetricEntity {
  const _$RevenueMetricEntityImpl({
    required this.icon,
    required this.amount,
    required this.label,
    required this.change,
  });

  @override
  final IconData icon;
  @override
  final String amount;
  @override
  final String label;
  @override
  final String change;

  @override
  String toString() {
    return 'RevenueMetricEntity(icon: $icon, amount: $amount, label: $label, change: $change)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RevenueMetricEntityImpl &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.change, change) || other.change == change));
  }

  @override
  int get hashCode => Object.hash(runtimeType, icon, amount, label, change);

  /// Create a copy of RevenueMetricEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RevenueMetricEntityImplCopyWith<_$RevenueMetricEntityImpl> get copyWith =>
      __$$RevenueMetricEntityImplCopyWithImpl<_$RevenueMetricEntityImpl>(
        this,
        _$identity,
      );
}

abstract class _RevenueMetricEntity implements RevenueMetricEntity {
  const factory _RevenueMetricEntity({
    required final IconData icon,
    required final String amount,
    required final String label,
    required final String change,
  }) = _$RevenueMetricEntityImpl;

  @override
  IconData get icon;
  @override
  String get amount;
  @override
  String get label;
  @override
  String get change;

  /// Create a copy of RevenueMetricEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RevenueMetricEntityImplCopyWith<_$RevenueMetricEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$PendingStatusEntity {
  IconData get icon => throw _privateConstructorUsedError;
  Color get color => throw _privateConstructorUsedError;
  String get count => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;

  /// Create a copy of PendingStatusEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PendingStatusEntityCopyWith<PendingStatusEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PendingStatusEntityCopyWith<$Res> {
  factory $PendingStatusEntityCopyWith(
    PendingStatusEntity value,
    $Res Function(PendingStatusEntity) then,
  ) = _$PendingStatusEntityCopyWithImpl<$Res, PendingStatusEntity>;
  @useResult
  $Res call({IconData icon, Color color, String count, String label});
}

/// @nodoc
class _$PendingStatusEntityCopyWithImpl<$Res, $Val extends PendingStatusEntity>
    implements $PendingStatusEntityCopyWith<$Res> {
  _$PendingStatusEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PendingStatusEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? icon = null,
    Object? color = null,
    Object? count = null,
    Object? label = null,
  }) {
    return _then(
      _value.copyWith(
            icon: null == icon
                ? _value.icon
                : icon // ignore: cast_nullable_to_non_nullable
                      as IconData,
            color: null == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as Color,
            count: null == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                      as String,
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PendingStatusEntityImplCopyWith<$Res>
    implements $PendingStatusEntityCopyWith<$Res> {
  factory _$$PendingStatusEntityImplCopyWith(
    _$PendingStatusEntityImpl value,
    $Res Function(_$PendingStatusEntityImpl) then,
  ) = __$$PendingStatusEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({IconData icon, Color color, String count, String label});
}

/// @nodoc
class __$$PendingStatusEntityImplCopyWithImpl<$Res>
    extends _$PendingStatusEntityCopyWithImpl<$Res, _$PendingStatusEntityImpl>
    implements _$$PendingStatusEntityImplCopyWith<$Res> {
  __$$PendingStatusEntityImplCopyWithImpl(
    _$PendingStatusEntityImpl _value,
    $Res Function(_$PendingStatusEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PendingStatusEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? icon = null,
    Object? color = null,
    Object? count = null,
    Object? label = null,
  }) {
    return _then(
      _$PendingStatusEntityImpl(
        icon: null == icon
            ? _value.icon
            : icon // ignore: cast_nullable_to_non_nullable
                  as IconData,
        color: null == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as Color,
        count: null == count
            ? _value.count
            : count // ignore: cast_nullable_to_non_nullable
                  as String,
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$PendingStatusEntityImpl implements _PendingStatusEntity {
  const _$PendingStatusEntityImpl({
    required this.icon,
    required this.color,
    required this.count,
    required this.label,
  });

  @override
  final IconData icon;
  @override
  final Color color;
  @override
  final String count;
  @override
  final String label;

  @override
  String toString() {
    return 'PendingStatusEntity(icon: $icon, color: $color, count: $count, label: $label)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PendingStatusEntityImpl &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.label, label) || other.label == label));
  }

  @override
  int get hashCode => Object.hash(runtimeType, icon, color, count, label);

  /// Create a copy of PendingStatusEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PendingStatusEntityImplCopyWith<_$PendingStatusEntityImpl> get copyWith =>
      __$$PendingStatusEntityImplCopyWithImpl<_$PendingStatusEntityImpl>(
        this,
        _$identity,
      );
}

abstract class _PendingStatusEntity implements PendingStatusEntity {
  const factory _PendingStatusEntity({
    required final IconData icon,
    required final Color color,
    required final String count,
    required final String label,
  }) = _$PendingStatusEntityImpl;

  @override
  IconData get icon;
  @override
  Color get color;
  @override
  String get count;
  @override
  String get label;

  /// Create a copy of PendingStatusEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PendingStatusEntityImplCopyWith<_$PendingStatusEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$WorkAssignmentEntity {
  int get id => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get department => throw _privateConstructorUsedError;
  String get technicianName => throw _privateConstructorUsedError;
  String get dateOfWork => throw _privateConstructorUsedError;
  int get statusPercent => throw _privateConstructorUsedError;
  String get stdTime => throw _privateConstructorUsedError;
  String get remarks => throw _privateConstructorUsedError;

  /// Create a copy of WorkAssignmentEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkAssignmentEntityCopyWith<WorkAssignmentEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkAssignmentEntityCopyWith<$Res> {
  factory $WorkAssignmentEntityCopyWith(
    WorkAssignmentEntity value,
    $Res Function(WorkAssignmentEntity) then,
  ) = _$WorkAssignmentEntityCopyWithImpl<$Res, WorkAssignmentEntity>;
  @useResult
  $Res call({
    int id,
    String description,
    String department,
    String technicianName,
    String dateOfWork,
    int statusPercent,
    String stdTime,
    String remarks,
  });
}

/// @nodoc
class _$WorkAssignmentEntityCopyWithImpl<
  $Res,
  $Val extends WorkAssignmentEntity
>
    implements $WorkAssignmentEntityCopyWith<$Res> {
  _$WorkAssignmentEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkAssignmentEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? description = null,
    Object? department = null,
    Object? technicianName = null,
    Object? dateOfWork = null,
    Object? statusPercent = null,
    Object? stdTime = null,
    Object? remarks = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            department: null == department
                ? _value.department
                : department // ignore: cast_nullable_to_non_nullable
                      as String,
            technicianName: null == technicianName
                ? _value.technicianName
                : technicianName // ignore: cast_nullable_to_non_nullable
                      as String,
            dateOfWork: null == dateOfWork
                ? _value.dateOfWork
                : dateOfWork // ignore: cast_nullable_to_non_nullable
                      as String,
            statusPercent: null == statusPercent
                ? _value.statusPercent
                : statusPercent // ignore: cast_nullable_to_non_nullable
                      as int,
            stdTime: null == stdTime
                ? _value.stdTime
                : stdTime // ignore: cast_nullable_to_non_nullable
                      as String,
            remarks: null == remarks
                ? _value.remarks
                : remarks // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WorkAssignmentEntityImplCopyWith<$Res>
    implements $WorkAssignmentEntityCopyWith<$Res> {
  factory _$$WorkAssignmentEntityImplCopyWith(
    _$WorkAssignmentEntityImpl value,
    $Res Function(_$WorkAssignmentEntityImpl) then,
  ) = __$$WorkAssignmentEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String description,
    String department,
    String technicianName,
    String dateOfWork,
    int statusPercent,
    String stdTime,
    String remarks,
  });
}

/// @nodoc
class __$$WorkAssignmentEntityImplCopyWithImpl<$Res>
    extends _$WorkAssignmentEntityCopyWithImpl<$Res, _$WorkAssignmentEntityImpl>
    implements _$$WorkAssignmentEntityImplCopyWith<$Res> {
  __$$WorkAssignmentEntityImplCopyWithImpl(
    _$WorkAssignmentEntityImpl _value,
    $Res Function(_$WorkAssignmentEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WorkAssignmentEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? description = null,
    Object? department = null,
    Object? technicianName = null,
    Object? dateOfWork = null,
    Object? statusPercent = null,
    Object? stdTime = null,
    Object? remarks = null,
  }) {
    return _then(
      _$WorkAssignmentEntityImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        department: null == department
            ? _value.department
            : department // ignore: cast_nullable_to_non_nullable
                  as String,
        technicianName: null == technicianName
            ? _value.technicianName
            : technicianName // ignore: cast_nullable_to_non_nullable
                  as String,
        dateOfWork: null == dateOfWork
            ? _value.dateOfWork
            : dateOfWork // ignore: cast_nullable_to_non_nullable
                  as String,
        statusPercent: null == statusPercent
            ? _value.statusPercent
            : statusPercent // ignore: cast_nullable_to_non_nullable
                  as int,
        stdTime: null == stdTime
            ? _value.stdTime
            : stdTime // ignore: cast_nullable_to_non_nullable
                  as String,
        remarks: null == remarks
            ? _value.remarks
            : remarks // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$WorkAssignmentEntityImpl implements _WorkAssignmentEntity {
  const _$WorkAssignmentEntityImpl({
    required this.id,
    this.description = '',
    this.department = '',
    this.technicianName = '',
    this.dateOfWork = '',
    this.statusPercent = 0,
    this.stdTime = '',
    this.remarks = '',
  });

  @override
  final int id;
  @override
  @JsonKey()
  final String description;
  @override
  @JsonKey()
  final String department;
  @override
  @JsonKey()
  final String technicianName;
  @override
  @JsonKey()
  final String dateOfWork;
  @override
  @JsonKey()
  final int statusPercent;
  @override
  @JsonKey()
  final String stdTime;
  @override
  @JsonKey()
  final String remarks;

  @override
  String toString() {
    return 'WorkAssignmentEntity(id: $id, description: $description, department: $department, technicianName: $technicianName, dateOfWork: $dateOfWork, statusPercent: $statusPercent, stdTime: $stdTime, remarks: $remarks)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkAssignmentEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.department, department) ||
                other.department == department) &&
            (identical(other.technicianName, technicianName) ||
                other.technicianName == technicianName) &&
            (identical(other.dateOfWork, dateOfWork) ||
                other.dateOfWork == dateOfWork) &&
            (identical(other.statusPercent, statusPercent) ||
                other.statusPercent == statusPercent) &&
            (identical(other.stdTime, stdTime) || other.stdTime == stdTime) &&
            (identical(other.remarks, remarks) || other.remarks == remarks));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    description,
    department,
    technicianName,
    dateOfWork,
    statusPercent,
    stdTime,
    remarks,
  );

  /// Create a copy of WorkAssignmentEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkAssignmentEntityImplCopyWith<_$WorkAssignmentEntityImpl>
  get copyWith =>
      __$$WorkAssignmentEntityImplCopyWithImpl<_$WorkAssignmentEntityImpl>(
        this,
        _$identity,
      );
}

abstract class _WorkAssignmentEntity implements WorkAssignmentEntity {
  const factory _WorkAssignmentEntity({
    required final int id,
    final String description,
    final String department,
    final String technicianName,
    final String dateOfWork,
    final int statusPercent,
    final String stdTime,
    final String remarks,
  }) = _$WorkAssignmentEntityImpl;

  @override
  int get id;
  @override
  String get description;
  @override
  String get department;
  @override
  String get technicianName;
  @override
  String get dateOfWork;
  @override
  int get statusPercent;
  @override
  String get stdTime;
  @override
  String get remarks;

  /// Create a copy of WorkAssignmentEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkAssignmentEntityImplCopyWith<_$WorkAssignmentEntityImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AssignedJobEntity {
  String get jobCard => throw _privateConstructorUsedError;
  String get customer => throw _privateConstructorUsedError;
  String get vehicle => throw _privateConstructorUsedError;
  String get dateAssigned => throw _privateConstructorUsedError;
  int get done => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;

  /// Create a copy of AssignedJobEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AssignedJobEntityCopyWith<AssignedJobEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssignedJobEntityCopyWith<$Res> {
  factory $AssignedJobEntityCopyWith(
    AssignedJobEntity value,
    $Res Function(AssignedJobEntity) then,
  ) = _$AssignedJobEntityCopyWithImpl<$Res, AssignedJobEntity>;
  @useResult
  $Res call({
    String jobCard,
    String customer,
    String vehicle,
    String dateAssigned,
    int done,
    int total,
    String status,
  });
}

/// @nodoc
class _$AssignedJobEntityCopyWithImpl<$Res, $Val extends AssignedJobEntity>
    implements $AssignedJobEntityCopyWith<$Res> {
  _$AssignedJobEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AssignedJobEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? jobCard = null,
    Object? customer = null,
    Object? vehicle = null,
    Object? dateAssigned = null,
    Object? done = null,
    Object? total = null,
    Object? status = null,
  }) {
    return _then(
      _value.copyWith(
            jobCard: null == jobCard
                ? _value.jobCard
                : jobCard // ignore: cast_nullable_to_non_nullable
                      as String,
            customer: null == customer
                ? _value.customer
                : customer // ignore: cast_nullable_to_non_nullable
                      as String,
            vehicle: null == vehicle
                ? _value.vehicle
                : vehicle // ignore: cast_nullable_to_non_nullable
                      as String,
            dateAssigned: null == dateAssigned
                ? _value.dateAssigned
                : dateAssigned // ignore: cast_nullable_to_non_nullable
                      as String,
            done: null == done
                ? _value.done
                : done // ignore: cast_nullable_to_non_nullable
                      as int,
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
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
abstract class _$$AssignedJobEntityImplCopyWith<$Res>
    implements $AssignedJobEntityCopyWith<$Res> {
  factory _$$AssignedJobEntityImplCopyWith(
    _$AssignedJobEntityImpl value,
    $Res Function(_$AssignedJobEntityImpl) then,
  ) = __$$AssignedJobEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String jobCard,
    String customer,
    String vehicle,
    String dateAssigned,
    int done,
    int total,
    String status,
  });
}

/// @nodoc
class __$$AssignedJobEntityImplCopyWithImpl<$Res>
    extends _$AssignedJobEntityCopyWithImpl<$Res, _$AssignedJobEntityImpl>
    implements _$$AssignedJobEntityImplCopyWith<$Res> {
  __$$AssignedJobEntityImplCopyWithImpl(
    _$AssignedJobEntityImpl _value,
    $Res Function(_$AssignedJobEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AssignedJobEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? jobCard = null,
    Object? customer = null,
    Object? vehicle = null,
    Object? dateAssigned = null,
    Object? done = null,
    Object? total = null,
    Object? status = null,
  }) {
    return _then(
      _$AssignedJobEntityImpl(
        jobCard: null == jobCard
            ? _value.jobCard
            : jobCard // ignore: cast_nullable_to_non_nullable
                  as String,
        customer: null == customer
            ? _value.customer
            : customer // ignore: cast_nullable_to_non_nullable
                  as String,
        vehicle: null == vehicle
            ? _value.vehicle
            : vehicle // ignore: cast_nullable_to_non_nullable
                  as String,
        dateAssigned: null == dateAssigned
            ? _value.dateAssigned
            : dateAssigned // ignore: cast_nullable_to_non_nullable
                  as String,
        done: null == done
            ? _value.done
            : done // ignore: cast_nullable_to_non_nullable
                  as int,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
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

class _$AssignedJobEntityImpl implements _AssignedJobEntity {
  const _$AssignedJobEntityImpl({
    required this.jobCard,
    required this.customer,
    required this.vehicle,
    required this.dateAssigned,
    required this.done,
    required this.total,
    required this.status,
  });

  @override
  final String jobCard;
  @override
  final String customer;
  @override
  final String vehicle;
  @override
  final String dateAssigned;
  @override
  final int done;
  @override
  final int total;
  @override
  final String status;

  @override
  String toString() {
    return 'AssignedJobEntity(jobCard: $jobCard, customer: $customer, vehicle: $vehicle, dateAssigned: $dateAssigned, done: $done, total: $total, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssignedJobEntityImpl &&
            (identical(other.jobCard, jobCard) || other.jobCard == jobCard) &&
            (identical(other.customer, customer) ||
                other.customer == customer) &&
            (identical(other.vehicle, vehicle) || other.vehicle == vehicle) &&
            (identical(other.dateAssigned, dateAssigned) ||
                other.dateAssigned == dateAssigned) &&
            (identical(other.done, done) || other.done == done) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    jobCard,
    customer,
    vehicle,
    dateAssigned,
    done,
    total,
    status,
  );

  /// Create a copy of AssignedJobEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AssignedJobEntityImplCopyWith<_$AssignedJobEntityImpl> get copyWith =>
      __$$AssignedJobEntityImplCopyWithImpl<_$AssignedJobEntityImpl>(
        this,
        _$identity,
      );
}

abstract class _AssignedJobEntity implements AssignedJobEntity {
  const factory _AssignedJobEntity({
    required final String jobCard,
    required final String customer,
    required final String vehicle,
    required final String dateAssigned,
    required final int done,
    required final int total,
    required final String status,
  }) = _$AssignedJobEntityImpl;

  @override
  String get jobCard;
  @override
  String get customer;
  @override
  String get vehicle;
  @override
  String get dateAssigned;
  @override
  int get done;
  @override
  int get total;
  @override
  String get status;

  /// Create a copy of AssignedJobEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AssignedJobEntityImplCopyWith<_$AssignedJobEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
