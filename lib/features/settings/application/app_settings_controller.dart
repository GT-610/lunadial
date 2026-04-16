import 'dart:async';

import 'package:flutter/material.dart';

import 'package:lunadial/features/settings/data/app_settings_repository.dart';
import 'package:lunadial/features/settings/domain/app_locale_option.dart';
import 'package:lunadial/features/settings/domain/app_settings.dart';
import 'package:lunadial/features/settings/domain/clock_display_mode.dart';

class AppSettingsController extends ChangeNotifier {
  final AppSettingsRepository repository;

  AppSettingsController({required this.repository});

  AppSettings _settings = AppSettings.defaults();

  AppSettings get settings => _settings;

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

  Future<void> setClockDisplayMode(ClockDisplayMode mode) =>
      _update(_settings.copyWith(clockDisplayMode: mode));

  Future<void> setLocaleOption(AppLocaleOption option) =>
      _update(_settings.copyWith(localeOption: option));

  Future<void> _update(AppSettings nextSettings) async {
    if (_settings == nextSettings) {
      return;
    }

    _settings = nextSettings;
    notifyListeners();
    unawaited(repository.save(_settings));
  }
}
