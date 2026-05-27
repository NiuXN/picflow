/// 通知/公告数据模型，对应后端 notifications 表
class NotificationModel {
  final int id;                    // 通知ID
  final String title;              // 通知标题
  final String? content;           // 通知内容
  final String target;             // 推送目标：all/用户ID
  final DateTime? createdAt;       // 发布时间

  const NotificationModel({
    required this.id,
    required this.title,
    this.content,
    this.target = 'all',
    this.createdAt,
  });

  /// 从后端 API JSON 响应创建实例
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String?,
      target: json['target'] as String? ?? 'all',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }
}
