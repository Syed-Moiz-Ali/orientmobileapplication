// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'work_task_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WorkTaskEntity _$WorkTaskEntityFromJson(Map<String, dynamic> json) {
  return _WorkTaskEntity.fromJson(json);
}

/// @nodoc
mixin _$WorkTaskEntity {
  int get id => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  TaskStatus get status => throw _privateConstructorUsedError;
  String? get startTime => throw _privateConstructorUsedError;
  String? get endTime => throw _privateConstructorUsedError;

  /// Serializes this WorkTaskEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorkTaskEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkTaskEntityCopyWith<WorkTaskEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkTaskEntityCopyWith<$Res> {
  factory $WorkTaskEntityCopyWith(
    WorkTaskEntity value,
    $Res Function(WorkTaskEntity) then,
  ) = _$WorkTaskEntityCopyWithImpl<$Res, WorkTaskEntity>;
  @useResult
  $Res call({
    int id,
    String description,
    TaskStatus status,
    String? startTime,
    String? endTime,
  });
}

/// @nodoc
class _$WorkTaskEntityCopyWithImpl<$Res, $Val extends WorkTaskEntity>
    implements $WorkTaskEntityCopyWith<$Res> {
  _$WorkTaskEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkTaskEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? description = null,
    Object? status = null,
    Object? startTime = freezed,
    Object? endTime = freezed,
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
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as TaskStatus,
            startTime: freezed == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                      as String?,
            endTime: freezed == endTime
                ? _value.endTime
                : endTime // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WorkTaskEntityImplCopyWith<$Res>
    implements $WorkTaskEntityCopyWith<$Res> {
  factory _$$WorkTaskEntityImplCopyWith(
    _$WorkTaskEntityImpl value,
    $Res Function(_$WorkTaskEntityImpl) then,
  ) = __$$WorkTaskEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String description,
    TaskStatus status,
    String? startTime,
    String? endTime,
  });
}

/// @nodoc
class __$$WorkTaskEntityImplCopyWithImpl<$Res>
    extends _$WorkTaskEntityCopyWithImpl<$Res, _$WorkTaskEntityImpl>
    implements _$$WorkTaskEntityImplCopyWith<$Res> {
  __$$WorkTaskEntityImplCopyWithImpl(
    _$WorkTaskEntityImpl _value,
    $Res Function(_$WorkTaskEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WorkTaskEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? description = null,
    Object? status = null,
    Object? startTime = freezed,
    Object? endTime = freezed,
  }) {
    return _then(
      _$WorkTaskEntityImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as TaskStatus,
        startTime: freezed == startTime
            ? _value.startTime
            : startTime // ignore: cast_nullable_to_non_nullable
                  as String?,
        endTime: freezed == endTime
            ? _value.endTime
            : endTime // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkTaskEntityImpl implements _WorkTaskEntity {
  const _$WorkTaskEntityImpl({
    required this.id,
    required this.description,
    this.status = TaskStatus.pending,
    this.startTime,
    this.endTime,
  });

  factory _$WorkTaskEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkTaskEntityImplFromJson(json);

  @override
  final int id;
  @override
  final String description;
  @override
  @JsonKey()
  final TaskStatus status;
  @override
  final String? startTime;
  @override
  final String? endTime;

  @override
  String toString() {
    return 'WorkTaskEntity(id: $id, description: $description, status: $status, startTime: $startTime, endTime: $endTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkTaskEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, description, status, startTime, endTime);

  /// Create a copy of WorkTaskEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkTaskEntityImplCopyWith<_$WorkTaskEntityImpl> get copyWith =>
      __$$WorkTaskEntityImplCopyWithImpl<_$WorkTaskEntityImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkTaskEntityImplToJson(this);
  }
}

abstract class _WorkTaskEntity implements WorkTaskEntity {
  const factory _WorkTaskEntity({
    required final int id,
    required final String description,
    final TaskStatus status,
    final String? startTime,
    final String? endTime,
  }) = _$WorkTaskEntityImpl;

  factory _WorkTaskEntity.fromJson(Map<String, dynamic> json) =
      _$WorkTaskEntityImpl.fromJson;

  @override
  int get id;
  @override
  String get description;
  @override
  TaskStatus get status;
  @override
  String? get startTime;
  @override
  String? get endTime;

  /// Create a copy of WorkTaskEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkTaskEntityImplCopyWith<_$WorkTaskEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
