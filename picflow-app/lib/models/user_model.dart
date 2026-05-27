/// 用户数据模型，对应后端 users 表
class UserModel {
  final int id;                  // 用户ID
  final String username;         // 用户名
  final String? nickname;        // 昵称
  final String? avatarUrl;       // 头像URL
  final String? bio;             // 个人简介
  final String role;             // 角色：user/admin
  final String status;           // 状态：active/banned
  final DateTime? createdAt;     // 注册时间

  const UserModel({
    required this.id,
    required this.username,
    this.nickname,
    this.avatarUrl,
    this.bio,
    this.role = 'user',
    this.status = 'active',
    this.createdAt,
  });

  /// 从后端 API JSON 响应创建实例
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      username: json['username'] as String,
      nickname: json['nickname'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      role: json['role'] as String? ?? 'user',
      status: json['status'] as String? ?? 'active',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  /// 转为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'nickname': nickname,
      'avatar_url': avatarUrl,
      'bio': bio,
      'role': role,
      'status': status,
    };
  }
}
