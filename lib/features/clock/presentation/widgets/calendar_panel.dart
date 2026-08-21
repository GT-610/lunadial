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
        final metrics = CalendarLayoutMetrics.forWidth(
          width: availableWidth,
          density: density,
          focusedDay: focusedDay,
        );
        final isRegularDensity = density == CalendarDensity.regular;
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
              height: metrics.headerHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    constraints: BoxConstraints.tightFor(
                      width: metrics.headerHeight,
                      height: metrics.headerHeight,
                    ),
                    visualDensity: isRegularDensity
                        ? VisualDensity.standard
                        : VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    iconSize: metrics.navigationIconSize,
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
                        fontSize: metrics.headerHeight * 0.36,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    constraints: BoxConstraints.tightFor(
                      width: metrics.headerHeight,
                      height: metrics.headerHeight,
                    ),
                    visualDensity: isRegularDensity
                        ? VisualDensity.standard
                        : VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    iconSize: metrics.navigationIconSize,
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
              height: metrics.weekdayHeaderHeight,
              child: Row(
                children: List.generate(dayLabels.length, (index) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        dayLabels[index],
                        style: TextStyle(
                          fontSize: metrics.weekdayFontSize,
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
              height: metrics.gridHeight,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: metrics.mainAxisSpacing,
                  crossAxisSpacing: metrics.crossAxisSpacing,
                  childAspectRatio: 1,
                ),
                itemCount: metrics.rowsNeeded * 7,
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
                        borderRadius: BorderRadius.circular(
                          metrics.renderedCellSize * 0.12,
                        ),
                      ),
                      child: Text(
                        dayFormat.format(day),
                        style: TextStyle(
                          fontSize: metrics.dayFontSize,
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
