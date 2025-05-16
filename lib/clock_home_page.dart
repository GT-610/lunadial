import '../widgets/analog_clock.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'settings_page.dart';
import 'app_data.dart';

class ClockHomePage extends StatefulWidget {
  const ClockHomePage({super.key});

  @override
  State<ClockHomePage> createState() => _ClockHomePageState();
}

/// State class for ClockHomePage, managing UI state and logic.
class _ClockHomePageState extends State<ClockHomePage> {
  String _currentDate = '';
  DateTime _currentTime = DateTime.now();  // 修改类型为DateTime
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  /// Calculate font size based on screen dimensions.
  double _calculateFontSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return (screenWidth < screenHeight ? screenWidth : screenHeight) * 0.35;
  }

  @override
  void initState() {
    super.initState();
    _updateDateTime();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateDateTime();
    });
  }

  /// Update current date and time every second.
  void _updateDateTime() {
    setState(() {
      final now = DateTime.now();
      _currentDate = DateFormat('yyyy-MM-dd, EEEE').format(now);
      _currentTime = now;  // 直接存储DateTime对象
    });
  }

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context); // Access AppData from Provider

    final fontSize = _calculateFontSize(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DesuClock'),
        backgroundColor: appData.selectedColor == Colors.black ? Colors.grey[900] : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()), // Navigate to SettingsPage
              );
            },
          ),
        ],
      ),
      body: appData.isDigitalClock
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentDate,
                    style: TextStyle(fontSize: fontSize * 0.3),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    DateFormat('HH:mm:ss').format(_currentTime),  // 显示时格式化
                    style: TextStyle(fontSize: fontSize),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : Row(
            children: [
              Expanded(
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 2.0, color: Colors.white),
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    width: 400.0,
                    height: 400.0,
                    child: CustomPaint(
                      painter: ClockPainter(
                          time: _currentTime, context: context),  // 直接传递DateTime对象
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: TableCalendar(
                    firstDay: DateTime.utc(2010, 10, 16),
                    lastDay: DateTime.utc(2030, 3, 14),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      if (!isSameDay(_selectedDay, selectedDay)) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      }
                    },
                    onFormatChanged: (format) {
                      if (_calendarFormat != format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      }
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      isTodayHighlighted: true,
                      selectedDecoration: BoxDecoration(
                        color: appData.selectedColor,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: appData.selectedColor.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: appData.selectedColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
      backgroundColor: appData.selectedColor == Colors.black ? Colors.black : null,
    );
  }
}