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
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
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
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: Column(
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9, // Make the calendar 90% of the screen width
              child: _buildCalendar(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(8.0), // Reduced padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            iconSize: 24.0, // Reduced icon size
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, _focusedDay.day);
              });
            },
          ),
          Text(
            DateFormat('MMMM yyyy').format(_focusedDay),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Reduced font size
          ),
          IconButton(
            iconSize: 24.0, // Reduced icon size
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, _focusedDay.day);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;

    final firstDayOfWeek = firstDayOfMonth.weekday;

    List<DateTime> days = [];

    // Add padding days for the first week if the first day is not Monday
    for (int i = 1; i < firstDayOfWeek; i++) {
      days.add(DateTime(_focusedDay.year, _focusedDay.month, 1 - (firstDayOfWeek - i)));
    }

    // Add all days of the month
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(_focusedDay.year, _focusedDay.month, i));
    }

    // Add padding days for the last week if the last day is not Sunday
    int paddingDays = 7 - (lastDayOfMonth.weekday % 7);
    for (int i = 1; i <= paddingDays; i++) {
      days.add(DateTime(_focusedDay.year, _focusedDay.month + 1, i));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8.0), // Reduced padding
      itemCount: days.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 4.0, // Reduced spacing
        crossAxisSpacing: 4.0, // Reduced spacing
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        final day = days[index];
        final isSameDay = _selectedDay.year == day.year &&
            _selectedDay.month == day.month &&
            _selectedDay.day == day.day;

        final isToday = DateTime.now().year == day.year &&
            DateTime.now().month == day.month &&
            DateTime.now().day == day.day;

        final isOutsideMonth = day.month != _focusedDay.month;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDay = day;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSameDay ? Theme.of(context).colorScheme.primary : null,
              borderRadius: BorderRadius.circular(8.0), // Reduced border radius
            ),
            child: Center(
              child: Text(
                day.day.toString(),
                style: TextStyle(
                  fontSize: 14.0, // Reduced font size
                  color: isSameDay
                      ? Theme.of(context).colorScheme.onPrimary
                      : isToday
                          ? Theme.of(context).colorScheme.primary
                          : isOutsideMonth
                              ? Colors.grey
                              : Colors.black,
                  fontWeight: isSameDay || isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}