import 'api_service.dart';

/// 社交互动服务：点赞/收藏 API
class SocialService {
  final ApiService _api;

  SocialService({ApiService? api}) : _api = api ?? ApiService();

  Future<bool> toggleLike(int artworkId, bool isLiked) async {
    if (isLiked) {
      final response = await _api.delete<dynamic>(
        path: '/artworks/$artworkId/like',
        fromJson: (_) => true,
      );
      return response.code == 0;
    } else {
      final response = await _api.post<dynamic>(
        path: '/artworks/$artworkId/like',
        fromJson: (_) => true,
      );
      return response.code == 0;
    }
  }

  Future<bool> toggleFavorite(int artworkId, bool isFavorited) async {
    if (isFavorited) {
      final response = await _api.delete<dynamic>(
        path: '/artworks/$artworkId/favorite',
        fromJson: (_) => true,
      );
      return response.code == 0;
    } else {
      final response = await _api.post<dynamic>(
        path: '/artworks/$artworkId/favorite',
        fromJson: (_) => true,
      );
      return response.code == 0;
    }
  }
}