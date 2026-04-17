import 'package:flutter/foundation.dart';

class AppSessionController extends ChangeNotifier {
  AppSessionController({bool initialFullscreen = false})
    : _isFullscreen = initialFullscreen;

  bool _isFullscreen = false;

  bool get isFullscreen => _isFullscreen;

  void setFullscreen(bool value) {
    if (_isFullscreen == value) {
      return;
    }

    _isFullscreen = value;
    notifyListeners();
  }

  void toggleFullscreen() {
    setFullscreen(!_isFullscreen);
  }
}
