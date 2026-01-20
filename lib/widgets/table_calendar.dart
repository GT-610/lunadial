import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';

class CalendarPage extends StatefulWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Function(DateTime) onDaySelected;
  final Function(DateTime) onPageChanged;

  const CalendarPage({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  @override
  CalendarPageState createState() => CalendarPageState();
}

class CalendarPageState extends State<CalendarPage> {
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
    final firstDayOfMonth = DateTime(widget.focusedDay.year, widget.focusedDay.month, 1);
    final firstDayOfWeek = firstDayOfMonth.weekday - 1;
    final daysInMonth = DateUtils.getDaysInMonth(widget.focusedDay.year, widget.focusedDay.month);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final cellSize = availableWidth / 7;
        final headerHeight = cellSize * 1.2;
        final weekRowHeight = cellSize * 0.9;
        final fontSize = (cellSize * 0.35).clamp(10.0, 16.0);
        final iconSize = (headerHeight * 0.5).clamp(20.0, 30.0);

        // Calculate the number of rows needed
        final rowsNeeded = ((firstDayOfWeek + daysInMonth) / 7).ceil();

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: headerHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    iconSize: iconSize,
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      final newFocusedDay = DateTime(
                        widget.focusedDay.year,
                        widget.focusedDay.month - 1,
                        1,
                      );
                      widget.onPageChanged(newFocusedDay);
                    },
                  ),
                  Text(
                    DateFormat.yMMMM().format(widget.focusedDay),
                    style: TextStyle(
                      fontSize: headerHeight * 0.4,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    iconSize: iconSize,
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () {
                      final newFocusedDay = DateTime(
                        widget.focusedDay.year,
                        widget.focusedDay.month + 1,
                        1,
                      );
                      widget.onPageChanged(newFocusedDay);
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: weekRowHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: dayLabels.map((day) {
                  return Text(
                    day,
                    style: TextStyle(
                      fontSize: fontSize * 0.9,
                      fontWeight: FontWeight.bold,
                      color: day == 'Sun' || day == 'Sat'
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(
              height: cellSize * rowsNeeded,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: cellSize * 0.01,
                  crossAxisSpacing: availableWidth * 0.01,
                  childAspectRatio: 1.0,
                ),
                itemCount: 42,
                itemBuilder: (context, index) {
                  final adjustedIndex = index - firstDayOfWeek;
                  if (adjustedIndex < 0 || adjustedIndex >= daysInMonth) {
                    return const SizedBox.shrink();
                  }
                  final day = firstDayOfMonth.add(Duration(days: adjustedIndex));
                  final isSelected = isSameDay(day, widget.selectedDay);
                  final isToday = isSameDay(day, DateTime.now());

                  final theme = Theme.of(context);
                  final todayColor = theme.colorScheme.primary;
                  final selectedColor = theme.colorScheme.secondary;
                  final onSurfaceColor = theme.colorScheme.onSurface;

                  return GestureDetector(
                    onTap: () {
                      widget.onDaySelected(day);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isToday
                            ? todayColor
                            : isSelected
                                ? selectedColor
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(cellSize * 0.1),
                      ),
                      child: Text(
                        DateFormat.d().format(day),
                        style: TextStyle(
                          fontSize: fontSize,
                          color: isToday
                              ? theme.colorScheme.onPrimary
                              : isSelected
                                  ? theme.colorScheme.onSecondary
                                  : onSurfaceColor,
                          fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
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

  bool isSameDay(DateTime a, DateTime? b) {
    if (b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
