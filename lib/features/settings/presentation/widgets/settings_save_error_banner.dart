import 'package:flutter/material.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    return MaterialBanner(
      content: Text(
        'Settings could not be saved. ${error ?? 'Please try again.'}',
      ),
      leading: Icon(Icons.error_outline, color: colorScheme.error),
      backgroundColor: colorScheme.errorContainer,
      actions: [TextButton(onPressed: onRetry, child: const Text('Retry'))],
    );
  }
}
