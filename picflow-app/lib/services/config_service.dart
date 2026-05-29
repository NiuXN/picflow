import 'dart:convert';
import 'api_service.dart';

class ConfigItem {
  final int id;
  final String configType;
  final String configKey;
  final String configValue;
  final String label;
  final String? description;
  final int sortOrder;
  final bool enabled;

  const ConfigItem({
    required this.id,
    required this.configType,
    required this.configKey,
    required this.configValue,
    required this.label,
    this.description,
    required this.sortOrder,
    required this.enabled,
  });

  factory ConfigItem.fromJson(Map<String, dynamic> json) {
    return ConfigItem(
      id: json['id'] as int,
      configType: json['configType'] as String? ?? '',
      configKey: json['configKey'] as String? ?? '',
      configValue: json['configValue'] as String? ?? '{}',
      label: json['label'] as String? ?? '',
      description: json['description'] as String?,
      sortOrder: json['sortOrder'] as int? ?? 0,
      enabled: json['enabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> get valueJson {
    try {
      return jsonDecode(configValue) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }
}

class ConfigService {
  final ApiService _api;

  ConfigService({ApiService? api}) : _api = api ?? ApiService();

  Future<List<ConfigItem>> getConfigs(String type) async {
    final response = await _api.get<List<ConfigItem>>(
      path: '/artworks/configs',
      queryParameters: {'type': type},
      fromJson: (data) {
        return (data['items'] as List)
            .map((e) => ConfigItem.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    if (response.code == 0 && response.data != null) {
      return response.data!;
    }
    return [];
  }

  Future<List<ConfigItem>> getFrames() => getConfigs('frame');

  Future<List<ConfigItem>> getFilters() => getConfigs('filter');
}
