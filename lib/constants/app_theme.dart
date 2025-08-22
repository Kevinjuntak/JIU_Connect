import 'package:flutter/material.dart';

// Colors
class AppColors {
  static const Color primaryLight = Color(0xFF4facfe);
  static const Color primaryDark = Color(0xFF00f2fe);
  static const Color primary = Color.fromARGB(255, 0, 60, 109); // fallback blue
  static const Color backgroundGradientStart = primaryLight;
  static const Color backgroundGradientEnd = primaryDark;
  static const Color buttonColor = primaryLight;
  static const Color buttonTextColor = Colors.white;
  static const Color cardBackground = Colors.white;
  static const Color iconColor = Color(0xFF2196F3);
}

// Sizes
class AppSizes {
  static const double padding = 24.0;
  static const double borderRadius = 16.0;
  static const double avatarRadius = 50.0;
  static const double inputVerticalPadding = 20.0;
  static const double buttonVerticalPadding = 16.0;
  static const double buttonBorderRadius = 16.0;
  static const double formSpacing = 20.0;
}
