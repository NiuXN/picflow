import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/filter_model.dart';
import '../models/frame_model.dart';
import '../models/layout_model.dart';
import '../models/template_model.dart';
import '../models/watermark_model.dart';
import '../utils/color_utils.dart';

class EditorState {
  final FrameType selectedFrame;
  final LayoutModel layout;
  final WatermarkModel watermark;
  final int editorTab;
  final FilterType selectedFilter;

  const EditorState({
    this.selectedFrame = FrameType.minimal,
    this.layout = const LayoutModel(),
    this.watermark = const WatermarkModel(),
    this.editorTab = 0,
    this.selectedFilter = FilterType.none,
  });

  EditorState copyWith({
    FrameType? selectedFrame,
    LayoutModel? layout,
    WatermarkModel? watermark,
    int? editorTab,
    FilterType? selectedFilter,
  }) {
    return EditorState(
      selectedFrame: selectedFrame ?? this.selectedFrame,
      layout: layout ?? this.layout,
      watermark: watermark ?? this.watermark,
      editorTab: editorTab ?? this.editorTab,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }
}

class EditorNotifier extends StateNotifier<EditorState> {
  EditorNotifier() : super(const EditorState());

  void selectFrame(FrameType frame) {
    state = state.copyWith(selectedFrame: frame);
  }

  void setAspectRatio(CanvasAspectRatio ratio) {
    state = state.copyWith(layout: state.layout.copyWith(aspectRatio: ratio));
  }

  void toggleGrid() {
    state = state.copyWith(layout: state.layout.copyWith(showGrid: !state.layout.showGrid));
  }

  void setBackgroundColorIndex(int index) {
    state = state.copyWith(layout: state.layout.copyWith(backgroundColorIndex: index));
  }

  void resetState() {
    state = const EditorState();
  }

  void setFilter(FilterType filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  void setWatermarkText(String text) {
    state = state.copyWith(watermark: state.watermark.copyWith(text: text));
  }

  void setWatermarkFont(WatermarkFont font) {
    state = state.copyWith(watermark: state.watermark.copyWith(font: font));
  }

  void setWatermarkPosition(WatermarkPosition position) {
    state = state.copyWith(watermark: state.watermark.copyWith(position: position));
  }

  void setEditorTab(int tab) {
    state = state.copyWith(editorTab: tab);
  }

  void applyTemplateConfig(TemplateConfig config) {
    final frame = _parseFrameType(config.frameType);
    final ratio = _parseAspectRatio(config.aspectRatio);
    final filter = _parseFilterType(config.filter);
    final bgIndex = _findBgColorIndex(config.bgColor);

    WatermarkFont? wFont;
    if (config.watermarkFont != null) {
      wFont = _parseWatermarkFont(config.watermarkFont!);
    }
    WatermarkPosition? wPos;
    if (config.watermarkPosition != null) {
      wPos = _parseWatermarkPosition(config.watermarkPosition!);
    }

    state = state.copyWith(
      selectedFrame: frame,
      selectedFilter: filter,
      layout: state.layout.copyWith(
        aspectRatio: ratio,
        backgroundColorIndex: bgIndex,
      ),
      watermark: state.watermark.copyWith(
        text: config.watermarkText ?? '',
        font: wFont ?? state.watermark.font,
        position: wPos ?? state.watermark.position,
      ),
    );
  }

  FrameType _parseFrameType(String type) {
    return FrameType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => FrameType.minimal,
    );
  }

  CanvasAspectRatio _parseAspectRatio(String ratio) {
    switch (ratio) {
      case '1x1':
        return CanvasAspectRatio.ratio1x1;
      case '9x16':
        return CanvasAspectRatio.ratio9x16;
      case '3x4':
      default:
        return CanvasAspectRatio.ratio3x4;
    }
  }

  FilterType _parseFilterType(String filter) {
    return FilterType.values.firstWhere(
      (e) => e.name == filter,
      orElse: () => FilterType.none,
    );
  }

  int _findBgColorIndex(String? bgColor) {
    if (bgColor == null) return 0;
    final hex = bgColor.replaceFirst('#', '');
    final target = int.parse('FF$hex', radix: 16);
    for (int i = 0; i < ColorUtils.backgroundColors.length; i++) {
      if (ColorUtils.backgroundColors[i].toARGB32() == target) return i;
    }
    return 0;
  }

  WatermarkFont _parseWatermarkFont(String font) {
    return WatermarkFont.values.firstWhere(
      (e) => e.name == font,
      orElse: () => WatermarkFont.sans,
    );
  }

  WatermarkPosition _parseWatermarkPosition(String position) {
    return WatermarkPosition.values.firstWhere(
      (e) => e.name == position,
      orElse: () => WatermarkPosition.bottomLeft,
    );
  }
}

final editorProvider = StateNotifierProvider<EditorNotifier, EditorState>((ref) {
  return EditorNotifier();
});
