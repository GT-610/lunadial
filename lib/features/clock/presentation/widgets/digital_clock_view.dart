import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:lunadial/features/clock/domain/clock_layout.dart';
import 'package:lunadial/l10n/app_localizations.dart';

class DigitalClockView extends StatelessWidget {
  const DigitalClockView({
    super.key,
    required this.currentTime,
    required this.layout,
  });

  final DateTime currentTime;
  final DigitalClockLayoutSpec layout;

  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final dateFormat = DateFormat(translations.dateFormat, locale.languageCode);

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
                    style: TextStyle(fontSize: layout.dateFontSize),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: layout.verticalSpacing),
                  Text(
                    DateFormat('HH:mm:ss').format(currentTime),
                    maxLines: 1,
                    style: TextStyle(fontSize: layout.timeFontSize),
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
}
