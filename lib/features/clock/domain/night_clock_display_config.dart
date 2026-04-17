import 'package:flutter/widgets.dart';

@immutable
class NightClockDisplayConfig {
  const NightClockDisplayConfig({
    required this.nightModeEnabled,
    required this.burnInProtectionEnabled,
    required this.isLandscape,
  });

  final bool nightModeEnabled;
  final bool burnInProtectionEnabled;
  final bool isLandscape;

  bool get shouldUseBurnInProtection =>
      nightModeEnabled && burnInProtectionEnabled;
}
