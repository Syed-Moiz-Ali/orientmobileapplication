// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_entities.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$DocumentExpiry {
  String get empId => throw _privateConstructorUsedError;
  String get employeeName => throw _privateConstructorUsedError;
  String get designation => throw _privateConstructorUsedError;
  String get documentType => throw _privateConstructorUsedError;
  String get expiryDate => throw _privateConstructorUsedError;
  int get daysLeft => throw _privateConstructorUsedError;
  ExpiryUrgency get urgency => throw _privateConstructorUsedError;

  /// Create a copy of DocumentExpiry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DocumentExpiryCopyWith<DocumentExpiry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DocumentExpiryCopyWith<$Res> {
  factory $DocumentExpiryCopyWith(
    DocumentExpiry value,
    $Res Function(DocumentExpiry) then,
  ) = _$DocumentExpiryCopyWithImpl<$Res, DocumentExpiry>;
  @useResult
  $Res call({
    String empId,
    String employeeName,
    String designation,
    String documentType,
    String expiryDate,
    int daysLeft,
    ExpiryUrgency urgency,
  });
}

/// @nodoc
class _$DocumentExpiryCopyWithImpl<$Res, $Val extends DocumentExpiry>
    implements $DocumentExpiryCopyWith<$Res> {
  _$DocumentExpiryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DocumentExpiry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? empId = null,
    Object? employeeName = null,
    Object? designation = null,
    Object? documentType = null,
    Object? expiryDate = null,
    Object? daysLeft = null,
    Object? urgency = null,
  }) {
    return _then(
      _value.copyWith(
            empId: null == empId
                ? _value.empId
                : empId // ignore: cast_nullable_to_non_nullable
                      as String,
            employeeName: null == employeeName
                ? _value.employeeName
                : employeeName // ignore: cast_nullable_to_non_nullable
                      as String,
            designation: null == designation
                ? _value.designation
                : designation // ignore: cast_nullable_to_non_nullable
                      as String,
            documentType: null == documentType
                ? _value.documentType
                : documentType // ignore: cast_nullable_to_non_nullable
                      as String,
            expiryDate: null == expiryDate
                ? _value.expiryDate
                : expiryDate // ignore: cast_nullable_to_non_nullable
                      as String,
            daysLeft: null == daysLeft
                ? _value.daysLeft
                : daysLeft // ignore: cast_nullable_to_non_nullable
                      as int,
            urgency: null == urgency
                ? _value.urgency
                : urgency // ignore: cast_nullable_to_non_nullable
                      as ExpiryUrgency,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DocumentExpiryImplCopyWith<$Res>
    implements $DocumentExpiryCopyWith<$Res> {
  factory _$$DocumentExpiryImplCopyWith(
    _$DocumentExpiryImpl value,
    $Res Function(_$DocumentExpiryImpl) then,
  ) = __$$DocumentExpiryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String empId,
    String employeeName,
    String designation,
    String documentType,
    String expiryDate,
    int daysLeft,
    ExpiryUrgency urgency,
  });
}

/// @nodoc
class __$$DocumentExpiryImplCopyWithImpl<$Res>
    extends _$DocumentExpiryCopyWithImpl<$Res, _$DocumentExpiryImpl>
    implements _$$DocumentExpiryImplCopyWith<$Res> {
  __$$DocumentExpiryImplCopyWithImpl(
    _$DocumentExpiryImpl _value,
    $Res Function(_$DocumentExpiryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DocumentExpiry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? empId = null,
    Object? employeeName = null,
    Object? designation = null,
    Object? documentType = null,
    Object? expiryDate = null,
    Object? daysLeft = null,
    Object? urgency = null,
  }) {
    return _then(
      _$DocumentExpiryImpl(
        empId: null == empId
            ? _value.empId
            : empId // ignore: cast_nullable_to_non_nullable
                  as String,
        employeeName: null == employeeName
            ? _value.employeeName
            : employeeName // ignore: cast_nullable_to_non_nullable
                  as String,
        designation: null == designation
            ? _value.designation
            : designation // ignore: cast_nullable_to_non_nullable
                  as String,
        documentType: null == documentType
            ? _value.documentType
            : documentType // ignore: cast_nullable_to_non_nullable
                  as String,
        expiryDate: null == expiryDate
            ? _value.expiryDate
            : expiryDate // ignore: cast_nullable_to_non_nullable
                  as String,
        daysLeft: null == daysLeft
            ? _value.daysLeft
            : daysLeft // ignore: cast_nullable_to_non_nullable
                  as int,
        urgency: null == urgency
            ? _value.urgency
            : urgency // ignore: cast_nullable_to_non_nullable
                  as ExpiryUrgency,
      ),
    );
  }
}

/// @nodoc

class _$DocumentExpiryImpl implements _DocumentExpiry {
  const _$DocumentExpiryImpl({
    required this.empId,
    required this.employeeName,
    required this.designation,
    required this.documentType,
    required this.expiryDate,
    required this.daysLeft,
    required this.urgency,
  });

  @override
  final String empId;
  @override
  final String employeeName;
  @override
  final String designation;
  @override
  final String documentType;
  @override
  final String expiryDate;
  @override
  final int daysLeft;
  @override
  final ExpiryUrgency urgency;

  @override
  String toString() {
    return 'DocumentExpiry(empId: $empId, employeeName: $employeeName, designation: $designation, documentType: $documentType, expiryDate: $expiryDate, daysLeft: $daysLeft, urgency: $urgency)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DocumentExpiryImpl &&
            (identical(other.empId, empId) || other.empId == empId) &&
            (identical(other.employeeName, employeeName) ||
                other.employeeName == employeeName) &&
            (identical(other.designation, designation) ||
                other.designation == designation) &&
            (identical(other.documentType, documentType) ||
                other.documentType == documentType) &&
            (identical(other.expiryDate, expiryDate) ||
                other.expiryDate == expiryDate) &&
            (identical(other.daysLeft, daysLeft) ||
                other.daysLeft == daysLeft) &&
            (identical(other.urgency, urgency) || other.urgency == urgency));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    empId,
    employeeName,
    designation,
    documentType,
    expiryDate,
    daysLeft,
    urgency,
  );

  /// Create a copy of DocumentExpiry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DocumentExpiryImplCopyWith<_$DocumentExpiryImpl> get copyWith =>
      __$$DocumentExpiryImplCopyWithImpl<_$DocumentExpiryImpl>(
        this,
        _$identity,
      );
}

abstract class _DocumentExpiry implements DocumentExpiry {
  const factory _DocumentExpiry({
    required final String empId,
    required final String employeeName,
    required final String designation,
    required final String documentType,
    required final String expiryDate,
    required final int daysLeft,
    required final ExpiryUrgency urgency,
  }) = _$DocumentExpiryImpl;

  @override
  String get empId;
  @override
  String get employeeName;
  @override
  String get designation;
  @override
  String get documentType;
  @override
  String get expiryDate;
  @override
  int get daysLeft;
  @override
  ExpiryUrgency get urgency;

