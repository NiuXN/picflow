import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/filter_model.dart';
import '../../models/frame_model.dart';
import '../../models/image_model.dart';
import '../../models/layout_model.dart';
import '../../models/watermark_model.dart';
import '../../providers/config_provider.dart';
import '../../providers/editor_provider.dart';
import '../../providers/image_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../utils/color_utils.dart';

class CanvasArea extends ConsumerWidget {
  final bool showGrid;

  const CanvasArea({super.key, this.showGrid = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageState = ref.watch(imageProvider);
    final editorState = ref.watch(editorProvider);
    final colorIndex = editorState.layout.backgroundColorIndex.clamp(
      0, ColorUtils.backgroundColors.length - 1,
    );
    final bgColor = ColorUtils.backgroundColors[colorIndex];

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.softShadows,
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _buildCanvasContent(imageState, editorState, ref),
            ),
            if (showGrid) _buildGridOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvasContent(ImageModel imageState, EditorState editorState, WidgetRef ref) {
    if (!imageState.isLoaded || imageState.path == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_outlined,
              size: 48,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              '选中照片后在此预览',
              style: AppTypography.bodyRegular.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: _buildFramedImage(imageState, editorState, ref),
    );
  }

  Widget _buildFramedImage(ImageModel imageState, EditorState editorState, WidgetRef ref) {
    final rawImage = _buildImageWidget(imageState.path!);
    final filteredImage = _applyFilter(rawImage, editorState, ref);
    final image = _applyWatermark(filteredImage, editorState);

    switch (editorState.selectedFrame) {
      case FrameType.minimal:
        return _buildMinimalFrame(image, editorState);
      case FrameType.exif:
        return _buildExifFrame(image, editorState, imageState);
      case FrameType.polaroid:
        return _buildPolaroidFrame(image, editorState);
      case FrameType.proFilm:
        return _buildProFilmFrame(image, editorState);
      case FrameType.circle:
        return _buildCircleFrame(image, editorState);
    }
  }

  Widget _buildMinimalFrame(Widget image, EditorState editorState) {
    final padding = _framePadding(editorState.layout.aspectRatio);
    return Padding(
      padding: padding,
      child: AspectRatio(
        aspectRatio: _aspectRatioValue(editorState.layout.aspectRatio),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: image,
        ),
      ),
    );
  }

