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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dateFormat.format(currentTime),
              style: TextStyle(fontSize: fontSize * 0.3),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              DateFormat('HH:mm:ss').format(currentTime),
              style: TextStyle(fontSize: fontSize),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
