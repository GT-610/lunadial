import 'package:fl_lib/generated/l10n/lib_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lunadial/features/clock/domain/clock_layout.dart';
import 'package:lunadial/features/clock/presentation/widgets/digital_clock_view.dart';
import 'package:lunadial/l10n/app_localizations.dart';

void main() {
  Future<void> pumpDigitalClock(
    WidgetTester tester, {
    required Size surfaceSize,
  }) async {
    await tester.binding.setSurfaceSize(surfaceSize);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          LibLocalizations.delegate,
          ...AppLocalizations.localizationsDelegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: LayoutBuilder(
            builder: (context, constraints) {
              return DigitalClockView(
                currentTime: DateTime(2026, 1, 1, 12, 34, 56),
                layout: resolveDigitalClockLayout(constraints.biggest),
              );
            },
          ),
        ),
      ),
    );
  }

  testWidgets('digital clock view handles extremely small constraints', (
    tester,
  ) async {
    await pumpDigitalClock(tester, surfaceSize: const Size(120, 120));
    await tester.pumpAndSettle();

    expect(find.byType(DigitalClockView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'digital clock view remains stable across phone and tablet sizes',
    (tester) async {
      for (final size in const [
        Size(320, 568),
        Size(390, 844),
        Size(800, 1280),
        Size(1280, 800),
      ]) {
        await pumpDigitalClock(tester, surfaceSize: size);
        await tester.pumpAndSettle();

        expect(find.byType(DigitalClockView), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    },
  );
}
