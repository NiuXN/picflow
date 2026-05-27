import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/editor_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../modules/filters/filter_panel.dart';
import '../modules/frames/frame_list.dart';
import '../modules/layout/layout_panel.dart';
import '../modules/watermark/watermark_panel.dart';

class TabNavigation extends ConsumerWidget {
  const TabNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref.watch(editorProvider);
    final editorNotifier = ref.read(editorProvider.notifier);

    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 24, right: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _TabItem(
            label: '相框',
            isActive: editorState.editorTab == 0,
            onTap: () => editorNotifier.setEditorTab(0),
          ),
          const SizedBox(width: 28),
          _TabItem(
            label: '排版',
            isActive: editorState.editorTab == 1,
            onTap: () => editorNotifier.setEditorTab(1),
          ),
          const SizedBox(width: 28),
          _TabItem(
            label: '水印',
            isActive: editorState.editorTab == 2,
            onTap: () => editorNotifier.setEditorTab(2),
          ),
          const SizedBox(width: 28),
          _TabItem(
            label: '滤镜',
            isActive: editorState.editorTab == 3,
            onTap: () => editorNotifier.setEditorTab(3),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: isActive ? AppColors.onSurface : AppColors.onSurfaceVariant,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? AppColors.inversePrimary : Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}

class EditorBottomPanel extends ConsumerWidget {
  const EditorBottomPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref.watch(editorProvider);
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final maxPanelHeight = screenHeight * 0.45;

    debugPrint('[EditorBottomPanel] ====== 布局调试信息 ======');
    debugPrint('[EditorBottomPanel] 屏幕高度: $screenHeight');
    debugPrint('[EditorBottomPanel] 底部安全区: $bottomPadding');
    debugPrint('[EditorBottomPanel] 最大面板高度: $maxPanelHeight');
    debugPrint('[EditorBottomPanel] 当前选中Tab: ${editorState.editorTab}');

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;

        debugPrint('[EditorBottomPanel] 可用高度(来自constraints): $availableHeight');

        return Container(
          constraints: BoxConstraints(
            maxHeight: maxPanelHeight,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 24,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: availableHeight > 0 ? availableHeight : 200,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const TabNavigation(),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Builder(
                            builder: (context) {
                              final widget = _getTabWidget(editorState.editorTab);
                              debugPrint('[EditorBottomPanel] 内容区域widget类型: ${widget.runtimeType}');
                              return widget;
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: bottomPadding + 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _getTabWidget(int tabIndex) {
    switch (tabIndex) {
      case 0:
        debugPrint('[EditorBottomPanel] 显示FrameList');
        return FrameList(key: const ValueKey('frames'));
      case 1:
        debugPrint('[EditorBottomPanel] 显示LayoutPanel');
        return LayoutPanel(key: const ValueKey('layout'));
      case 2:
        debugPrint('[EditorBottomPanel] 显示WatermarkPanel');
        return WatermarkPanel(key: const ValueKey('watermark'));
      case 3:
        debugPrint('[EditorBottomPanel] 显示FilterPanel');
        return FilterPanel(key: const ValueKey('filter'));
      default:
        debugPrint('[EditorBottomPanel] 默认显示FrameList');
        return FrameList(key: const ValueKey('frames'));
    }
  }
}
