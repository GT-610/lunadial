import 'package:fl_lib/generated/l10n/lib_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lunadial/features/clock/domain/clock_layout.dart';
import 'package:lunadial/features/clock/presentation/widgets/analog_clock_panel.dart';
import 'package:lunadial/l10n/app_localizations.dart';

void main() {
  Future<void> pumpAnalogClock(
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
              return AnalogClockPanel(
                currentTime: DateTime(2026, 1, 1, 12, 34, 56),
                focusedDay: DateTime(2026, 1, 1),
                selectedDay: DateTime(2026, 1, 1),
                onDaySelected: (_) {},
                onPageChanged: (_) {},
                layout: resolveAnalogClockLayout(constraints.biggest),
              );
            },
          ),
        ),
      ),
    );
  }

  testWidgets('analog clock panel uses compact calendar on small screens', (
    tester,
  ) async {
    await pumpAnalogClock(tester, surfaceSize: const Size(320, 568));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('calendar-compact')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('analog clock panel stays stable on phone and tablet layouts', (
    tester,
  ) async {
    for (final size in const [
      Size(390, 844),
      Size(480, 900),
      Size(648, 626),
      Size(1280, 800),
    ]) {
      await pumpAnalogClock(tester, surfaceSize: size);
      await tester.pumpAndSettle();

      expect(find.byType(AnalogClockPanel), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets(
    'analog clock panel stays stable in draggable intermediate sizes',
    (tester) async {
      await pumpAnalogClock(tester, surfaceSize: const Size(648, 626));
      await tester.pumpAndSettle();

      expect(find.byType(AnalogClockPanel), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'analog clock panel keeps regular calendar density when vertical fallback still fits',
    (tester) async {
      await pumpAnalogClock(tester, surfaceSize: const Size(648, 626));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('calendar-regular')), findsOneWidget);
      expect(find.byKey(const Key('calendar-compact')), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
