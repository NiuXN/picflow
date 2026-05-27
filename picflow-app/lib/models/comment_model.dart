import 'user_model.dart';

/// 评论数据模型，支持嵌套回复
class CommentModel {
  final int id;                        // 评论ID
  final int userId;                    // 评论用户ID
  final int artworkId;                 // 所属作品ID
  final String content;                // 评论内容
  final int? parentId;                 // 父评论ID（支持回复）
  final String status;                 // 状态：published
  final UserModel? author;             // 评论作者
  final List<CommentModel> replies;    // 子回复列表
  final DateTime? createdAt;           // 评论时间

  const CommentModel({
    required this.id,
    required this.userId,
    required this.artworkId,
    required this.content,
    this.parentId,
    this.status = 'published',
    this.author,
    this.replies = const [],
    this.createdAt,
  });

  /// 从后端 API JSON 响应创建实例
  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as int,
      userId: json['user_id'] as int? ?? 0,
      artworkId: json['artwork_id'] as int? ?? 0,
      content: json['content'] as String,
      parentId: json['parent_id'] as int?,
      status: json['status'] as String? ?? 'published',
      author: json['author'] != null
          ? UserModel.fromJson(json['author'] as Map<String, dynamic>)
          : null,
      replies: json['replies'] != null
          ? (json['replies'] as List)
              .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }
}
