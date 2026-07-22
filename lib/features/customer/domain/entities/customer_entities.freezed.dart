// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'customer_entities.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CustomerEntity _$CustomerEntityFromJson(Map<String, dynamic> json) {
  return _CustomerEntity.fromJson(json);
}

/// @nodoc
mixin _$CustomerEntity {
  String get name => throw _privateConstructorUsedError;
  String get firstName => throw _privateConstructorUsedError;
  String get avatarInitials => throw _privateConstructorUsedError;
  String get memberId => throw _privateConstructorUsedError;

  /// Serializes this CustomerEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CustomerEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CustomerEntityCopyWith<CustomerEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomerEntityCopyWith<$Res> {
  factory $CustomerEntityCopyWith(
    CustomerEntity value,
    $Res Function(CustomerEntity) then,
  ) = _$CustomerEntityCopyWithImpl<$Res, CustomerEntity>;
  @useResult
  $Res call({
    String name,
    String firstName,
    String avatarInitials,
    String memberId,
  });
}

/// @nodoc
class _$CustomerEntityCopyWithImpl<$Res, $Val extends CustomerEntity>
    implements $CustomerEntityCopyWith<$Res> {
  _$CustomerEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CustomerEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? firstName = null,
    Object? avatarInitials = null,
    Object? memberId = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            firstName: null == firstName
                ? _value.firstName
                : firstName // ignore: cast_nullable_to_non_nullable
                      as String,
            avatarInitials: null == avatarInitials
                ? _value.avatarInitials
                : avatarInitials // ignore: cast_nullable_to_non_nullable
                      as String,
            memberId: null == memberId
                ? _value.memberId
                : memberId // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CustomerEntityImplCopyWith<$Res>
    implements $CustomerEntityCopyWith<$Res> {
  factory _$$CustomerEntityImplCopyWith(
    _$CustomerEntityImpl value,
    $Res Function(_$CustomerEntityImpl) then,
  ) = __$$CustomerEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    String firstName,
    String avatarInitials,
    String memberId,
  });
}

