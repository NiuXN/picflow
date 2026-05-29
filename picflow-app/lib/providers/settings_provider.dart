import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsState {
  final bool isPro;
  final String defaultFont;
  final String defaultWatermark;
  final bool notificationsEnabled;
  final String defaultFrameType;
  final String defaultAspectRatio;

  const SettingsState({
    this.isPro = false,
    this.defaultFont = 'system',
    this.defaultWatermark = '',
    this.notificationsEnabled = true,
    this.defaultFrameType = 'minimal',
    this.defaultAspectRatio = '3x4',
  });

  SettingsState copyWith({
    bool? isPro,
    String? defaultFont,
    String? defaultWatermark,
    bool? notificationsEnabled,
    String? defaultFrameType,
    String? defaultAspectRatio,
  }) {
    return SettingsState(
      isPro: isPro ?? this.isPro,
      defaultFont: defaultFont ?? this.defaultFont,
      defaultWatermark: defaultWatermark ?? this.defaultWatermark,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      defaultFrameType: defaultFrameType ?? this.defaultFrameType,
      defaultAspectRatio: defaultAspectRatio ?? this.defaultAspectRatio,
    );
  }

  Map<String, dynamic> toJson() => {
        'isPro': isPro,
        'defaultFont': defaultFont,
        'defaultWatermark': defaultWatermark,
        'notificationsEnabled': notificationsEnabled,
        'defaultFrameType': defaultFrameType,
        'defaultAspectRatio': defaultAspectRatio,
      };

  factory SettingsState.fromJson(Map<String, dynamic> json) => SettingsState(
        isPro: json['isPro'] as bool? ?? false,
        defaultFont: json['defaultFont'] as String? ?? 'system',
        defaultWatermark: json['defaultWatermark'] as String? ?? '',
        notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
        defaultFrameType: json['defaultFrameType'] as String? ?? 'minimal',
        defaultAspectRatio: json['defaultAspectRatio'] as String? ?? '3x4',
      );
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  static const _storageKey = 'app_settings';
  final FlutterSecureStorage _storage;

  SettingsNotifier(this._storage) : super(const SettingsState()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final raw = await _storage.read(key: _storageKey);
      if (raw != null) {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        state = SettingsState.fromJson(json);
      }
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      await _storage.write(key: _storageKey, value: jsonEncode(state.toJson()));
    } catch (_) {}
  }

  Future<void> setDefaultFont(String font) async {
    state = state.copyWith(defaultFont: font);
    await _save();
  }

  Future<void> setDefaultWatermark(String watermark) async {
    state = state.copyWith(defaultWatermark: watermark);
    await _save();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    state = state.copyWith(notificationsEnabled: enabled);
    await _save();
  }

  Future<void> setDefaultFrameType(String frameType) async {
    state = state.copyWith(defaultFrameType: frameType);
    await _save();
  }

  Future<void> setDefaultAspectRatio(String ratio) async {
    state = state.copyWith(defaultAspectRatio: ratio);
    await _save();
  }

  Future<void> setPro(bool isPro) async {
    state = state.copyWith(isPro: isPro);
    await _save();
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(const FlutterSecureStorage());
});
