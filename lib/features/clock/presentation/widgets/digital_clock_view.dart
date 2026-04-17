import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:lunadial/features/clock/domain/clock_layout.dart';
import 'package:lunadial/features/settings/domain/time_format_preference.dart';
import 'package:lunadial/l10n/app_localizations.dart';

class DigitalClockView extends StatelessWidget {
  const DigitalClockView({
    super.key,
    required this.currentTime,
    required this.layout,
    required this.timeFormatPreference,
    required this.showSeconds,
    required this.digitalClockLeadingZero,
    required this.nightModeEnabled,
    required this.isLandscape,
  });

  final DateTime currentTime;
  final DigitalClockLayoutSpec layout;
  final TimeFormatPreference timeFormatPreference;
  final bool showSeconds;
  final bool digitalClockLeadingZero;
  final bool nightModeEnabled;
  final bool isLandscape;

  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final localeName = locale.toString();
    final dateFormat = DateFormat(translations.dateFormat, localeName);
    final use24HourFormat = _resolveUse24HourFormat(context, localeName);
    final timeText = _formatTime(
      locale: locale,
      localeName: localeName,
      use24HourFormat: use24HourFormat,
    );
    final timeFontSize = _resolveTimeFontSize();
    final verticalSpacing = _resolveVerticalSpacing();
    final theme = Theme.of(context);
    final dateColor = nightModeEnabled
        ? theme.colorScheme.onSurface.withValues(alpha: 0.42)
        : theme.colorScheme.onSurface;
    final timeColor = nightModeEnabled
        ? theme.colorScheme.onSurface.withValues(alpha: 0.92)
        : theme.colorScheme.onSurface;
    final dateFontSize = nightModeEnabled && isLandscape
        ? layout.dateFontSize * 0.9
        : layout.dateFontSize;

    return Semantics(
      label: translations.digitalClockSemantics,
      child: Center(
        child: Padding(
          padding: layout.padding,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: layout.maxContentWidth),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    dateFormat.format(currentTime),
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: dateFontSize,
                      color: dateColor,
                      fontWeight: nightModeEnabled ? FontWeight.w400 : null,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: verticalSpacing),
                  Text(
                    timeText,
                    key: const Key('digital-clock-time-text'),
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: timeFontSize,
                      color: timeColor,
                      fontWeight: nightModeEnabled ? FontWeight.w300 : null,
                      letterSpacing: nightModeEnabled && isLandscape ? 2.4 : 0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _resolveTimeFontSize() {
    final base = showSeconds ? layout.timeFontSize : layout.timeFontSize * 1.08;
    if (!nightModeEnabled) {
      return base;
    }
    return isLandscape ? base * 1.12 : base * 1.04;
  }

  double _resolveVerticalSpacing() {
    final base = showSeconds
        ? layout.verticalSpacing
        : layout.verticalSpacing * 1.15;
    if (!nightModeEnabled) {
      return base;
    }
    return isLandscape ? base * 0.78 : base * 0.92;
  }

  bool _resolveUse24HourFormat(BuildContext context, String localeName) {
    switch (timeFormatPreference) {
      case TimeFormatPreference.system:
        final mediaQuery = MediaQuery.maybeOf(context);
        if (mediaQuery != null) {
          return mediaQuery.alwaysUse24HourFormat;
        }
        return !(DateFormat.jm(localeName).pattern?.contains('a') ?? true);
      case TimeFormatPreference.twelveHour:
        return false;
      case TimeFormatPreference.twentyFourHour:
        return true;
    }
  }

  String _formatTime({
    required Locale locale,
    required String localeName,
    required bool use24HourFormat,
  }) {
    if (use24HourFormat) {
      final hourPattern = digitalClockLeadingZero ? 'HH' : 'H';
      final secondPattern = showSeconds ? ':ss' : '';
      return DateFormat(
        '$hourPattern:mm$secondPattern',
        localeName,
      ).format(currentTime);
    }

    final basePattern = _twelveHourPattern(
      locale: locale,
      showSeconds: showSeconds,
      leadingZero: digitalClockLeadingZero,
    );
    return DateFormat(basePattern, localeName).format(currentTime);
  }

  String _twelveHourPattern({
    required Locale locale,
    required bool showSeconds,
    required bool leadingZero,
  }) {
    final hourPattern = leadingZero ? 'hh' : 'h';
    final minuteSecondPattern = showSeconds ? ':mm:ss' : ':mm';
    if (locale.languageCode == 'zh') {
      return 'a $hourPattern$minuteSecondPattern';
    }

    return '$hourPattern$minuteSecondPattern a';
  }
}
