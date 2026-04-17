import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:lunadial/features/clock/application/clock_controller.dart';
import 'package:lunadial/features/clock/domain/clock_layout.dart';
import 'package:lunadial/l10n/app_localizations.dart';

class CalendarPanel extends StatelessWidget {
  const CalendarPanel({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onPageChanged,
    required this.density,
  });

  final DateTime focusedDay;
  final DateTime? selectedDay;
  final ValueChanged<DateTime> onDaySelected;
  final ValueChanged<DateTime> onPageChanged;
  final CalendarDensity density;

  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context)!;
    final showWeekdayHeader = density == CalendarDensity.regular;
    final dayLabels = [
      translations.sunday,
      translations.monday,
      translations.tuesday,
      translations.wednesday,
      translations.thursday,
      translations.friday,
      translations.saturday,
    ];
    final firstDayOfMonth = DateTime(focusedDay.year, focusedDay.month, 1);
    final firstDayOfWeek = firstDayOfMonth.weekday - 1;
    final daysInMonth = DateUtils.getDaysInMonth(
      focusedDay.year,
      focusedDay.month,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final cellSize = availableWidth / 7;
        final headerHeight = cellSize * (showWeekdayHeader ? 1.2 : 0.95);
        final weekRowHeight = showWeekdayHeader ? cellSize * 0.9 : 0.0;
        final fontSize = (cellSize * (showWeekdayHeader ? 0.35 : 0.3)).clamp(
          9.0,
          16.0,
        );
        final iconSize = (headerHeight * 0.46).clamp(18.0, 30.0);
        final rowsNeeded = ((firstDayOfWeek + daysInMonth) / 7).ceil();
        final locale = Localizations.localeOf(context);
        final headerFormat = DateFormat(
          translations.calendarHeaderFormat,
          locale.languageCode,
        );

        return Column(
          key: Key('calendar-${density.name}'),
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: headerHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    visualDensity: showWeekdayHeader
                        ? VisualDensity.standard
                        : VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    iconSize: iconSize,
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      onPageChanged(
                        DateTime(focusedDay.year, focusedDay.month - 1, 1),
                      );
                    },
                  ),
                  Expanded(
                    child: Text(
                      headerFormat.format(focusedDay),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize:
                            headerHeight * (showWeekdayHeader ? 0.34 : 0.28),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    visualDensity: showWeekdayHeader
                        ? VisualDensity.standard
                        : VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    iconSize: iconSize,
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () {
                      onPageChanged(
                        DateTime(focusedDay.year, focusedDay.month + 1, 1),
                      );
                    },
                  ),
                ],
              ),
            ),
            if (showWeekdayHeader)
              SizedBox(
                height: weekRowHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(dayLabels.length, (index) {
                    return Text(
                      dayLabels[index],
                      style: TextStyle(
                        fontSize: fontSize * 0.9,
                        fontWeight: FontWeight.bold,
                        color: index == 0 || index == 6
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    );
                  }),
                ),
              ),
            SizedBox(
              height: cellSize * rowsNeeded,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: showWeekdayHeader ? cellSize * 0.01 : 2,
                  crossAxisSpacing: showWeekdayHeader
                      ? availableWidth * 0.01
                      : 2,
                  childAspectRatio: 1,
                ),
                itemCount: rowsNeeded * 7,
                itemBuilder: (context, index) {
                  final dayNumber = index - firstDayOfWeek + 1;
                  if (dayNumber < 1 || dayNumber > daysInMonth) {
                    return const SizedBox.shrink();
                  }

                  final day = firstDayOfMonth.add(
                    Duration(days: dayNumber - 1),
                  );
                  final isSelected = ClockController.isSameDay(
                    day,
                    selectedDay,
                  );
                  final isToday = ClockController.isSameDay(
                    day,
                    DateTime.now(),
                  );
                  final theme = Theme.of(context);

                  return GestureDetector(
                    onTap: () => onDaySelected(day),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isToday
                            ? theme.colorScheme.primary
                            : isSelected
                            ? theme.colorScheme.secondary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(cellSize * 0.12),
                      ),
                      child: Text(
                        DateFormat.d().format(day),
                        style: TextStyle(
                          fontSize: fontSize,
                          color: isToday
                              ? theme.colorScheme.onPrimary
                              : isSelected
                              ? theme.colorScheme.onSecondary
                              : theme.colorScheme.onSurface,
                          fontWeight: isToday || isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
