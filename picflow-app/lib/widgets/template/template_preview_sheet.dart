import 'package:flutter/material.dart';
import '../../models/template_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class TemplatePreviewSheet extends StatelessWidget {
  final TemplateModel template;
  final VoidCallback onUseTemplate;

  const TemplatePreviewSheet({
    super.key,
    required this.template,
    required this.onUseTemplate,
  });

  static void show(
    BuildContext context, {
    required TemplateModel template,
    required VoidCallback onUseTemplate,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TemplatePreviewSheet(
        template: template,
        onUseTemplate: onUseTemplate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.outlineVariant,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      template.previewUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) {
                        return progress == null
                            ? child
                            : Container(
                                height: 280,
                                color: AppColors.background,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.inversePrimary,
                                  ),
                                ),
                              );
                      },
                      errorBuilder: (_, __, ___) => Container(
                        height: 280,
                        color: AppColors.background,
                        child: Center(
                          child: Icon(Icons.dashboard_customize_outlined,
                              size: 48, color: AppColors.onSurfaceVariant),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              template.name,
                              style: AppTypography.h2.copyWith(
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              template.description ?? '',
                              style: AppTypography.bodyRegular.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _ConfigChip(
                          icon: Icons.crop_free_rounded,
                          label: _frameLabel(template.config.frameType)),
                      const SizedBox(width: 8),
                      _ConfigChip(
                          icon: Icons.aspect_ratio_rounded,
                          label: template.config.aspectRatio),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _ConfigChip(
                        icon: Icons.palette_outlined,
                        label: _filterLabel(template.config.filter),
                      ),
                      const SizedBox(width: 8),
                      if (template.config.bgColor != null)
                        _ConfigChip(
                          icon: Icons.circle,
                          iconColor: _parseHexColor(template.config.bgColor!),
                          label: template.config.bgColor!,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.copy_rounded,
                          size: 16, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        '${template.useCount} 人使用',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onUseTemplate();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.inversePrimary,
                        foregroundColor: AppColors.surfaceContainerLowest,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text('使用此模板',
                          style: AppTypography.labelLarge),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _frameLabel(String frameType) {
    switch (frameType) {
      case 'minimal':
        return '极简';
      case 'exif':
        return 'EXIF';
      case 'polaroid':
        return '拍立得';
      case 'proFilm':
        return '底片';
      case 'circle':
        return '圆形';
      default:
        return frameType;
    }
  }

  String _filterLabel(String filter) {
    switch (filter) {
      case 'none':
        return '原图';
      case 'cream':
        return '奶油';
      case 'film':
        return '胶片';
      case 'mono':
        return '黑白';
      case 'warm':
        return '暖阳';
      case 'cool':
        return '冷调';
      case 'retro':
        return '复古';
      default:
        return filter;
    }
  }

  Color _parseHexColor(String hex) {
    final code = hex.replaceFirst('#', '');
    return Color(int.parse('FF$code', radix: 16));
  }
}

class _ConfigChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;

  const _ConfigChip({
    required this.icon,
    required this.label,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor ?? AppColors.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
