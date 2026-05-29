import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/api_config.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// 更新类型
enum UpdateType { none, optional, force }

/// App 版本信息（从 API 获取）
class AppVersionInfo {
  final String versionName;        // 最新版本号
  final int versionCode;           // 最新版本码
  final UpdateType updateType;     // 更新类型
  final bool forceUpdate;          // 是否强制
  final String? description;       // 简短说明
  final String? releaseNotes;      // 详细发布日志
  final String? downloadUrl;       // 安装包下载链接
  final String? hotfixUrl;         // 热更新链接（Shorebird）

  const AppVersionInfo({
    required this.versionName,
    required this.versionCode,
    required this.updateType,
    this.forceUpdate = false,
    this.description,
    this.releaseNotes,
    this.downloadUrl,
    this.hotfixUrl,
  });

  factory AppVersionInfo.fromJson(Map<String, dynamic> json) {
    final typeStr = json['updateType'] as String? ?? 'none';
    return AppVersionInfo(
      versionName: json['versionName'] as String? ?? '',
      versionCode: json['versionCode'] as int? ?? 0,
      updateType: typeStr == 'force' ? UpdateType.force
          : typeStr == 'optional' ? UpdateType.optional
          : UpdateType.none,
      forceUpdate: json['forceUpdate'] as bool? ?? false,
      description: json['description'] as String?,
      releaseNotes: json['releaseNotes'] as String?,
      downloadUrl: json['downloadUrl'] as String?,
      hotfixUrl: json['hotfixUrl'] as String?,
    );
  }
}

/// 检查 App 版本更新，根据更新类型弹出不同提示
Future<void> checkAppVersion(BuildContext context, {int? userId}) async {
  try {
    await _ensureVersionInfo();
    final dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ));

    final response = await dio.get('/app/version', queryParameters: {
      'platform': 'all',
      'channel': 'stable',
      if (userId != null) 'userId': userId,
      'currentVersionCode': _currentVersionCode(),
    });

    final data = response.data['data'];
    if (data == null) return;

    final info = AppVersionInfo.fromJson(data as Map<String, dynamic>);
    if (info.updateType == UpdateType.none) return;

    if (!context.mounted) return;

    // 优先尝试热更新（Shorebird）
    if (info.hotfixUrl != null && info.hotfixUrl!.isNotEmpty) {
      _applyHotfix(info.hotfixUrl!);
      return;
    }

    await _showUpdateDialog(context, info);
  } catch (_) {
    // 静默失败
  }
}

/// 显示版本更新弹窗
Future<void> _showUpdateDialog(BuildContext context, AppVersionInfo info) async {
  await showDialog(
    context: context,
    barrierDismissible: info.updateType != UpdateType.force,
    builder: (ctx) => PopScope(
      canPop: info.updateType != UpdateType.force,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              info.updateType == UpdateType.force ? Icons.system_update_rounded : Icons.new_releases_rounded,
              color: AppColors.onSurface,
            ),
            const SizedBox(width: 8),
            Text('发现新版本', style: AppTypography.h2.copyWith(color: AppColors.onSurface)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'v${_currentVersionName()} → v${info.versionName}',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.inversePrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (info.description != null && info.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(info.description!, style: AppTypography.bodyRegular.copyWith(height: 1.5)),
            ],
            if (info.releaseNotes != null && info.releaseNotes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  info.releaseNotes!,
                  style: AppTypography.labelSmall.copyWith(height: 1.6),
                ),
              ),
            ],
            if (info.updateType == UpdateType.force) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.error_outline, size: 16, color: AppColors.error),
                  const SizedBox(width: 6),
                  Text(
                    '此版本为强制更新，请升级后继续使用',
                    style: AppTypography.labelSmall.copyWith(color: AppColors.error),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          if (info.updateType != UpdateType.force)
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('稍后再说', style: AppTypography.labelMedium.copyWith(color: AppColors.onSurfaceVariant)),
            ),
          ElevatedButton.icon(
            onPressed: () => _handleUpdate(ctx, info),
            icon: const Icon(Icons.download_rounded, size: 18),
            label: Text(info.updateType == UpdateType.force ? '立即更新' : '更新'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.inversePrimary,
              foregroundColor: AppColors.surfaceContainerLowest,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            ),
          ),
        ],
      ),
    ),
  );
}

/// 处理更新操作：根据平台走不同更新通道
Future<void> _handleUpdate(BuildContext context, AppVersionInfo info) async {
  if (info.downloadUrl != null && info.downloadUrl!.isNotEmpty) {
    final uri = Uri.parse(info.downloadUrl!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('无法打开下载链接: ${info.downloadUrl}')),
        );
      }
    }
  }

  if (info.updateType != UpdateType.force && context.mounted) {
    Navigator.of(context).pop();
  }
}

/// 应用热更新补丁（Shorebird CodePush）
void _applyHotfix(String url) {
  // 集成 shorebird_code_push 后，调用 ShorebirdCodePush().downloadAndInstallPatch(url)
  // 当前版本: shorebird 不内置，需额外接入
  debugPrint('[Hotfix] 热更新补丁地址: $url');
}

String? _cachedVersionName;
int? _cachedVersionCode;

Future<void> _ensureVersionInfo() async {
  if (_cachedVersionName == null) {
    final info = await PackageInfo.fromPlatform();
    _cachedVersionName = info.version;
    _cachedVersionCode = int.tryParse(info.buildNumber) ?? 1;
  }
}

String _currentVersionName() => _cachedVersionName ?? '1.0.0';

int _currentVersionCode() => _cachedVersionCode ?? 1;
