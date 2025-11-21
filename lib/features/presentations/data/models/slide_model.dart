/// Slide data model
class SlideModel {
  final String? slideId;
  final int slideOrder;
  final String slideType; // 'image', 'video', 'text'
  final String? mediaUrl;
  final String? thumbnailUrl;
  final String? title;
  final String? subtitle;
  final String textColor;
  final String backgroundColor;
  final String layout; // 'centered', 'top', 'bottom', 'left', 'right'
  final int duration; // seconds
  final Map<String, dynamic>? ctaButton;
  final Map<String, dynamic>? agentBranding;

  SlideModel({
    this.slideId,
    required this.slideOrder,
    required this.slideType,
    this.mediaUrl,
    this.thumbnailUrl,
    this.title,
    this.subtitle,
    this.textColor = '#FFFFFF',
    this.backgroundColor = '#000000',
    this.layout = 'centered',
    this.duration = 4,
    this.ctaButton,
    this.agentBranding,
  });

  factory SlideModel.fromJson(Map<String, dynamic> json) {
    return SlideModel(
      slideId: json['slide_id'] ?? json['slideId'],
      slideOrder: json['slide_order'] ?? json['slideOrder'] ?? 0,
      slideType: json['slide_type'] ?? json['slideType'] ?? 'text',
      mediaUrl: json['media_url'] ?? json['mediaUrl'],
      thumbnailUrl: json['thumbnail_url'] ?? json['thumbnailUrl'],
      title: json['title'],
      subtitle: json['subtitle'],
      textColor: json['text_color'] ?? json['textColor'] ?? '#FFFFFF',
      backgroundColor:
          json['background_color'] ?? json['backgroundColor'] ?? '#000000',
      layout: json['layout'] ?? 'centered',
      duration: json['duration'] ?? 4,
      ctaButton: json['cta_button'] ?? json['ctaButton'],
      agentBranding: json['agent_branding'] ?? json['agentBranding'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (slideId != null) 'slide_id': slideId,
      'slide_order': slideOrder,
      'slide_type': slideType,
      if (mediaUrl != null) 'media_url': mediaUrl,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (title != null) 'title': title,
      if (subtitle != null) 'subtitle': subtitle,
      'text_color': textColor,
      'background_color': backgroundColor,
      'layout': layout,
      'duration': duration,
      if (ctaButton != null) 'cta_button': ctaButton,
      if (agentBranding != null) 'agent_branding': agentBranding,
    };
  }

  SlideModel copyWith({
    String? slideId,
    int? slideOrder,
    String? slideType,
    String? mediaUrl,
    String? thumbnailUrl,
    String? title,
    String? subtitle,
    String? textColor,
    String? backgroundColor,
    String? layout,
    int? duration,
    Map<String, dynamic>? ctaButton,
    Map<String, dynamic>? agentBranding,
  }) {
    return SlideModel(
      slideId: slideId ?? this.slideId,
      slideOrder: slideOrder ?? this.slideOrder,
      slideType: slideType ?? this.slideType,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      textColor: textColor ?? this.textColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      layout: layout ?? this.layout,
      duration: duration ?? this.duration,
      ctaButton: ctaButton ?? this.ctaButton,
      agentBranding: agentBranding ?? this.agentBranding,
    );
  }
}

