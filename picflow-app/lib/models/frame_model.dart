/// 相框类型枚举：5 种预设相框
enum FrameType {
  minimal,     // 极简留白
  exif,        // EXIF 参数
  polaroid,    // 拍立得风
  proFilm,     // 专业底片（徕卡风格）
  circle,      // 圆形取景
}

/// 相框数据模型，定义相框的展示信息和属性
class FrameModel {
  final FrameType type;       // 相框类型
  final String label;         // 显示名称
  final String subLabel;      // 副标题
  final bool isPro;           // 是否付费

  const FrameModel({
    required this.type,
    required this.label,
    required this.subLabel,
    this.isPro = false,
  });

  /// 所有可用相框列表
  static List<FrameModel> get all => const [
        FrameModel(type: FrameType.minimal, label: '极简留白', subLabel: '纯比例留白'),
        FrameModel(type: FrameType.exif, label: '基础参数', subLabel: 'EXIF 信息'),
        FrameModel(type: FrameType.polaroid, label: '拍立得风', subLabel: '1:1 裁切'),
        FrameModel(type: FrameType.proFilm, label: '专业底片', subLabel: '徕卡风格', isPro: true),
        FrameModel(type: FrameType.circle, label: '圆形取景', subLabel: '复古镜头'),
      ];
}
