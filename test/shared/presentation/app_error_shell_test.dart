import 'package:fl_lib/generated/l10n/lib_l10n.dart';
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
          localizationsDelegates: const [
            LibLocalizations.delegate,
            ...AppLocalizations.localizationsDelegates,
          ],
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
}
