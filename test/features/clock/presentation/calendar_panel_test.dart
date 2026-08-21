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
    for (final label in const [
      'Sun',
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('calendar displays Chinese weekday labels', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('zh'),
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

    for (final label in const ['日', '一', '二', '三', '四', '五', '六']) {
      expect(find.text(label), findsOneWidget);
    }
  });
}
