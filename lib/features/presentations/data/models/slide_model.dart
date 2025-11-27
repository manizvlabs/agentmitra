/// Slide data model
class SlideModel {
  final String? slideId;
  final int slideOrder;
  final String slideType; // 'image', 'video', 'text'
  final String? mediaUrl;
  final String? mediaType; // 'image', 'video' - explicit media type
  final String? thumbnailUrl;
  final String? title;
  final String? subtitle;
  final String? description;
  final String textColor;
  final String backgroundColor;
  final double overlayOpacity; // 0.0 to 1.0
  final String layout; // 'centered', 'top', 'bottom', 'left', 'right'
  final int duration; // seconds
  final Map<String, dynamic>? ctaButton;
  final Map<String, dynamic>? agentBranding;

  SlideModel({
    this.slideId,
    required this.slideOrder,
    required this.slideType,
    this.mediaUrl,
    this.mediaType,
    this.thumbnailUrl,
    this.title,
    this.subtitle,
    this.description,
    this.textColor = '#FFFFFF',
    this.backgroundColor = '#000000',
    this.overlayOpacity = 0.5,
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
      mediaType: json['media_type'] ?? json['mediaType'],
      thumbnailUrl: json['thumbnail_url'] ?? json['thumbnailUrl'],
      title: json['title'],
      subtitle: json['subtitle'],
      description: json['description'],
      textColor: json['text_color'] ?? json['textColor'] ?? '#FFFFFF',
      backgroundColor:
          json['background_color'] ?? json['backgroundColor'] ?? '#000000',
      overlayOpacity: (json['overlay_opacity'] ?? json['overlayOpacity'] ?? 0.5) is double
          ? (json['overlay_opacity'] ?? json['overlayOpacity'] ?? 0.5) as double
          : ((json['overlay_opacity'] ?? json['overlayOpacity'] ?? 0.5) as num).toDouble(),
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
      if (mediaType != null) 'media_type': mediaType,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (title != null) 'title': title,
      if (subtitle != null) 'subtitle': subtitle,
      if (description != null) 'description': description,
      'text_color': textColor,
      'background_color': backgroundColor,
      'overlay_opacity': overlayOpacity,
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
    String? mediaType,
    String? thumbnailUrl,
    String? title,
    String? subtitle,
    String? description,
    String? textColor,
    String? backgroundColor,
    double? overlayOpacity,
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
      mediaType: mediaType ?? this.mediaType,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      textColor: textColor ?? this.textColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      overlayOpacity: overlayOpacity ?? this.overlayOpacity,
      layout: layout ?? this.layout,
      duration: duration ?? this.duration,
      ctaButton: ctaButton ?? this.ctaButton,
      agentBranding: agentBranding ?? this.agentBranding,
    );
  }
}

