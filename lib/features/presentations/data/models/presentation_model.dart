/// Presentation data model
import 'slide_model.dart';

class PresentationModel {
  final String? presentationId;
  final String agentId;
  final String name;
  final String? description;
  final String status; // 'draft', 'published', 'archived'
  final bool isActive;
  final List<SlideModel> slides;
  final String? templateId;
  final List<String> tags;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastUpdated;

  PresentationModel({
    this.presentationId,
    required this.agentId,
    required this.name,
    this.description,
    this.status = 'draft',
    this.isActive = false,
    this.slides = const [],
    this.templateId,
    this.tags = const [],
    this.createdAt,
    this.updatedAt,
    this.lastUpdated,
  });

  factory PresentationModel.fromJson(Map<String, dynamic> json) {
    return PresentationModel(
      presentationId:
          json['presentation_id'] ?? json['presentationId'],
      agentId: json['agent_id'] ?? json['agentId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      status: json['status'] ?? 'draft',
      isActive: json['is_active'] ?? json['isActive'] ?? false,
      slides: (json['slides'] as List<dynamic>?)
              ?.map((s) => SlideModel.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      templateId: json['template_id'] ?? json['templateId'],
      tags: (json['tags'] as List<dynamic>?)
              ?.map((t) => t.toString())
              .toList() ??
          [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (presentationId != null) 'presentation_id': presentationId,
      'agent_id': agentId,
      'name': name,
      if (description != null) 'description': description,
      'status': status,
      'is_active': isActive,
      'slides': slides.map((s) => s.toJson()).toList(),
      if (templateId != null) 'template_id': templateId,
      'tags': tags,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  PresentationModel copyWith({
    String? presentationId,
    String? agentId,
    String? name,
    String? description,
    String? status,
    bool? isActive,
    List<SlideModel>? slides,
    String? templateId,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PresentationModel(
      presentationId: presentationId ?? this.presentationId,
      agentId: agentId ?? this.agentId,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      slides: slides ?? this.slides,
      templateId: templateId ?? this.templateId,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

