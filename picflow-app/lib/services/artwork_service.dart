import '../models/artwork_model.dart';
import '../models/comment_model.dart';
import 'api_service.dart';

/// 作品服务：作品列表/详情/发布/评论 API 调用（含 mock 兜底）
class ArtworkService {
  final ApiService _api;

  ArtworkService({ApiService? api}) : _api = api ?? ApiService();

  Future<(List<ArtworkModel>, bool)> getArtworks({
    int page = 1,
    int size = 20,
    String sort = 'latest',
    String? tag,
  }) async {
    final response = await _api.get<List<ArtworkModel>>(
      path: '/artworks',
      queryParameters: {
        'page': page,
        'size': size,
        'sort': sort,
        if (tag != null) 'tag': tag,
      },
      fromJson: (data) {
        final items = (data['items'] as List)
            .map((e) => ArtworkModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return items;
      },
    );

    if (response.code == 0 && response.data != null) {
      final hasMore = response.data!.length >= size;
      return (response.data!, hasMore);
    }
    return (mockArtworks(page), false);
  }

  Future<ArtworkModel?> getArtwork(int id) async {
    final response = await _api.get<ArtworkModel>(
      path: '/artworks/$id',
      fromJson: (data) => ArtworkModel.fromJson(data),
    );
    return response.data;
  }

  Future<bool> publishArtwork(Map<String, dynamic> data) async {
    final response = await _api.post<dynamic>(
      path: '/artworks',
      data: data,
      fromJson: (_) => true,
    );
    return response.code == 0;
  }

  Future<List<CommentModel>> getComments(int artworkId, {int page = 1}) async {
    final response = await _api.get<List<CommentModel>>(
      path: '/artworks/$artworkId/comments',
      queryParameters: {'page': page},
      fromJson: (data) {
        final items = (data['items'] as List)
            .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return items;
      },
    );

    if (response.code == 0 && response.data != null) {
      return response.data!;
    }
    return [];
  }

  Future<bool> postComment(int artworkId, String content) async {
    final response = await _api.post<dynamic>(
      path: '/artworks/$artworkId/comments',
      data: {'content': content},
      fromJson: (_) => true,
    );
    return response.code == 0;
  }

  List<ArtworkModel> mockArtworks(int page) {
    return List.generate(6, (index) {
      final id = (page - 1) * 6 + index + 1;
      return ArtworkModel(
        id: id,
        userId: 1,
        title: '作品标题 $id',
        description: '这是一段作品描述，记录了创作时的灵感和心情',
        imageUrl: 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=minimal%20photography%20aesthetic%20calm&image_size=square',
        thumbnailUrl: 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=minimal%20photography%20aesthetic%20calm&image_size=portrait_4_3',
        tags: ['胶片', '治愈', '简约'],
        frameType: ['minimal', 'exif', 'polaroid', 'proFilm', 'circle'][index % 5],
        aspectRatio: ['3x4', '1x1', '9x16'][index % 3],
        likesCount: index * 10 + 5,
        favoritesCount: index * 3 + 1,
        commentsCount: index % 3,
        isLiked: index % 2 == 0,
        isFavorited: false,
      );
    });
  }
}