import 'dart:async';

import 'package:flutter/foundation.dart';

class ClockController extends ChangeNotifier {
  ClockController() {
    _currentTime = DateTime.now();
    _focusedDay = DateTime(
      _currentTime.year,
      _currentTime.month,
      _currentTime.day,
    );
    _startPreciseTimer();
  }

  late DateTime _currentTime;
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  Timer? _timer;

  DateTime get currentTime => _currentTime;
  DateTime get focusedDay => _focusedDay;
  DateTime? get selectedDay => _selectedDay;

  static Duration delayUntilNextSecond(DateTime now) {
    final nextSecond = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
      now.second + 1,
    );
    return nextSecond.difference(now);
  }

  void selectDay(DateTime selectedDay) {
    if (isSameDay(_selectedDay, selectedDay)) {
      return;
    }

    _selectedDay = selectedDay;
    _focusedDay = selectedDay;
    notifyListeners();
  }

  void focusDay(DateTime focusedDay) {
    _focusedDay = DateTime(focusedDay.year, focusedDay.month, 1);
    notifyListeners();
  }

  static bool isSameDay(DateTime? left, DateTime? right) {
    if (left == null || right == null) {
      return false;
    }

    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  void _startPreciseTimer() {
    void tick() {
      _currentTime = DateTime.now();
      notifyListeners();
      _timer = Timer(delayUntilNextSecond(_currentTime), tick);
    }

    tick();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
