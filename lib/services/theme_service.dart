import 'package:flutter/material.dart';

import '../constants/enums/app_theme.dart';

class ThemeService {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  final ValueNotifier<AppTheme> currentTheme = ValueNotifier(AppTheme.light);

  ThemeData getTheme(AppTheme mode) {
    switch (mode) {
      case AppTheme.light:
        return _lightTheme;
      case AppTheme.dark:
        return _darkTheme;
      case AppTheme.nature:
        return _natureTheme;
      case AppTheme.ocean:
        return _oceanTheme;
    }
  }

  static final ThemeData _lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );

  static final ThemeData _darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );

  static final ThemeData _natureTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.green,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: Colors.green[50],
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );

  static final ThemeData _oceanTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: Colors.blue[50],
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );

  Color getCellBackgroundColor(AppTheme mode) {
    switch (mode) {
      case AppTheme.light:
        return Colors.white;
      case AppTheme.dark:
        return Colors.grey[800]!;
      case AppTheme.nature:
        return Colors.green[50]!;
      case AppTheme.ocean:
        return Colors.blue[50]!;
    }
  }

  Color getSelectedCellColor(AppTheme mode) {
    switch (mode) {
      case AppTheme.light:
        return Colors.lightGreen[200]!;
      case AppTheme.dark:
        return Colors.lightGreen[700]!;
      case AppTheme.nature:
        return Colors.green[200]!;
      case AppTheme.ocean:
        return Colors.blue[200]!;
    }
  }

  Color getErrorCellColor(AppTheme mode) {
    switch (mode) {
      case AppTheme.light:
        return Colors.red[200]!;
      case AppTheme.dark:
        return Colors.red[900]!;
      case AppTheme.nature:
        return Colors.red[300]!;
      case AppTheme.ocean:
        return Colors.red[300]!;
    }
  }
}
