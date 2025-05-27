import '../widgets/analog_clock.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'settings_page.dart';
import 'app_data.dart';
import 'widgets/table_calendar.dart';

class ClockHomePage extends StatefulWidget {
  const ClockHomePage({super.key});

  @override
  State<ClockHomePage> createState() => _ClockHomePageState();
}

/// State class for ClockHomePage, managing UI state and logic.
class _ClockHomePageState extends State<ClockHomePage> {
  String _currentDate = '';
  DateTime _currentTime = DateTime.now();  // 修改类型为DateTime
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

  // 新增: 定义 isSameDay 方法
  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);

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
                MaterialPageRoute(builder: (context) => const SettingsPage()),
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
                    DateFormat('HH:mm:ss').format(_currentTime),
                    style: TextStyle(fontSize: fontSize),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,  // 修改: 改为Column布局并添加居中
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,  // 新增: 垂直居中
                  children: [
                    Expanded(
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(width: 2.0, color: Colors.white),
                            color: Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          width: MediaQuery.of(context).size.shortestSide * 0.8,  // 修改为动态尺寸
                          height: MediaQuery.of(context).size.shortestSide * 0.8, // 修改为动态尺寸
                          child: CustomPaint(
                            painter: ClockPainter(
                                time: _currentTime, context: context),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(width: 2.0, color: Colors.white),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          width: MediaQuery.of(context).size.shortestSide * 0.8,  // 修改为动态尺寸
                          height: MediaQuery.of(context).size.shortestSide * 0.8, // 修改为动态尺寸
                          child: CalendarPage(
                            focusedDay: _focusedDay,
                            selectedDay: _selectedDay,
                            onDaySelected: (selectedDay) {
                              if (!isSameDay(_selectedDay, selectedDay)) {
                                setState(() {
                                  _selectedDay = selectedDay;
                                  _focusedDay = selectedDay;  // 修改: 更新 _focusedDay
                                });
                              }
                            },
                            onPageChanged: (focusedDay) {
                              _focusedDay = focusedDay;
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
      backgroundColor: appData.selectedColor == Colors.black ? Colors.black : null,
    );
  }
}