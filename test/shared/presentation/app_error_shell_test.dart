import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:lunadial/l10n/app_localizations.dart';
import 'package:lunadial/shared/application/app_error_controller.dart';
import 'package:lunadial/shared/presentation/app_error_shell.dart';

void main() {
  testWidgets('app error shell shows fallback for explicit app errors', (
    tester,
  ) async {
    final controller = AppErrorController();

    await tester.pumpWidget(
      ChangeNotifierProvider<AppErrorController>.value(
        value: controller,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) {
            return AppErrorShell(child: child ?? const SizedBox.shrink());
          },
          home: const Scaffold(body: Text('Healthy app')),
        ),
      ),
    );

    expect(find.text('Healthy app'), findsOneWidget);

    controller.showError(StateError('boom'));
    await tester.pumpAndSettle();

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.textContaining('boom'), findsOneWidget);
  });

  testWidgets('app error view hides diagnostic details when disabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AppErrorView(
          error: StateError('sensitive error'),
          stackTrace: StackTrace.fromString('sensitive stack trace'),
          showErrorDetails: false,
          onRetry: () {},
        ),
      ),
    );

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.textContaining('sensitive error'), findsNothing);
    expect(find.textContaining('sensitive stack trace'), findsNothing);
  });
}
