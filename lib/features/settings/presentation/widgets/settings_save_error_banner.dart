import 'package:flutter/material.dart';

import 'package:lunadial/l10n/app_localizations.dart';

class SettingsSaveErrorBanner extends StatelessWidget {
  final Object? error;
  final VoidCallback onRetry;

  const SettingsSaveErrorBanner({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return MaterialBanner(
      content: Text(
        translations.settingsSaveFailedMessage(
          error?.toString() ?? translations.settingsSaveRetryFallback,
        ),
      ),
      leading: Icon(Icons.error_outline, color: colorScheme.error),
      backgroundColor: colorScheme.errorContainer,
      actions: [
        TextButton(onPressed: onRetry, child: Text(translations.tryAgain)),
      ],
    );
  }
}
