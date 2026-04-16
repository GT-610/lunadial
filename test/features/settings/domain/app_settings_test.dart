import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lunadial/features/settings/domain/app_locale_option.dart';
import 'package:lunadial/features/settings/domain/app_settings.dart';
import 'package:lunadial/features/settings/domain/clock_display_mode.dart';

void main() {
  group('AppSettings', () {
    test('round-trips to and from map', () {
      const settings = AppSettings(
        themeColor: Colors.black,
        themeMode: ThemeMode.dark,
        keepScreenOn: true,
        clockDisplayMode: ClockDisplayMode.analog,
        localeOption: AppLocaleOption.zhCn,
      );

      final decoded = AppSettings.fromMap(settings.toMap());

      expect(decoded.themeColor, settings.themeColor);
      expect(decoded.themeMode, settings.themeMode);
      expect(decoded.keepScreenOn, settings.keepScreenOn);
      expect(decoded.clockDisplayMode, settings.clockDisplayMode);
      expect(decoded.localeOption, settings.localeOption);
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
      expect(settings.clockDisplayMode, defaults.clockDisplayMode);
      expect(settings.localeOption, defaults.localeOption);
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
  });
}
