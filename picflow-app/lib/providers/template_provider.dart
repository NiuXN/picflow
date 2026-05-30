import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/template_model.dart';
import '../services/template_service.dart';

enum TemplateSort { latest, trending, featured }

class TemplateSquareState {
  final List<TemplateModel> templates;
  final bool isLoading;
  final bool isRefreshing;
  final TemplateSort sort;
  final String? selectedCategory;
  final String? selectedTag;
  final String? error;

  const TemplateSquareState({
    this.templates = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.sort = TemplateSort.latest,
    this.selectedCategory,
    this.selectedTag,
    this.error,
  });

  TemplateSquareState copyWith({
    List<TemplateModel>? templates,
    bool? isLoading,
    bool? isRefreshing,
    TemplateSort? sort,
    String? selectedCategory,
    String? selectedTag,
    String? error,
  }) {
    return TemplateSquareState(
      templates: templates ?? this.templates,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      sort: sort ?? this.sort,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedTag: selectedTag ?? this.selectedTag,
      error: error,
    );
  }
}

class TemplateSquareNotifier extends StateNotifier<TemplateSquareState> {
  final TemplateService _service;

  TemplateSquareNotifier(this._service)
      : super(const TemplateSquareState()) {
    loadTemplates();
  }

  Future<void> loadTemplates() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final templates = await _service.getTemplates(
        sort: state.sort.name,
        category: state.selectedCategory,
        tag: state.selectedTag,
      );

      state = state.copyWith(
        templates: templates,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: '加载失败，请重试');
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true, error: null);

    try {
      final templates = await _service.getTemplates(
        sort: state.sort.name,
        category: state.selectedCategory,
        tag: state.selectedTag,
      );

      state = state.copyWith(
        templates: templates,
        isRefreshing: false,
      );
    } catch (e) {
      state = state.copyWith(isRefreshing: false, error: '刷新失败');
    }
  }

  void changeSort(TemplateSort newSort) {
    if (state.sort == newSort) return;
    state = state.copyWith(sort: newSort);
    loadTemplates();
  }

  void selectCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
    loadTemplates();
  }

  void selectTag(String? tag) {
    state = state.copyWith(selectedTag: tag);
    loadTemplates();
  }

  Future<void> recordUsage(int templateId) async {
    await _service.recordUsage(templateId);
  }
}

final templateServiceProvider = Provider<TemplateService>((ref) {
  return TemplateService();
});

final templateSquareProvider =
    StateNotifierProvider<TemplateSquareNotifier, TemplateSquareState>((ref) {
  final service = ref.read(templateServiceProvider);
  return TemplateSquareNotifier(service);
});
