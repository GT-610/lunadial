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
        // Display the month and year at the top of the calendar, with navigation buttons
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
        // Show the names of the days of the week
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
                      ? Theme.of(context).colorScheme.secondary // 使用主题中的次要颜色
                      : Theme.of(context).colorScheme.onSurface, // 其他日期使用默认颜色
                ),
              ),
          ],
        ),
        // Calendar grid
        Expanded( // 新增 Expanded 使网格占据可用空间
          child: GridView.builder(
            shrinkWrap: false, // 改为 false 以允许 Expanded 控制布局
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 42, // 6 weeks x 7 days
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 2.0,  // 减少纵向间距
              crossAxisSpacing: 2.0,  // 减少横向间距
              childAspectRatio: 1.1,  // 新增宽高比调整
            ),
            itemBuilder: (context, index) {
              // Get the first day of the month
              final firstDayOfMonth = DateTime(widget.focusedDay.year, widget.focusedDay.month, 1);
              // Calculate the day of the week for the first day of the month (0 for Sunday, 6 for Saturday)
              final firstDayOfWeek = firstDayOfMonth.weekday - 1;
              // Adjust the index to align the first day of the month correctly
              final adjustedIndex = index - firstDayOfWeek;
              // If the adjusted index is negative, it means this position is empty
              if (adjustedIndex < 0) {
                return Container(); // Empty container for spacing
              }
              // Calculate the current date
              final day = firstDayOfMonth.add(Duration(days: adjustedIndex));
              final isSelected = isSameDay(day, widget.selectedDay);
              final isToday = isSameDay(day, DateTime.now()); // Check if it's today

              // Get the theme colors
              final theme = Theme.of(context);
              final todayColor = theme.colorScheme.primary; // Color for today
              final selectedColor = theme.colorScheme.secondary; // Color for selected date
              final onSurfaceColor = theme.colorScheme.onSurface; // Color that follows the main program's light or dark mode

              return GestureDetector(
                onTap: () {
                  if (isToday) { // Only allow selecting today
                    widget.onDaySelected(day);
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isToday ? todayColor : isSelected ? selectedColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(4.0),  // 缩小圆角半径
                  ),
                  child: Text(
                    DateFormat.d().format(day),
                    style: TextStyle(
                      fontSize: 14,  // 新增字体大小约束
                      color: isToday ? theme.colorScheme.onPrimary : isSelected ? theme.colorScheme.onSecondary : onSurfaceColor,
                      fontWeight: isToday ? FontWeight.bold : isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
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