import 'package:fl_lib/generated/l10n/lib_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:lunadial/features/clock/application/app_session_controller.dart';
import 'package:lunadial/features/clock/presentation/pages/clock_home_page.dart';
import 'package:lunadial/features/clock/presentation/widgets/analog_clock_panel.dart';
import 'package:lunadial/features/clock/presentation/widgets/digital_clock_view.dart';
import 'package:lunadial/features/settings/application/app_settings_controller.dart';
import 'package:lunadial/features/settings/data/app_settings_repository.dart';
import 'package:lunadial/features/settings/domain/app_locale_option.dart';
import 'package:lunadial/features/settings/domain/app_settings.dart';
import 'package:lunadial/features/settings/domain/clock_display_mode.dart';
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

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppSettingsController>.value(
            value: settingsController,
          ),
          ChangeNotifierProvider<AppSessionController>(
            create: (_) => AppSessionController(),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            LibLocalizations.delegate,
            ...AppLocalizations.localizationsDelegates,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ClockHomePage(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(DigitalClockView), findsOneWidget);

    await settingsController.setClockDisplayMode(ClockDisplayMode.analog);
    await tester.pumpAndSettle();

    expect(find.byType(AnalogClockPanel), findsOneWidget);
  });

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

  testWidgets('fullscreen exit button auto hides and can be revealed again', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final settingsController = AppSettingsController(
      repository: _MemorySettingsRepository(),
    );
    await settingsController.initialize();

    await tester.pumpWidget(_buildApp(settingsController: settingsController));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('enter-fullscreen-button')));
    await tester.pump();

    expect(
      tester
          .widget<IgnorePointer>(
            find.byKey(const Key('fullscreen-exit-ignore-pointer')),
          )
          .ignoring,
      isFalse,
    );

    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      tester
          .widget<IgnorePointer>(
            find.byKey(const Key('fullscreen-exit-ignore-pointer')),
          )
          .ignoring,
      isTrue,
    );

    await tester.tap(find.byKey(const Key('fullscreen-surface')));
    await tester.pump();

    expect(
      tester
          .widget<IgnorePointer>(
            find.byKey(const Key('fullscreen-exit-ignore-pointer')),
          )
          .ignoring,
      isFalse,
    );

    await tester.tap(find.byKey(const Key('fullscreen-exit-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('enter-fullscreen-button')), findsOneWidget);
  });

  testWidgets('dedicated clock mode restores fullscreen on startup', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final settingsController = AppSettingsController(
      repository: _MemorySettingsRepository(
        initialSettings: const AppSettings(
          themeColor: Colors.green,
          themeMode: ThemeMode.system,
          keepScreenOn: false,
          dedicatedClockModeEnabled: true,
          restoreFullscreenOnLaunch: true,
          clockDisplayMode: ClockDisplayMode.digital,
          localeOption: AppLocaleOption.system,
        ),
      ),
    );
    await settingsController.initialize();

    await tester.pumpWidget(
      _buildApp(
        settingsController: settingsController,
        sessionController: AppSessionController(
          initialFullscreen:
              settingsController.settings.shouldLaunchToFullscreen,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('fullscreen-surface')), findsOneWidget);
    expect(find.byKey(const Key('enter-fullscreen-button')), findsNothing);
  });

  testWidgets('fullscreen is not restored when dedicated mode is disabled', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final settingsController = AppSettingsController(
      repository: _MemorySettingsRepository(
        initialSettings: const AppSettings(
          themeColor: Colors.green,
          themeMode: ThemeMode.system,
          keepScreenOn: false,
          dedicatedClockModeEnabled: false,
          restoreFullscreenOnLaunch: true,
          clockDisplayMode: ClockDisplayMode.digital,
          localeOption: AppLocaleOption.system,
        ),
      ),
    );
    await settingsController.initialize();

    await tester.pumpWidget(
      _buildApp(
        settingsController: settingsController,
        sessionController: AppSessionController(
          initialFullscreen:
              settingsController.settings.shouldLaunchToFullscreen,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('fullscreen-surface')), findsNothing);
    expect(find.byKey(const Key('enter-fullscreen-button')), findsOneWidget);
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
}

Widget _buildApp({
  required AppSettingsController settingsController,
  AppSessionController? sessionController,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AppSettingsController>.value(
        value: settingsController,
      ),
      ChangeNotifierProvider<AppSessionController>.value(
        value: sessionController ?? AppSessionController(),
      ),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        LibLocalizations.delegate,
        ...AppLocalizations.localizationsDelegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const ClockHomePage(),
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
