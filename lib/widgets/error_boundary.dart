import 'package:flutter/material.dart';

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final VoidCallback? onReset;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.onReset,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool hasError = false;
  Object? error;
  StackTrace? stackTrace;

  @override
  void initState() {
    super.initState();
  }

  void _handleError(dynamic error, StackTrace stackTrace) {
    setState(() {
      hasError = true;
      this.error = error;
      this.stackTrace = stackTrace;
    });
  }

  void _resetError() {
    setState(() {
      hasError = false;
      error = null;
      stackTrace = null;
    });
    widget.onReset?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return _buildErrorFallback();
    }

    try {
      return widget.child;
    } catch (e, stack) {
      _handleError(e, stack);
      return _buildErrorFallback();
    }
  }

  Widget _buildErrorFallback() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'An unexpected error occurred. You can try again or restart the app.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _resetError,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AppErrorHandler {
  static void reportError(dynamic error, StackTrace stackTrace) {}

  static void reportFlutterError(FlutterErrorDetails details) {}
}
