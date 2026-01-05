import '../../widgets/analog_clock.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'settings_page.dart';
import '../utils/app_data.dart';
import '../widgets/table_calendar.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class ClockHomePage extends StatefulWidget {
  const ClockHomePage({super.key});

  @override
  State<ClockHomePage> createState() => _ClockHomePageState();
}

class _ClockHomePageState extends State<ClockHomePage> {
  String _currentDate = '';
  DateTime _currentTime = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Timer? _timer;

  double _calculateFontSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return (screenWidth < screenHeight ? screenWidth : screenHeight) * 0.35;
  }

  @override
  void initState() {
    super.initState();
    _updateDateTime();
    _handleWakeLock();
    _startPreciseTimer();
  }

  void _startPreciseTimer() {
    void updateTick() {
      _updateDateTime();
      final now = DateTime.now();
      final nextSecond = DateTime(now.year, now.month, now.day, now.hour, now.minute, now.second + 1);
      final delay = nextSecond.difference(now);
      _timer = Timer(delay, updateTick);
    }
    
    updateTick();
  }

  void _handleWakeLock() {
    final appData = Provider.of<AppData>(context, listen: false);
    if (appData.keepScreenOn) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }
  }

  void _toggleFullscreen() {
    final appData = Provider.of<AppData>(context, listen: false);
    appData.setFullscreen(!appData.isFullscreen);
  }

  @override
  void dispose() {
    _timer?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  void _updateDateTime() {
    setState(() {
      final now = DateTime.now();
      _currentDate = DateFormat('yyyy-MM-dd, EEEE').format(now);
      _currentTime = now;
    });
  }

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool isLandscape(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width > size.height;
  }

  bool isTablet(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide >= 600;
  }

  Widget _buildAnalogClock(BuildContext context) {
    final isTab = isTablet(context);
    final sizeFactor = isTab ? 0.7 : 0.8;
    final clockSize = MediaQuery.of(context).size.shortestSide * sizeFactor;
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 2.0, color: Colors.white),
        color: Colors.transparent,
        shape: BoxShape.circle,
      ),
      width: clockSize,
      height: clockSize,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: ClockPainter(time: _currentTime, context: context),
        ),
      ),
    );
  }

  Widget _buildCalendar(BuildContext context) {
    final isTab = isTablet(context);
    final sizeFactor = isTab ? 0.7 : 0.8;
    final calendarSize = MediaQuery.of(context).size.shortestSide * sizeFactor;
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 2.0, color: Colors.white),
        borderRadius: BorderRadius.circular(20.0),
      ),
      width: calendarSize,
      height: calendarSize,
      child: CalendarPage(
        focusedDay: _focusedDay,
        selectedDay: _selectedDay,
        onDaySelected: (selectedDay) {
          if (!isSameDay(_selectedDay, selectedDay)) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = selectedDay;
            });
          }
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
      ),
    );
  }

  Widget _buildAnalogLayout(BuildContext context) {
    final isLand = isLandscape(context);
    final isTab = isTablet(context);
    
    if (isLand && !isTab) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildAnalogClock(context),
          _buildCalendar(context),
        ],
      );
    } else if (isTab) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildAnalogClock(context),
          _buildCalendar(context),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildAnalogClock(context),
          const SizedBox(height: 20),
          _buildCalendar(context),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    final fontSize = _calculateFontSize(context);

    final clockContent = appData.isDigitalClock
        ? Semantics(
            label: 'Digital clock showing current time',
            child: Center(
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
            ),
          )
        : Semantics(
            label: 'Analog clock with calendar',
            child: _buildAnalogLayout(context),
          );

    if (appData.isFullscreen) {
      return Scaffold(
        backgroundColor: appData.selectedColor == Colors.black ? Colors.black : null,
        body: GestureDetector(
          onTap: _toggleFullscreen,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              clockContent,
              Positioned(
                top: 20,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.fullscreen_exit, color: Colors.grey),
                  onPressed: _toggleFullscreen,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('LunaDial'),
        backgroundColor: appData.selectedColor == Colors.black ? Colors.grey[900] : null,
        actions: [
          Semantics(
            label: 'Enter fullscreen mode',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.fullscreen),
              onPressed: _toggleFullscreen,
            ),
          ),
          Semantics(
            label: 'Open settings',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
          ),
        ],
      ),
      body: clockContent,
      backgroundColor: appData.selectedColor == Colors.black ? Colors.black : null,
    );
  }
}
