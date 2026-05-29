import '../models/user_model.dart';
import 'api_service.dart';

class UserService {
  final ApiService _api;

  UserService({ApiService? api}) : _api = api ?? ApiService();

  Future<UserModel?> getProfile() async {
    final response = await _api.get<UserModel>(
      path: '/auth/profile',
      fromJson: (data) => UserModel.fromJson(data),
    );
    if (response.code == 0 && response.data != null) {
      return response.data;
    }
    return null;
  }

  Future<UserModel?> updateProfile({String? nickname, String? bio}) async {
    final response = await _api.put<UserModel>(
      path: '/auth/profile',
      data: {
        if (nickname != null) 'nickname': nickname,
        if (bio != null) 'bio': bio,
      },
      fromJson: (data) => UserModel.fromJson(data),
    );
    if (response.code == 0 && response.data != null) {
      return response.data;
    }
    return null;
  }

  Future<UserStats?> getUserStats() async {
    final response = await _api.get<UserStats>(
      path: '/auth/stats',
      fromJson: (data) => UserStats.fromJson(data),
    );
    if (response.code == 0 && response.data != null) {
      return response.data;
    }
    return null;
  }
}

class UserStats {
  final int artworksCount;
  final int likesCount;
  final int favoritesCount;
  final int followingCount;

  const UserStats({
    this.artworksCount = 0,
    this.likesCount = 0,
    this.favoritesCount = 0,
    this.followingCount = 0,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      artworksCount: json['artworksCount'] as int? ?? 0,
      likesCount: json['likesCount'] as int? ?? 0,
      favoritesCount: json['favoritesCount'] as int? ?? 0,
      followingCount: json['followingCount'] as int? ?? 0,
    );
  }
}