/// @nodoc
class __$$CustomerEntityImplCopyWithImpl<$Res>
    extends _$CustomerEntityCopyWithImpl<$Res, _$CustomerEntityImpl>
    implements _$$CustomerEntityImplCopyWith<$Res> {
  __$$CustomerEntityImplCopyWithImpl(
    _$CustomerEntityImpl _value,
    $Res Function(_$CustomerEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CustomerEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? firstName = null,
    Object? avatarInitials = null,
    Object? memberId = null,
  }) {
    return _then(
      _$CustomerEntityImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        firstName: null == firstName
            ? _value.firstName
            : firstName // ignore: cast_nullable_to_non_nullable
                  as String,
        avatarInitials: null == avatarInitials
            ? _value.avatarInitials
            : avatarInitials // ignore: cast_nullable_to_non_nullable
                  as String,
        memberId: null == memberId
            ? _value.memberId
            : memberId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomerEntityImpl implements _CustomerEntity {
  const _$CustomerEntityImpl({
    required this.name,
    required this.firstName,
    required this.avatarInitials,
    required this.memberId,
  });

  factory _$CustomerEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomerEntityImplFromJson(json);

  @override
  final String name;
  @override
  final String firstName;
  @override
  final String avatarInitials;
  @override
  final String memberId;

  @override
  String toString() {
    return 'CustomerEntity(name: $name, firstName: $firstName, avatarInitials: $avatarInitials, memberId: $memberId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomerEntityImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.avatarInitials, avatarInitials) ||
                other.avatarInitials == avatarInitials) &&
            (identical(other.memberId, memberId) ||
                other.memberId == memberId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, firstName, avatarInitials, memberId);

  /// Create a copy of CustomerEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomerEntityImplCopyWith<_$CustomerEntityImpl> get copyWith =>
      __$$CustomerEntityImplCopyWithImpl<_$CustomerEntityImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomerEntityImplToJson(this);
  }
}

abstract class _CustomerEntity implements CustomerEntity {
  const factory _CustomerEntity({
    required final String name,
    required final String firstName,
    required final String avatarInitials,
    required final String memberId,
  }) = _$CustomerEntityImpl;

  factory _CustomerEntity.fromJson(Map<String, dynamic> json) =
      _$CustomerEntityImpl.fromJson;

  @override
  String get name;
  @override
  String get firstName;
  @override
  String get avatarInitials;
  @override
  String get memberId;

  /// Create a copy of CustomerEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomerEntityImplCopyWith<_$CustomerEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CustomerVehicleEntity _$CustomerVehicleEntityFromJson(
  Map<String, dynamic> json,
) {
  return _CustomerVehicleEntity.fromJson(json);
}

/// @nodoc
mixin _$CustomerVehicleEntity {
  String get id => throw _privateConstructorUsedError;
  String get brand => throw _privateConstructorUsedError;
  String get model => throw _privateConstructorUsedError;
  String get plateNumber => throw _privateConstructorUsedError;
  String get vin => throw _privateConstructorUsedError;
  String get color => throw _privateConstructorUsedError;
  int get year => throw _privateConstructorUsedError;
  String get mileage => throw _privateConstructorUsedError;
  String get lastService => throw _privateConstructorUsedError;
  String get nextDue => throw _privateConstructorUsedError;
  int get healthScore => throw _privateConstructorUsedError;

  /// Serializes this CustomerVehicleEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CustomerVehicleEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CustomerVehicleEntityCopyWith<CustomerVehicleEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomerVehicleEntityCopyWith<$Res> {
  factory $CustomerVehicleEntityCopyWith(
    CustomerVehicleEntity value,
    $Res Function(CustomerVehicleEntity) then,
  ) = _$CustomerVehicleEntityCopyWithImpl<$Res, CustomerVehicleEntity>;
  @useResult
  $Res call({
    String id,
    String brand,
    String model,
    String plateNumber,
    String vin,
    String color,
    int year,
    String mileage,
    String lastService,
    String nextDue,
    int healthScore,
  });
}

/// @nodoc
class _$CustomerVehicleEntityCopyWithImpl<
  $Res,
  $Val extends CustomerVehicleEntity
>
    implements $CustomerVehicleEntityCopyWith<$Res> {
  _$CustomerVehicleEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CustomerVehicleEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? brand = null,
    Object? model = null,
    Object? plateNumber = null,
    Object? vin = null,
    Object? color = null,
    Object? year = null,
    Object? mileage = null,
    Object? lastService = null,
    Object? nextDue = null,
    Object? healthScore = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            brand: null == brand
                ? _value.brand
                : brand // ignore: cast_nullable_to_non_nullable
                      as String,
            model: null == model
                ? _value.model
                : model // ignore: cast_nullable_to_non_nullable
                      as String,
            plateNumber: null == plateNumber
                ? _value.plateNumber
                : plateNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            vin: null == vin
                ? _value.vin
                : vin // ignore: cast_nullable_to_non_nullable
                      as String,
            color: null == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as String,
            year: null == year
                ? _value.year
                : year // ignore: cast_nullable_to_non_nullable
                      as int,
            mileage: null == mileage
                ? _value.mileage
                : mileage // ignore: cast_nullable_to_non_nullable
                      as String,
            lastService: null == lastService
                ? _value.lastService
                : lastService // ignore: cast_nullable_to_non_nullable
                      as String,
            nextDue: null == nextDue
                ? _value.nextDue
                : nextDue // ignore: cast_nullable_to_non_nullable
                      as String,
            healthScore: null == healthScore
                ? _value.healthScore
                : healthScore // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CustomerVehicleEntityImplCopyWith<$Res>
    implements $CustomerVehicleEntityCopyWith<$Res> {
  factory _$$CustomerVehicleEntityImplCopyWith(
    _$CustomerVehicleEntityImpl value,
    $Res Function(_$CustomerVehicleEntityImpl) then,
  ) = __$$CustomerVehicleEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String brand,
    String model,
    String plateNumber,
    String vin,
    String color,
    int year,
    String mileage,
    String lastService,
    String nextDue,
    int healthScore,
  });
}

/// @nodoc
class __$$CustomerVehicleEntityImplCopyWithImpl<$Res>
    extends
        _$CustomerVehicleEntityCopyWithImpl<$Res, _$CustomerVehicleEntityImpl>
    implements _$$CustomerVehicleEntityImplCopyWith<$Res> {
  __$$CustomerVehicleEntityImplCopyWithImpl(
    _$CustomerVehicleEntityImpl _value,
    $Res Function(_$CustomerVehicleEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CustomerVehicleEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? brand = null,
    Object? model = null,
    Object? plateNumber = null,
    Object? vin = null,
    Object? color = null,
    Object? year = null,
    Object? mileage = null,
    Object? lastService = null,
    Object? nextDue = null,
    Object? healthScore = null,
  }) {
    return _then(
      _$CustomerVehicleEntityImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        brand: null == brand
            ? _value.brand
            : brand // ignore: cast_nullable_to_non_nullable
                  as String,
        model: null == model
            ? _value.model
            : model // ignore: cast_nullable_to_non_nullable
                  as String,
        plateNumber: null == plateNumber
            ? _value.plateNumber
            : plateNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        vin: null == vin
            ? _value.vin
            : vin // ignore: cast_nullable_to_non_nullable
                  as String,
        color: null == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as String,
        year: null == year
            ? _value.year
            : year // ignore: cast_nullable_to_non_nullable
                  as int,
        mileage: null == mileage
            ? _value.mileage
            : mileage // ignore: cast_nullable_to_non_nullable
                  as String,
        lastService: null == lastService
            ? _value.lastService
            : lastService // ignore: cast_nullable_to_non_nullable
                  as String,
        nextDue: null == nextDue
            ? _value.nextDue
            : nextDue // ignore: cast_nullable_to_non_nullable
                  as String,
        healthScore: null == healthScore
            ? _value.healthScore
            : healthScore // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomerVehicleEntityImpl extends _CustomerVehicleEntity {
  const _$CustomerVehicleEntityImpl({
    required this.id,
    required this.brand,
    required this.model,
    required this.plateNumber,
    required this.vin,
    required this.color,
    required this.year,
    required this.mileage,
    required this.lastService,
    required this.nextDue,
    required this.healthScore,
  }) : super._();

  factory _$CustomerVehicleEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomerVehicleEntityImplFromJson(json);

  @override
  final String id;
  @override
  final String brand;
  @override
  final String model;
  @override
  final String plateNumber;
  @override
  final String vin;
  @override
  final String color;
  @override
  final int year;
  @override
  final String mileage;
  @override
  final String lastService;
  @override
  final String nextDue;
  @override
  final int healthScore;

  @override
  String toString() {
    return 'CustomerVehicleEntity(id: $id, brand: $brand, model: $model, plateNumber: $plateNumber, vin: $vin, color: $color, year: $year, mileage: $mileage, lastService: $lastService, nextDue: $nextDue, healthScore: $healthScore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomerVehicleEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.brand, brand) || other.brand == brand) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.plateNumber, plateNumber) ||
                other.plateNumber == plateNumber) &&
            (identical(other.vin, vin) || other.vin == vin) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.mileage, mileage) || other.mileage == mileage) &&
            (identical(other.lastService, lastService) ||
                other.lastService == lastService) &&
            (identical(other.nextDue, nextDue) || other.nextDue == nextDue) &&
            (identical(other.healthScore, healthScore) ||
                other.healthScore == healthScore));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    brand,
    model,
    plateNumber,
    vin,
    color,
    year,
    mileage,
    lastService,
    nextDue,
    healthScore,
  );

  /// Create a copy of CustomerVehicleEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomerVehicleEntityImplCopyWith<_$CustomerVehicleEntityImpl>
  get copyWith =>
      __$$CustomerVehicleEntityImplCopyWithImpl<_$CustomerVehicleEntityImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomerVehicleEntityImplToJson(this);
  }
}

