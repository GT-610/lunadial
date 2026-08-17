import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:lunadial/features/settings/data/json_app_settings_repository.dart';
import 'package:lunadial/features/settings/domain/app_settings.dart';
import 'package:lunadial/features/settings/domain/app_theme_mode.dart';

void main() {
  late Directory temporaryDirectory;
  late File settingsFile;
  late JsonAppSettingsRepository repository;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'lunadial-settings-test-',
    );
    settingsFile = File('${temporaryDirectory.path}/settings.json');
    repository = JsonAppSettingsRepository(
      fileProvider: () async => settingsFile,
    );
  });

  tearDown(() async {
    await temporaryDirectory.delete(recursive: true);
  });

  test(
    'save replaces the settings file and leaves no temporary file',
    () async {
      final settings = AppSettings.defaults().copyWith(
        themeMode: AppThemeMode.dark,
        showSeconds: false,
      );

      await repository.save(settings);

      expect(await File('${settingsFile.path}.tmp').exists(), isFalse);
      expect((await repository.load()).toMap(), settings.toMap());
    },
  );

  test(
    'load recovers a complete temporary file after an interrupted save',
    () async {
      final settings = AppSettings.defaults().copyWith(keepScreenOn: true);
      await settingsFile.writeAsString('{broken json', flush: true);
      final temporaryFile = File('${settingsFile.path}.tmp');
      await temporaryFile.writeAsString(
        json.encode(settings.toMap()),
        flush: true,
      );

      final loaded = await repository.load();

      expect(loaded.toMap(), settings.toMap());
      expect(await temporaryFile.exists(), isFalse);
      expect((await repository.load()).toMap(), settings.toMap());
    },
  );

  test(
    'load recovers temporary settings when the primary object is invalid',
    () async {
      final settings = AppSettings.defaults().copyWith(
        themeMode: AppThemeMode.dark,
        keepScreenOn: true,
      );
      await settingsFile.writeAsString('{}', flush: true);
      final temporaryFile = File('${settingsFile.path}.tmp');
      await temporaryFile.writeAsString(
        json.encode(settings.toMap()),
        flush: true,
      );

      final loaded = await repository.load();

      expect(loaded.toMap(), settings.toMap());
      expect(await temporaryFile.exists(), isFalse);
      expect((await repository.load()).toMap(), settings.toMap());
    },
  );
}
