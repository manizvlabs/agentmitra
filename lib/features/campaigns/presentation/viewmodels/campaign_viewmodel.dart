import '../../../../core/architecture/base/base_viewmodel.dart';
import '../../data/repositories/campaign_repository.dart';
import '../../data/models/campaign_model.dart';

/// ViewModel for campaign management
class CampaignViewModel extends BaseViewModel {
  final CampaignRepository _repository;

  CampaignViewModel({CampaignRepository? repository})
      : _repository = repository ?? CampaignRepository();

  List<Campaign> _campaigns = [];
  Campaign? _selectedCampaign;
  List<CampaignTemplate> _templates = [];
  Map<String, dynamic>? _analytics;
  List<Map<String, dynamic>> _recommendations = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Campaign> get campaigns => _campaigns;
  Campaign? get selectedCampaign => _selectedCampaign;
  List<CampaignTemplate> get templates => _templates;
  Map<String, dynamic>? get analytics => _analytics;
  List<Map<String, dynamic>> get recommendations => _recommendations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  @override
  Future<void> initialize() async {
    await super.initialize();
    await loadCampaigns();
    await loadTemplates();
    await loadRecommendations();
  }

  /// Load campaigns list
  Future<void> loadCampaigns({String? status, String? type}) async {
    await executeAsync(
      () async {
        _isLoading = true;
        notifyListeners();
        try {
          _campaigns = await _repository.getCampaigns(status: status, type: type);
          _errorMessage = null;
        } catch (e) {
          _errorMessage = e.toString();
        } finally {
          _isLoading = false;
          notifyListeners();
        }
      },
    );
  }

  /// Load campaign details
  Future<void> loadCampaign(String campaignId) async {
    await executeAsync(
      () async {
        _isLoading = true;
        notifyListeners();
        try {
          _selectedCampaign = await _repository.getCampaign(campaignId);
          _errorMessage = null;
        } catch (e) {
          _errorMessage = e.toString();
        } finally {
          _isLoading = false;
          notifyListeners();
        }
      },
    );
  }

  /// Create new campaign
  Future<bool> createCampaign(Map<String, dynamic> campaignData) async {
    bool success = false;
    await executeAsync(
      () async {
        _isLoading = true;
        notifyListeners();
        try {
          final campaign = await _repository.createCampaign(campaignData);
          _campaigns.insert(0, campaign);
          _errorMessage = null;
          success = true;
        } catch (e) {
          _errorMessage = e.toString();
          success = false;
        } finally {
          _isLoading = false;
          notifyListeners();
        }
      },
    );
    return success;
  }

  /// Update campaign
  Future<bool> updateCampaign(String campaignId, Map<String, dynamic> updateData) async {
    bool success = false;
    await executeAsync(
      () async {
        _isLoading = true;
        notifyListeners();
        try {
          final updatedCampaign = await _repository.updateCampaign(campaignId, updateData);
          final index = _campaigns.indexWhere((c) => c.campaignId == campaignId);
          if (index != -1) {
            _campaigns[index] = updatedCampaign;
          }
          if (_selectedCampaign?.campaignId == campaignId) {
            _selectedCampaign = updatedCampaign;
          }
          _errorMessage = null;
          success = true;
        } catch (e) {
          _errorMessage = e.toString();
          success = false;
        } finally {
          _isLoading = false;
          notifyListeners();
        }
      },
    );
    return success;
  }

  /// Launch campaign
  Future<bool> launchCampaign(String campaignId) async {
    bool success = false;
    await executeAsync(
      () async {
        _isLoading = true;
        notifyListeners();
        try {
          final campaign = await _repository.launchCampaign(campaignId);
          final index = _campaigns.indexWhere((c) => c.campaignId == campaignId);
          if (index != -1) {
            _campaigns[index] = campaign;
          }
          if (_selectedCampaign?.campaignId == campaignId) {
            _selectedCampaign = campaign;
          }
          _errorMessage = null;
          success = true;
        } catch (e) {
          _errorMessage = e.toString();
          success = false;
        } finally {
          _isLoading = false;
          notifyListeners();
        }
      },
    );
    return success;
  }

  /// Load campaign analytics
  Future<void> loadCampaignAnalytics(String campaignId) async {
    await executeAsync(
      () async {
        _isLoading = true;
        notifyListeners();
        try {
          _analytics = await _repository.getCampaignAnalytics(campaignId);
          _errorMessage = null;
        } catch (e) {
          _errorMessage = e.toString();
        } finally {
          _isLoading = false;
          notifyListeners();
        }
      },
    );
  }

  /// Load templates
  Future<void> loadTemplates({String? category}) async {
    await executeAsync(
      () async {
        try {
          _templates = await _repository.getCampaignTemplates(category: category);
        } catch (e) {
          _errorMessage = e.toString();
        } finally {
          notifyListeners();
        }
      },
    );
  }

  /// Create campaign from template
  Future<bool> createCampaignFromTemplate(
    String templateId,
    Map<String, dynamic> campaignData,
  ) async {
    bool success = false;
    await executeAsync(
      () async {
        _isLoading = true;
        notifyListeners();
        try {
          final campaign = await _repository.createCampaignFromTemplate(templateId, campaignData);
          _campaigns.insert(0, campaign);
          _errorMessage = null;
          success = true;
        } catch (e) {
          _errorMessage = e.toString();
          success = false;
        } finally {
          _isLoading = false;
          notifyListeners();
        }
      },
    );
    return success;
  }

  /// Load recommendations
  Future<void> loadRecommendations() async {
    await executeAsync(
      () async {
        try {
          _recommendations = await _repository.getCampaignRecommendations();
        } catch (e) {
          // Recommendations are optional, don't set error
        } finally {
          notifyListeners();
        }
      },
    );
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

