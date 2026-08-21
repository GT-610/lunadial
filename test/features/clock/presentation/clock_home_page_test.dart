import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:lunadial/app/luna_dial_app.dart';
import 'package:lunadial/features/clock/application/clock_controller.dart';
import 'package:lunadial/features/clock/presentation/pages/clock_home_page.dart';
import 'package:lunadial/features/clock/presentation/widgets/analog_clock_panel.dart';
import 'package:lunadial/features/clock/presentation/widgets/burn_in_protection_layer.dart';
import 'package:lunadial/features/clock/presentation/widgets/digital_clock_view.dart';
import 'package:lunadial/features/settings/application/app_settings_controller.dart';
import 'package:lunadial/features/settings/data/app_settings_repository.dart';
import 'package:lunadial/features/settings/domain/app_locale_option.dart';
import 'package:lunadial/features/settings/domain/app_settings.dart';
import 'package:lunadial/features/settings/domain/app_theme_mode.dart';
import 'package:lunadial/features/settings/domain/clock_display_mode.dart';
import 'package:lunadial/features/settings/domain/night_mode_behavior.dart';
import 'package:lunadial/features/settings/domain/time_format_preference.dart';
import 'package:lunadial/features/settings/presentation/pages/settings_page.dart';
import 'package:lunadial/l10n/app_localizations.dart';

void main() {
  testWidgets('clock home page switches between digital and analog modes', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1600, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final settingsController = AppSettingsController(
      repository: _MemorySettingsRepository(),
    );
    await settingsController.initialize();

    await tester.pumpWidget(_buildApp(settingsController: settingsController));

    await tester.pumpAndSettle();
    expect(find.byType(DigitalClockView), findsOneWidget);

    await settingsController.setClockDisplayMode(ClockDisplayMode.analog);
    await tester.pumpAndSettle();

    expect(find.byType(AnalogClockPanel), findsOneWidget);
  });

  testWidgets(
    'clock home page stays stable when switching to analog at boundary window sizes',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(648, 626));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final settingsController = AppSettingsController(
        repository: _MemorySettingsRepository(),
      );
      await settingsController.initialize();

      await tester.pumpWidget(
        _buildApp(settingsController: settingsController),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DigitalClockView), findsOneWidget);

      await settingsController.setClockDisplayMode(ClockDisplayMode.analog);
      await tester.pumpAndSettle();

      expect(find.byType(AnalogClockPanel), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('digital clock remains stable on a small screen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 480));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final settingsController = AppSettingsController(
      repository: _MemorySettingsRepository(),
    );
    await settingsController.initialize();

    await tester.pumpWidget(_buildApp(settingsController: settingsController));
    await tester.pumpAndSettle();

    expect(find.byType(DigitalClockView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'settings button is initially visible, then auto hides and can be revealed',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final settingsController = AppSettingsController(
        repository: _MemorySettingsRepository(),
      );
      await settingsController.initialize();

      await tester.pumpWidget(
        _buildApp(settingsController: settingsController),
      );
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<IgnorePointer>(
              find.byKey(const Key('settings-ignore-pointer')),
            )
            .ignoring,
        isFalse,
      );

      await tester.pump(const Duration(seconds: 4));
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        tester
            .widget<IgnorePointer>(
              find.byKey(const Key('settings-ignore-pointer')),
            )
            .ignoring,
        isTrue,
      );

      await tester.tap(find.byKey(const Key('clock-surface')));
      await tester.pump();

      expect(
        tester
            .widget<IgnorePointer>(
              find.byKey(const Key('settings-ignore-pointer')),
            )
            .ignoring,
        isFalse,
      );

      await tester.tap(find.byKey(const Key('settings-reveal-button')));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsPage), findsOneWidget);
    },
  );

  testWidgets('clock ticker only runs on the foreground home route', (
    tester,
  ) async {
    final settingsController = AppSettingsController(
      repository: _MemorySettingsRepository(),
    );
    final clockController = ClockController(startTicker: false);
    await settingsController.initialize();

    await tester.pumpWidget(
      _buildApp(
        settingsController: settingsController,
        home: ClockHomePage.forTesting(clockController: clockController),
      ),
    );
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(clockController.isTicking, isTrue);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(clockController.isTicking, isFalse);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(clockController.isTicking, isTrue);

    await tester.tap(find.byKey(const Key('settings-reveal-button')));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsPage), findsOneWidget);
    expect(clockController.isTicking, isFalse);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(clockController.isTicking, isFalse);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(clockController.isTicking, isTrue);

    await tester.pumpWidget(const SizedBox.shrink());
    clockController.dispose();
  });

  testWidgets('clock home page stays stable across responsive breakpoints', (
    tester,
  ) async {
    final settingsController = AppSettingsController(
      repository: _MemorySettingsRepository(),
    );
    await settingsController.initialize();

    for (final size in const [
      Size(320, 568),
      Size(390, 844),
      Size(800, 1280),
      Size(1280, 800),
    ]) {
      await tester.binding.setSurfaceSize(size);

      await tester.pumpWidget(
        _buildApp(settingsController: settingsController),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ClockHomePage), findsOneWidget);
      expect(tester.takeException(), isNull);
    }

    addTearDown(() => tester.binding.setSurfaceSize(null));
  });

  testWidgets(
    'clock home page renders night mode in landscape without errors',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final settingsController = AppSettingsController(
        repository: _MemorySettingsRepository(
          initialSettings: const AppSettings(
            themeColor: Colors.green,
            themeMode: AppThemeMode.system,
            keepScreenOn: false,
            clockDisplayMode: ClockDisplayMode.digital,
            localeOption: AppLocaleOption.system,
            timeFormatPreference: TimeFormatPreference.system,
            showSeconds: true,
            digitalClockLeadingZero: true,
            nightModeBehavior: NightModeBehavior.on,
            nightModeStartTime: TimeOfDay(hour: 22, minute: 0),
            nightModeEndTime: TimeOfDay(hour: 7, minute: 0),
            burnInProtectionEnabled: true,
          ),
        ),
      );
      await settingsController.initialize();

      await tester.pumpWidget(
        _buildApp(settingsController: settingsController),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BurnInProtectionLayer), findsOneWidget);
      expect(find.byType(DigitalClockView), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

Widget _buildApp({
  required AppSettingsController settingsController,
  Widget home = const ClockHomePage(),
}) {
  return ChangeNotifierProvider<AppSettingsController>.value(
    value: settingsController,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      navigatorObservers: [appRouteObserver],
      home: home,
    ),
  );
}

class _MemorySettingsRepository implements AppSettingsRepository {
  _MemorySettingsRepository({AppSettings? initialSettings})
    : _settings = initialSettings ?? AppSettings.defaults();

  AppSettings _settings;

  @override
  Future<AppSettings> load() async => _settings;

  @override
  Future<void> save(AppSettings settings) async {
    _settings = settings;
  }
}
