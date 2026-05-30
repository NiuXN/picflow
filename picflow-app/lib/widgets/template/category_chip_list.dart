import 'package:flutter/material.dart';
import '../../providers/template_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class CategoryChipList extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<String?> onCategorySelected;

  const CategoryChipList({
    super.key,
    this.selectedCategory,
    required this.onCategorySelected,
  });

  static const _categories = [
    (key: null, label: '全部'),
    (key: 'minimal', label: '极简'),
    (key: 'film', label: '胶片'),
    (key: 'polaroid', label: '拍立得'),
    (key: 'creative', label: '创意'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = selectedCategory == cat.key;

          return GestureDetector(
            onTap: () => onCategorySelected(cat.key),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.inversePrimary
                    : AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.inversePrimary
                      : AppColors.outlineVariant,
                  width: 1,
                ),
              ),
              child: Text(
                cat.label,
                style: AppTypography.labelMedium.copyWith(
                  color: isSelected
                      ? AppColors.surfaceContainerLowest
                      : AppColors.onSurface,
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

class TemplateSortBar extends StatelessWidget {
  final TemplateSort currentSort;
  final ValueChanged<TemplateSort> onSortChanged;

  const TemplateSortBar({
    super.key,
    required this.currentSort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Row(
        children: TemplateSort.values.map((sort) {
          final isActive = currentSort == sort;
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => onSortChanged(sort),
              child: Text(
                _sortLabel(sort),
                style: AppTypography.labelMedium.copyWith(
                  color: isActive
                      ? AppColors.onSurface
                      : AppColors.onSurfaceVariant,
                  fontWeight:
                      isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _sortLabel(TemplateSort sort) {
    switch (sort) {
      case TemplateSort.latest:
        return '最新';
      case TemplateSort.trending:
        return '热门';
      case TemplateSort.featured:
        return '精选';
    }
  }
}
