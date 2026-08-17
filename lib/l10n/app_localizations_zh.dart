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
  String get themeColor => '主题颜色';

  @override
  String get useDynamicColor => '使用系统动态色';

  @override
  String get useDynamicColorDescription => '系统支持时使用 Material You 或系统强调色，否则回退到自选颜色';

  @override
  String get themeMode => '主题模式';

  @override
  String get display => '显示';

  @override
  String get keepScreenOn => '保持屏幕常亮';

  @override
  String get nightAndBurnIn => '夜间与防烧屏';

  @override
  String get nightDisplayMode => '夜间显示策略';

  @override
  String get nightDisplayModeDescription => '选择 LunaDial 何时切换到更克制、更低干扰的夜间展示风格';

  @override
  String get nightModeOff => '关闭';

  @override
  String get nightModeOn => '始终开启';

  @override
  String get nightModeScheduled => '定时切换';

  @override
  String get nightModeFollowSystem => '跟随系统深色模式';

  @override
  String get nightModeOffDescription => '保持常规显示风格，不自动进入夜间展示';

  @override
  String get nightModeOnDescription => '始终使用更克制的暗色常驻展示风格';

  @override
  String get nightModeScheduledDescription => '按设定时段自动在日间与夜间展示之间切换';

  @override
  String get nightModeFollowSystemDescription => '在系统支持亮暗主题切换时，跟随系统深色模式自动切换';

  @override
  String get nightModeStartTime => '夜间开始时间';

  @override
  String get nightModeStartTimeDescription => '每天从这个时间开始使用夜间展示风格';

  @override
  String get nightModeEndTime => '夜间结束时间';

  @override
  String get nightModeEndTimeDescription => '每天在这个时间恢复常规显示风格';

  @override
  String get burnInProtection => '防烧屏位移';

  @override
  String get burnInProtectionDescription => '在夜间展示实际生效时进行轻微周期位移，降低静态画面长期停留的风险';

  @override
  String get digitalClock => '数字时钟';

  @override
  String get analogClock => '模拟时钟';

  @override
  String get clockDisplayMode => '时钟显示模式';

  @override
  String get timeFormat => '时间格式';

  @override
  String get systemTimeFormat => '跟随系统';

  @override
  String get twelveHourFormat => '12 小时制';

  @override
  String get twentyFourHourFormat => '24 小时制';

  @override
  String get showSeconds => '显示秒';

  @override
  String get digitalClockLeadingZero => '小时补零';

  @override
  String get digitalClockLeadingZeroDescription => '在需要时为数字时钟小时补前导零';

  @override
  String get information => '关于';

  @override
  String get version => '版本';

  @override
  String get license => '许可证';

  @override
  String get system => '跟随系统';

  @override
  String get light => '浅色';

  @override
  String get dark => '深色';

  @override
  String get oled => '纯黑（OLED）';

  @override
  String get selectThemeColor => '选择主题颜色';

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
  String get language => '语言';

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
