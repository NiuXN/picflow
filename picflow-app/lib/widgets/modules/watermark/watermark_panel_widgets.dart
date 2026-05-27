import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/watermark_model.dart';
import '../../../providers/editor_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

class WatermarkInput extends ConsumerWidget {
  const WatermarkInput({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorNotifier = ref.read(editorProvider.notifier);

    return TextField(
      onChanged: (value) => editorNotifier.setWatermarkText(value),
      decoration: InputDecoration(
        hintText: '输入水印文字，如 @我的生活手记',
        hintStyle: AppTypography.bodyRegular.copyWith(color: AppColors.onSurfaceVariant),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.inversePrimary, width: 2),
        ),
        contentPadding: const EdgeInsets.all(14),
      ),
      style: AppTypography.bodyRegular,
    );
  }
}

class FontSelector extends ConsumerWidget {
  const FontSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref.watch(editorProvider);
    final editorNotifier = ref.read(editorProvider.notifier);

    return Row(
      children: WatermarkFont.values.map((font) {
        final isActive = editorState.watermark.font == font;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: GestureDetector(
            onTap: () => editorNotifier.setWatermarkFont(font),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isActive ? AppColors.inversePrimary : AppColors.background,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _fontLabel(font),
                  style: TextStyle(
                    fontSize: 13,
                    color: isActive ? AppColors.surfaceContainerLowest : AppColors.onSurfaceVariant,
                    fontFamily: _fontFamily(font),
                    fontWeight: FontWeight.w600,
                    fontStyle: font == WatermarkFont.script ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _fontLabel(WatermarkFont font) {
    switch (font) {
      case WatermarkFont.sans:
        return 'A';
      case WatermarkFont.script:
        return 'a';
      case WatermarkFont.typewriter:
        return 'A';
    }
  }

  String _fontFamily(WatermarkFont font) {
    switch (font) {
      case WatermarkFont.sans:
        return 'NunitoSans';
      case WatermarkFont.script:
        return 'Georgia';
      case WatermarkFont.typewriter:
        return 'Courier';
    }
  }
}

class PositionSelector extends ConsumerWidget {
  const PositionSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref.watch(editorProvider);
    final editorNotifier = ref.read(editorProvider.notifier);

    return Row(
      children: WatermarkPosition.values.map((position) {
        final isActive = editorState.watermark.position == position;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: GestureDetector(
              onTap: () => editorNotifier.setWatermarkPosition(position),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.inversePrimary : AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomPaint(
                  size: const Size(20, 20),
                  painter: _PositionIconPainter(position: position, isActive: isActive),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PositionIconPainter extends CustomPainter {
  final WatermarkPosition position;
  final bool isActive;

  _PositionIconPainter({required this.position, required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    final rectPaint = Paint()
      ..color = isActive ? AppColors.surfaceContainerLowest : AppColors.onSurface
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final linePaint = Paint()
      ..color = isActive ? AppColors.surfaceContainerLowest : AppColors.onSurface
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(3),
    );
    canvas.drawRRect(rect, rectPaint);

    double startX;
    double endX;
    switch (position) {
      case WatermarkPosition.bottomLeft:
        startX = 3;
        endX = size.width * 0.4;
        break;
      case WatermarkPosition.bottomCenter:
        startX = size.width * 0.25;
        endX = size.width * 0.75;
        break;
      case WatermarkPosition.bottomRight:
        startX = size.width * 0.6;
        endX = size.width - 3;
        break;
    }
    canvas.drawLine(
      Offset(startX, size.height - 4),
      Offset(endX, size.height - 4),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _PositionIconPainter oldDelegate) =>
      isActive != oldDelegate.isActive;
}
