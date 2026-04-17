import 'package:flutter/material.dart';

import 'package:lunadial/features/settings/domain/app_locale_option.dart';
import 'package:lunadial/features/settings/domain/clock_display_mode.dart';
import 'package:lunadial/features/settings/domain/time_format_preference.dart';

@immutable
class AppSettings {
  static const int configVersion = 1;

  final Color themeColor;
  final ThemeMode themeMode;
  final bool keepScreenOn;
  final bool dedicatedClockModeEnabled;
  final bool restoreFullscreenOnLaunch;
  final ClockDisplayMode clockDisplayMode;
  final AppLocaleOption localeOption;
  final TimeFormatPreference timeFormatPreference;
  final bool showSeconds;
  final bool digitalClockLeadingZero;

  const AppSettings({
    required this.themeColor,
    required this.themeMode,
    required this.keepScreenOn,
    required this.dedicatedClockModeEnabled,
    required this.restoreFullscreenOnLaunch,
    required this.clockDisplayMode,
    required this.localeOption,
    required this.timeFormatPreference,
    required this.showSeconds,
    required this.digitalClockLeadingZero,
  });

  factory AppSettings.defaults() {
    return const AppSettings(
      themeColor: Colors.green,
      themeMode: ThemeMode.system,
      keepScreenOn: false,
      dedicatedClockModeEnabled: false,
      restoreFullscreenOnLaunch: false,
      clockDisplayMode: ClockDisplayMode.digital,
      localeOption: AppLocaleOption.system,
      timeFormatPreference: TimeFormatPreference.system,
      showSeconds: true,
      digitalClockLeadingZero: true,
    );
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    final defaults = AppSettings.defaults();
    final normalizedMap = _needsLegacyMigration(map)
        ? _migrateLegacyMap(map)
        : map;

    return AppSettings(
      themeColor:
          _parseColor(normalizedMap['themeColor']) ?? defaults.themeColor,
      themeMode:
          _parseThemeMode(normalizedMap['themeMode']) ?? defaults.themeMode,
      keepScreenOn: normalizedMap['keepScreenOn'] is bool
          ? normalizedMap['keepScreenOn'] as bool
          : defaults.keepScreenOn,
      dedicatedClockModeEnabled:
          normalizedMap['dedicatedClockModeEnabled'] is bool
          ? normalizedMap['dedicatedClockModeEnabled'] as bool
          : defaults.dedicatedClockModeEnabled,
      restoreFullscreenOnLaunch:
          normalizedMap['restoreFullscreenOnLaunch'] is bool
          ? normalizedMap['restoreFullscreenOnLaunch'] as bool
          : defaults.restoreFullscreenOnLaunch,
      clockDisplayMode:
          _parseClockDisplayMode(
            normalizedMap['clockDisplayMode'],
            normalizedMap['isDigitalClock'],
          ) ??
          defaults.clockDisplayMode,
      localeOption: AppLocaleOption.fromStorageValue(
        normalizedMap['selectedLocale'],
      ),
      timeFormatPreference: TimeFormatPreferenceStorage.fromStorageValue(
        normalizedMap['timeFormatPreference'],
      ),
      showSeconds: normalizedMap['showSeconds'] is bool
          ? normalizedMap['showSeconds'] as bool
          : defaults.showSeconds,
      digitalClockLeadingZero: normalizedMap['digitalClockLeadingZero'] is bool
          ? normalizedMap['digitalClockLeadingZero'] as bool
          : defaults.digitalClockLeadingZero,
    );
  }

  AppSettings copyWith({
    Color? themeColor,
    ThemeMode? themeMode,
    bool? keepScreenOn,
    bool? dedicatedClockModeEnabled,
    bool? restoreFullscreenOnLaunch,
    ClockDisplayMode? clockDisplayMode,
    AppLocaleOption? localeOption,
    TimeFormatPreference? timeFormatPreference,
    bool? showSeconds,
    bool? digitalClockLeadingZero,
  }) {
    return AppSettings(
      themeColor: themeColor ?? this.themeColor,
      themeMode: themeMode ?? this.themeMode,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
      dedicatedClockModeEnabled:
          dedicatedClockModeEnabled ?? this.dedicatedClockModeEnabled,
      restoreFullscreenOnLaunch:
          restoreFullscreenOnLaunch ?? this.restoreFullscreenOnLaunch,
      clockDisplayMode: clockDisplayMode ?? this.clockDisplayMode,
      localeOption: localeOption ?? this.localeOption,
      timeFormatPreference: timeFormatPreference ?? this.timeFormatPreference,
      showSeconds: showSeconds ?? this.showSeconds,
      digitalClockLeadingZero:
          digitalClockLeadingZero ?? this.digitalClockLeadingZero,
    );
  }

