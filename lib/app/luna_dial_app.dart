import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lunadial/app/view/device_display_sync.dart';
import 'package:lunadial/app/view/wakelock_sync.dart';
import 'package:lunadial/features/clock/presentation/pages/clock_home_page.dart';
import 'package:lunadial/features/settings/application/app_settings_controller.dart';
import 'package:lunadial/features/settings/domain/app_theme_mode.dart';
import 'package:lunadial/l10n/app_localizations.dart';
import 'package:lunadial/shared/presentation/app_error_shell.dart';
import 'package:lunadial/shared/presentation/app_theme_utils.dart';

final RouteObserver<ModalRoute<void>> appRouteObserver =
    RouteObserver<ModalRoute<void>>();

class LunaDialApp extends StatelessWidget {
  const LunaDialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return Consumer<AppSettingsController>(
          builder: (context, settingsController, _) {
            final settings = settingsController.settings;
            final lightColorScheme = resolveAppColorScheme(
              brightness: Brightness.light,
              seedColor: settings.themeColor,
              useDynamicColor: settings.useDynamicColor,
              dynamicColorScheme: lightDynamic,
            );
            final darkColorScheme = resolveAppColorScheme(
              brightness: Brightness.dark,
              seedColor: settings.themeColor,
              useDynamicColor: settings.useDynamicColor,
              dynamicColorScheme: darkDynamic,
            );
            final usePureBlack = settings.themeMode == AppThemeMode.oled;

            return WakelockSync(
              child: DeviceDisplaySync(
                child: MaterialApp(
                  key: ValueKey(settings.localeOption.storageValue),
                  debugShowCheckedModeBanner: false,
                  onGenerateTitle: (context) =>
                      AppLocalizations.of(context)!.appTitle,
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  locale: settings.localeOption.locale,
                  localeListResolutionCallback: _resolveLocale,
                  themeMode: settings.themeMode.materialThemeMode,
                  theme: _buildTheme(
                    colorScheme: lightColorScheme,
                    usePureBlack: false,
                  ),
                  darkTheme: _buildTheme(
                    colorScheme: darkColorScheme,
                    usePureBlack: usePureBlack,
                  ),
                  navigatorObservers: [appRouteObserver],
                  builder: (context, child) {
                    return AppErrorShell(
                      child: child ?? const SizedBox.shrink(),
                    );
                  },
                  home: const ClockHomePage(),
                ),
              ),
            );
          },
        );
      },
    );
  }

  ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required bool usePureBlack,
  }) {
    final resolvedColorScheme = usePureBlack
        ? colorScheme.copyWith(surface: Colors.black)
        : colorScheme;
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: resolvedColorScheme,
      scaffoldBackgroundColor: usePureBlack ? Colors.black : null,
      appBarTheme: AppBarTheme(
        backgroundColor: usePureBlack ? Colors.black : null,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: usePureBlack ? Colors.black : null,
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
