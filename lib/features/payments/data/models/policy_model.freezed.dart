// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'policy_model.dart';

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
  String get policyId => throw _privateConstructorUsedError;
  String get policyNumber => throw _privateConstructorUsedError;
  String get providerPolicyId => throw _privateConstructorUsedError;
  String get policyholderId => throw _privateConstructorUsedError;
  String get agentId => throw _privateConstructorUsedError;
  String get providerId => throw _privateConstructorUsedError;
  String get policyType => throw _privateConstructorUsedError;
  String get planName => throw _privateConstructorUsedError;
  String get planCode => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  double get sumAssured => throw _privateConstructorUsedError;
  double get premiumAmount => throw _privateConstructorUsedError;
  String get premiumFrequency => throw _privateConstructorUsedError;
  String get premiumMode => throw _privateConstructorUsedError;
  DateTime get applicationDate => throw _privateConstructorUsedError;
  DateTime? get approvalDate => throw _privateConstructorUsedError;
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime? get maturityDate => throw _privateConstructorUsedError;
  DateTime? get renewalDate => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get subStatus => throw _privateConstructorUsedError;
  String? get paymentStatus => throw _privateConstructorUsedError;
  Map<String, dynamic>? get coverageDetails =>
      throw _privateConstructorUsedError;
  Map<String, dynamic>? get exclusions => throw _privateConstructorUsedError;
  Map<String, dynamic>? get termsAndConditions =>
      throw _privateConstructorUsedError;
  String? get policyDocumentUrl => throw _privateConstructorUsedError;
  String? get applicationFormUrl => throw _privateConstructorUsedError;
  Map<String, dynamic>? get medicalReports =>
      throw _privateConstructorUsedError;
  Map<String, dynamic>? get nomineeDetails =>
      throw _privateConstructorUsedError;
  Map<String, dynamic>? get assigneeDetails =>
      throw _privateConstructorUsedError;
  DateTime? get lastPaymentDate => throw _privateConstructorUsedError;
  DateTime? get nextPaymentDate => throw _privateConstructorUsedError;
  int? get totalPayments => throw _privateConstructorUsedError;
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
      {String policyId,
      String policyNumber,
      String providerPolicyId,
      String policyholderId,
      String agentId,
      String providerId,
      String policyType,
      String planName,
      String planCode,
      String category,
      double sumAssured,
      double premiumAmount,
      String premiumFrequency,
      String premiumMode,
      DateTime applicationDate,
      DateTime? approvalDate,
      DateTime startDate,
      DateTime? maturityDate,
      DateTime? renewalDate,
      String status,
      String? subStatus,
      String? paymentStatus,
      Map<String, dynamic>? coverageDetails,
      Map<String, dynamic>? exclusions,
      Map<String, dynamic>? termsAndConditions,
      String? policyDocumentUrl,
      String? applicationFormUrl,
      Map<String, dynamic>? medicalReports,
      Map<String, dynamic>? nomineeDetails,
      Map<String, dynamic>? assigneeDetails,
      DateTime? lastPaymentDate,
      DateTime? nextPaymentDate,
      int? totalPayments,
      double? outstandingAmount});
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
    Object? providerPolicyId = null,
    Object? policyholderId = null,
    Object? agentId = null,
    Object? providerId = null,
    Object? policyType = null,
    Object? planName = null,
    Object? planCode = null,
    Object? category = null,
    Object? sumAssured = null,
    Object? premiumAmount = null,
    Object? premiumFrequency = null,
    Object? premiumMode = null,
    Object? applicationDate = null,
    Object? approvalDate = freezed,
    Object? startDate = null,
    Object? maturityDate = freezed,
    Object? renewalDate = freezed,
    Object? status = null,
    Object? subStatus = freezed,
    Object? paymentStatus = freezed,
    Object? coverageDetails = freezed,
    Object? exclusions = freezed,
    Object? termsAndConditions = freezed,
    Object? policyDocumentUrl = freezed,
    Object? applicationFormUrl = freezed,
    Object? medicalReports = freezed,
    Object? nomineeDetails = freezed,
    Object? assigneeDetails = freezed,
    Object? lastPaymentDate = freezed,
    Object? nextPaymentDate = freezed,
    Object? totalPayments = freezed,
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
      providerPolicyId: null == providerPolicyId
          ? _value.providerPolicyId
          : providerPolicyId // ignore: cast_nullable_to_non_nullable
              as String,
      policyholderId: null == policyholderId
          ? _value.policyholderId
          : policyholderId // ignore: cast_nullable_to_non_nullable
              as String,
      agentId: null == agentId
          ? _value.agentId
          : agentId // ignore: cast_nullable_to_non_nullable
              as String,
      providerId: null == providerId
          ? _value.providerId
          : providerId // ignore: cast_nullable_to_non_nullable
              as String,
      policyType: null == policyType
          ? _value.policyType
          : policyType // ignore: cast_nullable_to_non_nullable
              as String,
      planName: null == planName
          ? _value.planName
          : planName // ignore: cast_nullable_to_non_nullable
              as String,
      planCode: null == planCode
          ? _value.planCode
          : planCode // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
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
      premiumMode: null == premiumMode
          ? _value.premiumMode
          : premiumMode // ignore: cast_nullable_to_non_nullable
              as String,
      applicationDate: null == applicationDate
          ? _value.applicationDate
          : applicationDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      approvalDate: freezed == approvalDate
          ? _value.approvalDate
          : approvalDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      maturityDate: freezed == maturityDate
          ? _value.maturityDate
          : maturityDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      renewalDate: freezed == renewalDate
          ? _value.renewalDate
          : renewalDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      subStatus: freezed == subStatus
          ? _value.subStatus
          : subStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentStatus: freezed == paymentStatus
          ? _value.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      coverageDetails: freezed == coverageDetails
          ? _value.coverageDetails
          : coverageDetails // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      exclusions: freezed == exclusions
          ? _value.exclusions
          : exclusions // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      termsAndConditions: freezed == termsAndConditions
          ? _value.termsAndConditions
          : termsAndConditions // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      policyDocumentUrl: freezed == policyDocumentUrl
          ? _value.policyDocumentUrl
          : policyDocumentUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      applicationFormUrl: freezed == applicationFormUrl
          ? _value.applicationFormUrl
          : applicationFormUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      medicalReports: freezed == medicalReports
          ? _value.medicalReports
          : medicalReports // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      nomineeDetails: freezed == nomineeDetails
          ? _value.nomineeDetails
          : nomineeDetails // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      assigneeDetails: freezed == assigneeDetails
          ? _value.assigneeDetails
          : assigneeDetails // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      lastPaymentDate: freezed == lastPaymentDate
          ? _value.lastPaymentDate
          : lastPaymentDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      nextPaymentDate: freezed == nextPaymentDate
          ? _value.nextPaymentDate
          : nextPaymentDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      totalPayments: freezed == totalPayments
          ? _value.totalPayments
          : totalPayments // ignore: cast_nullable_to_non_nullable
              as int?,
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
      {String policyId,
      String policyNumber,
      String providerPolicyId,
      String policyholderId,
      String agentId,
      String providerId,
      String policyType,
      String planName,
      String planCode,
      String category,
      double sumAssured,
      double premiumAmount,
      String premiumFrequency,
      String premiumMode,
      DateTime applicationDate,
      DateTime? approvalDate,
      DateTime startDate,
      DateTime? maturityDate,
      DateTime? renewalDate,
      String status,
      String? subStatus,
      String? paymentStatus,
      Map<String, dynamic>? coverageDetails,
      Map<String, dynamic>? exclusions,
      Map<String, dynamic>? termsAndConditions,
      String? policyDocumentUrl,
      String? applicationFormUrl,
      Map<String, dynamic>? medicalReports,
      Map<String, dynamic>? nomineeDetails,
      Map<String, dynamic>? assigneeDetails,
      DateTime? lastPaymentDate,
      DateTime? nextPaymentDate,
      int? totalPayments,
      double? outstandingAmount});
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
    Object? providerPolicyId = null,
    Object? policyholderId = null,
    Object? agentId = null,
    Object? providerId = null,
    Object? policyType = null,
    Object? planName = null,
    Object? planCode = null,
    Object? category = null,
    Object? sumAssured = null,
    Object? premiumAmount = null,
    Object? premiumFrequency = null,
    Object? premiumMode = null,
    Object? applicationDate = null,
    Object? approvalDate = freezed,
    Object? startDate = null,
    Object? maturityDate = freezed,
    Object? renewalDate = freezed,
    Object? status = null,
    Object? subStatus = freezed,
    Object? paymentStatus = freezed,
    Object? coverageDetails = freezed,
    Object? exclusions = freezed,
    Object? termsAndConditions = freezed,
    Object? policyDocumentUrl = freezed,
    Object? applicationFormUrl = freezed,
    Object? medicalReports = freezed,
    Object? nomineeDetails = freezed,
    Object? assigneeDetails = freezed,
    Object? lastPaymentDate = freezed,
    Object? nextPaymentDate = freezed,
    Object? totalPayments = freezed,
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
      providerPolicyId: null == providerPolicyId
          ? _value.providerPolicyId
          : providerPolicyId // ignore: cast_nullable_to_non_nullable
              as String,
      policyholderId: null == policyholderId
          ? _value.policyholderId
          : policyholderId // ignore: cast_nullable_to_non_nullable
              as String,
      agentId: null == agentId
          ? _value.agentId
          : agentId // ignore: cast_nullable_to_non_nullable
              as String,
      providerId: null == providerId
          ? _value.providerId
          : providerId // ignore: cast_nullable_to_non_nullable
              as String,
      policyType: null == policyType
          ? _value.policyType
          : policyType // ignore: cast_nullable_to_non_nullable
              as String,
      planName: null == planName
          ? _value.planName
          : planName // ignore: cast_nullable_to_non_nullable
              as String,
      planCode: null == planCode
          ? _value.planCode
          : planCode // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
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
      premiumMode: null == premiumMode
          ? _value.premiumMode
          : premiumMode // ignore: cast_nullable_to_non_nullable
              as String,
      applicationDate: null == applicationDate
          ? _value.applicationDate
          : applicationDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      approvalDate: freezed == approvalDate
          ? _value.approvalDate
          : approvalDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      maturityDate: freezed == maturityDate
          ? _value.maturityDate
          : maturityDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      renewalDate: freezed == renewalDate
          ? _value.renewalDate
          : renewalDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      subStatus: freezed == subStatus
          ? _value.subStatus
          : subStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentStatus: freezed == paymentStatus
          ? _value.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      coverageDetails: freezed == coverageDetails
          ? _value._coverageDetails
          : coverageDetails // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      exclusions: freezed == exclusions
          ? _value._exclusions
          : exclusions // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      termsAndConditions: freezed == termsAndConditions
          ? _value._termsAndConditions
          : termsAndConditions // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      policyDocumentUrl: freezed == policyDocumentUrl
          ? _value.policyDocumentUrl
          : policyDocumentUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      applicationFormUrl: freezed == applicationFormUrl
          ? _value.applicationFormUrl
          : applicationFormUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      medicalReports: freezed == medicalReports
          ? _value._medicalReports
          : medicalReports // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      nomineeDetails: freezed == nomineeDetails
          ? _value._nomineeDetails
          : nomineeDetails // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      assigneeDetails: freezed == assigneeDetails
          ? _value._assigneeDetails
          : assigneeDetails // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      lastPaymentDate: freezed == lastPaymentDate
          ? _value.lastPaymentDate
          : lastPaymentDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      nextPaymentDate: freezed == nextPaymentDate
          ? _value.nextPaymentDate
          : nextPaymentDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      totalPayments: freezed == totalPayments
          ? _value.totalPayments
          : totalPayments // ignore: cast_nullable_to_non_nullable
              as int?,
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
      {required this.policyId,
      required this.policyNumber,
      required this.providerPolicyId,
      required this.policyholderId,
      required this.agentId,
      required this.providerId,
      required this.policyType,
      required this.planName,
      required this.planCode,
      required this.category,
      required this.sumAssured,
      required this.premiumAmount,
      required this.premiumFrequency,
      required this.premiumMode,
      required this.applicationDate,
      this.approvalDate,
      required this.startDate,
      this.maturityDate,
      this.renewalDate,
      required this.status,
      this.subStatus,
      this.paymentStatus,
      final Map<String, dynamic>? coverageDetails,
      final Map<String, dynamic>? exclusions,
      final Map<String, dynamic>? termsAndConditions,
      this.policyDocumentUrl,
      this.applicationFormUrl,
      final Map<String, dynamic>? medicalReports,
      final Map<String, dynamic>? nomineeDetails,
      final Map<String, dynamic>? assigneeDetails,
      this.lastPaymentDate,
      this.nextPaymentDate,
      this.totalPayments,
      this.outstandingAmount})
      : _coverageDetails = coverageDetails,
        _exclusions = exclusions,
        _termsAndConditions = termsAndConditions,
        _medicalReports = medicalReports,
        _nomineeDetails = nomineeDetails,
        _assigneeDetails = assigneeDetails;

  factory _$PolicyImpl.fromJson(Map<String, dynamic> json) =>
      _$$PolicyImplFromJson(json);

  @override
  final String policyId;
  @override
  final String policyNumber;
  @override
  final String providerPolicyId;
  @override
  final String policyholderId;
  @override
  final String agentId;
  @override
  final String providerId;
  @override
  final String policyType;
  @override
  final String planName;
  @override
  final String planCode;
  @override
  final String category;
  @override
  final double sumAssured;
  @override
  final double premiumAmount;
  @override
  final String premiumFrequency;
  @override
  final String premiumMode;
  @override
  final DateTime applicationDate;
  @override
  final DateTime? approvalDate;
  @override
  final DateTime startDate;
  @override
  final DateTime? maturityDate;
  @override
  final DateTime? renewalDate;
  @override
  final String status;
  @override
  final String? subStatus;
  @override
  final String? paymentStatus;
  final Map<String, dynamic>? _coverageDetails;
  @override
  Map<String, dynamic>? get coverageDetails {
    final value = _coverageDetails;
    if (value == null) return null;
    if (_coverageDetails is EqualUnmodifiableMapView) return _coverageDetails;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _exclusions;
  @override
  Map<String, dynamic>? get exclusions {
    final value = _exclusions;
    if (value == null) return null;
    if (_exclusions is EqualUnmodifiableMapView) return _exclusions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _termsAndConditions;
  @override
  Map<String, dynamic>? get termsAndConditions {
    final value = _termsAndConditions;
    if (value == null) return null;
    if (_termsAndConditions is EqualUnmodifiableMapView)
      return _termsAndConditions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? policyDocumentUrl;
  @override
  final String? applicationFormUrl;
  final Map<String, dynamic>? _medicalReports;
  @override
  Map<String, dynamic>? get medicalReports {
    final value = _medicalReports;
    if (value == null) return null;
    if (_medicalReports is EqualUnmodifiableMapView) return _medicalReports;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _nomineeDetails;
  @override
  Map<String, dynamic>? get nomineeDetails {
    final value = _nomineeDetails;
    if (value == null) return null;
    if (_nomineeDetails is EqualUnmodifiableMapView) return _nomineeDetails;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _assigneeDetails;
  @override
  Map<String, dynamic>? get assigneeDetails {
    final value = _assigneeDetails;
    if (value == null) return null;
    if (_assigneeDetails is EqualUnmodifiableMapView) return _assigneeDetails;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final DateTime? lastPaymentDate;
  @override
  final DateTime? nextPaymentDate;
  @override
  final int? totalPayments;
  @override
  final double? outstandingAmount;

  @override
  String toString() {
    return 'Policy(policyId: $policyId, policyNumber: $policyNumber, providerPolicyId: $providerPolicyId, policyholderId: $policyholderId, agentId: $agentId, providerId: $providerId, policyType: $policyType, planName: $planName, planCode: $planCode, category: $category, sumAssured: $sumAssured, premiumAmount: $premiumAmount, premiumFrequency: $premiumFrequency, premiumMode: $premiumMode, applicationDate: $applicationDate, approvalDate: $approvalDate, startDate: $startDate, maturityDate: $maturityDate, renewalDate: $renewalDate, status: $status, subStatus: $subStatus, paymentStatus: $paymentStatus, coverageDetails: $coverageDetails, exclusions: $exclusions, termsAndConditions: $termsAndConditions, policyDocumentUrl: $policyDocumentUrl, applicationFormUrl: $applicationFormUrl, medicalReports: $medicalReports, nomineeDetails: $nomineeDetails, assigneeDetails: $assigneeDetails, lastPaymentDate: $lastPaymentDate, nextPaymentDate: $nextPaymentDate, totalPayments: $totalPayments, outstandingAmount: $outstandingAmount)';
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
            (identical(other.providerPolicyId, providerPolicyId) ||
                other.providerPolicyId == providerPolicyId) &&
            (identical(other.policyholderId, policyholderId) ||
                other.policyholderId == policyholderId) &&
            (identical(other.agentId, agentId) || other.agentId == agentId) &&
            (identical(other.providerId, providerId) ||
                other.providerId == providerId) &&
            (identical(other.policyType, policyType) ||
                other.policyType == policyType) &&
            (identical(other.planName, planName) ||
                other.planName == planName) &&
            (identical(other.planCode, planCode) ||
                other.planCode == planCode) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.sumAssured, sumAssured) ||
                other.sumAssured == sumAssured) &&
            (identical(other.premiumAmount, premiumAmount) ||
                other.premiumAmount == premiumAmount) &&
            (identical(other.premiumFrequency, premiumFrequency) ||
                other.premiumFrequency == premiumFrequency) &&
            (identical(other.premiumMode, premiumMode) ||
                other.premiumMode == premiumMode) &&
            (identical(other.applicationDate, applicationDate) ||
                other.applicationDate == applicationDate) &&
            (identical(other.approvalDate, approvalDate) ||
                other.approvalDate == approvalDate) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.maturityDate, maturityDate) ||
                other.maturityDate == maturityDate) &&
            (identical(other.renewalDate, renewalDate) ||
                other.renewalDate == renewalDate) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.subStatus, subStatus) ||
                other.subStatus == subStatus) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus) &&
            const DeepCollectionEquality()
                .equals(other._coverageDetails, _coverageDetails) &&
            const DeepCollectionEquality()
                .equals(other._exclusions, _exclusions) &&
            const DeepCollectionEquality()
                .equals(other._termsAndConditions, _termsAndConditions) &&
            (identical(other.policyDocumentUrl, policyDocumentUrl) ||
                other.policyDocumentUrl == policyDocumentUrl) &&
            (identical(other.applicationFormUrl, applicationFormUrl) ||
                other.applicationFormUrl == applicationFormUrl) &&
            const DeepCollectionEquality()
                .equals(other._medicalReports, _medicalReports) &&
            const DeepCollectionEquality()
                .equals(other._nomineeDetails, _nomineeDetails) &&
            const DeepCollectionEquality()
                .equals(other._assigneeDetails, _assigneeDetails) &&
            (identical(other.lastPaymentDate, lastPaymentDate) ||
                other.lastPaymentDate == lastPaymentDate) &&
            (identical(other.nextPaymentDate, nextPaymentDate) ||
                other.nextPaymentDate == nextPaymentDate) &&
            (identical(other.totalPayments, totalPayments) ||
                other.totalPayments == totalPayments) &&
            (identical(other.outstandingAmount, outstandingAmount) ||
                other.outstandingAmount == outstandingAmount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        policyId,
        policyNumber,
        providerPolicyId,
        policyholderId,
        agentId,
        providerId,
        policyType,
        planName,
        planCode,
        category,
        sumAssured,
        premiumAmount,
        premiumFrequency,
        premiumMode,
        applicationDate,
        approvalDate,
        startDate,
        maturityDate,
        renewalDate,
        status,
        subStatus,
        paymentStatus,
        const DeepCollectionEquality().hash(_coverageDetails),
        const DeepCollectionEquality().hash(_exclusions),
        const DeepCollectionEquality().hash(_termsAndConditions),
        policyDocumentUrl,
        applicationFormUrl,
        const DeepCollectionEquality().hash(_medicalReports),
        const DeepCollectionEquality().hash(_nomineeDetails),
        const DeepCollectionEquality().hash(_assigneeDetails),
        lastPaymentDate,
        nextPaymentDate,
        totalPayments,
        outstandingAmount
      ]);

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
      {required final String policyId,
      required final String policyNumber,
      required final String providerPolicyId,
      required final String policyholderId,
      required final String agentId,
      required final String providerId,
      required final String policyType,
      required final String planName,
      required final String planCode,
      required final String category,
      required final double sumAssured,
      required final double premiumAmount,
      required final String premiumFrequency,
      required final String premiumMode,
      required final DateTime applicationDate,
      final DateTime? approvalDate,
      required final DateTime startDate,
      final DateTime? maturityDate,
      final DateTime? renewalDate,
      required final String status,
      final String? subStatus,
      final String? paymentStatus,
      final Map<String, dynamic>? coverageDetails,
      final Map<String, dynamic>? exclusions,
      final Map<String, dynamic>? termsAndConditions,
      final String? policyDocumentUrl,
      final String? applicationFormUrl,
      final Map<String, dynamic>? medicalReports,
      final Map<String, dynamic>? nomineeDetails,
      final Map<String, dynamic>? assigneeDetails,
      final DateTime? lastPaymentDate,
      final DateTime? nextPaymentDate,
      final int? totalPayments,
      final double? outstandingAmount}) = _$PolicyImpl;

  factory _Policy.fromJson(Map<String, dynamic> json) = _$PolicyImpl.fromJson;

  @override
  String get policyId;
  @override
  String get policyNumber;
  @override
  String get providerPolicyId;
  @override
  String get policyholderId;
  @override
  String get agentId;
  @override
  String get providerId;
  @override
  String get policyType;
  @override
  String get planName;
  @override
  String get planCode;
  @override
  String get category;
  @override
  double get sumAssured;
  @override
  double get premiumAmount;
  @override
  String get premiumFrequency;
  @override
  String get premiumMode;
  @override
  DateTime get applicationDate;
  @override
  DateTime? get approvalDate;
  @override
  DateTime get startDate;
  @override
  DateTime? get maturityDate;
  @override
  DateTime? get renewalDate;
  @override
  String get status;
  @override
  String? get subStatus;
  @override
  String? get paymentStatus;
  @override
  Map<String, dynamic>? get coverageDetails;
  @override
  Map<String, dynamic>? get exclusions;
  @override
  Map<String, dynamic>? get termsAndConditions;
  @override
  String? get policyDocumentUrl;
  @override
  String? get applicationFormUrl;
  @override
  Map<String, dynamic>? get medicalReports;
  @override
  Map<String, dynamic>? get nomineeDetails;
  @override
  Map<String, dynamic>? get assigneeDetails;
  @override
  DateTime? get lastPaymentDate;
  @override
  DateTime? get nextPaymentDate;
  @override
  int? get totalPayments;
  @override
  double? get outstandingAmount;
  @override
  @JsonKey(ignore: true)
  _$$PolicyImplCopyWith<_$PolicyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Policyholder _$PolicyholderFromJson(Map<String, dynamic> json) {
  return _Policyholder.fromJson(json);
}

