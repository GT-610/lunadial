import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lunadial/shared/application/app_error_controller.dart';
import 'package:lunadial/l10n/app_localizations.dart';

class AppErrorShell extends StatelessWidget {
  final Widget child;

  const AppErrorShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppErrorController>(
      builder: (context, errorController, _) {
        final state = errorController.state;
        if (state == null) {
          return child;
        }

        return AppErrorView(
          error: state.error,
          stackTrace: state.stackTrace,
          onRetry: errorController.clear,
        );
      },
    );
  }
}

class AppErrorView extends StatelessWidget {
  final Object? error;
  final StackTrace? stackTrace;
  final VoidCallback onRetry;

  const AppErrorView({
    super.key,
    required this.error,
    required this.stackTrace,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  translations.unexpectedErrorTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  translations.unexpectedErrorMessage,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    '$error',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
                if (stackTrace != null) ...[
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 160),
                    child: SingleChildScrollView(
                      child: Text(
                        '$stackTrace',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: Text(translations.tryAgain),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
