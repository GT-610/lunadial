import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class SettingsManager {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/settings.json');
  }

  static Future<Map<String, dynamic>> loadSettings() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString(encoding: utf8);
      return json.decode(contents) as Map<String, dynamic>;
    } catch (e) {
      return {}; // 返回空设置当文件不存在时
    }
  }

  static Future<void> saveSettings(Map<String, dynamic> settings) async {
    final file = await _localFile;
    await file.writeAsString(
      json.encode(settings),
      encoding: utf8,
      mode: FileMode.writeOnly,
    );
  }
}