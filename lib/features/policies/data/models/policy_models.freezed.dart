// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'policy_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Policy _$PolicyFromJson(Map<String, dynamic> json) {
  return _Policy.fromJson(json);
}

/// @nodoc
mixin _$Policy {
  @JsonKey(name: 'policy_id')
  String get policyId => throw _privateConstructorUsedError;
  @JsonKey(name: 'policy_number')
  String get policyNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'plan_name')
  String get planName => throw _privateConstructorUsedError;
  @JsonKey(name: 'sum_assured')
  double get sumAssured => throw _privateConstructorUsedError;
  @JsonKey(name: 'premium_amount')
  double get premiumAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'premium_frequency')
  String get premiumFrequency => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_date')
  DateTime get startDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'maturity_date')
  DateTime? get maturityDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'next_payment_date')
  DateTime? get nextPaymentDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'status')
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'policy_document_url')
  String? get policyDocumentUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'application_form_url')
  String? get applicationFormUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'outstanding_amount')
  double? get outstandingAmount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PolicyCopyWith<Policy> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PolicyCopyWith<$Res> {
  factory $PolicyCopyWith(Policy value, $Res Function(Policy) then) =
      _$PolicyCopyWithImpl<$Res, Policy>;
  @useResult
  $Res call(
      {@JsonKey(name: 'policy_id') String policyId,
      @JsonKey(name: 'policy_number') String policyNumber,
      @JsonKey(name: 'plan_name') String planName,
      @JsonKey(name: 'sum_assured') double sumAssured,
      @JsonKey(name: 'premium_amount') double premiumAmount,
      @JsonKey(name: 'premium_frequency') String premiumFrequency,
      @JsonKey(name: 'start_date') DateTime startDate,
      @JsonKey(name: 'maturity_date') DateTime? maturityDate,
      @JsonKey(name: 'next_payment_date') DateTime? nextPaymentDate,
      @JsonKey(name: 'status') String status,
      @JsonKey(name: 'policy_document_url') String? policyDocumentUrl,
      @JsonKey(name: 'application_form_url') String? applicationFormUrl,
      @JsonKey(name: 'outstanding_amount') double? outstandingAmount});
}

/// @nodoc
class _$PolicyCopyWithImpl<$Res, $Val extends Policy>
    implements $PolicyCopyWith<$Res> {
  _$PolicyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? policyId = null,
    Object? policyNumber = null,
    Object? planName = null,
    Object? sumAssured = null,
    Object? premiumAmount = null,
    Object? premiumFrequency = null,
    Object? startDate = null,
    Object? maturityDate = freezed,
    Object? nextPaymentDate = freezed,
    Object? status = null,
    Object? policyDocumentUrl = freezed,
    Object? applicationFormUrl = freezed,
    Object? outstandingAmount = freezed,
  }) {
    return _then(_value.copyWith(
      policyId: null == policyId
          ? _value.policyId
          : policyId // ignore: cast_nullable_to_non_nullable
              as String,
      policyNumber: null == policyNumber
          ? _value.policyNumber
          : policyNumber // ignore: cast_nullable_to_non_nullable
              as String,
      planName: null == planName
          ? _value.planName
          : planName // ignore: cast_nullable_to_non_nullable
              as String,
      sumAssured: null == sumAssured
          ? _value.sumAssured
          : sumAssured // ignore: cast_nullable_to_non_nullable
              as double,
      premiumAmount: null == premiumAmount
          ? _value.premiumAmount
          : premiumAmount // ignore: cast_nullable_to_non_nullable
              as double,
      premiumFrequency: null == premiumFrequency
          ? _value.premiumFrequency
          : premiumFrequency // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      maturityDate: freezed == maturityDate
          ? _value.maturityDate
          : maturityDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      nextPaymentDate: freezed == nextPaymentDate
          ? _value.nextPaymentDate
          : nextPaymentDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      policyDocumentUrl: freezed == policyDocumentUrl
          ? _value.policyDocumentUrl
          : policyDocumentUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      applicationFormUrl: freezed == applicationFormUrl
          ? _value.applicationFormUrl
          : applicationFormUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      outstandingAmount: freezed == outstandingAmount
          ? _value.outstandingAmount
          : outstandingAmount // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PolicyImplCopyWith<$Res> implements $PolicyCopyWith<$Res> {
  factory _$$PolicyImplCopyWith(
          _$PolicyImpl value, $Res Function(_$PolicyImpl) then) =
      __$$PolicyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'policy_id') String policyId,
      @JsonKey(name: 'policy_number') String policyNumber,
      @JsonKey(name: 'plan_name') String planName,
      @JsonKey(name: 'sum_assured') double sumAssured,
      @JsonKey(name: 'premium_amount') double premiumAmount,
      @JsonKey(name: 'premium_frequency') String premiumFrequency,
      @JsonKey(name: 'start_date') DateTime startDate,
      @JsonKey(name: 'maturity_date') DateTime? maturityDate,
      @JsonKey(name: 'next_payment_date') DateTime? nextPaymentDate,
      @JsonKey(name: 'status') String status,
      @JsonKey(name: 'policy_document_url') String? policyDocumentUrl,
      @JsonKey(name: 'application_form_url') String? applicationFormUrl,
      @JsonKey(name: 'outstanding_amount') double? outstandingAmount});
}

