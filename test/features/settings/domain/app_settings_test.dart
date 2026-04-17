import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lunadial/features/settings/domain/app_locale_option.dart';
import 'package:lunadial/features/settings/domain/app_settings.dart';
import 'package:lunadial/features/settings/domain/clock_display_mode.dart';
import 'package:lunadial/features/settings/domain/time_format_preference.dart';

void main() {
  group('AppSettings', () {
    test('round-trips to and from map', () {
      const settings = AppSettings(
        themeColor: Colors.black,
        themeMode: ThemeMode.dark,
        keepScreenOn: true,
        dedicatedClockModeEnabled: true,
        restoreFullscreenOnLaunch: true,
        clockDisplayMode: ClockDisplayMode.analog,
        localeOption: AppLocaleOption.zhCn,
        timeFormatPreference: TimeFormatPreference.twelveHour,
        showSeconds: false,
        digitalClockLeadingZero: false,
      );

      final decoded = AppSettings.fromMap(settings.toMap());

      expect(decoded.themeColor, settings.themeColor);
      expect(decoded.themeMode, settings.themeMode);
      expect(decoded.keepScreenOn, settings.keepScreenOn);
      expect(
        decoded.dedicatedClockModeEnabled,
        settings.dedicatedClockModeEnabled,
      );
      expect(
        decoded.restoreFullscreenOnLaunch,
        settings.restoreFullscreenOnLaunch,
      );
      expect(decoded.clockDisplayMode, settings.clockDisplayMode);
      expect(decoded.localeOption, settings.localeOption);
      expect(decoded.timeFormatPreference, settings.timeFormatPreference);
      expect(decoded.showSeconds, settings.showSeconds);
      expect(decoded.digitalClockLeadingZero, settings.digitalClockLeadingZero);
    });

    test('falls back to defaults for invalid values', () {
      final settings = AppSettings.fromMap({
        'themeColor': 'invalid',
        'themeMode': 'unknown',
        'keepScreenOn': 'yes',
        'clockDisplayMode': 'broken',
        'selectedLocale': '???',
      });

      final defaults = AppSettings.defaults();
      expect(settings.themeColor, defaults.themeColor);
      expect(settings.themeMode, defaults.themeMode);
      expect(settings.keepScreenOn, defaults.keepScreenOn);
      expect(
        settings.dedicatedClockModeEnabled,
        defaults.dedicatedClockModeEnabled,
      );
      expect(
        settings.restoreFullscreenOnLaunch,
        defaults.restoreFullscreenOnLaunch,
      );
      expect(settings.clockDisplayMode, defaults.clockDisplayMode);
      expect(settings.localeOption, defaults.localeOption);
      expect(settings.timeFormatPreference, defaults.timeFormatPreference);
      expect(settings.showSeconds, defaults.showSeconds);
      expect(
        settings.digitalClockLeadingZero,
        defaults.digitalClockLeadingZero,
      );
    });

    test('migrates legacy digital clock flag', () {
      final settings = AppSettings.fromMap({
        'configVersion': 1,
        'selectedColor': '#ff000000',
        'themeMode': 'dark',
        'keepScreenOn': true,
        'isDigitalClock': false,
        'selectedLocale': 'en',
      });

      expect(settings.clockDisplayMode, ClockDisplayMode.analog);
      expect(settings.themeMode, ThemeMode.dark);
      expect(settings.localeOption, AppLocaleOption.en);
    });

    test(
      'launches to fullscreen only when dedicated mode and restore are on',
      () {
        expect(AppSettings.defaults().shouldLaunchToFullscreen, isFalse);

        const settings = AppSettings(
          themeColor: Colors.green,
          themeMode: ThemeMode.system,
          keepScreenOn: false,
          dedicatedClockModeEnabled: true,
          restoreFullscreenOnLaunch: true,
          clockDisplayMode: ClockDisplayMode.digital,
          localeOption: AppLocaleOption.system,
          timeFormatPreference: TimeFormatPreference.system,
          showSeconds: true,
          digitalClockLeadingZero: true,
        );

        expect(settings.shouldLaunchToFullscreen, isTrue);
      },
    );

    test('new display settings default for legacy configs', () {
      final settings = AppSettings.fromMap({
        'configVersion': 3,
        'themeColor': '#ff00ff00',
        'themeMode': 'system',
        'keepScreenOn': false,
        'dedicatedClockModeEnabled': false,
        'restoreFullscreenOnLaunch': false,
        'clockDisplayMode': 'digital',
        'selectedLocale': 'system',
      });

      expect(settings.timeFormatPreference, TimeFormatPreference.system);
      expect(settings.showSeconds, isTrue);
      expect(settings.digitalClockLeadingZero, isTrue);
    });
  });
}
