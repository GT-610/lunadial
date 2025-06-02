import 'package:flutter/material.dart';
import 'settings_manager.dart';

/// Data model for application settings.
class AppData extends ChangeNotifier {
  // 新增初始化方法
  static Future<AppData> initialize() async {
    final appData = AppData();
    final settings = await SettingsManager().loadSettings();
    if (settings.isNotEmpty) {
      appData.loadFromMap(settings);
    }
    return appData;
  }

  Color _selectedColor = Colors.green;
  bool _isDigitalClock = true;
  ThemeMode _themeMode = ThemeMode.system;
  bool _keepScreenOn = false; // 新增屏幕常亮状态

  Color get selectedColor => _selectedColor;
  bool get isDigitalClock => _isDigitalClock;
  ThemeMode get themeMode => _themeMode;
  bool get keepScreenOn => _keepScreenOn; // 新增getter

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

  /// 设置屏幕常亮状态
  void setKeepScreenOn(bool value) {
    _keepScreenOn = value;
    notifyListeners();
  }

  void loadFromMap(Map<String, dynamic> map) {
    print('[DEBUG] 正在加载配置...');

    // 字段存在性校验
    if (!map.containsKey('selectedColor') ||
        !map.containsKey('isDigitalClock') ||
        !map.containsKey('themeMode')) {
      throw FormatException('配置文件缺少必要字段');
    }

    // 类型校验
    final colorValue = map['selectedColor'];
    if (colorValue is! int) {
      throw FormatException('颜色值类型异常，应为整数');
    }

    final themeIndex = map['themeMode'];
    if (themeIndex is! int || themeIndex < 0 || themeIndex >= ThemeMode.values.length) {
      throw FormatException('主题模式索引异常');
    }

    final isDigital = map['isDigitalClock'];
    if (isDigital is! bool) {
      throw FormatException('时钟样式类型异常');
    }

    final keepOn = map['keepScreenOn'];
    if (keepOn is! bool) {
      throw FormatException('屏幕常亮状态类型异常');
    }
    
    _selectedColor = Color(colorValue);
    _isDigitalClock = isDigital;
    _themeMode = ThemeMode.values[themeIndex];
    _keepScreenOn = keepOn;

    print('''
[DEBUG] 配置校验通过：
- 主题颜色: 0x${_selectedColor.value.toRadixString(16)}
- 时钟样式: ${_isDigitalClock ? '数字' : '模拟'}
- 主题模式: ${_themeMode.toString().split('.').last}
''');
    notifyListeners();
  }

  Map<String, dynamic> toMap() {
    print('[DEBUG] 正在序列化配置...');
    final configMap = {
      'selectedColor': _selectedColor.value,
      'isDigitalClock': _isDigitalClock,
      'themeMode': _themeMode.index,
      'keepScreenOn': _keepScreenOn,
    };
    print('[DEBUG] 序列化结果: $configMap');
    return configMap;
  }
}