  /// Create a copy of DocumentExpiry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DocumentExpiryImplCopyWith<_$DocumentExpiryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$JobStatus {
  String get jobCardId => throw _privateConstructorUsedError;
  String get customerName => throw _privateConstructorUsedError;
  String get vehicleInfo => throw _privateConstructorUsedError;
  String get assignedTo => throw _privateConstructorUsedError;
  String get createdDate => throw _privateConstructorUsedError;
  String get dueDate => throw _privateConstructorUsedError;
  JobStage get stage => throw _privateConstructorUsedError;
  double get estimatedAmount => throw _privateConstructorUsedError;

  /// Create a copy of JobStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JobStatusCopyWith<JobStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JobStatusCopyWith<$Res> {
  factory $JobStatusCopyWith(JobStatus value, $Res Function(JobStatus) then) =
      _$JobStatusCopyWithImpl<$Res, JobStatus>;
  @useResult
  $Res call({
    String jobCardId,
    String customerName,
    String vehicleInfo,
    String assignedTo,
    String createdDate,
    String dueDate,
    JobStage stage,
    double estimatedAmount,
  });
}

/// @nodoc
class _$JobStatusCopyWithImpl<$Res, $Val extends JobStatus>
    implements $JobStatusCopyWith<$Res> {
  _$JobStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of JobStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? jobCardId = null,
    Object? customerName = null,
    Object? vehicleInfo = null,
    Object? assignedTo = null,
    Object? createdDate = null,
    Object? dueDate = null,
    Object? stage = null,
    Object? estimatedAmount = null,
  }) {
    return _then(
      _value.copyWith(
            jobCardId: null == jobCardId
                ? _value.jobCardId
                : jobCardId // ignore: cast_nullable_to_non_nullable
                      as String,
            customerName: null == customerName
                ? _value.customerName
                : customerName // ignore: cast_nullable_to_non_nullable
                      as String,
            vehicleInfo: null == vehicleInfo
                ? _value.vehicleInfo
                : vehicleInfo // ignore: cast_nullable_to_non_nullable
                      as String,
            assignedTo: null == assignedTo
                ? _value.assignedTo
                : assignedTo // ignore: cast_nullable_to_non_nullable
                      as String,
            createdDate: null == createdDate
                ? _value.createdDate
                : createdDate // ignore: cast_nullable_to_non_nullable
                      as String,
            dueDate: null == dueDate
                ? _value.dueDate
                : dueDate // ignore: cast_nullable_to_non_nullable
                      as String,
            stage: null == stage
                ? _value.stage
                : stage // ignore: cast_nullable_to_non_nullable
                      as JobStage,
            estimatedAmount: null == estimatedAmount
                ? _value.estimatedAmount
                : estimatedAmount // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$JobStatusImplCopyWith<$Res>
    implements $JobStatusCopyWith<$Res> {
  factory _$$JobStatusImplCopyWith(
    _$JobStatusImpl value,
    $Res Function(_$JobStatusImpl) then,
  ) = __$$JobStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String jobCardId,
    String customerName,
    String vehicleInfo,
    String assignedTo,
    String createdDate,
    String dueDate,
    JobStage stage,
    double estimatedAmount,
  });
}

/// @nodoc
class __$$JobStatusImplCopyWithImpl<$Res>
    extends _$JobStatusCopyWithImpl<$Res, _$JobStatusImpl>
    implements _$$JobStatusImplCopyWith<$Res> {
  __$$JobStatusImplCopyWithImpl(
    _$JobStatusImpl _value,
    $Res Function(_$JobStatusImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of JobStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? jobCardId = null,
    Object? customerName = null,
    Object? vehicleInfo = null,
    Object? assignedTo = null,
    Object? createdDate = null,
    Object? dueDate = null,
    Object? stage = null,
    Object? estimatedAmount = null,
  }) {
    return _then(
      _$JobStatusImpl(
        jobCardId: null == jobCardId
            ? _value.jobCardId
            : jobCardId // ignore: cast_nullable_to_non_nullable
                  as String,
        customerName: null == customerName
            ? _value.customerName
            : customerName // ignore: cast_nullable_to_non_nullable
                  as String,
        vehicleInfo: null == vehicleInfo
            ? _value.vehicleInfo
            : vehicleInfo // ignore: cast_nullable_to_non_nullable
                  as String,
        assignedTo: null == assignedTo
            ? _value.assignedTo
            : assignedTo // ignore: cast_nullable_to_non_nullable
                  as String,
        createdDate: null == createdDate
            ? _value.createdDate
            : createdDate // ignore: cast_nullable_to_non_nullable
                  as String,
        dueDate: null == dueDate
            ? _value.dueDate
            : dueDate // ignore: cast_nullable_to_non_nullable
                  as String,
        stage: null == stage
            ? _value.stage
            : stage // ignore: cast_nullable_to_non_nullable
                  as JobStage,
        estimatedAmount: null == estimatedAmount
            ? _value.estimatedAmount
            : estimatedAmount // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc

class _$JobStatusImpl implements _JobStatus {
  const _$JobStatusImpl({
    required this.jobCardId,
    required this.customerName,
    required this.vehicleInfo,
    required this.assignedTo,
    required this.createdDate,
    required this.dueDate,
    required this.stage,
    required this.estimatedAmount,
  });

  @override
  final String jobCardId;
  @override
  final String customerName;
  @override
  final String vehicleInfo;
  @override
  final String assignedTo;
  @override
  final String createdDate;
  @override
  final String dueDate;
  @override
  final JobStage stage;
  @override
  final double estimatedAmount;

  @override
  String toString() {
    return 'JobStatus(jobCardId: $jobCardId, customerName: $customerName, vehicleInfo: $vehicleInfo, assignedTo: $assignedTo, createdDate: $createdDate, dueDate: $dueDate, stage: $stage, estimatedAmount: $estimatedAmount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JobStatusImpl &&
            (identical(other.jobCardId, jobCardId) ||
                other.jobCardId == jobCardId) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.vehicleInfo, vehicleInfo) ||
                other.vehicleInfo == vehicleInfo) &&
            (identical(other.assignedTo, assignedTo) ||
                other.assignedTo == assignedTo) &&
            (identical(other.createdDate, createdDate) ||
                other.createdDate == createdDate) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.stage, stage) || other.stage == stage) &&
            (identical(other.estimatedAmount, estimatedAmount) ||
                other.estimatedAmount == estimatedAmount));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    jobCardId,
    customerName,
    vehicleInfo,
    assignedTo,
    createdDate,
    dueDate,
    stage,
    estimatedAmount,
  );

  /// Create a copy of JobStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JobStatusImplCopyWith<_$JobStatusImpl> get copyWith =>
      __$$JobStatusImplCopyWithImpl<_$JobStatusImpl>(this, _$identity);
}

