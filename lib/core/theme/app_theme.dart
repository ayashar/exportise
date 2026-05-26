import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary04,
      brightness: Brightness.light,
      primary: AppColors.primary04,
      onPrimary: AppColors.primary08,
      secondary: AppColors.primary03,
      onSecondary: AppColors.primary08,
      surface: AppColors.primary01,
      onSurface: AppColors.primary08,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.primary01,
      textTheme: AppTypography.textTheme.apply(
        bodyColor: AppColors.primary08,
        displayColor: AppColors.primary08,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary04,
        foregroundColor: AppColors.primary08,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary04,
        foregroundColor: AppColors.primary08,
      ),
    );
  }
}
