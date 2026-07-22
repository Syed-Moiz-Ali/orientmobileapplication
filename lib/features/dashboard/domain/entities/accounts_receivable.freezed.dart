// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'accounts_receivable.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ARRecord {
  String get arId => throw _privateConstructorUsedError;
  String get customer => throw _privateConstructorUsedError;
  String get invoiceDate => throw _privateConstructorUsedError;
  String get dueDate => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  double get outstanding => throw _privateConstructorUsedError;
  AgingBucket get aging => throw _privateConstructorUsedError;
  String get contactPerson => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;

  /// Create a copy of ARRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ARRecordCopyWith<ARRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ARRecordCopyWith<$Res> {
  factory $ARRecordCopyWith(ARRecord value, $Res Function(ARRecord) then) =
      _$ARRecordCopyWithImpl<$Res, ARRecord>;
  @useResult
  $Res call({
    String arId,
    String customer,
    String invoiceDate,
    String dueDate,
    double amount,
    double outstanding,
    AgingBucket aging,
    String contactPerson,
    String phone,
  });
}

/// @nodoc
class _$ARRecordCopyWithImpl<$Res, $Val extends ARRecord>
    implements $ARRecordCopyWith<$Res> {
  _$ARRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ARRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? arId = null,
    Object? customer = null,
    Object? invoiceDate = null,
    Object? dueDate = null,
    Object? amount = null,
    Object? outstanding = null,
    Object? aging = null,
    Object? contactPerson = null,
    Object? phone = null,
  }) {
    return _then(
      _value.copyWith(
            arId: null == arId
                ? _value.arId
                : arId // ignore: cast_nullable_to_non_nullable
                      as String,
            customer: null == customer
                ? _value.customer
                : customer // ignore: cast_nullable_to_non_nullable
                      as String,
            invoiceDate: null == invoiceDate
                ? _value.invoiceDate
                : invoiceDate // ignore: cast_nullable_to_non_nullable
                      as String,
            dueDate: null == dueDate
                ? _value.dueDate
                : dueDate // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            outstanding: null == outstanding
                ? _value.outstanding
                : outstanding // ignore: cast_nullable_to_non_nullable
                      as double,
            aging: null == aging
                ? _value.aging
                : aging // ignore: cast_nullable_to_non_nullable
                      as AgingBucket,
            contactPerson: null == contactPerson
                ? _value.contactPerson
                : contactPerson // ignore: cast_nullable_to_non_nullable
                      as String,
            phone: null == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ARRecordImplCopyWith<$Res>
    implements $ARRecordCopyWith<$Res> {
  factory _$$ARRecordImplCopyWith(
    _$ARRecordImpl value,
    $Res Function(_$ARRecordImpl) then,
  ) = __$$ARRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String arId,
    String customer,
    String invoiceDate,
    String dueDate,
    double amount,
    double outstanding,
    AgingBucket aging,
    String contactPerson,
    String phone,
  });
}

/// @nodoc
class __$$ARRecordImplCopyWithImpl<$Res>
    extends _$ARRecordCopyWithImpl<$Res, _$ARRecordImpl>
    implements _$$ARRecordImplCopyWith<$Res> {
  __$$ARRecordImplCopyWithImpl(
    _$ARRecordImpl _value,
    $Res Function(_$ARRecordImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ARRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? arId = null,
    Object? customer = null,
    Object? invoiceDate = null,
    Object? dueDate = null,
    Object? amount = null,
    Object? outstanding = null,
    Object? aging = null,
    Object? contactPerson = null,
    Object? phone = null,
  }) {
    return _then(
      _$ARRecordImpl(
        arId: null == arId
            ? _value.arId
            : arId // ignore: cast_nullable_to_non_nullable
                  as String,
        customer: null == customer
            ? _value.customer
            : customer // ignore: cast_nullable_to_non_nullable
                  as String,
        invoiceDate: null == invoiceDate
            ? _value.invoiceDate
            : invoiceDate // ignore: cast_nullable_to_non_nullable
                  as String,
        dueDate: null == dueDate
            ? _value.dueDate
            : dueDate // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        outstanding: null == outstanding
            ? _value.outstanding
            : outstanding // ignore: cast_nullable_to_non_nullable
                  as double,
        aging: null == aging
            ? _value.aging
            : aging // ignore: cast_nullable_to_non_nullable
                  as AgingBucket,
        contactPerson: null == contactPerson
            ? _value.contactPerson
            : contactPerson // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: null == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$ARRecordImpl implements _ARRecord {
  const _$ARRecordImpl({
    required this.arId,
    required this.customer,
    required this.invoiceDate,
    required this.dueDate,
    required this.amount,
    required this.outstanding,
    required this.aging,
    required this.contactPerson,
    required this.phone,
  });

  @override
  final String arId;
  @override
  final String customer;
  @override
  final String invoiceDate;
  @override
  final String dueDate;
  @override
  final double amount;
  @override
  final double outstanding;
  @override
  final AgingBucket aging;
  @override
  final String contactPerson;
  @override
  final String phone;

  @override
  String toString() {
    return 'ARRecord(arId: $arId, customer: $customer, invoiceDate: $invoiceDate, dueDate: $dueDate, amount: $amount, outstanding: $outstanding, aging: $aging, contactPerson: $contactPerson, phone: $phone)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ARRecordImpl &&
            (identical(other.arId, arId) || other.arId == arId) &&
            (identical(other.customer, customer) ||
                other.customer == customer) &&
            (identical(other.invoiceDate, invoiceDate) ||
                other.invoiceDate == invoiceDate) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.outstanding, outstanding) ||
                other.outstanding == outstanding) &&
            (identical(other.aging, aging) || other.aging == aging) &&
            (identical(other.contactPerson, contactPerson) ||
                other.contactPerson == contactPerson) &&
            (identical(other.phone, phone) || other.phone == phone));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    arId,
    customer,
    invoiceDate,
    dueDate,
    amount,
    outstanding,
    aging,
    contactPerson,
    phone,
  );

  /// Create a copy of ARRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ARRecordImplCopyWith<_$ARRecordImpl> get copyWith =>
      __$$ARRecordImplCopyWithImpl<_$ARRecordImpl>(this, _$identity);
}

abstract class _ARRecord implements ARRecord {
  const factory _ARRecord({
    required final String arId,
    required final String customer,
    required final String invoiceDate,
    required final String dueDate,
    required final double amount,
    required final double outstanding,
    required final AgingBucket aging,
    required final String contactPerson,
    required final String phone,
  }) = _$ARRecordImpl;

  @override
  String get arId;
  @override
  String get customer;
  @override
  String get invoiceDate;
  @override
  String get dueDate;
  @override
  double get amount;
  @override
  double get outstanding;
  @override
  AgingBucket get aging;
  @override
  String get contactPerson;
  @override
  String get phone;

  /// Create a copy of ARRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ARRecordImplCopyWith<_$ARRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ARSummary {
  double get totalOutstanding => throw _privateConstructorUsedError;
  double get days0to30 => throw _privateConstructorUsedError;
  double get days31to60 => throw _privateConstructorUsedError;
  double get days61to90 => throw _privateConstructorUsedError;
  double get days90plus => throw _privateConstructorUsedError;

  /// Create a copy of ARSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ARSummaryCopyWith<ARSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ARSummaryCopyWith<$Res> {
  factory $ARSummaryCopyWith(ARSummary value, $Res Function(ARSummary) then) =
      _$ARSummaryCopyWithImpl<$Res, ARSummary>;
  @useResult
  $Res call({
    double totalOutstanding,
    double days0to30,
    double days31to60,
    double days61to90,
    double days90plus,
  });
}

/// @nodoc
class _$ARSummaryCopyWithImpl<$Res, $Val extends ARSummary>
    implements $ARSummaryCopyWith<$Res> {
  _$ARSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ARSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalOutstanding = null,
    Object? days0to30 = null,
    Object? days31to60 = null,
    Object? days61to90 = null,
    Object? days90plus = null,
  }) {
    return _then(
      _value.copyWith(
            totalOutstanding: null == totalOutstanding
                ? _value.totalOutstanding
                : totalOutstanding // ignore: cast_nullable_to_non_nullable
                      as double,
            days0to30: null == days0to30
                ? _value.days0to30
                : days0to30 // ignore: cast_nullable_to_non_nullable
                      as double,
            days31to60: null == days31to60
                ? _value.days31to60
                : days31to60 // ignore: cast_nullable_to_non_nullable
                      as double,
            days61to90: null == days61to90
                ? _value.days61to90
                : days61to90 // ignore: cast_nullable_to_non_nullable
                      as double,
            days90plus: null == days90plus
                ? _value.days90plus
                : days90plus // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ARSummaryImplCopyWith<$Res>
    implements $ARSummaryCopyWith<$Res> {
  factory _$$ARSummaryImplCopyWith(
    _$ARSummaryImpl value,
    $Res Function(_$ARSummaryImpl) then,
  ) = __$$ARSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double totalOutstanding,
    double days0to30,
    double days31to60,
    double days61to90,
    double days90plus,
  });
}

/// @nodoc
class __$$ARSummaryImplCopyWithImpl<$Res>
    extends _$ARSummaryCopyWithImpl<$Res, _$ARSummaryImpl>
    implements _$$ARSummaryImplCopyWith<$Res> {
  __$$ARSummaryImplCopyWithImpl(
    _$ARSummaryImpl _value,
    $Res Function(_$ARSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ARSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalOutstanding = null,
    Object? days0to30 = null,
    Object? days31to60 = null,
    Object? days61to90 = null,
    Object? days90plus = null,
  }) {
    return _then(
      _$ARSummaryImpl(
        totalOutstanding: null == totalOutstanding
            ? _value.totalOutstanding
            : totalOutstanding // ignore: cast_nullable_to_non_nullable
                  as double,
        days0to30: null == days0to30
            ? _value.days0to30
            : days0to30 // ignore: cast_nullable_to_non_nullable
                  as double,
        days31to60: null == days31to60
            ? _value.days31to60
            : days31to60 // ignore: cast_nullable_to_non_nullable
                  as double,
        days61to90: null == days61to90
            ? _value.days61to90
            : days61to90 // ignore: cast_nullable_to_non_nullable
                  as double,
        days90plus: null == days90plus
            ? _value.days90plus
            : days90plus // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc

class _$ARSummaryImpl implements _ARSummary {
  const _$ARSummaryImpl({
    required this.totalOutstanding,
    required this.days0to30,
    required this.days31to60,
    required this.days61to90,
    required this.days90plus,
  });

  @override
  final double totalOutstanding;
  @override
  final double days0to30;
  @override
  final double days31to60;
  @override
  final double days61to90;
  @override
  final double days90plus;

  @override
  String toString() {
    return 'ARSummary(totalOutstanding: $totalOutstanding, days0to30: $days0to30, days31to60: $days31to60, days61to90: $days61to90, days90plus: $days90plus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ARSummaryImpl &&
            (identical(other.totalOutstanding, totalOutstanding) ||
                other.totalOutstanding == totalOutstanding) &&
            (identical(other.days0to30, days0to30) ||
                other.days0to30 == days0to30) &&
            (identical(other.days31to60, days31to60) ||
                other.days31to60 == days31to60) &&
            (identical(other.days61to90, days61to90) ||
                other.days61to90 == days61to90) &&
            (identical(other.days90plus, days90plus) ||
                other.days90plus == days90plus));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    totalOutstanding,
    days0to30,
    days31to60,
    days61to90,
    days90plus,
  );

  /// Create a copy of ARSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ARSummaryImplCopyWith<_$ARSummaryImpl> get copyWith =>
      __$$ARSummaryImplCopyWithImpl<_$ARSummaryImpl>(this, _$identity);
}

abstract class _ARSummary implements ARSummary {
  const factory _ARSummary({
    required final double totalOutstanding,
    required final double days0to30,
    required final double days31to60,
    required final double days61to90,
    required final double days90plus,
  }) = _$ARSummaryImpl;

  @override
  double get totalOutstanding;
  @override
  double get days0to30;
  @override
  double get days31to60;
  @override
  double get days61to90;
  @override
  double get days90plus;

  /// Create a copy of ARSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ARSummaryImplCopyWith<_$ARSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
