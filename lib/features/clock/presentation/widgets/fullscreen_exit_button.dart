import 'dart:async';

import 'package:flutter/material.dart';

class FullscreenExitButtonController extends ChangeNotifier {
  final Duration visibilityDuration;

  FullscreenExitButtonController({
    this.visibilityDuration = const Duration(seconds: 3),
  });

  Timer? _timer;
  bool _isVisible = false;

  bool get isVisible => _isVisible;

  void showTemporarily() {
    _isVisible = true;
    notifyListeners();
    _timer?.cancel();
    _timer = Timer(visibilityDuration, hide);
  }

  void hide() {
    if (!_isVisible) {
      return;
    }

    _timer?.cancel();
    _timer = null;
    _isVisible = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class FullscreenExitButton extends StatelessWidget {
  final FullscreenExitButtonController controller;
  final VoidCallback onExit;

  const FullscreenExitButton({
    super.key,
    required this.controller,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return IgnorePointer(
          key: const Key('fullscreen-exit-ignore-pointer'),
          ignoring: !controller.isVisible,
          child: AnimatedOpacity(
            opacity: controller.isVisible ? 1 : 0,
            duration: const Duration(milliseconds: 300),
            child: IconButton(
              key: const Key('fullscreen-exit-button'),
              icon: const Icon(Icons.fullscreen_exit, color: Colors.white),
              onPressed: onExit,
            ),
          ),
        );
      },
    );
  }
}