abstract class _CustomerVehicleEntity extends CustomerVehicleEntity {
  const factory _CustomerVehicleEntity({
    required final String id,
    required final String brand,
    required final String model,
    required final String plateNumber,
    required final String vin,
    required final String color,
    required final int year,
    required final String mileage,
    required final String lastService,
    required final String nextDue,
    required final int healthScore,
  }) = _$CustomerVehicleEntityImpl;
  const _CustomerVehicleEntity._() : super._();

  factory _CustomerVehicleEntity.fromJson(Map<String, dynamic> json) =
      _$CustomerVehicleEntityImpl.fromJson;

  @override
  String get id;
  @override
  String get brand;
  @override
  String get model;
  @override
  String get plateNumber;
  @override
  String get vin;
  @override
  String get color;
  @override
  int get year;
  @override
  String get mileage;
  @override
  String get lastService;
  @override
  String get nextDue;
  @override
  int get healthScore;

  /// Create a copy of CustomerVehicleEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomerVehicleEntityImplCopyWith<_$CustomerVehicleEntityImpl>
  get copyWith => throw _privateConstructorUsedError;
}

CustomerBookingEntity _$CustomerBookingEntityFromJson(
  Map<String, dynamic> json,
) {
  return _CustomerBookingEntity.fromJson(json);
}

/// @nodoc
mixin _$CustomerBookingEntity {
  String get service => throw _privateConstructorUsedError;
  String get vehicleName => throw _privateConstructorUsedError;
  String get plateNumber => throw _privateConstructorUsedError;
  String get date => throw _privateConstructorUsedError;
  String get time => throw _privateConstructorUsedError;
  BookingStatus get status => throw _privateConstructorUsedError;

  /// Serializes this CustomerBookingEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CustomerBookingEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CustomerBookingEntityCopyWith<CustomerBookingEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomerBookingEntityCopyWith<$Res> {
  factory $CustomerBookingEntityCopyWith(
    CustomerBookingEntity value,
    $Res Function(CustomerBookingEntity) then,
  ) = _$CustomerBookingEntityCopyWithImpl<$Res, CustomerBookingEntity>;
  @useResult
  $Res call({
    String service,
    String vehicleName,
    String plateNumber,
    String date,
    String time,
    BookingStatus status,
  });
}

/// @nodoc
class _$CustomerBookingEntityCopyWithImpl<
  $Res,
  $Val extends CustomerBookingEntity
