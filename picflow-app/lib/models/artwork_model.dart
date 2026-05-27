import 'user_model.dart';

/// 作品数据模型，对应后端 artworks 表
class ArtworkModel {
  final int id;                 // 作品ID
  final int userId;             // 作者用户ID
  final String title;           // 作品标题
  final String? description;    // 作品描述
  final String imageUrl;        // 原图URL
  final String? thumbnailUrl;   // 缩略图URL
  final List<String> tags;      // 标签列表
  final String? frameType;      // 相框类型：minimal/exif/polaroid/proFilm/circle
  final String? aspectRatio;    // 画面比例：3x4/1x1/9x16
  final String? bgColor;        // 背景色Hex
  final String? watermarkText;  // 水印文字
  final String? filter;         // 滤镜：none/cream/film/mono/warm/cool/retro
  final int likesCount;         // 点赞数
  final int favoritesCount;     // 收藏数
  final int commentsCount;      // 评论数
  final int viewsCount;         // 浏览数
  final String status;          // 状态：published/review/removed
  final bool isFeatured;        // 是否精选
  final bool isLiked;           // 当前用户是否已点赞
  final bool isFavorited;       // 当前用户是否已收藏
  final UserModel? author;      // 作者信息
  final DateTime? createdAt;    // 创建时间

  const ArtworkModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.imageUrl,
    this.thumbnailUrl,
    this.tags = const [],
    this.frameType,
    this.aspectRatio,
    this.bgColor,
    this.watermarkText,
    this.filter,
    this.likesCount = 0,
    this.favoritesCount = 0,
    this.commentsCount = 0,
    this.viewsCount = 0,
    this.status = 'published',
    this.isFeatured = false,
    this.isLiked = false,
    this.isFavorited = false,
    this.author,
    this.createdAt,
  });

  /// 从后端 API JSON 响应创建实例
  factory ArtworkModel.fromJson(Map<String, dynamic> json) {
    return ArtworkModel(
      id: json['id'] as int,
      userId: json['user_id'] as int? ?? 0,
      title: json['title'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : [],
      frameType: json['frame_type'] as String?,
      aspectRatio: json['aspect_ratio'] as String?,
      bgColor: json['bg_color'] as String?,
      watermarkText: json['watermark_text'] as String?,
      filter: json['filter'] as String?,
      likesCount: json['likes_count'] as int? ?? 0,
      favoritesCount: json['favorites_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      viewsCount: json['views_count'] as int? ?? 0,
      status: json['status'] as String? ?? 'published',
      isFeatured: json['is_featured'] as bool? ?? false,
      isLiked: json['is_liked'] as bool? ?? false,
      isFavorited: json['is_favorited'] as bool? ?? false,
      author: json['author'] != null
          ? UserModel.fromJson(json['author'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  /// 转为请求 JSON（发送给发布 API）
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'thumbnail_url': thumbnailUrl,
      'tags': tags,
      'frame_type': frameType,
      'aspect_ratio': aspectRatio,
      'bg_color': bgColor,
      'watermark_text': watermarkText,
      'filter': filter,
    };
  }
}
