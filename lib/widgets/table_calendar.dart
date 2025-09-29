// Table Calendar widget

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum CalendarFormat { month }

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
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  final newFocusedDay = widget.focusedDay.subtract(const Duration(days: 30));
                  widget.onPageChanged(newFocusedDay);
                },
              ),
              Text(
                DateFormat.yMMMM().format(widget.focusedDay),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () {
                  final newFocusedDay = widget.focusedDay.add(const Duration(days: 30));
                  widget.onPageChanged(newFocusedDay);
                },
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (var day in ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'])
              Text(
                day,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: day == 'Sun' || day == 'Sat'
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height * 0.5, // 设置最小高度
              ),
              child: GridView.builder(
                shrinkWrap: true, // 允许 GridView 根据内容调整高度
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 42,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 2.0,
                  crossAxisSpacing: 2.0,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, index) {
                  final firstDayOfMonth = DateTime(widget.focusedDay.year, widget.focusedDay.month, 1);
                  final firstDayOfWeek = firstDayOfMonth.weekday - 1;
                  final adjustedIndex = index - firstDayOfWeek;
                  if (adjustedIndex < 0) {
                    return Container();
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
                      if (isToday) {
                        widget.onDaySelected(day);
                      }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isToday ? todayColor : isSelected ? selectedColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(
                        DateFormat.d().format(day),
                        style: TextStyle(
                          fontSize: 14,
                          color: isToday ? theme.colorScheme.onPrimary : isSelected ? theme.colorScheme.onSecondary : onSurfaceColor,
                          fontWeight: isToday ? FontWeight.bold : isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool isSameDay(DateTime a, DateTime? b) {
    if (b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}