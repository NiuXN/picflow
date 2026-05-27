import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsState {
  final bool isPro;

  const SettingsState({this.isPro = false});
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState());
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
