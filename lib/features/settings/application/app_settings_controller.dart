import 'dart:async';

import 'package:flutter/material.dart';

import 'package:lunadial/features/settings/data/app_settings_repository.dart';
import 'package:lunadial/features/settings/domain/app_locale_option.dart';
import 'package:lunadial/features/settings/domain/app_settings.dart';
import 'package:lunadial/features/settings/domain/clock_display_mode.dart';
import 'package:lunadial/features/settings/domain/time_format_preference.dart';

enum AppSettingsSaveState { idle, saving, error }

class AppSettingsController extends ChangeNotifier {
  final AppSettingsRepository repository;

  AppSettingsController({required this.repository});

  AppSettings _settings = AppSettings.defaults();
  AppSettingsSaveState _saveState = AppSettingsSaveState.idle;
  Object? _saveError;
  int _saveOperationId = 0;

  AppSettings get settings => _settings;
  AppSettingsSaveState get saveState => _saveState;
  Object? get saveError => _saveError;
  bool get hasSaveError => _saveState == AppSettingsSaveState.error;

  Future<void> initialize() async {
    _settings = await repository.load();
    notifyListeners();
  }

  Future<void> setThemeColor(Color color) =>
      _update(_settings.copyWith(themeColor: color));

  Future<void> setThemeMode(ThemeMode mode) =>
      _update(_settings.copyWith(themeMode: mode));

  Future<void> setKeepScreenOn(bool value) =>
      _update(_settings.copyWith(keepScreenOn: value));

  Future<void> setDedicatedClockModeEnabled(bool value) {
    return _update(
      _settings.copyWith(
        dedicatedClockModeEnabled: value,
        restoreFullscreenOnLaunch: value
            ? _settings.restoreFullscreenOnLaunch
            : false,
      ),
    );
  }

  Future<void> setRestoreFullscreenOnLaunch(bool value) {
    if (!_settings.dedicatedClockModeEnabled && value) {
      return _update(
        _settings.copyWith(
          dedicatedClockModeEnabled: true,
          restoreFullscreenOnLaunch: true,
        ),
      );
    }

    return _update(_settings.copyWith(restoreFullscreenOnLaunch: value));
  }

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

  Future<void> retrySave() => _persist(_settings);

  Future<void> _update(AppSettings nextSettings) async {
    if (_settings == nextSettings) {
      return;
    }

    _settings = nextSettings;
    _saveState = AppSettingsSaveState.saving;
    _saveError = null;
    notifyListeners();
    unawaited(_persist(nextSettings));
  }

  Future<void> _persist(AppSettings settingsToPersist) async {
    final operationId = ++_saveOperationId;
    if (_saveState != AppSettingsSaveState.saving || _saveError != null) {
      _saveState = AppSettingsSaveState.saving;
      _saveError = null;
      notifyListeners();
    }

    try {
      await repository.save(settingsToPersist);
      if (operationId != _saveOperationId) {
        return;
      }
      _saveState = AppSettingsSaveState.idle;
      _saveError = null;
      notifyListeners();
    } catch (error) {
      if (operationId != _saveOperationId) {
        return;
      }
      _saveState = AppSettingsSaveState.error;
      _saveError = error;
      notifyListeners();
    }
  }
}
