import '../models/template_model.dart';
import '../data/local_templates.dart';
import 'api_service.dart';

class TemplateService {
  final ApiService _api;

  TemplateService({ApiService? api}) : _api = api ?? ApiService();

  Future<List<TemplateModel>> getTemplates({
    String? category,
    String? tag,
    String sort = 'latest',
    int page = 1,
    int size = 20,
  }) async {
    final local = _filterLocal(category: category, tag: tag, sort: sort);

    try {
      final response = await _api.get<List<TemplateModel>>(
        path: '/templates',
        queryParameters: {
          'page': page,
          'size': size,
          'sort': sort,
          if (category != null) 'category': category,
          if (tag != null) 'tag': tag,
        },
        fromJson: (data) {
          final items = (data['items'] as List)
              .map((e) => TemplateModel.fromJson(e as Map<String, dynamic>))
              .toList();
          return items;
        },
      );

      if (response.code == 0 && response.data != null) {
        final remote = response.data!;
        final localIds = local.map((t) => t.id).toSet();
        final merged = [...local, ...remote.where((t) => !localIds.contains(t.id))];
        return _sortTemplates(merged, sort);
      }
    } catch (_) {}

    return local;
  }

  Future<void> recordUsage(int templateId) async {
    try {
      await _api.post<dynamic>(
        path: '/templates/$templateId/use',
        data: {},
        fromJson: (_) => true,
      );
    } catch (_) {}
  }

  List<TemplateModel> _filterLocal({
    String? category,
    String? tag,
    String sort = 'latest',
  }) {
    var result = localTemplates.toList();

    if (category != null) {
      result = result.where((t) => t.category == category).toList();
    }
    if (tag != null) {
      result = result.where((t) => t.tags.contains(tag)).toList();
    }

    return _sortTemplates(result, sort);
  }

  List<TemplateModel> _sortTemplates(List<TemplateModel> templates, String sort) {
    switch (sort) {
      case 'trending':
        templates.sort((a, b) => b.useCount.compareTo(a.useCount));
      case 'featured':
        break;
      case 'latest':
      default:
        break;
    }
    return templates;
  }
}
