// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'technician_entities.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TechnicianProfileEntity {
  String get name => throw _privateConstructorUsedError;
  String get empId => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;
  String get branch => throw _privateConstructorUsedError;
  String get shift => throw _privateConstructorUsedError;
  String get avatarInitials => throw _privateConstructorUsedError;

  /// Create a copy of TechnicianProfileEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TechnicianProfileEntityCopyWith<TechnicianProfileEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TechnicianProfileEntityCopyWith<$Res> {
  factory $TechnicianProfileEntityCopyWith(
    TechnicianProfileEntity value,
    $Res Function(TechnicianProfileEntity) then,
  ) = _$TechnicianProfileEntityCopyWithImpl<$Res, TechnicianProfileEntity>;
  @useResult
  $Res call({
    String name,
    String empId,
    String role,
    String branch,
    String shift,
    String avatarInitials,
  });
}

/// @nodoc
class _$TechnicianProfileEntityCopyWithImpl<
  $Res,
  $Val extends TechnicianProfileEntity
>
    implements $TechnicianProfileEntityCopyWith<$Res> {
  _$TechnicianProfileEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TechnicianProfileEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? empId = null,
    Object? role = null,
    Object? branch = null,
    Object? shift = null,
    Object? avatarInitials = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            empId: null == empId
                ? _value.empId
                : empId // ignore: cast_nullable_to_non_nullable
                      as String,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String,
            branch: null == branch
                ? _value.branch
                : branch // ignore: cast_nullable_to_non_nullable
                      as String,
            shift: null == shift
                ? _value.shift
                : shift // ignore: cast_nullable_to_non_nullable
                      as String,
            avatarInitials: null == avatarInitials
                ? _value.avatarInitials
                : avatarInitials // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TechnicianProfileEntityImplCopyWith<$Res>
    implements $TechnicianProfileEntityCopyWith<$Res> {
  factory _$$TechnicianProfileEntityImplCopyWith(
    _$TechnicianProfileEntityImpl value,
    $Res Function(_$TechnicianProfileEntityImpl) then,
  ) = __$$TechnicianProfileEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    String empId,
    String role,
    String branch,
    String shift,
    String avatarInitials,
  });
}

