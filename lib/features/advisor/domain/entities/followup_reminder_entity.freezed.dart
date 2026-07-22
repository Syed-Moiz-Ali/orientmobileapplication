// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'followup_reminder_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$FollowupReminderEntity {
  String get customerName => throw _privateConstructorUsedError;
  String get vehicleId => throw _privateConstructorUsedError;
  String get task => throw _privateConstructorUsedError;
  String get dueDate => throw _privateConstructorUsedError;
  ReminderPriority get priority => throw _privateConstructorUsedError;

  /// Create a copy of FollowupReminderEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FollowupReminderEntityCopyWith<FollowupReminderEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FollowupReminderEntityCopyWith<$Res> {
  factory $FollowupReminderEntityCopyWith(
    FollowupReminderEntity value,
    $Res Function(FollowupReminderEntity) then,
  ) = _$FollowupReminderEntityCopyWithImpl<$Res, FollowupReminderEntity>;
  @useResult
  $Res call({
    String customerName,
    String vehicleId,
    String task,
    String dueDate,
    ReminderPriority priority,
  });
}

/// @nodoc
class _$FollowupReminderEntityCopyWithImpl<
  $Res,
  $Val extends FollowupReminderEntity
>
    implements $FollowupReminderEntityCopyWith<$Res> {
  _$FollowupReminderEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FollowupReminderEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customerName = null,
    Object? vehicleId = null,
    Object? task = null,
    Object? dueDate = null,
    Object? priority = null,
  }) {
    return _then(
      _value.copyWith(
            customerName: null == customerName
                ? _value.customerName
                : customerName // ignore: cast_nullable_to_non_nullable
                      as String,
            vehicleId: null == vehicleId
                ? _value.vehicleId
                : vehicleId // ignore: cast_nullable_to_non_nullable
                      as String,
            task: null == task
                ? _value.task
                : task // ignore: cast_nullable_to_non_nullable
                      as String,
            dueDate: null == dueDate
                ? _value.dueDate
                : dueDate // ignore: cast_nullable_to_non_nullable
                      as String,
            priority: null == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                      as ReminderPriority,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FollowupReminderEntityImplCopyWith<$Res>
    implements $FollowupReminderEntityCopyWith<$Res> {
  factory _$$FollowupReminderEntityImplCopyWith(
    _$FollowupReminderEntityImpl value,
    $Res Function(_$FollowupReminderEntityImpl) then,
  ) = __$$FollowupReminderEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String customerName,
    String vehicleId,
    String task,
    String dueDate,
    ReminderPriority priority,
  });
}

/// @nodoc
class __$$FollowupReminderEntityImplCopyWithImpl<$Res>
    extends
        _$FollowupReminderEntityCopyWithImpl<$Res, _$FollowupReminderEntityImpl>
    implements _$$FollowupReminderEntityImplCopyWith<$Res> {
  __$$FollowupReminderEntityImplCopyWithImpl(
    _$FollowupReminderEntityImpl _value,
    $Res Function(_$FollowupReminderEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FollowupReminderEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? customerName = null,
    Object? vehicleId = null,
    Object? task = null,
    Object? dueDate = null,
    Object? priority = null,
  }) {
    return _then(
      _$FollowupReminderEntityImpl(
        customerName: null == customerName
            ? _value.customerName
            : customerName // ignore: cast_nullable_to_non_nullable
                  as String,
        vehicleId: null == vehicleId
            ? _value.vehicleId
            : vehicleId // ignore: cast_nullable_to_non_nullable
                  as String,
        task: null == task
            ? _value.task
            : task // ignore: cast_nullable_to_non_nullable
                  as String,
        dueDate: null == dueDate
            ? _value.dueDate
            : dueDate // ignore: cast_nullable_to_non_nullable
                  as String,
        priority: null == priority
            ? _value.priority
            : priority // ignore: cast_nullable_to_non_nullable
                  as ReminderPriority,
      ),
    );
  }
}

/// @nodoc

class _$FollowupReminderEntityImpl implements _FollowupReminderEntity {
  const _$FollowupReminderEntityImpl({
    required this.customerName,
    required this.vehicleId,
    required this.task,
    required this.dueDate,
    required this.priority,
  });

  @override
  final String customerName;
  @override
  final String vehicleId;
  @override
  final String task;
  @override
  final String dueDate;
  @override
  final ReminderPriority priority;

  @override
  String toString() {
    return 'FollowupReminderEntity(customerName: $customerName, vehicleId: $vehicleId, task: $task, dueDate: $dueDate, priority: $priority)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FollowupReminderEntityImpl &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.vehicleId, vehicleId) ||
                other.vehicleId == vehicleId) &&
            (identical(other.task, task) || other.task == task) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.priority, priority) ||
                other.priority == priority));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    customerName,
    vehicleId,
    task,
    dueDate,
    priority,
  );

  /// Create a copy of FollowupReminderEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FollowupReminderEntityImplCopyWith<_$FollowupReminderEntityImpl>
  get copyWith =>
      __$$FollowupReminderEntityImplCopyWithImpl<_$FollowupReminderEntityImpl>(
        this,
        _$identity,
      );
}

abstract class _FollowupReminderEntity implements FollowupReminderEntity {
  const factory _FollowupReminderEntity({
    required final String customerName,
    required final String vehicleId,
    required final String task,
    required final String dueDate,
    required final ReminderPriority priority,
  }) = _$FollowupReminderEntityImpl;

  @override
  String get customerName;
  @override
  String get vehicleId;
  @override
  String get task;
  @override
  String get dueDate;
  @override
  ReminderPriority get priority;

  /// Create a copy of FollowupReminderEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FollowupReminderEntityImplCopyWith<_$FollowupReminderEntityImpl>
  get copyWith => throw _privateConstructorUsedError;
}
