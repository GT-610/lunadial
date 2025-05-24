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
    Key? key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onPageChanged,
  }) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 日历头部（显示月份和年份）
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            DateFormat.yMMMM().format(widget.focusedDay),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        // 日历网格
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 42, // 6周 x 7天
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4.0,
            crossAxisSpacing: 4.0,
          ),
          itemBuilder: (context, index) {
            final day = widget.focusedDay.subtract(Duration(days: widget.focusedDay.weekday - 1)) // 当前月的第一天
                .add(Duration(days: index));
            final isSelected = isSameDay(day, widget.selectedDay);
            final isToday = isSameDay(day, DateTime.now()); // 新增：判断是否为今天

            return GestureDetector(
              onTap: () {
                if (isToday) { // 只允许选择今天
                  widget.onDaySelected(day);
                }
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isToday ? Colors.red : isSelected ? Colors.blue : Colors.transparent, // 突出标注今天
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  DateFormat.d().format(day),
                  style: TextStyle(
                    color: isToday ? Colors.white : isSelected ? Colors.white : Colors.black,
                    fontWeight: isToday ? FontWeight.bold : isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          },
        ),
        // 导航按钮（上个月/下个月）
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                final newFocusedDay = widget.focusedDay.subtract(const Duration(days: 30));
                widget.onPageChanged(newFocusedDay);
              },
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
      ],
    );
  }

  bool isSameDay(DateTime a, DateTime? b) {
    if (b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}