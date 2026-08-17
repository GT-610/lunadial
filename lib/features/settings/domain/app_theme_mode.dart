import 'package:flutter/material.dart';

enum AppThemeMode { system, light, dark, oled }

extension AppThemeModeStorage on AppThemeMode {
  ThemeMode get materialThemeMode {
    switch (this) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
      case AppThemeMode.oled:
        return ThemeMode.dark;
    }
  }

  static AppThemeMode fromStorageValue(Object? value) {
    if (value is int && value >= 0 && value < AppThemeMode.values.length) {
      return AppThemeMode.values[value];
    }

    if (value is String) {
      return AppThemeMode.values.cast<AppThemeMode?>().firstWhere(
            (mode) => mode?.name == value,
            orElse: () => AppThemeMode.system,
          ) ??
          AppThemeMode.system;
    }

    return AppThemeMode.system;
  }
}
