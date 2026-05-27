import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/filter_model.dart';
import '../../../providers/editor_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

class FilterPanel extends ConsumerWidget {
  const FilterPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref.watch(editorProvider);
    final editorNotifier = ref.read(editorProvider.notifier);
    final currentFilter = editorState.selectedFilter;

    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: FilterModel.presets.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final filter = FilterModel.presets[index];
          final isSelected = currentFilter == filter.type;

          return GestureDetector(
            onTap: () => editorNotifier.setFilter(filter.type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 80,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.inversePrimary : AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: isSelected ? Border.all(color: AppColors.inversePrimary, width: 2) : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPreview(filter.type, isSelected),
                  const SizedBox(height: 8),
                  Text(
                    filter.label,
                    style: AppTypography.labelSmall.copyWith(
                      color: isSelected ? AppColors.surfaceContainerLowest : AppColors.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    filter.subLabel,
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected ? AppColors.surfaceContainerLowest.withValues(alpha: 0.7) : AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPreview(FilterType type, bool isActive) {
    final color = isActive ? AppColors.surfaceContainerLowest : AppColors.onSurface;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _previewColor(type),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: _previewIcon(type, color),
    );
  }

  Color _previewColor(FilterType type) {
    switch (type) {
      case FilterType.none: return AppColors.surfaceContainerLowest;
      case FilterType.cream: return const Color(0xFFF5ECD7);
      case FilterType.film: return const Color(0xFFD4C5A9);
      case FilterType.mono: return const Color(0xFFB0B0B0);
      case FilterType.warm: return const Color(0xFFF0D5A0);
      case FilterType.cool: return const Color(0xFFA0C4E8);
      case FilterType.retro: return const Color(0xFFC9A96E);
    }
  }

  Widget _previewIcon(FilterType type, Color color) {
    return Center(
      child: Text(
        type == FilterType.none ? '1:1' : '',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color.withValues(alpha: 0.5)),
      ),
    );
  }
}
