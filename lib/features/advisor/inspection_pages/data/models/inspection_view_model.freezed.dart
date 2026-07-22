// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inspection_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ItemMedia _$ItemMediaFromJson(Map<String, dynamic> json) {
  return _ItemMedia.fromJson(json);
}

/// @nodoc
mixin _$ItemMedia {
  List<String> get photoPaths => throw _privateConstructorUsedError;
  List<String> get videoPaths => throw _privateConstructorUsedError;
  String get audioPath => throw _privateConstructorUsedError;
  String get note => throw _privateConstructorUsedError;

  /// Serializes this ItemMedia to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ItemMedia
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ItemMediaCopyWith<ItemMedia> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ItemMediaCopyWith<$Res> {
  factory $ItemMediaCopyWith(ItemMedia value, $Res Function(ItemMedia) then) =
      _$ItemMediaCopyWithImpl<$Res, ItemMedia>;
  @useResult
  $Res call({
    List<String> photoPaths,
    List<String> videoPaths,
    String audioPath,
    String note,
  });
}

/// @nodoc
class _$ItemMediaCopyWithImpl<$Res, $Val extends ItemMedia>
    implements $ItemMediaCopyWith<$Res> {
  _$ItemMediaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ItemMedia
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? photoPaths = null,
    Object? videoPaths = null,
    Object? audioPath = null,
    Object? note = null,
  }) {
    return _then(
      _value.copyWith(
            photoPaths: null == photoPaths
                ? _value.photoPaths
                : photoPaths // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            videoPaths: null == videoPaths
                ? _value.videoPaths
                : videoPaths // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            audioPath: null == audioPath
                ? _value.audioPath
                : audioPath // ignore: cast_nullable_to_non_nullable
                      as String,
            note: null == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ItemMediaImplCopyWith<$Res>
    implements $ItemMediaCopyWith<$Res> {
  factory _$$ItemMediaImplCopyWith(
    _$ItemMediaImpl value,
    $Res Function(_$ItemMediaImpl) then,
  ) = __$$ItemMediaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<String> photoPaths,
    List<String> videoPaths,
    String audioPath,
    String note,
  });
}

/// @nodoc
class __$$ItemMediaImplCopyWithImpl<$Res>
    extends _$ItemMediaCopyWithImpl<$Res, _$ItemMediaImpl>
    implements _$$ItemMediaImplCopyWith<$Res> {
  __$$ItemMediaImplCopyWithImpl(
    _$ItemMediaImpl _value,
    $Res Function(_$ItemMediaImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ItemMedia
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? photoPaths = null,
    Object? videoPaths = null,
    Object? audioPath = null,
    Object? note = null,
  }) {
    return _then(
      _$ItemMediaImpl(
        photoPaths: null == photoPaths
            ? _value._photoPaths
            : photoPaths // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        videoPaths: null == videoPaths
            ? _value._videoPaths
            : videoPaths // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        audioPath: null == audioPath
            ? _value.audioPath
            : audioPath // ignore: cast_nullable_to_non_nullable
                  as String,
        note: null == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ItemMediaImpl extends _ItemMedia {
  const _$ItemMediaImpl({
    final List<String> photoPaths = const <String>[],
    final List<String> videoPaths = const <String>[],
    this.audioPath = '',
    this.note = '',
  }) : _photoPaths = photoPaths,
       _videoPaths = videoPaths,
       super._();

  factory _$ItemMediaImpl.fromJson(Map<String, dynamic> json) =>
      _$$ItemMediaImplFromJson(json);

  final List<String> _photoPaths;
  @override
  @JsonKey()
  List<String> get photoPaths {
    if (_photoPaths is EqualUnmodifiableListView) return _photoPaths;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_photoPaths);
  }

  final List<String> _videoPaths;
  @override
  @JsonKey()
  List<String> get videoPaths {
    if (_videoPaths is EqualUnmodifiableListView) return _videoPaths;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_videoPaths);
  }

  @override
  @JsonKey()
  final String audioPath;
  @override
  @JsonKey()
  final String note;

  @override
  String toString() {
    return 'ItemMedia(photoPaths: $photoPaths, videoPaths: $videoPaths, audioPath: $audioPath, note: $note)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ItemMediaImpl &&
            const DeepCollectionEquality().equals(
              other._photoPaths,
              _photoPaths,
            ) &&
            const DeepCollectionEquality().equals(
              other._videoPaths,
              _videoPaths,
            ) &&
            (identical(other.audioPath, audioPath) ||
                other.audioPath == audioPath) &&
            (identical(other.note, note) || other.note == note));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_photoPaths),
    const DeepCollectionEquality().hash(_videoPaths),
    audioPath,
    note,
  );

  /// Create a copy of ItemMedia
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ItemMediaImplCopyWith<_$ItemMediaImpl> get copyWith =>
      __$$ItemMediaImplCopyWithImpl<_$ItemMediaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ItemMediaImplToJson(this);
  }
}

