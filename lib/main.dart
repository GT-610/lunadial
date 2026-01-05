import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/clock_home_page.dart';
import 'utils/app_data.dart';
import 'widgets/error_boundary.dart';

/// Main entry point of the application.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final appData = await AppData.initialize();

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
    return ErrorBoundary(
      child: Consumer<AppData>(
        builder: (context, appData, child) {
          return MaterialApp(
            title: 'LunaDial',
            debugShowCheckedModeBanner: false,
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
            home: const ClockHomePage(),
          );
        },
      ),
    );
  }
}

