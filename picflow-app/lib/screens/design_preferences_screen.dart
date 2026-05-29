import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../providers/config_provider.dart';
import '../providers/settings_provider.dart';

class DesignPreferencesScreen extends ConsumerWidget {
  const DesignPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final frames = ref.watch(frameConfigProvider).frames;
    final filters = ref.watch(filterConfigProvider).filters;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text('设计偏好', style: AppTypography.labelLarge.copyWith(color: AppColors.onSurface)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('默认相框', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: settings.defaultFrameType,
            decoration: _decoration(),
            items: frames.map((f) => DropdownMenuItem(
              value: f.type.name,
              child: Text(f.label, style: AppTypography.bodyRegular),
            )).toList(),
            onChanged: (v) {
              if (v != null) settingsNotifier.setDefaultFrameType(v);
            },
          ),
          const SizedBox(height: 24),
          Text('默认画面比例', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: settings.defaultAspectRatio,
            decoration: _decoration(),
            items: const [
              DropdownMenuItem(value: '3x4', child: Text('3:4', style: AppTypography.bodyRegular)),
              DropdownMenuItem(value: '1x1', child: Text('1:1', style: AppTypography.bodyRegular)),
              DropdownMenuItem(value: '9x16', child: Text('9:16', style: AppTypography.bodyRegular)),
            ],
            onChanged: (v) {
              if (v != null) settingsNotifier.setDefaultAspectRatio(v);
            },
          ),
          const SizedBox(height: 24),
          Text('推送通知', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SwitchListTile(
            value: settings.notificationsEnabled,
            onChanged: (v) => settingsNotifier.setNotificationsEnabled(v),
            title: Text('接收推送通知', style: AppTypography.bodyRegular),
            contentPadding: EdgeInsets.zero,
            activeColor: AppColors.inversePrimary,
          ),
        ],
      ),
    );
  }

  InputDecoration _decoration() {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.surfaceContainerLowest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
