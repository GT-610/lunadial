import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lunadial/features/settings/domain/app_locale_option.dart';
import 'package:lunadial/features/settings/domain/app_settings.dart';
import 'package:lunadial/features/settings/domain/clock_display_mode.dart';
import 'package:lunadial/features/settings/domain/night_mode_behavior.dart';
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
        nightModeBehavior: NightModeBehavior.scheduled,
        nightModeStartTime: TimeOfDay(hour: 21, minute: 30),
        nightModeEndTime: TimeOfDay(hour: 6, minute: 45),
        burnInProtectionEnabled: false,
        preferLandscapeInDedicatedMode: false,
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
      expect(decoded.nightModeBehavior, settings.nightModeBehavior);
      expect(decoded.nightModeStartTime, settings.nightModeStartTime);
      expect(decoded.nightModeEndTime, settings.nightModeEndTime);
      expect(decoded.burnInProtectionEnabled, settings.burnInProtectionEnabled);
      expect(
        decoded.preferLandscapeInDedicatedMode,
        settings.preferLandscapeInDedicatedMode,
      );
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
      expect(settings.nightModeBehavior, defaults.nightModeBehavior);
      expect(settings.nightModeStartTime, defaults.nightModeStartTime);
      expect(settings.nightModeEndTime, defaults.nightModeEndTime);
      expect(
        settings.burnInProtectionEnabled,
        defaults.burnInProtectionEnabled,
      );
      expect(
        settings.preferLandscapeInDedicatedMode,
        defaults.preferLandscapeInDedicatedMode,
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
          nightModeBehavior: NightModeBehavior.off,
          nightModeStartTime: TimeOfDay(hour: 22, minute: 0),
          nightModeEndTime: TimeOfDay(hour: 7, minute: 0),
          burnInProtectionEnabled: true,
          preferLandscapeInDedicatedMode: true,
        );

        expect(settings.shouldLaunchToFullscreen, isTrue);
      },
    );

    test('new display settings default for legacy configs', () {
      final settings = AppSettings.fromMap({
        'configVersion': 1,
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
      expect(settings.nightModeBehavior, NightModeBehavior.off);
      expect(settings.nightModeStartTime, const TimeOfDay(hour: 22, minute: 0));
      expect(settings.nightModeEndTime, const TimeOfDay(hour: 7, minute: 0));
      expect(settings.burnInProtectionEnabled, isTrue);
      expect(settings.preferLandscapeInDedicatedMode, isTrue);
    });

    test('preserves clock display mode for pre-release v3 configs', () {
      final settings = AppSettings.fromMap({
        'configVersion': 3,
        'themeColor': '#ff00ff00',
        'themeMode': 'system',
        'keepScreenOn': false,
        'dedicatedClockModeEnabled': false,
        'restoreFullscreenOnLaunch': false,
        'clockDisplayMode': 'analog',
        'selectedLocale': 'system',
      });

      expect(settings.clockDisplayMode, ClockDisplayMode.analog);
      expect(settings.timeFormatPreference, TimeFormatPreference.system);
      expect(settings.showSeconds, isTrue);
      expect(settings.digitalClockLeadingZero, isTrue);
      expect(settings.nightModeBehavior, NightModeBehavior.off);
      expect(settings.burnInProtectionEnabled, isTrue);
      expect(settings.preferLandscapeInDedicatedMode, isTrue);
    });

    test('migrates legacy night mode bool into behavior enum', () {
      final enabledSettings = AppSettings.fromMap({'nightModeEnabled': true});
      final disabledSettings = AppSettings.fromMap({'nightModeEnabled': false});

      expect(enabledSettings.nightModeBehavior, NightModeBehavior.on);
      expect(disabledSettings.nightModeBehavior, NightModeBehavior.off);
    });
  });
}
