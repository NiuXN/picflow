import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/image_model.dart';
import '../providers/editor_provider.dart';
import '../providers/image_provider.dart';
import '../services/image_service.dart';
import '../services/recent_works_service.dart';
import '../services/version_check_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import '../widgets/home/center_card.dart';
import '../widgets/home/pro_badge.dart';

final imageServiceProvider = Provider<ImageService>((ref) => ImageService());

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final RecentWorksService _recentWorksService = RecentWorksService();
  List<ImageModel> _recentWorks = [];

  @override
  void initState() {
    super.initState();
    _loadRecentWorks();
    _checkVersion();
  }

  Future<void> _checkVersion() async {
    // 延迟一下，等界面渲染完成后再弹更新提示
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) checkAppVersion(context);
  }

  Future<void> _loadRecentWorks() async {
    final works = await _recentWorksService.load();
    if (mounted) {
      setState(() => _recentWorks = works);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              _buildHeader(),
              const SizedBox(height: 32),
              CenterCard(
                onTap: _navigateToEditor,
              ),
              const SizedBox(height: 40),
              _buildRecentSection(),
              const SizedBox(height: 32),
              _buildQuickActions(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '灵感相框',
              style: AppTypography.heading.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 2),
            Text(
              'PicFlow · 治愈系排版工具',
              style: AppTypography.caption,
            ),
          ],
        ),
        const ProBadge(),
      ],
    );
  }

  Widget _buildRecentSection() {
    final recentWorks = _recentWorks;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '最近作品',
              style: AppTypography.heading.copyWith(fontSize: 18),
            ),
            GestureDetector(
              onTap: () => context.push('/profile'),
              child: Text(
                '查看全部',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.inversePrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: recentWorks.map((work) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: work == recentWorks.first ? 0 : 8,
                  right: work == recentWorks.last ? 0 : 8,
                ),
                child: _TapScale(
                  onTap: _navigateToEditor,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 40,
                              color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                work.name ?? '',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                work.date ?? '',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      _QuickAction(icon: Icons.grid_on_outlined, label: '拼图', onTap: () => _showComingSoon('拼图')),
      _QuickAction(icon: Icons.edit_outlined, label: '修图', onTap: _navigateToEditor),
      _QuickAction(icon: Icons.monitor_outlined, label: '视频', onTap: () => _showComingSoon('视频')),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '快捷工具',
          style: AppTypography.heading.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 16),
        Row(
          children: actions.map((action) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _TapScale(
                  onTap: action.onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(action.icon, size: 24, color: AppColors.onSurface),
                        const SizedBox(height: 8),
                        Text(
                          action.label,
                          style: AppTypography.labelSmall.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature 功能即将上线', style: AppTypography.labelSmall),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _navigateToEditor() async {
    final imageService = ref.read(imageServiceProvider);
    final image = await imageService.pickFromGallery();
    if (image != null && image.path != null) {
      // 重置编辑器状态，避免旧作品的相框/排版/水印设置残留
      ref.read(editorProvider.notifier).resetState();
      ref.read(imageProvider.notifier).setImage(
            image.path!,
            name: image.name,
          );
      if (mounted) {
        context.push('/editor');
      }
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
      onTapDown: (_) => setState(() => _scale = 0.97),
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

class _QuickAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  _QuickAction({required this.icon, required this.label, required this.onTap});
}
