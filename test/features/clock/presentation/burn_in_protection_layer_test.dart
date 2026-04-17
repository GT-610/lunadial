import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lunadial/features/clock/presentation/widgets/burn_in_protection_layer.dart';

void main() {
  testWidgets('burn-in protection layer stays still when disabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: BurnInProtectionLayer(
          enabled: false,
          child: SizedBox(width: 100, height: 100),
        ),
      ),
    );

    final transform = tester.widget<Transform>(
      find.byKey(const Key('burn-in-transform')),
    );
    expect(transform.transform.getTranslation().x, 0);
    expect(transform.transform.getTranslation().y, 0);
  });

  testWidgets('burn-in protection layer shifts over time when enabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: BurnInProtectionLayer(
          enabled: true,
          stepDuration: Duration(milliseconds: 10),
          child: SizedBox(width: 100, height: 100),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 10));
    await tester.pump(const Duration(milliseconds: 900));

    final transform = tester.widget<Transform>(
      find.byKey(const Key('burn-in-transform')),
    );
    expect(transform.transform.getTranslation().x, isNonZero);
  });

  testWidgets(
    'burn-in protection layer does not snap back to origin between steps',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: BurnInProtectionLayer(
            enabled: true,
            stepDuration: Duration(milliseconds: 10),
            child: SizedBox(width: 100, height: 100),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 10));
      await tester.pump(const Duration(milliseconds: 900));

      final firstTransform = tester.widget<Transform>(
        find.byKey(const Key('burn-in-transform')),
      );
      expect(firstTransform.transform.getTranslation().x, isNonZero);

      await tester.pump(const Duration(milliseconds: 10));
      await tester.pump(const Duration(milliseconds: 1));

      final secondTransform = tester.widget<Transform>(
        find.byKey(const Key('burn-in-transform')),
      );
      expect(secondTransform.transform.getTranslation().x, isNonZero);
    },
  );
}