/// @nodoc
class __$$PolicyImplCopyWithImpl<$Res>
    extends _$PolicyCopyWithImpl<$Res, _$PolicyImpl>
    implements _$$PolicyImplCopyWith<$Res> {
  __$$PolicyImplCopyWithImpl(
      _$PolicyImpl _value, $Res Function(_$PolicyImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? policyId = null,
    Object? policyNumber = null,
    Object? planName = null,
    Object? sumAssured = null,
    Object? premiumAmount = null,
    Object? premiumFrequency = null,
    Object? startDate = null,
    Object? maturityDate = freezed,
    Object? nextPaymentDate = freezed,
    Object? status = null,
    Object? policyDocumentUrl = freezed,
    Object? applicationFormUrl = freezed,
    Object? outstandingAmount = freezed,
  }) {
    return _then(_$PolicyImpl(
      policyId: null == policyId
          ? _value.policyId
          : policyId // ignore: cast_nullable_to_non_nullable
              as String,
      policyNumber: null == policyNumber
          ? _value.policyNumber
          : policyNumber // ignore: cast_nullable_to_non_nullable
              as String,
      planName: null == planName
          ? _value.planName
          : planName // ignore: cast_nullable_to_non_nullable
              as String,
      sumAssured: null == sumAssured
          ? _value.sumAssured
          : sumAssured // ignore: cast_nullable_to_non_nullable
              as double,
      premiumAmount: null == premiumAmount
          ? _value.premiumAmount
          : premiumAmount // ignore: cast_nullable_to_non_nullable
              as double,
      premiumFrequency: null == premiumFrequency
          ? _value.premiumFrequency
          : premiumFrequency // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      maturityDate: freezed == maturityDate
          ? _value.maturityDate
          : maturityDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      nextPaymentDate: freezed == nextPaymentDate
          ? _value.nextPaymentDate
          : nextPaymentDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      policyDocumentUrl: freezed == policyDocumentUrl
          ? _value.policyDocumentUrl
          : policyDocumentUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      applicationFormUrl: freezed == applicationFormUrl
          ? _value.applicationFormUrl
          : applicationFormUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      outstandingAmount: freezed == outstandingAmount
          ? _value.outstandingAmount
          : outstandingAmount // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PolicyImpl implements _Policy {
  const _$PolicyImpl(
      {@JsonKey(name: 'policy_id') required this.policyId,
      @JsonKey(name: 'policy_number') required this.policyNumber,
      @JsonKey(name: 'plan_name') required this.planName,
      @JsonKey(name: 'sum_assured') required this.sumAssured,
      @JsonKey(name: 'premium_amount') required this.premiumAmount,
      @JsonKey(name: 'premium_frequency') required this.premiumFrequency,
      @JsonKey(name: 'start_date') required this.startDate,
      @JsonKey(name: 'maturity_date') this.maturityDate,
      @JsonKey(name: 'next_payment_date') this.nextPaymentDate,
      @JsonKey(name: 'status') required this.status,
      @JsonKey(name: 'policy_document_url') this.policyDocumentUrl,
      @JsonKey(name: 'application_form_url') this.applicationFormUrl,
      @JsonKey(name: 'outstanding_amount') this.outstandingAmount});

  factory _$PolicyImpl.fromJson(Map<String, dynamic> json) =>
      _$$PolicyImplFromJson(json);

  @override
  @JsonKey(name: 'policy_id')
  final String policyId;
  @override
  @JsonKey(name: 'policy_number')
  final String policyNumber;
  @override
  @JsonKey(name: 'plan_name')
  final String planName;
  @override
  @JsonKey(name: 'sum_assured')
  final double sumAssured;
  @override
  @JsonKey(name: 'premium_amount')
  final double premiumAmount;
  @override
  @JsonKey(name: 'premium_frequency')
  final String premiumFrequency;
  @override
  @JsonKey(name: 'start_date')
  final DateTime startDate;
  @override
  @JsonKey(name: 'maturity_date')
  final DateTime? maturityDate;
  @override
  @JsonKey(name: 'next_payment_date')
  final DateTime? nextPaymentDate;
  @override
  @JsonKey(name: 'status')
  final String status;
  @override
  @JsonKey(name: 'policy_document_url')
  final String? policyDocumentUrl;
  @override
  @JsonKey(name: 'application_form_url')
  final String? applicationFormUrl;
  @override
  @JsonKey(name: 'outstanding_amount')
  final double? outstandingAmount;

  @override
  String toString() {
    return 'Policy(policyId: $policyId, policyNumber: $policyNumber, planName: $planName, sumAssured: $sumAssured, premiumAmount: $premiumAmount, premiumFrequency: $premiumFrequency, startDate: $startDate, maturityDate: $maturityDate, nextPaymentDate: $nextPaymentDate, status: $status, policyDocumentUrl: $policyDocumentUrl, applicationFormUrl: $applicationFormUrl, outstandingAmount: $outstandingAmount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PolicyImpl &&
            (identical(other.policyId, policyId) ||
                other.policyId == policyId) &&
            (identical(other.policyNumber, policyNumber) ||
                other.policyNumber == policyNumber) &&
            (identical(other.planName, planName) ||
                other.planName == planName) &&
            (identical(other.sumAssured, sumAssured) ||
                other.sumAssured == sumAssured) &&
            (identical(other.premiumAmount, premiumAmount) ||
                other.premiumAmount == premiumAmount) &&
            (identical(other.premiumFrequency, premiumFrequency) ||
                other.premiumFrequency == premiumFrequency) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.maturityDate, maturityDate) ||
                other.maturityDate == maturityDate) &&
            (identical(other.nextPaymentDate, nextPaymentDate) ||
                other.nextPaymentDate == nextPaymentDate) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.policyDocumentUrl, policyDocumentUrl) ||
                other.policyDocumentUrl == policyDocumentUrl) &&
            (identical(other.applicationFormUrl, applicationFormUrl) ||
                other.applicationFormUrl == applicationFormUrl) &&
            (identical(other.outstandingAmount, outstandingAmount) ||
                other.outstandingAmount == outstandingAmount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      policyId,
      policyNumber,
      planName,
      sumAssured,
      premiumAmount,
      premiumFrequency,
      startDate,
      maturityDate,
      nextPaymentDate,
      status,
      policyDocumentUrl,
      applicationFormUrl,
      outstandingAmount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PolicyImplCopyWith<_$PolicyImpl> get copyWith =>
      __$$PolicyImplCopyWithImpl<_$PolicyImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PolicyImplToJson(
      this,
    );
  }
}

abstract class _Policy implements Policy {
  const factory _Policy(
      {@JsonKey(name: 'policy_id') required final String policyId,
      @JsonKey(name: 'policy_number') required final String policyNumber,
      @JsonKey(name: 'plan_name') required final String planName,
      @JsonKey(name: 'sum_assured') required final double sumAssured,
      @JsonKey(name: 'premium_amount') required final double premiumAmount,
      @JsonKey(name: 'premium_frequency')
      required final String premiumFrequency,
      @JsonKey(name: 'start_date') required final DateTime startDate,
      @JsonKey(name: 'maturity_date') final DateTime? maturityDate,
      @JsonKey(name: 'next_payment_date') final DateTime? nextPaymentDate,
      @JsonKey(name: 'status') required final String status,
      @JsonKey(name: 'policy_document_url') final String? policyDocumentUrl,
      @JsonKey(name: 'application_form_url') final String? applicationFormUrl,
      @JsonKey(name: 'outstanding_amount')
      final double? outstandingAmount}) = _$PolicyImpl;

