import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// PicFlow 字体系统 — Plus Jakarta Sans（MD3 风格）
/// 层级对应: display / headline / title / body / label
class AppTypography {
  AppTypography._();

  static TextStyle get plusJakartaSans => GoogleFonts.plusJakartaSans(
        color: AppColors.onSurface,
      );

  // ========== Display（大标题，仅桌面） ==========
  static TextStyle get displayLarge => plusJakartaSans.copyWith(
        fontSize: 40, height: 48 / 40, letterSpacing: -0.02, fontWeight: FontWeight.w600,
      );

  // ========== Headline（标题） ==========
  static TextStyle get headlineLarge => plusJakartaSans.copyWith(
        fontSize: 32, height: 40 / 32, letterSpacing: -0.01, fontWeight: FontWeight.w600,
      );
  static TextStyle get headlineMedium => plusJakartaSans.copyWith(
        fontSize: 24, height: 32 / 24, fontWeight: FontWeight.w600,
      );

  // ========== Title（小标题） ==========
  static TextStyle get titleMedium => plusJakartaSans.copyWith(
        fontSize: 18, height: 24 / 18, fontWeight: FontWeight.w500,
      );
  static TextStyle get titleSmall => plusJakartaSans.copyWith(
        fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500,
      );

  // ========== Body（正文） ==========
  static TextStyle get bodyLarge => plusJakartaSans.copyWith(
        fontSize: 18, height: 1.5,
      );
  static TextStyle get bodyMedium => plusJakartaSans.copyWith(
        fontSize: 16, height: 1.5,
      );
  static TextStyle get bodySmall => plusJakartaSans.copyWith(
        fontSize: 14, height: 20 / 14,
      );

  // ========== Label（标签/按钮） ==========
  static TextStyle get labelLarge => plusJakartaSans.copyWith(
        fontSize: 16, fontWeight: FontWeight.w600, height: 1.4,
      );
  static TextStyle get labelMedium => plusJakartaSans.copyWith(
        fontSize: 14, fontWeight: FontWeight.w500, height: 1.4,
      );
  static TextStyle get labelSmall => plusJakartaSans.copyWith(
        fontSize: 12, fontWeight: FontWeight.w400, height: 1.4,
      );

  // ========== Caps（全大写标签） ==========
  static TextStyle get labelCaps => plusJakartaSans.copyWith(
        fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.05, height: 16 / 12,
      );

  // ========== Caption（辅助文字） ==========
  static TextStyle get caption => plusJakartaSans.copyWith(
        fontSize: 13, color: AppColors.onSurfaceVariant, height: 1.5,
      );

  // ========== Overline（顶部装饰文字） ==========
  static TextStyle get overline => plusJakartaSans.copyWith(
        fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.05,
        color: AppColors.onSurfaceVariant, height: 1.4,
      );

  // ========== 旧名称兼容别名 ==========
  static TextStyle get h1 => headlineLarge;
  static TextStyle get h2 => headlineMedium;
  static TextStyle get bodyRegular => bodyMedium;
  static TextStyle get heading => plusJakartaSans;
  static TextStyle get body => plusJakartaSans;
}
