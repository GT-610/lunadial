import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const _windowsFontFallback = <String>[
  'Segoe UI',
  'Microsoft YaHei UI',
  'Microsoft YaHei',
  'sans-serif',
];

ThemeData applyPlatformFontFallback(ThemeData theme) {
  if (defaultTargetPlatform != TargetPlatform.windows) {
    return theme;
  }

  return theme.copyWith(
    textTheme: theme.textTheme.apply(fontFamilyFallback: _windowsFontFallback),
    primaryTextTheme: theme.primaryTextTheme.apply(
      fontFamilyFallback: _windowsFontFallback,
    ),
  );
}

ColorScheme resolveAppColorScheme({
  required Brightness brightness,
  required Color seedColor,
  required bool useDynamicColor,
  ColorScheme? dynamicColorScheme,
}) {
  if (useDynamicColor && dynamicColorScheme != null) {
    return dynamicColorScheme.harmonized();
  }

  return ColorScheme.fromSeed(seedColor: seedColor, brightness: brightness);
}

ColorScheme applyOledSurfaces(ColorScheme colorScheme) {
  return colorScheme.copyWith(
    surface: Colors.black,
    surfaceDim: Colors.black,
    surfaceBright: Colors.black,
    surfaceContainerLowest: Colors.black,
    surfaceContainerLow: Colors.black,
    surfaceContainer: Colors.black,
    surfaceContainerHigh: Colors.black,
    surfaceContainerHighest: Colors.black,
  );
}
