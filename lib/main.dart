import 'package:DesuClock/utils/settings_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/clock_home_page.dart';
import 'utils/app_data.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Main entry point of the application.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final appData = AppData();
  
  if (!kIsWeb) {
    final settings = await SettingsManager.loadSettings();
    
    if (settings.isEmpty) {
      await SettingsManager.saveSettings(appData.toMap());
    } else {
      appData.loadFromMap(settings);
    }
  }

  runApp(
    ChangeNotifierProvider.value(
      value: appData,
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