abstract class _JobStatus implements JobStatus {
  const factory _JobStatus({
    required final String jobCardId,
    required final String customerName,
    required final String vehicleInfo,
    required final String assignedTo,
    required final String createdDate,
    required final String dueDate,
    required final JobStage stage,
    required final double estimatedAmount,
  }) = _$JobStatusImpl;

  @override
  String get jobCardId;
  @override
  String get customerName;
  @override
  String get vehicleInfo;
  @override
  String get assignedTo;
  @override
  String get createdDate;
  @override
  String get dueDate;
  @override
  JobStage get stage;
  @override
  double get estimatedAmount;

  /// Create a copy of JobStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JobStatusImplCopyWith<_$JobStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ApprovalCategory {
  String get title => throw _privateConstructorUsedError;
  String get subtitle => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;
  Color get iconBg => throw _privateConstructorUsedError;
  IconData get icon => throw _privateConstructorUsedError;

  /// Create a copy of ApprovalCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ApprovalCategoryCopyWith<ApprovalCategory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ApprovalCategoryCopyWith<$Res> {
  factory $ApprovalCategoryCopyWith(
    ApprovalCategory value,
    $Res Function(ApprovalCategory) then,
  ) = _$ApprovalCategoryCopyWithImpl<$Res, ApprovalCategory>;
  @useResult
  $Res call({
    String title,
    String subtitle,
    int count,
    Color iconBg,
    IconData icon,
  });
}

/// @nodoc
class _$ApprovalCategoryCopyWithImpl<$Res, $Val extends ApprovalCategory>
    implements $ApprovalCategoryCopyWith<$Res> {
  _$ApprovalCategoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ApprovalCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? subtitle = null,
    Object? count = null,
    Object? iconBg = null,
    Object? icon = null,
  }) {
    return _then(
      _value.copyWith(
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            subtitle: null == subtitle
                ? _value.subtitle
                : subtitle // ignore: cast_nullable_to_non_nullable
                      as String,
            count: null == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                      as int,
            iconBg: null == iconBg
                ? _value.iconBg
                : iconBg // ignore: cast_nullable_to_non_nullable
                      as Color,
            icon: null == icon
                ? _value.icon
                : icon // ignore: cast_nullable_to_non_nullable
                      as IconData,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ApprovalCategoryImplCopyWith<$Res>
    implements $ApprovalCategoryCopyWith<$Res> {
  factory _$$ApprovalCategoryImplCopyWith(
    _$ApprovalCategoryImpl value,
    $Res Function(_$ApprovalCategoryImpl) then,
  ) = __$$ApprovalCategoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String title,
    String subtitle,
    int count,
    Color iconBg,
    IconData icon,
  });
}

/// @nodoc
class __$$ApprovalCategoryImplCopyWithImpl<$Res>
    extends _$ApprovalCategoryCopyWithImpl<$Res, _$ApprovalCategoryImpl>
    implements _$$ApprovalCategoryImplCopyWith<$Res> {
  __$$ApprovalCategoryImplCopyWithImpl(
    _$ApprovalCategoryImpl _value,
    $Res Function(_$ApprovalCategoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ApprovalCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? subtitle = null,
    Object? count = null,
    Object? iconBg = null,
    Object? icon = null,
  }) {
    return _then(
      _$ApprovalCategoryImpl(
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        subtitle: null == subtitle
            ? _value.subtitle
            : subtitle // ignore: cast_nullable_to_non_nullable
                  as String,
        count: null == count
            ? _value.count
            : count // ignore: cast_nullable_to_non_nullable
                  as int,
        iconBg: null == iconBg
            ? _value.iconBg
            : iconBg // ignore: cast_nullable_to_non_nullable
                  as Color,
        icon: null == icon
            ? _value.icon
            : icon // ignore: cast_nullable_to_non_nullable
                  as IconData,
      ),
    );
  }
}

/// @nodoc

class _$ApprovalCategoryImpl implements _ApprovalCategory {
  const _$ApprovalCategoryImpl({
    required this.title,
    required this.subtitle,
    required this.count,
    required this.iconBg,
    required this.icon,
  });

  @override
  final String title;
  @override
  final String subtitle;
  @override
  final int count;
  @override
  final Color iconBg;
  @override
  final IconData icon;

  @override
  String toString() {
    return 'ApprovalCategory(title: $title, subtitle: $subtitle, count: $count, iconBg: $iconBg, icon: $icon)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ApprovalCategoryImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.subtitle, subtitle) ||
                other.subtitle == subtitle) &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.iconBg, iconBg) || other.iconBg == iconBg) &&
            (identical(other.icon, icon) || other.icon == icon));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, title, subtitle, count, iconBg, icon);

  /// Create a copy of ApprovalCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ApprovalCategoryImplCopyWith<_$ApprovalCategoryImpl> get copyWith =>
      __$$ApprovalCategoryImplCopyWithImpl<_$ApprovalCategoryImpl>(
        this,
        _$identity,
      );
}

abstract class _ApprovalCategory implements ApprovalCategory {
  const factory _ApprovalCategory({
    required final String title,
    required final String subtitle,
    required final int count,
    required final Color iconBg,
    required final IconData icon,
  }) = _$ApprovalCategoryImpl;

  @override
  String get title;
  @override
  String get subtitle;
  @override
  int get count;
  @override
  Color get iconBg;
  @override
  IconData get icon;

  /// Create a copy of ApprovalCategory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ApprovalCategoryImplCopyWith<_$ApprovalCategoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$PendingJobCard {
  String get jobCardId => throw _privateConstructorUsedError;
  String get customerName => throw _privateConstructorUsedError;
  String get vehicleInfo => throw _privateConstructorUsedError;
  String get assignedTo => throw _privateConstructorUsedError;
  String get createdDate => throw _privateConstructorUsedError;
  String get dueDate => throw _privateConstructorUsedError;
  int get daysOverdue => throw _privateConstructorUsedError;
  PendingJobCardStatus get status => throw _privateConstructorUsedError;
  double get estimatedAmount => throw _privateConstructorUsedError;

  /// Create a copy of PendingJobCard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PendingJobCardCopyWith<PendingJobCard> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PendingJobCardCopyWith<$Res> {
  factory $PendingJobCardCopyWith(
    PendingJobCard value,
    $Res Function(PendingJobCard) then,
  ) = _$PendingJobCardCopyWithImpl<$Res, PendingJobCard>;
  @useResult
  $Res call({
    String jobCardId,
    String customerName,
    String vehicleInfo,
    String assignedTo,
    String createdDate,
    String dueDate,
    int daysOverdue,
    PendingJobCardStatus status,
    double estimatedAmount,
  });
}

