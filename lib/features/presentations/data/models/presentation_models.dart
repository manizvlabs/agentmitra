/// Presentation data models

class PresentationTemplate {
  final String templateId;
  final String name;
  final String description;
  final String category;
  final bool isPublic;
  final String? thumbnailUrl;
  final List<PresentationSlide> slides;

  PresentationTemplate({
    required this.templateId,
    required this.name,
    required this.description,
    required this.category,
    required this.isPublic,
    this.thumbnailUrl,
    required this.slides,
  });

  factory PresentationTemplate.fromJson(Map<String, dynamic> json) {
    return PresentationTemplate(
      templateId: json['template_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      isPublic: json['is_public'] ?? false,
      thumbnailUrl: json['thumbnail_url'],
      slides: (json['slides'] as List<dynamic>?)
          ?.map((slide) => PresentationSlide.fromJson(slide))
          .toList() ?? [],
    );
  }
}

class PresentationSlide {
  final String? type;
  final String? layout;
  final String? title;
  final String? content;
  final String? imageUrl;
  final String? videoUrl;
  final Map<String, dynamic>? metadata;

  PresentationSlide({
    this.type,
    this.layout,
    this.title,
    this.content,
    this.imageUrl,
    this.videoUrl,
    this.metadata,
  });

  factory PresentationSlide.fromJson(Map<String, dynamic> json) {
    return PresentationSlide(
      type: json['type'],
      layout: json['layout'],
      title: json['title'],
      content: json['content'],
      imageUrl: json['image_url'],
      videoUrl: json['video_url'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (type != null) 'type': type,
      if (layout != null) 'layout': layout,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (imageUrl != null) 'image_url': imageUrl,
      if (videoUrl != null) 'video_url': videoUrl,
      if (metadata != null) 'metadata': metadata,
    };
  }
}

class Presentation {
  final String presentationId;
  final String agentId;
  final String title;
  final String? description;
  final String status;
  final List<PresentationSlide> slides;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? analytics;

  Presentation({
    required this.presentationId,
    required this.agentId,
    required this.title,
    this.description,
    required this.status,
    required this.slides,
    required this.createdAt,
    required this.updatedAt,
    this.analytics,
  });

  factory Presentation.fromJson(Map<String, dynamic> json) {
    return Presentation(
      presentationId: json['presentation_id'] ?? '',
      agentId: json['agent_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      status: json['status'] ?? 'draft',
      slides: (json['slides'] as List<dynamic>?)
          ?.map((slide) => PresentationSlide.fromJson(slide))
          .toList() ?? [],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      analytics: json['analytics'],
    );
  }
}

class PresentationAnalytics {
  final String presentationId;
  final int views;
  final int shares;
  final double averageTimeSpent;
  final Map<String, int> slideViews;
  final DateTime lastViewed;

  PresentationAnalytics({
    required this.presentationId,
    required this.views,
    required this.shares,
    required this.averageTimeSpent,
    required this.slideViews,
    required this.lastViewed,
  });

  factory PresentationAnalytics.fromJson(Map<String, dynamic> json) {
    return PresentationAnalytics(
      presentationId: json['presentation_id'] ?? '',
      views: json['views'] ?? 0,
      shares: json['shares'] ?? 0,
      averageTimeSpent: (json['average_time_spent'] ?? 0.0).toDouble(),
      slideViews: Map<String, int>.from(json['slide_views'] ?? {}),
      lastViewed: DateTime.parse(json['last_viewed'] ?? DateTime.now().toIso8601String()),
    );
  }
}
