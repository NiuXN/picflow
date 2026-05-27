import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../theme/app_colors.dart';

/// 骨架屏：作品网格加载占位
class ArtworkGridSkeleton extends StatelessWidget {
  const ArtworkGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.outlineVariant,
      highlightColor: AppColors.surfaceContainerLowest,
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        children: List.generate(6, (_) => _skeletonCard()),
      ),
    );
  }

  Widget _skeletonCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 12, width: 100, decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 8),
                Container(height: 10, width: 60, decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(4))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 骨架屏：作品详情加载占位
class ArtworkDetailSkeleton extends StatelessWidget {
  const ArtworkDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.outlineVariant,
      highlightColor: AppColors.surfaceContainerLowest,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(height: 300, color: AppColors.surfaceContainerLowest),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 20, width: 200, decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 16),
                  Container(height: 14, width: 140, decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 20),
                  Container(height: 14, width: double.infinity, decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 8),
                  Container(height: 14, width: 200, decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(4))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
