import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/template_model.dart';
import '../providers/editor_provider.dart';
import '../providers/image_provider.dart';
import '../providers/template_provider.dart';
import '../services/image_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/template/category_chip_list.dart';
import '../widgets/template/template_grid.dart';
import '../widgets/template/template_preview_sheet.dart';

final _imageServiceProvider = Provider<ImageService>((ref) => ImageService());

class TemplateSquareScreen extends ConsumerStatefulWidget {
  final Key? pageKey;

  const TemplateSquareScreen({super.key, this.pageKey});

  @override
  ConsumerState<TemplateSquareScreen> createState() =>
      _TemplateSquareScreenState();
}

class _TemplateSquareScreenState extends ConsumerState<TemplateSquareScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(templateSquareProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '模板广场',
                      style: AppTypography.h2.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search_rounded,
                          color: AppColors.onSurface),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('搜索功能即将上线')),
                        );
                      },
                    ),
                  ],
                ),
              ),
              CategoryChipList(
                selectedCategory: state.selectedCategory,
                onCategorySelected: (category) {
                  ref
                      .read(templateSquareProvider.notifier)
                      .selectCategory(category);
                },
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          TemplateSortBar(
            currentSort: state.sort,
            onSortChanged: (sort) {
              ref.read(templateSquareProvider.notifier).changeSort(sort);
            },
          ),
          Expanded(
            child: state.isLoading && state.templates.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.inversePrimary))
                : RefreshIndicator(
                    onRefresh: () =>
                        ref.read(templateSquareProvider.notifier).refresh(),
                    color: AppColors.inversePrimary,
                    child: TemplateGrid(
                      templates: state.templates,
                      scrollController: _scrollController,
                      onTemplateTap: (template) =>
                          _onTemplateTap(context, template),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _onTemplateTap(BuildContext context, TemplateModel template) {
    TemplatePreviewSheet.show(
      context,
      template: template,
      onUseTemplate: () => _useTemplate(template),
    );
  }

  Future<void> _useTemplate(TemplateModel template) async {
    final imageService = ref.read(_imageServiceProvider);
    final image = await imageService.pickFromGallery();
    if (image != null && image.path != null) {
      ref.read(editorProvider.notifier).resetState();
      ref.read(editorProvider.notifier).applyTemplateConfig(template.config);
      ref.read(imageProvider.notifier).setImage(
            image.path!,
            name: image.name,
          );

      ref.read(templateSquareProvider.notifier).recordUsage(template.id);

      if (mounted) {
        context.push('/editor');
      }
    }
  }
}
