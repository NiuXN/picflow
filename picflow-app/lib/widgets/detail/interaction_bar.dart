import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class InteractionBar extends StatelessWidget {
  final int likesCount;
  final int favoritesCount;
  final int commentsCount;
  final bool isLiked;
  final bool isFavorited;
  final VoidCallback onLike;
  final VoidCallback onFavorite;

  const InteractionBar({
    super.key,
    required this.likesCount,
    required this.favoritesCount,
    required this.commentsCount,
    required this.isLiked,
    required this.isFavorited,
    required this.onLike,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: AppColors.surfaceContainerLowest,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _interactionItem(
            icon: isLiked ? Icons.favorite : Icons.favorite_border,
            label: '$likesCount',
            isActive: isLiked,
            activeColor: AppColors.leicaRed,
            onTap: onLike,
          ),
          _interactionItem(
            icon: isFavorited ? Icons.star : Icons.star_border,
            label: '$favoritesCount',
            isActive: isFavorited,
            activeColor: const Color(0xFFFFB800),
            onTap: onFavorite,
          ),
          _interactionItem(
            icon: Icons.chat_bubble_outline,
            label: '$commentsCount',
            isActive: false,
          ),
        ],
      ),
    );
  }

  Widget _interactionItem({
    required IconData icon,
    required String label,
    required bool isActive,
    Color activeColor = AppColors.inversePrimary,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 22,
            color: isActive ? activeColor : AppColors.onSurface,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: isActive ? activeColor : AppColors.onSurface,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}