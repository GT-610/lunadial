import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'pages/clock_home_page.dart';
import 'utils/app_data.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'utils/settings_manager.dart';

/// Main entry point of the application.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final appData = AppData();
  
  if (!kIsWeb) {
    final settings = await SettingsManager().loadSettings();
    
    if (settings.isEmpty) {
      print('[DEBUG] 未找到配置文件，正在创建默认配置...');
      await SettingsManager.saveSettings(appData.toMap());
      print('[DEBUG] 默认配置已保存: ${appData.toMap()}');
    } else {
      try {
        print('[DEBUG] 找到现有配置: $settings');
        appData.loadFromMap(settings);
        print('[DEBUG] 配置加载完成: ${appData.toMap()}');
      } catch (e) {
        print('[ERROR] 配置加载失败: $e');
        print('[DEBUG] 配置损坏，正在覆盖写入默认配置...');
        await SettingsManager.saveSettings(appData.toMap());
        print('[DEBUG] 默认配置已覆盖保存: ${appData.toMap()}');
        appData.loadFromMap(appData.toMap());
      }
    }
  }
  
  // Set full-screen immersive mode for Android/iOS platforms.
  if (Platform.isAndroid || Platform.isIOS) {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky, overlays: []);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.restoreSystemUIOverlays();
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => AppData(),
      child: const MyApp(),
    ),
  );
}

/// Main application widget.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: (context, appData, child) {
        return MaterialApp(
          title: 'DesuClock',
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: appData.selectedColor,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: appData.selectedColor,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: appData.selectedColor == Colors.black ? Colors.black : null,
          ),
          themeMode: appData.themeMode,
          home: const ClockHomePage(), // Use ClockHomePage as the home screen
        );
      },
    );
  }
}

