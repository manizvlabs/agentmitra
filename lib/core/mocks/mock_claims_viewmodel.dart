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
        policyholderId: 'PH001',
        claimType: 'Medical',
        description: 'Hospitalization due to accident',
        incidentDate: DateTime.now().subtract(const Duration(days: 10)),
        claimDate: DateTime.now().subtract(const Duration(days: 7)),
        claimedAmount: 50000.0,
        status: 'approved',
        documents: {
          'medical_report': 'medical_report.pdf',
          'bill_receipt': 'bill_receipt.pdf',
        },
      ),
      Claim(
        claimId: 'CLM002',
        policyId: 'POL002',
        policyholderId: 'PH002',
        claimType: 'Vehicle Damage',
        description: 'Car accident damage',
        incidentDate: DateTime.now().subtract(const Duration(days: 5)),
        claimDate: DateTime.now().subtract(const Duration(days: 2)),
        claimedAmount: 25000.0,
        status: 'pending',
        documents: {
          'accident_report': 'accident_report.pdf',
          'repair_estimate': 'repair_estimate.pdf',
        },
      ),
      Claim(
        claimId: 'CLM003',
        policyId: 'POL003',
        policyholderId: 'PH003',
        claimType: 'Property Damage',
        description: 'House fire damage',
        incidentDate: DateTime.now().subtract(const Duration(days: 12)),
        claimDate: DateTime.now().subtract(const Duration(days: 10)),
        claimedAmount: 15000.0,
        status: 'rejected',
        documents: {
          'fire_report': 'fire_report.pdf',
          'damage_photos': 'damage_photos.pdf',
        },
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
    _claims.insert(0, Claim(
      claimId: 'CLM${(_claims.length + 1).toString().padLeft(3, '0')}',
      policyId: claim.policyId,
      policyholderId: claim.policyholderId,
      claimType: claim.claimType,
      description: claim.description,
      incidentDate: claim.incidentDate,
      claimDate: DateTime.now(),
      claimedAmount: claim.claimedAmount,
      status: 'pending',
      documents: claim.documents,
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
      final existingClaim = _claims[index];
      _claims[index] = Claim(
        claimId: existingClaim.claimId,
        policyId: existingClaim.policyId,
        policyholderId: existingClaim.policyholderId,
        claimType: existingClaim.claimType,
        description: existingClaim.description,
        incidentDate: existingClaim.incidentDate,
        claimDate: existingClaim.claimDate,
        claimedAmount: existingClaim.claimedAmount,
        status: status,
        documents: existingClaim.documents,
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