  factory _Policy.fromJson(Map<String, dynamic> json) = _$PolicyImpl.fromJson;

  @override
  @JsonKey(name: 'policy_id')
  String get policyId;
  @override
  @JsonKey(name: 'policy_number')
  String get policyNumber;
  @override
  @JsonKey(name: 'plan_name')
  String get planName;
  @override
  @JsonKey(name: 'sum_assured')
  double get sumAssured;
  @override
  @JsonKey(name: 'premium_amount')
  double get premiumAmount;
  @override
  @JsonKey(name: 'premium_frequency')
  String get premiumFrequency;
  @override
  @JsonKey(name: 'start_date')
  DateTime get startDate;
  @override
  @JsonKey(name: 'maturity_date')
  DateTime? get maturityDate;
  @override
  @JsonKey(name: 'next_payment_date')
  DateTime? get nextPaymentDate;
  @override
  @JsonKey(name: 'status')
  String get status;
  @override
  @JsonKey(name: 'policy_document_url')
  String? get policyDocumentUrl;
  @override
  @JsonKey(name: 'application_form_url')
  String? get applicationFormUrl;
  @override
  @JsonKey(name: 'outstanding_amount')
  double? get outstandingAmount;
  @override
  @JsonKey(ignore: true)
  _$$PolicyImplCopyWith<_$PolicyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Premium _$PremiumFromJson(Map<String, dynamic> json) {
  return _Premium.fromJson(json);
}

/// @nodoc
mixin _$Premium {
  String get paymentId => throw _privateConstructorUsedError;
  String get policyId => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  DateTime get paymentDate => throw _privateConstructorUsedError;
  DateTime get dueDate => throw _privateConstructorUsedError;
  String? get paymentMethod => throw _privateConstructorUsedError;
  String? get transactionId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get receiptUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PremiumCopyWith<Premium> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PremiumCopyWith<$Res> {
  factory $PremiumCopyWith(Premium value, $Res Function(Premium) then) =
      _$PremiumCopyWithImpl<$Res, Premium>;
  @useResult
  $Res call(
      {String paymentId,
      String policyId,
      double amount,
      DateTime paymentDate,
      DateTime dueDate,
      String? paymentMethod,
      String? transactionId,
      String status,
      String? receiptUrl});
}

/// @nodoc
class _$PremiumCopyWithImpl<$Res, $Val extends Premium>
    implements $PremiumCopyWith<$Res> {
  _$PremiumCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? paymentId = null,
    Object? policyId = null,
    Object? amount = null,
    Object? paymentDate = null,
    Object? dueDate = null,
    Object? paymentMethod = freezed,
    Object? transactionId = freezed,
    Object? status = null,
    Object? receiptUrl = freezed,
  }) {
    return _then(_value.copyWith(
      paymentId: null == paymentId
          ? _value.paymentId
          : paymentId // ignore: cast_nullable_to_non_nullable
              as String,
      policyId: null == policyId
          ? _value.policyId
          : policyId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      paymentDate: null == paymentDate
          ? _value.paymentDate
          : paymentDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      dueDate: null == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      paymentMethod: freezed == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as String?,
      transactionId: freezed == transactionId
          ? _value.transactionId
          : transactionId // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      receiptUrl: freezed == receiptUrl
          ? _value.receiptUrl
          : receiptUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PremiumImplCopyWith<$Res> implements $PremiumCopyWith<$Res> {
  factory _$$PremiumImplCopyWith(
          _$PremiumImpl value, $Res Function(_$PremiumImpl) then) =
      __$$PremiumImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String paymentId,
      String policyId,
      double amount,
      DateTime paymentDate,
      DateTime dueDate,
      String? paymentMethod,
      String? transactionId,
      String status,
      String? receiptUrl});
}

/// @nodoc
class __$$PremiumImplCopyWithImpl<$Res>
    extends _$PremiumCopyWithImpl<$Res, _$PremiumImpl>
    implements _$$PremiumImplCopyWith<$Res> {
  __$$PremiumImplCopyWithImpl(
      _$PremiumImpl _value, $Res Function(_$PremiumImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? paymentId = null,
    Object? policyId = null,
    Object? amount = null,
    Object? paymentDate = null,
    Object? dueDate = null,
    Object? paymentMethod = freezed,
    Object? transactionId = freezed,
    Object? status = null,
    Object? receiptUrl = freezed,
  }) {
    return _then(_$PremiumImpl(
      paymentId: null == paymentId
          ? _value.paymentId
          : paymentId // ignore: cast_nullable_to_non_nullable
              as String,
      policyId: null == policyId
          ? _value.policyId
          : policyId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      paymentDate: null == paymentDate
          ? _value.paymentDate
          : paymentDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      dueDate: null == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      paymentMethod: freezed == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as String?,
      transactionId: freezed == transactionId
          ? _value.transactionId
          : transactionId // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      receiptUrl: freezed == receiptUrl
          ? _value.receiptUrl
          : receiptUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PremiumImpl implements _Premium {
  const _$PremiumImpl(
      {required this.paymentId,
      required this.policyId,
      required this.amount,
      required this.paymentDate,
      required this.dueDate,
      this.paymentMethod,
      this.transactionId,
      required this.status,
      this.receiptUrl});

  factory _$PremiumImpl.fromJson(Map<String, dynamic> json) =>
      _$$PremiumImplFromJson(json);

  @override
  final String paymentId;
  @override
  final String policyId;
  @override
  final double amount;
  @override
  final DateTime paymentDate;
  @override
  final DateTime dueDate;
  @override
  final String? paymentMethod;
  @override
  final String? transactionId;
  @override
  final String status;
  @override
  final String? receiptUrl;

  @override
  String toString() {
    return 'Premium(paymentId: $paymentId, policyId: $policyId, amount: $amount, paymentDate: $paymentDate, dueDate: $dueDate, paymentMethod: $paymentMethod, transactionId: $transactionId, status: $status, receiptUrl: $receiptUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PremiumImpl &&
            (identical(other.paymentId, paymentId) ||
                other.paymentId == paymentId) &&
            (identical(other.policyId, policyId) ||
                other.policyId == policyId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.paymentDate, paymentDate) ||
                other.paymentDate == paymentDate) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.transactionId, transactionId) ||
                other.transactionId == transactionId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.receiptUrl, receiptUrl) ||
                other.receiptUrl == receiptUrl));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, paymentId, policyId, amount,
      paymentDate, dueDate, paymentMethod, transactionId, status, receiptUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PremiumImplCopyWith<_$PremiumImpl> get copyWith =>
      __$$PremiumImplCopyWithImpl<_$PremiumImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PremiumImplToJson(
      this,
    );
  }
}

abstract class _Premium implements Premium {
  const factory _Premium(
      {required final String paymentId,
      required final String policyId,
      required final double amount,
      required final DateTime paymentDate,
      required final DateTime dueDate,
      final String? paymentMethod,
      final String? transactionId,
      required final String status,
      final String? receiptUrl}) = _$PremiumImpl;

