import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lunadial/features/settings/application/app_settings_controller.dart';
import 'package:lunadial/features/settings/data/app_settings_repository.dart';
import 'package:lunadial/features/settings/domain/app_settings.dart';

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
