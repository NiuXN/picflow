import 'package:flutter/material.dart';

/// PicFlow 阴影系统 — MD3 ambient 弥散阴影
/// 参考: https://m3.material.io/styles/elevation
///
/// 使用 rgba(74, 74, 74, opacity) 保持一致性：
/// - ambient: 0 8px 24px rgba(74,74,74,0.06)
/// - ambient-hover: 0 12px 32px rgba(74,74,74,0.1)
class AppShadows {
  AppShadows._();

  /// 基础弥散阴影
  static const BoxShadow ambient = BoxShadow(
    color: Color(0x0F4A4A4A), // rgba(74,74,74,0.06)
    blurRadius: 24,
    offset: Offset(0, 8),
  );

  /// 悬停弥散阴影（更深）
  static const BoxShadow ambientHover = BoxShadow(
    color: Color(0x1A4A4A4A), // rgba(74,74,74,0.10)
    blurRadius: 32,
    offset: Offset(0, 12),
  );

  /// 顶部面板阴影
  static const BoxShadow topShadow = BoxShadow(
    color: Color(0x0F4A4A4A), // rgba(74,74,74,0.06)
    blurRadius: 40,
    offset: Offset(0, -12),
  );

  /// 按钮阴影
  static const BoxShadow buttonShadow = BoxShadow(
    color: Color(0x0A4A4A4A), // rgba(74,74,74,0.04)
    blurRadius: 8,
    offset: Offset(0, 2),
  );

  /// 强调色按钮阴影
  static const BoxShadow accentButtonShadow = BoxShadow(
    color: Color(0x40D2C4B3),
    blurRadius: 12,
    offset: Offset(0, 4),
  );

  // ========== 便捷列表 ==========
  static List<BoxShadow> get ambientShadows => [ambient];
  static List<BoxShadow> get ambientHoverShadows => [ambientHover];
  static List<BoxShadow> get buttonShadows => [buttonShadow];
  static List<BoxShadow> get accentButtonShadows => [accentButtonShadow];

  // ========== 旧名称兼容 ==========
  static const BoxShadow softShadow = ambient;
  static const BoxShadow cardShadow = ambient;
  static List<BoxShadow> get cardShadows => [ambient];
  static List<BoxShadow> get softShadows => [ambient];
}
