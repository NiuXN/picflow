import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import '../models/layout_model.dart';
import '../models/image_model.dart';
import '../providers/editor_provider.dart';
import '../providers/image_provider.dart';
import '../providers/share_config_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../services/recent_works_service.dart';
import '../services/share_service.dart';
import '../utils/color_utils.dart';
import '../widgets/editor/top_bar.dart';
import '../widgets/editor/canvas_area.dart';
import '../widgets/editor/bottom_sheet.dart';

class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  final GlobalKey _canvasKey = GlobalKey();
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final editorState = ref.watch(editorProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            TopBar(
              onBack: () => context.pop(),
              onExport: _isExporting ? null : _handleExport,
            ),
            Expanded(
              child: RepaintBoundary(
                key: _canvasKey,
                child: CanvasArea(
                  showGrid: editorState.layout.showGrid,
                ),
              ),
            ),
            Flexible(
              child: const EditorBottomPanel(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleExport() async {
    setState(() => _isExporting = true);

    try {
      final boundary = _canvasKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      await ImageGallerySaver.saveImage(pngBytes);

      if (!mounted) return;

      _showExportOptions(pngBytes);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('导出失败：$e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isExporting = false);
    }
  }

  void _showExportOptions(Uint8List imageBytes) async {
    final editorState = ref.read(editorProvider);
    final imageState = ref.read(imageProvider);
    final shareConfig = ref.read(shareConfigProvider);

    RecentWorksService().save(
      ImageModel(
        path: imageState.path,
        name: imageState.name,
        date: imageState.date,
        isLoaded: true,
      ),
    );

    final tempFile = await ShareService.saveImageToTemp(imageBytes, 'picflow_export.png');

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.outlineVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '导出成功 ✧',
                  style: AppTypography.h2.copyWith(color: AppColors.onSurface),
                ),
                const SizedBox(height: 4),
                Text(
                  '选择你要的操作',
                  style: AppTypography.bodyRegular
                      .copyWith(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 20),
                _buildShareGrid(ctx, tempFile, shareConfig.channels),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _navigateToPublish(editorState, imageState.path);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.inversePrimary,
                      foregroundColor: AppColors.surfaceContainerLowest,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text('发布到模板广场', style: AppTypography.labelLarge),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShareGrid(BuildContext ctx, File imageFile, List<ShareConfig> channels) {
    final allChannels = [
      const ShareConfig(
        platform: SharePlatform.system,
        label: '保存相册',
        icon: Icons.photo_library,
        sortOrder: 0,
      ),
      ...channels,
    ]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final crossAxisCount = MediaQuery.of(context).size.width > 400 ? 4 : 3;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: allChannels.length,
      itemBuilder: (ctx, index) {
        final config = allChannels[index];
        return _ExportOption(
          icon: config.icon,
          label: config.label,
          onTap: () async {
            Navigator.of(ctx).pop();
            await _handleShare(imageFile, config.platform);
          },
        );
      },
    );
  }

  Future<void> _handleShare(File imageFile, SharePlatform platform) async {
    if (platform == SharePlatform.system) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '已保存到相册 ✧',
            style: AppTypography.labelMedium
                .copyWith(color: AppColors.surfaceContainerLowest),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          backgroundColor: AppColors.onSurface,
        ),
      );
      return;
    }

    await ShareService.shareImage(
      imageFile: imageFile,
      text: '用 PicFlow 制作的图片 ✧',
      targetPlatform: platform,
    );
  }

  void _navigateToPublish(EditorState editorState, String? imagePath) {
    String? hexColor;
    if (editorState.layout.backgroundColorIndex >= 0 &&
        editorState.layout.backgroundColorIndex < ColorUtils.backgroundColors.length) {
      final color = ColorUtils.backgroundColors[editorState.layout.backgroundColorIndex];
      hexColor = '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
    }

    context.push('/publish', extra: {
      'imagePath': imagePath,
      'frameType': editorState.selectedFrame.name,
      'aspectRatio': LayoutModel.ratioLabel(editorState.layout.aspectRatio),
      'bgColor': hexColor,
      'watermarkText': editorState.watermark.text,
      'filter': editorState.selectedFilter.name,
    });
  }
}

class _ExportOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ExportOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppColors.onSurface),
            const SizedBox(height: 8),
            Text(label, style: AppTypography.labelMedium.copyWith(color: AppColors.onSurface)),
          ],
        ),
      ),
    );
  }
}
