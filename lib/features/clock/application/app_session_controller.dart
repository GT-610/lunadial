import 'package:flutter/foundation.dart';

class AppSessionController extends ChangeNotifier {
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
