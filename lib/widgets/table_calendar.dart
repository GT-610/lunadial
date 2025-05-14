// Table Calendar demo
// Need to be integrated into the main app as a widget.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Table Calendar',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const CalendarPage(),
    );
  }
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: Column(
        children: [
          _buildHeader(),
          _buildWeekdayLabels(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: _buildCalendar(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            iconSize: 24.0,
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime(
                  _focusedDay.year,
                  _focusedDay.month - 1,
                  _focusedDay.day,
                );
              });
            },
          ),
          Text(
            DateFormat('MMMM yyyy').format(_focusedDay),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            iconSize: 24.0,
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime(
                  _focusedDay.year,
                  _focusedDay.month + 1,
                  _focusedDay.day,
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayLabels() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildWeekdayLabel('S'),
          _buildWeekdayLabel('M'),
          _buildWeekdayLabel('T'),
          _buildWeekdayLabel('W'),
          _buildWeekdayLabel('T'),
          _buildWeekdayLabel('F'),
          _buildWeekdayLabel('S'),
        ],
      ),
    );
  }

  Widget _buildWeekdayLabel(String day) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9 / 7,
      child: Center(
        child: Text(
          day,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;

    final firstDayOfWeek = firstDayOfMonth.weekday;

    List<DateTime> days = [];

    for (int i = 1; i < firstDayOfWeek; i++) {
      days.add(
        DateTime(_focusedDay.year, _focusedDay.month, 1 - (firstDayOfWeek - i)),
      );
    }

    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(_focusedDay.year, _focusedDay.month, i));
    }

    int paddingDays = 7 - (lastDayOfMonth.weekday % 7);
    for (int i = 1; i <= paddingDays; i++) {
      days.add(DateTime(_focusedDay.year, _focusedDay.month + 1, i));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8.0),
      itemCount: days.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 4.0,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        final day = days[index];
        final isSameDay =
            _selectedDay.year == day.year &&
            _selectedDay.month == day.month &&
            _selectedDay.day == day.day;

        final isToday =
            DateTime.now().year == day.year &&
            DateTime.now().month == day.month &&
            DateTime.now().day == day.day;

        final isOutsideMonth = day.month != _focusedDay.month;

        return SizedBox(
          width: MediaQuery.of(context).size.width * 0.9 / 7,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedDay = day;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: isSameDay ? Theme.of(context).colorScheme.primary : null,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: Text(
                  day.day.toString(),
                  style: TextStyle(
                    fontSize: 14.0,
                    color:
                        isSameDay
                            ? Theme.of(context).colorScheme.onPrimary
                            : isToday
                            ? Theme.of(context).colorScheme.primary
                            : isOutsideMonth
                            ? Colors.grey
                            : Colors.black,
                    fontWeight:
                        isSameDay || isToday
                            ? FontWeight.bold
                            : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
