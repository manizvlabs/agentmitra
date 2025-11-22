import 'package:flutter/material.dart';
import '../../features/payments/data/models/claim_model.dart';

/// Mock ClaimsViewModel for web compatibility
class MockClaimsViewModel extends ChangeNotifier {
  List<Claim> _claims = [];
  Claim? _selectedClaim;
  bool _isLoading = false;
  String? _error;

  List<Claim> get claims => _claims;
  Claim? get selectedClaim => _selectedClaim;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Claim> get pendingClaims => _claims.where((c) => c.status == 'pending').toList();
  List<Claim> get approvedClaims => _claims.where((c) => c.status == 'approved').toList();
  List<Claim> get rejectedClaims => _claims.where((c) => c.status == 'rejected').toList();

  MockClaimsViewModel() {
    _initializeMockClaims();
  }

  void _initializeMockClaims() {
    _claims = [
      Claim(
        claimId: 'CLM001',
        policyId: 'POL001',
        customerId: 'CUST001',
        customerName: 'John Doe',
        claimAmount: 50000.0,
        claimReason: 'Medical Emergency',
        description: 'Hospitalization due to accident',
        status: 'approved',
        submittedDate: DateTime.now().subtract(const Duration(days: 7)),
        approvedDate: DateTime.now().subtract(const Duration(days: 3)),
        documents: ['medical_report.pdf', 'bill_receipt.pdf'],
        comments: 'Claim approved after document verification',
      ),
      Claim(
        claimId: 'CLM002',
        policyId: 'POL002',
        customerId: 'CUST002',
        customerName: 'Jane Smith',
        claimAmount: 25000.0,
        claimReason: 'Vehicle Damage',
        description: 'Car accident damage',
        status: 'pending',
        submittedDate: DateTime.now().subtract(const Duration(days: 2)),
        documents: ['accident_report.pdf', 'repair_estimate.pdf'],
        comments: null,
      ),
      Claim(
        claimId: 'CLM003',
        policyId: 'POL003',
        customerId: 'CUST003',
        customerName: 'Bob Johnson',
        claimAmount: 15000.0,
        claimReason: 'Property Damage',
        description: 'House fire damage',
        status: 'rejected',
        submittedDate: DateTime.now().subtract(const Duration(days: 10)),
        rejectedDate: DateTime.now().subtract(const Duration(days: 5)),
        documents: ['fire_report.pdf', 'damage_photos.pdf'],
        comments: 'Insufficient documentation provided',
      ),
    ];
  }

  Future<void> loadClaims({String? status, int? limit, int? offset}) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    // Filter claims if status is provided
    if (status != null) {
      _claims = _claims.where((c) => c.status == status).toList();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadClaimDetails(String claimId) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _selectedClaim = _claims.firstWhere((c) => c.claimId == claimId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> submitClaim(Claim claim) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    // Add the new claim to the list
    _claims.insert(0, claim.copyWith(
      claimId: 'CLM${(_claims.length + 1).toString().padLeft(3, '0')}',
      status: 'pending',
      submittedDate: DateTime.now(),
    ));

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateClaimStatus(String claimId, String status, {String? comments}) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    final index = _claims.indexWhere((c) => c.claimId == claimId);
    if (index != -1) {
      _claims[index] = _claims[index].copyWith(
        status: status,
        comments: comments,
        approvedDate: status == 'approved' ? DateTime.now() : null,
        rejectedDate: status == 'rejected' ? DateTime.now() : null,
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  void selectClaim(Claim claim) {
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
