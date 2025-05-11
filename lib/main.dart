import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'clock_home_page.dart';

/// Main entry point of the application.
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppData(),
      child: const MyApp(),
    ),
  );
}

/// Data model for application settings.
class AppData extends ChangeNotifier {
  Color _selectedColor = Colors.green;
  bool _isDigitalClock = true;

  Color get selectedColor => _selectedColor;
  bool get isDigitalClock => _isDigitalClock;

  /// Set the selected theme color.
  void setSelectedColor(Color color) {
    _selectedColor = color;
    notifyListeners();
  }

  /// Toggle between digital and analog clock styles.
  void toggleClockStyle() {
    _isDigitalClock = !_isDigitalClock;
    notifyListeners();
  }
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
          themeMode: ThemeMode.system,
          home: const ClockHomePage(), // Use ClockHomePage as the home screen
        );
      },
    );
  }
}