abstract class _ItemMedia extends ItemMedia {
  const factory _ItemMedia({
    final List<String> photoPaths,
    final List<String> videoPaths,
    final String audioPath,
    final String note,
  }) = _$ItemMediaImpl;
  const _ItemMedia._() : super._();

  factory _ItemMedia.fromJson(Map<String, dynamic> json) =
      _$ItemMediaImpl.fromJson;

  @override
  List<String> get photoPaths;
  @override
  List<String> get videoPaths;
  @override
  String get audioPath;
  @override
  String get note;

  /// Create a copy of ItemMedia
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ItemMediaImplCopyWith<_$ItemMediaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ServiceLineItem _$ServiceLineItemFromJson(Map<String, dynamic> json) {
  return _ServiceLineItem.fromJson(json);
}

/// @nodoc
mixin _$ServiceLineItem {
  String get name => throw _privateConstructorUsedError;
  int get qty => throw _privateConstructorUsedError;
  double get rate => throw _privateConstructorUsedError;
  double get discountPercent => throw _privateConstructorUsedError;
  double get discountAmount => throw _privateConstructorUsedError;

  /// Serializes this ServiceLineItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ServiceLineItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ServiceLineItemCopyWith<ServiceLineItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServiceLineItemCopyWith<$Res> {
  factory $ServiceLineItemCopyWith(
    ServiceLineItem value,
    $Res Function(ServiceLineItem) then,
  ) = _$ServiceLineItemCopyWithImpl<$Res, ServiceLineItem>;
  @useResult
  $Res call({
    String name,
    int qty,
    double rate,
    double discountPercent,
    double discountAmount,
  });
}

/// @nodoc
class _$ServiceLineItemCopyWithImpl<$Res, $Val extends ServiceLineItem>
    implements $ServiceLineItemCopyWith<$Res> {
  _$ServiceLineItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ServiceLineItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? qty = null,
    Object? rate = null,
    Object? discountPercent = null,
    Object? discountAmount = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            qty: null == qty
                ? _value.qty
                : qty // ignore: cast_nullable_to_non_nullable
                      as int,
            rate: null == rate
                ? _value.rate
                : rate // ignore: cast_nullable_to_non_nullable
                      as double,
            discountPercent: null == discountPercent
                ? _value.discountPercent
                : discountPercent // ignore: cast_nullable_to_non_nullable
                      as double,
            discountAmount: null == discountAmount
                ? _value.discountAmount
                : discountAmount // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ServiceLineItemImplCopyWith<$Res>
    implements $ServiceLineItemCopyWith<$Res> {
  factory _$$ServiceLineItemImplCopyWith(
    _$ServiceLineItemImpl value,
    $Res Function(_$ServiceLineItemImpl) then,
  ) = __$$ServiceLineItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    int qty,
    double rate,
    double discountPercent,
    double discountAmount,
  });
}

