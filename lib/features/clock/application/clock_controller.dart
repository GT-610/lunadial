import 'dart:async';

import 'package:flutter/foundation.dart';

class ClockController extends ChangeNotifier {
  final DateTime Function() _now;

  ClockController({DateTime Function()? now, bool startTicker = true})
    : _now = now ?? DateTime.now {
    _currentTime = _now();
    _focusedDay = DateTime(_currentTime.year, _currentTime.month, 1);
    if (startTicker) {
      _startPreciseTimer();
    }
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
    _focusedDay = DateTime(selectedDay.year, selectedDay.month, 1);
    notifyListeners();
  }

  void focusDay(DateTime focusedDay) {
    final normalizedDay = DateTime(focusedDay.year, focusedDay.month, 1);
    if (_focusedDay == normalizedDay) {
      return;
    }

    _focusedDay = normalizedDay;
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
      _currentTime = _now();
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