/// @nodoc
mixin _$Policyholder {
  String get policyholderId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String? get agentId => throw _privateConstructorUsedError;
  String? get customerId => throw _privateConstructorUsedError;
  String? get salutation => throw _privateConstructorUsedError;
  String? get maritalStatus => throw _privateConstructorUsedError;
  String? get occupation => throw _privateConstructorUsedError;
  double? get annualIncome => throw _privateConstructorUsedError;
  String? get educationLevel => throw _privateConstructorUsedError;
  Map<String, dynamic>? get riskProfile => throw _privateConstructorUsedError;
  String? get investmentHorizon => throw _privateConstructorUsedError;
  Map<String, dynamic>? get communicationPreferences =>
      throw _privateConstructorUsedError;
  bool? get marketingConsent => throw _privateConstructorUsedError;
  Map<String, dynamic>? get familyMembers => throw _privateConstructorUsedError;
  Map<String, dynamic>? get nomineeDetails =>
      throw _privateConstructorUsedError;
  Map<String, dynamic>? get bankDetails => throw _privateConstructorUsedError;
  Map<String, dynamic>? get investmentPortfolio =>
      throw _privateConstructorUsedError;
  String? get preferredContactTime => throw _privateConstructorUsedError;
  String? get preferredLanguage => throw _privateConstructorUsedError;
  int? get digitalLiteracyScore => throw _privateConstructorUsedError;
  double? get engagementScore => throw _privateConstructorUsedError;
  String? get onboardingStatus => throw _privateConstructorUsedError;
  double? get churnRiskScore => throw _privateConstructorUsedError;
  DateTime? get lastInteractionAt => throw _privateConstructorUsedError;
  int? get totalInteractions => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PolicyholderCopyWith<Policyholder> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PolicyholderCopyWith<$Res> {
  factory $PolicyholderCopyWith(
          Policyholder value, $Res Function(Policyholder) then) =
      _$PolicyholderCopyWithImpl<$Res, Policyholder>;
  @useResult
  $Res call(
      {String policyholderId,
      String userId,
      String? agentId,
      String? customerId,
      String? salutation,
      String? maritalStatus,
      String? occupation,
      double? annualIncome,
      String? educationLevel,
      Map<String, dynamic>? riskProfile,
      String? investmentHorizon,
      Map<String, dynamic>? communicationPreferences,
      bool? marketingConsent,
      Map<String, dynamic>? familyMembers,
      Map<String, dynamic>? nomineeDetails,
      Map<String, dynamic>? bankDetails,
      Map<String, dynamic>? investmentPortfolio,
      String? preferredContactTime,
      String? preferredLanguage,
      int? digitalLiteracyScore,
      double? engagementScore,
      String? onboardingStatus,
      double? churnRiskScore,
      DateTime? lastInteractionAt,
      int? totalInteractions});
}

/// @nodoc
class _$PolicyholderCopyWithImpl<$Res, $Val extends Policyholder>
    implements $PolicyholderCopyWith<$Res> {
  _$PolicyholderCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? policyholderId = null,
    Object? userId = null,
    Object? agentId = freezed,
    Object? customerId = freezed,
    Object? salutation = freezed,
    Object? maritalStatus = freezed,
    Object? occupation = freezed,
    Object? annualIncome = freezed,
    Object? educationLevel = freezed,
    Object? riskProfile = freezed,
    Object? investmentHorizon = freezed,
    Object? communicationPreferences = freezed,
    Object? marketingConsent = freezed,
    Object? familyMembers = freezed,
    Object? nomineeDetails = freezed,
    Object? bankDetails = freezed,
    Object? investmentPortfolio = freezed,
    Object? preferredContactTime = freezed,
    Object? preferredLanguage = freezed,
    Object? digitalLiteracyScore = freezed,
    Object? engagementScore = freezed,
    Object? onboardingStatus = freezed,
    Object? churnRiskScore = freezed,
    Object? lastInteractionAt = freezed,
    Object? totalInteractions = freezed,
  }) {
    return _then(_value.copyWith(
      policyholderId: null == policyholderId
          ? _value.policyholderId
          : policyholderId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      agentId: freezed == agentId
          ? _value.agentId
          : agentId // ignore: cast_nullable_to_non_nullable
              as String?,
      customerId: freezed == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String?,
      salutation: freezed == salutation
          ? _value.salutation
          : salutation // ignore: cast_nullable_to_non_nullable
              as String?,
      maritalStatus: freezed == maritalStatus
          ? _value.maritalStatus
          : maritalStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      occupation: freezed == occupation
          ? _value.occupation
          : occupation // ignore: cast_nullable_to_non_nullable
              as String?,
      annualIncome: freezed == annualIncome
          ? _value.annualIncome
          : annualIncome // ignore: cast_nullable_to_non_nullable
              as double?,
      educationLevel: freezed == educationLevel
          ? _value.educationLevel
          : educationLevel // ignore: cast_nullable_to_non_nullable
              as String?,
      riskProfile: freezed == riskProfile
          ? _value.riskProfile
          : riskProfile // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      investmentHorizon: freezed == investmentHorizon
          ? _value.investmentHorizon
          : investmentHorizon // ignore: cast_nullable_to_non_nullable
              as String?,
      communicationPreferences: freezed == communicationPreferences
          ? _value.communicationPreferences
          : communicationPreferences // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      marketingConsent: freezed == marketingConsent
          ? _value.marketingConsent
          : marketingConsent // ignore: cast_nullable_to_non_nullable
              as bool?,
      familyMembers: freezed == familyMembers
          ? _value.familyMembers
          : familyMembers // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      nomineeDetails: freezed == nomineeDetails
          ? _value.nomineeDetails
          : nomineeDetails // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      bankDetails: freezed == bankDetails
          ? _value.bankDetails
          : bankDetails // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      investmentPortfolio: freezed == investmentPortfolio
          ? _value.investmentPortfolio
          : investmentPortfolio // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      preferredContactTime: freezed == preferredContactTime
          ? _value.preferredContactTime
          : preferredContactTime // ignore: cast_nullable_to_non_nullable
              as String?,
      preferredLanguage: freezed == preferredLanguage
          ? _value.preferredLanguage
          : preferredLanguage // ignore: cast_nullable_to_non_nullable
              as String?,
      digitalLiteracyScore: freezed == digitalLiteracyScore
          ? _value.digitalLiteracyScore
          : digitalLiteracyScore // ignore: cast_nullable_to_non_nullable
              as int?,
      engagementScore: freezed == engagementScore
          ? _value.engagementScore
          : engagementScore // ignore: cast_nullable_to_non_nullable
              as double?,
      onboardingStatus: freezed == onboardingStatus
          ? _value.onboardingStatus
          : onboardingStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      churnRiskScore: freezed == churnRiskScore
          ? _value.churnRiskScore
          : churnRiskScore // ignore: cast_nullable_to_non_nullable
              as double?,
      lastInteractionAt: freezed == lastInteractionAt
          ? _value.lastInteractionAt
          : lastInteractionAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      totalInteractions: freezed == totalInteractions
          ? _value.totalInteractions
          : totalInteractions // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PolicyholderImplCopyWith<$Res>
    implements $PolicyholderCopyWith<$Res> {
  factory _$$PolicyholderImplCopyWith(
          _$PolicyholderImpl value, $Res Function(_$PolicyholderImpl) then) =
      __$$PolicyholderImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String policyholderId,
      String userId,
      String? agentId,
      String? customerId,
      String? salutation,
      String? maritalStatus,
      String? occupation,
      double? annualIncome,
      String? educationLevel,
      Map<String, dynamic>? riskProfile,
      String? investmentHorizon,
      Map<String, dynamic>? communicationPreferences,
      bool? marketingConsent,
      Map<String, dynamic>? familyMembers,
      Map<String, dynamic>? nomineeDetails,
      Map<String, dynamic>? bankDetails,
      Map<String, dynamic>? investmentPortfolio,
      String? preferredContactTime,
      String? preferredLanguage,
      int? digitalLiteracyScore,
      double? engagementScore,
      String? onboardingStatus,
      double? churnRiskScore,
      DateTime? lastInteractionAt,
      int? totalInteractions});
}

/// @nodoc
class __$$PolicyholderImplCopyWithImpl<$Res>
    extends _$PolicyholderCopyWithImpl<$Res, _$PolicyholderImpl>
    implements _$$PolicyholderImplCopyWith<$Res> {
  __$$PolicyholderImplCopyWithImpl(
      _$PolicyholderImpl _value, $Res Function(_$PolicyholderImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? policyholderId = null,
    Object? userId = null,
    Object? agentId = freezed,
    Object? customerId = freezed,
    Object? salutation = freezed,
    Object? maritalStatus = freezed,
    Object? occupation = freezed,
    Object? annualIncome = freezed,
    Object? educationLevel = freezed,
    Object? riskProfile = freezed,
    Object? investmentHorizon = freezed,
    Object? communicationPreferences = freezed,
    Object? marketingConsent = freezed,
    Object? familyMembers = freezed,
    Object? nomineeDetails = freezed,
    Object? bankDetails = freezed,
    Object? investmentPortfolio = freezed,
    Object? preferredContactTime = freezed,
    Object? preferredLanguage = freezed,
    Object? digitalLiteracyScore = freezed,
    Object? engagementScore = freezed,
    Object? onboardingStatus = freezed,
    Object? churnRiskScore = freezed,
    Object? lastInteractionAt = freezed,
    Object? totalInteractions = freezed,
  }) {
    return _then(_$PolicyholderImpl(
      policyholderId: null == policyholderId
          ? _value.policyholderId
          : policyholderId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      agentId: freezed == agentId
          ? _value.agentId
          : agentId // ignore: cast_nullable_to_non_nullable
              as String?,
      customerId: freezed == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String?,
      salutation: freezed == salutation
          ? _value.salutation
          : salutation // ignore: cast_nullable_to_non_nullable
              as String?,
      maritalStatus: freezed == maritalStatus
          ? _value.maritalStatus
          : maritalStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      occupation: freezed == occupation
          ? _value.occupation
          : occupation // ignore: cast_nullable_to_non_nullable
              as String?,
      annualIncome: freezed == annualIncome
          ? _value.annualIncome
          : annualIncome // ignore: cast_nullable_to_non_nullable
              as double?,
      educationLevel: freezed == educationLevel
          ? _value.educationLevel
          : educationLevel // ignore: cast_nullable_to_non_nullable
              as String?,
      riskProfile: freezed == riskProfile
          ? _value._riskProfile
          : riskProfile // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      investmentHorizon: freezed == investmentHorizon
          ? _value.investmentHorizon
          : investmentHorizon // ignore: cast_nullable_to_non_nullable
              as String?,
      communicationPreferences: freezed == communicationPreferences
          ? _value._communicationPreferences
          : communicationPreferences // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      marketingConsent: freezed == marketingConsent
          ? _value.marketingConsent
          : marketingConsent // ignore: cast_nullable_to_non_nullable
              as bool?,
      familyMembers: freezed == familyMembers
          ? _value._familyMembers
          : familyMembers // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      nomineeDetails: freezed == nomineeDetails
          ? _value._nomineeDetails
          : nomineeDetails // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      bankDetails: freezed == bankDetails
          ? _value._bankDetails
          : bankDetails // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      investmentPortfolio: freezed == investmentPortfolio
          ? _value._investmentPortfolio
          : investmentPortfolio // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      preferredContactTime: freezed == preferredContactTime
          ? _value.preferredContactTime
          : preferredContactTime // ignore: cast_nullable_to_non_nullable
              as String?,
      preferredLanguage: freezed == preferredLanguage
          ? _value.preferredLanguage
          : preferredLanguage // ignore: cast_nullable_to_non_nullable
              as String?,
      digitalLiteracyScore: freezed == digitalLiteracyScore
          ? _value.digitalLiteracyScore
          : digitalLiteracyScore // ignore: cast_nullable_to_non_nullable
              as int?,
      engagementScore: freezed == engagementScore
          ? _value.engagementScore
          : engagementScore // ignore: cast_nullable_to_non_nullable
              as double?,
      onboardingStatus: freezed == onboardingStatus
          ? _value.onboardingStatus
          : onboardingStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      churnRiskScore: freezed == churnRiskScore
          ? _value.churnRiskScore
          : churnRiskScore // ignore: cast_nullable_to_non_nullable
              as double?,
      lastInteractionAt: freezed == lastInteractionAt
          ? _value.lastInteractionAt
          : lastInteractionAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      totalInteractions: freezed == totalInteractions
          ? _value.totalInteractions
          : totalInteractions // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PolicyholderImpl implements _Policyholder {
  const _$PolicyholderImpl(
      {required this.policyholderId,
      required this.userId,
      this.agentId,
      this.customerId,
      this.salutation,
      this.maritalStatus,
      this.occupation,
      this.annualIncome,
      this.educationLevel,
      final Map<String, dynamic>? riskProfile,
      this.investmentHorizon,
      final Map<String, dynamic>? communicationPreferences,
      this.marketingConsent,
      final Map<String, dynamic>? familyMembers,
      final Map<String, dynamic>? nomineeDetails,
      final Map<String, dynamic>? bankDetails,
      final Map<String, dynamic>? investmentPortfolio,
      this.preferredContactTime,
      this.preferredLanguage,
      this.digitalLiteracyScore,
      this.engagementScore,
      this.onboardingStatus,
      this.churnRiskScore,
      this.lastInteractionAt,
      this.totalInteractions})
      : _riskProfile = riskProfile,
        _communicationPreferences = communicationPreferences,
        _familyMembers = familyMembers,
        _nomineeDetails = nomineeDetails,
        _bankDetails = bankDetails,
        _investmentPortfolio = investmentPortfolio;

  factory _$PolicyholderImpl.fromJson(Map<String, dynamic> json) =>
      _$$PolicyholderImplFromJson(json);

  @override
  final String policyholderId;
  @override
  final String userId;
  @override
  final String? agentId;
  @override
  final String? customerId;
  @override
  final String? salutation;
  @override
  final String? maritalStatus;
  @override
  final String? occupation;
  @override
  final double? annualIncome;
  @override
  final String? educationLevel;
  final Map<String, dynamic>? _riskProfile;
  @override
  Map<String, dynamic>? get riskProfile {
    final value = _riskProfile;
    if (value == null) return null;
    if (_riskProfile is EqualUnmodifiableMapView) return _riskProfile;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? investmentHorizon;
  final Map<String, dynamic>? _communicationPreferences;
  @override
  Map<String, dynamic>? get communicationPreferences {
    final value = _communicationPreferences;
    if (value == null) return null;
    if (_communicationPreferences is EqualUnmodifiableMapView)
      return _communicationPreferences;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final bool? marketingConsent;
  final Map<String, dynamic>? _familyMembers;
  @override
  Map<String, dynamic>? get familyMembers {
    final value = _familyMembers;
    if (value == null) return null;
    if (_familyMembers is EqualUnmodifiableMapView) return _familyMembers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _nomineeDetails;
  @override
  Map<String, dynamic>? get nomineeDetails {
    final value = _nomineeDetails;
    if (value == null) return null;
    if (_nomineeDetails is EqualUnmodifiableMapView) return _nomineeDetails;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _bankDetails;
  @override
  Map<String, dynamic>? get bankDetails {
    final value = _bankDetails;
    if (value == null) return null;
    if (_bankDetails is EqualUnmodifiableMapView) return _bankDetails;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _investmentPortfolio;
  @override
  Map<String, dynamic>? get investmentPortfolio {
    final value = _investmentPortfolio;
    if (value == null) return null;
    if (_investmentPortfolio is EqualUnmodifiableMapView)
      return _investmentPortfolio;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? preferredContactTime;
  @override
  final String? preferredLanguage;
  @override
  final int? digitalLiteracyScore;
  @override
  final double? engagementScore;
  @override
  final String? onboardingStatus;
  @override
  final double? churnRiskScore;
  @override
  final DateTime? lastInteractionAt;
  @override
  final int? totalInteractions;

  @override
  String toString() {
    return 'Policyholder(policyholderId: $policyholderId, userId: $userId, agentId: $agentId, customerId: $customerId, salutation: $salutation, maritalStatus: $maritalStatus, occupation: $occupation, annualIncome: $annualIncome, educationLevel: $educationLevel, riskProfile: $riskProfile, investmentHorizon: $investmentHorizon, communicationPreferences: $communicationPreferences, marketingConsent: $marketingConsent, familyMembers: $familyMembers, nomineeDetails: $nomineeDetails, bankDetails: $bankDetails, investmentPortfolio: $investmentPortfolio, preferredContactTime: $preferredContactTime, preferredLanguage: $preferredLanguage, digitalLiteracyScore: $digitalLiteracyScore, engagementScore: $engagementScore, onboardingStatus: $onboardingStatus, churnRiskScore: $churnRiskScore, lastInteractionAt: $lastInteractionAt, totalInteractions: $totalInteractions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PolicyholderImpl &&
            (identical(other.policyholderId, policyholderId) ||
                other.policyholderId == policyholderId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.agentId, agentId) || other.agentId == agentId) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.salutation, salutation) ||
                other.salutation == salutation) &&
            (identical(other.maritalStatus, maritalStatus) ||
                other.maritalStatus == maritalStatus) &&
            (identical(other.occupation, occupation) ||
                other.occupation == occupation) &&
            (identical(other.annualIncome, annualIncome) ||
                other.annualIncome == annualIncome) &&
            (identical(other.educationLevel, educationLevel) ||
                other.educationLevel == educationLevel) &&
            const DeepCollectionEquality()
                .equals(other._riskProfile, _riskProfile) &&
            (identical(other.investmentHorizon, investmentHorizon) ||
                other.investmentHorizon == investmentHorizon) &&
            const DeepCollectionEquality().equals(
                other._communicationPreferences, _communicationPreferences) &&
            (identical(other.marketingConsent, marketingConsent) ||
                other.marketingConsent == marketingConsent) &&
            const DeepCollectionEquality()
                .equals(other._familyMembers, _familyMembers) &&
            const DeepCollectionEquality()
                .equals(other._nomineeDetails, _nomineeDetails) &&
            const DeepCollectionEquality()
                .equals(other._bankDetails, _bankDetails) &&
            const DeepCollectionEquality()
                .equals(other._investmentPortfolio, _investmentPortfolio) &&
            (identical(other.preferredContactTime, preferredContactTime) ||
                other.preferredContactTime == preferredContactTime) &&
            (identical(other.preferredLanguage, preferredLanguage) ||
                other.preferredLanguage == preferredLanguage) &&
            (identical(other.digitalLiteracyScore, digitalLiteracyScore) ||
                other.digitalLiteracyScore == digitalLiteracyScore) &&
            (identical(other.engagementScore, engagementScore) ||
                other.engagementScore == engagementScore) &&
            (identical(other.onboardingStatus, onboardingStatus) ||
                other.onboardingStatus == onboardingStatus) &&
            (identical(other.churnRiskScore, churnRiskScore) ||
                other.churnRiskScore == churnRiskScore) &&
            (identical(other.lastInteractionAt, lastInteractionAt) ||
                other.lastInteractionAt == lastInteractionAt) &&
            (identical(other.totalInteractions, totalInteractions) ||
                other.totalInteractions == totalInteractions));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        policyholderId,
        userId,
        agentId,
        customerId,
        salutation,
        maritalStatus,
        occupation,
        annualIncome,
        educationLevel,
        const DeepCollectionEquality().hash(_riskProfile),
        investmentHorizon,
        const DeepCollectionEquality().hash(_communicationPreferences),
        marketingConsent,
        const DeepCollectionEquality().hash(_familyMembers),
        const DeepCollectionEquality().hash(_nomineeDetails),
        const DeepCollectionEquality().hash(_bankDetails),
        const DeepCollectionEquality().hash(_investmentPortfolio),
        preferredContactTime,
        preferredLanguage,
        digitalLiteracyScore,
        engagementScore,
        onboardingStatus,
        churnRiskScore,
        lastInteractionAt,
        totalInteractions
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PolicyholderImplCopyWith<_$PolicyholderImpl> get copyWith =>
      __$$PolicyholderImplCopyWithImpl<_$PolicyholderImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PolicyholderImplToJson(
      this,
    );
  }
}

abstract class _Policyholder implements Policyholder {
  const factory _Policyholder(
      {required final String policyholderId,
      required final String userId,
      final String? agentId,
      final String? customerId,
      final String? salutation,
      final String? maritalStatus,
      final String? occupation,
      final double? annualIncome,
      final String? educationLevel,
      final Map<String, dynamic>? riskProfile,
      final String? investmentHorizon,
      final Map<String, dynamic>? communicationPreferences,
      final bool? marketingConsent,
      final Map<String, dynamic>? familyMembers,
      final Map<String, dynamic>? nomineeDetails,
      final Map<String, dynamic>? bankDetails,
      final Map<String, dynamic>? investmentPortfolio,
      final String? preferredContactTime,
      final String? preferredLanguage,
      final int? digitalLiteracyScore,
      final double? engagementScore,
      final String? onboardingStatus,
      final double? churnRiskScore,
      final DateTime? lastInteractionAt,
      final int? totalInteractions}) = _$PolicyholderImpl;

  factory _Policyholder.fromJson(Map<String, dynamic> json) =
      _$PolicyholderImpl.fromJson;

  @override
  String get policyholderId;
  @override
  String get userId;
  @override
  String? get agentId;
  @override
  String? get customerId;
  @override
  String? get salutation;
  @override
  String? get maritalStatus;
  @override
  String? get occupation;
  @override
  double? get annualIncome;
  @override
  String? get educationLevel;
  @override
  Map<String, dynamic>? get riskProfile;
  @override
  String? get investmentHorizon;
  @override
  Map<String, dynamic>? get communicationPreferences;
  @override
  bool? get marketingConsent;
  @override
  Map<String, dynamic>? get familyMembers;
  @override
  Map<String, dynamic>? get nomineeDetails;
  @override
  Map<String, dynamic>? get bankDetails;
  @override
  Map<String, dynamic>? get investmentPortfolio;
  @override
  String? get preferredContactTime;
  @override
  String? get preferredLanguage;
  @override
  int? get digitalLiteracyScore;
  @override
  double? get engagementScore;
  @override
  String? get onboardingStatus;
  @override
  double? get churnRiskScore;
  @override
  DateTime? get lastInteractionAt;
  @override
  int? get totalInteractions;
  @override
  @JsonKey(ignore: true)
  _$$PolicyholderImplCopyWith<_$PolicyholderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Premium _$PremiumFromJson(Map<String, dynamic> json) {
  return _Premium.fromJson(json);
}

/// @nodoc
mixin _$Premium {
  String get paymentId => throw _privateConstructorUsedError;
  String get policyId => throw _privateConstructorUsedError;
  String get policyholderId => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  DateTime get paymentDate => throw _privateConstructorUsedError;
  DateTime get dueDate => throw _privateConstructorUsedError;
  String? get paymentMethod => throw _privateConstructorUsedError;
  String? get transactionId => throw _privateConstructorUsedError;
  String? get paymentGateway => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get failureReason => throw _privateConstructorUsedError;
  Map<String, dynamic>? get paymentDetails =>
      throw _privateConstructorUsedError;
  String? get receiptUrl => throw _privateConstructorUsedError;
  String? get processedBy => throw _privateConstructorUsedError;

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
      String policyholderId,
      double amount,
      DateTime paymentDate,
      DateTime dueDate,
      String? paymentMethod,
      String? transactionId,
      String? paymentGateway,
      String status,
      String? failureReason,
      Map<String, dynamic>? paymentDetails,
      String? receiptUrl,
      String? processedBy});
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
    Object? policyholderId = null,
    Object? amount = null,
    Object? paymentDate = null,
    Object? dueDate = null,
    Object? paymentMethod = freezed,
    Object? transactionId = freezed,
    Object? paymentGateway = freezed,
    Object? status = null,
    Object? failureReason = freezed,
    Object? paymentDetails = freezed,
    Object? receiptUrl = freezed,
    Object? processedBy = freezed,
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
      policyholderId: null == policyholderId
          ? _value.policyholderId
          : policyholderId // ignore: cast_nullable_to_non_nullable
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
      paymentGateway: freezed == paymentGateway
          ? _value.paymentGateway
          : paymentGateway // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      failureReason: freezed == failureReason
          ? _value.failureReason
          : failureReason // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentDetails: freezed == paymentDetails
          ? _value.paymentDetails
          : paymentDetails // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      receiptUrl: freezed == receiptUrl
          ? _value.receiptUrl
          : receiptUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      processedBy: freezed == processedBy
          ? _value.processedBy
          : processedBy // ignore: cast_nullable_to_non_nullable
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
      String policyholderId,
      double amount,
      DateTime paymentDate,
      DateTime dueDate,
      String? paymentMethod,
      String? transactionId,
      String? paymentGateway,
      String status,
      String? failureReason,
      Map<String, dynamic>? paymentDetails,
      String? receiptUrl,
      String? processedBy});
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
    Object? policyholderId = null,
    Object? amount = null,
    Object? paymentDate = null,
    Object? dueDate = null,
    Object? paymentMethod = freezed,
    Object? transactionId = freezed,
    Object? paymentGateway = freezed,
    Object? status = null,
    Object? failureReason = freezed,
    Object? paymentDetails = freezed,
    Object? receiptUrl = freezed,
    Object? processedBy = freezed,
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
      policyholderId: null == policyholderId
          ? _value.policyholderId
          : policyholderId // ignore: cast_nullable_to_non_nullable
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
      paymentGateway: freezed == paymentGateway
          ? _value.paymentGateway
          : paymentGateway // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      failureReason: freezed == failureReason
          ? _value.failureReason
          : failureReason // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentDetails: freezed == paymentDetails
          ? _value._paymentDetails
          : paymentDetails // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      receiptUrl: freezed == receiptUrl
          ? _value.receiptUrl
          : receiptUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      processedBy: freezed == processedBy
          ? _value.processedBy
          : processedBy // ignore: cast_nullable_to_non_nullable
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
      required this.policyholderId,
      required this.amount,
      required this.paymentDate,
      required this.dueDate,
      this.paymentMethod,
      this.transactionId,
      this.paymentGateway,
      required this.status,
      this.failureReason,
      final Map<String, dynamic>? paymentDetails,
      this.receiptUrl,
      this.processedBy})
      : _paymentDetails = paymentDetails;

  factory _$PremiumImpl.fromJson(Map<String, dynamic> json) =>
      _$$PremiumImplFromJson(json);

  @override
  final String paymentId;
  @override
  final String policyId;
  @override
  final String policyholderId;
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
  final String? paymentGateway;
  @override
  final String status;
  @override
  final String? failureReason;
  final Map<String, dynamic>? _paymentDetails;
  @override
  Map<String, dynamic>? get paymentDetails {
    final value = _paymentDetails;
    if (value == null) return null;
    if (_paymentDetails is EqualUnmodifiableMapView) return _paymentDetails;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? receiptUrl;
  @override
  final String? processedBy;

  @override
  String toString() {
    return 'Premium(paymentId: $paymentId, policyId: $policyId, policyholderId: $policyholderId, amount: $amount, paymentDate: $paymentDate, dueDate: $dueDate, paymentMethod: $paymentMethod, transactionId: $transactionId, paymentGateway: $paymentGateway, status: $status, failureReason: $failureReason, paymentDetails: $paymentDetails, receiptUrl: $receiptUrl, processedBy: $processedBy)';
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
            (identical(other.policyholderId, policyholderId) ||
                other.policyholderId == policyholderId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.paymentDate, paymentDate) ||
                other.paymentDate == paymentDate) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.transactionId, transactionId) ||
                other.transactionId == transactionId) &&
            (identical(other.paymentGateway, paymentGateway) ||
                other.paymentGateway == paymentGateway) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.failureReason, failureReason) ||
                other.failureReason == failureReason) &&
            const DeepCollectionEquality()
                .equals(other._paymentDetails, _paymentDetails) &&
            (identical(other.receiptUrl, receiptUrl) ||
                other.receiptUrl == receiptUrl) &&
            (identical(other.processedBy, processedBy) ||
                other.processedBy == processedBy));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      paymentId,
      policyId,
      policyholderId,
      amount,
      paymentDate,
      dueDate,
      paymentMethod,
      transactionId,
      paymentGateway,
      status,
      failureReason,
      const DeepCollectionEquality().hash(_paymentDetails),
      receiptUrl,
      processedBy);

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
      required final String policyholderId,
      required final double amount,
      required final DateTime paymentDate,
      required final DateTime dueDate,
      final String? paymentMethod,
      final String? transactionId,
      final String? paymentGateway,
      required final String status,
      final String? failureReason,
      final Map<String, dynamic>? paymentDetails,
      final String? receiptUrl,
      final String? processedBy}) = _$PremiumImpl;

  factory _Premium.fromJson(Map<String, dynamic> json) = _$PremiumImpl.fromJson;

  @override
  String get paymentId;
  @override
  String get policyId;
  @override
  String get policyholderId;
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
  String? get paymentGateway;
  @override
  String get status;
  @override
  String? get failureReason;
  @override
  Map<String, dynamic>? get paymentDetails;
  @override
  String? get receiptUrl;
  @override
  String? get processedBy;
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
  String get policyholderId => throw _privateConstructorUsedError;
  String get claimType => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  DateTime get incidentDate => throw _privateConstructorUsedError;
  DateTime get claimDate => throw _privateConstructorUsedError;
  double get claimedAmount => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  String? get subStatus => throw _privateConstructorUsedError;
  Map<String, dynamic>? get documents => throw _privateConstructorUsedError;
  Map<String, dynamic>? get claimDetails => throw _privateConstructorUsedError;
  DateTime? get approvalDate => throw _privateConstructorUsedError;
  DateTime? get settlementDate => throw _privateConstructorUsedError;
  double? get approvedAmount => throw _privateConstructorUsedError;
  String? get rejectionReason => throw _privateConstructorUsedError;
  String? get processedBy => throw _privateConstructorUsedError;
  String? get approvedBy => throw _privateConstructorUsedError;

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
      String policyholderId,
      String claimType,
      String description,
      DateTime incidentDate,
      DateTime claimDate,
      double claimedAmount,
      String? status,
      String? subStatus,
      Map<String, dynamic>? documents,
      Map<String, dynamic>? claimDetails,
      DateTime? approvalDate,
      DateTime? settlementDate,
      double? approvedAmount,
      String? rejectionReason,
      String? processedBy,
      String? approvedBy});
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
    Object? policyholderId = null,
    Object? claimType = null,
    Object? description = null,
    Object? incidentDate = null,
    Object? claimDate = null,
    Object? claimedAmount = null,
    Object? status = freezed,
    Object? subStatus = freezed,
    Object? documents = freezed,
    Object? claimDetails = freezed,
    Object? approvalDate = freezed,
    Object? settlementDate = freezed,
    Object? approvedAmount = freezed,
    Object? rejectionReason = freezed,
    Object? processedBy = freezed,
    Object? approvedBy = freezed,
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
      policyholderId: null == policyholderId
          ? _value.policyholderId
          : policyholderId // ignore: cast_nullable_to_non_nullable
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
      subStatus: freezed == subStatus
          ? _value.subStatus
          : subStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      documents: freezed == documents
          ? _value.documents
          : documents // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      claimDetails: freezed == claimDetails
          ? _value.claimDetails
          : claimDetails // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      approvalDate: freezed == approvalDate
          ? _value.approvalDate
          : approvalDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      settlementDate: freezed == settlementDate
          ? _value.settlementDate
          : settlementDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      approvedAmount: freezed == approvedAmount
          ? _value.approvedAmount
          : approvedAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      rejectionReason: freezed == rejectionReason
          ? _value.rejectionReason
          : rejectionReason // ignore: cast_nullable_to_non_nullable
              as String?,
      processedBy: freezed == processedBy
          ? _value.processedBy
          : processedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      approvedBy: freezed == approvedBy
          ? _value.approvedBy
          : approvedBy // ignore: cast_nullable_to_non_nullable
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
      String policyholderId,
      String claimType,
      String description,
      DateTime incidentDate,
      DateTime claimDate,
      double claimedAmount,
      String? status,
      String? subStatus,
      Map<String, dynamic>? documents,
      Map<String, dynamic>? claimDetails,
      DateTime? approvalDate,
      DateTime? settlementDate,
      double? approvedAmount,
      String? rejectionReason,
      String? processedBy,
      String? approvedBy});
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
    Object? policyholderId = null,
    Object? claimType = null,
    Object? description = null,
    Object? incidentDate = null,
    Object? claimDate = null,
    Object? claimedAmount = null,
    Object? status = freezed,
    Object? subStatus = freezed,
    Object? documents = freezed,
    Object? claimDetails = freezed,
    Object? approvalDate = freezed,
    Object? settlementDate = freezed,
    Object? approvedAmount = freezed,
    Object? rejectionReason = freezed,
    Object? processedBy = freezed,
    Object? approvedBy = freezed,
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
      policyholderId: null == policyholderId
          ? _value.policyholderId
          : policyholderId // ignore: cast_nullable_to_non_nullable
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
      subStatus: freezed == subStatus
          ? _value.subStatus
          : subStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      documents: freezed == documents
          ? _value._documents
          : documents // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      claimDetails: freezed == claimDetails
          ? _value._claimDetails
          : claimDetails // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      approvalDate: freezed == approvalDate
          ? _value.approvalDate
          : approvalDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      settlementDate: freezed == settlementDate
          ? _value.settlementDate
          : settlementDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      approvedAmount: freezed == approvedAmount
          ? _value.approvedAmount
          : approvedAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      rejectionReason: freezed == rejectionReason
          ? _value.rejectionReason
          : rejectionReason // ignore: cast_nullable_to_non_nullable
              as String?,
      processedBy: freezed == processedBy
          ? _value.processedBy
          : processedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      approvedBy: freezed == approvedBy
          ? _value.approvedBy
          : approvedBy // ignore: cast_nullable_to_non_nullable
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
      required this.policyholderId,
      required this.claimType,
      required this.description,
      required this.incidentDate,
      required this.claimDate,
      required this.claimedAmount,
      this.status,
      this.subStatus,
      final Map<String, dynamic>? documents,
      final Map<String, dynamic>? claimDetails,
      this.approvalDate,
      this.settlementDate,
      this.approvedAmount,
      this.rejectionReason,
      this.processedBy,
      this.approvedBy})
      : _documents = documents,
        _claimDetails = claimDetails;

  factory _$ClaimImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClaimImplFromJson(json);

  @override
  final String claimId;
  @override
  final String policyId;
  @override
  final String policyholderId;
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
  final String? subStatus;
  final Map<String, dynamic>? _documents;
  @override
  Map<String, dynamic>? get documents {
    final value = _documents;
    if (value == null) return null;
    if (_documents is EqualUnmodifiableMapView) return _documents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _claimDetails;
  @override
  Map<String, dynamic>? get claimDetails {
    final value = _claimDetails;
    if (value == null) return null;
    if (_claimDetails is EqualUnmodifiableMapView) return _claimDetails;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final DateTime? approvalDate;
  @override
  final DateTime? settlementDate;
  @override
  final double? approvedAmount;
  @override
  final String? rejectionReason;
  @override
  final String? processedBy;
  @override
  final String? approvedBy;

  @override
  String toString() {
    return 'Claim(claimId: $claimId, policyId: $policyId, policyholderId: $policyholderId, claimType: $claimType, description: $description, incidentDate: $incidentDate, claimDate: $claimDate, claimedAmount: $claimedAmount, status: $status, subStatus: $subStatus, documents: $documents, claimDetails: $claimDetails, approvalDate: $approvalDate, settlementDate: $settlementDate, approvedAmount: $approvedAmount, rejectionReason: $rejectionReason, processedBy: $processedBy, approvedBy: $approvedBy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClaimImpl &&
            (identical(other.claimId, claimId) || other.claimId == claimId) &&
            (identical(other.policyId, policyId) ||
                other.policyId == policyId) &&
            (identical(other.policyholderId, policyholderId) ||
                other.policyholderId == policyholderId) &&
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
            (identical(other.subStatus, subStatus) ||
                other.subStatus == subStatus) &&
            const DeepCollectionEquality()
                .equals(other._documents, _documents) &&
            const DeepCollectionEquality()
                .equals(other._claimDetails, _claimDetails) &&
            (identical(other.approvalDate, approvalDate) ||
                other.approvalDate == approvalDate) &&
            (identical(other.settlementDate, settlementDate) ||
                other.settlementDate == settlementDate) &&
            (identical(other.approvedAmount, approvedAmount) ||
                other.approvedAmount == approvedAmount) &&
            (identical(other.rejectionReason, rejectionReason) ||
                other.rejectionReason == rejectionReason) &&
            (identical(other.processedBy, processedBy) ||
                other.processedBy == processedBy) &&
            (identical(other.approvedBy, approvedBy) ||
                other.approvedBy == approvedBy));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      claimId,
      policyId,
      policyholderId,
      claimType,
      description,
      incidentDate,
      claimDate,
      claimedAmount,
      status,
      subStatus,
      const DeepCollectionEquality().hash(_documents),
      const DeepCollectionEquality().hash(_claimDetails),
      approvalDate,
      settlementDate,
      approvedAmount,
      rejectionReason,
      processedBy,
      approvedBy);

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
      required final String policyholderId,
      required final String claimType,
      required final String description,
      required final DateTime incidentDate,
      required final DateTime claimDate,
      required final double claimedAmount,
      final String? status,
      final String? subStatus,
      final Map<String, dynamic>? documents,
      final Map<String, dynamic>? claimDetails,
      final DateTime? approvalDate,
      final DateTime? settlementDate,
      final double? approvedAmount,
      final String? rejectionReason,
      final String? processedBy,
      final String? approvedBy}) = _$ClaimImpl;

  factory _Claim.fromJson(Map<String, dynamic> json) = _$ClaimImpl.fromJson;

  @override
  String get claimId;
  @override
  String get policyId;
  @override
  String get policyholderId;
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
  String? get subStatus;
  @override
  Map<String, dynamic>? get documents;
  @override
  Map<String, dynamic>? get claimDetails;
  @override
  DateTime? get approvalDate;
  @override
  DateTime? get settlementDate;
  @override
  double? get approvedAmount;
  @override
  String? get rejectionReason;
  @override
  String? get processedBy;
  @override
  String? get approvedBy;
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
  Map<String, dynamic>? get terms => throw _privateConstructorUsedError;
  Map<String, dynamic>? get conditions => throw _privateConstructorUsedError;

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
      String? status,
      Map<String, dynamic>? terms,
      Map<String, dynamic>? conditions});
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
    Object? terms = freezed,
    Object? conditions = freezed,
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
      terms: freezed == terms
          ? _value.terms
          : terms // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      conditions: freezed == conditions
          ? _value.conditions
          : conditions // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
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
      String? status,
      Map<String, dynamic>? terms,
      Map<String, dynamic>? conditions});
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
    Object? terms = freezed,
    Object? conditions = freezed,
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
      terms: freezed == terms
          ? _value._terms
          : terms // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      conditions: freezed == conditions
          ? _value._conditions
          : conditions // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
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
      this.status,
      final Map<String, dynamic>? terms,
      final Map<String, dynamic>? conditions})
      : _terms = terms,
        _conditions = conditions;

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
  final Map<String, dynamic>? _terms;
  @override
  Map<String, dynamic>? get terms {
    final value = _terms;
    if (value == null) return null;
    if (_terms is EqualUnmodifiableMapView) return _terms;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _conditions;
  @override
  Map<String, dynamic>? get conditions {
    final value = _conditions;
    if (value == null) return null;
    if (_conditions is EqualUnmodifiableMapView) return _conditions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'Coverage(coverageId: $coverageId, policyId: $policyId, coverageType: $coverageType, description: $description, sumAssured: $sumAssured, premium: $premium, startDate: $startDate, endDate: $endDate, status: $status, terms: $terms, conditions: $conditions)';
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
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._terms, _terms) &&
            const DeepCollectionEquality()
                .equals(other._conditions, _conditions));
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
      status,
      const DeepCollectionEquality().hash(_terms),
      const DeepCollectionEquality().hash(_conditions));

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
      final String? status,
      final Map<String, dynamic>? terms,
      final Map<String, dynamic>? conditions}) = _$CoverageImpl;

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
  Map<String, dynamic>? get terms;
  @override
  Map<String, dynamic>? get conditions;
  @override
  @JsonKey(ignore: true)
  _$$CoverageImplCopyWith<_$CoverageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
