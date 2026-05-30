import '../models/artwork_model.dart';
import '../models/comment_model.dart';
import 'api_service.dart';

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
    return (<ArtworkModel>[], false);
  }

  Future<(List<ArtworkModel>, bool)> getMyArtworks({
    int page = 1,
    int size = 20,
  }) async {
    final response = await _api.get<List<ArtworkModel>>(
      path: '/artworks/my',
      queryParameters: {'page': page, 'size': size},
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
    return (<ArtworkModel>[], false);
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

  Future<List<String>> getTags() async {
    final response = await _api.get<List<String>>(
      path: '/artworks/tags',
      fromJson: (data) {
        return (data['items'] as List).map((e) => e.toString()).toList();
      },
    );
    if (response.code == 0 && response.data != null) {
      return response.data!;
    }
    return [];
  }
}