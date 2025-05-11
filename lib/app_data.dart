import 'package:flutter/material.dart';

/// Data model for application settings.
class AppData extends ChangeNotifier {
  Color _selectedColor = Colors.green;
  bool _isDigitalClock = true;
  ThemeMode _themeMode = ThemeMode.system;

  Color get selectedColor => _selectedColor;
  bool get isDigitalClock => _isDigitalClock;
  ThemeMode get themeMode => _themeMode;

  /// Set the selected theme color.
  void setSelectedColor(Color color) {
    _selectedColor = color;
    notifyListeners();
  }

  /// Toggle between digital and analog clock styles.
  void toggleClockStyle() {
    _isDigitalClock = !_isDigitalClock;
    notifyListeners();
  }

  /// Set the theme mode (Light, Dark, System).
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}