  bool get shouldLaunchToFullscreen =>
      dedicatedClockModeEnabled && restoreFullscreenOnLaunch;

  Map<String, dynamic> toMap() {
    return {
      'configVersion': configVersion,
      'themeColor':
          '#${themeColor.toARGB32().toRadixString(16).padLeft(8, '0')}',
      'themeMode': themeMode.name,
      'keepScreenOn': keepScreenOn,
      'dedicatedClockModeEnabled': dedicatedClockModeEnabled,
      'restoreFullscreenOnLaunch': restoreFullscreenOnLaunch,
      'clockDisplayMode': clockDisplayMode.name,
      'selectedLocale': localeOption.storageValue,
      'timeFormatPreference': timeFormatPreference.storageValue,
      'showSeconds': showSeconds,
      'digitalClockLeadingZero': digitalClockLeadingZero,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is AppSettings &&
        other.themeColor == themeColor &&
        other.themeMode == themeMode &&
        other.keepScreenOn == keepScreenOn &&
        other.dedicatedClockModeEnabled == dedicatedClockModeEnabled &&
        other.restoreFullscreenOnLaunch == restoreFullscreenOnLaunch &&
        other.clockDisplayMode == clockDisplayMode &&
        other.localeOption == localeOption &&
        other.timeFormatPreference == timeFormatPreference &&
        other.showSeconds == showSeconds &&
        other.digitalClockLeadingZero == digitalClockLeadingZero;
  }

  @override
  int get hashCode => Object.hash(
    themeColor,
    themeMode,
    keepScreenOn,
    dedicatedClockModeEnabled,
    restoreFullscreenOnLaunch,
    clockDisplayMode,
    localeOption,
    timeFormatPreference,
    showSeconds,
    digitalClockLeadingZero,
  );

  static Map<String, dynamic> _migrateLegacyMap(
    Map<String, dynamic> legacyMap,
  ) {
    return {
      ...legacyMap,
      'themeColor': legacyMap['themeColor'] ?? legacyMap['selectedColor'],
      'clockDisplayMode':
          (legacyMap['isDigitalClock'] is bool &&
              legacyMap['isDigitalClock'] == false)
          ? ClockDisplayMode.analog.name
          : ClockDisplayMode.digital.name,
    };
  }

  static bool _needsLegacyMigration(Map<String, dynamic> map) {
    final hasLegacyColor = map.containsKey('selectedColor');
    final hasLegacyClockMode =
        map.containsKey('isDigitalClock') &&
        !map.containsKey('clockDisplayMode');

    return hasLegacyColor || hasLegacyClockMode;
  }

  static Color? _parseColor(Object? value) {
    if (value is int) {
      return Color(value);
    }

    if (value is String) {
      final normalized = value.replaceFirst('#', '0x');
      final parsed = int.tryParse(normalized);
      if (parsed != null) {
        return Color(parsed);
      }
    }

    return null;
  }

  static ThemeMode? _parseThemeMode(Object? value) {
    if (value is int && value >= 0 && value < ThemeMode.values.length) {
      return ThemeMode.values[value];
    }

    if (value is String) {
      return ThemeMode.values.cast<ThemeMode?>().firstWhere(
        (mode) => mode?.name == value,
        orElse: () => ThemeMode.system,
      );
    }

    return null;
  }

  static ClockDisplayMode? _parseClockDisplayMode(
    Object? displayMode,
    Object? legacyDigitalFlag,
  ) {
    if (displayMode is String) {
      return ClockDisplayMode.values.cast<ClockDisplayMode?>().firstWhere(
        (mode) => mode?.name == displayMode,
        orElse: () => null,
      );
    }

    if (legacyDigitalFlag is bool) {
      return legacyDigitalFlag
          ? ClockDisplayMode.digital
          : ClockDisplayMode.analog;
    }

    return null;
  }
}
