/// 画布宽高比：3:4(小红书精选) / 1:1(方形) / 9:16(壁纸)
enum CanvasAspectRatio {
  ratio3x4,
  ratio1x1,
  ratio9x16,
}

/// 排版布局模型：比例 + 网格 + 背景色
class LayoutModel {
  final CanvasAspectRatio aspectRatio;        // 当前选中的画布比例
  final bool showGrid;                        // 是否显示九宫格辅助线
  final int backgroundColorIndex;             // 背景色索引（对应 ColorUtils.backgroundColors）

  const LayoutModel({
    this.aspectRatio = CanvasAspectRatio.ratio3x4,
    this.showGrid = false,
    this.backgroundColorIndex = 0,
  });

  LayoutModel copyWith({
    CanvasAspectRatio? aspectRatio,
    bool? showGrid,
    int? backgroundColorIndex,
  }) {
    return LayoutModel(
      aspectRatio: aspectRatio ?? this.aspectRatio,
      showGrid: showGrid ?? this.showGrid,
      backgroundColorIndex: backgroundColorIndex ?? this.backgroundColorIndex,
    );
  }

  /// 获取比例的显示标签
  static String ratioLabel(CanvasAspectRatio ratio) {
    switch (ratio) {
      case CanvasAspectRatio.ratio3x4:
        return '3:4';
      case CanvasAspectRatio.ratio1x1:
        return '1:1';
      case CanvasAspectRatio.ratio9x16:
        return '9:16';
    }
  }

  /// 获取比例的副标题描述
  static String ratioSubLabel(CanvasAspectRatio ratio) {
    switch (ratio) {
      case CanvasAspectRatio.ratio3x4:
        return '小红书精选';
      case CanvasAspectRatio.ratio1x1:
        return '经典方形';
      case CanvasAspectRatio.ratio9x16:
        return '壁纸比例';
    }
  }
}
