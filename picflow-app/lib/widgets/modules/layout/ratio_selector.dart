import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/layout_model.dart';
import '../../../providers/editor_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../utils/color_utils.dart';

class RatioSelector extends ConsumerWidget {
  const RatioSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref.watch(editorProvider);
    final editorNotifier = ref.read(editorProvider.notifier);

    return Row(
      children: CanvasAspectRatio.values.map((ratio) {
        final isActive = editorState.layout.aspectRatio == ratio;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: GestureDetector(
              onTap: () => editorNotifier.setAspectRatio(ratio),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.inversePrimary : AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      LayoutModel.ratioLabel(ratio),
                      style: AppTypography.labelMedium.copyWith(
                        color: isActive ? AppColors.surfaceContainerLowest : AppColors.onSurfaceVariant,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      LayoutModel.ratioSubLabel(ratio),
                      style: TextStyle(
                        fontSize: 10,
                        color: isActive
                            ? AppColors.surfaceContainerLowest.withValues(alpha: 0.7)
                            : AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class GridToggle extends ConsumerWidget {
  const GridToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref.watch(editorProvider);
    final editorNotifier = ref.read(editorProvider.notifier);
    final isOn = editorState.layout.showGrid;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '九宫格辅助线',
          style: AppTypography.bodyRegular.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        GestureDetector(
          onTap: () => editorNotifier.toggleGrid(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 48,
            height: 28,
            decoration: BoxDecoration(
              color: isOn ? AppColors.inversePrimary : AppColors.background,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: isOn ? AppColors.inversePrimary : AppColors.background,
                width: 2,
              ),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 150),
              alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 22,
                height: 22,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ColorPicker extends ConsumerWidget {
  const ColorPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref.watch(editorProvider);
    final editorNotifier = ref.read(editorProvider.notifier);
    final selectedIndex = editorState.layout.backgroundColorIndex;

    return Row(
      children: List.generate(ColorUtils.backgroundColors.length, (index) {
        final color = ColorUtils.backgroundColors[index];
        final isSelected = selectedIndex == index;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7),
          child: GestureDetector(
            onTap: () => editorNotifier.setBackgroundColorIndex(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: AppColors.onSurface, width: 2)
                    : color == AppColors.surfaceContainerLowest
                        ? Border.all(color: AppColors.outlineVariant, width: 2)
                        : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        );
      }),
    );
  }
}
