import 'package:fl_lib/fl_lib.dart' as fl;
import 'package:fl_lib/generated/l10n/lib_l10n.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lunadial/app/view/wakelock_sync.dart';
import 'package:lunadial/features/clock/presentation/pages/clock_home_page.dart';
import 'package:lunadial/features/settings/application/app_settings_controller.dart';
import 'package:lunadial/l10n/app_localizations.dart';
import 'package:lunadial/shared/presentation/app_error_shell.dart';
import 'package:lunadial/shared/presentation/app_theme_utils.dart';

class LunaDialApp extends StatelessWidget {
  const LunaDialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettingsController>(
      builder: (context, settingsController, _) {
        final settings = settingsController.settings;

        return WakelockSync(
          child: MaterialApp(
            title: 'LunaDial',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              LibLocalizations.delegate,
              ...AppLocalizations.localizationsDelegates,
            ],
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
            builder: (context, child) {
              return _LibL10nScope(
                child: AppErrorShell(child: child ?? const SizedBox.shrink()),
              );
            },
            home: const ClockHomePage(),
          ),
        );
      },
    );
  }

  ThemeData _buildTheme({
    required Brightness brightness,
    required Color seedColor,
  }) {
    return ThemeData(
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
  }
}

class _LibL10nScope extends StatefulWidget {
  const _LibL10nScope({required this.child});

  final Widget child;

  @override
  State<_LibL10nScope> createState() => _LibL10nScopeState();
}

class _LibL10nScopeState extends State<_LibL10nScope> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.setLibL10n();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
