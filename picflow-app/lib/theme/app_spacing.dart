import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  static const EdgeInsets tinyPadding = EdgeInsets.all(xs);
  static const EdgeInsets smallPadding = EdgeInsets.all(sm);
  static const EdgeInsets mediumPadding = EdgeInsets.all(md);
  static const EdgeInsets largePadding = EdgeInsets.all(lg);
  static const EdgeInsets hugePadding = EdgeInsets.all(xl);

  static const EdgeInsets symmetricSmall = EdgeInsets.symmetric(horizontal: sm, vertical: sm);
  static const EdgeInsets symmetricMedium = EdgeInsets.symmetric(horizontal: md, vertical: md);
  static const EdgeInsets symmetricLarge = EdgeInsets.symmetric(horizontal: lg, vertical: lg);

  static const EdgeInsets horizontalMedium = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLarge = EdgeInsets.symmetric(horizontal: lg);

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: md);
}
