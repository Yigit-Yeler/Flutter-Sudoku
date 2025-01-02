enum AppTheme {
  light,
  dark,
  nature,
  ocean;

  String get name {
    switch (this) {
      case AppTheme.light:
        return 'Aydınlık';
      case AppTheme.dark:
        return 'Karanlık';
      case AppTheme.nature:
        return 'Doğa';
      case AppTheme.ocean:
        return 'Okyanus';
    }
  }
}
