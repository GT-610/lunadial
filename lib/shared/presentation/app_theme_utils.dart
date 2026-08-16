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

bool usesPureBlackSurface(Color seedColor) => seedColor == Colors.black;

Color? pureBlackScaffoldBackground(Color seedColor) {
  return usesPureBlackSurface(seedColor) ? Colors.black : null;
}

Color? pureBlackAppBarBackground(Color seedColor) {
  return usesPureBlackSurface(seedColor) ? Colors.grey.shade900 : null;
}
