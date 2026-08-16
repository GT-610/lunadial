import 'dart:async';

import 'package:flutter/material.dart';

import 'package:lunadial/features/settings/data/app_settings_repository.dart';
import 'package:lunadial/features/settings/domain/app_locale_option.dart';
import 'package:lunadial/features/settings/domain/app_settings.dart';
import 'package:lunadial/features/settings/domain/clock_display_mode.dart';
import 'package:lunadial/features/settings/domain/night_mode_behavior.dart';
import 'package:lunadial/features/settings/domain/time_format_preference.dart';

class AppSettingsController extends ChangeNotifier {
  final AppSettingsRepository repository;

  AppSettingsController({required this.repository});

  AppSettings _settings = AppSettings.defaults();
  Object? _saveError;
  AppSettings? _pendingSettings;
  Future<void>? _saveLoop;

  AppSettings get settings => _settings;
  Object? get saveError => _saveError;
  bool get hasSaveError => _saveError != null;

  Future<void> initialize() async {
    _settings = await repository.load();
    notifyListeners();
  }

  Future<void> setThemeColor(Color color) =>
      _update(_settings.copyWith(themeColor: color));

  Future<void> setUseDynamicColor(bool value) =>
      _update(_settings.copyWith(useDynamicColor: value));

  Future<void> setThemeMode(ThemeMode mode) =>
      _update(_settings.copyWith(themeMode: mode));

  Future<void> setKeepScreenOn(bool value) =>
      _update(_settings.copyWith(keepScreenOn: value));

  Future<void> setClockDisplayMode(ClockDisplayMode mode) =>
      _update(_settings.copyWith(clockDisplayMode: mode));

  Future<void> setLocaleOption(AppLocaleOption option) =>
      _update(_settings.copyWith(localeOption: option));

  Future<void> setTimeFormatPreference(TimeFormatPreference preference) =>
      _update(_settings.copyWith(timeFormatPreference: preference));

  Future<void> setShowSeconds(bool value) =>
      _update(_settings.copyWith(showSeconds: value));

  Future<void> setDigitalClockLeadingZero(bool value) =>
      _update(_settings.copyWith(digitalClockLeadingZero: value));

  Future<void> setNightModeBehavior(NightModeBehavior behavior) =>
      _update(_settings.copyWith(nightModeBehavior: behavior));

  Future<void> setNightModeStartTime(TimeOfDay time) =>
      _update(_settings.copyWith(nightModeStartTime: time));

  Future<void> setNightModeEndTime(TimeOfDay time) =>
      _update(_settings.copyWith(nightModeEndTime: time));

  Future<void> setBurnInProtectionEnabled(bool value) =>
      _update(_settings.copyWith(burnInProtectionEnabled: value));

  Future<void> retrySave() => _enqueueSave(_settings);

  Future<void> _update(AppSettings nextSettings) async {
    if (_settings == nextSettings) {
      return;
    }

    _settings = nextSettings;
    await _enqueueSave(nextSettings);
  }

  Future<void> _enqueueSave(AppSettings settingsToPersist) {
    _pendingSettings = settingsToPersist;
    _saveError = null;
    notifyListeners();

    return _saveLoop ??= _drainSaveQueue();
  }

  Future<void> _drainSaveQueue() async {
    try {
      while (_pendingSettings != null) {
        final settingsToPersist = _pendingSettings!;
        _pendingSettings = null;
        await repository.save(settingsToPersist);
      }
    } catch (error) {
      _pendingSettings = null;
      _saveError = error;
      notifyListeners();
    } finally {
      _saveLoop = null;
    }
  }
}