/// @nodoc
class __$$ServiceLineItemImplCopyWithImpl<$Res>
    extends _$ServiceLineItemCopyWithImpl<$Res, _$ServiceLineItemImpl>
    implements _$$ServiceLineItemImplCopyWith<$Res> {
  __$$ServiceLineItemImplCopyWithImpl(
    _$ServiceLineItemImpl _value,
    $Res Function(_$ServiceLineItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ServiceLineItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? qty = null,
    Object? rate = null,
    Object? discountPercent = null,
    Object? discountAmount = null,
  }) {
    return _then(
      _$ServiceLineItemImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        qty: null == qty
            ? _value.qty
            : qty // ignore: cast_nullable_to_non_nullable
                  as int,
        rate: null == rate
            ? _value.rate
            : rate // ignore: cast_nullable_to_non_nullable
                  as double,
        discountPercent: null == discountPercent
            ? _value.discountPercent
            : discountPercent // ignore: cast_nullable_to_non_nullable
                  as double,
        discountAmount: null == discountAmount
            ? _value.discountAmount
            : discountAmount // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ServiceLineItemImpl extends _ServiceLineItem {
  const _$ServiceLineItemImpl({
    required this.name,
    this.qty = 1,
    this.rate = 0,
    this.discountPercent = 0,
    this.discountAmount = 0,
  }) : super._();

  factory _$ServiceLineItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ServiceLineItemImplFromJson(json);

  @override
  final String name;
  @override
  @JsonKey()
  final int qty;
  @override
  @JsonKey()
  final double rate;
  @override
  @JsonKey()
  final double discountPercent;
  @override
  @JsonKey()
  final double discountAmount;

  @override
  String toString() {
    return 'ServiceLineItem(name: $name, qty: $qty, rate: $rate, discountPercent: $discountPercent, discountAmount: $discountAmount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServiceLineItemImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.qty, qty) || other.qty == qty) &&
            (identical(other.rate, rate) || other.rate == rate) &&
            (identical(other.discountPercent, discountPercent) ||
                other.discountPercent == discountPercent) &&
            (identical(other.discountAmount, discountAmount) ||
                other.discountAmount == discountAmount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    qty,
    rate,
    discountPercent,
    discountAmount,
  );

  /// Create a copy of ServiceLineItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ServiceLineItemImplCopyWith<_$ServiceLineItemImpl> get copyWith =>
      __$$ServiceLineItemImplCopyWithImpl<_$ServiceLineItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ServiceLineItemImplToJson(this);
  }
}

abstract class _ServiceLineItem extends ServiceLineItem {
  const factory _ServiceLineItem({
    required final String name,
    final int qty,
    final double rate,
    final double discountPercent,
    final double discountAmount,
  }) = _$ServiceLineItemImpl;
  const _ServiceLineItem._() : super._();

  factory _ServiceLineItem.fromJson(Map<String, dynamic> json) =
      _$ServiceLineItemImpl.fromJson;

  @override
  String get name;
  @override
  int get qty;
  @override
  double get rate;
  @override
  double get discountPercent;
  @override
  double get discountAmount;

  /// Create a copy of ServiceLineItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ServiceLineItemImplCopyWith<_$ServiceLineItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PartLineItem _$PartLineItemFromJson(Map<String, dynamic> json) {
  return _PartLineItem.fromJson(json);
}

/// @nodoc
mixin _$PartLineItem {
  String get name => throw _privateConstructorUsedError;
  int get qty => throw _privateConstructorUsedError;
  double get rate => throw _privateConstructorUsedError;
  double get discountPercent => throw _privateConstructorUsedError;
  double get discountAmount => throw _privateConstructorUsedError;

  /// Serializes this PartLineItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PartLineItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PartLineItemCopyWith<PartLineItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PartLineItemCopyWith<$Res> {
  factory $PartLineItemCopyWith(
    PartLineItem value,
    $Res Function(PartLineItem) then,
  ) = _$PartLineItemCopyWithImpl<$Res, PartLineItem>;
  @useResult
  $Res call({
    String name,
    int qty,
    double rate,
    double discountPercent,
    double discountAmount,
  });
}

/// @nodoc
class _$PartLineItemCopyWithImpl<$Res, $Val extends PartLineItem>
    implements $PartLineItemCopyWith<$Res> {
  _$PartLineItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PartLineItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? qty = null,
    Object? rate = null,
    Object? discountPercent = null,
    Object? discountAmount = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            qty: null == qty
                ? _value.qty
                : qty // ignore: cast_nullable_to_non_nullable
                      as int,
            rate: null == rate
                ? _value.rate
                : rate // ignore: cast_nullable_to_non_nullable
                      as double,
            discountPercent: null == discountPercent
                ? _value.discountPercent
                : discountPercent // ignore: cast_nullable_to_non_nullable
                      as double,
            discountAmount: null == discountAmount
                ? _value.discountAmount
                : discountAmount // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PartLineItemImplCopyWith<$Res>
    implements $PartLineItemCopyWith<$Res> {
  factory _$$PartLineItemImplCopyWith(
    _$PartLineItemImpl value,
    $Res Function(_$PartLineItemImpl) then,
  ) = __$$PartLineItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    int qty,
    double rate,
    double discountPercent,
    double discountAmount,
  });
}

/// @nodoc
class __$$PartLineItemImplCopyWithImpl<$Res>
    extends _$PartLineItemCopyWithImpl<$Res, _$PartLineItemImpl>
    implements _$$PartLineItemImplCopyWith<$Res> {
  __$$PartLineItemImplCopyWithImpl(
    _$PartLineItemImpl _value,
    $Res Function(_$PartLineItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PartLineItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? qty = null,
    Object? rate = null,
    Object? discountPercent = null,
    Object? discountAmount = null,
  }) {
    return _then(
      _$PartLineItemImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        qty: null == qty
            ? _value.qty
            : qty // ignore: cast_nullable_to_non_nullable
                  as int,
        rate: null == rate
            ? _value.rate
            : rate // ignore: cast_nullable_to_non_nullable
                  as double,
        discountPercent: null == discountPercent
            ? _value.discountPercent
            : discountPercent // ignore: cast_nullable_to_non_nullable
                  as double,
        discountAmount: null == discountAmount
            ? _value.discountAmount
            : discountAmount // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PartLineItemImpl extends _PartLineItem {
  const _$PartLineItemImpl({
    required this.name,
    this.qty = 1,
    this.rate = 0,
    this.discountPercent = 0,
    this.discountAmount = 0,
  }) : super._();

  factory _$PartLineItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$PartLineItemImplFromJson(json);

  @override
  final String name;
  @override
  @JsonKey()
  final int qty;
  @override
  @JsonKey()
  final double rate;
  @override
  @JsonKey()
  final double discountPercent;
  @override
  @JsonKey()
  final double discountAmount;

  @override
  String toString() {
    return 'PartLineItem(name: $name, qty: $qty, rate: $rate, discountPercent: $discountPercent, discountAmount: $discountAmount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PartLineItemImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.qty, qty) || other.qty == qty) &&
            (identical(other.rate, rate) || other.rate == rate) &&
            (identical(other.discountPercent, discountPercent) ||
                other.discountPercent == discountPercent) &&
            (identical(other.discountAmount, discountAmount) ||
                other.discountAmount == discountAmount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    qty,
    rate,
    discountPercent,
    discountAmount,
  );

  /// Create a copy of PartLineItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PartLineItemImplCopyWith<_$PartLineItemImpl> get copyWith =>
      __$$PartLineItemImplCopyWithImpl<_$PartLineItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PartLineItemImplToJson(this);
  }
}

abstract class _PartLineItem extends PartLineItem {
  const factory _PartLineItem({
    required final String name,
    final int qty,
    final double rate,
    final double discountPercent,
    final double discountAmount,
  }) = _$PartLineItemImpl;
  const _PartLineItem._() : super._();

  factory _PartLineItem.fromJson(Map<String, dynamic> json) =
      _$PartLineItemImpl.fromJson;

  @override
  String get name;
  @override
  int get qty;
  @override
  double get rate;
  @override
  double get discountPercent;
  @override
  double get discountAmount;

  /// Create a copy of PartLineItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PartLineItemImplCopyWith<_$PartLineItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
