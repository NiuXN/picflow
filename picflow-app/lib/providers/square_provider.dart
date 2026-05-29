import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/artwork_model.dart';
import '../services/artwork_service.dart';
import '../services/social_service.dart';
import 'artwork_service_provider.dart';

enum SquareSort { latest, trending, featured }

class SquareState {
  final List<ArtworkModel> artworks;
  final bool isLoading;
  final bool isRefreshing;
  final bool hasMore;
  final SquareSort sort;
  final String? selectedTag;
  final String? error;

  const SquareState({
    this.artworks = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.hasMore = true,
    this.sort = SquareSort.latest,
    this.selectedTag,
    this.error,
  });

  SquareState copyWith({
    List<ArtworkModel>? artworks,
    bool? isLoading,
    bool? isRefreshing,
    bool? hasMore,
    SquareSort? sort,
    String? selectedTag,
    String? error,
  }) {
    return SquareState(
      artworks: artworks ?? this.artworks,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      hasMore: hasMore ?? this.hasMore,
      sort: sort ?? this.sort,
      selectedTag: selectedTag ?? this.selectedTag,
      error: error,
    );
  }
}

class SquareNotifier extends StateNotifier<SquareState> {
  final ArtworkService _service;
  final SocialService _socialService;
  int _page = 1;

  SquareNotifier(this._service, this._socialService) : super(const SquareState()) {
    loadArtworks();
  }

  Future<void> loadArtworks() async {
    state = state.copyWith(isLoading: true, error: null);
    _page = 1;

    try {
      final (artworks, hasMore) = await _service.getArtworks(
        page: _page,
        sort: state.sort.name,
        tag: state.selectedTag,
      );

      state = state.copyWith(
        artworks: artworks,
        isLoading: false,
        hasMore: hasMore,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: '加载失败，请重试');
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;

    _page++;
    try {
      final (artworks, hasMore) = await _service.getArtworks(
        page: _page,
        sort: state.sort.name,
        tag: state.selectedTag,
      );

      state = state.copyWith(
        artworks: [...state.artworks, ...artworks],
        hasMore: hasMore,
      );
    } catch (e) {
      _page--; // 回退页码
      state = state.copyWith(error: '加载更多失败');
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true, error: null);
    _page = 1;

    try {
      final (artworks, hasMore) = await _service.getArtworks(
        page: _page,
        sort: state.sort.name,
        tag: state.selectedTag,
      );

      state = state.copyWith(
        artworks: artworks,
        isRefreshing: false,
        hasMore: hasMore,
      );
    } catch (e) {
      state = state.copyWith(isRefreshing: false, error: '刷新失败');
    }
  }

  void changeSort(SquareSort newSort) {
    if (state.sort == newSort) return;
    state = state.copyWith(sort: newSort);
    loadArtworks();
  }

  void selectTag(String? tag) {
    state = state.copyWith(selectedTag: tag);
    loadArtworks();
  }

  Future<void> toggleLike(int artworkId, bool isLiked) async {
    try {
      await _socialService.toggleLike(artworkId, isLiked);
    } catch (_) {
      return; // API 失败则不更新 UI
    }
    state = state.copyWith(
      artworks: state.artworks.map((a) {
        if (a.id == artworkId) {
          return ArtworkModel(
            id: a.id,
            userId: a.userId,
            title: a.title,
            description: a.description,
            imageUrl: a.imageUrl,
            thumbnailUrl: a.thumbnailUrl,
            tags: a.tags,
            frameType: a.frameType,
            aspectRatio: a.aspectRatio,
            bgColor: a.bgColor,
            watermarkText: a.watermarkText,
            likesCount: isLiked ? a.likesCount - 1 : a.likesCount + 1,
            favoritesCount: a.favoritesCount,
            commentsCount: a.commentsCount,
            viewsCount: a.viewsCount,
            status: a.status,
            isFeatured: a.isFeatured,
            isLiked: !isLiked,
            isFavorited: a.isFavorited,
            author: a.author,
            createdAt: a.createdAt,
          );
        }
        return a;
      }).toList(),
    );
  }
}

final squareProvider = StateNotifierProvider<SquareNotifier, SquareState>((ref) {
  final artworkService = ref.read(artworkServiceProvider);
  final socialService = ref.read(socialServiceProvider);
  return SquareNotifier(artworkService, socialService);
});