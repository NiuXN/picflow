import 'package:flutter/material.dart';
import '../../../theme/app_typography.dart';
import 'watermark_panel_widgets.dart';

class WatermarkPanel extends StatelessWidget {
  const WatermarkPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const WatermarkInput(),
        const SizedBox(height: 20),
        _sectionLabel('字体样式'),
        const SizedBox(height: 12),
        const FontSelector(),
        const SizedBox(height: 20),
        _sectionLabel('水印位置'),
        const SizedBox(height: 12),
        const PositionSelector(),
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
