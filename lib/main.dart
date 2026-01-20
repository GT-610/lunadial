import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
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
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: const [
              Locale('en'),
              Locale('zh', 'CN'),
            ],
            locale: _getLocale(appData.selectedLocale),
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

  Locale? _getLocale(String selectedLocale) {
    switch (selectedLocale) {
      case 'en':
        return const Locale('en');
      case 'zh_CN':
        return const Locale('zh', 'CN');
      case 'system':
        final systemLocale = PlatformDispatcher.instance.locale;
        final languageCode = systemLocale.languageCode;
        if (languageCode == 'zh_CN' || languageCode == 'zh') {
          return const Locale('zh', 'CN');
        } else {
          return const Locale('en');
        }
      default:
        return const Locale('en');
    }
  }
}

