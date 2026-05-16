import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:lunadial/features/clock/domain/clock_layout.dart';
import 'package:lunadial/features/settings/domain/time_format_preference.dart';
import 'package:lunadial/l10n/app_localizations.dart';

class DigitalClockView extends StatefulWidget {
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
  State<DigitalClockView> createState() => _DigitalClockViewState();
}

class _DigitalClockViewState extends State<DigitalClockView> {
  DateFormat? _dateFormat;
  String? _dateFormatKey;
  DateFormat? _timeFormat;
  String? _timeFormatKey;

  DateFormat _resolveDateFormat(String localeName, String dateFormatPattern) {
    final key = '$localeName|$dateFormatPattern';
    if (_dateFormatKey != key || _dateFormat == null) {
      _dateFormatKey = key;
      _dateFormat = DateFormat(dateFormatPattern, localeName);
    }
    return _dateFormat!;
  }

  DateFormat _resolveTimeFormat({
    required String localeName,
    required bool use24HourFormat,
  }) {
    final pattern = use24HourFormat
        ? _twentyFourHourPattern()
        : _twelveHourPattern(localeName);
    final key = '$localeName|$pattern';
    if (_timeFormatKey != key || _timeFormat == null) {
      _timeFormatKey = key;
      _timeFormat = DateFormat(pattern, localeName);
    }
    return _timeFormat!;
  }

  String _twentyFourHourPattern() {
    final hourPattern = widget.digitalClockLeadingZero ? 'HH' : 'H';
    final secondPattern = widget.showSeconds ? ':ss' : '';
    return '$hourPattern:mm$secondPattern';
  }

  String _twelveHourPattern(String localeName) {
    final hourPattern = widget.digitalClockLeadingZero ? 'hh' : 'h';
    final minuteSecondPattern = widget.showSeconds ? ':mm:ss' : ':mm';
    if (localeName.startsWith('zh')) {
      return 'a $hourPattern$minuteSecondPattern';
    }
    return '$hourPattern$minuteSecondPattern a';
  }

  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context)!;
    final localeName = Localizations.localeOf(context).toString();
    final dateFormat = _resolveDateFormat(localeName, translations.dateFormat);
    final use24HourFormat = _resolveUse24HourFormat(context, localeName);
    final timeFormat = _resolveTimeFormat(
      localeName: localeName,
      use24HourFormat: use24HourFormat,
    );
    final timeText = timeFormat.format(widget.currentTime);
    final timeFontSize = _resolveTimeFontSize();
    final verticalSpacing = _resolveVerticalSpacing();
    final theme = Theme.of(context);
    final dateColor = widget.nightModeEnabled
        ? theme.colorScheme.onSurface.withValues(alpha: 0.42)
        : theme.colorScheme.onSurface;
    final timeColor = widget.nightModeEnabled
        ? theme.colorScheme.onSurface.withValues(alpha: 0.92)
        : theme.colorScheme.onSurface;
    final dateFontSize = widget.nightModeEnabled && widget.isLandscape
        ? widget.layout.dateFontSize * 0.9
        : widget.layout.dateFontSize;

    return Semantics(
      label: translations.digitalClockSemantics,
      child: Center(
        child: Padding(
          padding: widget.layout.padding,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: widget.layout.maxContentWidth),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RepaintBoundary(
                    child: Text(
                      dateFormat.format(widget.currentTime),
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: dateFontSize,
                        color: dateColor,
                        fontWeight: widget.nightModeEnabled ? FontWeight.w400 : null,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: verticalSpacing),
                  Text(
                    timeText,
                    key: const Key('digital-clock-time-text'),
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: timeFontSize,
                      color: timeColor,
                      fontWeight: widget.nightModeEnabled ? FontWeight.w300 : null,
                      letterSpacing: widget.nightModeEnabled && widget.isLandscape ? 2.4 : null,
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
    final base = widget.showSeconds
        ? widget.layout.timeFontSize
        : widget.layout.timeFontSize * 1.08;
    if (!widget.nightModeEnabled) {
      return base;
    }
    return widget.isLandscape ? base * 1.12 : base * 1.04;
  }

  double _resolveVerticalSpacing() {
    final base = widget.showSeconds
        ? widget.layout.verticalSpacing
        : widget.layout.verticalSpacing * 1.15;
    if (!widget.nightModeEnabled) {
      return base;
    }
    return widget.isLandscape ? base * 0.78 : base * 0.92;
  }

  bool _resolveUse24HourFormat(BuildContext context, String localeName) {
    switch (widget.timeFormatPreference) {
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
}
