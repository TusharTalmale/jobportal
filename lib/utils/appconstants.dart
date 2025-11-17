import 'package:flutter/material.dart';

class AppColors {
  static const primaryColor = Color(0xFF2D1B69);
  static const accentColor = Color(0xFFFF9F43);
  static const backgroundColor = Color(0xFFF5F5F5);
  static const textPrimary = Color(0xFF2D2D2D);
  static const textSecondary = Color(0xFF999999);
  static const borderColor = Color(0xFFE8E8E8);
  static const successColor = Color(0xFF27AE60);
}

class AppTheme {
  static ThemeData getTheme() {
    return ThemeData(
      primaryColor: AppColors.primaryColor,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}