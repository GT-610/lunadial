import 'package:fl_lib/fl_lib.dart' as fl;
import 'package:fl_lib/generated/l10n/lib_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import 'package:lunadial/features/settings/application/app_settings_controller.dart';
import 'package:lunadial/features/settings/data/app_settings_repository.dart';
import 'package:lunadial/features/settings/domain/app_locale_option.dart';
import 'package:lunadial/features/settings/domain/app_settings.dart';
import 'package:lunadial/features/settings/domain/time_format_preference.dart';
import 'package:lunadial/features/settings/presentation/pages/settings_page.dart';
import 'package:lunadial/l10n/app_localizations.dart';

void main() {
  testWidgets(
    'settings page renders fl_lib style sections and updates display settings',
    (tester) async {
      PackageInfo.setMockInitialValues(
        appName: 'LunaDial',
        packageName: 'dev.lunadial.app',
        version: '0.4.0',
        buildNumber: '1',
        buildSignature: '',
      );

      final controller = AppSettingsController(
        repository: _MemorySettingsRepository(),
      );
      await controller.initialize();

      await tester.pumpWidget(
        ChangeNotifierProvider<AppSettingsController>.value(
          value: controller,
          child: MaterialApp(
            localizationsDelegates: const [
              LibLocalizations.delegate,
              ...AppLocalizations.localizationsDelegates,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SettingsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Dedicated Clock Mode'), findsOneWidget);
      expect(find.text('Time Display'), findsOneWidget);
      expect(find.byType(fl.CardX), findsWidgets);

      await tester.tap(
        find.descendant(
          of: find.widgetWithText(ListTile, 'Dedicated Clock Mode'),
          matching: find.byType(Switch),
        ),
      );
      await tester.pumpAndSettle();

      expect(controller.settings.dedicatedClockModeEnabled, isTrue);

      await tester.scrollUntilVisible(find.text('Time Format'), 200);
      await tester.tap(find.text('Time Format'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('12-hour'));
      await tester.pumpAndSettle();

      expect(
        controller.settings.timeFormatPreference,
        TimeFormatPreference.twelveHour,
      );

      await tester.scrollUntilVisible(find.text('Show Seconds'), 200);
      await tester.tap(
        find.descendant(
          of: find.widgetWithText(ListTile, 'Show Seconds'),
          matching: find.byType(Switch),
        ),
      );
      await tester.pumpAndSettle();
      expect(controller.settings.showSeconds, isFalse);

      await tester.scrollUntilVisible(find.text('Leading Zero for Hour'), 200);
      await tester.tap(
        find.descendant(
          of: find.widgetWithText(ListTile, 'Leading Zero for Hour'),
          matching: find.byType(Switch),
        ),
      );
      await tester.pumpAndSettle();
      expect(controller.settings.digitalClockLeadingZero, isFalse);

      await tester.ensureVisible(find.text('Language'));
      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      expect(controller.settings.localeOption, AppLocaleOption.en);
    },
  );
}

class _MemorySettingsRepository implements AppSettingsRepository {
  AppSettings _settings = AppSettings.defaults();

  @override
  Future<AppSettings> load() async => _settings;

  @override
  Future<void> save(AppSettings settings) async {
    _settings = settings;
  }
}
