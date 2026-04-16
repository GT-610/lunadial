import 'package:flutter/material.dart';

bool usesPureBlackSurface(Color seedColor) => seedColor == Colors.black;

Color? pureBlackScaffoldBackground(Color seedColor) {
  return usesPureBlackSurface(seedColor) ? Colors.black : null;
}

Color? pureBlackAppBarBackground(Color seedColor) {
  return usesPureBlackSurface(seedColor) ? Colors.grey.shade900 : null;
}
