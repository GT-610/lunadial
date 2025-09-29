import 'package:flutter/material.dart';
import 'settings_manager.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Data model for application settings.
class AppData extends ChangeNotifier {
  void copyWith({
    int? colorValue,
    bool? isDigital,
    int? themeIndex,
    bool? keepOn,
  }) {
    _selectedColor = Color(colorValue ?? _selectedColor.value);
    _isDigitalClock = isDigital ?? _isDigitalClock;
    _themeMode = ThemeMode.values[themeIndex ?? _themeMode.index];
    _keepScreenOn = keepOn ?? _keepScreenOn;
    notifyListeners();
  }

  // 修改初始化方法确保完整加载配置
  static Future<AppData> initialize() async {
    final appData = AppData();
    try {
      final settingsManager = SettingsManager();
      final settings = await settingsManager.loadSettings();
      
      if (settings.isNotEmpty) {
        print('[DEBUG] 配置数据不为空，开始加载...');
        appData.loadFromMap(settings);
      } else {
        print('[DEBUG] 配置数据为空，使用默认值');
      }
    } catch (e) {
      print('[ERROR] 加载配置时出错: $e');
      // 出错时使用默认值，不抛出异常
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
    // 使用 wakelock_plus 实现全平台屏幕常亮功能
    if (value) {
      WakelockPlus.enable();
      print('[DEBUG] 屏幕常亮已启用');
    } else {
      WakelockPlus.disable();
      print('[DEBUG] 屏幕常亮已禁用');
    }
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

    // 处理颜色值 - 支持字符串HEX格式和整数值
    final colorValue = map['selectedColor'];
    if (colorValue is String) {
      // 解析HEX颜色字符串
      try {
        _selectedColor = Color(int.parse(colorValue.replaceFirst('#', '0x')));
      } catch (e) {
        print('[ERROR] 无法解析颜色字符串: $colorValue');
        _selectedColor = Colors.green; // 默认颜色
      }
    } else if (colorValue is int) {
      _selectedColor = Color(colorValue);
    } else {
      print('[ERROR] 颜色值类型异常，使用默认颜色');
      _selectedColor = Colors.green; // 默认颜色
    }

    // 处理主题模式 - 支持字符串和索引值
    final themeModeValue = map['themeMode'];
    if (themeModeValue is String) {
      // 从字符串映射到ThemeMode枚举
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
      print('[ERROR] 主题模式类型异常，使用默认值');
      _themeMode = ThemeMode.system; // 默认主题
    }

    // 处理时钟样式
    final isDigital = map['isDigitalClock'];
    if (isDigital is bool) {
      _isDigitalClock = isDigital;
    } else {
      print('[ERROR] 时钟样式类型异常，使用默认值');
      _isDigitalClock = true; // 默认数字时钟
    }

    // 处理屏幕常亮状态（可选字段）
    final keepOn = map['keepScreenOn'];
    if (keepOn is bool) {
      _keepScreenOn = keepOn;
    } else {
      print('[DEBUG] 屏幕常亮状态未设置，使用默认值');
      _keepScreenOn = false; // 默认关闭
    }

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
    // 输出与app_settings.json格式一致的数据，使用字符串格式的颜色值和主题模式
    final configMap = {
      'selectedColor': '#${_selectedColor.value.toRadixString(16).padLeft(8, '0')}',
      'isDigitalClock': _isDigitalClock,
      'themeMode': _themeMode.toString().split('.').last,
      'keepScreenOn': _keepScreenOn,
    };
    print('[DEBUG] 序列化结果: $configMap');
    return configMap;
  }
}