import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/config_service.dart';
import '../services/share_service.dart';
import '../providers/config_provider.dart';

final shareConfigProvider =
    StateNotifierProvider<ShareConfigNotifier, ShareConfigState>((ref) {
  final configService = ref.read(configServiceProvider);
  return ShareConfigNotifier(configService);
});

class ShareConfigState {
  final List<ShareConfig> channels;
  final bool isLoading;
  final String? error;

  const ShareConfigState({
    this.channels = const [],
    this.isLoading = false,
    this.error,
  });

  ShareConfigState copyWith({
    List<ShareConfig>? channels,
    bool? isLoading,
    String? error,
  }) {
    return ShareConfigState(
      channels: channels ?? this.channels,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ShareConfigNotifier extends StateNotifier<ShareConfigState> {
  final ConfigService _configService;

  ShareConfigNotifier(this._configService)
      : super(const ShareConfigState(channels: [])) {
    _load();
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final configs = await _configService.getShareChannels();
      if (configs.isNotEmpty) {
        final channels = configs.where((c) => c.enabled).map((c) {
          final platform = SharePlatform.values.firstWhere(
            (p) => p.name == c.configKey,
            orElse: () => SharePlatform.system,
          );
          final valueJson = c.valueJson;
          return ShareConfig(
            platform: platform,
            label: c.label,
            icon: _parseIcon(valueJson['icon'] as String?),
            enabled: c.enabled,
            sortOrder: c.sortOrder,
          );
        }).toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        state = state.copyWith(channels: channels, isLoading: false);
      } else {
        state = state.copyWith(
          channels: ShareConfig.defaultConfigs,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        channels: ShareConfig.defaultConfigs,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  IconData _parseIcon(String? iconName) {
    switch (iconName) {
      case 'chat':
        return Icons.chat;
      case 'camera_roll':
        return Icons.camera_roll;
      case 'collections_bookmark':
        return Icons.collections_bookmark;
      case 'wifi_tethering':
        return Icons.wifi_tethering;
      case 'video_collection':
        return Icons.video_collection;
      case 'more_horiz':
      default:
        return Icons.more_horiz;
    }
  }
}
