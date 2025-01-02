import 'dart:math';

import '../constants/enums/difficulty_level.dart';

class SudokuService {
  List<List<int>> generateSudoku(int size, DifficultyLevel difficulty) {
    List<List<int>> board = List.generate(size, (_) => List.filled(size, 0));
    _fillDiagonal(board, size);
    _solveSudoku(board, size);
    return board;
  }

  void _fillDiagonal(List<List<int>> board, int size) {
    int boxSize = sqrt(size).floor();
    for (int box = 0; box < size; box += boxSize) {
      _fillBox(board, box, box, size);
    }
  }

  void _fillBox(List<List<int>> board, int row, int col, int size) {
    Random random = Random();
    int boxSize = sqrt(size).floor();
    List<int> numbers = List.generate(size, (i) => i + 1)..shuffle(random);
    int num = 0;

    for (int i = 0; i < boxSize; i++) {
      for (int j = 0; j < boxSize; j++) {
        board[row + i][col + j] = numbers[num];
        num++;
      }
    }
  }

  bool _solveSudoku(List<List<int>> board, int size) {
    int row = 0, col = 0;
    bool isEmpty = false;

    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (board[i][j] == 0) {
          row = i;
          col = j;
          isEmpty = true;
          break;
        }
      }
      if (isEmpty) break;
    }

    if (!isEmpty) return true;

    for (int num = 1; num <= size; num++) {
      if (_isSafe(board, row, col, num, size)) {
        board[row][col] = num;
        if (_solveSudoku(board, size)) return true;
        board[row][col] = 0;
      }
    }
    return false;
  }

  bool _isSafe(List<List<int>> board, int row, int col, int num, int size) {
    return !_usedInRow(board, row, num, size) &&
        !_usedInCol(board, col, num, size) &&
        !_usedInBox(board, row - row % sqrt(size).floor(),
            col - col % sqrt(size).floor(), num, size);
  }

  bool _usedInRow(List<List<int>> board, int row, int num, int size) {
    for (int col = 0; col < size; col++) {
      if (board[row][col] == num) return true;
    }
    return false;
  }

  bool _usedInCol(List<List<int>> board, int col, int num, int size) {
    for (int row = 0; row < size; row++) {
      if (board[row][col] == num) return true;
    }
    return false;
  }

  bool _usedInBox(List<List<int>> board, int boxStartRow, int boxStartCol,
      int num, int size) {
    int boxSize = sqrt(size).floor();
    for (int row = 0; row < boxSize; row++) {
      for (int col = 0; col < boxSize; col++) {
        if (board[row + boxStartRow][col + boxStartCol] == num) return true;
      }
    }
    return false;
  }

  void removeNumbers(
      List<List<int>> board, int size, DifficultyLevel difficulty) {
    Random random = Random();
    int cellsToRemove = (size * size * difficulty.emptyRatio).floor();

    while (cellsToRemove > 0) {
      int row = random.nextInt(size);
      int col = random.nextInt(size);

      if (board[row][col] != 0) {
        board[row][col] = 0;
        cellsToRemove--;
      }
    }
  }

  bool isValidMove(List<List<int>> board, int row, int col, int num, int size) {
    // Geçici olarak sayıyı kaldır
    int temp = board[row][col];
    board[row][col] = 0;

    bool isValid = _isSafe(board, row, col, num, size);

    // Sayıyı geri koy
    board[row][col] = temp;
    return isValid;
  }

  bool isSudokuComplete(List<List<int>> board) {
    int size = board.length;
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (board[i][j] == 0) return false;
      }
    }
    return true;
  }
}
