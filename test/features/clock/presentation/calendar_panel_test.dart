import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lunadial/features/clock/domain/clock_layout.dart';
import 'package:lunadial/features/clock/presentation/widgets/calendar_panel.dart';
import 'package:lunadial/l10n/app_localizations.dart';

void main() {
  testWidgets('calendar uses Sunday as the first column without an extra row', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SizedBox(
            width: 350,
            child: CalendarPanel(
              focusedDay: DateTime(2026, 2, 1),
              selectedDay: null,
              onDaySelected: (_) {},
              onPageChanged: (_) {},
              density: CalendarDensity.regular,
              today: DateTime(2026, 2, 15),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final grid = tester.widget<GridView>(find.byType(GridView));
    expect(grid.childrenDelegate.estimatedChildCount, 28);

    final gridLeft = tester.getTopLeft(find.byType(GridView)).dx;
    final firstDayLeft = tester
        .getTopLeft(find.byKey(const Key('calendar-day-1')))
        .dx;
    expect(firstDayLeft, closeTo(gridLeft, 0.01));
  });
}
