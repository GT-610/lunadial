import 'package:fl_lib/generated/l10n/lib_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lunadial/features/clock/presentation/widgets/digital_clock_view.dart';
import 'package:lunadial/l10n/app_localizations.dart';

void main() {
  testWidgets('digital clock view handles extremely small constraints', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(120, 120));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          LibLocalizations.delegate,
          ...AppLocalizations.localizationsDelegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: AppBar(),
          ),
          body: SizedBox(
            height: 30,
            child: DigitalClockView(
              currentTime: DateTime(2026, 1, 1, 12, 34, 56),
              fontSize: 200,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(DigitalClockView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
