import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lunadial/features/clock/domain/night_clock_display_config.dart';
import 'package:lunadial/features/settings/domain/app_locale_option.dart';
import 'package:lunadial/features/settings/domain/app_settings.dart';
import 'package:lunadial/features/settings/domain/clock_display_mode.dart';
import 'package:lunadial/features/settings/domain/night_mode_behavior.dart';
import 'package:lunadial/features/settings/domain/time_format_preference.dart';

void main() {
  const baseSettings = AppSettings(
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
    nightModeBehavior: NightModeBehavior.off,
    nightModeStartTime: TimeOfDay(hour: 22, minute: 0),
    nightModeEndTime: TimeOfDay(hour: 7, minute: 0),
    burnInProtectionEnabled: true,
    preferLandscapeInDedicatedMode: true,
  );

  test('off mode keeps night display inactive', () {
    final config = NightClockDisplayConfig.resolve(
      settings: baseSettings,
      currentTime: DateTime(2026, 4, 17, 23, 0),
      platformBrightness: Brightness.dark,
      isLandscape: true,
    );

    expect(config.isNightModeActive, isFalse);
    expect(config.shouldUseBurnInProtection, isFalse);
  });

  test('on mode always enables night display', () {
    final config = NightClockDisplayConfig.resolve(
      settings: baseSettings.copyWith(nightModeBehavior: NightModeBehavior.on),
      currentTime: DateTime(2026, 4, 17, 10, 0),
      platformBrightness: Brightness.light,
      isLandscape: false,
    );

    expect(config.isNightModeActive, isTrue);
    expect(config.shouldUseBurnInProtection, isTrue);
  });

  test('follow system mode matches platform brightness', () {
    final darkConfig = NightClockDisplayConfig.resolve(
      settings: baseSettings.copyWith(
        nightModeBehavior: NightModeBehavior.followSystem,
      ),
      currentTime: DateTime(2026, 4, 17, 10, 0),
      platformBrightness: Brightness.dark,
      isLandscape: false,
    );
    final lightConfig = NightClockDisplayConfig.resolve(
      settings: baseSettings.copyWith(
        nightModeBehavior: NightModeBehavior.followSystem,
      ),
      currentTime: DateTime(2026, 4, 17, 10, 0),
      platformBrightness: Brightness.light,
      isLandscape: false,
    );

    expect(darkConfig.isNightModeActive, isTrue);
    expect(lightConfig.isNightModeActive, isFalse);
  });

  test('scheduled mode handles same-day time windows', () {
    final settings = baseSettings.copyWith(
      nightModeBehavior: NightModeBehavior.scheduled,
      nightModeStartTime: const TimeOfDay(hour: 12, minute: 0),
      nightModeEndTime: const TimeOfDay(hour: 18, minute: 0),
    );

    final activeConfig = NightClockDisplayConfig.resolve(
      settings: settings,
      currentTime: DateTime(2026, 4, 17, 13, 0),
      platformBrightness: Brightness.light,
      isLandscape: true,
    );
    final inactiveConfig = NightClockDisplayConfig.resolve(
      settings: settings,
      currentTime: DateTime(2026, 4, 17, 19, 0),
      platformBrightness: Brightness.dark,
      isLandscape: true,
    );

    expect(activeConfig.isNightModeActive, isTrue);
    expect(inactiveConfig.isNightModeActive, isFalse);
  });

  test('scheduled mode handles overnight time windows', () {
    final settings = baseSettings.copyWith(
      nightModeBehavior: NightModeBehavior.scheduled,
      nightModeStartTime: const TimeOfDay(hour: 22, minute: 0),
      nightModeEndTime: const TimeOfDay(hour: 7, minute: 0),
    );

    final lateNightConfig = NightClockDisplayConfig.resolve(
      settings: settings,
      currentTime: DateTime(2026, 4, 17, 23, 30),
      platformBrightness: Brightness.light,
      isLandscape: true,
    );
    final earlyMorningConfig = NightClockDisplayConfig.resolve(
      settings: settings,
      currentTime: DateTime(2026, 4, 18, 6, 30),
      platformBrightness: Brightness.light,
      isLandscape: true,
    );
    final daytimeConfig = NightClockDisplayConfig.resolve(
      settings: settings,
      currentTime: DateTime(2026, 4, 18, 12, 0),
      platformBrightness: Brightness.dark,
      isLandscape: true,
    );

    expect(lateNightConfig.isNightModeActive, isTrue);
    expect(earlyMorningConfig.isNightModeActive, isTrue);
    expect(daytimeConfig.isNightModeActive, isFalse);
  });
}