/// @nodoc
class _$PendingJobCardCopyWithImpl<$Res, $Val extends PendingJobCard>
    implements $PendingJobCardCopyWith<$Res> {
  _$PendingJobCardCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PendingJobCard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? jobCardId = null,
    Object? customerName = null,
    Object? vehicleInfo = null,
    Object? assignedTo = null,
    Object? createdDate = null,
    Object? dueDate = null,
    Object? daysOverdue = null,
    Object? status = null,
    Object? estimatedAmount = null,
  }) {
    return _then(
      _value.copyWith(
            jobCardId: null == jobCardId
                ? _value.jobCardId
                : jobCardId // ignore: cast_nullable_to_non_nullable
                      as String,
            customerName: null == customerName
                ? _value.customerName
                : customerName // ignore: cast_nullable_to_non_nullable
                      as String,
            vehicleInfo: null == vehicleInfo
                ? _value.vehicleInfo
                : vehicleInfo // ignore: cast_nullable_to_non_nullable
                      as String,
            assignedTo: null == assignedTo
                ? _value.assignedTo
                : assignedTo // ignore: cast_nullable_to_non_nullable
                      as String,
            createdDate: null == createdDate
                ? _value.createdDate
                : createdDate // ignore: cast_nullable_to_non_nullable
                      as String,
            dueDate: null == dueDate
                ? _value.dueDate
                : dueDate // ignore: cast_nullable_to_non_nullable
                      as String,
            daysOverdue: null == daysOverdue
                ? _value.daysOverdue
                : daysOverdue // ignore: cast_nullable_to_non_nullable
                      as int,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as PendingJobCardStatus,
            estimatedAmount: null == estimatedAmount
                ? _value.estimatedAmount
                : estimatedAmount // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PendingJobCardImplCopyWith<$Res>
    implements $PendingJobCardCopyWith<$Res> {
  factory _$$PendingJobCardImplCopyWith(
    _$PendingJobCardImpl value,
    $Res Function(_$PendingJobCardImpl) then,
  ) = __$$PendingJobCardImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String jobCardId,
    String customerName,
    String vehicleInfo,
    String assignedTo,
    String createdDate,
    String dueDate,
    int daysOverdue,
    PendingJobCardStatus status,
    double estimatedAmount,
  });
}

/// @nodoc
class __$$PendingJobCardImplCopyWithImpl<$Res>
    extends _$PendingJobCardCopyWithImpl<$Res, _$PendingJobCardImpl>
    implements _$$PendingJobCardImplCopyWith<$Res> {
  __$$PendingJobCardImplCopyWithImpl(
    _$PendingJobCardImpl _value,
    $Res Function(_$PendingJobCardImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PendingJobCard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? jobCardId = null,
    Object? customerName = null,
    Object? vehicleInfo = null,
    Object? assignedTo = null,
    Object? createdDate = null,
    Object? dueDate = null,
    Object? daysOverdue = null,
    Object? status = null,
    Object? estimatedAmount = null,
  }) {
    return _then(
      _$PendingJobCardImpl(
        jobCardId: null == jobCardId
            ? _value.jobCardId
            : jobCardId // ignore: cast_nullable_to_non_nullable
                  as String,
        customerName: null == customerName
            ? _value.customerName
            : customerName // ignore: cast_nullable_to_non_nullable
                  as String,
        vehicleInfo: null == vehicleInfo
            ? _value.vehicleInfo
            : vehicleInfo // ignore: cast_nullable_to_non_nullable
                  as String,
        assignedTo: null == assignedTo
            ? _value.assignedTo
            : assignedTo // ignore: cast_nullable_to_non_nullable
                  as String,
        createdDate: null == createdDate
            ? _value.createdDate
            : createdDate // ignore: cast_nullable_to_non_nullable
                  as String,
        dueDate: null == dueDate
            ? _value.dueDate
            : dueDate // ignore: cast_nullable_to_non_nullable
                  as String,
        daysOverdue: null == daysOverdue
            ? _value.daysOverdue
            : daysOverdue // ignore: cast_nullable_to_non_nullable
                  as int,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as PendingJobCardStatus,
        estimatedAmount: null == estimatedAmount
            ? _value.estimatedAmount
            : estimatedAmount // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc

class _$PendingJobCardImpl implements _PendingJobCard {
  const _$PendingJobCardImpl({
    required this.jobCardId,
    required this.customerName,
    required this.vehicleInfo,
    required this.assignedTo,
    required this.createdDate,
    required this.dueDate,
    required this.daysOverdue,
    required this.status,
    required this.estimatedAmount,
  });

  @override
  final String jobCardId;
  @override
  final String customerName;
  @override
  final String vehicleInfo;
  @override
  final String assignedTo;
  @override
  final String createdDate;
  @override
  final String dueDate;
  @override
  final int daysOverdue;
  @override
  final PendingJobCardStatus status;
  @override
  final double estimatedAmount;

  @override
  String toString() {
    return 'PendingJobCard(jobCardId: $jobCardId, customerName: $customerName, vehicleInfo: $vehicleInfo, assignedTo: $assignedTo, createdDate: $createdDate, dueDate: $dueDate, daysOverdue: $daysOverdue, status: $status, estimatedAmount: $estimatedAmount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PendingJobCardImpl &&
            (identical(other.jobCardId, jobCardId) ||
                other.jobCardId == jobCardId) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.vehicleInfo, vehicleInfo) ||
                other.vehicleInfo == vehicleInfo) &&
            (identical(other.assignedTo, assignedTo) ||
                other.assignedTo == assignedTo) &&
            (identical(other.createdDate, createdDate) ||
                other.createdDate == createdDate) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.daysOverdue, daysOverdue) ||
                other.daysOverdue == daysOverdue) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.estimatedAmount, estimatedAmount) ||
                other.estimatedAmount == estimatedAmount));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    jobCardId,
    customerName,
    vehicleInfo,
    assignedTo,
    createdDate,
    dueDate,
    daysOverdue,
    status,
    estimatedAmount,
  );

  /// Create a copy of PendingJobCard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PendingJobCardImplCopyWith<_$PendingJobCardImpl> get copyWith =>
      __$$PendingJobCardImplCopyWithImpl<_$PendingJobCardImpl>(
        this,
        _$identity,
      );
}

abstract class _PendingJobCard implements PendingJobCard {
  const factory _PendingJobCard({
    required final String jobCardId,
    required final String customerName,
    required final String vehicleInfo,
    required final String assignedTo,
    required final String createdDate,
    required final String dueDate,
    required final int daysOverdue,
    required final PendingJobCardStatus status,
    required final double estimatedAmount,
  }) = _$PendingJobCardImpl;

  @override
  String get jobCardId;
  @override
  String get customerName;
  @override
  String get vehicleInfo;
  @override
  String get assignedTo;
  @override
  String get createdDate;
  @override
  String get dueDate;
  @override
  int get daysOverdue;
  @override
  PendingJobCardStatus get status;
  @override
  double get estimatedAmount;

