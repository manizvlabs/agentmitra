/// Campaign data models
class Campaign {
  final String campaignId;
  final String agentId;
  final String campaignName;
  final String campaignType;
  final String? campaignGoal;
  final String? description;
  final String? subject;
  final String message;
  final String status;
  final int totalSent;
  final int totalDelivered;
  final int totalOpened;
  final int totalClicked;
  final int totalConverted;
  final double totalRevenue;
  final double roiPercentage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Campaign({
    required this.campaignId,
    required this.agentId,
    required this.campaignName,
    required this.campaignType,
    this.campaignGoal,
    this.description,
    this.subject,
    required this.message,
    required this.status,
    this.totalSent = 0,
    this.totalDelivered = 0,
    this.totalOpened = 0,
    this.totalClicked = 0,
    this.totalConverted = 0,
    this.totalRevenue = 0.0,
    this.roiPercentage = 0.0,
    this.createdAt,
    this.updatedAt,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      campaignId: json['campaign_id'] ?? json['data']?['campaign_id'] ?? '',
      agentId: json['agent_id'] ?? json['data']?['agent_id'] ?? '',
      campaignName: json['campaign_name'] ?? json['data']?['campaign_name'] ?? '',
      campaignType: json['campaign_type'] ?? json['data']?['campaign_type'] ?? '',
      campaignGoal: json['campaign_goal'] ?? json['data']?['campaign_goal'],
      description: json['description'] ?? json['data']?['description'],
      subject: json['subject'] ?? json['data']?['subject'],
      message: json['message'] ?? json['data']?['message'] ?? '',
      status: json['status'] ?? json['data']?['status'] ?? 'draft',
      totalSent: json['total_sent'] ?? json['data']?['total_sent'] ?? 0,
      totalDelivered: json['total_delivered'] ?? json['data']?['total_delivered'] ?? 0,
      totalOpened: json['total_opened'] ?? json['data']?['total_opened'] ?? 0,
      totalClicked: json['total_clicked'] ?? json['data']?['total_clicked'] ?? 0,
      totalConverted: json['total_converted'] ?? json['data']?['total_converted'] ?? 0,
      totalRevenue: (json['total_revenue'] ?? json['data']?['total_revenue'] ?? 0).toDouble(),
      roiPercentage: (json['roi_percentage'] ?? json['data']?['roi_percentage'] ?? 0).toDouble(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'campaign_name': campaignName,
      'campaign_type': campaignType,
      'campaign_goal': campaignGoal,
      'description': description,
      'subject': subject,
      'message': message,
      'status': status,
    };
  }
}

class CampaignTemplate {
  final String templateId;
  final String templateName;
  final String? description;
  final String category;
  final String? subjectTemplate;
  final String messageTemplate;
  final List<String> personalizationTags;
  final int usageCount;
  final double averageRoi;

  CampaignTemplate({
    required this.templateId,
    required this.templateName,
    this.description,
    required this.category,
    this.subjectTemplate,
    required this.messageTemplate,
    this.personalizationTags = const [],
    this.usageCount = 0,
    this.averageRoi = 0.0,
  });

  factory CampaignTemplate.fromJson(Map<String, dynamic> json) {
    return CampaignTemplate(
      templateId: json['template_id'] ?? json['data']?['template_id'] ?? '',
      templateName: json['template_name'] ?? json['data']?['template_name'] ?? '',
      description: json['description'] ?? json['data']?['description'],
      category: json['category'] ?? json['data']?['category'] ?? '',
      subjectTemplate: json['subject_template'] ?? json['data']?['subject_template'],
      messageTemplate: json['message_template'] ?? json['data']?['message_template'] ?? '',
      personalizationTags: List<String>.from(json['personalization_tags'] ?? json['data']?['personalization_tags'] ?? []),
      usageCount: json['usage_count'] ?? json['data']?['usage_count'] ?? 0,
      averageRoi: (json['average_roi'] ?? json['data']?['average_roi'] ?? 0).toDouble(),
    );
  }
}

