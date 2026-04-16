import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:lunadial/features/clock/application/app_session_controller.dart';
import 'package:lunadial/features/clock/presentation/pages/clock_home_page.dart';
import 'package:lunadial/features/clock/presentation/widgets/analog_clock_panel.dart';
import 'package:lunadial/features/clock/presentation/widgets/digital_clock_view.dart';
import 'package:lunadial/features/settings/application/app_settings_controller.dart';
import 'package:lunadial/features/settings/data/app_settings_repository.dart';
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
          localizationsDelegates: AppLocalizations.localizationsDelegates,
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
