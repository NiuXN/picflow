import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/image_model.dart';

/// 最近作品持久化服务：本地 JSON 文件存储（最多保留6条）
class RecentWorksService {
  static const _fileName = 'recent_works.json';
  static const _maxItems = 6;

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<List<ImageModel>> load() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) return [];

      final content = await file.readAsString();
      final List<dynamic> data = json.decode(content) as List<dynamic>;

      return data.map((e) {
        final map = e as Map<String, dynamic>;
        return ImageModel(
          path: map['path'] as String?,
          name: map['name'] as String?,
          date: map['date'] as String?,
          isLoaded: true,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(ImageModel work) async {
    try {
      final items = await load();

      // 去重：如果路径相同，移除旧记录
      items.removeWhere((item) => item.path != null && item.path == work.path);

      // 新记录插到最前面
      items.insert(0, work);

      // 限制数量
      final trimmed = items.take(_maxItems).toList();

      final file = await _getFile();
      final data = trimmed.map((item) => {
        'path': item.path,
        'name': item.name,
        'date': item.date,
      }).toList();

      await file.writeAsString(json.encode(data));
    } catch (_) {
      // 静默失败，不影响主流程
    }
  }

  Future<void> clear() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}
