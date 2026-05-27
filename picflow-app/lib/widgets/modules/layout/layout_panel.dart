import 'package:flutter/material.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_spacing.dart';
import 'ratio_selector.dart';

class LayoutPanel extends StatelessWidget {
  const LayoutPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('画面比例'),
        const SizedBox(height: AppSpacing.sm),
        const RatioSelector(),
        const SizedBox(height: AppSpacing.lg),
        const GridToggle(),
        const SizedBox(height: AppSpacing.lg),
        _sectionLabel('背景取色'),
        const SizedBox(height: AppSpacing.sm),
        const ColorPicker(),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: AppTypography.overline,
    );
  }
}
