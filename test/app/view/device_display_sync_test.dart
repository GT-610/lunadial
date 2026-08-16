import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lunadial/app/view/device_display_sync.dart';
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

    testWidgets('applies immersiveSticky on Android', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const DeviceDisplaySync(
            debugPlatformOverride: TargetPlatform.android,
            child: SizedBox.shrink(),
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
    });
  });
}
