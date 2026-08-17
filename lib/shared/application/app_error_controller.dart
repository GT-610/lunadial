import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

@immutable
class AppErrorState {
  final Object error;
  final StackTrace? stackTrace;

  const AppErrorState({required this.error, this.stackTrace});
}

class AppErrorController extends ChangeNotifier {
  AppErrorState? _state;
  bool _notificationScheduled = false;

  AppErrorState? get state => _state;

  void showError(Object error, [StackTrace? stackTrace]) {
    _state = AppErrorState(error: error, stackTrace: stackTrace);
    _notifyListenersWhenSafe();
  }

  void clear() {
    if (_state == null) {
      return;
    }

    _state = null;
    _notifyListenersWhenSafe();
  }

  void _notifyListenersWhenSafe() {
    final scheduler = SchedulerBinding.instance;
    if (scheduler.schedulerPhase != SchedulerPhase.persistentCallbacks) {
      notifyListeners();
      return;
    }

    if (_notificationScheduled) {
      return;
    }

    _notificationScheduled = true;
    scheduler.addPostFrameCallback((_) {
      _notificationScheduled = false;
      notifyListeners();
    });
  }
}
