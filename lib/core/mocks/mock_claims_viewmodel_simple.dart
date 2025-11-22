import 'package:flutter/material.dart';
import 'mock_data.dart';

/// Production-grade Mock ClaimsViewModel for web compatibility
class MockClaimsViewModel extends ChangeNotifier {
  List<Map<String, dynamic>> _claims = [];
  Map<String, dynamic>? _selectedClaim;
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get claims => _claims;
  Map<String, dynamic>? get selectedClaim => _selectedClaim;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Map<String, dynamic>> get pendingClaims => _claims.where((c) => c['status'] == 'pending').toList();
  List<Map<String, dynamic>> get approvedClaims => _claims.where((c) => c['status'] == 'approved').toList();
  List<Map<String, dynamic>> get rejectedClaims => _claims.where((c) => c['status'] == 'rejected').toList();

  MockClaimsViewModel() {
    _initializeMockClaims();
  }

  void _initializeMockClaims() {
    _claims = [
      MockData.mockClaim,
      {
        'claimId': 'CLM002',
        'policyId': 'POL002',
        'customerId': 'CUST002',
        'customerName': 'Jane Smith',
        'claimAmount': 25000.0,
        'claimReason': 'Vehicle Damage',
        'description': 'Car accident damage',
        'status': 'pending',
        'submittedDate': DateTime.now().subtract(const Duration(days: 2)),
        'documents': ['accident_report.pdf', 'repair_estimate.pdf'],
        'comments': null,
      },
      {
        'claimId': 'CLM003',
        'policyId': 'POL003',
        'customerId': 'CUST003',
        'customerName': 'Bob Johnson',
        'claimAmount': 15000.0,
        'claimReason': 'Property Damage',
        'description': 'House fire damage',
        'status': 'rejected',
        'submittedDate': DateTime.now().subtract(const Duration(days: 10)),
        'rejectedDate': DateTime.now().subtract(const Duration(days: 5)),
        'documents': ['fire_report.pdf', 'damage_photos.pdf'],
        'comments': 'Insufficient documentation provided',
      },
    ];
  }

  Future<void> loadClaims({String? status, int? limit, int? offset}) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    if (status != null) {
      _claims = _claims.where((c) => c['status'] == status).toList();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadClaimDetails(String claimId) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _selectedClaim = _claims.firstWhere((c) => c['claimId'] == claimId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> submitClaim(Map<String, dynamic> claim) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    _claims.insert(0, {
      ...claim,
      'claimId': 'CLM${(_claims.length + 1).toString().padLeft(3, '0')}',
      'status': 'pending',
      'submittedDate': DateTime.now(),
    });

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateClaimStatus(String claimId, String status, {String? comments}) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    final index = _claims.indexWhere((c) => c['claimId'] == claimId);
    if (index != -1) {
      _claims[index] = {
        ..._claims[index],
        'status': status,
        'comments': comments,
        'approvedDate': status == 'approved' ? DateTime.now() : null,
        'rejectedDate': status == 'rejected' ? DateTime.now() : null,
      };
    }

    _isLoading = false;
    notifyListeners();
  }

  void selectClaim(Map<String, dynamic> claim) {
    _selectedClaim = claim;
    notifyListeners();
  }

  void clearSelection() {
    _selectedClaim = null;
    notifyListeners();
  }

  Future<void> initialize() async {
    await loadClaims();
  }
}
