import 'dart:math';

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_strings.dart';
import '../constants/enums/app_theme.dart';
import '../constants/enums/difficulty_level.dart';
import '../services/sudoku_service.dart';
import '../services/theme_service.dart';

class GameScreen extends StatefulWidget {
  final int size;
  final DifficultyLevel difficulty;

  const GameScreen({
    super.key,
    required this.size,
    required this.difficulty,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late List<List<int>> board;
  late List<List<bool>> isInitialNumber;
  final SudokuService _sudokuService = SudokuService();
  final ThemeService _themeService = ThemeService();
  int? selectedRow;
  int? selectedCol;
  late AnimationController _buttonController;
  late Animation<double> _buttonAnimation;
  late AnimationController _gridController;
  late Animation<double> _gridAnimation;
  late List<List<int>> _solution;

  @override
  void initState() {
    super.initState();
    _initializeGame();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: AppSizes.animFast),
      vsync: this,
    );
    _buttonAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _buttonController,
        curve: Curves.easeInOut,
      ),
    );

    _gridController = AnimationController(
      duration: const Duration(milliseconds: AppSizes.animVerySlow),
      vsync: this,
    );
    _gridAnimation = CurvedAnimation(
      parent: _gridController,
      curve: Curves.easeInOut,
    );
    _gridController.forward();
  }

  @override
  void dispose() {
    _buttonController.dispose();
    _gridController.dispose();
    super.dispose();
  }

  void _initializeGame() {
    _solution = _sudokuService.generateSudoku(widget.size, widget.difficulty);
    board = List.generate(
      widget.size,
      (i) => List.generate(widget.size, (j) => _solution[i][j]),
    );
    _sudokuService.removeNumbers(board, widget.size, widget.difficulty);

    isInitialNumber = List.generate(
      widget.size,
      (i) => List.generate(
        widget.size,
        (j) => board[i][j] != 0,
      ),
    );
  }

  void _onCellTap(int row, int col) {
    if (!isInitialNumber[row][col]) {
      setState(() {
        selectedRow = row;
        selectedCol = col;
      });
    }
  }

  void _onNumberSelected(int number) {
    if (selectedRow != null && selectedCol != null) {
      setState(() {
        board[selectedRow!][selectedCol!] = number;
      });
    }
  }

  Color _getCellColor(int row, int col) {
    if (selectedRow == row && selectedCol == col) {
      return _themeService
          .getSelectedCellColor(_themeService.currentTheme.value);
    }

    if (selectedRow != null &&
        selectedCol != null &&
        board[selectedRow!][selectedCol!] != 0 &&
        !isInitialNumber[selectedRow!][selectedCol!]) {
      int selectedNumber = board[selectedRow!][selectedCol!];

      if (_hasConflict(row, col, selectedNumber)) {
        return _themeService
            .getErrorCellColor(_themeService.currentTheme.value);
      }
    }

    return _themeService
        .getCellBackgroundColor(_themeService.currentTheme.value);
  }

  bool _hasConflict(int row, int col, int number) {
    if (board[row][col] == number &&
        (row != selectedRow || col != selectedCol)) {
      if (row == selectedRow) return true;
      if (col == selectedCol) return true;
      int boxSize = sqrt(widget.size).floor();
      int selectedBoxRow = selectedRow! ~/ boxSize;
      int selectedBoxCol = selectedCol! ~/ boxSize;
      int currentBoxRow = row ~/ boxSize;
      int currentBoxCol = col ~/ boxSize;
      if (selectedBoxRow == currentBoxRow && selectedBoxCol == currentBoxCol) {
        return true;
      }
    }
    return false;
  }

  void _checkSolution() {
    bool isComplete = true;
    for (int i = 0; i < widget.size; i++) {
      for (int j = 0; j < widget.size; j++) {
        if (board[i][j] == 0) {
          isComplete = false;
          break;
        }
      }
    }

    if (!isComplete) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
          ),
          title: const Text(AppStrings.incompleteWarning),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(AppStrings.understand),
            ),
          ],
        ),
      );
      return;
    }

    if (_sudokuService.isSudokuComplete(board)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
          ),
          title: const Text(AppStrings.congratulations),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.celebration,
                size: AppSizes.iconXXL,
                color: Colors.amber,
              ),
              const SizedBox(height: AppSizes.paddingM),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _initializeGame();
                    _gridController.reset();
                    _gridController.forward();
                  });
                },
                child: const Text(AppStrings.newGame),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _showSolution() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.2,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSizes.radiusXL),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: AppSizes.iconXL,
                height: AppSizes.borderThick,
                margin:
                    const EdgeInsets.symmetric(vertical: AppSizes.paddingXS),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(AppSizes.opacityMedium),
                  borderRadius: BorderRadius.circular(AppSizes.borderThin),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSizes.paddingM),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      AppStrings.solutionTitle,
                      style: TextStyle(
                        fontSize: AppSizes.fontXL,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.keyboard_arrow_down),
                      label: const Text(AppStrings.hideSheet),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.paddingM),
                    child: _buildSolutionGrid(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSolutionGrid(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: AppSizes.borderThick,
          ),
        ),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.size,
          ),
          itemCount: widget.size * widget.size,
          itemBuilder: (context, index) {
            int row = index ~/ widget.size;
            int col = index % widget.size;
            return Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    width: row % AppSizes.gridBoxSize == 0
                        ? AppSizes.borderThick
                        : AppSizes.borderThin,
                    color: Theme.of(context).dividerColor,
                  ),
                  bottom: BorderSide(
                    width: (row + 1) % AppSizes.gridBoxSize == 0
                        ? AppSizes.borderThick
                        : AppSizes.borderThin,
                    color: Theme.of(context).dividerColor,
                  ),
                  left: BorderSide(
                    width: col % AppSizes.gridBoxSize == 0
                        ? AppSizes.borderThick
                        : AppSizes.borderThin,
                    color: Theme.of(context).dividerColor,
                  ),
                  right: BorderSide(
                    width: (col + 1) % AppSizes.gridBoxSize == 0
                        ? AppSizes.borderThick
                        : AppSizes.borderThin,
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  _solution[row][col].toString(),
                  style: TextStyle(
                    fontSize: AppSizes.fontL,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _themeService.currentTheme,
      builder: (context, theme, _) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(context),
                  Expanded(
                    child: FadeTransition(
                      opacity: _gridAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.1),
                          end: Offset.zero,
                        ).animate(_gridAnimation),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSizes.paddingL),
                          child: _buildSudokuGrid(context),
                        ),
                      ),
                    ),
                  ),
                  _buildNumberPad(context),
                ],
              ),
            ),
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
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              '${AppStrings.appTitle} - ${widget.difficulty.name}',
              style: const TextStyle(
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

  Widget _buildSudokuGrid(BuildContext context) {
    return Card(
      elevation: AppSizes.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        child: GridView.builder(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.size,
            childAspectRatio: 1.0,
          ),
          itemCount: widget.size * widget.size,
          itemBuilder: (context, index) {
            int row = index ~/ widget.size;
            int col = index % widget.size;
            return _buildCell(context, row, col);
          },
        ),
      ),
    );
  }

  Widget _buildCell(BuildContext context, int row, int col) {
    return GestureDetector(
      onTap: () => _onCellTap(row, col),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: AppSizes.animFast),
        decoration: BoxDecoration(
          color: _getCellColor(row, col),
          border: Border(
            top: BorderSide(
              width: row % AppSizes.gridBoxSize == 0
                  ? AppSizes.borderThick
                  : AppSizes.borderThin,
              color: Theme.of(context).dividerColor,
            ),
            bottom: BorderSide(
              width: (row + 1) % AppSizes.gridBoxSize == 0
                  ? AppSizes.borderThick
                  : AppSizes.borderThin,
              color: Theme.of(context).dividerColor,
            ),
            left: BorderSide(
              width: col % AppSizes.gridBoxSize == 0
                  ? AppSizes.borderThick
                  : AppSizes.borderThin,
              color: Theme.of(context).dividerColor,
            ),
            right: BorderSide(
              width: (col + 1) % AppSizes.gridBoxSize == 0
                  ? AppSizes.borderThick
                  : AppSizes.borderThin,
              color: Theme.of(context).dividerColor,
            ),
          ),
          boxShadow: [
            if (selectedRow == row && selectedCol == col)
              BoxShadow(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withOpacity(AppSizes.opacityHigh),
                blurRadius: AppSizes.paddingL,
                spreadRadius: AppSizes.paddingXS,
              ),
          ],
        ),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: AppSizes.animFast),
            style: TextStyle(
              fontSize: AppSizes.fontL,
              fontWeight: isInitialNumber[row][col]
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: isInitialNumber[row][col]
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
            ),
            child: Text(
              board[row][col] == 0 ? '' : board[row][col].toString(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPad(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSizes.radiusXL)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: AppSizes.paddingL,
            spreadRadius: 0,
            offset: Offset(0, -AppSizes.paddingS),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppSizes.iconXL,
            height: AppSizes.borderThick,
            margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(AppSizes.opacityMedium),
              borderRadius: BorderRadius.circular(AppSizes.borderThin),
            ),
          ),
          Wrap(
            spacing: AppSizes.paddingS,
            runSpacing: AppSizes.paddingS,
            alignment: WrapAlignment.center,
            children: List.generate(
              widget.size,
              (index) => ScaleTransition(
                scale: _buttonAnimation,
                child: SizedBox(
                  width: AppSizes.buttonWidth,
                  height: AppSizes.buttonHeight,
                  child: ElevatedButton(
                    onPressed: () {
                      _buttonController.forward().then((_) {
                        _buttonController.reverse();
                      });
                      _onNumberSelected(index + 1);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      ),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(fontSize: AppSizes.fontXXL),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _checkSolution,
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                  ),
                  icon: const Icon(Icons.check_circle),
                  label: const Text(
                    AppStrings.checkSolution,
                    style: TextStyle(fontSize: AppSizes.fontL),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.paddingS),
              ElevatedButton(
                onPressed: _showSolution,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.paddingM,
                    horizontal: AppSizes.paddingM,
                  ),
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                ),
                child: const Icon(Icons.lightbulb),
              ),
            ],
          ),
        ],
      ),
    );
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
}
