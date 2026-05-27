import 'package:flutter/material.dart';
import '../../providers/square_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class SortFilterBar extends StatelessWidget {
  final SquareSort currentSort;
  final ValueChanged<SquareSort> onSortChanged;

  const SortFilterBar({
    super.key,
    required this.currentSort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.surfaceContainerLowest,
      child: Row(
        children: [
          _sortChip('推荐', SquareSort.featured),
          const SizedBox(width: 8),
          _sortChip('最新', SquareSort.latest),
          const SizedBox(width: 8),
          _sortChip('热门', SquareSort.trending),
        ],
      ),
    );
  }

  Widget _sortChip(String label, SquareSort sort) {
    final isActive = currentSort == sort;
    return GestureDetector(
      onTap: () => onSortChanged(sort),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.inversePrimary : AppColors.background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: isActive ? AppColors.surfaceContainerLowest : AppColors.onSurface,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}