import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

enum SharePlatform {
  wechat,
  wechatMoments,
  xiaohongshu,
  weibo,
  douyin,
  copy,
  system,
}

class ShareService {
  ShareService._();

  static const Map<SharePlatform, String> _platformSchemes = {
    SharePlatform.wechat: 'weixin://',
    SharePlatform.xiaohongshu: 'xhs://',
    SharePlatform.weibo: 'sinaweibo://',
    SharePlatform.douyin: 'snssdk1128://',
  };

  static Future<bool> canLaunchPlatform(SharePlatform platform) async {
    final scheme = _platformSchemes[platform];
    if (scheme == null) return true;
    return await canLaunchUrl(Uri.parse(scheme));
  }

  static Future<bool> launchPlatform(SharePlatform platform) async {
    final scheme = _platformSchemes[platform];
    if (scheme == null) return false;
    final uri = Uri.parse(scheme);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  static Future<void> shareImage({
    required File imageFile,
    String? text,
    SharePlatform? targetPlatform,
  }) async {
    if (targetPlatform == null) {
      final xFiles = [XFile(imageFile.path)];
      await Share.shareXFiles(
        xFiles,
        text: text ?? '用 PicFlow 制作的图片 ✧',
      );
      return;
    }

    switch (targetPlatform) {
      case SharePlatform.wechat:
      case SharePlatform.wechatMoments:
      case SharePlatform.xiaohongshu:
      case SharePlatform.weibo:
      case SharePlatform.douyin:
        final canLaunch = await canLaunchPlatform(targetPlatform);
        if (canLaunch) {
          final launched = await launchPlatform(targetPlatform);
          if (!launched) {
            await _fallbackShare(imageFile, text);
          }
        } else {
          await _fallbackShare(imageFile, text);
        }
        break;
      case SharePlatform.copy:
        break;
      case SharePlatform.system:
        await _fallbackShare(imageFile, text);
        break;
    }
  }

  static Future<void> _fallbackShare(File imageFile, String? text) async {
    final xFiles = [XFile(imageFile.path)];
    await Share.shareXFiles(
      xFiles,
      text: text ?? '用 PicFlow 制作的图片 ✧',
    );
  }

  static Future<File> saveImageToTemp(Uint8List imageBytes, String name) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$name');
    await file.writeAsBytes(imageBytes);
    return file;
  }
}

class ShareConfig {
  final SharePlatform platform;
  final String label;
  final IconData icon;
  final bool enabled;
  final int sortOrder;

  const ShareConfig({
    required this.platform,
    required this.label,
    required this.icon,
    this.enabled = true,
    this.sortOrder = 0,
  });

  static List<ShareConfig> get defaultConfigs => [
        const ShareConfig(
          platform: SharePlatform.xiaohongshu,
          label: '小红书',
          icon: Icons.collections_bookmark,
          sortOrder: 1,
        ),
        const ShareConfig(
          platform: SharePlatform.wechatMoments,
          label: '朋友圈',
          icon: Icons.camera_roll,
          sortOrder: 2,
        ),
        const ShareConfig(
          platform: SharePlatform.wechat,
          label: '微信好友',
          icon: Icons.chat,
          sortOrder: 3,
        ),
        const ShareConfig(
          platform: SharePlatform.weibo,
          label: '微博',
          icon: Icons.wifi_tethering,
          sortOrder: 4,
        ),
        const ShareConfig(
          platform: SharePlatform.douyin,
          label: '抖音',
          icon: Icons.video_collection,
          sortOrder: 5,
        ),
        const ShareConfig(
          platform: SharePlatform.system,
          label: '更多',
          icon: Icons.more_horiz,
          sortOrder: 100,
        ),
      ];
}