  /// Create a copy of PendingJobCard
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PendingJobCardImplCopyWith<_$PendingJobCardImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ActiveJobCard {
  String get id => throw _privateConstructorUsedError;
  String get customerName => throw _privateConstructorUsedError;
  String get vehicleInfo => throw _privateConstructorUsedError;
  String get services => throw _privateConstructorUsedError;
  String get technician => throw _privateConstructorUsedError;
  String get estCompletion => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  ActiveJobStatus get status => throw _privateConstructorUsedError;

  /// Create a copy of ActiveJobCard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActiveJobCardCopyWith<ActiveJobCard> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActiveJobCardCopyWith<$Res> {
  factory $ActiveJobCardCopyWith(
    ActiveJobCard value,
    $Res Function(ActiveJobCard) then,
  ) = _$ActiveJobCardCopyWithImpl<$Res, ActiveJobCard>;
  @useResult
  $Res call({
    String id,
    String customerName,
    String vehicleInfo,
    String services,
    String technician,
    String estCompletion,
    double amount,
    ActiveJobStatus status,
  });
}

/// @nodoc
class _$ActiveJobCardCopyWithImpl<$Res, $Val extends ActiveJobCard>
    implements $ActiveJobCardCopyWith<$Res> {
  _$ActiveJobCardCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActiveJobCard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerName = null,
    Object? vehicleInfo = null,
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
            vehicleInfo: null == vehicleInfo
                ? _value.vehicleInfo
                : vehicleInfo // ignore: cast_nullable_to_non_nullable
                      as String,
            services: null == services
                ? _value.services
                : services // ignore: cast_nullable_to_non_nullable
                      as String,
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
                      as ActiveJobStatus,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ActiveJobCardImplCopyWith<$Res>
    implements $ActiveJobCardCopyWith<$Res> {
  factory _$$ActiveJobCardImplCopyWith(
    _$ActiveJobCardImpl value,
    $Res Function(_$ActiveJobCardImpl) then,
  ) = __$$ActiveJobCardImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String customerName,
    String vehicleInfo,
    String services,
    String technician,
    String estCompletion,
    double amount,
    ActiveJobStatus status,
  });
}

/// @nodoc
class __$$ActiveJobCardImplCopyWithImpl<$Res>
    extends _$ActiveJobCardCopyWithImpl<$Res, _$ActiveJobCardImpl>
    implements _$$ActiveJobCardImplCopyWith<$Res> {
  __$$ActiveJobCardImplCopyWithImpl(
    _$ActiveJobCardImpl _value,
    $Res Function(_$ActiveJobCardImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ActiveJobCard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerName = null,
    Object? vehicleInfo = null,
    Object? services = null,
    Object? technician = null,
    Object? estCompletion = null,
    Object? amount = null,
    Object? status = null,
  }) {
    return _then(
      _$ActiveJobCardImpl(
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
        services: null == services
            ? _value.services
            : services // ignore: cast_nullable_to_non_nullable
                  as String,
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
                  as ActiveJobStatus,
      ),
    );
  }
}

/// @nodoc

class _$ActiveJobCardImpl implements _ActiveJobCard {
  const _$ActiveJobCardImpl({
    required this.id,
    required this.customerName,
    required this.vehicleInfo,
    required this.services,
    required this.technician,
    required this.estCompletion,
    required this.amount,
    required this.status,
  });

  @override
  final String id;
  @override
  final String customerName;
  @override
  final String vehicleInfo;
  @override
  final String services;
  @override
  final String technician;
  @override
  final String estCompletion;
  @override
  final double amount;
  @override
  final ActiveJobStatus status;

  @override
  String toString() {
    return 'ActiveJobCard(id: $id, customerName: $customerName, vehicleInfo: $vehicleInfo, services: $services, technician: $technician, estCompletion: $estCompletion, amount: $amount, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActiveJobCardImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.vehicleInfo, vehicleInfo) ||
                other.vehicleInfo == vehicleInfo) &&
            (identical(other.services, services) ||
                other.services == services) &&
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
    vehicleInfo,
    services,
    technician,
    estCompletion,
    amount,
    status,
  );

  /// Create a copy of ActiveJobCard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActiveJobCardImplCopyWith<_$ActiveJobCardImpl> get copyWith =>
      __$$ActiveJobCardImplCopyWithImpl<_$ActiveJobCardImpl>(this, _$identity);
}

abstract class _ActiveJobCard implements ActiveJobCard {
  const factory _ActiveJobCard({
    required final String id,
    required final String customerName,
    required final String vehicleInfo,
    required final String services,
    required final String technician,
    required final String estCompletion,
    required final double amount,
    required final ActiveJobStatus status,
  }) = _$ActiveJobCardImpl;

  @override
  String get id;
  @override
  String get customerName;
  @override
  String get vehicleInfo;
  @override
  String get services;
  @override
  String get technician;
  @override
  String get estCompletion;
  @override
  double get amount;
  @override
  ActiveJobStatus get status;

  /// Create a copy of ActiveJobCard
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActiveJobCardImplCopyWith<_$ActiveJobCardImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SalesInvoice {
  String get id => throw _privateConstructorUsedError;
  String get customerName => throw _privateConstructorUsedError;
  String get date => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  InvoiceStatus get status => throw _privateConstructorUsedError;

  /// Create a copy of SalesInvoice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SalesInvoiceCopyWith<SalesInvoice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SalesInvoiceCopyWith<$Res> {
  factory $SalesInvoiceCopyWith(
    SalesInvoice value,
    $Res Function(SalesInvoice) then,
  ) = _$SalesInvoiceCopyWithImpl<$Res, SalesInvoice>;
  @useResult
  $Res call({
    String id,
    String customerName,
    String date,
    double amount,
    InvoiceStatus status,
  });
}

/// @nodoc
class _$SalesInvoiceCopyWithImpl<$Res, $Val extends SalesInvoice>
    implements $SalesInvoiceCopyWith<$Res> {
  _$SalesInvoiceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SalesInvoice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerName = null,
    Object? date = null,
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
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as InvoiceStatus,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SalesInvoiceImplCopyWith<$Res>
    implements $SalesInvoiceCopyWith<$Res> {
  factory _$$SalesInvoiceImplCopyWith(
    _$SalesInvoiceImpl value,
    $Res Function(_$SalesInvoiceImpl) then,
  ) = __$$SalesInvoiceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String customerName,
    String date,
    double amount,
    InvoiceStatus status,
  });
}

/// @nodoc
class __$$SalesInvoiceImplCopyWithImpl<$Res>
    extends _$SalesInvoiceCopyWithImpl<$Res, _$SalesInvoiceImpl>
    implements _$$SalesInvoiceImplCopyWith<$Res> {
  __$$SalesInvoiceImplCopyWithImpl(
    _$SalesInvoiceImpl _value,
    $Res Function(_$SalesInvoiceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SalesInvoice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerName = null,
    Object? date = null,
    Object? amount = null,
    Object? status = null,
  }) {
    return _then(
      _$SalesInvoiceImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        customerName: null == customerName
            ? _value.customerName
            : customerName // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as InvoiceStatus,
      ),
    );
  }
}

