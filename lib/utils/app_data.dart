import 'package:flutter/material.dart';
import 'settings_manager.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Data model for application settings.
class AppData extends ChangeNotifier {
  static const int configVersion = 1;
  
  void copyWith({
    int? colorValue,
    bool? isDigital,
    int? themeIndex,
    bool? keepOn,
    bool? fullscreen,
  }) {
    _selectedColor = Color(colorValue ?? _selectedColor.toARGB32());
    _isDigitalClock = isDigital ?? _isDigitalClock;
    _themeMode = ThemeMode.values[themeIndex ?? _themeMode.index];
    _keepScreenOn = keepOn ?? _keepScreenOn;
    _isFullscreen = fullscreen ?? _isFullscreen;
    notifyListeners();
  }

  // 修改初始化方法确保完整加载配置
  static Future<AppData> initialize() async {
    final appData = AppData();
    try {
      final settingsManager = SettingsManager();
      final settings = await settingsManager.loadSettings();
      
      if (settings.isNotEmpty) {
        appData.loadFromMap(settings);
      }
    } catch (e) {
      // Silently fail and use default values
    }
    
    return appData;
  }

  Color _selectedColor = Colors.green;
  bool _isDigitalClock = true;
  ThemeMode _themeMode = ThemeMode.system;
  bool _keepScreenOn = false;
  bool _isFullscreen = false;

  Color get selectedColor => _selectedColor;
  bool get isDigitalClock => _isDigitalClock;
  ThemeMode get themeMode => _themeMode;
  bool get keepScreenOn => _keepScreenOn;
  bool get isFullscreen => _isFullscreen;

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

  void setKeepScreenOn(bool value) {
    _keepScreenOn = value;
    if (value) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }
    notifyListeners();
  }

  void setFullscreen(bool value) {
    _isFullscreen = value;
    notifyListeners();
  }

  void loadFromMap(Map<String, dynamic> map) {
    if (!map.containsKey('selectedColor') ||
        !map.containsKey('isDigitalClock') ||
        !map.containsKey('themeMode')) {
      throw FormatException('配置文件缺少必要字段');
    }

    final savedVersion = map['configVersion'] ?? 0;
    if (savedVersion < configVersion) {
      _migrateConfig(savedVersion, map);
    } else {
      _loadCurrentConfig(map);
    }
  }

  void _migrateConfig(int fromVersion, Map<String, dynamic> map) {
    switch (fromVersion) {
      case 0:
        _loadCurrentConfig(map);
        break;
      default:
        _loadCurrentConfig(map);
    }
    notifyListeners();
  }

  void _loadCurrentConfig(Map<String, dynamic> map) {

    final colorValue = map['selectedColor'];
    if (colorValue is String) {
      try {
        _selectedColor = Color(int.parse(colorValue.replaceFirst('#', '0x')));
      } catch (e) {
        _selectedColor = Colors.green;
      }
    } else if (colorValue is int) {
      _selectedColor = Color(colorValue);
    } else {
      _selectedColor = Colors.green;
    }

    final themeModeValue = map['themeMode'];
    if (themeModeValue is String) {
      switch (themeModeValue.toLowerCase()) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        case 'system':
        default:
          _themeMode = ThemeMode.system;
          break;
      }
    } else if (themeModeValue is int && 
               themeModeValue >= 0 && 
               themeModeValue < ThemeMode.values.length) {
      _themeMode = ThemeMode.values[themeModeValue];
    } else {
      _themeMode = ThemeMode.system;
    }

    final isDigital = map['isDigitalClock'];
    if (isDigital is bool) {
      _isDigitalClock = isDigital;
    } else {
      _isDigitalClock = true;
    }

    final keepOn = map['keepScreenOn'];
    if (keepOn is bool) {
      _keepScreenOn = keepOn;
    } else {
      _keepScreenOn = false;
    }

    final fullscreen = map['isFullscreen'];
    if (fullscreen is bool) {
      _isFullscreen = fullscreen;
    } else {
      _isFullscreen = false;
    }

    notifyListeners();
  }

  Map<String, dynamic> toMap() {
    final configMap = {
      'configVersion': configVersion,
      'selectedColor': '#${_selectedColor.toARGB32().toRadixString(16).padLeft(8, '0')}',
      'isDigitalClock': _isDigitalClock,
      'themeMode': _themeMode.toString().split('.').last,
      'keepScreenOn': _keepScreenOn,
      'isFullscreen': _isFullscreen,
    };
    return configMap;
  }
}