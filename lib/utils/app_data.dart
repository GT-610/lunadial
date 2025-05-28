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

  // Serialize data to a map.
  void loadFromMap(Map<String, dynamic> map) {
    _selectedColor = Color(map['selectedColor'] ?? Colors.green.value);
    _isDigitalClock = map['isDigitalClock'] ?? true;
    _themeMode = ThemeMode.values[map['themeMode'] ?? ThemeMode.system.index];
    notifyListeners();
  }

  // Deserialize data from a map.
  Map<String, dynamic> toMap() {
    return {
      'selectedColor': _selectedColor.value,
      'isDigitalClock': _isDigitalClock,
      'themeMode': _themeMode.index,
    };
  }
}