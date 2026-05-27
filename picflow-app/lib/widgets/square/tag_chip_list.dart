import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class TagChipList extends StatelessWidget {
  final String? selectedTag;
  final ValueChanged<String?> onTagSelected;

  const TagChipList({
    super.key,
    required this.selectedTag,
    required this.onTagSelected,
  });

  static const _tags = ['胶片', '治愈', '简约', '复古', '风景', '人物', '美食', '黑白'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _tags.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final tag = _tags[index];
          final isSelected = selectedTag == tag;
          return GestureDetector(
            onTap: () => onTagSelected(isSelected ? null : tag),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.inversePrimary : AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected ? AppColors.inversePrimary : AppColors.onSurfaceVariant.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                '#$tag',
                style: AppTypography.labelSmall.copyWith(
                  color: isSelected ? AppColors.surfaceContainerLowest : AppColors.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}