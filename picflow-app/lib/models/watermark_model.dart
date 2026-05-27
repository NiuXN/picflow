/// 水印字体：无衬线 / 手写体 / 打字机
enum WatermarkFont {
  sans,
  script,
  typewriter,
}

/// 水印位置：左下 / 底部居中 / 右下
enum WatermarkPosition {
  bottomLeft,
  bottomCenter,
  bottomRight,
}

/// 水印配置模型：文字内容 + 字体 + 位置
class WatermarkModel {
  final String text;                      // 水印文字内容
  final WatermarkFont font;               // 字体样式
  final WatermarkPosition position;       // 水印位置

  const WatermarkModel({
    this.text = '',
    this.font = WatermarkFont.sans,
    this.position = WatermarkPosition.bottomLeft,
  });

  WatermarkModel copyWith({
    String? text,
    WatermarkFont? font,
    WatermarkPosition? position,
  }) {
    return WatermarkModel(
      text: text ?? this.text,
      font: font ?? this.font,
      position: position ?? this.position,
    );
  }
}
