/// Remote data source for campaign API calls
import '../../../../core/services/api_service.dart';
import '../models/campaign_model.dart';

class CampaignRemoteDataSource {
  /// Create a new campaign
  Future<Campaign> createCampaign(Map<String, dynamic> campaignData) async {
    final response = await ApiService.post('/campaigns', campaignData);
    if (response['success'] == true && response['data'] != null) {
      return Campaign.fromJson(response['data']);
    }
    throw Exception(response['message'] ?? 'Failed to create campaign');
  }

  /// Get list of campaigns
  Future<List<Campaign>> getCampaigns({
    String? status,
    String? type,
    int limit = 50,
    int offset = 0,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
      'offset': offset,
    };
    if (status != null) queryParams['status'] = status;
    if (type != null) queryParams['type'] = type;

    final response = await ApiService.get('/campaigns', queryParameters: queryParams);
    if (response['success'] == true && response['data'] != null) {
      final List<dynamic> campaignsJson = response['data'];
      return campaignsJson.map((json) => Campaign.fromJson(json)).toList();
    }
    return [];
  }

  /// Get campaign by ID
  Future<Campaign> getCampaign(String campaignId) async {
    final response = await ApiService.get('/campaigns/$campaignId');
    if (response['success'] == true && response['data'] != null) {
      return Campaign.fromJson(response['data']);
    }
    throw Exception(response['message'] ?? 'Campaign not found');
  }

  /// Update campaign
  Future<Campaign> updateCampaign(String campaignId, Map<String, dynamic> updateData) async {
    final response = await ApiService.put('/campaigns/$campaignId', updateData);
    if (response['success'] == true) {
      // Fetch updated campaign
      return await getCampaign(campaignId);
    }
    throw Exception(response['message'] ?? 'Failed to update campaign');
  }

  /// Launch campaign
  Future<Campaign> launchCampaign(String campaignId) async {
    final response = await ApiService.post('/campaigns/$campaignId/launch', {});
    if (response['success'] == true && response['data'] != null) {
      return await getCampaign(campaignId);
    }
    throw Exception(response['message'] ?? 'Failed to launch campaign');
  }

  /// Get campaign analytics
  Future<Map<String, dynamic>> getCampaignAnalytics(String campaignId) async {
    final response = await ApiService.get('/campaigns/$campaignId/analytics');
    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }
    throw Exception(response['message'] ?? 'Failed to get analytics');
  }

  /// Get campaign templates
  Future<List<CampaignTemplate>> getCampaignTemplates({
    String? category,
    bool isPublic = true,
    int limit = 50,
  }) async {
    final queryParams = <String, dynamic>{
      'is_public': isPublic,
      'limit': limit,
    };
    if (category != null) queryParams['category'] = category;

    final response = await ApiService.get('/campaigns/templates', queryParameters: queryParams);
    if (response['success'] == true && response['data'] != null) {
      final List<dynamic> templatesJson = response['data'];
      return templatesJson.map((json) => CampaignTemplate.fromJson(json)).toList();
    }
    return [];
  }

  /// Create campaign from template
  Future<Campaign> createCampaignFromTemplate(
    String templateId,
    Map<String, dynamic> campaignData,
  ) async {
    final response = await ApiService.post(
      '/campaigns/templates/$templateId/create',
      campaignData,
    );
    if (response['success'] == true && response['data'] != null) {
      return Campaign.fromJson(response['data']);
    }
    throw Exception(response['message'] ?? 'Failed to create campaign from template');
  }

  /// Get campaign recommendations
  Future<List<Map<String, dynamic>>> getCampaignRecommendations() async {
    final response = await ApiService.get('/campaigns/recommendations');
    if (response['success'] == true && response['data'] != null) {
      final List<dynamic> recommendationsJson = response['data'];
      return recommendationsJson.cast<Map<String, dynamic>>();
    }
    return [];
  }
}

