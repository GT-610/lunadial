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
    required this.today,
  });

  final DateTime focusedDay;
  final DateTime? selectedDay;
  final ValueChanged<DateTime> onDaySelected;
  final ValueChanged<DateTime> onPageChanged;
  final CalendarDensity density;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context)!;
    final isRegularDensity = density == CalendarDensity.regular;
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
    final firstDayOfWeek = firstDayOfMonth.weekday % DateTime.daysPerWeek;
    final daysInMonth = DateUtils.getDaysInMonth(
      focusedDay.year,
      focusedDay.month,
    );
    final theme = Theme.of(context);
    final weekdayHeaderColor = theme.colorScheme.secondary;
    final weekendOnSurfaceColor = theme.colorScheme.onSurface;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final cellSize = availableWidth / 7;
        final headerHeight = cellSize * (isRegularDensity ? 1.45 : 1.15);
        final weekRowHeight = cellSize * (isRegularDensity ? 0.75 : 0.62);
        final fontSize = (cellSize * (isRegularDensity ? 0.35 : 0.3)).clamp(
          9.0,
          16.0,
        );
        final weekdayFontSize = (cellSize * 0.3).clamp(10.0, 18.0);
        final iconSize = (headerHeight * 0.54).clamp(22.0, 38.0);
        final rowsNeeded = ((firstDayOfWeek + daysInMonth) / 7).ceil();
        final locale = Localizations.localeOf(context);
        final headerFormat = DateFormat(
          translations.calendarHeaderFormat,
          locale.languageCode,
        );
        final dayFormat = DateFormat.d();

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
                    constraints: BoxConstraints.tightFor(
                      width: headerHeight,
                      height: headerHeight,
                    ),
                    visualDensity: isRegularDensity
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
                        fontSize: headerHeight * 0.36,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    constraints: BoxConstraints.tightFor(
                      width: headerHeight,
                      height: headerHeight,
                    ),
                    visualDensity: isRegularDensity
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
            SizedBox(
              height: weekRowHeight,
              child: Row(
                children: List.generate(dayLabels.length, (index) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        dayLabels[index],
                        style: TextStyle(
                          fontSize: weekdayFontSize,
                          fontWeight: FontWeight.bold,
                          color: index == 0 || index == 6
                              ? weekdayHeaderColor
                              : weekendOnSurfaceColor,
                        ),
                      ),
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
                  mainAxisSpacing: isRegularDensity ? cellSize * 0.01 : 2,
                  crossAxisSpacing: isRegularDensity
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
                  final isToday = ClockController.isSameDay(day, today);

                  return GestureDetector(
                    key: Key('calendar-day-$dayNumber'),
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
                        dayFormat.format(day),
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
