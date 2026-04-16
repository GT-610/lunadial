import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'package:lunadial/features/settings/data/app_settings_repository.dart';
import 'package:lunadial/features/settings/domain/app_settings.dart';

class JsonAppSettingsRepository implements AppSettingsRepository {
  const JsonAppSettingsRepository();

  @override
  Future<AppSettings> load() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) {
        return AppSettings.defaults();
      }

      final contents = await file.readAsString(encoding: utf8);
      final decoded = json.decode(contents);
      if (decoded is! Map<String, dynamic>) {
        return AppSettings.defaults();
      }

      return AppSettings.fromMap(decoded);
    } catch (_) {
      return AppSettings.defaults();
    }
  }

  @override
  Future<void> save(AppSettings settings) async {
    final file = await _localFile;
    await file.writeAsString(
      json.encode(settings.toMap()),
      encoding: utf8,
      mode: FileMode.writeOnly,
    );
  }

  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/settings.json');
  }
}