/// @nodoc

class _$SalesInvoiceImpl implements _SalesInvoice {
  const _$SalesInvoiceImpl({
    required this.id,
    required this.customerName,
    required this.date,
    required this.amount,
    required this.status,
  });

  @override
  final String id;
  @override
  final String customerName;
  @override
  final String date;
  @override
  final double amount;
  @override
  final InvoiceStatus status;

  @override
  String toString() {
    return 'SalesInvoice(id: $id, customerName: $customerName, date: $date, amount: $amount, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SalesInvoiceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, customerName, date, amount, status);

  /// Create a copy of SalesInvoice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SalesInvoiceImplCopyWith<_$SalesInvoiceImpl> get copyWith =>
      __$$SalesInvoiceImplCopyWithImpl<_$SalesInvoiceImpl>(this, _$identity);
}

abstract class _SalesInvoice implements SalesInvoice {
  const factory _SalesInvoice({
    required final String id,
    required final String customerName,
    required final String date,
    required final double amount,
    required final InvoiceStatus status,
  }) = _$SalesInvoiceImpl;

  @override
  String get id;
  @override
  String get customerName;
  @override
  String get date;
  @override
  double get amount;
  @override
  InvoiceStatus get status;

  /// Create a copy of SalesInvoice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SalesInvoiceImplCopyWith<_$SalesInvoiceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$OwnerKpi {
  String get label => throw _privateConstructorUsedError;
  String get value => throw _privateConstructorUsedError;
  IconData get icon => throw _privateConstructorUsedError;
  Color get color => throw _privateConstructorUsedError;
  String get sub => throw _privateConstructorUsedError;

