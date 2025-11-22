import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import '../../data/repositories/policy_repository.dart';
import '../../data/datasources/policy_remote_datasource.dart';
import '../../data/datasources/policy_local_datasource.dart';
import '../../data/models/policy_model.dart';

class ClaimsViewModel extends ChangeNotifier {
  final PolicyRepository _policyRepository;

  ClaimsViewModel([PolicyRepository? policyRepository])
      : _policyRepository = policyRepository ?? PolicyRepository(PolicyRemoteDataSourceImpl(), PolicyLocalDataSourceImpl()) {
    // Initialize with mock data for Phase 5 testing
    _initializeMockData();
  }

  // State
  List<Claim> _claims = [];
  bool _isLoading = false;
  String? _error;
  dynamic _selectedImage;
  dynamic _selectedDocument;

  // Form state
  String _claimType = '';
  String _description = '';
  DateTime _incidentDate = DateTime.now();
  double _claimedAmount = 0.0;
  String _policyId = '';

  // Getters
  List<Claim> get claims => _claims;
  bool get isLoading => _isLoading;
  String? get error => _error;
  dynamic get selectedImage => _selectedImage;
  dynamic get selectedDocument => _selectedDocument;

  // Form getters
  String get claimType => _claimType;
  String get description => _description;
  DateTime get incidentDate => _incidentDate;
  double get claimedAmount => _claimedAmount;
  String get policyId => _policyId;

  // Computed properties
  List<Claim> get pendingClaims =>
      _claims.where((claim) => claim.status == 'pending').toList();

  List<Claim> get approvedClaims =>
      _claims.where((claim) => claim.status == 'approved').toList();

  List<Claim> get rejectedClaims =>
      _claims.where((claim) => claim.status == 'rejected').toList();

  bool get isFormValid =>
      _claimType.isNotEmpty &&
      _description.isNotEmpty &&
      _claimedAmount > 0 &&
      _policyId.isNotEmpty;

  // Actions
  Future<void> loadClaims(String policyId) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    _policyId = policyId;
    notifyListeners();

    try {
      final result = await _policyRepository.getClaimsByPolicyId(policyId);

      result.fold(
        (error) {
          _error = error.toString();
        },
        (claims) {
          _claims = claims;
        },
      );
    } catch (e) {
      _error = 'Failed to load claims: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshClaims() async {
    if (_policyId.isNotEmpty) {
      await loadClaims(_policyId);
    }
  }

  // Form actions
  void setClaimType(String type) {
    _claimType = type;
    notifyListeners();
  }

  void setDescription(String desc) {
    _description = desc;
    notifyListeners();
  }

  void setIncidentDate(DateTime date) {
    _incidentDate = date;
    notifyListeners();
  }

  void setClaimedAmount(double amount) {
    _claimedAmount = amount;
    notifyListeners();
  }

  void setPolicyId(String policyId) {
    _policyId = policyId;
    notifyListeners();
  }

  // Image/Document selection (disabled for web compatibility)
  Future<void> pickImage() async {
    // TODO: Implement web-compatible image picking
    // final picker = ImagePicker();
    // final image = await picker.pickImage(source: ImageSource.gallery);
    // if (image != null) {
    //   _selectedImage = image;
    //   notifyListeners();
    // }
  }

  Future<void> pickDocument() async {
    // TODO: Implement web-compatible document picking
    // final picker = ImagePicker();
    // final document = await picker.pickImage(source: ImageSource.gallery);
    // if (document != null) {
    //   _selectedDocument = document;
    //   notifyListeners();
    // }
  }

  Future<void> takePhoto() async {
    // TODO: Implement web-compatible camera access
    // final picker = ImagePicker();
    // final photo = await picker.pickImage(source: ImageSource.camera);
    // if (photo != null) {
    //   _selectedImage = photo;
    //   notifyListeners();
    // }
  }

  void clearSelectedFiles() {
    _selectedImage = null;
    _selectedDocument = null;
    notifyListeners();
  }

  // Claim submission
  Future<Either<Exception, Claim>> submitClaim() async {
    if (!isFormValid) {
      return Left(Exception('Please fill all required fields'));
    }

    _isLoading = true;
    notifyListeners();

    try {
      // For now, create a mock claim response
      // TODO: Replace with actual API call when backend claim endpoint is ready
      final mockClaim = Claim(
        claimId: DateTime.now().millisecondsSinceEpoch.toString(),
        policyId: _policyId,
        policyholderId: '', // Will be set by backend
        claimType: _claimType,
        description: _description,
        incidentDate: _incidentDate,
        claimDate: DateTime.now(),
        claimedAmount: _claimedAmount,
        status: 'pending',
      );

      // Reset form
      _resetForm();

      _isLoading = false;
      notifyListeners();

      return Right(mockClaim);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return Left(Exception('Failed to submit claim: $e'));
    }
  }

  void _resetForm() {
    _claimType = '';
    _description = '';
    _incidentDate = DateTime.now();
    _claimedAmount = 0.0;
    _selectedImage = null;
    _selectedDocument = null;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _initializeMockData() {
    // Mock claims data for Phase 5 testing
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
          'hospital_bill': 'hospital_bill.pdf',
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
        claimedAmount: 75000.0,
        status: 'processing',
        documents: {
          'accident_report': 'accident_report.pdf',
          'repair_estimate': 'repair_estimate.pdf',
        },
      ),
    ];
  }
}