>
    implements $CustomerBookingEntityCopyWith<$Res> {
  _$CustomerBookingEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CustomerBookingEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? service = null,
    Object? vehicleName = null,
    Object? plateNumber = null,
    Object? date = null,
    Object? time = null,
    Object? status = null,
  }) {
    return _then(
      _value.copyWith(
            service: null == service
                ? _value.service
                : service // ignore: cast_nullable_to_non_nullable
                      as String,
            vehicleName: null == vehicleName
                ? _value.vehicleName
                : vehicleName // ignore: cast_nullable_to_non_nullable
                      as String,
            plateNumber: null == plateNumber
                ? _value.plateNumber
                : plateNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String,
            time: null == time
                ? _value.time
                : time // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as BookingStatus,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CustomerBookingEntityImplCopyWith<$Res>
    implements $CustomerBookingEntityCopyWith<$Res> {
  factory _$$CustomerBookingEntityImplCopyWith(
    _$CustomerBookingEntityImpl value,
    $Res Function(_$CustomerBookingEntityImpl) then,
  ) = __$$CustomerBookingEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String service,
    String vehicleName,
    String plateNumber,
    String date,
    String time,
    BookingStatus status,
  });
}

/// @nodoc
class __$$CustomerBookingEntityImplCopyWithImpl<$Res>
    extends
        _$CustomerBookingEntityCopyWithImpl<$Res, _$CustomerBookingEntityImpl>
    implements _$$CustomerBookingEntityImplCopyWith<$Res> {
  __$$CustomerBookingEntityImplCopyWithImpl(
    _$CustomerBookingEntityImpl _value,
    $Res Function(_$CustomerBookingEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CustomerBookingEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? service = null,
    Object? vehicleName = null,
    Object? plateNumber = null,
    Object? date = null,
    Object? time = null,
    Object? status = null,
  }) {
    return _then(
      _$CustomerBookingEntityImpl(
        service: null == service
            ? _value.service
            : service // ignore: cast_nullable_to_non_nullable
                  as String,
        vehicleName: null == vehicleName
            ? _value.vehicleName
            : vehicleName // ignore: cast_nullable_to_non_nullable
                  as String,
        plateNumber: null == plateNumber
            ? _value.plateNumber
            : plateNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String,
        time: null == time
            ? _value.time
            : time // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as BookingStatus,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomerBookingEntityImpl extends _CustomerBookingEntity {
  const _$CustomerBookingEntityImpl({
    required this.service,
    required this.vehicleName,
    required this.plateNumber,
    required this.date,
    required this.time,
    required this.status,
  }) : super._();

  factory _$CustomerBookingEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomerBookingEntityImplFromJson(json);

  @override
  final String service;
  @override
  final String vehicleName;
  @override
  final String plateNumber;
  @override
  final String date;
  @override
  final String time;
  @override
  final BookingStatus status;

  @override
  String toString() {
    return 'CustomerBookingEntity(service: $service, vehicleName: $vehicleName, plateNumber: $plateNumber, date: $date, time: $time, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomerBookingEntityImpl &&
            (identical(other.service, service) || other.service == service) &&
            (identical(other.vehicleName, vehicleName) ||
                other.vehicleName == vehicleName) &&
            (identical(other.plateNumber, plateNumber) ||
                other.plateNumber == plateNumber) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    service,
    vehicleName,
    plateNumber,
    date,
    time,
    status,
  );

  /// Create a copy of CustomerBookingEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomerBookingEntityImplCopyWith<_$CustomerBookingEntityImpl>
  get copyWith =>
      __$$CustomerBookingEntityImplCopyWithImpl<_$CustomerBookingEntityImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomerBookingEntityImplToJson(this);
  }
}

abstract class _CustomerBookingEntity extends CustomerBookingEntity {
  const factory _CustomerBookingEntity({
    required final String service,
    required final String vehicleName,
    required final String plateNumber,
    required final String date,
    required final String time,
    required final BookingStatus status,
  }) = _$CustomerBookingEntityImpl;
  const _CustomerBookingEntity._() : super._();

  factory _CustomerBookingEntity.fromJson(Map<String, dynamic> json) =
      _$CustomerBookingEntityImpl.fromJson;

  @override
  String get service;
  @override
  String get vehicleName;
  @override
  String get plateNumber;
  @override
  String get date;
  @override
  String get time;
  @override
  BookingStatus get status;

  /// Create a copy of CustomerBookingEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomerBookingEntityImplCopyWith<_$CustomerBookingEntityImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ServiceStageEntity _$ServiceStageEntityFromJson(Map<String, dynamic> json) {
  return _ServiceStageEntity.fromJson(json);
}

/// @nodoc
mixin _$ServiceStageEntity {
  String get name => throw _privateConstructorUsedError;
  String? get time => throw _privateConstructorUsedError;
  StageStatus get status => throw _privateConstructorUsedError;

  /// Serializes this ServiceStageEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ServiceStageEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ServiceStageEntityCopyWith<ServiceStageEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServiceStageEntityCopyWith<$Res> {
  factory $ServiceStageEntityCopyWith(
    ServiceStageEntity value,
    $Res Function(ServiceStageEntity) then,
  ) = _$ServiceStageEntityCopyWithImpl<$Res, ServiceStageEntity>;
  @useResult
  $Res call({String name, String? time, StageStatus status});
}

/// @nodoc
class _$ServiceStageEntityCopyWithImpl<$Res, $Val extends ServiceStageEntity>
    implements $ServiceStageEntityCopyWith<$Res> {
  _$ServiceStageEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ServiceStageEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? time = freezed,
    Object? status = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            time: freezed == time
                ? _value.time
                : time // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as StageStatus,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ServiceStageEntityImplCopyWith<$Res>
    implements $ServiceStageEntityCopyWith<$Res> {
  factory _$$ServiceStageEntityImplCopyWith(
    _$ServiceStageEntityImpl value,
    $Res Function(_$ServiceStageEntityImpl) then,
  ) = __$$ServiceStageEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String? time, StageStatus status});
}

/// @nodoc
class __$$ServiceStageEntityImplCopyWithImpl<$Res>
    extends _$ServiceStageEntityCopyWithImpl<$Res, _$ServiceStageEntityImpl>
    implements _$$ServiceStageEntityImplCopyWith<$Res> {
  __$$ServiceStageEntityImplCopyWithImpl(
    _$ServiceStageEntityImpl _value,
    $Res Function(_$ServiceStageEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ServiceStageEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? time = freezed,
    Object? status = null,
  }) {
    return _then(
      _$ServiceStageEntityImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        time: freezed == time
            ? _value.time
            : time // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as StageStatus,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ServiceStageEntityImpl implements _ServiceStageEntity {
  const _$ServiceStageEntityImpl({
    required this.name,
    this.time,
    required this.status,
  });

  factory _$ServiceStageEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$ServiceStageEntityImplFromJson(json);

  @override
  final String name;
  @override
  final String? time;
  @override
  final StageStatus status;

  @override
  String toString() {
    return 'ServiceStageEntity(name: $name, time: $time, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServiceStageEntityImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, time, status);

  /// Create a copy of ServiceStageEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ServiceStageEntityImplCopyWith<_$ServiceStageEntityImpl> get copyWith =>
      __$$ServiceStageEntityImplCopyWithImpl<_$ServiceStageEntityImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ServiceStageEntityImplToJson(this);
  }
}

abstract class _ServiceStageEntity implements ServiceStageEntity {
  const factory _ServiceStageEntity({
    required final String name,
    final String? time,
    required final StageStatus status,
  }) = _$ServiceStageEntityImpl;

  factory _ServiceStageEntity.fromJson(Map<String, dynamic> json) =
      _$ServiceStageEntityImpl.fromJson;

  @override
  String get name;
  @override
  String? get time;
  @override
  StageStatus get status;

  /// Create a copy of ServiceStageEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ServiceStageEntityImplCopyWith<_$ServiceStageEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CustomerServiceEntity _$CustomerServiceEntityFromJson(
  Map<String, dynamic> json,
) {
  return _CustomerServiceEntity.fromJson(json);
}

/// @nodoc
mixin _$CustomerServiceEntity {
  String get jobCardId => throw _privateConstructorUsedError;
  String get plateNumber => throw _privateConstructorUsedError;
  String get vehicleName => throw _privateConstructorUsedError;
  String get service => throw _privateConstructorUsedError;
  String get started => throw _privateConstructorUsedError;
  String get estCompletion => throw _privateConstructorUsedError;
  int get progressPercent => throw _privateConstructorUsedError;
  String get currentStage => throw _privateConstructorUsedError;
  String get technicianName => throw _privateConstructorUsedError;
  List<ServiceStageEntity> get stages => throw _privateConstructorUsedError;

  /// Serializes this CustomerServiceEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CustomerServiceEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CustomerServiceEntityCopyWith<CustomerServiceEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomerServiceEntityCopyWith<$Res> {
  factory $CustomerServiceEntityCopyWith(
    CustomerServiceEntity value,
    $Res Function(CustomerServiceEntity) then,
  ) = _$CustomerServiceEntityCopyWithImpl<$Res, CustomerServiceEntity>;
  @useResult
  $Res call({
    String jobCardId,
    String plateNumber,
    String vehicleName,
    String service,
    String started,
    String estCompletion,
    int progressPercent,
    String currentStage,
    String technicianName,
    List<ServiceStageEntity> stages,
  });
}

/// @nodoc
class _$CustomerServiceEntityCopyWithImpl<
  $Res,
  $Val extends CustomerServiceEntity
>
    implements $CustomerServiceEntityCopyWith<$Res> {
  _$CustomerServiceEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CustomerServiceEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? jobCardId = null,
    Object? plateNumber = null,
    Object? vehicleName = null,
    Object? service = null,
    Object? started = null,
    Object? estCompletion = null,
    Object? progressPercent = null,
    Object? currentStage = null,
    Object? technicianName = null,
    Object? stages = null,
  }) {
    return _then(
      _value.copyWith(
            jobCardId: null == jobCardId
                ? _value.jobCardId
                : jobCardId // ignore: cast_nullable_to_non_nullable
                      as String,
            plateNumber: null == plateNumber
                ? _value.plateNumber
                : plateNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            vehicleName: null == vehicleName
                ? _value.vehicleName
                : vehicleName // ignore: cast_nullable_to_non_nullable
                      as String,
            service: null == service
                ? _value.service
                : service // ignore: cast_nullable_to_non_nullable
                      as String,
            started: null == started
                ? _value.started
                : started // ignore: cast_nullable_to_non_nullable
                      as String,
            estCompletion: null == estCompletion
                ? _value.estCompletion
                : estCompletion // ignore: cast_nullable_to_non_nullable
                      as String,
            progressPercent: null == progressPercent
                ? _value.progressPercent
                : progressPercent // ignore: cast_nullable_to_non_nullable
                      as int,
            currentStage: null == currentStage
                ? _value.currentStage
                : currentStage // ignore: cast_nullable_to_non_nullable
                      as String,
            technicianName: null == technicianName
                ? _value.technicianName
                : technicianName // ignore: cast_nullable_to_non_nullable
                      as String,
            stages: null == stages
                ? _value.stages
                : stages // ignore: cast_nullable_to_non_nullable
                      as List<ServiceStageEntity>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CustomerServiceEntityImplCopyWith<$Res>
    implements $CustomerServiceEntityCopyWith<$Res> {
  factory _$$CustomerServiceEntityImplCopyWith(
    _$CustomerServiceEntityImpl value,
    $Res Function(_$CustomerServiceEntityImpl) then,
  ) = __$$CustomerServiceEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String jobCardId,
    String plateNumber,
    String vehicleName,
    String service,
    String started,
    String estCompletion,
    int progressPercent,
    String currentStage,
    String technicianName,
    List<ServiceStageEntity> stages,
  });
}

/// @nodoc
class __$$CustomerServiceEntityImplCopyWithImpl<$Res>
    extends
        _$CustomerServiceEntityCopyWithImpl<$Res, _$CustomerServiceEntityImpl>
    implements _$$CustomerServiceEntityImplCopyWith<$Res> {
  __$$CustomerServiceEntityImplCopyWithImpl(
    _$CustomerServiceEntityImpl _value,
    $Res Function(_$CustomerServiceEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CustomerServiceEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? jobCardId = null,
    Object? plateNumber = null,
    Object? vehicleName = null,
    Object? service = null,
    Object? started = null,
    Object? estCompletion = null,
    Object? progressPercent = null,
    Object? currentStage = null,
    Object? technicianName = null,
    Object? stages = null,
  }) {
    return _then(
      _$CustomerServiceEntityImpl(
        jobCardId: null == jobCardId
            ? _value.jobCardId
            : jobCardId // ignore: cast_nullable_to_non_nullable
                  as String,
        plateNumber: null == plateNumber
            ? _value.plateNumber
            : plateNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        vehicleName: null == vehicleName
            ? _value.vehicleName
            : vehicleName // ignore: cast_nullable_to_non_nullable
                  as String,
        service: null == service
            ? _value.service
            : service // ignore: cast_nullable_to_non_nullable
                  as String,
        started: null == started
            ? _value.started
            : started // ignore: cast_nullable_to_non_nullable
                  as String,
        estCompletion: null == estCompletion
            ? _value.estCompletion
            : estCompletion // ignore: cast_nullable_to_non_nullable
                  as String,
        progressPercent: null == progressPercent
            ? _value.progressPercent
            : progressPercent // ignore: cast_nullable_to_non_nullable
                  as int,
        currentStage: null == currentStage
            ? _value.currentStage
            : currentStage // ignore: cast_nullable_to_non_nullable
                  as String,
        technicianName: null == technicianName
            ? _value.technicianName
            : technicianName // ignore: cast_nullable_to_non_nullable
                  as String,
        stages: null == stages
            ? _value._stages
            : stages // ignore: cast_nullable_to_non_nullable
                  as List<ServiceStageEntity>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomerServiceEntityImpl implements _CustomerServiceEntity {
  const _$CustomerServiceEntityImpl({
    required this.jobCardId,
    required this.plateNumber,
    required this.vehicleName,
    required this.service,
    required this.started,
    required this.estCompletion,
    required this.progressPercent,
    required this.currentStage,
    required this.technicianName,
    required final List<ServiceStageEntity> stages,
  }) : _stages = stages;

  factory _$CustomerServiceEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomerServiceEntityImplFromJson(json);

  @override
  final String jobCardId;
  @override
  final String plateNumber;
  @override
  final String vehicleName;
  @override
  final String service;
  @override
  final String started;
  @override
  final String estCompletion;
  @override
  final int progressPercent;
  @override
  final String currentStage;
  @override
  final String technicianName;
  final List<ServiceStageEntity> _stages;
  @override
  List<ServiceStageEntity> get stages {
    if (_stages is EqualUnmodifiableListView) return _stages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_stages);
  }

  @override
  String toString() {
    return 'CustomerServiceEntity(jobCardId: $jobCardId, plateNumber: $plateNumber, vehicleName: $vehicleName, service: $service, started: $started, estCompletion: $estCompletion, progressPercent: $progressPercent, currentStage: $currentStage, technicianName: $technicianName, stages: $stages)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomerServiceEntityImpl &&
            (identical(other.jobCardId, jobCardId) ||
                other.jobCardId == jobCardId) &&
            (identical(other.plateNumber, plateNumber) ||
                other.plateNumber == plateNumber) &&
            (identical(other.vehicleName, vehicleName) ||
                other.vehicleName == vehicleName) &&
            (identical(other.service, service) || other.service == service) &&
            (identical(other.started, started) || other.started == started) &&
            (identical(other.estCompletion, estCompletion) ||
                other.estCompletion == estCompletion) &&
            (identical(other.progressPercent, progressPercent) ||
                other.progressPercent == progressPercent) &&
            (identical(other.currentStage, currentStage) ||
                other.currentStage == currentStage) &&
            (identical(other.technicianName, technicianName) ||
                other.technicianName == technicianName) &&
            const DeepCollectionEquality().equals(other._stages, _stages));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    jobCardId,
    plateNumber,
    vehicleName,
    service,
    started,
    estCompletion,
    progressPercent,
    currentStage,
    technicianName,
    const DeepCollectionEquality().hash(_stages),
  );

  /// Create a copy of CustomerServiceEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomerServiceEntityImplCopyWith<_$CustomerServiceEntityImpl>
  get copyWith =>
      __$$CustomerServiceEntityImplCopyWithImpl<_$CustomerServiceEntityImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomerServiceEntityImplToJson(this);
  }
}

abstract class _CustomerServiceEntity implements CustomerServiceEntity {
  const factory _CustomerServiceEntity({
    required final String jobCardId,
    required final String plateNumber,
    required final String vehicleName,
    required final String service,
    required final String started,
    required final String estCompletion,
    required final int progressPercent,
    required final String currentStage,
    required final String technicianName,
    required final List<ServiceStageEntity> stages,
  }) = _$CustomerServiceEntityImpl;

  factory _CustomerServiceEntity.fromJson(Map<String, dynamic> json) =
      _$CustomerServiceEntityImpl.fromJson;

  @override
  String get jobCardId;
  @override
  String get plateNumber;
  @override
  String get vehicleName;
  @override
  String get service;
  @override
  String get started;
  @override
  String get estCompletion;
  @override
  int get progressPercent;
  @override
  String get currentStage;
  @override
  String get technicianName;
  @override
  List<ServiceStageEntity> get stages;

  /// Create a copy of CustomerServiceEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomerServiceEntityImplCopyWith<_$CustomerServiceEntityImpl>
  get copyWith => throw _privateConstructorUsedError;
}

CustomerNotificationEntity _$CustomerNotificationEntityFromJson(
  Map<String, dynamic> json,
) {
  return _CustomerNotificationEntity.fromJson(json);
}

/// @nodoc
mixin _$CustomerNotificationEntity {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  String get time => throw _privateConstructorUsedError;
  NotifType get type => throw _privateConstructorUsedError;
  bool get isRead => throw _privateConstructorUsedError;

  /// Serializes this CustomerNotificationEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CustomerNotificationEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CustomerNotificationEntityCopyWith<CustomerNotificationEntity>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomerNotificationEntityCopyWith<$Res> {
  factory $CustomerNotificationEntityCopyWith(
    CustomerNotificationEntity value,
    $Res Function(CustomerNotificationEntity) then,
  ) =
      _$CustomerNotificationEntityCopyWithImpl<
        $Res,
        CustomerNotificationEntity
      >;
  @useResult
  $Res call({
    String id,
    String title,
    String body,
    String time,
    NotifType type,
    bool isRead,
  });
}

/// @nodoc
class _$CustomerNotificationEntityCopyWithImpl<
  $Res,
  $Val extends CustomerNotificationEntity
>
    implements $CustomerNotificationEntityCopyWith<$Res> {
  _$CustomerNotificationEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CustomerNotificationEntity
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
                      as NotifType,
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
abstract class _$$CustomerNotificationEntityImplCopyWith<$Res>
    implements $CustomerNotificationEntityCopyWith<$Res> {
  factory _$$CustomerNotificationEntityImplCopyWith(
    _$CustomerNotificationEntityImpl value,
    $Res Function(_$CustomerNotificationEntityImpl) then,
  ) = __$$CustomerNotificationEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String body,
    String time,
    NotifType type,
    bool isRead,
  });
}

/// @nodoc
class __$$CustomerNotificationEntityImplCopyWithImpl<$Res>
    extends
        _$CustomerNotificationEntityCopyWithImpl<
          $Res,
          _$CustomerNotificationEntityImpl
        >
    implements _$$CustomerNotificationEntityImplCopyWith<$Res> {
  __$$CustomerNotificationEntityImplCopyWithImpl(
    _$CustomerNotificationEntityImpl _value,
    $Res Function(_$CustomerNotificationEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CustomerNotificationEntity
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
      _$CustomerNotificationEntityImpl(
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
                  as NotifType,
        isRead: null == isRead
            ? _value.isRead
            : isRead // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomerNotificationEntityImpl implements _CustomerNotificationEntity {
  const _$CustomerNotificationEntityImpl({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    this.isRead = false,
  });

  factory _$CustomerNotificationEntityImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$CustomerNotificationEntityImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String body;
  @override
  final String time;
  @override
  final NotifType type;
  @override
  @JsonKey()
  final bool isRead;

  @override
  String toString() {
    return 'CustomerNotificationEntity(id: $id, title: $title, body: $body, time: $time, type: $type, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomerNotificationEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.isRead, isRead) || other.isRead == isRead));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, title, body, time, type, isRead);

  /// Create a copy of CustomerNotificationEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomerNotificationEntityImplCopyWith<_$CustomerNotificationEntityImpl>
  get copyWith =>
      __$$CustomerNotificationEntityImplCopyWithImpl<
        _$CustomerNotificationEntityImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomerNotificationEntityImplToJson(this);
  }
}

abstract class _CustomerNotificationEntity
    implements CustomerNotificationEntity {
  const factory _CustomerNotificationEntity({
    required final String id,
    required final String title,
    required final String body,
    required final String time,
    required final NotifType type,
    final bool isRead,
  }) = _$CustomerNotificationEntityImpl;

  factory _CustomerNotificationEntity.fromJson(Map<String, dynamic> json) =
      _$CustomerNotificationEntityImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get body;
  @override
  String get time;
  @override
  NotifType get type;
  @override
  bool get isRead;

  /// Create a copy of CustomerNotificationEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomerNotificationEntityImplCopyWith<_$CustomerNotificationEntityImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ServiceTypeEntity _$ServiceTypeEntityFromJson(Map<String, dynamic> json) {
  return _ServiceTypeEntity.fromJson(json);
}

/// @nodoc
mixin _$ServiceTypeEntity {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get price => throw _privateConstructorUsedError;
  String get duration => throw _privateConstructorUsedError;

  /// Serializes this ServiceTypeEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ServiceTypeEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ServiceTypeEntityCopyWith<ServiceTypeEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServiceTypeEntityCopyWith<$Res> {
  factory $ServiceTypeEntityCopyWith(
    ServiceTypeEntity value,
    $Res Function(ServiceTypeEntity) then,
  ) = _$ServiceTypeEntityCopyWithImpl<$Res, ServiceTypeEntity>;
  @useResult
  $Res call({String id, String name, String price, String duration});
}

/// @nodoc
class _$ServiceTypeEntityCopyWithImpl<$Res, $Val extends ServiceTypeEntity>
    implements $ServiceTypeEntityCopyWith<$Res> {
  _$ServiceTypeEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ServiceTypeEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? price = null,
    Object? duration = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as String,
            duration: null == duration
                ? _value.duration
                : duration // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ServiceTypeEntityImplCopyWith<$Res>
    implements $ServiceTypeEntityCopyWith<$Res> {
  factory _$$ServiceTypeEntityImplCopyWith(
    _$ServiceTypeEntityImpl value,
    $Res Function(_$ServiceTypeEntityImpl) then,
  ) = __$$ServiceTypeEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, String price, String duration});
}

/// @nodoc
class __$$ServiceTypeEntityImplCopyWithImpl<$Res>
    extends _$ServiceTypeEntityCopyWithImpl<$Res, _$ServiceTypeEntityImpl>
    implements _$$ServiceTypeEntityImplCopyWith<$Res> {
  __$$ServiceTypeEntityImplCopyWithImpl(
    _$ServiceTypeEntityImpl _value,
    $Res Function(_$ServiceTypeEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ServiceTypeEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? price = null,
    Object? duration = null,
  }) {
    return _then(
      _$ServiceTypeEntityImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as String,
        duration: null == duration
            ? _value.duration
            : duration // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ServiceTypeEntityImpl implements _ServiceTypeEntity {
  const _$ServiceTypeEntityImpl({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
  });

  factory _$ServiceTypeEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$ServiceTypeEntityImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String price;
  @override
  final String duration;

  @override
  String toString() {
    return 'ServiceTypeEntity(id: $id, name: $name, price: $price, duration: $duration)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServiceTypeEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.duration, duration) ||
                other.duration == duration));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, price, duration);

  /// Create a copy of ServiceTypeEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ServiceTypeEntityImplCopyWith<_$ServiceTypeEntityImpl> get copyWith =>
      __$$ServiceTypeEntityImplCopyWithImpl<_$ServiceTypeEntityImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ServiceTypeEntityImplToJson(this);
  }
}

abstract class _ServiceTypeEntity implements ServiceTypeEntity {
  const factory _ServiceTypeEntity({
    required final String id,
    required final String name,
    required final String price,
    required final String duration,
  }) = _$ServiceTypeEntityImpl;

  factory _ServiceTypeEntity.fromJson(Map<String, dynamic> json) =
      _$ServiceTypeEntityImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get price;
  @override
  String get duration;

  /// Create a copy of ServiceTypeEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ServiceTypeEntityImplCopyWith<_$ServiceTypeEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
