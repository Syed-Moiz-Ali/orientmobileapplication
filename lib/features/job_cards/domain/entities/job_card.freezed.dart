// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'job_card.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$JobCard {
  String get id => throw _privateConstructorUsedError;
  String get customerName => throw _privateConstructorUsedError;
  String get vehicle => throw _privateConstructorUsedError;
  String get plateNumber => throw _privateConstructorUsedError;
  List<String> get services => throw _privateConstructorUsedError;
  String get technician => throw _privateConstructorUsedError;
  String get estCompletion => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  JobCardStatus get status => throw _privateConstructorUsedError;

  /// Create a copy of JobCard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JobCardCopyWith<JobCard> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JobCardCopyWith<$Res> {
  factory $JobCardCopyWith(JobCard value, $Res Function(JobCard) then) =
      _$JobCardCopyWithImpl<$Res, JobCard>;
  @useResult
  $Res call({
    String id,
    String customerName,
    String vehicle,
    String plateNumber,
    List<String> services,
    String technician,
    String estCompletion,
    double amount,
    JobCardStatus status,
  });
}

/// @nodoc
class _$JobCardCopyWithImpl<$Res, $Val extends JobCard>
    implements $JobCardCopyWith<$Res> {
  _$JobCardCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of JobCard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerName = null,
    Object? vehicle = null,
    Object? plateNumber = null,
    Object? services = null,
    Object? technician = null,
    Object? estCompletion = null,
    Object? amount = null,
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
            vehicle: null == vehicle
                ? _value.vehicle
                : vehicle // ignore: cast_nullable_to_non_nullable
                      as String,
            plateNumber: null == plateNumber
                ? _value.plateNumber
                : plateNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            services: null == services
                ? _value.services
                : services // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            technician: null == technician
                ? _value.technician
                : technician // ignore: cast_nullable_to_non_nullable
                      as String,
            estCompletion: null == estCompletion
                ? _value.estCompletion
                : estCompletion // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as JobCardStatus,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$JobCardImplCopyWith<$Res> implements $JobCardCopyWith<$Res> {
  factory _$$JobCardImplCopyWith(
    _$JobCardImpl value,
    $Res Function(_$JobCardImpl) then,
  ) = __$$JobCardImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String customerName,
    String vehicle,
    String plateNumber,
    List<String> services,
    String technician,
    String estCompletion,
    double amount,
    JobCardStatus status,
  });
}

/// @nodoc
class __$$JobCardImplCopyWithImpl<$Res>
    extends _$JobCardCopyWithImpl<$Res, _$JobCardImpl>
    implements _$$JobCardImplCopyWith<$Res> {
  __$$JobCardImplCopyWithImpl(
    _$JobCardImpl _value,
    $Res Function(_$JobCardImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of JobCard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerName = null,
    Object? vehicle = null,
    Object? plateNumber = null,
    Object? services = null,
    Object? technician = null,
    Object? estCompletion = null,
    Object? amount = null,
    Object? status = null,
  }) {
    return _then(
      _$JobCardImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        customerName: null == customerName
            ? _value.customerName
            : customerName // ignore: cast_nullable_to_non_nullable
                  as String,
        vehicle: null == vehicle
            ? _value.vehicle
            : vehicle // ignore: cast_nullable_to_non_nullable
                  as String,
        plateNumber: null == plateNumber
            ? _value.plateNumber
            : plateNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        services: null == services
            ? _value._services
            : services // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        technician: null == technician
            ? _value.technician
            : technician // ignore: cast_nullable_to_non_nullable
                  as String,
        estCompletion: null == estCompletion
            ? _value.estCompletion
            : estCompletion // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as JobCardStatus,
      ),
    );
  }
}

/// @nodoc

class _$JobCardImpl extends _JobCard {
  const _$JobCardImpl({
    required this.id,
    required this.customerName,
    required this.vehicle,
    required this.plateNumber,
    required final List<String> services,
    required this.technician,
    required this.estCompletion,
    required this.amount,
    required this.status,
  }) : _services = services,
       super._();

  @override
  final String id;
  @override
  final String customerName;
  @override
  final String vehicle;
  @override
  final String plateNumber;
  final List<String> _services;
  @override
  List<String> get services {
    if (_services is EqualUnmodifiableListView) return _services;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_services);
  }

  @override
  final String technician;
  @override
  final String estCompletion;
  @override
  final double amount;
  @override
  final JobCardStatus status;

  @override
  String toString() {
    return 'JobCard(id: $id, customerName: $customerName, vehicle: $vehicle, plateNumber: $plateNumber, services: $services, technician: $technician, estCompletion: $estCompletion, amount: $amount, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JobCardImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.vehicle, vehicle) || other.vehicle == vehicle) &&
            (identical(other.plateNumber, plateNumber) ||
                other.plateNumber == plateNumber) &&
            const DeepCollectionEquality().equals(other._services, _services) &&
            (identical(other.technician, technician) ||
                other.technician == technician) &&
            (identical(other.estCompletion, estCompletion) ||
                other.estCompletion == estCompletion) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    customerName,
    vehicle,
    plateNumber,
    const DeepCollectionEquality().hash(_services),
    technician,
    estCompletion,
    amount,
    status,
  );

  /// Create a copy of JobCard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JobCardImplCopyWith<_$JobCardImpl> get copyWith =>
      __$$JobCardImplCopyWithImpl<_$JobCardImpl>(this, _$identity);
}

abstract class _JobCard extends JobCard {
  const factory _JobCard({
    required final String id,
    required final String customerName,
    required final String vehicle,
    required final String plateNumber,
    required final List<String> services,
    required final String technician,
    required final String estCompletion,
    required final double amount,
    required final JobCardStatus status,
  }) = _$JobCardImpl;
  const _JobCard._() : super._();

  @override
  String get id;
  @override
  String get customerName;
  @override
  String get vehicle;
  @override
  String get plateNumber;
  @override
  List<String> get services;
  @override
  String get technician;
  @override
  String get estCompletion;
  @override
  double get amount;
  @override
  JobCardStatus get status;

  /// Create a copy of JobCard
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JobCardImplCopyWith<_$JobCardImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
