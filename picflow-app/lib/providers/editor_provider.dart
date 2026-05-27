import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/filter_model.dart';
import '../models/frame_model.dart';
import '../models/layout_model.dart';
import '../models/watermark_model.dart';

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
}

final editorProvider = StateNotifierProvider<EditorNotifier, EditorState>((ref) {
  return EditorNotifier();
});