  factory _Premium.fromJson(Map<String, dynamic> json) = _$PremiumImpl.fromJson;

  @override
  String get paymentId;
  @override
  String get policyId;
  @override
  double get amount;
  @override
  DateTime get paymentDate;
  @override
  DateTime get dueDate;
  @override
  String? get paymentMethod;
  @override
  String? get transactionId;
  @override
  String get status;
  @override
  String? get receiptUrl;
  @override
  @JsonKey(ignore: true)
  _$$PremiumImplCopyWith<_$PremiumImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Claim _$ClaimFromJson(Map<String, dynamic> json) {
  return _Claim.fromJson(json);
}

/// @nodoc
mixin _$Claim {
  String get claimId => throw _privateConstructorUsedError;
  String get policyId => throw _privateConstructorUsedError;
  String get claimType => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  DateTime get incidentDate => throw _privateConstructorUsedError;
  DateTime get claimDate => throw _privateConstructorUsedError;
  double get claimedAmount => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  double? get approvedAmount => throw _privateConstructorUsedError;
  String? get rejectionReason => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ClaimCopyWith<Claim> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClaimCopyWith<$Res> {
  factory $ClaimCopyWith(Claim value, $Res Function(Claim) then) =
      _$ClaimCopyWithImpl<$Res, Claim>;
  @useResult
  $Res call(
      {String claimId,
      String policyId,
      String claimType,
      String description,
      DateTime incidentDate,
      DateTime claimDate,
      double claimedAmount,
      String? status,
      double? approvedAmount,
      String? rejectionReason});
}

/// @nodoc
class _$ClaimCopyWithImpl<$Res, $Val extends Claim>
    implements $ClaimCopyWith<$Res> {
  _$ClaimCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? claimId = null,
    Object? policyId = null,
    Object? claimType = null,
    Object? description = null,
    Object? incidentDate = null,
    Object? claimDate = null,
    Object? claimedAmount = null,
    Object? status = freezed,
    Object? approvedAmount = freezed,
    Object? rejectionReason = freezed,
  }) {
    return _then(_value.copyWith(
      claimId: null == claimId
          ? _value.claimId
          : claimId // ignore: cast_nullable_to_non_nullable
              as String,
      policyId: null == policyId
          ? _value.policyId
          : policyId // ignore: cast_nullable_to_non_nullable
              as String,
      claimType: null == claimType
          ? _value.claimType
          : claimType // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      incidentDate: null == incidentDate
          ? _value.incidentDate
          : incidentDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      claimDate: null == claimDate
          ? _value.claimDate
          : claimDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      claimedAmount: null == claimedAmount
          ? _value.claimedAmount
          : claimedAmount // ignore: cast_nullable_to_non_nullable
              as double,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      approvedAmount: freezed == approvedAmount
          ? _value.approvedAmount
          : approvedAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      rejectionReason: freezed == rejectionReason
          ? _value.rejectionReason
          : rejectionReason // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ClaimImplCopyWith<$Res> implements $ClaimCopyWith<$Res> {
  factory _$$ClaimImplCopyWith(
          _$ClaimImpl value, $Res Function(_$ClaimImpl) then) =
      __$$ClaimImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String claimId,
      String policyId,
      String claimType,
      String description,
      DateTime incidentDate,
      DateTime claimDate,
      double claimedAmount,
      String? status,
      double? approvedAmount,
      String? rejectionReason});
}

/// @nodoc
class __$$ClaimImplCopyWithImpl<$Res>
    extends _$ClaimCopyWithImpl<$Res, _$ClaimImpl>
    implements _$$ClaimImplCopyWith<$Res> {
  __$$ClaimImplCopyWithImpl(
      _$ClaimImpl _value, $Res Function(_$ClaimImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? claimId = null,
    Object? policyId = null,
    Object? claimType = null,
    Object? description = null,
    Object? incidentDate = null,
    Object? claimDate = null,
    Object? claimedAmount = null,
    Object? status = freezed,
    Object? approvedAmount = freezed,
    Object? rejectionReason = freezed,
  }) {
    return _then(_$ClaimImpl(
      claimId: null == claimId
          ? _value.claimId
          : claimId // ignore: cast_nullable_to_non_nullable
              as String,
      policyId: null == policyId
          ? _value.policyId
          : policyId // ignore: cast_nullable_to_non_nullable
              as String,
      claimType: null == claimType
          ? _value.claimType
          : claimType // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      incidentDate: null == incidentDate
          ? _value.incidentDate
          : incidentDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      claimDate: null == claimDate
          ? _value.claimDate
          : claimDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      claimedAmount: null == claimedAmount
          ? _value.claimedAmount
          : claimedAmount // ignore: cast_nullable_to_non_nullable
              as double,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      approvedAmount: freezed == approvedAmount
          ? _value.approvedAmount
          : approvedAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      rejectionReason: freezed == rejectionReason
          ? _value.rejectionReason
          : rejectionReason // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ClaimImpl implements _Claim {
  const _$ClaimImpl(
      {required this.claimId,
      required this.policyId,
      required this.claimType,
      required this.description,
      required this.incidentDate,
      required this.claimDate,
      required this.claimedAmount,
      this.status,
      this.approvedAmount,
      this.rejectionReason});

  factory _$ClaimImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClaimImplFromJson(json);

  @override
  final String claimId;
  @override
  final String policyId;
  @override
  final String claimType;
  @override
  final String description;
  @override
  final DateTime incidentDate;
  @override
  final DateTime claimDate;
  @override
  final double claimedAmount;
  @override
  final String? status;
  @override
  final double? approvedAmount;
  @override
  final String? rejectionReason;

  @override
  String toString() {
    return 'Claim(claimId: $claimId, policyId: $policyId, claimType: $claimType, description: $description, incidentDate: $incidentDate, claimDate: $claimDate, claimedAmount: $claimedAmount, status: $status, approvedAmount: $approvedAmount, rejectionReason: $rejectionReason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClaimImpl &&
            (identical(other.claimId, claimId) || other.claimId == claimId) &&
            (identical(other.policyId, policyId) ||
                other.policyId == policyId) &&
            (identical(other.claimType, claimType) ||
                other.claimType == claimType) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.incidentDate, incidentDate) ||
                other.incidentDate == incidentDate) &&
            (identical(other.claimDate, claimDate) ||
                other.claimDate == claimDate) &&
            (identical(other.claimedAmount, claimedAmount) ||
                other.claimedAmount == claimedAmount) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.approvedAmount, approvedAmount) ||
                other.approvedAmount == approvedAmount) &&
            (identical(other.rejectionReason, rejectionReason) ||
                other.rejectionReason == rejectionReason));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      claimId,
      policyId,
      claimType,
      description,
      incidentDate,
      claimDate,
      claimedAmount,
      status,
      approvedAmount,
      rejectionReason);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ClaimImplCopyWith<_$ClaimImpl> get copyWith =>
      __$$ClaimImplCopyWithImpl<_$ClaimImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClaimImplToJson(
      this,
    );
  }
}

