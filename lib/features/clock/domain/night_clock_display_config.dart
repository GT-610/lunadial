import 'package:flutter/material.dart';

import 'package:lunadial/features/settings/domain/app_settings.dart';
import 'package:lunadial/features/settings/domain/night_mode_behavior.dart';

@immutable
class NightClockDisplayConfig {
  const NightClockDisplayConfig({
    required this.isNightModeActive,
    required this.burnInProtectionEnabled,
    required this.isLandscape,
  });

  factory NightClockDisplayConfig.resolve({
    required AppSettings settings,
    required DateTime currentTime,
    required Brightness platformBrightness,
    required bool isLandscape,
  }) {
    final isNightModeActive = switch (settings.nightModeBehavior) {
      NightModeBehavior.off => false,
      NightModeBehavior.on => true,
      NightModeBehavior.followSystem => platformBrightness == Brightness.dark,
      NightModeBehavior.scheduled => _isWithinScheduledWindow(
        currentTime: currentTime,
        startTime: settings.nightModeStartTime,
        endTime: settings.nightModeEndTime,
      ),
    };

    return NightClockDisplayConfig(
      isNightModeActive: isNightModeActive,
      burnInProtectionEnabled: settings.burnInProtectionEnabled,
      isLandscape: isLandscape,
    );
  }

  final bool isNightModeActive;
  final bool burnInProtectionEnabled;
  final bool isLandscape;

  bool get shouldUseBurnInProtection =>
      isNightModeActive && burnInProtectionEnabled;

  static bool _isWithinScheduledWindow({
    required DateTime currentTime,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  }) {
    final currentMinutes = currentTime.hour * 60 + currentTime.minute;
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;

    if (startMinutes == endMinutes) {
      return true;
    }
    if (startMinutes < endMinutes) {
      return currentMinutes >= startMinutes && currentMinutes < endMinutes;
    }

    return currentMinutes >= startMinutes || currentMinutes < endMinutes;
  }
}