  Widget _buildExifFrame(Widget image, EditorState editorState, ImageModel imageState) {
    final padding = _framePadding(editorState.layout.aspectRatio);
    final exif = imageState.exifData ?? {};

    final camera = [_readExif(exif, 'Make'), _readExif(exif, 'Model')]
        .where((s) => s.isNotEmpty)
        .join(' ');
    final takenDate = _readExif(exif, 'DateTimeOriginal');
    final iso = _readExif(exif, 'ISOSpeedRatings');
    final aperture = _readExif(exif, 'FNumber');
    final shutter = _readExif(exif, 'ExposureTime');
    final focal = _readExif(exif, 'FocalLength');
    final dimensions = '${_readExif(exif, 'PixelXDimension')}\u00d7${_readExif(exif, 'PixelYDimension')}';

    final topLine = <String>[
      if (imageState.name != null && imageState.name!.isNotEmpty) imageState.name!,
      if (takenDate.isNotEmpty) takenDate,
    ].join(' · ');

    final bottomLine = <String>[
      if (camera.isNotEmpty) camera,
      if (focal.isNotEmpty) focal,
      if (aperture.isNotEmpty) 'f/$aperture',
      if (shutter.isNotEmpty && shutter.length < 8) '${shutter}s',
      if (iso.isNotEmpty) 'ISO $iso',
      if (dimensions.contains('\u00d7') && !dimensions.contains('\u00d70')) dimensions,
    ].join(' · ');

    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: _aspectRatioValue(editorState.layout.aspectRatio),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              child: image,
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (topLine.isNotEmpty)
                  Text(
                    topLine,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                if (bottomLine.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    bottomLine,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _readExif(Map<String, String> exif, String key) {
    final value = exif[key];
    if (value == null || value.isEmpty || value == 'null' || value == '0') return '';
    return value;
  }

  Widget _buildPolaroidFrame(Widget image, EditorState editorState) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
        color: AppColors.surfaceContainerLowest,
        child: AspectRatio(
          aspectRatio: 1.0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: image,
          ),
        ),
      ),
    );
  }

  Widget _buildProFilmFrame(Widget image, EditorState editorState) {
    final padding = _framePadding(editorState.layout.aspectRatio);

    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: _aspectRatioValue(editorState.layout.aspectRatio),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  child: image,
                ),
              ),
              Positioned(
                top: 8,
                right: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.leicaRed,
                  ),
                ),
              ),
            ],
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Container(
                    height: 3,
                    width: 40,
                    decoration: BoxDecoration(
                      color: AppColors.inversePrimary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  'LEICA',
                  style: AppTypography.overline.copyWith(
                    fontSize: 10,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleFrame(Widget image, EditorState editorState) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: ClipOval(
          child: image,
        ),
      ),
    );
  }

  Widget _buildImageWidget(String path) {
    final imageWidget = kIsWeb
        ? Image.network(
            path,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            loadingBuilder: (_, child, progress) {
              return progress == null ? child : _buildImagePlaceholder();
            },
            errorBuilder: (_, __, ___) => _buildImageError(),
          )
        : Image.file(
            File(path),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) => _buildImageError(),
          );

    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 200),
      child: imageWidget,
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.background,
      child: Center(
        child: SizedBox(
          width: 24, height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.inversePrimary.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  /// 应用滤镜
  Widget _applyFilter(Widget child, EditorState editorState, WidgetRef ref) {
    if (editorState.selectedFilter == FilterType.none) return child;
    final filters = ref.watch(filterConfigProvider).filters;
    final filter = filters.firstWhere(
      (f) => f.type == editorState.selectedFilter,
      orElse: () => FilterModel.findByType(editorState.selectedFilter),
    );
    return ColorFiltered(
      colorFilter: filter.colorFilter,
      child: child,
    );
  }

  /// 在图片上叠加水印文字
  Widget _applyWatermark(Widget child, EditorState editorState) {
    final text = editorState.watermark.text;
    if (text.isEmpty) return child;

    Alignment align;
    EdgeInsets pad;
    switch (editorState.watermark.position) {
      case WatermarkPosition.bottomLeft:
        align = Alignment.bottomLeft;
        pad = const EdgeInsets.only(left: 12, bottom: 12);
      case WatermarkPosition.bottomCenter:
        align = Alignment.bottomCenter;
        pad = const EdgeInsets.only(bottom: 12);
      case WatermarkPosition.bottomRight:
        align = Alignment.bottomRight;
        pad = const EdgeInsets.only(right: 12, bottom: 12);
    }

    TextStyle wmStyle;
    switch (editorState.watermark.font) {
      case WatermarkFont.sans:
        wmStyle = const TextStyle(color: Colors.white, fontSize: 12);
      case WatermarkFont.script:
        wmStyle = const TextStyle(color: Colors.white, fontSize: 12, fontStyle: FontStyle.italic);
      case WatermarkFont.typewriter:
        wmStyle = const TextStyle(color: Colors.white, fontSize: 12, letterSpacing: 1.5);
    }

    return Stack(
      children: [
        child,
        Align(
          alignment: align,
          child: Padding(
            padding: pad,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(text, style: wmStyle),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageError() {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: 48,
          color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  EdgeInsets _framePadding(CanvasAspectRatio ratio) {
    switch (ratio) {
      case CanvasAspectRatio.ratio3x4:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
      case CanvasAspectRatio.ratio1x1:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
      case CanvasAspectRatio.ratio9x16:
        return const EdgeInsets.symmetric(horizontal: 40, vertical: 8);
    }
  }

  double _aspectRatioValue(CanvasAspectRatio ratio) {
    switch (ratio) {
      case CanvasAspectRatio.ratio3x4:
        return 3 / 4;
      case CanvasAspectRatio.ratio1x1:
        return 1.0;
      case CanvasAspectRatio.ratio9x16:
        return 9 / 16;
    }
  }

  Widget _buildGridOverlay() {
    return IgnorePointer(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CustomPaint(
          painter: _GridPainter(),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.onSurfaceVariant.withValues(alpha: 0.25)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (int i = 1; i < 3; i++) {
      final x = size.width * i / 3;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (int i = 1; i < 3; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
