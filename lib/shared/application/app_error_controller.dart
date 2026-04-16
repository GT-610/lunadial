import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

@immutable
class AppErrorState {
  final Object error;
  final StackTrace? stackTrace;

  const AppErrorState({required this.error, this.stackTrace});
}

class AppErrorController extends ChangeNotifier {
  AppErrorState? _state;

  AppErrorState? get state => _state;
  bool get hasError => _state != null;

  void showError(Object error, [StackTrace? stackTrace]) {
    _state = AppErrorState(error: error, stackTrace: stackTrace);
    notifyListeners();
  }

  void reportFlutterError(FlutterErrorDetails details) {
    showError(details.exception, details.stack);
  }

  void clear() {
    if (_state == null) {
      return;
    }

    _state = null;
    notifyListeners();
  }
}
