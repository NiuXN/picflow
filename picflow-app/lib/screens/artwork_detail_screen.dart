import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/artwork_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/common/skeleton_grid.dart';
import '../widgets/detail/interaction_bar.dart';
import '../widgets/detail/comment_list.dart';

class ArtworkDetailScreen extends ConsumerStatefulWidget {
  final int artworkId;

  const ArtworkDetailScreen({super.key, required this.artworkId});

  @override
  ConsumerState<ArtworkDetailScreen> createState() => _ArtworkDetailScreenState();
}

class _ArtworkDetailScreenState extends ConsumerState<ArtworkDetailScreen> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detailState = ref.watch(artworkDetailProvider(widget.artworkId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '作品详情',
          style: AppTypography.labelLarge.copyWith(color: AppColors.onSurface),
        ),
        centerTitle: true,
      ),
      body: SafeArea(child: detailState.isLoading
          ? const ArtworkDetailSkeleton()
          : detailState.error != null || detailState.artwork == null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.image_outlined, size: 64, color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
                      const SizedBox(height: 12),
                      Text(detailState.error ?? '作品不存在', style: AppTypography.bodyRegular.copyWith(color: AppColors.onSurfaceVariant)),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => ref.read(artworkDetailProvider(widget.artworkId).notifier).load(),
                        child: Text('重试', style: AppTypography.labelMedium.copyWith(color: AppColors.inversePrimary)),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImageSection(detailState.artwork!),
                      _buildInfoSection(detailState.artwork!),
                      _buildMetaSection(detailState.artwork!),
                      _buildTagsSection(detailState.artwork!),
                      InteractionBar(
                        likesCount: detailState.artwork!.likesCount,
                        favoritesCount: detailState.artwork!.favoritesCount,
                        commentsCount: detailState.artwork!.commentsCount,
                        isLiked: detailState.artwork!.isLiked,
                        isFavorited: detailState.artwork!.isFavorited,
                        onLike: () {
                          ref.read(artworkDetailProvider(widget.artworkId).notifier).toggleLike();
                        },
                        onFavorite: () {
                          ref.read(artworkDetailProvider(widget.artworkId).notifier).toggleFavorite();
                        },
                      ),
                      const Divider(height: 1, thickness: 1, color: AppColors.outlineVariant),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                        child: Text(
                          '评论 (${detailState.artwork!.commentsCount})',
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      CommentList(comments: detailState.comments),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
      bottomSheet: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(context).padding.bottom + 12,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          boxShadow: [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 12,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: '写下你的评论...',
                  hintStyle: AppTypography.bodyRegular.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                if (_commentController.text.trim().isNotEmpty) {
                  ref.read(artworkDetailProvider(widget.artworkId).notifier)
                      .postComment(_commentController.text.trim());
                  _commentController.clear();
                }
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.inversePrimary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.send_rounded, color: AppColors.surfaceContainerLowest, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(artwork) {
    return Container(
      width: double.infinity,
      color: AppColors.surfaceContainerLowest,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            artwork.imageUrl,
            width: MediaQuery.of(context).size.width * 0.85,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: 300,
              color: AppColors.background,
              child: const Center(
                child: Icon(Icons.broken_image, color: AppColors.onSurfaceVariant, size: 48),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(artwork) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: AppColors.surfaceContainerLowest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            artwork.title,
            style: AppTypography.h2.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.inversePrimary,
                child: Text(
                  (artwork.author?.nickname?.isNotEmpty == true ? artwork.author!.nickname![0] : (artwork.author?.username?.isNotEmpty == true ? artwork.author!.username![0] : 'U')).toUpperCase(),
                  style: const TextStyle(color: AppColors.surfaceContainerLowest, fontSize: 14),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '@${artwork.author?.nickname ?? "用户"}',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (artwork.createdAt != null)
                Text(
                  _formatDate(artwork.createdAt!),
                  style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
                ),
            ],
          ),
          if (artwork.description != null && artwork.description!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              artwork.description!,
              style: AppTypography.bodyRegular.copyWith(
                color: AppColors.onSurface,
                height: 1.6,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetaSection(artwork) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: AppColors.background.withValues(alpha: 0.5),
      child: Row(
        children: [
          if (artwork.frameType != null) ...[
            _metaChip('📷', '相框：${_frameName(artwork.frameType!)}'),
            const SizedBox(width: 12),
          ],
          if (artwork.aspectRatio != null) ...[
            _metaChip('📐', '比例：${artwork.aspectRatio!}'),
            const SizedBox(width: 12),
          ],
          if (artwork.bgColor != null)
            _metaChip('🎨', '背景：${artwork.bgColor!}'),
        ],
      ),
    );
  }

  Widget _metaChip(String emoji, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$emoji $text',
        style: AppTypography.labelSmall.copyWith(color: AppColors.onSurface),
      ),
    );
  }

  Widget _buildTagsSection(artwork) {
    if (artwork.tags.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: AppColors.surfaceContainerLowest,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: artwork.tags.map<Widget>((tag) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.inversePrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '#$tag',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.inversePrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _frameName(String type) {
    switch (type) {
      case 'exif':
        return 'EXIF参数';
      case 'polaroid':
        return '拍立得';
      case 'proFilm':
        return '专业底片';
      case 'circle':
        return '圆形取景';
      case 'minimal':
      default:
        return '极简留白';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
    if (diff.inDays < 1) return '${diff.inHours}小时前';
    if (diff.inDays < 30) return '${diff.inDays}天前';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}