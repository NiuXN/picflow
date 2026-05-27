import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/frame_model.dart';
import '../../../providers/editor_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_shadows.dart';
import '../../../theme/app_typography.dart';

class FrameCard extends ConsumerWidget {
  final FrameModel frame;

  const FrameCard({super.key, required this.frame});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref.watch(editorProvider);
    final isSelected = editorState.selectedFrame == frame.type;

    return _TapScale(
      onTap: () => ref.read(editorProvider.notifier).selectFrame(frame.type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: AppColors.inversePrimary, width: 2)
              : null,
        ),
        child: Column(
          children: [
            _buildPreview(),
            const SizedBox(height: 8),
            Text(
              frame.label,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              frame.subLabel,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return Container(
      width: 80,
      height: 90,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        boxShadow: AppShadows.cardShadows,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildFramePreview(),
          if (frame.type == FrameType.proFilm) ...[
            Positioned(
              top: 4,
              right: 6,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.leicaRed,
                ),
              ),
            ),
            Positioned(
              bottom: 4,
              left: 8,
              right: 8,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.inversePrimary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFramePreview() {
    switch (frame.type) {
      case FrameType.minimal:
      case FrameType.exif:
        return Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      case FrameType.polaroid:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 2),
            Container(
              width: 56,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        );
      case FrameType.proFilm:
        return Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      case FrameType.circle:
        return Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.background,
            shape: BoxShape.circle,
          ),
        );
    }
  }
}

class _TapScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _TapScale({required this.child, this.onTap});

  @override
  State<_TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<_TapScale> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.96),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: widget.child,
      ),
    );
  }
}
