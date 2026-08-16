import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lunadial/shared/presentation/app_theme_utils.dart';

void main() {
  test('dynamic color is used when enabled and available', () {
    final dynamicScheme = ColorScheme.fromSeed(
      seedColor: Colors.purple,
      brightness: Brightness.dark,
    );

    final resolved = resolveAppColorScheme(
      brightness: Brightness.dark,
      seedColor: Colors.green,
      useDynamicColor: true,
      dynamicColorScheme: dynamicScheme,
    );

    expect(resolved.primary, dynamicScheme.harmonized().primary);
  });

  test('custom seed color is used as the dynamic color fallback', () {
    final resolved = resolveAppColorScheme(
      brightness: Brightness.light,
      seedColor: Colors.orange,
      useDynamicColor: true,
    );

    expect(
      resolved,
      ColorScheme.fromSeed(
        seedColor: Colors.orange,
        brightness: Brightness.light,
      ),
    );
  });
}
