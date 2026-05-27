import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/artwork_model.dart';
import '../models/comment_model.dart';
import '../services/artwork_service.dart';
import '../services/social_service.dart';
import 'artwork_service_provider.dart';

final artworkDetailProvider = StateNotifierProvider.family<
    ArtworkDetailNotifier, ArtworkDetailState, int>(
  (ref, artworkId) {
    return ArtworkDetailNotifier(
      ref.read(artworkServiceProvider),
      ref.read(socialServiceProvider),
      artworkId,
    );
  },
);

class ArtworkDetailState {
  final ArtworkModel? artwork;
  final List<CommentModel> comments;
  final bool isLoading;
  final String? error;

  const ArtworkDetailState({
    this.artwork,
    this.comments = const [],
    this.isLoading = false,
    this.error,
  });

  ArtworkDetailState copyWith({
    ArtworkModel? artwork,
    List<CommentModel>? comments,
    bool? isLoading,
    String? error,
  }) {
    return ArtworkDetailState(
      artwork: artwork ?? this.artwork,
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ArtworkDetailNotifier extends StateNotifier<ArtworkDetailState> {
  final ArtworkService _artworkService;
  final SocialService _socialService;
  final int artworkId;

  ArtworkDetailNotifier(
    this._artworkService,
    this._socialService,
    this.artworkId,
  ) : super(const ArtworkDetailState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final artwork = await _artworkService.getArtwork(artworkId);
      final comments = await _artworkService.getComments(artworkId);

      state = state.copyWith(
        artwork: artwork,
        comments: comments,
        isLoading: false,
        error: artwork == null ? '作品不存在' : null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: '加载失败，请重试');
    }
  }

  Future<void> toggleLike() async {
    if (state.artwork == null) return;

    try {
      final artwork = state.artwork!;
      final success = await _socialService.toggleLike(artwork.id, artwork.isLiked);

      if (success) {
        state = state.copyWith(
          artwork: ArtworkModel(
            id: artwork.id,
            userId: artwork.userId,
            title: artwork.title,
            description: artwork.description,
            imageUrl: artwork.imageUrl,
            thumbnailUrl: artwork.thumbnailUrl,
            tags: artwork.tags,
            frameType: artwork.frameType,
            aspectRatio: artwork.aspectRatio,
            bgColor: artwork.bgColor,
            watermarkText: artwork.watermarkText,
            likesCount: artwork.isLiked ? artwork.likesCount - 1 : artwork.likesCount + 1,
            favoritesCount: artwork.favoritesCount,
            commentsCount: artwork.commentsCount,
            viewsCount: artwork.viewsCount,
            status: artwork.status,
            isFeatured: artwork.isFeatured,
            isLiked: !artwork.isLiked,
            isFavorited: artwork.isFavorited,
            author: artwork.author,
            createdAt: artwork.createdAt,
          ),
        );
      }
    } catch (_) {}
  }

  Future<void> toggleFavorite() async {
    if (state.artwork == null) return;

    try {
      final artwork = state.artwork!;
      final success = await _socialService.toggleFavorite(
        artwork.id,
        artwork.isFavorited,
      );

      if (success) {
        state = state.copyWith(
          artwork: ArtworkModel(
            id: artwork.id,
            userId: artwork.userId,
            title: artwork.title,
            description: artwork.description,
            imageUrl: artwork.imageUrl,
            thumbnailUrl: artwork.thumbnailUrl,
            tags: artwork.tags,
            frameType: artwork.frameType,
            aspectRatio: artwork.aspectRatio,
            bgColor: artwork.bgColor,
            watermarkText: artwork.watermarkText,
            likesCount: artwork.likesCount,
            favoritesCount: artwork.isFavorited ? artwork.favoritesCount - 1 : artwork.favoritesCount + 1,
            commentsCount: artwork.commentsCount,
            viewsCount: artwork.viewsCount,
            status: artwork.status,
            isFeatured: artwork.isFeatured,
            isLiked: artwork.isLiked,
            isFavorited: !artwork.isFavorited,
            author: artwork.author,
            createdAt: artwork.createdAt,
          ),
        );
      }
    } catch (_) {}
  }

  Future<void> postComment(String content) async {
    try {
      await _artworkService.postComment(artworkId, content);
      load();
    } catch (_) {}
  }
}