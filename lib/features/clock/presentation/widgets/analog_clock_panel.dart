import 'package:flutter/material.dart';

import 'package:lunadial/features/clock/domain/clock_layout.dart';
import 'package:lunadial/features/clock/presentation/widgets/analog_clock_face.dart';
import 'package:lunadial/features/clock/presentation/widgets/calendar_panel.dart';
import 'package:lunadial/l10n/app_localizations.dart';

class AnalogClockPanel extends StatelessWidget {
  final DateTime currentTime;
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final ValueChanged<DateTime> onDaySelected;
  final ValueChanged<DateTime> onPageChanged;

  const AnalogClockPanel({
    super.key,
    required this.currentTime,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context)!;
    final size = MediaQuery.sizeOf(context);
    final isTab = isTablet(size);
    final sizeFactor = isTab ? 0.7 : 0.8;
    final clockSize = size.shortestSide * sizeFactor;
    final calendarWidth = size.shortestSide * sizeFactor;
    final useHorizontalLayout = useHorizontalClockLayout(size);

    final clock = DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          width: 2,
          color: Theme.of(context).colorScheme.outline,
        ),
        shape: BoxShape.circle,
      ),
      child: AnalogClockFace(time: currentTime, size: clockSize),
    );

    final calendar = SizedBox(
      width: calendarWidth,
      child: CalendarPanel(
        focusedDay: focusedDay,
        selectedDay: selectedDay,
        onDaySelected: onDaySelected,
        onPageChanged: onPageChanged,
      ),
    );

    return Semantics(
      label: translations.analogClockSemantics,
      child: Center(
        child: useHorizontalLayout
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [clock, calendar],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [clock, const SizedBox(height: 20), calendar],
              ),
      ),
    );
  }
}