abstract class _Claim implements Claim {
  const factory _Claim(
      {required final String claimId,
      required final String policyId,
      required final String claimType,
      required final String description,
      required final DateTime incidentDate,
      required final DateTime claimDate,
      required final double claimedAmount,
      final String? status,
      final double? approvedAmount,
      final String? rejectionReason}) = _$ClaimImpl;

  factory _Claim.fromJson(Map<String, dynamic> json) = _$ClaimImpl.fromJson;

  @override
  String get claimId;
  @override
  String get policyId;
  @override
  String get claimType;
  @override
  String get description;
  @override
  DateTime get incidentDate;
  @override
  DateTime get claimDate;
  @override
  double get claimedAmount;
  @override
  String? get status;
  @override
  double? get approvedAmount;
  @override
  String? get rejectionReason;
  @override
  @JsonKey(ignore: true)
  _$$ClaimImplCopyWith<_$ClaimImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Coverage _$CoverageFromJson(Map<String, dynamic> json) {
  return _Coverage.fromJson(json);
}

/// @nodoc
mixin _$Coverage {
  String get coverageId => throw _privateConstructorUsedError;
  String get policyId => throw _privateConstructorUsedError;
  String get coverageType => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  double get sumAssured => throw _privateConstructorUsedError;
  double get premium => throw _privateConstructorUsedError;
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime? get endDate => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CoverageCopyWith<Coverage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CoverageCopyWith<$Res> {
  factory $CoverageCopyWith(Coverage value, $Res Function(Coverage) then) =
      _$CoverageCopyWithImpl<$Res, Coverage>;
  @useResult
  $Res call(
      {String coverageId,
      String policyId,
      String coverageType,
      String description,
      double sumAssured,
      double premium,
      DateTime startDate,
      DateTime? endDate,
      String? status});
}

/// @nodoc
class _$CoverageCopyWithImpl<$Res, $Val extends Coverage>
    implements $CoverageCopyWith<$Res> {
  _$CoverageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? coverageId = null,
    Object? policyId = null,
    Object? coverageType = null,
    Object? description = null,
    Object? sumAssured = null,
    Object? premium = null,
    Object? startDate = null,
    Object? endDate = freezed,
    Object? status = freezed,
  }) {
    return _then(_value.copyWith(
      coverageId: null == coverageId
          ? _value.coverageId
          : coverageId // ignore: cast_nullable_to_non_nullable
              as String,
      policyId: null == policyId
          ? _value.policyId
          : policyId // ignore: cast_nullable_to_non_nullable
              as String,
      coverageType: null == coverageType
          ? _value.coverageType
          : coverageType // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      sumAssured: null == sumAssured
          ? _value.sumAssured
          : sumAssured // ignore: cast_nullable_to_non_nullable
              as double,
      premium: null == premium
          ? _value.premium
          : premium // ignore: cast_nullable_to_non_nullable
              as double,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CoverageImplCopyWith<$Res>
    implements $CoverageCopyWith<$Res> {
  factory _$$CoverageImplCopyWith(
          _$CoverageImpl value, $Res Function(_$CoverageImpl) then) =
      __$$CoverageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String coverageId,
      String policyId,
      String coverageType,
      String description,
      double sumAssured,
      double premium,
      DateTime startDate,
      DateTime? endDate,
      String? status});
}

/// @nodoc
class __$$CoverageImplCopyWithImpl<$Res>
    extends _$CoverageCopyWithImpl<$Res, _$CoverageImpl>
    implements _$$CoverageImplCopyWith<$Res> {
  __$$CoverageImplCopyWithImpl(
      _$CoverageImpl _value, $Res Function(_$CoverageImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? coverageId = null,
    Object? policyId = null,
    Object? coverageType = null,
    Object? description = null,
    Object? sumAssured = null,
    Object? premium = null,
    Object? startDate = null,
    Object? endDate = freezed,
    Object? status = freezed,
  }) {
    return _then(_$CoverageImpl(
      coverageId: null == coverageId
          ? _value.coverageId
          : coverageId // ignore: cast_nullable_to_non_nullable
              as String,
      policyId: null == policyId
          ? _value.policyId
          : policyId // ignore: cast_nullable_to_non_nullable
              as String,
      coverageType: null == coverageType
          ? _value.coverageType
          : coverageType // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      sumAssured: null == sumAssured
          ? _value.sumAssured
          : sumAssured // ignore: cast_nullable_to_non_nullable
              as double,
      premium: null == premium
          ? _value.premium
          : premium // ignore: cast_nullable_to_non_nullable
              as double,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CoverageImpl implements _Coverage {
  const _$CoverageImpl(
      {required this.coverageId,
      required this.policyId,
      required this.coverageType,
      required this.description,
      required this.sumAssured,
      required this.premium,
      required this.startDate,
      this.endDate,
      this.status});

  factory _$CoverageImpl.fromJson(Map<String, dynamic> json) =>
      _$$CoverageImplFromJson(json);

  @override
  final String coverageId;
  @override
  final String policyId;
  @override
  final String coverageType;
  @override
  final String description;
  @override
  final double sumAssured;
  @override
  final double premium;
  @override
  final DateTime startDate;
  @override
  final DateTime? endDate;
  @override
  final String? status;

  @override
  String toString() {
    return 'Coverage(coverageId: $coverageId, policyId: $policyId, coverageType: $coverageType, description: $description, sumAssured: $sumAssured, premium: $premium, startDate: $startDate, endDate: $endDate, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CoverageImpl &&
            (identical(other.coverageId, coverageId) ||
                other.coverageId == coverageId) &&
            (identical(other.policyId, policyId) ||
                other.policyId == policyId) &&
            (identical(other.coverageType, coverageType) ||
                other.coverageType == coverageType) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.sumAssured, sumAssured) ||
                other.sumAssured == sumAssured) &&
            (identical(other.premium, premium) || other.premium == premium) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      coverageId,
      policyId,
      coverageType,
      description,
      sumAssured,
      premium,
      startDate,
      endDate,
      status);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CoverageImplCopyWith<_$CoverageImpl> get copyWith =>
      __$$CoverageImplCopyWithImpl<_$CoverageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CoverageImplToJson(
      this,
    );
  }
}

abstract class _Coverage implements Coverage {
  const factory _Coverage(
      {required final String coverageId,
      required final String policyId,
      required final String coverageType,
      required final String description,
      required final double sumAssured,
      required final double premium,
      required final DateTime startDate,
      final DateTime? endDate,
      final String? status}) = _$CoverageImpl;

  factory _Coverage.fromJson(Map<String, dynamic> json) =
      _$CoverageImpl.fromJson;

  @override
  String get coverageId;
  @override
  String get policyId;
  @override
  String get coverageType;
  @override
  String get description;
  @override
  double get sumAssured;
  @override
  double get premium;
  @override
  DateTime get startDate;
  @override
  DateTime? get endDate;
  @override
  String? get status;
  @override
  @JsonKey(ignore: true)
  _$$CoverageImplCopyWith<_$CoverageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PolicyFilters _$PolicyFiltersFromJson(Map<String, dynamic> json) {
  return _PolicyFilters.fromJson(json);
}

/// @nodoc
mixin _$PolicyFilters {
  PolicyStatus? get status => throw _privateConstructorUsedError;
  PolicyType? get policyType => throw _privateConstructorUsedError;
  String? get providerId => throw _privateConstructorUsedError;
  String? get searchQuery => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get limit => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PolicyFiltersCopyWith<PolicyFilters> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PolicyFiltersCopyWith<$Res> {
  factory $PolicyFiltersCopyWith(
          PolicyFilters value, $Res Function(PolicyFilters) then) =
      _$PolicyFiltersCopyWithImpl<$Res, PolicyFilters>;
  @useResult
  $Res call(
      {PolicyStatus? status,
      PolicyType? policyType,
      String? providerId,
      String? searchQuery,
      int page,
      int limit});
}

/// @nodoc
class _$PolicyFiltersCopyWithImpl<$Res, $Val extends PolicyFilters>
    implements $PolicyFiltersCopyWith<$Res> {
  _$PolicyFiltersCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = freezed,
    Object? policyType = freezed,
    Object? providerId = freezed,
    Object? searchQuery = freezed,
    Object? page = null,
    Object? limit = null,
  }) {
    return _then(_value.copyWith(
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as PolicyStatus?,
      policyType: freezed == policyType
          ? _value.policyType
          : policyType // ignore: cast_nullable_to_non_nullable
              as PolicyType?,
      providerId: freezed == providerId
          ? _value.providerId
          : providerId // ignore: cast_nullable_to_non_nullable
              as String?,
      searchQuery: freezed == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String?,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      limit: null == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PolicyFiltersImplCopyWith<$Res>
    implements $PolicyFiltersCopyWith<$Res> {
  factory _$$PolicyFiltersImplCopyWith(
          _$PolicyFiltersImpl value, $Res Function(_$PolicyFiltersImpl) then) =
      __$$PolicyFiltersImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {PolicyStatus? status,
      PolicyType? policyType,
      String? providerId,
      String? searchQuery,
      int page,
      int limit});
}

/// @nodoc
class __$$PolicyFiltersImplCopyWithImpl<$Res>
    extends _$PolicyFiltersCopyWithImpl<$Res, _$PolicyFiltersImpl>
    implements _$$PolicyFiltersImplCopyWith<$Res> {
  __$$PolicyFiltersImplCopyWithImpl(
      _$PolicyFiltersImpl _value, $Res Function(_$PolicyFiltersImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = freezed,
    Object? policyType = freezed,
    Object? providerId = freezed,
    Object? searchQuery = freezed,
    Object? page = null,
    Object? limit = null,
  }) {
    return _then(_$PolicyFiltersImpl(
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as PolicyStatus?,
      policyType: freezed == policyType
          ? _value.policyType
          : policyType // ignore: cast_nullable_to_non_nullable
              as PolicyType?,
      providerId: freezed == providerId
          ? _value.providerId
          : providerId // ignore: cast_nullable_to_non_nullable
              as String?,
      searchQuery: freezed == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String?,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      limit: null == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PolicyFiltersImpl implements _PolicyFilters {
  const _$PolicyFiltersImpl(
      {this.status,
      this.policyType,
      this.providerId,
      this.searchQuery,
      this.page = 1,
      this.limit = 20});

  factory _$PolicyFiltersImpl.fromJson(Map<String, dynamic> json) =>
      _$$PolicyFiltersImplFromJson(json);

  @override
  final PolicyStatus? status;
  @override
  final PolicyType? policyType;
  @override
  final String? providerId;
  @override
  final String? searchQuery;
  @override
  @JsonKey()
  final int page;
  @override
  @JsonKey()
  final int limit;

  @override
  String toString() {
    return 'PolicyFilters(status: $status, policyType: $policyType, providerId: $providerId, searchQuery: $searchQuery, page: $page, limit: $limit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PolicyFiltersImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.policyType, policyType) ||
                other.policyType == policyType) &&
            (identical(other.providerId, providerId) ||
                other.providerId == providerId) &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.limit, limit) || other.limit == limit));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, status, policyType, providerId, searchQuery, page, limit);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PolicyFiltersImplCopyWith<_$PolicyFiltersImpl> get copyWith =>
      __$$PolicyFiltersImplCopyWithImpl<_$PolicyFiltersImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PolicyFiltersImplToJson(
      this,
    );
  }
}

abstract class _PolicyFilters implements PolicyFilters {
  const factory _PolicyFilters(
      {final PolicyStatus? status,
      final PolicyType? policyType,
      final String? providerId,
      final String? searchQuery,
      final int page,
      final int limit}) = _$PolicyFiltersImpl;

  factory _PolicyFilters.fromJson(Map<String, dynamic> json) =
      _$PolicyFiltersImpl.fromJson;

  @override
  PolicyStatus? get status;
  @override
  PolicyType? get policyType;
  @override
  String? get providerId;
  @override
  String? get searchQuery;
  @override
  int get page;
  @override
  int get limit;
  @override
  @JsonKey(ignore: true)
  _$$PolicyFiltersImplCopyWith<_$PolicyFiltersImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PolicyListResponse _$PolicyListResponseFromJson(Map<String, dynamic> json) {
  return _PolicyListResponse.fromJson(json);
}

/// @nodoc
mixin _$PolicyListResponse {
  List<Policy> get policies => throw _privateConstructorUsedError;
  int get totalCount => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get limit => throw _privateConstructorUsedError;
  bool get hasNextPage => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PolicyListResponseCopyWith<PolicyListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PolicyListResponseCopyWith<$Res> {
  factory $PolicyListResponseCopyWith(
          PolicyListResponse value, $Res Function(PolicyListResponse) then) =
      _$PolicyListResponseCopyWithImpl<$Res, PolicyListResponse>;
  @useResult
  $Res call(
      {List<Policy> policies,
      int totalCount,
      int page,
      int limit,
      bool hasNextPage});
}

/// @nodoc
class _$PolicyListResponseCopyWithImpl<$Res, $Val extends PolicyListResponse>
    implements $PolicyListResponseCopyWith<$Res> {
  _$PolicyListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? policies = null,
    Object? totalCount = null,
    Object? page = null,
    Object? limit = null,
    Object? hasNextPage = null,
  }) {
    return _then(_value.copyWith(
      policies: null == policies
          ? _value.policies
          : policies // ignore: cast_nullable_to_non_nullable
              as List<Policy>,
      totalCount: null == totalCount
          ? _value.totalCount
          : totalCount // ignore: cast_nullable_to_non_nullable
              as int,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      limit: null == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
      hasNextPage: null == hasNextPage
          ? _value.hasNextPage
          : hasNextPage // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PolicyListResponseImplCopyWith<$Res>
    implements $PolicyListResponseCopyWith<$Res> {
  factory _$$PolicyListResponseImplCopyWith(_$PolicyListResponseImpl value,
          $Res Function(_$PolicyListResponseImpl) then) =
      __$$PolicyListResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<Policy> policies,
      int totalCount,
      int page,
      int limit,
      bool hasNextPage});
}

/// @nodoc
class __$$PolicyListResponseImplCopyWithImpl<$Res>
    extends _$PolicyListResponseCopyWithImpl<$Res, _$PolicyListResponseImpl>
    implements _$$PolicyListResponseImplCopyWith<$Res> {
  __$$PolicyListResponseImplCopyWithImpl(_$PolicyListResponseImpl _value,
      $Res Function(_$PolicyListResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? policies = null,
    Object? totalCount = null,
    Object? page = null,
    Object? limit = null,
    Object? hasNextPage = null,
  }) {
    return _then(_$PolicyListResponseImpl(
      policies: null == policies
          ? _value._policies
          : policies // ignore: cast_nullable_to_non_nullable
              as List<Policy>,
      totalCount: null == totalCount
          ? _value.totalCount
          : totalCount // ignore: cast_nullable_to_non_nullable
              as int,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      limit: null == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
      hasNextPage: null == hasNextPage
          ? _value.hasNextPage
          : hasNextPage // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PolicyListResponseImpl implements _PolicyListResponse {
  const _$PolicyListResponseImpl(
      {required final List<Policy> policies,
      required this.totalCount,
      required this.page,
      required this.limit,
      required this.hasNextPage})
      : _policies = policies;

  factory _$PolicyListResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$PolicyListResponseImplFromJson(json);

  final List<Policy> _policies;
  @override
  List<Policy> get policies {
    if (_policies is EqualUnmodifiableListView) return _policies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_policies);
  }

  @override
  final int totalCount;
  @override
  final int page;
  @override
  final int limit;
  @override
  final bool hasNextPage;

  @override
  String toString() {
    return 'PolicyListResponse(policies: $policies, totalCount: $totalCount, page: $page, limit: $limit, hasNextPage: $hasNextPage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PolicyListResponseImpl &&
            const DeepCollectionEquality().equals(other._policies, _policies) &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.limit, limit) || other.limit == limit) &&
            (identical(other.hasNextPage, hasNextPage) ||
                other.hasNextPage == hasNextPage));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_policies),
      totalCount,
      page,
      limit,
      hasNextPage);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PolicyListResponseImplCopyWith<_$PolicyListResponseImpl> get copyWith =>
      __$$PolicyListResponseImplCopyWithImpl<_$PolicyListResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PolicyListResponseImplToJson(
      this,
    );
  }
}

abstract class _PolicyListResponse implements PolicyListResponse {
  const factory _PolicyListResponse(
      {required final List<Policy> policies,
      required final int totalCount,
      required final int page,
      required final int limit,
      required final bool hasNextPage}) = _$PolicyListResponseImpl;

  factory _PolicyListResponse.fromJson(Map<String, dynamic> json) =
      _$PolicyListResponseImpl.fromJson;

  @override
  List<Policy> get policies;
  @override
  int get totalCount;
  @override
  int get page;
  @override
  int get limit;
  @override
  bool get hasNextPage;
  @override
  @JsonKey(ignore: true)
  _$$PolicyListResponseImplCopyWith<_$PolicyListResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PolicyDetail _$PolicyDetailFromJson(Map<String, dynamic> json) {
  return _PolicyDetail.fromJson(json);
}

/// @nodoc
mixin _$PolicyDetail {
  Policy get policy => throw _privateConstructorUsedError;
  List<Premium>? get premiums => throw _privateConstructorUsedError;
  List<Claim>? get claims => throw _privateConstructorUsedError;
  List<Coverage>? get coverages => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PolicyDetailCopyWith<PolicyDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PolicyDetailCopyWith<$Res> {
  factory $PolicyDetailCopyWith(
          PolicyDetail value, $Res Function(PolicyDetail) then) =
      _$PolicyDetailCopyWithImpl<$Res, PolicyDetail>;
  @useResult
  $Res call(
      {Policy policy,
      List<Premium>? premiums,
      List<Claim>? claims,
      List<Coverage>? coverages});

  $PolicyCopyWith<$Res> get policy;
}

/// @nodoc
class _$PolicyDetailCopyWithImpl<$Res, $Val extends PolicyDetail>
    implements $PolicyDetailCopyWith<$Res> {
  _$PolicyDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? policy = null,
    Object? premiums = freezed,
    Object? claims = freezed,
    Object? coverages = freezed,
  }) {
    return _then(_value.copyWith(
      policy: null == policy
          ? _value.policy
          : policy // ignore: cast_nullable_to_non_nullable
              as Policy,
      premiums: freezed == premiums
          ? _value.premiums
          : premiums // ignore: cast_nullable_to_non_nullable
              as List<Premium>?,
      claims: freezed == claims
          ? _value.claims
          : claims // ignore: cast_nullable_to_non_nullable
              as List<Claim>?,
      coverages: freezed == coverages
          ? _value.coverages
          : coverages // ignore: cast_nullable_to_non_nullable
              as List<Coverage>?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $PolicyCopyWith<$Res> get policy {
    return $PolicyCopyWith<$Res>(_value.policy, (value) {
      return _then(_value.copyWith(policy: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PolicyDetailImplCopyWith<$Res>
    implements $PolicyDetailCopyWith<$Res> {
  factory _$$PolicyDetailImplCopyWith(
          _$PolicyDetailImpl value, $Res Function(_$PolicyDetailImpl) then) =
      __$$PolicyDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Policy policy,
      List<Premium>? premiums,
      List<Claim>? claims,
      List<Coverage>? coverages});

  @override
  $PolicyCopyWith<$Res> get policy;
}

/// @nodoc
class __$$PolicyDetailImplCopyWithImpl<$Res>
    extends _$PolicyDetailCopyWithImpl<$Res, _$PolicyDetailImpl>
    implements _$$PolicyDetailImplCopyWith<$Res> {
  __$$PolicyDetailImplCopyWithImpl(
      _$PolicyDetailImpl _value, $Res Function(_$PolicyDetailImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? policy = null,
    Object? premiums = freezed,
    Object? claims = freezed,
    Object? coverages = freezed,
  }) {
    return _then(_$PolicyDetailImpl(
      policy: null == policy
          ? _value.policy
          : policy // ignore: cast_nullable_to_non_nullable
              as Policy,
      premiums: freezed == premiums
          ? _value._premiums
          : premiums // ignore: cast_nullable_to_non_nullable
              as List<Premium>?,
      claims: freezed == claims
          ? _value._claims
          : claims // ignore: cast_nullable_to_non_nullable
              as List<Claim>?,
      coverages: freezed == coverages
          ? _value._coverages
          : coverages // ignore: cast_nullable_to_non_nullable
              as List<Coverage>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PolicyDetailImpl implements _PolicyDetail {
  const _$PolicyDetailImpl(
      {required this.policy,
      final List<Premium>? premiums,
      final List<Claim>? claims,
      final List<Coverage>? coverages})
      : _premiums = premiums,
        _claims = claims,
        _coverages = coverages;

  factory _$PolicyDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$PolicyDetailImplFromJson(json);

  @override
  final Policy policy;
  final List<Premium>? _premiums;
  @override
  List<Premium>? get premiums {
    final value = _premiums;
    if (value == null) return null;
    if (_premiums is EqualUnmodifiableListView) return _premiums;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<Claim>? _claims;
  @override
  List<Claim>? get claims {
    final value = _claims;
    if (value == null) return null;
    if (_claims is EqualUnmodifiableListView) return _claims;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<Coverage>? _coverages;
  @override
  List<Coverage>? get coverages {
    final value = _coverages;
    if (value == null) return null;
    if (_coverages is EqualUnmodifiableListView) return _coverages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'PolicyDetail(policy: $policy, premiums: $premiums, claims: $claims, coverages: $coverages)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PolicyDetailImpl &&
            (identical(other.policy, policy) || other.policy == policy) &&
            const DeepCollectionEquality().equals(other._premiums, _premiums) &&
            const DeepCollectionEquality().equals(other._claims, _claims) &&
            const DeepCollectionEquality()
                .equals(other._coverages, _coverages));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      policy,
      const DeepCollectionEquality().hash(_premiums),
      const DeepCollectionEquality().hash(_claims),
      const DeepCollectionEquality().hash(_coverages));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PolicyDetailImplCopyWith<_$PolicyDetailImpl> get copyWith =>
      __$$PolicyDetailImplCopyWithImpl<_$PolicyDetailImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PolicyDetailImplToJson(
      this,
    );
  }
}

abstract class _PolicyDetail implements PolicyDetail {
  const factory _PolicyDetail(
      {required final Policy policy,
      final List<Premium>? premiums,
      final List<Claim>? claims,
      final List<Coverage>? coverages}) = _$PolicyDetailImpl;

  factory _PolicyDetail.fromJson(Map<String, dynamic> json) =
      _$PolicyDetailImpl.fromJson;

  @override
  Policy get policy;
  @override
  List<Premium>? get premiums;
  @override
  List<Claim>? get claims;
  @override
  List<Coverage>? get coverages;
  @override
  @JsonKey(ignore: true)
  _$$PolicyDetailImplCopyWith<_$PolicyDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
