import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lunadial/features/settings/application/app_settings_controller.dart';
import 'package:lunadial/features/settings/data/app_settings_repository.dart';
import 'package:lunadial/features/settings/domain/app_settings.dart';
import 'package:lunadial/features/settings/domain/night_mode_behavior.dart';
import 'package:lunadial/features/settings/domain/time_format_preference.dart';

void main() {
  test('save failures become observable and retry clears the error', () async {
    final repository = _FailingSettingsRepository();
    final controller = AppSettingsController(repository: repository);
    await controller.initialize();

    await controller.setThemeMode(ThemeMode.dark);
    await Future<void>.delayed(Duration.zero);

    expect(controller.settings.themeMode, ThemeMode.dark);
    expect(controller.saveState, AppSettingsSaveState.error);
    expect(controller.saveError, isA<StateError>());

    repository.shouldFail = false;
    await controller.retrySave();

    expect(controller.saveState, AppSettingsSaveState.idle);
    expect(controller.saveError, isNull);
  });

  test('display settings update through controller', () async {
    final repository = _FailingSettingsRepository()..shouldFail = false;
    final controller = AppSettingsController(repository: repository);
    await controller.initialize();

    await controller.setTimeFormatPreference(TimeFormatPreference.twelveHour);
    await controller.setUseDynamicColor(false);
    await controller.setShowSeconds(false);
    await controller.setDigitalClockLeadingZero(false);

    expect(
      controller.settings.timeFormatPreference,
      TimeFormatPreference.twelveHour,
    );
    expect(controller.settings.useDynamicColor, isFalse);
    expect(controller.settings.showSeconds, isFalse);
    expect(controller.settings.digitalClockLeadingZero, isFalse);
  });

  test('night mode settings update through controller', () async {
    final repository = _FailingSettingsRepository()..shouldFail = false;
    final controller = AppSettingsController(repository: repository);
    await controller.initialize();

    await controller.setNightModeBehavior(NightModeBehavior.scheduled);
    await controller.setNightModeStartTime(
      const TimeOfDay(hour: 21, minute: 0),
    );
    await controller.setNightModeEndTime(const TimeOfDay(hour: 6, minute: 30));
    await controller.setBurnInProtectionEnabled(false);

    expect(controller.settings.nightModeBehavior, NightModeBehavior.scheduled);
    expect(
      controller.settings.nightModeStartTime,
      const TimeOfDay(hour: 21, minute: 0),
    );
    expect(
      controller.settings.nightModeEndTime,
      const TimeOfDay(hour: 6, minute: 30),
    );
    expect(controller.settings.burnInProtectionEnabled, isFalse);
  });

  test(
    'rapid updates are persisted in order without overlapping writes',
    () async {
      final repository = _ControllableSettingsRepository();
      final controller = AppSettingsController(repository: repository);
      await controller.initialize();

      final firstUpdate = controller.setThemeMode(ThemeMode.dark);
      await repository.waitForSaveCount(1);

      final secondUpdate = controller.setShowSeconds(false);
      await Future<void>.delayed(Duration.zero);

      expect(repository.saveCount, 1);
      expect(repository.maxConcurrentSaves, 1);

      repository.completeSave(0);
      await repository.waitForSaveCount(2);
      repository.completeSave(1);
      await Future.wait([firstUpdate, secondUpdate]);

      expect(repository.maxConcurrentSaves, 1);
      expect(repository.settings.themeMode, ThemeMode.dark);
      expect(repository.settings.showSeconds, isFalse);
      expect(controller.saveState, AppSettingsSaveState.idle);
    },
  );
}

class _FailingSettingsRepository implements AppSettingsRepository {
  bool shouldFail = true;
  AppSettings settings = AppSettings.defaults();

  @override
  Future<AppSettings> load() async => settings;

  @override
  Future<void> save(AppSettings settings) async {
    if (shouldFail) {
      throw StateError('disk unavailable');
    }

    this.settings = settings;
  }
}

class _ControllableSettingsRepository implements AppSettingsRepository {
  AppSettings settings = AppSettings.defaults();
  final List<Completer<void>> _saveCompleters = [];
  int _concurrentSaves = 0;
  int maxConcurrentSaves = 0;

  int get saveCount => _saveCompleters.length;

  @override
  Future<AppSettings> load() async => settings;

  @override
  Future<void> save(AppSettings settings) async {
    final completer = Completer<void>();
    _saveCompleters.add(completer);
    _concurrentSaves++;
    if (_concurrentSaves > maxConcurrentSaves) {
      maxConcurrentSaves = _concurrentSaves;
    }

    await completer.future;
    this.settings = settings;
    _concurrentSaves--;
  }

  void completeSave(int index) => _saveCompleters[index].complete();

  Future<void> waitForSaveCount(int expectedCount) async {
    while (saveCount < expectedCount) {
      await Future<void>.delayed(Duration.zero);
    }
  }
}
