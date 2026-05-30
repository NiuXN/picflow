class TemplateConfig {
  final String frameType;
  final String aspectRatio;
  final String? bgColor;
  final String? watermarkText;
  final String? watermarkFont;
  final String? watermarkPosition;
  final String filter;

  const TemplateConfig({
    required this.frameType,
    required this.aspectRatio,
    this.bgColor,
    this.watermarkText,
    this.watermarkFont,
    this.watermarkPosition,
    this.filter = 'none',
  });

  factory TemplateConfig.fromJson(Map<String, dynamic> json) {
    return TemplateConfig(
      frameType: json['frame_type'] as String,
      aspectRatio: json['aspect_ratio'] as String,
      bgColor: json['bg_color'] as String?,
      watermarkText: json['watermark_text'] as String?,
      watermarkFont: json['watermark_font'] as String?,
      watermarkPosition: json['watermark_position'] as String?,
      filter: json['filter'] as String? ?? 'none',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'frame_type': frameType,
      'aspect_ratio': aspectRatio,
      if (bgColor != null) 'bg_color': bgColor,
      if (watermarkText != null) 'watermark_text': watermarkText,
      if (watermarkFont != null) 'watermark_font': watermarkFont,
      if (watermarkPosition != null) 'watermark_position': watermarkPosition,
      'filter': filter,
    };
  }
}

class TemplateModel {
  final int id;
  final String name;
  final String? description;
  final String previewUrl;
  final String? thumbnailUrl;
  final String category;
  final List<String> tags;
  final TemplateConfig config;
  final int useCount;
  final bool isLocal;

  const TemplateModel({
    required this.id,
    required this.name,
    this.description,
    required this.previewUrl,
    this.thumbnailUrl,
    required this.category,
    this.tags = const [],
    required this.config,
    this.useCount = 0,
    this.isLocal = true,
  });

  factory TemplateModel.fromJson(Map<String, dynamic> json) {
    return TemplateModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      previewUrl: json['preview_url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      category: json['category'] as String,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : [],
      config: TemplateConfig.fromJson(json['config'] as Map<String, dynamic>),
      useCount: json['use_count'] as int? ?? 0,
      isLocal: json['is_local'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'preview_url': previewUrl,
      'thumbnail_url': thumbnailUrl,
      'category': category,
      'tags': tags,
      'config': config.toJson(),
      'use_count': useCount,
      'is_local': isLocal,
    };
  }
}
