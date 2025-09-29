import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'app_data.dart';

class SettingsManager {
  // Get the local path for storing settings
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Get the local file for settings
  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/settings.json');
  }

  // Load settings from the local file
  Future<Map<String, dynamic>> loadSettings() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString(encoding: utf8);
      // 新增配置文件内容输出
      print('[DEBUG] 加载的配置文件内容: $contents');
      return json.decode(contents) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }

  // New method to initialize app data
  static Future<AppData> initializeAppData() async {
    return AppData.initialize();
  }

  // Save settings to the local file
  static Future<void> saveSettings(Map<String, dynamic> settings) async {
    final file = await _localFile;
    
    // DEBUG: 保存配置前输出提示
    print('[DEBUG] 正在保存配置...');
    print('保存路径: ${file.path}');
    print('配置内容: ${json.encode(settings)}');

    await file.writeAsString(
      json.encode(settings),
      encoding: utf8,
      mode: FileMode.writeOnly,
    );

    // DEBUG: 保存完成后输出提示
    print('[DEBUG] 配置保存完成 (${DateTime.now().toLocal()})');
    print('----------------------------------------');
  }
}