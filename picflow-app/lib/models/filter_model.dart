import 'dart:ui' show ColorFilter;

/// 滤镜类型枚举：7 种预设
enum FilterType {
  none,    // 原图
  cream,   // 奶油
  film,    // 胶片
  mono,    // 黑白
  warm,    // 暖阳
  cool,    // 冷调
  retro,   // 复古
}

/// 滤镜模型，预设 7 种 ColorMatrix 滤镜
class FilterModel {
  final FilterType type;        // 滤镜类型
  final String label;           // 显示名称
  final String subLabel;        // 副标题描述
  final List<double> matrix;    // 5x4 RGBA ColorMatrix

  const FilterModel({
    required this.type,
    required this.label,
    required this.subLabel,
    required this.matrix,
  });

  /// 获取 ColorFilter 对象，用于 ColorFiltered widget
  ColorFilter get colorFilter => ColorFilter.matrix(matrix);

  /// 所有内置滤镜预设
  static const List<FilterModel> presets = [
    FilterModel(type: FilterType.none, label: '原图', subLabel: '无滤镜', matrix: _identity),
    FilterModel(type: FilterType.cream, label: '奶油', subLabel: '暖白柔和', matrix: _cream),
    FilterModel(type: FilterType.film, label: '胶片', subLabel: '复古褪色', matrix: _film),
    FilterModel(type: FilterType.mono, label: '黑白', subLabel: '经典', matrix: _mono),
    FilterModel(type: FilterType.warm, label: '暖阳', subLabel: '金色暖调', matrix: _warm),
    FilterModel(type: FilterType.cool, label: '冷调', subLabel: '清冷蓝调', matrix: _cool),
    FilterModel(type: FilterType.retro, label: '复古', subLabel: '怀旧棕调', matrix: _retro),
  ];

  /// 按 FilterType 查找对应的滤镜预设
  static FilterModel findByType(FilterType type) {
    return presets.firstWhere((f) => f.type == type);
  }

  // ========== Color Matrices (20个值, RGBA 顺序) ==========

  /// 单位矩阵 — 无变化
  static const List<double> _identity = [
    1, 0, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 0, 1, 0, 0,
    0, 0, 0, 1, 0,
  ];

  /// 奶油 — 暖白柔和，降低对比
  static const List<double> _cream = [
    1.05, 0.02, 0, 0, 8,
    0.02, 1.02, 0, 0, 4,
    0, 0.02, 0.95, 0, 2,
    0, 0, 0, 1, 0,
  ];

  /// 胶片 — 褪色复古，降低饱和度，暖调
  static const List<double> _film = [
    0.9, 0.05, 0.05, 0, 18,
    0.05, 0.85, 0.05, 0, 12,
    0.05, 0.05, 0.75, 0, 8,
    0, 0, 0, 0.95, 0,
  ];

  /// 黑白 — 去饱和度
  static const List<double> _mono = [
    0.33, 0.34, 0.33, 0, 0,
    0.33, 0.34, 0.33, 0, 0,
    0.33, 0.34, 0.33, 0, 0,
    0, 0, 0, 1, 0,
  ];

  /// 暖阳 — 金色暖调
  static const List<double> _warm = [
    1.1, 0.05, 0, 0, 10,
    0.05, 0.95, 0, 0, 6,
    0, 0, 0.8, 0, 0,
    0, 0, 0, 1, 0,
  ];

  /// 冷调 — 清冷蓝调
  static const List<double> _cool = [
    0.9, 0, 0, 0, 0,
    0, 0.95, 0.02, 0, 0,
    0, 0.02, 1.1, 0, 10,
    0, 0, 0, 1, 0,
  ];

  /// 复古 — 怀旧棕调（仿 sepia）
  static const List<double> _retro = [
    1.0, 0.1, 0.05, 0, 20,
    0.05, 0.85, 0.05, 0, 10,
    0.02, 0.05, 0.7, 0, 0,
    0, 0, 0, 0.92, 0,
  ];
}
