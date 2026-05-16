import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lunadial/l10n/app_localizations.dart';

class SettingsButtonController extends ChangeNotifier {
  final Duration visibilityDuration;

  SettingsButtonController({
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

class SettingsRevealButton extends StatelessWidget {
  final SettingsButtonController controller;
  final VoidCallback onTap;

  const SettingsRevealButton({
    super.key,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context)!;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return IgnorePointer(
          key: const Key('settings-ignore-pointer'),
          ignoring: !controller.isVisible,
          child: AnimatedOpacity(
            opacity: controller.isVisible ? 1 : 0,
            duration: const Duration(milliseconds: 300),
            child: Semantics(
              label: translations.openSettings,
              button: true,
              child: IconButton(
                key: const Key('settings-reveal-button'),
                icon: const Icon(Icons.settings),
                onPressed: onTap,
              ),
            ),
          ),
        );
      },
    );
  }
}
