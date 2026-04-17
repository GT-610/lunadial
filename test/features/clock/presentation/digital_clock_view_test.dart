import 'package:fl_lib/generated/l10n/lib_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lunadial/features/clock/domain/clock_layout.dart';
import 'package:lunadial/features/clock/presentation/widgets/digital_clock_view.dart';
import 'package:lunadial/features/settings/domain/time_format_preference.dart';
import 'package:lunadial/l10n/app_localizations.dart';

void main() {
  Future<void> pumpDigitalClock(
    WidgetTester tester, {
    required Size surfaceSize,
    TimeFormatPreference timeFormatPreference = TimeFormatPreference.system,
    bool showSeconds = true,
    bool digitalClockLeadingZero = true,
    bool nightModeEnabled = false,
    bool isLandscape = false,
    Locale? locale,
    bool? alwaysUse24HourFormat,
    DateTime? currentTime,
  }) async {
    await tester.binding.setSurfaceSize(surfaceSize);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final mediaQueryData = MediaQueryData(
      size: surfaceSize,
      alwaysUse24HourFormat: alwaysUse24HourFormat ?? false,
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          LibLocalizations.delegate,
          ...AppLocalizations.localizationsDelegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,
        home: MediaQuery(
          data: mediaQueryData,
          child: Scaffold(
            body: LayoutBuilder(
              builder: (context, constraints) {
                return DigitalClockView(
                  currentTime: currentTime ?? DateTime(2026, 1, 1, 12, 34, 56),
                  layout: resolveDigitalClockLayout(constraints.biggest),
                  timeFormatPreference: timeFormatPreference,
                  showSeconds: showSeconds,
                  digitalClockLeadingZero: digitalClockLeadingZero,
                  nightModeEnabled: nightModeEnabled,
                  isLandscape: isLandscape,
                );
              },
            ),
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

  testWidgets('digital clock view renders explicit 24-hour format', (
    tester,
  ) async {
    await pumpDigitalClock(
      tester,
      surfaceSize: const Size(390, 844),
      timeFormatPreference: TimeFormatPreference.twentyFourHour,
      showSeconds: true,
      digitalClockLeadingZero: true,
    );
    await tester.pumpAndSettle();

    expect(find.text('12:34:56'), findsOneWidget);
  });

  testWidgets(
    'digital clock view renders explicit 12-hour format without seconds',
    (tester) async {
      await pumpDigitalClock(
        tester,
        surfaceSize: const Size(390, 844),
        timeFormatPreference: TimeFormatPreference.twelveHour,
        showSeconds: false,
        digitalClockLeadingZero: false,
        locale: const Locale('en'),
      );
      await tester.pumpAndSettle();

      expect(find.text('12:34 PM'), findsOneWidget);
    },
  );

  testWidgets('digital clock view toggles digital leading zero for hour', (
    tester,
  ) async {
    await pumpDigitalClock(
      tester,
      surfaceSize: const Size(390, 844),
      timeFormatPreference: TimeFormatPreference.twentyFourHour,
      showSeconds: false,
      digitalClockLeadingZero: true,
      currentTime: DateTime(2026, 1, 1, 8, 34, 56),
    );
    await tester.pumpAndSettle();
    expect(find.text('08:34'), findsOneWidget);

    await pumpDigitalClock(
      tester,
      surfaceSize: const Size(390, 844),
      timeFormatPreference: TimeFormatPreference.twentyFourHour,
      showSeconds: false,
      digitalClockLeadingZero: false,
      currentTime: DateTime(2026, 1, 1, 8, 34, 56),
    );
    await tester.pumpAndSettle();
    expect(find.text('8:34'), findsOneWidget);
  });

  testWidgets('digital clock view remains stable in night landscape mode', (
    tester,
  ) async {
    await pumpDigitalClock(
      tester,
      surfaceSize: const Size(1280, 800),
      nightModeEnabled: true,
      isLandscape: true,
      showSeconds: false,
    );
    await tester.pumpAndSettle();

    expect(find.byType(DigitalClockView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
