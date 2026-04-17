// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'LunaDial';

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get appearanceDescription => 'Customize the look and feel of LunaDial';

  @override
  String get themeColor => 'Theme Color';

  @override
  String get themeColorDescription => 'Choose the primary color for the clock';

  @override
  String get themeMode => 'Theme Mode';

  @override
  String get themeModeDescription =>
      'Choose between light, dark, or system theme';

  @override
  String get screen => 'Screen';

  @override
  String get screenDescription => 'Configure screen behavior';

  @override
  String get keepScreenOn => 'Keep Screen On';

  @override
  String get keepScreenOnDescription => 'Prevent the screen from turning off';

  @override
  String get preferLandscapeInDedicatedMode =>
      'Prefer Landscape in Dedicated Mode';

  @override
  String get preferLandscapeInDedicatedModeDescription =>
      'Keep Android devices in landscape while dedicated clock mode is active';

  @override
  String get nightAndBurnIn => 'Night & Burn-In';

  @override
  String get nightMode => 'Night Mode';

  @override
  String get nightModeDescription =>
      'Use a calmer dark presentation designed for long landscape display sessions';

  @override
  String get burnInProtection => 'Burn-In Protection';

  @override
  String get burnInProtectionDescription =>
      'Apply a subtle periodic shift to reduce long-term static image retention in night mode';

  @override
  String get dedicatedClockMode => 'Dedicated Clock Mode';

  @override
  String get dedicatedClockModeDescription =>
      'Remember fullscreen clock state on launch and reduce distractions for spare devices.';

  @override
  String get clockStyle => 'Clock Style';

  @override
  String get clockStyleDescription => 'Change how the time is displayed';

  @override
  String get digitalClock => 'Digital Clock';

  @override
  String get analogClock => 'Analog Clock';

  @override
  String get clockDisplayMode => 'Clock Display Mode';

  @override
  String get clockDisplayModeDescription =>
      'Choose between digital and analog clock styles';

  @override
  String get timeDisplay => 'Time Display';

  @override
  String get timeFormat => 'Time Format';

  @override
  String get timeFormatDescription => 'Choose how the clock formats hours';

  @override
  String get systemTimeFormat => 'Follow System';

  @override
  String get twelveHourFormat => '12-hour';

  @override
  String get twentyFourHourFormat => '24-hour';

  @override
  String get showSeconds => 'Show Seconds';

  @override
  String get showSecondsDescription =>
      'Show seconds in the digital clock and analog second hand';

  @override
  String get digitalClockLeadingZero => 'Leading Zero for Hour';

  @override
  String get digitalClockLeadingZeroDescription =>
      'Pad the digital clock hour with a leading zero when needed';

  @override
  String get digitalClockDescription => 'Use digital format instead of analog';

  @override
  String get information => 'Information';

  @override
  String get informationDescription => 'Learn more about LunaDial';

  @override
  String get version => 'Version';

  @override
  String get versionDescription => 'Current version of LunaDial';

  @override
  String get license => 'License';

  @override
  String get licenseDescription => 'View license information';

  @override
  String get contributors => 'Contributors';

  @override
  String get contributorsDescription => 'List of contributors to this project';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get selectThemeColor => 'Select Theme Color';

  @override
  String get close => 'Close';

  @override
  String get loading => 'Loading...';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get unexpectedErrorTitle => 'Something went wrong';

  @override
  String get unexpectedErrorMessage =>
      'An unexpected error occurred. Try again to rebuild the screen.';

  @override
  String settingsSaveFailedMessage(String details) {
    return 'Settings could not be saved. $details';
  }

  @override
  String get settingsSaveRetryFallback => 'Please try again.';

  @override
  String get appDescription =>
      'LunaDial is a cross-platform clock app focused on turning spare screens into elegant full-time clocks.\n\nThis stage emphasizes structure, reuse, and a clean base for future features.';

  @override
  String get contributorsDialogContent =>
      'LunaDial is being organized for long-term development.\n\nContributor credits will continue to be expanded as the project evolves. Please refer to the repository history and merged pull requests for the latest record.';

  @override
  String get language => 'Language';

  @override
  String get languageDescription => 'Choose the app language';

  @override
  String get enterFullscreenMode => 'Enter fullscreen mode';

  @override
  String get exitFullscreenMode => 'Exit fullscreen mode';

  @override
  String get openSettings => 'Open settings';

  @override
  String get digitalClockSemantics => 'Digital clock showing current time';

  @override
  String get analogClockSemantics => 'Analog clock with calendar';

  @override
  String get english => 'English';

  @override
  String get chinese => 'Simplified Chinese';

  @override
  String get sunday => 'Sun';

  @override
  String get monday => 'Mon';

  @override
  String get tuesday => 'Tue';

  @override
  String get wednesday => 'Wed';

  @override
  String get thursday => 'Thu';

  @override
  String get friday => 'Fri';

  @override
  String get saturday => 'Sat';

  @override
  String get dateFormat => 'EEEE, MMMM d, yyyy';

  @override
  String get calendarHeaderFormat => 'MMMM yyyy';
}
