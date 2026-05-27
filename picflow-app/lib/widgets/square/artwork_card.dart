import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/artwork_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class ArtworkCard extends StatelessWidget {
  final ArtworkModel artwork;
  final VoidCallback? onTap;

  const ArtworkCard({
    super.key,
    required this.artwork,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => context.push('/artwork/${artwork.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                artwork.thumbnailUrl ?? artwork.imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) {
                  return progress == null ? child : Container(height: 180, color: AppColors.background);
                },
                errorBuilder: (_, __, ___) => Container(
                  height: 180,
                  color: AppColors.background,
                  child: const Center(
                    child: Icon(Icons.image, color: AppColors.onSurfaceVariant),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    artwork.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${artwork.author?.nickname ?? "用户"}',
                    style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        artwork.isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 14,
                        color: artwork.isLiked ? AppColors.leicaRed : AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${artwork.likesCount}',
                        style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.star_border, size: 14, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        '${artwork.favoritesCount}',
                        style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}