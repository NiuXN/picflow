import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../models/template_model.dart';
import 'template_card.dart';

class TemplateGrid extends StatelessWidget {
  final List<TemplateModel> templates;
  final ScrollController? scrollController;
  final ValueChanged<TemplateModel>? onTemplateTap;

  const TemplateGrid({
    super.key,
    required this.templates,
    this.scrollController,
    this.onTemplateTap,
  });

  @override
  Widget build(BuildContext context) {
    if (templates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.dashboard_customize_outlined,
                size: 64, color: Color(0xFFD9D9D9)),
            const SizedBox(height: 12),
            Text(
              '暂无模板',
              style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
            ),
          ],
        ),
      );
    }

    return MasonryGridView.count(
      controller: scrollController,
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        return TemplateCard(
          template: templates[index],
          onTap: () => onTemplateTap?.call(templates[index]),
        );
      },
    );
  }
}
