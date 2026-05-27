import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// 统一风格的 SnackBar 工具
class AppSnackbar {
  AppSnackbar._();

  static void success(BuildContext context, String message) {
    _show(context, message, AppColors.onSurface);
  }

  static void error(BuildContext context, String message) {
    _show(context, message, AppColors.error);
  }

  static void info(BuildContext context, String message) {
    _show(context, message, AppColors.inversePrimary);
  }

  static void _show(BuildContext context, String message, Color bgColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTypography.labelMedium.copyWith(color: AppColors.surfaceContainerLowest),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        backgroundColor: bgColor,
        margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        duration: const Duration(milliseconds: 1800),
      ),
    );
  }
}
