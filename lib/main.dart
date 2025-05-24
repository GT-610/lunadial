import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'clock_home_page.dart';
import 'app_data.dart';

/// Main entry point of the application.
void main() {
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

