// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'LunaDial';

  @override
  String get settings => '设置';

  @override
  String get appearance => '外观';

  @override
  String get appearanceDescription => '自定义 LunaDial 的外观';

  @override
  String get themeColor => '主题颜色';

  @override
  String get themeColorDescription => '选择时钟的主色调';

  @override
  String get themeMode => '主题模式';

  @override
  String get themeModeDescription => '选择浅色、深色或跟随系统主题';

  @override
  String get screen => '屏幕';

  @override
  String get screenDescription => '配置屏幕行为';

  @override
  String get keepScreenOn => '保持屏幕常亮';

  @override
  String get keepScreenOnDescription => '防止屏幕关闭';

  @override
  String get clockStyle => '时钟样式';

  @override
  String get clockStyleDescription => '更改时间的显示方式';

  @override
  String get digitalClock => '数字时钟';

  @override
  String get analogClock => '模拟时钟';

  @override
  String get clockDisplayMode => '时钟显示模式';

  @override
  String get clockDisplayModeDescription => '在数字时钟和模拟时钟之间切换';

  @override
  String get digitalClockDescription => '使用数字格式而非模拟时钟';

  @override
  String get information => '关于';

  @override
  String get informationDescription => '了解更多关于 LunaDial 的信息';

  @override
  String get version => '版本';

  @override
  String get versionDescription => 'LunaDial 当前版本';

  @override
  String get license => '许可证';

  @override
  String get licenseDescription => '查看许可证信息';

  @override
  String get contributors => '贡献者';

  @override
  String get contributorsDescription => '项目贡献者列表';

  @override
  String get system => '跟随系统';

  @override
  String get light => '浅色';

  @override
  String get dark => '深色';

  @override
  String get selectThemeColor => '选择主题颜色';

  @override
  String get close => '关闭';

  @override
  String get language => '语言';

  @override
  String get languageDescription => '选择应用语言';

  @override
  String get english => '英语';

  @override
  String get chinese => '简体中文';

  @override
  String get sunday => '日';

  @override
  String get monday => '一';

  @override
  String get tuesday => '二';

  @override
  String get wednesday => '三';

  @override
  String get thursday => '四';

  @override
  String get friday => '五';

  @override
  String get saturday => '六';

  @override
  String get dateFormat => 'yyyy年M月d日 EEEE';

  @override
  String get calendarHeaderFormat => 'yyyy年M月';
}
