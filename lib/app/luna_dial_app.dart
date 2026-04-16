import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lunadial/app/view/wakelock_sync.dart';
import 'package:lunadial/features/clock/presentation/pages/clock_home_page.dart';
import 'package:lunadial/features/settings/application/app_settings_controller.dart';
import 'package:lunadial/l10n/app_localizations.dart';
import 'package:lunadial/shared/presentation/app_error_boundary.dart';

class LunaDialApp extends StatelessWidget {
  const LunaDialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppErrorBoundary(
      child: Consumer<AppSettingsController>(
        builder: (context, settingsController, _) {
          final settings = settingsController.settings;

          return WakelockSync(
            child: MaterialApp(
              title: 'LunaDial',
              debugShowCheckedModeBanner: false,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: settings.localeOption.locale,
              themeMode: settings.themeMode,
              theme: _buildTheme(
                brightness: Brightness.light,
                seedColor: settings.themeColor,
              ),
              darkTheme: _buildTheme(
                brightness: Brightness.dark,
                seedColor: settings.themeColor,
              ),
              home: const ClockHomePage(),
            ),
          );
        },
      ),
    );
  }

  ThemeData _buildTheme({
    required Brightness brightness,
    required Color seedColor,
  }) {
    final isBlack = seedColor == Colors.black;
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: seedColor,
      brightness: brightness,
      scaffoldBackgroundColor: brightness == Brightness.dark && isBlack
          ? Colors.black
          : null,
      appBarTheme: AppBarTheme(
        backgroundColor: brightness == Brightness.dark && isBlack
            ? Colors.grey.shade900
            : null,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
