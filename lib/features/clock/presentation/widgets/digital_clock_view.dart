import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:lunadial/l10n/app_localizations.dart';

class DigitalClockView extends StatelessWidget {
  final DateTime currentTime;
  final double fontSize;

  const DigitalClockView({
    super.key,
    required this.currentTime,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final dateFormat = DateFormat(translations.dateFormat, locale.languageCode);

    return Semantics(
      label: 'Digital clock showing current time',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final shortestSide = constraints.biggest.shortestSide;
          final clampedClockFontSize = fontSize.clamp(
            56.0,
            shortestSide * 0.58,
          );
          final clampedDateFontSize = (clampedClockFontSize * 0.3).clamp(
            16.0,
            48.0,
          );

          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      dateFormat.format(currentTime),
                      maxLines: 1,
                      style: TextStyle(fontSize: clampedDateFontSize),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      DateFormat('HH:mm:ss').format(currentTime),
                      maxLines: 1,
                      style: TextStyle(fontSize: clampedClockFontSize),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
