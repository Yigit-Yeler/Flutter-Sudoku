import 'package:flutter/material.dart';

import 'constants/strings.dart';
import 'screens/size_selection_screen.dart';
import 'services/theme_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService();

    return ValueListenableBuilder(
      valueListenable: themeService.currentTheme,
      builder: (context, theme, _) {
        return MaterialApp(
          title: AppStrings.appTitle,
          debugShowCheckedModeBanner: false,
          theme: themeService.getTheme(theme),
          home: const SizeSelectionScreen(),
        );
      },
    );
  }
}
