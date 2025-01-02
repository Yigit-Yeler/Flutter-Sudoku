import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_strings.dart';
import '../constants/enums/app_theme.dart';
import '../constants/enums/difficulty_level.dart';
import '../painters/background_painter.dart';
import '../services/theme_service.dart';
import 'game_screen.dart';

class SizeSelectionScreen extends StatefulWidget {
  const SizeSelectionScreen({super.key});

  @override
  State<SizeSelectionScreen> createState() => _SizeSelectionScreenState();
}

class _SizeSelectionScreenState extends State<SizeSelectionScreen>
    with SingleTickerProviderStateMixin {
  final ThemeService _themeService = ThemeService();
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: AppSizes.animFast),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _themeService.currentTheme,
      builder: (context, theme, _) {
        return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: BackgroundPainter(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    _buildAppBar(context),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(AppSizes.paddingL),
                        children: [
                          const SizedBox(height: AppSizes.paddingL),
                          const Text(
                            AppStrings.selectSize,
                            style: TextStyle(
                              fontSize: AppSizes.fontXL,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSizes.paddingXL),
                          for (final size in AppSizes.availableBoardSizes) ...[
                            _buildSizeCard(context, size),
                            const SizedBox(height: AppSizes.paddingL),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              AppStrings.appTitle,
              style: TextStyle(
                fontSize: AppSizes.fontXL,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.color_lens),
            onPressed: _showThemeDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildSizeCard(BuildContext context, int size) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: AppSizes.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isDark
                  ? Theme.of(context).colorScheme.surface
                  : AppColors.lightBackground,
              isDark
                  ? Theme.of(context)
                      .colorScheme
                      .surface
                      .withOpacity(AppSizes.opacityHigh)
                  : Theme.of(context)
                      .colorScheme
                      .surface
                      .withOpacity(AppSizes.opacityMedium),
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(
                    isDark ? AppSizes.opacityHigh : AppSizes.opacityMedium),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSizes.radiusL),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    size == AppSizes.defaultBoardSize
                        ? Icons.grid_4x4
                        : Icons.grid_3x3,
                    size: AppSizes.iconL,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: AppSizes.paddingS),
                  Text(
                    '${size}x$size',
                    style: TextStyle(
                      fontSize: AppSizes.fontHuge,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final difficulty in DifficultyLevel.values) ...[
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: _buildDifficultyButton(context, size, difficulty),
                    ),
                    const SizedBox(height: AppSizes.paddingS),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyButton(
    BuildContext context,
    int size,
    DifficultyLevel difficulty,
  ) {
    return Hero(
      tag: 'game_${size}_${difficulty.name}',
      child: Material(
        color: Colors.transparent,
        child: ElevatedButton(
          onPressed: () {
            _controller.forward().then((_) {
              _controller.reverse();
              _navigateToGame(context, size, difficulty);
            });
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
            backgroundColor: _getDifficultyColor(difficulty),
            foregroundColor: AppColors.lightBackground,
            elevation: AppSizes.cardElevation,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_getDifficultyIcon(difficulty)),
              const SizedBox(width: AppSizes.paddingS),
              Text(
                difficulty.name,
                style: const TextStyle(
                  fontSize: AppSizes.fontL,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return AppColors.easyColor;
      case DifficultyLevel.medium:
        return AppColors.mediumColor;
      case DifficultyLevel.hard:
        return AppColors.hardColor;
    }
  }

  IconData _getDifficultyIcon(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return Icons.sentiment_satisfied;
      case DifficultyLevel.medium:
        return Icons.sentiment_neutral;
      case DifficultyLevel.hard:
        return Icons.sentiment_dissatisfied;
    }
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.selectTheme),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final theme in AppTheme.values)
              ListTile(
                title: Text(theme.name),
                leading: Icon(
                  Icons.circle,
                  color: _themeService.getTheme(theme).colorScheme.primary,
                ),
                onTap: () {
                  _themeService.currentTheme.value = theme;
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _navigateToGame(
    BuildContext context,
    int size,
    DifficultyLevel difficulty,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(
          size: size,
          difficulty: difficulty,
        ),
      ),
    );
  }
}
