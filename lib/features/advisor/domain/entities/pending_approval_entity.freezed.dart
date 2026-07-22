// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pending_approval_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PendingApprovalEntity _$PendingApprovalEntityFromJson(
  Map<String, dynamic> json,
) {
  return _PendingApprovalEntity.fromJson(json);
}

/// @nodoc
mixin _$PendingApprovalEntity {
  String get estimateId => throw _privateConstructorUsedError;
  String get customerName => throw _privateConstructorUsedError;
  String get vehicleId => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get timeAgo => throw _privateConstructorUsedError;

  /// Serializes this PendingApprovalEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PendingApprovalEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PendingApprovalEntityCopyWith<PendingApprovalEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PendingApprovalEntityCopyWith<$Res> {
  factory $PendingApprovalEntityCopyWith(
    PendingApprovalEntity value,
    $Res Function(PendingApprovalEntity) then,
  ) = _$PendingApprovalEntityCopyWithImpl<$Res, PendingApprovalEntity>;
  @useResult
  $Res call({
    String estimateId,
    String customerName,
    String vehicleId,
    double amount,
    String timeAgo,
  });
}

/// @nodoc
class _$PendingApprovalEntityCopyWithImpl<
  $Res,
  $Val extends PendingApprovalEntity
>
    implements $PendingApprovalEntityCopyWith<$Res> {
  _$PendingApprovalEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PendingApprovalEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? estimateId = null,
    Object? customerName = null,
    Object? vehicleId = null,
    Object? amount = null,
    Object? timeAgo = null,
  }) {
    return _then(
      _value.copyWith(
            estimateId: null == estimateId
                ? _value.estimateId
                : estimateId // ignore: cast_nullable_to_non_nullable
                      as String,
            customerName: null == customerName
                ? _value.customerName
                : customerName // ignore: cast_nullable_to_non_nullable
                      as String,
            vehicleId: null == vehicleId
                ? _value.vehicleId
                : vehicleId // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            timeAgo: null == timeAgo
                ? _value.timeAgo
                : timeAgo // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PendingApprovalEntityImplCopyWith<$Res>
    implements $PendingApprovalEntityCopyWith<$Res> {
  factory _$$PendingApprovalEntityImplCopyWith(
    _$PendingApprovalEntityImpl value,
    $Res Function(_$PendingApprovalEntityImpl) then,
  ) = __$$PendingApprovalEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String estimateId,
    String customerName,
    String vehicleId,
    double amount,
    String timeAgo,
  });
}

/// @nodoc
class __$$PendingApprovalEntityImplCopyWithImpl<$Res>
    extends
        _$PendingApprovalEntityCopyWithImpl<$Res, _$PendingApprovalEntityImpl>
    implements _$$PendingApprovalEntityImplCopyWith<$Res> {
  __$$PendingApprovalEntityImplCopyWithImpl(
    _$PendingApprovalEntityImpl _value,
    $Res Function(_$PendingApprovalEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PendingApprovalEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? estimateId = null,
    Object? customerName = null,
    Object? vehicleId = null,
    Object? amount = null,
    Object? timeAgo = null,
  }) {
    return _then(
      _$PendingApprovalEntityImpl(
        estimateId: null == estimateId
            ? _value.estimateId
            : estimateId // ignore: cast_nullable_to_non_nullable
                  as String,
        customerName: null == customerName
            ? _value.customerName
            : customerName // ignore: cast_nullable_to_non_nullable
                  as String,
        vehicleId: null == vehicleId
            ? _value.vehicleId
            : vehicleId // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        timeAgo: null == timeAgo
            ? _value.timeAgo
            : timeAgo // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PendingApprovalEntityImpl implements _PendingApprovalEntity {
  const _$PendingApprovalEntityImpl({
    required this.estimateId,
    required this.customerName,
    required this.vehicleId,
    required this.amount,
    this.timeAgo = 'now',
  });

  factory _$PendingApprovalEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$PendingApprovalEntityImplFromJson(json);

  @override
  final String estimateId;
  @override
  final String customerName;
  @override
  final String vehicleId;
  @override
  final double amount;
  @override
  @JsonKey()
  final String timeAgo;

  @override
  String toString() {
    return 'PendingApprovalEntity(estimateId: $estimateId, customerName: $customerName, vehicleId: $vehicleId, amount: $amount, timeAgo: $timeAgo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PendingApprovalEntityImpl &&
            (identical(other.estimateId, estimateId) ||
                other.estimateId == estimateId) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.vehicleId, vehicleId) ||
                other.vehicleId == vehicleId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.timeAgo, timeAgo) || other.timeAgo == timeAgo));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    estimateId,
    customerName,
    vehicleId,
    amount,
    timeAgo,
  );

  /// Create a copy of PendingApprovalEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PendingApprovalEntityImplCopyWith<_$PendingApprovalEntityImpl>
  get copyWith =>
      __$$PendingApprovalEntityImplCopyWithImpl<_$PendingApprovalEntityImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PendingApprovalEntityImplToJson(this);
  }
}

abstract class _PendingApprovalEntity implements PendingApprovalEntity {
  const factory _PendingApprovalEntity({
    required final String estimateId,
    required final String customerName,
    required final String vehicleId,
    required final double amount,
    final String timeAgo,
  }) = _$PendingApprovalEntityImpl;

  factory _PendingApprovalEntity.fromJson(Map<String, dynamic> json) =
      _$PendingApprovalEntityImpl.fromJson;

  @override
  String get estimateId;
  @override
  String get customerName;
  @override
  String get vehicleId;
  @override
  double get amount;
  @override
  String get timeAgo;

  /// Create a copy of PendingApprovalEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PendingApprovalEntityImplCopyWith<_$PendingApprovalEntityImpl>
  get copyWith => throw _privateConstructorUsedError;
}
