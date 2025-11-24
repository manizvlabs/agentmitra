/// Repository for campaign data operations
import '../datasources/campaign_remote_datasource.dart';
import '../models/campaign_model.dart';

class CampaignRepository {
  final CampaignRemoteDataSource _remoteDataSource;

  CampaignRepository({CampaignRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? CampaignRemoteDataSource();

  /// Create a new campaign
  Future<Campaign> createCampaign(Map<String, dynamic> campaignData) {
    return _remoteDataSource.createCampaign(campaignData);
  }

  /// Get list of campaigns
  Future<List<Campaign>> getCampaigns({
    String? status,
    String? type,
    int limit = 50,
    int offset = 0,
  }) {
    return _remoteDataSource.getCampaigns(
      status: status,
      type: type,
      limit: limit,
      offset: offset,
    );
  }

  /// Get campaign by ID
  Future<Campaign> getCampaign(String campaignId) {
    return _remoteDataSource.getCampaign(campaignId);
  }

  /// Update campaign
  Future<Campaign> updateCampaign(String campaignId, Map<String, dynamic> updateData) {
    return _remoteDataSource.updateCampaign(campaignId, updateData);
  }

  /// Launch campaign
  Future<Campaign> launchCampaign(String campaignId) {
    return _remoteDataSource.launchCampaign(campaignId);
  }

  /// Get campaign analytics
  Future<Map<String, dynamic>> getCampaignAnalytics(String campaignId) {
    return _remoteDataSource.getCampaignAnalytics(campaignId);
  }

  /// Get campaign templates
  Future<List<CampaignTemplate>> getCampaignTemplates({
    String? category,
    bool isPublic = true,
    int limit = 50,
  }) {
    return _remoteDataSource.getCampaignTemplates(
      category: category,
      isPublic: isPublic,
      limit: limit,
    );
  }

  /// Create campaign from template
  Future<Campaign> createCampaignFromTemplate(
    String templateId,
    Map<String, dynamic> campaignData,
  ) {
    return _remoteDataSource.createCampaignFromTemplate(templateId, campaignData);
  }

  /// Get campaign recommendations
  Future<List<Map<String, dynamic>>> getCampaignRecommendations() {
    return _remoteDataSource.getCampaignRecommendations();
  }
}

