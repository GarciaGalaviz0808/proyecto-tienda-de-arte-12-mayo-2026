import 'package:flutter/material.dart';

class AppDimensions {
  static const double radiusProductCard = 16.0;
  static const double radiusButton = 12.0;
  static const double radiusInput = 12.0;
  static const double radiusModal = 24.0;
  static const double radiusCategoryBadge = 8.0;
  static const double radiusFilterChip = 20.0;
  static const double radiusCard = 16.0;

  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  static const double paddingScreenHorizontal = 16.0;
  static const double paddingCardInternal = 16.0;
  static const double paddingSectionVertical = 24.0;
  static const double gridSpacing = 12.0;

  static const double minButtonHeight = 48.0;
  static const double minTouchTarget = 48.0;

  static const List<BoxShadow> shadowStandard = [
    BoxShadow(
      color: Color(0x102C241B), // textPrimary at 6% opacity
      blurRadius: 16,
      offset: Offset(0, 4),
    )
  ];

  static const List<BoxShadow> shadowElevated = [
    BoxShadow(
      color: Color(0x1A2C241B), // textPrimary at 10% opacity
      blurRadius: 24,
      offset: Offset(0, 8),
    )
  ];
}