  /// Create a copy of OwnerKpi
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OwnerKpiCopyWith<OwnerKpi> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OwnerKpiCopyWith<$Res> {
  factory $OwnerKpiCopyWith(OwnerKpi value, $Res Function(OwnerKpi) then) =
      _$OwnerKpiCopyWithImpl<$Res, OwnerKpi>;
  @useResult
  $Res call({
    String label,
    String value,
    IconData icon,
    Color color,
    String sub,
  });
}

/// @nodoc
class _$OwnerKpiCopyWithImpl<$Res, $Val extends OwnerKpi>
    implements $OwnerKpiCopyWith<$Res> {
  _$OwnerKpiCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OwnerKpi
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? value = null,
    Object? icon = null,
    Object? color = null,
    Object? sub = null,
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
abstract class _$$OwnerKpiImplCopyWith<$Res>
    implements $OwnerKpiCopyWith<$Res> {
  factory _$$OwnerKpiImplCopyWith(
    _$OwnerKpiImpl value,
    $Res Function(_$OwnerKpiImpl) then,
  ) = __$$OwnerKpiImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String label,
    String value,
    IconData icon,
    Color color,
    String sub,
  });
}

/// @nodoc
class __$$OwnerKpiImplCopyWithImpl<$Res>
    extends _$OwnerKpiCopyWithImpl<$Res, _$OwnerKpiImpl>
    implements _$$OwnerKpiImplCopyWith<$Res> {
  __$$OwnerKpiImplCopyWithImpl(
    _$OwnerKpiImpl _value,
    $Res Function(_$OwnerKpiImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OwnerKpi
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? value = null,
    Object? icon = null,
    Object? color = null,
    Object? sub = null,
  }) {
    return _then(
      _$OwnerKpiImpl(
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
        sub: null == sub
            ? _value.sub
            : sub // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$OwnerKpiImpl implements _OwnerKpi {
  const _$OwnerKpiImpl({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.sub,
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
  final String sub;

  @override
  String toString() {
    return 'OwnerKpi(label: $label, value: $value, icon: $icon, color: $color, sub: $sub)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OwnerKpiImpl &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.sub, sub) || other.sub == sub));
  }

  @override
  int get hashCode => Object.hash(runtimeType, label, value, icon, color, sub);

  /// Create a copy of OwnerKpi
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OwnerKpiImplCopyWith<_$OwnerKpiImpl> get copyWith =>
      __$$OwnerKpiImplCopyWithImpl<_$OwnerKpiImpl>(this, _$identity);
}

abstract class _OwnerKpi implements OwnerKpi {
  const factory _OwnerKpi({
    required final String label,
    required final String value,
    required final IconData icon,
    required final Color color,
    required final String sub,
  }) = _$OwnerKpiImpl;

  @override
  String get label;
  @override
  String get value;
  @override
  IconData get icon;
  @override
  Color get color;
  @override
  String get sub;

  /// Create a copy of OwnerKpi
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OwnerKpiImplCopyWith<_$OwnerKpiImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SalesTrendPoint {
  String get month => throw _privateConstructorUsedError;
  double get value => throw _privateConstructorUsedError;

  /// Create a copy of SalesTrendPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SalesTrendPointCopyWith<SalesTrendPoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SalesTrendPointCopyWith<$Res> {
  factory $SalesTrendPointCopyWith(
    SalesTrendPoint value,
    $Res Function(SalesTrendPoint) then,
  ) = _$SalesTrendPointCopyWithImpl<$Res, SalesTrendPoint>;
  @useResult
  $Res call({String month, double value});
}

/// @nodoc
class _$SalesTrendPointCopyWithImpl<$Res, $Val extends SalesTrendPoint>
    implements $SalesTrendPointCopyWith<$Res> {
  _$SalesTrendPointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SalesTrendPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? month = null, Object? value = null}) {
    return _then(
      _value.copyWith(
            month: null == month
                ? _value.month
                : month // ignore: cast_nullable_to_non_nullable
                      as String,
            value: null == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SalesTrendPointImplCopyWith<$Res>
    implements $SalesTrendPointCopyWith<$Res> {
  factory _$$SalesTrendPointImplCopyWith(
    _$SalesTrendPointImpl value,
    $Res Function(_$SalesTrendPointImpl) then,
  ) = __$$SalesTrendPointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String month, double value});
}

/// @nodoc
class __$$SalesTrendPointImplCopyWithImpl<$Res>
    extends _$SalesTrendPointCopyWithImpl<$Res, _$SalesTrendPointImpl>
    implements _$$SalesTrendPointImplCopyWith<$Res> {
  __$$SalesTrendPointImplCopyWithImpl(
    _$SalesTrendPointImpl _value,
    $Res Function(_$SalesTrendPointImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SalesTrendPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? month = null, Object? value = null}) {
    return _then(
      _$SalesTrendPointImpl(
        null == month
            ? _value.month
            : month // ignore: cast_nullable_to_non_nullable
                  as String,
        null == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc

class _$SalesTrendPointImpl implements _SalesTrendPoint {
  const _$SalesTrendPointImpl(this.month, this.value);

  @override
  final String month;
  @override
  final double value;

  @override
  String toString() {
    return 'SalesTrendPoint(month: $month, value: $value)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SalesTrendPointImpl &&
            (identical(other.month, month) || other.month == month) &&
            (identical(other.value, value) || other.value == value));
  }

  @override
  int get hashCode => Object.hash(runtimeType, month, value);

  /// Create a copy of SalesTrendPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SalesTrendPointImplCopyWith<_$SalesTrendPointImpl> get copyWith =>
      __$$SalesTrendPointImplCopyWithImpl<_$SalesTrendPointImpl>(
        this,
        _$identity,
      );
}

abstract class _SalesTrendPoint implements SalesTrendPoint {
  const factory _SalesTrendPoint(final String month, final double value) =
      _$SalesTrendPointImpl;

  @override
  String get month;
  @override
  double get value;

  /// Create a copy of SalesTrendPoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SalesTrendPointImplCopyWith<_$SalesTrendPointImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$TopSalesCategory {
  String get title => throw _privateConstructorUsedError;
  List<TopSalesItem> get items => throw _privateConstructorUsedError;

  /// Create a copy of TopSalesCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TopSalesCategoryCopyWith<TopSalesCategory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TopSalesCategoryCopyWith<$Res> {
  factory $TopSalesCategoryCopyWith(
    TopSalesCategory value,
    $Res Function(TopSalesCategory) then,
  ) = _$TopSalesCategoryCopyWithImpl<$Res, TopSalesCategory>;
  @useResult
  $Res call({String title, List<TopSalesItem> items});
}

/// @nodoc
class _$TopSalesCategoryCopyWithImpl<$Res, $Val extends TopSalesCategory>
    implements $TopSalesCategoryCopyWith<$Res> {
  _$TopSalesCategoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TopSalesCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? title = null, Object? items = null}) {
    return _then(
      _value.copyWith(
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<TopSalesItem>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TopSalesCategoryImplCopyWith<$Res>
    implements $TopSalesCategoryCopyWith<$Res> {
  factory _$$TopSalesCategoryImplCopyWith(
    _$TopSalesCategoryImpl value,
    $Res Function(_$TopSalesCategoryImpl) then,
  ) = __$$TopSalesCategoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String title, List<TopSalesItem> items});
}

/// @nodoc
class __$$TopSalesCategoryImplCopyWithImpl<$Res>
    extends _$TopSalesCategoryCopyWithImpl<$Res, _$TopSalesCategoryImpl>
    implements _$$TopSalesCategoryImplCopyWith<$Res> {
  __$$TopSalesCategoryImplCopyWithImpl(
    _$TopSalesCategoryImpl _value,
    $Res Function(_$TopSalesCategoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TopSalesCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? title = null, Object? items = null}) {
    return _then(
      _$TopSalesCategoryImpl(
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<TopSalesItem>,
      ),
    );
  }
}

/// @nodoc

class _$TopSalesCategoryImpl implements _TopSalesCategory {
  const _$TopSalesCategoryImpl({
    required this.title,
    required final List<TopSalesItem> items,
  }) : _items = items;

  @override
  final String title;
  final List<TopSalesItem> _items;
  @override
  List<TopSalesItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'TopSalesCategory(title: $title, items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TopSalesCategoryImpl &&
            (identical(other.title, title) || other.title == title) &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    title,
    const DeepCollectionEquality().hash(_items),
  );

  /// Create a copy of TopSalesCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TopSalesCategoryImplCopyWith<_$TopSalesCategoryImpl> get copyWith =>
      __$$TopSalesCategoryImplCopyWithImpl<_$TopSalesCategoryImpl>(
        this,
        _$identity,
      );
}

abstract class _TopSalesCategory implements TopSalesCategory {
  const factory _TopSalesCategory({
    required final String title,
    required final List<TopSalesItem> items,
  }) = _$TopSalesCategoryImpl;

  @override
  String get title;
  @override
  List<TopSalesItem> get items;

  /// Create a copy of TopSalesCategory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TopSalesCategoryImplCopyWith<_$TopSalesCategoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$TopSalesItem {
  int get sno => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get value => throw _privateConstructorUsedError;

  /// Create a copy of TopSalesItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TopSalesItemCopyWith<TopSalesItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TopSalesItemCopyWith<$Res> {
  factory $TopSalesItemCopyWith(
    TopSalesItem value,
    $Res Function(TopSalesItem) then,
  ) = _$TopSalesItemCopyWithImpl<$Res, TopSalesItem>;
  @useResult
  $Res call({int sno, String description, String value});
}

/// @nodoc
class _$TopSalesItemCopyWithImpl<$Res, $Val extends TopSalesItem>
    implements $TopSalesItemCopyWith<$Res> {
  _$TopSalesItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TopSalesItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sno = null,
    Object? description = null,
    Object? value = null,
  }) {
    return _then(
      _value.copyWith(
            sno: null == sno
                ? _value.sno
                : sno // ignore: cast_nullable_to_non_nullable
                      as int,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            value: null == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TopSalesItemImplCopyWith<$Res>
    implements $TopSalesItemCopyWith<$Res> {
  factory _$$TopSalesItemImplCopyWith(
    _$TopSalesItemImpl value,
    $Res Function(_$TopSalesItemImpl) then,
  ) = __$$TopSalesItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int sno, String description, String value});
}

/// @nodoc
class __$$TopSalesItemImplCopyWithImpl<$Res>
    extends _$TopSalesItemCopyWithImpl<$Res, _$TopSalesItemImpl>
    implements _$$TopSalesItemImplCopyWith<$Res> {
  __$$TopSalesItemImplCopyWithImpl(
    _$TopSalesItemImpl _value,
    $Res Function(_$TopSalesItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TopSalesItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sno = null,
    Object? description = null,
    Object? value = null,
  }) {
    return _then(
      _$TopSalesItemImpl(
        sno: null == sno
            ? _value.sno
            : sno // ignore: cast_nullable_to_non_nullable
                  as int,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        value: null == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$TopSalesItemImpl implements _TopSalesItem {
  const _$TopSalesItemImpl({
    required this.sno,
    required this.description,
    required this.value,
  });

  @override
  final int sno;
  @override
  final String description;
  @override
  final String value;

  @override
  String toString() {
    return 'TopSalesItem(sno: $sno, description: $description, value: $value)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TopSalesItemImpl &&
            (identical(other.sno, sno) || other.sno == sno) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.value, value) || other.value == value));
  }

  @override
  int get hashCode => Object.hash(runtimeType, sno, description, value);

  /// Create a copy of TopSalesItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TopSalesItemImplCopyWith<_$TopSalesItemImpl> get copyWith =>
      __$$TopSalesItemImplCopyWithImpl<_$TopSalesItemImpl>(this, _$identity);
}

abstract class _TopSalesItem implements TopSalesItem {
  const factory _TopSalesItem({
    required final int sno,
    required final String description,
    required final String value,
  }) = _$TopSalesItemImpl;

  @override
  int get sno;
  @override
  String get description;
  @override
  String get value;

  /// Create a copy of TopSalesItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TopSalesItemImplCopyWith<_$TopSalesItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$Message {
  String get id => throw _privateConstructorUsedError;
  String get recipient => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  String get time => throw _privateConstructorUsedError;

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MessageCopyWith<Message> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageCopyWith<$Res> {
  factory $MessageCopyWith(Message value, $Res Function(Message) then) =
      _$MessageCopyWithImpl<$Res, Message>;
  @useResult
  $Res call({String id, String recipient, String message, String time});
}

/// @nodoc
class _$MessageCopyWithImpl<$Res, $Val extends Message>
    implements $MessageCopyWith<$Res> {
  _$MessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? recipient = null,
    Object? message = null,
    Object? time = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            recipient: null == recipient
                ? _value.recipient
                : recipient // ignore: cast_nullable_to_non_nullable
                      as String,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
            time: null == time
                ? _value.time
                : time // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MessageImplCopyWith<$Res> implements $MessageCopyWith<$Res> {
  factory _$$MessageImplCopyWith(
    _$MessageImpl value,
    $Res Function(_$MessageImpl) then,
  ) = __$$MessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String recipient, String message, String time});
}

/// @nodoc
class __$$MessageImplCopyWithImpl<$Res>
    extends _$MessageCopyWithImpl<$Res, _$MessageImpl>
    implements _$$MessageImplCopyWith<$Res> {
  __$$MessageImplCopyWithImpl(
    _$MessageImpl _value,
    $Res Function(_$MessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? recipient = null,
    Object? message = null,
    Object? time = null,
  }) {
    return _then(
      _$MessageImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        recipient: null == recipient
            ? _value.recipient
            : recipient // ignore: cast_nullable_to_non_nullable
                  as String,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        time: null == time
            ? _value.time
            : time // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$MessageImpl implements _Message {
  const _$MessageImpl({
    required this.id,
    required this.recipient,
    required this.message,
    required this.time,
  });

  @override
  final String id;
  @override
  final String recipient;
  @override
  final String message;
  @override
  final String time;

  @override
  String toString() {
    return 'Message(id: $id, recipient: $recipient, message: $message, time: $time)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.recipient, recipient) ||
                other.recipient == recipient) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.time, time) || other.time == time));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, recipient, message, time);

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageImplCopyWith<_$MessageImpl> get copyWith =>
      __$$MessageImplCopyWithImpl<_$MessageImpl>(this, _$identity);
}

abstract class _Message implements Message {
  const factory _Message({
    required final String id,
    required final String recipient,
    required final String message,
    required final String time,
  }) = _$MessageImpl;

  @override
  String get id;
  @override
  String get recipient;
  @override
  String get message;
  @override
  String get time;

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageImplCopyWith<_$MessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$JobCardRegisterItem {
  String get label => throw _privateConstructorUsedError;
  int get open => throw _privateConstructorUsedError;
  int get completed => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;

  /// Create a copy of JobCardRegisterItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JobCardRegisterItemCopyWith<JobCardRegisterItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JobCardRegisterItemCopyWith<$Res> {
  factory $JobCardRegisterItemCopyWith(
    JobCardRegisterItem value,
    $Res Function(JobCardRegisterItem) then,
  ) = _$JobCardRegisterItemCopyWithImpl<$Res, JobCardRegisterItem>;
  @useResult
  $Res call({String label, int open, int completed, int total});
}

/// @nodoc
class _$JobCardRegisterItemCopyWithImpl<$Res, $Val extends JobCardRegisterItem>
    implements $JobCardRegisterItemCopyWith<$Res> {
  _$JobCardRegisterItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of JobCardRegisterItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? open = null,
    Object? completed = null,
    Object? total = null,
  }) {
    return _then(
      _value.copyWith(
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            open: null == open
                ? _value.open
                : open // ignore: cast_nullable_to_non_nullable
                      as int,
            completed: null == completed
                ? _value.completed
                : completed // ignore: cast_nullable_to_non_nullable
                      as int,
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$JobCardRegisterItemImplCopyWith<$Res>
    implements $JobCardRegisterItemCopyWith<$Res> {
  factory _$$JobCardRegisterItemImplCopyWith(
    _$JobCardRegisterItemImpl value,
    $Res Function(_$JobCardRegisterItemImpl) then,
  ) = __$$JobCardRegisterItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String label, int open, int completed, int total});
}

/// @nodoc
class __$$JobCardRegisterItemImplCopyWithImpl<$Res>
    extends _$JobCardRegisterItemCopyWithImpl<$Res, _$JobCardRegisterItemImpl>
    implements _$$JobCardRegisterItemImplCopyWith<$Res> {
  __$$JobCardRegisterItemImplCopyWithImpl(
    _$JobCardRegisterItemImpl _value,
    $Res Function(_$JobCardRegisterItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of JobCardRegisterItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? open = null,
    Object? completed = null,
    Object? total = null,
  }) {
    return _then(
      _$JobCardRegisterItemImpl(
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        open: null == open
            ? _value.open
            : open // ignore: cast_nullable_to_non_nullable
                  as int,
        completed: null == completed
            ? _value.completed
            : completed // ignore: cast_nullable_to_non_nullable
                  as int,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$JobCardRegisterItemImpl implements _JobCardRegisterItem {
  const _$JobCardRegisterItemImpl({
    required this.label,
    required this.open,
    required this.completed,
    required this.total,
  });

  @override
  final String label;
  @override
  final int open;
  @override
  final int completed;
  @override
  final int total;

  @override
  String toString() {
    return 'JobCardRegisterItem(label: $label, open: $open, completed: $completed, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JobCardRegisterItemImpl &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.open, open) || other.open == open) &&
            (identical(other.completed, completed) ||
                other.completed == completed) &&
            (identical(other.total, total) || other.total == total));
  }

  @override
  int get hashCode => Object.hash(runtimeType, label, open, completed, total);

  /// Create a copy of JobCardRegisterItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JobCardRegisterItemImplCopyWith<_$JobCardRegisterItemImpl> get copyWith =>
      __$$JobCardRegisterItemImplCopyWithImpl<_$JobCardRegisterItemImpl>(
        this,
        _$identity,
      );
}

abstract class _JobCardRegisterItem implements JobCardRegisterItem {
  const factory _JobCardRegisterItem({
    required final String label,
    required final int open,
    required final int completed,
    required final int total,
  }) = _$JobCardRegisterItemImpl;

  @override
  String get label;
  @override
  int get open;
  @override
  int get completed;
  @override
  int get total;

  /// Create a copy of JobCardRegisterItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JobCardRegisterItemImplCopyWith<_$JobCardRegisterItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
