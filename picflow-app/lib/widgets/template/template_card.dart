import 'package:flutter/material.dart';
import '../../models/template_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class TemplateCard extends StatelessWidget {
  final TemplateModel template;
  final VoidCallback? onTap;

  const TemplateCard({
    super.key,
    required this.template,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                template.thumbnailUrl ?? template.previewUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) {
                  return progress == null
                      ? child
                      : Container(
                          height: 180,
                          color: AppColors.background,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              value: progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded /
                                      progress.expectedTotalBytes!
                                  : null,
                              color: AppColors.inversePrimary,
                            ),
                          ),
                        );
                },
                errorBuilder: (_, __, ___) => Container(
                  height: 180,
                  color: AppColors.background,
                  child: Center(
                    child: Icon(Icons.dashboard_customize_outlined,
                        color: AppColors.onSurfaceVariant),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    template.description ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.copy_rounded,
                        size: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${template.useCount} 人使用',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
