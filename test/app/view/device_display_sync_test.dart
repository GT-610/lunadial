import 'package:fl_lib/generated/l10n/lib_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:lunadial/app/view/device_display_sync.dart';
import 'package:lunadial/features/clock/application/app_session_controller.dart';
import 'package:lunadial/features/settings/application/app_settings_controller.dart';
import 'package:lunadial/features/settings/data/app_settings_repository.dart';
import 'package:lunadial/features/settings/domain/app_locale_option.dart';
import 'package:lunadial/features/settings/domain/app_settings.dart';
import 'package:lunadial/features/settings/domain/clock_display_mode.dart';
import 'package:lunadial/features/settings/domain/time_format_preference.dart';
import 'package:lunadial/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DeviceDisplaySync', () {
    final methodCalls = <MethodCall>[];

    setUp(() async {
      methodCalls.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            methodCalls.add(call);
            return null;
          });
    });

    tearDown(() async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    testWidgets(
      'applies landscape and immersive behavior in dedicated fullscreen mode',
      (tester) async {
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
              timeFormatPreference: TimeFormatPreference.system,
              showSeconds: true,
              digitalClockLeadingZero: true,
              nightModeEnabled: false,
              burnInProtectionEnabled: true,
              preferLandscapeInDedicatedMode: true,
            ),
          ),
        );
        await settingsController.initialize();
        final sessionController = AppSessionController(initialFullscreen: true);

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<AppSettingsController>.value(
                value: settingsController,
              ),
              ChangeNotifierProvider<AppSessionController>.value(
                value: sessionController,
              ),
            ],
            child: MaterialApp(
              localizationsDelegates: const [
                LibLocalizations.delegate,
                ...AppLocalizations.localizationsDelegates,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              home: const DeviceDisplaySync(
                debugPlatformOverride: TargetPlatform.android,
                child: SizedBox.shrink(),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(
          methodCalls.any(
            (call) => call.method == 'SystemChrome.setPreferredOrientations',
          ),
          isTrue,
        );
        expect(
          methodCalls.any(
            (call) => call.method == 'SystemChrome.setEnabledSystemUIMode',
          ),
          isTrue,
        );
      },
    );

    testWidgets(
      'restores fullscreen state when app resumes in dedicated mode',
      (tester) async {
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
              timeFormatPreference: TimeFormatPreference.system,
              showSeconds: true,
              digitalClockLeadingZero: true,
              nightModeEnabled: false,
              burnInProtectionEnabled: true,
              preferLandscapeInDedicatedMode: true,
            ),
          ),
        );
        await settingsController.initialize();
        final sessionController = AppSessionController(
          initialFullscreen: false,
        );

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<AppSettingsController>.value(
                value: settingsController,
              ),
              ChangeNotifierProvider<AppSessionController>.value(
                value: sessionController,
              ),
            ],
            child: MaterialApp(
              localizationsDelegates: const [
                LibLocalizations.delegate,
                ...AppLocalizations.localizationsDelegates,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              home: const DeviceDisplaySync(
                debugPlatformOverride: TargetPlatform.android,
                child: SizedBox.shrink(),
              ),
            ),
          ),
        );

        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pump();

        expect(sessionController.isFullscreen, isTrue);
      },
    );
  });
}

class _MemorySettingsRepository implements AppSettingsRepository {
  _MemorySettingsRepository({required AppSettings initialSettings})
    : _settings = initialSettings;

  AppSettings _settings;

  @override
  Future<AppSettings> load() async => _settings;

  @override
  Future<void> save(AppSettings settings) async {
    _settings = settings;
  }
}
