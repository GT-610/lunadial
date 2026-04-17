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
  String get dedicatedClockMode => '专用时钟模式';

  @override
  String get dedicatedClockModeDescription =>
      '记住启动时的全屏时钟状态，减少界面干扰，更适合闲置设备长期展示。';

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
  String get timeDisplay => '时间显示';

  @override
  String get timeFormat => '时间格式';

  @override
  String get timeFormatDescription => '选择小时的显示方式';

  @override
  String get systemTimeFormat => '跟随系统';

  @override
  String get twelveHourFormat => '12 小时制';

  @override
  String get twentyFourHourFormat => '24 小时制';

  @override
  String get showSeconds => '显示秒';

  @override
  String get showSecondsDescription => '控制数字时钟秒显示和模拟时钟秒针显示';

  @override
  String get digitalClockLeadingZero => '小时补零';

  @override
  String get digitalClockLeadingZeroDescription => '在需要时为数字时钟小时补前导零';

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
  String get loading => '加载中...';

  @override
  String get tryAgain => '重试';

  @override
  String get unexpectedErrorTitle => '出了点问题';

  @override
  String get unexpectedErrorMessage => '发生了一个意外错误。请重试以重新构建当前界面。';

  @override
  String settingsSaveFailedMessage(String details) {
    return '设置保存失败。$details';
  }

  @override
  String get settingsSaveRetryFallback => '请稍后再试。';

  @override
  String get appDescription =>
      'LunaDial 是一个跨平台时钟应用，目标是把闲置屏幕变成优雅的常驻时钟。\n\n当前阶段重点在于整理结构、复用能力，并为后续功能打下干净基础。';

  @override
  String get contributorsDialogContent =>
      'LunaDial 正在为长期开发持续整理中。\n\n贡献者名单会随着项目演进逐步补充完善。当前请以仓库历史记录和已合并的拉取请求为准。';

  @override
  String get language => '语言';

  @override
  String get languageDescription => '选择应用语言';

  @override
  String get enterFullscreenMode => '进入全屏模式';

  @override
  String get exitFullscreenMode => '退出全屏模式';

  @override
  String get openSettings => '打开设置';

  @override
  String get digitalClockSemantics => '显示当前时间的数字时钟';

  @override
  String get analogClockSemantics => '带日历的模拟时钟';

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
