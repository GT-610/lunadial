import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:lunadial/app/view/wakelock_sync.dart';
import 'package:lunadial/features/settings/application/app_settings_controller.dart';
import 'package:lunadial/features/settings/data/app_settings_repository.dart';
import 'package:lunadial/features/settings/domain/app_settings.dart';
import 'package:lunadial/features/settings/domain/app_theme_mode.dart';

void main() {
  final originalPlatform = wakelockPlusPlatformInstance;
  late _FakeWakelockPlatform fakePlatform;

  setUp(() {
    fakePlatform = _FakeWakelockPlatform();
    wakelockPlusPlatformInstance = fakePlatform;
  });

  tearDown(() {
    wakelockPlusPlatformInstance = originalPlatform;
  });

  testWidgets('syncs only when keep-screen-on changes', (tester) async {
    final controller = AppSettingsController(
      repository: _MemorySettingsRepository(),
    );
    await controller.initialize();

    await tester.pumpWidget(
      ChangeNotifierProvider<AppSettingsController>.value(
        value: controller,
        child: const WakelockSync(child: SizedBox.shrink()),
      ),
    );

    expect(fakePlatform.toggles, [false]);

    await controller.setShowSeconds(false);
    expect(fakePlatform.toggles, [false]);

    await controller.setKeepScreenOn(true);
    expect(fakePlatform.toggles, [false, true]);

    await controller.setThemeMode(AppThemeMode.dark);
    expect(fakePlatform.toggles, [false, true]);

    await tester.pumpWidget(const SizedBox.shrink());
    expect(fakePlatform.toggles, [false, true, false]);

    controller.dispose();
  });

  testWidgets('ignores wakelock platform failures', (tester) async {
    wakelockPlusPlatformInstance = _FailingWakelockPlatform();
    final controller = AppSettingsController(
      repository: _MemorySettingsRepository(),
    );
    await controller.initialize();

    await tester.pumpWidget(
      ChangeNotifierProvider<AppSettingsController>.value(
        value: controller,
        child: const WakelockSync(child: SizedBox.shrink()),
      ),
    );
    await tester.pump();

    await controller.setKeepScreenOn(true);
    await tester.pump();

    expect(tester.takeException(), isNull);
    controller.dispose();
  });
}

class _FakeWakelockPlatform extends WakelockPlusWindowsPlugin {
  final List<bool> toggles = [];
  bool _enabled = false;

  @override
  Future<void> toggle({required bool enable}) async {
    toggles.add(enable);
    _enabled = enable;
  }

  @override
  Future<bool> get enabled async => _enabled;
}

class _FailingWakelockPlatform extends WakelockPlusWindowsPlugin {
  @override
  Future<void> toggle({required bool enable}) {
    return Future<void>.error(StateError('Wakelock unavailable'));
  }

  @override
  Future<bool> get enabled async => false;
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
