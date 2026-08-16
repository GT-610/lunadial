import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'package:lunadial/features/settings/data/app_settings_repository.dart';
import 'package:lunadial/features/settings/domain/app_settings.dart';

class JsonAppSettingsRepository implements AppSettingsRepository {
  const JsonAppSettingsRepository({Future<File> Function()? fileProvider})
    : _fileProvider = fileProvider;

  final Future<File> Function()? _fileProvider;

  @override
  Future<AppSettings> load() async {
    try {
      final file = await _localFile;
      final settings = await _readSettings(file);
      if (settings != null) {
        await _deleteIfExists(_temporaryFileFor(file));
        return settings;
      }

      final temporaryFile = _temporaryFileFor(file);
      final recoveredSettings = await _readSettings(temporaryFile);
      if (recoveredSettings != null) {
        try {
          await temporaryFile.rename(file.path);
        } catch (_) {
          // The recovered settings are still usable for this session.
        }
        return recoveredSettings;
      }
    } catch (_) {
      // A corrupt or inaccessible settings file must not prevent startup.
    }

    return AppSettings.defaults();
  }

  @override
  Future<void> save(AppSettings settings) async {
    final file = await _localFile;
    await file.parent.create(recursive: true);
    final temporaryFile = _temporaryFileFor(file);

    try {
      await temporaryFile.writeAsString(
        json.encode(settings.toMap()),
        encoding: utf8,
        mode: FileMode.writeOnly,
        flush: true,
      );
      await temporaryFile.rename(file.path);
    } catch (_) {
      await _deleteIfExists(temporaryFile);
      rethrow;
    }
  }

  Future<File> get _localFile async {
    final fileProvider = _fileProvider;
    if (fileProvider != null) {
      return fileProvider();
    }

    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/settings.json');
  }

  static File _temporaryFileFor(File file) => File('${file.path}.tmp');

  static Future<AppSettings?> _readSettings(File file) async {
    try {
      if (!await file.exists()) {
        return null;
      }

      final contents = await file.readAsString(encoding: utf8);
      final decoded = json.decode(contents);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      return AppSettings.fromMap(decoded);
    } catch (_) {
      return null;
    }
  }

  static Future<void> _deleteIfExists(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Stale temporary files are safe to retry or clean up on the next run.
    }
  }
}
