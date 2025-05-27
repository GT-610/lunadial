import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'clock_home_page.dart';
import 'app_data.dart';
import 'dart:io' show Platform;

/// Main entry point of the application.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 仅针对Android/iOS平台设置全屏横屏
  if (Platform.isAndroid || Platform.isIOS) {
    // 设置全屏沉浸模式（隐藏状态栏和导航栏）
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky, overlays: []);
    // 设置屏幕方向为双横屏
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // 隐藏系统界面后强制更新布局
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

