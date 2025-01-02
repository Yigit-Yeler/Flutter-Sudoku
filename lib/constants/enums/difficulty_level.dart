enum DifficultyLevel {
  easy,
  medium,
  hard;

  String get name {
    switch (this) {
      case DifficultyLevel.easy:
        return 'Kolay';
      case DifficultyLevel.medium:
        return 'Orta';
      case DifficultyLevel.hard:
        return 'Zor';
    }
  }

  double get emptyRatio {
    switch (this) {
      case DifficultyLevel.easy:
        return 0.4; // %40 boş
      case DifficultyLevel.medium:
        return 0.5; // %50 boş
      case DifficultyLevel.hard:
        return 0.6; // %60 boş
    }
  }
}
