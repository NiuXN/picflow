import 'package:flutter/material.dart';

/// PicFlow MD3 色板 — 源自 HTML Prototype
/// 参考: https://m3.material.io/styles/color
class AppColors {
  AppColors._();

  // ========== 主色 ==========
  static const Color primary = Color(0xFF675D4F);           // 主色 — 深褐色
  static const Color inversePrimary = Color(0xFFD2C4B3);    // 反色主色 — 燕麦色（旧 oatMilkTea）
  static const Color primaryContainer = Color(0xFFD2C4B3);  // 主色容器
  static const Color onPrimary = Color(0xFFFFFFFF);         // 主色上文字
  static const Color onPrimaryContainer = Color(0xFF5B5143); // 主色容器上文字

  static const Color primaryFixed = Color(0xFFEFE0CF);      // 主色固定
  static const Color primaryFixedDim = Color(0xFFD2C4B3);   // 主色固定暗

  // ========== 二级色 ==========
  static const Color secondary = Color(0xFF665D52);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFEBDDCF);
  static const Color onSecondaryContainer = Color(0xFF6B6156);

  static const Color secondaryFixed = Color(0xFFEEE0D2);
  static const Color secondaryFixedDim = Color(0xFFD2C4B7);

  // ========== 三级色 ==========
  static const Color tertiary = Color(0xFF615E58);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFCBC5BE);
  static const Color onTertiaryContainer = Color(0xFF55524C);

  static const Color tertiaryFixed = Color(0xFFE8E2DA);
  static const Color tertiaryFixedDim = Color(0xFFCBC6BE);

  // ========== 表面/背景层级 ==========
  /// 应用背景
  static const Color background = Color(0xFFFBF9F8);
  /// 表面色（与背景相同）
  static const Color surface = Color(0xFFFBF9F8);
  /// 最亮表面
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  /// 低层表面
  static const Color surfaceContainerLow = Color(0xFFF5F3F3);
  /// 中层表面
  static const Color surfaceContainer = Color(0xFFEFEDED);
  /// 高层表面
  static const Color surfaceContainerHigh = Color(0xFFEAE8E7);
  /// 最高层表面
  static const Color surfaceContainerHighest = Color(0xFFE4E2E2);
  /// 暗表面
  static const Color surfaceDim = Color(0xFFDBD9D9);

  // ========== 表面变体 ==========
  static const Color surfaceVariant = Color(0xFFE4E2E2);

  // ========== 文字色 ==========
  static const Color onBackground = Color(0xFF1B1C1C);
  static const Color onSurface = Color(0xFF1B1C1C);
  static const Color onSurfaceVariant = Color(0xFF4C463E);

  // ========== 轮廓 ==========
  static const Color outline = Color(0xFF7D766D);
  static const Color outlineVariant = Color(0xFFCFC5BB);

  // ========== 其他系统色 ==========
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  static const Color inverseSurface = Color(0xFF303030);
  static const Color inverseOnSurface = Color(0xFFF2F0F0);

  // ========== 功能色 ==========
  static const Color leicaRed = Color(0xFFE85D3F); // 徕卡红点


  // ========== 背景色系列（排版面板用） ==========
  static const Color beige = Color(0xFFE8DCC8);
  static const Color warm = Color(0xFFD4C5B2);
  static const Color olive = Color(0xFFC5C0AA);
  static const Color blush = Color(0xFFE8D5D0);
}
