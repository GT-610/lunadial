import 'dart:ui';

double calculateDigitalFontSize(Size size) {
  return (size.width < size.height ? size.width : size.height) * 0.35;
}

bool isLandscape(Size size) => size.width > size.height;

bool isTablet(Size size) => size.shortestSide >= 600;

bool useHorizontalClockLayout(Size size) {
  return isLandscape(size) || isTablet(size);
}
