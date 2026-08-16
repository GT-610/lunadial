import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lunadial/app/view/device_display_sync.dart';
import 'package:lunadial/app/view/wakelock_sync.dart';
import 'package:lunadial/features/clock/presentation/pages/clock_home_page.dart';
import 'package:lunadial/features/settings/application/app_settings_controller.dart';
import 'package:lunadial/l10n/app_localizations.dart';
import 'package:lunadial/shared/presentation/app_error_shell.dart';
import 'package:lunadial/shared/presentation/app_theme_utils.dart';

final RouteObserver<ModalRoute<void>> appRouteObserver =
    RouteObserver<ModalRoute<void>>();

class LunaDialApp extends StatelessWidget {
  const LunaDialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettingsController>(
      builder: (context, settingsController, _) {
        final settings = settingsController.settings;

        return WakelockSync(
          child: DeviceDisplaySync(
            child: MaterialApp(
              key: ValueKey(settings.localeOption.storageValue),
              debugShowCheckedModeBanner: false,
              onGenerateTitle: (context) =>
                  AppLocalizations.of(context)!.appTitle,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: settings.localeOption.locale,
              localeListResolutionCallback: _resolveLocale,
              themeMode: settings.themeMode,
              theme: _buildTheme(
                brightness: Brightness.light,
                seedColor: settings.themeColor,
              ),
              darkTheme: _buildTheme(
                brightness: Brightness.dark,
                seedColor: settings.themeColor,
              ),
              navigatorObservers: [appRouteObserver],
              builder: (context, child) {
                return AppErrorShell(child: child ?? const SizedBox.shrink());
              },
              home: const ClockHomePage(),
            ),
          ),
        );
      },
    );
  }

  ThemeData _buildTheme({
    required Brightness brightness,
    required Color seedColor,
  }) {
    final theme = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: seedColor,
      brightness: brightness,
      scaffoldBackgroundColor: brightness == Brightness.dark
          ? pureBlackScaffoldBackground(seedColor)
          : null,
      appBarTheme: AppBarTheme(
        backgroundColor: brightness == Brightness.dark
            ? pureBlackAppBarBackground(seedColor)
            : null,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
    return applyPlatformFontFallback(theme);
  }

  Locale _resolveLocale(
    List<Locale>? locales,
    Iterable<Locale> supportedLocales,
  ) {
    if (locales == null || locales.isEmpty) {
      return supportedLocales.first;
    }

    for (final locale in locales) {
      for (final supportedLocale in supportedLocales) {
        if (supportedLocale == locale ||
            supportedLocale.languageCode == locale.languageCode) {
          return supportedLocale;
        }
      }
    }

    return supportedLocales.first;
  }
}
