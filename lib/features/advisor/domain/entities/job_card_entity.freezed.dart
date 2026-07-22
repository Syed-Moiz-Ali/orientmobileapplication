// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'job_card_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

JobCardEntity _$JobCardEntityFromJson(Map<String, dynamic> json) {
  return _JobCardEntity.fromJson(json);
}

/// @nodoc
mixin _$JobCardEntity {
  String get id => throw _privateConstructorUsedError;
  String get customerName => throw _privateConstructorUsedError;
  String get vehicleInfo => throw _privateConstructorUsedError;
  String get time => throw _privateConstructorUsedError;
  String get createdDate => throw _privateConstructorUsedError;
  String get lastUpdated => throw _privateConstructorUsedError;
  JobCardStatus get status => throw _privateConstructorUsedError;
  String get technician => throw _privateConstructorUsedError;

  /// Serializes this JobCardEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of JobCardEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JobCardEntityCopyWith<JobCardEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JobCardEntityCopyWith<$Res> {
  factory $JobCardEntityCopyWith(
    JobCardEntity value,
    $Res Function(JobCardEntity) then,
  ) = _$JobCardEntityCopyWithImpl<$Res, JobCardEntity>;
  @useResult
  $Res call({
    String id,
    String customerName,
    String vehicleInfo,
    String time,
    String createdDate,
    String lastUpdated,
    JobCardStatus status,
    String technician,
  });
}

/// @nodoc
class _$JobCardEntityCopyWithImpl<$Res, $Val extends JobCardEntity>
    implements $JobCardEntityCopyWith<$Res> {
  _$JobCardEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of JobCardEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerName = null,
    Object? vehicleInfo = null,
    Object? time = null,
    Object? createdDate = null,
    Object? lastUpdated = null,
    Object? status = null,
    Object? technician = null,
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
            vehicleInfo: null == vehicleInfo
                ? _value.vehicleInfo
                : vehicleInfo // ignore: cast_nullable_to_non_nullable
                      as String,
            time: null == time
                ? _value.time
                : time // ignore: cast_nullable_to_non_nullable
                      as String,
            createdDate: null == createdDate
                ? _value.createdDate
                : createdDate // ignore: cast_nullable_to_non_nullable
                      as String,
            lastUpdated: null == lastUpdated
                ? _value.lastUpdated
                : lastUpdated // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as JobCardStatus,
            technician: null == technician
                ? _value.technician
                : technician // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$JobCardEntityImplCopyWith<$Res>
    implements $JobCardEntityCopyWith<$Res> {
  factory _$$JobCardEntityImplCopyWith(
    _$JobCardEntityImpl value,
    $Res Function(_$JobCardEntityImpl) then,
  ) = __$$JobCardEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String customerName,
    String vehicleInfo,
    String time,
    String createdDate,
    String lastUpdated,
    JobCardStatus status,
    String technician,
  });
}

/// @nodoc
class __$$JobCardEntityImplCopyWithImpl<$Res>
    extends _$JobCardEntityCopyWithImpl<$Res, _$JobCardEntityImpl>
    implements _$$JobCardEntityImplCopyWith<$Res> {
  __$$JobCardEntityImplCopyWithImpl(
    _$JobCardEntityImpl _value,
    $Res Function(_$JobCardEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of JobCardEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerName = null,
    Object? vehicleInfo = null,
    Object? time = null,
    Object? createdDate = null,
    Object? lastUpdated = null,
    Object? status = null,
    Object? technician = null,
  }) {
    return _then(
      _$JobCardEntityImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        customerName: null == customerName
            ? _value.customerName
            : customerName // ignore: cast_nullable_to_non_nullable
                  as String,
        vehicleInfo: null == vehicleInfo
            ? _value.vehicleInfo
            : vehicleInfo // ignore: cast_nullable_to_non_nullable
                  as String,
        time: null == time
            ? _value.time
            : time // ignore: cast_nullable_to_non_nullable
                  as String,
        createdDate: null == createdDate
            ? _value.createdDate
            : createdDate // ignore: cast_nullable_to_non_nullable
                  as String,
        lastUpdated: null == lastUpdated
            ? _value.lastUpdated
            : lastUpdated // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as JobCardStatus,
        technician: null == technician
            ? _value.technician
            : technician // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$JobCardEntityImpl implements _JobCardEntity {
  const _$JobCardEntityImpl({
    required this.id,
    required this.customerName,
    required this.vehicleInfo,
    required this.time,
    this.createdDate = '',
    this.lastUpdated = '',
    required this.status,
    this.technician = '',
  });

  factory _$JobCardEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$JobCardEntityImplFromJson(json);

  @override
  final String id;
  @override
  final String customerName;
  @override
  final String vehicleInfo;
  @override
  final String time;
  @override
  @JsonKey()
  final String createdDate;
  @override
  @JsonKey()
  final String lastUpdated;
  @override
  final JobCardStatus status;
  @override
  @JsonKey()
  final String technician;

  @override
  String toString() {
    return 'JobCardEntity(id: $id, customerName: $customerName, vehicleInfo: $vehicleInfo, time: $time, createdDate: $createdDate, lastUpdated: $lastUpdated, status: $status, technician: $technician)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JobCardEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.vehicleInfo, vehicleInfo) ||
                other.vehicleInfo == vehicleInfo) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.createdDate, createdDate) ||
                other.createdDate == createdDate) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.technician, technician) ||
                other.technician == technician));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    customerName,
    vehicleInfo,
    time,
    createdDate,
    lastUpdated,
    status,
    technician,
  );

  /// Create a copy of JobCardEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JobCardEntityImplCopyWith<_$JobCardEntityImpl> get copyWith =>
      __$$JobCardEntityImplCopyWithImpl<_$JobCardEntityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$JobCardEntityImplToJson(this);
  }
}

abstract class _JobCardEntity implements JobCardEntity {
  const factory _JobCardEntity({
    required final String id,
    required final String customerName,
    required final String vehicleInfo,
    required final String time,
    final String createdDate,
    final String lastUpdated,
    required final JobCardStatus status,
    final String technician,
  }) = _$JobCardEntityImpl;

  factory _JobCardEntity.fromJson(Map<String, dynamic> json) =
      _$JobCardEntityImpl.fromJson;

  @override
  String get id;
  @override
  String get customerName;
  @override
  String get vehicleInfo;
  @override
  String get time;
  @override
  String get createdDate;
  @override
  String get lastUpdated;
  @override
  JobCardStatus get status;
  @override
  String get technician;

  /// Create a copy of JobCardEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JobCardEntityImplCopyWith<_$JobCardEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