/// @nodoc
class __$$TechnicianProfileEntityImplCopyWithImpl<$Res>
    extends
        _$TechnicianProfileEntityCopyWithImpl<
          $Res,
          _$TechnicianProfileEntityImpl
        >
    implements _$$TechnicianProfileEntityImplCopyWith<$Res> {
  __$$TechnicianProfileEntityImplCopyWithImpl(
    _$TechnicianProfileEntityImpl _value,
    $Res Function(_$TechnicianProfileEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TechnicianProfileEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? empId = null,
    Object? role = null,
    Object? branch = null,
    Object? shift = null,
    Object? avatarInitials = null,
  }) {
    return _then(
      _$TechnicianProfileEntityImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        empId: null == empId
            ? _value.empId
            : empId // ignore: cast_nullable_to_non_nullable
                  as String,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String,
        branch: null == branch
            ? _value.branch
            : branch // ignore: cast_nullable_to_non_nullable
                  as String,
        shift: null == shift
            ? _value.shift
            : shift // ignore: cast_nullable_to_non_nullable
                  as String,
        avatarInitials: null == avatarInitials
            ? _value.avatarInitials
            : avatarInitials // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$TechnicianProfileEntityImpl implements _TechnicianProfileEntity {
  const _$TechnicianProfileEntityImpl({
    required this.name,
    required this.empId,
    required this.role,
    required this.branch,
    required this.shift,
    required this.avatarInitials,
  });

  @override
  final String name;
  @override
  final String empId;
  @override
  final String role;
  @override
  final String branch;
  @override
  final String shift;
  @override
  final String avatarInitials;

  @override
  String toString() {
    return 'TechnicianProfileEntity(name: $name, empId: $empId, role: $role, branch: $branch, shift: $shift, avatarInitials: $avatarInitials)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TechnicianProfileEntityImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.empId, empId) || other.empId == empId) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.branch, branch) || other.branch == branch) &&
            (identical(other.shift, shift) || other.shift == shift) &&
            (identical(other.avatarInitials, avatarInitials) ||
                other.avatarInitials == avatarInitials));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    empId,
    role,
    branch,
    shift,
    avatarInitials,
  );

  /// Create a copy of TechnicianProfileEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TechnicianProfileEntityImplCopyWith<_$TechnicianProfileEntityImpl>
  get copyWith =>
      __$$TechnicianProfileEntityImplCopyWithImpl<
        _$TechnicianProfileEntityImpl
      >(this, _$identity);
}

abstract class _TechnicianProfileEntity implements TechnicianProfileEntity {
  const factory _TechnicianProfileEntity({
    required final String name,
    required final String empId,
    required final String role,
    required final String branch,
    required final String shift,
    required final String avatarInitials,
  }) = _$TechnicianProfileEntityImpl;

  @override
  String get name;
  @override
  String get empId;
  @override
  String get role;
  @override
  String get branch;
  @override
  String get shift;
  @override
  String get avatarInitials;

  /// Create a copy of TechnicianProfileEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TechnicianProfileEntityImplCopyWith<_$TechnicianProfileEntityImpl>
  get copyWith => throw _privateConstructorUsedError;
}

AttendanceSummaryEntity _$AttendanceSummaryEntityFromJson(
  Map<String, dynamic> json,
) {
  return _AttendanceSummaryEntity.fromJson(json);
}

/// @nodoc
mixin _$AttendanceSummaryEntity {
  String get punchIn => throw _privateConstructorUsedError;
  String get punchOut => throw _privateConstructorUsedError;
  String get breakTime => throw _privateConstructorUsedError;
  String get workHours => throw _privateConstructorUsedError;

  /// Serializes this AttendanceSummaryEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AttendanceSummaryEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AttendanceSummaryEntityCopyWith<AttendanceSummaryEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AttendanceSummaryEntityCopyWith<$Res> {
  factory $AttendanceSummaryEntityCopyWith(
    AttendanceSummaryEntity value,
    $Res Function(AttendanceSummaryEntity) then,
  ) = _$AttendanceSummaryEntityCopyWithImpl<$Res, AttendanceSummaryEntity>;
  @useResult
  $Res call({
    String punchIn,
    String punchOut,
    String breakTime,
    String workHours,
  });
}

/// @nodoc
class _$AttendanceSummaryEntityCopyWithImpl<
  $Res,
  $Val extends AttendanceSummaryEntity
>
    implements $AttendanceSummaryEntityCopyWith<$Res> {
  _$AttendanceSummaryEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AttendanceSummaryEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? punchIn = null,
    Object? punchOut = null,
    Object? breakTime = null,
    Object? workHours = null,
  }) {
    return _then(
      _value.copyWith(
            punchIn: null == punchIn
                ? _value.punchIn
                : punchIn // ignore: cast_nullable_to_non_nullable
                      as String,
            punchOut: null == punchOut
                ? _value.punchOut
                : punchOut // ignore: cast_nullable_to_non_nullable
                      as String,
            breakTime: null == breakTime
                ? _value.breakTime
                : breakTime // ignore: cast_nullable_to_non_nullable
                      as String,
            workHours: null == workHours
                ? _value.workHours
                : workHours // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AttendanceSummaryEntityImplCopyWith<$Res>
    implements $AttendanceSummaryEntityCopyWith<$Res> {
  factory _$$AttendanceSummaryEntityImplCopyWith(
    _$AttendanceSummaryEntityImpl value,
    $Res Function(_$AttendanceSummaryEntityImpl) then,
  ) = __$$AttendanceSummaryEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String punchIn,
    String punchOut,
    String breakTime,
    String workHours,
  });
}

/// @nodoc
class __$$AttendanceSummaryEntityImplCopyWithImpl<$Res>
    extends
        _$AttendanceSummaryEntityCopyWithImpl<
          $Res,
          _$AttendanceSummaryEntityImpl
        >
    implements _$$AttendanceSummaryEntityImplCopyWith<$Res> {
  __$$AttendanceSummaryEntityImplCopyWithImpl(
    _$AttendanceSummaryEntityImpl _value,
    $Res Function(_$AttendanceSummaryEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AttendanceSummaryEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? punchIn = null,
    Object? punchOut = null,
    Object? breakTime = null,
    Object? workHours = null,
  }) {
    return _then(
      _$AttendanceSummaryEntityImpl(
        punchIn: null == punchIn
            ? _value.punchIn
            : punchIn // ignore: cast_nullable_to_non_nullable
                  as String,
        punchOut: null == punchOut
            ? _value.punchOut
            : punchOut // ignore: cast_nullable_to_non_nullable
                  as String,
        breakTime: null == breakTime
            ? _value.breakTime
            : breakTime // ignore: cast_nullable_to_non_nullable
                  as String,
        workHours: null == workHours
            ? _value.workHours
            : workHours // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AttendanceSummaryEntityImpl implements _AttendanceSummaryEntity {
  const _$AttendanceSummaryEntityImpl({
    this.punchIn = '--:--',
    this.punchOut = '--:--',
    this.breakTime = '0 min',
    this.workHours = '0h 0m',
  });

  factory _$AttendanceSummaryEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$AttendanceSummaryEntityImplFromJson(json);

  @override
  @JsonKey()
  final String punchIn;
  @override
  @JsonKey()
  final String punchOut;
  @override
  @JsonKey()
  final String breakTime;
  @override
  @JsonKey()
  final String workHours;

  @override
  String toString() {
    return 'AttendanceSummaryEntity(punchIn: $punchIn, punchOut: $punchOut, breakTime: $breakTime, workHours: $workHours)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AttendanceSummaryEntityImpl &&
            (identical(other.punchIn, punchIn) || other.punchIn == punchIn) &&
            (identical(other.punchOut, punchOut) ||
                other.punchOut == punchOut) &&
            (identical(other.breakTime, breakTime) ||
                other.breakTime == breakTime) &&
            (identical(other.workHours, workHours) ||
                other.workHours == workHours));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, punchIn, punchOut, breakTime, workHours);

  /// Create a copy of AttendanceSummaryEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AttendanceSummaryEntityImplCopyWith<_$AttendanceSummaryEntityImpl>
  get copyWith =>
      __$$AttendanceSummaryEntityImplCopyWithImpl<
        _$AttendanceSummaryEntityImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AttendanceSummaryEntityImplToJson(this);
  }
}

abstract class _AttendanceSummaryEntity implements AttendanceSummaryEntity {
  const factory _AttendanceSummaryEntity({
    final String punchIn,
    final String punchOut,
    final String breakTime,
    final String workHours,
  }) = _$AttendanceSummaryEntityImpl;

  factory _AttendanceSummaryEntity.fromJson(Map<String, dynamic> json) =
      _$AttendanceSummaryEntityImpl.fromJson;

  @override
  String get punchIn;
  @override
  String get punchOut;
  @override
  String get breakTime;
  @override
  String get workHours;

  /// Create a copy of AttendanceSummaryEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AttendanceSummaryEntityImplCopyWith<_$AttendanceSummaryEntityImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$TechnicianStatsEntity {
  int get assignedJobs => throw _privateConstructorUsedError;
  int get inProgress => throw _privateConstructorUsedError;
  int get completedToday => throw _privateConstructorUsedError;
  double get efficiency => throw _privateConstructorUsedError;
  String get avgTimePerJob => throw _privateConstructorUsedError;
  String get totalHoursWorked => throw _privateConstructorUsedError;

  /// Create a copy of TechnicianStatsEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TechnicianStatsEntityCopyWith<TechnicianStatsEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TechnicianStatsEntityCopyWith<$Res> {
  factory $TechnicianStatsEntityCopyWith(
    TechnicianStatsEntity value,
    $Res Function(TechnicianStatsEntity) then,
  ) = _$TechnicianStatsEntityCopyWithImpl<$Res, TechnicianStatsEntity>;
  @useResult
  $Res call({
    int assignedJobs,
    int inProgress,
    int completedToday,
    double efficiency,
    String avgTimePerJob,
    String totalHoursWorked,
  });
}

/// @nodoc
class _$TechnicianStatsEntityCopyWithImpl<
  $Res,
  $Val extends TechnicianStatsEntity
>
    implements $TechnicianStatsEntityCopyWith<$Res> {
  _$TechnicianStatsEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TechnicianStatsEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? assignedJobs = null,
    Object? inProgress = null,
    Object? completedToday = null,
    Object? efficiency = null,
    Object? avgTimePerJob = null,
    Object? totalHoursWorked = null,
  }) {
    return _then(
      _value.copyWith(
            assignedJobs: null == assignedJobs
                ? _value.assignedJobs
                : assignedJobs // ignore: cast_nullable_to_non_nullable
                      as int,
            inProgress: null == inProgress
                ? _value.inProgress
                : inProgress // ignore: cast_nullable_to_non_nullable
                      as int,
            completedToday: null == completedToday
                ? _value.completedToday
                : completedToday // ignore: cast_nullable_to_non_nullable
                      as int,
            efficiency: null == efficiency
                ? _value.efficiency
                : efficiency // ignore: cast_nullable_to_non_nullable
                      as double,
            avgTimePerJob: null == avgTimePerJob
                ? _value.avgTimePerJob
                : avgTimePerJob // ignore: cast_nullable_to_non_nullable
                      as String,
            totalHoursWorked: null == totalHoursWorked
                ? _value.totalHoursWorked
                : totalHoursWorked // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TechnicianStatsEntityImplCopyWith<$Res>
    implements $TechnicianStatsEntityCopyWith<$Res> {
  factory _$$TechnicianStatsEntityImplCopyWith(
    _$TechnicianStatsEntityImpl value,
    $Res Function(_$TechnicianStatsEntityImpl) then,
  ) = __$$TechnicianStatsEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int assignedJobs,
    int inProgress,
    int completedToday,
    double efficiency,
    String avgTimePerJob,
    String totalHoursWorked,
  });
}

/// @nodoc
class __$$TechnicianStatsEntityImplCopyWithImpl<$Res>
    extends
        _$TechnicianStatsEntityCopyWithImpl<$Res, _$TechnicianStatsEntityImpl>
    implements _$$TechnicianStatsEntityImplCopyWith<$Res> {
  __$$TechnicianStatsEntityImplCopyWithImpl(
    _$TechnicianStatsEntityImpl _value,
    $Res Function(_$TechnicianStatsEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TechnicianStatsEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? assignedJobs = null,
    Object? inProgress = null,
    Object? completedToday = null,
    Object? efficiency = null,
    Object? avgTimePerJob = null,
    Object? totalHoursWorked = null,
  }) {
    return _then(
      _$TechnicianStatsEntityImpl(
        assignedJobs: null == assignedJobs
            ? _value.assignedJobs
            : assignedJobs // ignore: cast_nullable_to_non_nullable
                  as int,
        inProgress: null == inProgress
            ? _value.inProgress
            : inProgress // ignore: cast_nullable_to_non_nullable
                  as int,
        completedToday: null == completedToday
            ? _value.completedToday
            : completedToday // ignore: cast_nullable_to_non_nullable
                  as int,
        efficiency: null == efficiency
            ? _value.efficiency
            : efficiency // ignore: cast_nullable_to_non_nullable
                  as double,
        avgTimePerJob: null == avgTimePerJob
            ? _value.avgTimePerJob
            : avgTimePerJob // ignore: cast_nullable_to_non_nullable
                  as String,
        totalHoursWorked: null == totalHoursWorked
            ? _value.totalHoursWorked
            : totalHoursWorked // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$TechnicianStatsEntityImpl implements _TechnicianStatsEntity {
  const _$TechnicianStatsEntityImpl({
    required this.assignedJobs,
    required this.inProgress,
    required this.completedToday,
    required this.efficiency,
    required this.avgTimePerJob,
    required this.totalHoursWorked,
  });

  @override
  final int assignedJobs;
  @override
  final int inProgress;
  @override
  final int completedToday;
  @override
  final double efficiency;
  @override
  final String avgTimePerJob;
  @override
  final String totalHoursWorked;

  @override
  String toString() {
    return 'TechnicianStatsEntity(assignedJobs: $assignedJobs, inProgress: $inProgress, completedToday: $completedToday, efficiency: $efficiency, avgTimePerJob: $avgTimePerJob, totalHoursWorked: $totalHoursWorked)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TechnicianStatsEntityImpl &&
            (identical(other.assignedJobs, assignedJobs) ||
                other.assignedJobs == assignedJobs) &&
            (identical(other.inProgress, inProgress) ||
                other.inProgress == inProgress) &&
            (identical(other.completedToday, completedToday) ||
                other.completedToday == completedToday) &&
            (identical(other.efficiency, efficiency) ||
                other.efficiency == efficiency) &&
            (identical(other.avgTimePerJob, avgTimePerJob) ||
                other.avgTimePerJob == avgTimePerJob) &&
            (identical(other.totalHoursWorked, totalHoursWorked) ||
                other.totalHoursWorked == totalHoursWorked));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    assignedJobs,
    inProgress,
    completedToday,
    efficiency,
    avgTimePerJob,
    totalHoursWorked,
  );

  /// Create a copy of TechnicianStatsEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TechnicianStatsEntityImplCopyWith<_$TechnicianStatsEntityImpl>
  get copyWith =>
      __$$TechnicianStatsEntityImplCopyWithImpl<_$TechnicianStatsEntityImpl>(
        this,
        _$identity,
      );
}

abstract class _TechnicianStatsEntity implements TechnicianStatsEntity {
  const factory _TechnicianStatsEntity({
    required final int assignedJobs,
    required final int inProgress,
    required final int completedToday,
    required final double efficiency,
    required final String avgTimePerJob,
    required final String totalHoursWorked,
  }) = _$TechnicianStatsEntityImpl;

  @override
  int get assignedJobs;
  @override
  int get inProgress;
  @override
  int get completedToday;
  @override
  double get efficiency;
  @override
  String get avgTimePerJob;
  @override
  String get totalHoursWorked;

  /// Create a copy of TechnicianStatsEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TechnicianStatsEntityImplCopyWith<_$TechnicianStatsEntityImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AssignedJobEntity {
  String get id => throw _privateConstructorUsedError;
  String get customerName => throw _privateConstructorUsedError;
  String get vehicle => throw _privateConstructorUsedError;
  String get service => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  AssignedJobStatus get status => throw _privateConstructorUsedError;

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
    String id,
    String customerName,
    String vehicle,
    String service,
    double amount,
    AssignedJobStatus status,
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
    Object? id = null,
    Object? customerName = null,
    Object? vehicle = null,
    Object? service = null,
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
            service: null == service
                ? _value.service
                : service // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as AssignedJobStatus,
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
    String id,
    String customerName,
    String vehicle,
    String service,
    double amount,
    AssignedJobStatus status,
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
    Object? id = null,
    Object? customerName = null,
    Object? vehicle = null,
    Object? service = null,
    Object? amount = null,
    Object? status = null,
  }) {
    return _then(
      _$AssignedJobEntityImpl(
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
        service: null == service
            ? _value.service
            : service // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as AssignedJobStatus,
      ),
    );
  }
}

/// @nodoc

class _$AssignedJobEntityImpl implements _AssignedJobEntity {
  const _$AssignedJobEntityImpl({
    required this.id,
    required this.customerName,
    required this.vehicle,
    required this.service,
    required this.amount,
    required this.status,
  });

  @override
  final String id;
  @override
  final String customerName;
  @override
  final String vehicle;
  @override
  final String service;
  @override
  final double amount;
  @override
  final AssignedJobStatus status;

  @override
  String toString() {
    return 'AssignedJobEntity(id: $id, customerName: $customerName, vehicle: $vehicle, service: $service, amount: $amount, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssignedJobEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.vehicle, vehicle) || other.vehicle == vehicle) &&
            (identical(other.service, service) || other.service == service) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    customerName,
    vehicle,
    service,
    amount,
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
    required final String id,
    required final String customerName,
    required final String vehicle,
    required final String service,
    required final double amount,
    required final AssignedJobStatus status,
  }) = _$AssignedJobEntityImpl;

  @override
  String get id;
  @override
  String get customerName;
  @override
  String get vehicle;
  @override
  String get service;
  @override
  double get amount;
  @override
  AssignedJobStatus get status;

  /// Create a copy of AssignedJobEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AssignedJobEntityImplCopyWith<_$AssignedJobEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TechnicianJobEntity _$TechnicianJobEntityFromJson(Map<String, dynamic> json) {
  return _TechnicianJobEntity.fromJson(json);
}

/// @nodoc
mixin _$TechnicianJobEntity {
  String get jobCardNo => throw _privateConstructorUsedError;
  String get dateOfWork => throw _privateConstructorUsedError;
  String get startTime => throw _privateConstructorUsedError;
  String get vehicleBrand => throw _privateConstructorUsedError;
  String get vehicleModel => throw _privateConstructorUsedError;
  String get plateNumber => throw _privateConstructorUsedError;
  TechJobStatus get status => throw _privateConstructorUsedError;
  List<WorkTaskEntity> get tasks => throw _privateConstructorUsedError;
  String get notes => throw _privateConstructorUsedError;

  /// Serializes this TechnicianJobEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TechnicianJobEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TechnicianJobEntityCopyWith<TechnicianJobEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TechnicianJobEntityCopyWith<$Res> {
  factory $TechnicianJobEntityCopyWith(
    TechnicianJobEntity value,
    $Res Function(TechnicianJobEntity) then,
  ) = _$TechnicianJobEntityCopyWithImpl<$Res, TechnicianJobEntity>;
  @useResult
  $Res call({
    String jobCardNo,
    String dateOfWork,
    String startTime,
    String vehicleBrand,
    String vehicleModel,
    String plateNumber,
    TechJobStatus status,
    List<WorkTaskEntity> tasks,
    String notes,
  });
}

/// @nodoc
class _$TechnicianJobEntityCopyWithImpl<$Res, $Val extends TechnicianJobEntity>
    implements $TechnicianJobEntityCopyWith<$Res> {
  _$TechnicianJobEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TechnicianJobEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? jobCardNo = null,
    Object? dateOfWork = null,
    Object? startTime = null,
    Object? vehicleBrand = null,
    Object? vehicleModel = null,
    Object? plateNumber = null,
    Object? status = null,
    Object? tasks = null,
    Object? notes = null,
  }) {
    return _then(
      _value.copyWith(
            jobCardNo: null == jobCardNo
                ? _value.jobCardNo
                : jobCardNo // ignore: cast_nullable_to_non_nullable
                      as String,
            dateOfWork: null == dateOfWork
                ? _value.dateOfWork
                : dateOfWork // ignore: cast_nullable_to_non_nullable
                      as String,
            startTime: null == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                      as String,
            vehicleBrand: null == vehicleBrand
                ? _value.vehicleBrand
                : vehicleBrand // ignore: cast_nullable_to_non_nullable
                      as String,
            vehicleModel: null == vehicleModel
                ? _value.vehicleModel
                : vehicleModel // ignore: cast_nullable_to_non_nullable
                      as String,
            plateNumber: null == plateNumber
                ? _value.plateNumber
                : plateNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as TechJobStatus,
            tasks: null == tasks
                ? _value.tasks
                : tasks // ignore: cast_nullable_to_non_nullable
                      as List<WorkTaskEntity>,
            notes: null == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TechnicianJobEntityImplCopyWith<$Res>
    implements $TechnicianJobEntityCopyWith<$Res> {
  factory _$$TechnicianJobEntityImplCopyWith(
    _$TechnicianJobEntityImpl value,
    $Res Function(_$TechnicianJobEntityImpl) then,
  ) = __$$TechnicianJobEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String jobCardNo,
    String dateOfWork,
    String startTime,
    String vehicleBrand,
    String vehicleModel,
    String plateNumber,
    TechJobStatus status,
    List<WorkTaskEntity> tasks,
    String notes,
  });
}

/// @nodoc
class __$$TechnicianJobEntityImplCopyWithImpl<$Res>
    extends _$TechnicianJobEntityCopyWithImpl<$Res, _$TechnicianJobEntityImpl>
    implements _$$TechnicianJobEntityImplCopyWith<$Res> {
  __$$TechnicianJobEntityImplCopyWithImpl(
    _$TechnicianJobEntityImpl _value,
    $Res Function(_$TechnicianJobEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TechnicianJobEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? jobCardNo = null,
    Object? dateOfWork = null,
    Object? startTime = null,
    Object? vehicleBrand = null,
    Object? vehicleModel = null,
    Object? plateNumber = null,
    Object? status = null,
    Object? tasks = null,
    Object? notes = null,
  }) {
    return _then(
      _$TechnicianJobEntityImpl(
        jobCardNo: null == jobCardNo
            ? _value.jobCardNo
            : jobCardNo // ignore: cast_nullable_to_non_nullable
                  as String,
        dateOfWork: null == dateOfWork
            ? _value.dateOfWork
            : dateOfWork // ignore: cast_nullable_to_non_nullable
                  as String,
        startTime: null == startTime
            ? _value.startTime
            : startTime // ignore: cast_nullable_to_non_nullable
                  as String,
        vehicleBrand: null == vehicleBrand
            ? _value.vehicleBrand
            : vehicleBrand // ignore: cast_nullable_to_non_nullable
                  as String,
        vehicleModel: null == vehicleModel
            ? _value.vehicleModel
            : vehicleModel // ignore: cast_nullable_to_non_nullable
                  as String,
        plateNumber: null == plateNumber
            ? _value.plateNumber
            : plateNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as TechJobStatus,
        tasks: null == tasks
            ? _value._tasks
            : tasks // ignore: cast_nullable_to_non_nullable
                  as List<WorkTaskEntity>,
        notes: null == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TechnicianJobEntityImpl extends _TechnicianJobEntity {
  const _$TechnicianJobEntityImpl({
    required this.jobCardNo,
    required this.dateOfWork,
    required this.startTime,
    required this.vehicleBrand,
    required this.vehicleModel,
    required this.plateNumber,
    this.status = TechJobStatus.pending,
    required final List<WorkTaskEntity> tasks,
    this.notes = '',
  }) : _tasks = tasks,
       super._();

  factory _$TechnicianJobEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$TechnicianJobEntityImplFromJson(json);

  @override
  final String jobCardNo;
  @override
  final String dateOfWork;
  @override
  final String startTime;
  @override
  final String vehicleBrand;
  @override
  final String vehicleModel;
  @override
  final String plateNumber;
  @override
  @JsonKey()
  final TechJobStatus status;
  final List<WorkTaskEntity> _tasks;
  @override
  List<WorkTaskEntity> get tasks {
    if (_tasks is EqualUnmodifiableListView) return _tasks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tasks);
  }

  @override
  @JsonKey()
  final String notes;

  @override
  String toString() {
    return 'TechnicianJobEntity(jobCardNo: $jobCardNo, dateOfWork: $dateOfWork, startTime: $startTime, vehicleBrand: $vehicleBrand, vehicleModel: $vehicleModel, plateNumber: $plateNumber, status: $status, tasks: $tasks, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TechnicianJobEntityImpl &&
            (identical(other.jobCardNo, jobCardNo) ||
                other.jobCardNo == jobCardNo) &&
            (identical(other.dateOfWork, dateOfWork) ||
                other.dateOfWork == dateOfWork) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.vehicleBrand, vehicleBrand) ||
                other.vehicleBrand == vehicleBrand) &&
            (identical(other.vehicleModel, vehicleModel) ||
                other.vehicleModel == vehicleModel) &&
            (identical(other.plateNumber, plateNumber) ||
                other.plateNumber == plateNumber) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._tasks, _tasks) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    jobCardNo,
    dateOfWork,
    startTime,
    vehicleBrand,
    vehicleModel,
    plateNumber,
    status,
    const DeepCollectionEquality().hash(_tasks),
    notes,
  );

  /// Create a copy of TechnicianJobEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TechnicianJobEntityImplCopyWith<_$TechnicianJobEntityImpl> get copyWith =>
      __$$TechnicianJobEntityImplCopyWithImpl<_$TechnicianJobEntityImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TechnicianJobEntityImplToJson(this);
  }
}

abstract class _TechnicianJobEntity extends TechnicianJobEntity {
  const factory _TechnicianJobEntity({
    required final String jobCardNo,
    required final String dateOfWork,
    required final String startTime,
    required final String vehicleBrand,
    required final String vehicleModel,
    required final String plateNumber,
    final TechJobStatus status,
    required final List<WorkTaskEntity> tasks,
    final String notes,
  }) = _$TechnicianJobEntityImpl;
  const _TechnicianJobEntity._() : super._();

  factory _TechnicianJobEntity.fromJson(Map<String, dynamic> json) =
      _$TechnicianJobEntityImpl.fromJson;

  @override
  String get jobCardNo;
  @override
  String get dateOfWork;
  @override
  String get startTime;
  @override
  String get vehicleBrand;
  @override
  String get vehicleModel;
  @override
  String get plateNumber;
  @override
  TechJobStatus get status;
  @override
  List<WorkTaskEntity> get tasks;
  @override
  String get notes;

  /// Create a copy of TechnicianJobEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TechnicianJobEntityImplCopyWith<_$TechnicianJobEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
